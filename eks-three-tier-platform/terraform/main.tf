data "aws_availability_zones" "available" { state = "available" }
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.18.1"
  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support = true
  public_subnet_tags = { "kubernetes.io/role/elb" = "1" }
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = "1" }
  tags = { Project = var.cluster_name, ManagedBy = "Terraform" }
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.6"
  cluster_name = var.cluster_name
  cluster_version = var.kubernetes_version
  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] # Restrict to your public IP before production use.
  cluster_addons = {
    coredns = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni = { most_recent = true }
    eks-pod-identity-agent = { most_recent = true }
  }
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  enable_irsa = true
  eks_managed_node_groups = {
    general = {
      name = "general"
      instance_types = var.instance_types
      ami_type       = "AL2023_x86_64_STANDARD"
      min_size = var.min_size
      max_size = var.max_size
      desired_size = var.desired_size
      capacity_type = "ON_DEMAND"
      labels = { role = "general" }
    }
  }
  tags = { Project = var.cluster_name, ManagedBy = "Terraform" }
}

# EBS CSI driver permissions use EKS Pod Identity (no static AWS keys in Kubernetes).
data "aws_iam_policy_document" "ebs_csi_pod_identity_trust" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "ebs_csi" {
  name               = "${var.cluster_name}-ebs-csi-pod-identity"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_pod_identity_trust.json
}
resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
data "aws_eks_addon_version" "ebs_csi" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = data.aws_eks_addon_version.ebs_csi.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  depends_on = [aws_iam_role_policy_attachment.ebs_csi, aws_eks_pod_identity_association.ebs_csi]
}
resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name    = module.eks.cluster_name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi.arn
  depends_on      = [module.eks]
}

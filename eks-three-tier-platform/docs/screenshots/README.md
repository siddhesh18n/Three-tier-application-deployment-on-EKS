# Screenshots

This directory is reserved for screenshots captured from **your own deployment**. Do not use screenshots from someone else's cluster as proof that you deployed this project.

Suggested captures:

1. `01-frontend.png` — application page with the API status visible.
2. `02-argocd.png` — Argo CD Application showing Healthy / Synced.
3. `03-eks-nodes.png` — `kubectl get nodes -o wide` output.
4. `04-grafana.png` — Grafana dashboard with pod CPU, memory and request metrics.
5. `05-github-actions.png` — successful CI build and image-publish workflow.

Official reference architecture (AWS): https://d1.awsstatic.com/solutions/guidance/architecture-diagrams/automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform_argo.pdf

Argo CD GitOps reference: https://docs.aws.amazon.com/eks/latest/userguide/argocd.html

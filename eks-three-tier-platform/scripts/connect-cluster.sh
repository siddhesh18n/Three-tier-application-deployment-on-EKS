#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../terraform"
REGION="$(terraform output -raw region)"
CLUSTER="$(terraform output -raw cluster_name)"
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER"
kubectl get nodes -o wide

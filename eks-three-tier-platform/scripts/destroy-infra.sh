#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../terraform"
echo "WARNING: this destroys the EKS cluster and associated VPC resources. Persistent database data may be lost."
read -r -p "Type DESTROY to continue: " answer
[[ "$answer" == "DESTROY" ]] || { echo "Cancelled"; exit 1; }
terraform destroy

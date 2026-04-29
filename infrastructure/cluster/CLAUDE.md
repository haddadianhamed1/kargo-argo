# EKS Cluster Configuration

This directory contains eksctl configurations for Kargo EKS clusters.

## Files

- `kargo-dev-eks.yaml` - Development cluster configuration
- `kargo-stg-eks.yaml` - Staging cluster configuration

## Instructions

### Apply Configuration

To create IAM service accounts from the YAML config:

```bash
# Ensure OIDC provider is associated
eksctl utils associate-iam-oidc-provider \
  --config-file kargo-dev-eks.yaml \
  --approve

# Create IAM service account
eksctl create iamserviceaccount \
  --config-file kargo-dev-eks.yaml \
  --include kube-system/aws-load-balancer-controller \
  --override-existing-serviceaccounts \
  --approve
```

### Install AWS Load Balancer Controller

After creating the IAM service account, install the controller with Helm:

```bash
# Add helm repo
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

# Install controller
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=kargo-dev-eks \
  --set region=us-east-1 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### Verify Installation

```bash
# Check service account has role annotation
kubectl get sa -n kube-system aws-load-balancer-controller -o yaml | grep eks.amazonaws.com/role-arn

# Check controller deployment
kubectl get deployment -n kube-system aws-load-balancer-controller
```

### Workflow

1. Update YAML configuration files
2. Apply with `eksctl create iamserviceaccount -f <file>`
3. Install additional components via Helm if needed

#!/bin/bash

# Add IAM user to EKS cluster aws-auth ConfigMap
# This allows kubectl access for the admin user

CLUSTER_NAME="kargo-dev-dev-argocd-eks-cluster"
USER_ARN="arn:aws:iam::992382364873:user/admin"
USERNAME="admin"

echo "Adding user $USERNAME to EKS cluster $CLUSTER_NAME..."

# Create the aws-auth ConfigMap patch
cat > /tmp/aws-auth-patch.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapUsers: |
    - userarn: $USER_ARN
      username: $USERNAME
      groups:
        - system:masters
EOF

# Apply the patch using AWS CLI (since kubectl doesn't work yet)
# First, let's check if aws-auth ConfigMap exists
kubectl get configmap aws-auth -n kube-system -o yaml > /tmp/current-aws-auth.yaml 2>/dev/null

if [ $? -eq 0 ]; then
  echo "aws-auth ConfigMap exists. Updating..."
  # Add user to existing ConfigMap
  kubectl patch configmap aws-auth -n kube-system --patch "$(cat /tmp/aws-auth-patch.yaml)"
else
  echo "aws-auth ConfigMap doesn't exist. Creating..."
  # Create new ConfigMap
  kubectl apply -f /tmp/aws-auth-patch.yaml
fi

echo "User added! Try: kubectl get nodes"

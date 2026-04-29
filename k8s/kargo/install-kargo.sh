#!/bin/bash

# Install Kargo on the dev cluster
echo "Installing cert-manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.0/cert-manager.yaml
echo "Waiting for cert-manager to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cert-manager -n cert-manager --timeout=300s

echo "Installing Argo Rollouts..."
kubectl create namespace argo-rollouts --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
echo "Waiting for Argo Rollouts to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argo-rollouts -n argo-rollouts --timeout=300s

echo "Installing Kargo..."

# Generate admin password and signing key
pass=$(openssl rand -base64 48 | tr -d "=+/" | head -c 32)
echo "Admin Password: $pass"
hashed_pass=$(htpasswd -bnBC 10 "" $pass | tr -d ':\n')
signing_key=$(openssl rand -base64 48 | tr -d "=+/" | head -c 32)

# Install Kargo using OCI registry (without cert-manager)
helm install kargo \
  oci://ghcr.io/akuity/kargo-charts/kargo \
  --namespace kargo \
  --create-namespace \
  --values values.yaml \
  --set api.adminAccount.passwordHash=$hashed_pass \
  --set api.adminAccount.tokenSigningKey=$signing_key \
  --wait

# Create the kargo-argocd namespace
kubectl create namespace kargo-argocd --dry-run=client -o yaml | kubectl apply -f -

# Apply Kargo configurations
echo "Applying Kargo configurations..."
kubectl apply -f project.yaml
kubectl apply -f warehouse.yaml
kubectl apply -f dev-stage.yaml
kubectl apply -f staging-stage.yaml

echo "Kargo installation complete!"
echo ""
echo "Admin Password: $pass"
echo ""
echo "Deploying Istio configuration..."
kubectl apply -f kargo-gateway.yaml
kubectl apply -f kargo-istio-dev.yaml
echo ""
echo "🎉 Kargo Access Information:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌍 URL: https://kargo-dev.hamedstock.com"
echo "👤 Username: admin"
echo "🔑 Password: $pass"
echo ""
echo "📝 Note: Access through Istio Gateway (same IP restriction as other apps)"

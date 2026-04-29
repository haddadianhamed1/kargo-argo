#!/bin/bash

# ArgoCD Helm Deployment Script
# This script deploys ArgoCD using the official Helm chart

set -e

echo "🚀 Deploying ArgoCD using Helm..."

# Add ArgoCD Helm repository
echo "📦 Adding ArgoCD Helm repository..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create namespace if it doesn't exist
echo "📁 Creating argocd namespace..."
kubectl apply -f namespace.yaml

# Deploy ArgoCD with custom values
echo "🎯 Installing ArgoCD with custom values..."
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --values values.yaml \
  --timeout 10m \
  --wait

echo "✅ ArgoCD deployed successfully!"

# Get the load balancer URL
echo ""
echo "🌐 Getting ArgoCD access information..."
echo "Waiting for load balancer to be provisioned..."

# Wait for ingress to get an address
kubectl wait --for=condition=ready ingress/argocd-server \
  --namespace argocd \
  --timeout=300s || echo "⚠️  Ingress not ready yet, check manually"

# Get ingress details
INGRESS_HOST=$(kubectl get ingress argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "Not available yet")

echo ""
echo "🎉 ArgoCD Access Information:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌍 URL: https://${INGRESS_HOST}"
echo "👤 Username: admin"
echo "🔑 Password: admin123 (change this after first login!)"
echo ""
echo "📝 Note: Access is restricted to IP 24.130.139.84/32"
echo ""
echo "🔧 To change the admin password:"
echo "   argocd admin initial-password -n argocd"
echo ""
echo "📊 To check deployment status:"
echo "   kubectl get pods -n argocd"
echo "   kubectl get ingress -n argocd"

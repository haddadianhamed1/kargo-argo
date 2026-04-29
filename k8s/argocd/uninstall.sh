#!/bin/bash

# ArgoCD Helm Uninstall Script
# This script removes ArgoCD deployment

set -e

echo "🗑️  Uninstalling ArgoCD..."

# Uninstall ArgoCD Helm release
echo "📦 Removing ArgoCD Helm release..."
helm uninstall argocd --namespace argocd || echo "ArgoCD release not found"

# Optionally remove the namespace (uncomment if you want to remove it completely)
echo "⚠️  To remove the namespace completely, run:"
echo "   kubectl delete namespace argocd"

echo "✅ ArgoCD uninstalled successfully!"
echo ""
echo "📝 Note: The namespace 'argocd' is preserved. Delete manually if needed."

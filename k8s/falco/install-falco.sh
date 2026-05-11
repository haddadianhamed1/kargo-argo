#!/bin/bash

# Falco Security Monitoring Installation Script for Kargo Environments
# Usage: ./install-falco.sh [dev|stg]

set -e

# Check if environment parameter is provided
if [ $# -eq 0 ]; then
    echo "❌ Error: Environment parameter required"
    echo "Usage: ./install-falco.sh [dev|stg]"
    echo ""
    echo "Examples:"
    echo "  ./install-falco.sh dev    # Deploy to development"
    echo "  ./install-falco.sh stg    # Deploy to staging"
    exit 1
fi

ENV=$1

# Validate environment parameter
if [ "$ENV" != "dev" ] && [ "$ENV" != "stg" ]; then
    echo "❌ Error: Invalid environment '$ENV'"
    echo "Valid environments: dev, stg"
    exit 1
fi

# Set environment-specific variables
if [ "$ENV" = "dev" ]; then
    ENV_NAME="Development"
elif [ "$ENV" = "stg" ]; then
    ENV_NAME="Staging"
fi

echo "🛡️  Installing Falco security monitoring for $ENV_NAME environment..."

# Create namespace if it doesn't exist
echo "📦 Creating falco namespace..."
kubectl create namespace falco --dry-run=client -o yaml | kubectl apply -f -

# Add Falco Helm repository
echo "📋 Adding Falco Helm repository..."
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

# Install Falco with values file
echo "🚀 Installing Falco with $ENV configuration..."
helm upgrade --install falco falcosecurity/falco \
  --namespace falco \
  --values overlays/$ENV/values.yaml \
  --wait \
  --timeout=300s

echo "⏳ Waiting for Falco deployment to be ready..."
kubectl wait --for=condition=Available deployment/falco-falcosidekick -n falco --timeout=300s

echo "✅ Falco installation completed successfully for $ENV_NAME!"
echo ""

# Check installation status
echo "📊 Checking Falco installation status..."
echo ""
echo "🔧 Falco pods:"
kubectl get pods -n falco

echo ""
echo "🌐 Falco services:"
kubectl get svc -n falco

echo ""
echo "📋 Falco configuration:"
kubectl get configmap -n falco

echo ""
echo "🎯 Falco is ready for $ENV_NAME! Security monitoring is now active."
echo "   - Falcosidekick enabled for alert forwarding"
echo "   - Web UI enabled for dashboard access"
echo "   - Real-time security event detection active"
echo ""
echo "🌐 To access Falco UI, run:"
echo "   kubectl port-forward -n falco svc/falco-falcosidekick-ui 2802:2802"
echo "   Then open: http://localhost:2802"

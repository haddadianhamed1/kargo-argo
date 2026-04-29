#!/bin/bash

# Istio Installation Script for Kargo Environments
# Usage: ./deploy-istio.sh [dev|stg]

set -e

# Check if environment parameter is provided
if [ $# -eq 0 ]; then
    echo "❌ Error: Environment parameter required"
    echo "Usage: ./deploy-istio.sh [dev|stg]"
    echo ""
    echo "Examples:"
    echo "  ./deploy-istio.sh dev    # Deploy to development"
    echo "  ./deploy-istio.sh stg    # Deploy to staging"
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
    LB_NAME="kargo-dev-istio-public"
elif [ "$ENV" = "stg" ]; then
    ENV_NAME="Staging"
    LB_NAME="kargo-stg-istio-public"
fi

echo "🚀 Installing Istio service mesh for $ENV_NAME environment..."

# Install Istio using the operator configuration
echo "📦 Installing Istio with $ENV operator configuration..."
$HOME/.istioctl/bin/istioctl install -f istio-operator-$ENV.yaml -y

echo "⏳ Waiting for Istio installation to complete..."
kubectl wait --for=condition=Available deployment/istiod -n istio-system --timeout=300s

# Label default namespace for Istio injection
echo "🏷️  Enabling Istio sidecar injection for default namespace..."
kubectl label namespace default istio-injection=enabled --overwrite

# Create public ALB ingress for Istio gateway
echo "🌐 Creating $ENV public ALB ingress..."
kubectl apply -f istio-public-alb-$ENV.yaml

echo "✅ Istio installation completed successfully for $ENV_NAME!"
echo ""

# Check installation status
echo "📊 Checking Istio installation status..."
echo ""
echo "🔧 Istio control plane:"
kubectl get pods -n istio-system

echo ""
echo "🌐 Istio ingress gateway service:"
kubectl get svc -n istio-system istio-ingressgateway

echo ""
echo "📋 $ENV_NAME public ALB ingress:"
kubectl get ingress -n istio-system istio-public-alb

echo ""
echo "🎯 Istio is ready for $ENV_NAME! You can now deploy applications with Istio sidecar injection."
echo "   - Default namespace has istio-injection=enabled"
echo "   - Public access via ALB with SSL certificate"
echo "   - Load balancer name: $LB_NAME"
echo "   - Access restricted to IP: 24.130.139.84/32"

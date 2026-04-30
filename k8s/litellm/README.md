# LiteLLM GitOps Deployment

This directory contains the GitOps deployment manifests for LiteLLM with AWS Bedrock integration.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                ArgoCD Applications                  │
├─────────────────────────────────────────────────────┤
│  1. litellm-secrets  →  Kubernetes Secrets         │
│  2. litellm          →  Helm Chart (OCI)           │
└─────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────┐
│                LiteLLM Pod                          │
│  • IRSA ServiceAccount                              │
│  • AWS Bedrock Integration                          │
│  • DeepSeek R1 Model                                │
│  • RDS PostgreSQL Backend                           │
└─────────────────────────────────────────────────────┘
```

## Components

### 1. Base Manifests (`base/`)
- `namespace.yaml` - LiteLLM namespace
- `secrets.yaml` - Required secrets (master key, DB credentials, salt key)
- `values-bedrock.yaml` - Helm values for Bedrock configuration
- `kustomization.yaml` - Base kustomization

### 2. Environment Overlays (`overlays/`)
- `dev/` - Development-specific patches and configurations

### 3. ArgoCD Applications (`../../argocd/applications/`)
- `litellm-secrets.yaml` - Deploys secrets via Kustomize
- `litellm.yaml` - Deploys LiteLLM via Helm (OCI registry)

## Deployment Process

### Prerequisites
1. ✅ AWS Bedrock IAM role deployed via Terraform
2. ✅ RDS PostgreSQL instance available
3. ✅ EKS cluster with ArgoCD installed

### GitOps Deployment Steps

1. **Update Secrets** (for production):
   ```bash
   # Edit k8s/litellm/base/secrets.yaml
   # Replace placeholder values with actual secrets
   ```

2. **Commit and Push**:
   ```bash
   git add k8s/litellm/
   git commit -m "feat(litellm): add GitOps deployment for Bedrock integration"
   git push origin main
   ```

3. **Deploy via ArgoCD**:
   ```bash
   # Apply ArgoCD applications
   kubectl apply -f k8s/argocd/applications/litellm-secrets.yaml
   kubectl apply -f k8s/argocd/applications/litellm.yaml
   ```

4. **Verify Deployment**:
   ```bash
   # Check ArgoCD applications
   kubectl get applications -n argocd | grep litellm

   # Check pods
   kubectl get pods -n litellm

   # Check logs
   kubectl logs -n litellm -l app=litellm
   ```

## Configuration

### Bedrock Models
Currently configured with:
- **DeepSeek R1**: `bedrock/us.deepseek.r1-v1:0`

### Database
- **Type**: RDS PostgreSQL
- **Endpoint**: `litellm-instance-1.cmru28caiqsp.us-east-1.rds.amazonaws.com`
- **Database**: `litellm`
- **SSL**: Required

### IRSA Integration
- **ServiceAccount**: `litellm`
- **IAM Role**: `arn:aws:iam::992382364873:role/dev-litellm-bedrock-role`
- **AWS Region**: `us-east-1`

## Testing

### Internal Testing
```bash
# Port forward to access LiteLLM API
kubectl port-forward -n litellm svc/litellm 4000:4000

# Test health endpoint
curl http://localhost:4000/health

# Test model endpoint
curl -X POST http://localhost:4000/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_MASTER_KEY" \
  -d '{
    "model": "deepseek-r1",
    "prompt": "Hello, world!",
    "max_tokens": 50
  }'
```

### External Access (Future)
- Add Istio Gateway and VirtualService
- Configure external domain (e.g., `litellm-dev.hamedstock.com`)
- Add authentication and rate limiting

## Security Notes

🔒 **Important**: The current secrets in `base/secrets.yaml` contain placeholder values. For production:

1. **Use Sealed Secrets**: Convert to SealedSecrets for secure GitOps
2. **External Secret Operator**: Use AWS Secrets Manager integration
3. **Strong Keys**: Generate cryptographically strong master and salt keys
4. **Database Security**: Ensure RDS encryption and secure password

## Monitoring

### Health Checks
- **Liveness**: `/health/liveliness`
- **Readiness**: `/health/readiness`

### Logs
```bash
# Application logs
kubectl logs -n litellm -l app=litellm -f

# Migration job logs
kubectl logs -n litellm -l job-name=litellm-migration
```

## Scaling

### Horizontal Pod Autoscaler
```bash
# Enable HPA in values-bedrock.yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

## Troubleshooting

### Common Issues

1. **Pod Fails to Start**
   ```bash
   kubectl describe pods -n litellm
   kubectl logs -n litellm -l app=litellm
   ```

2. **Database Connection Issues**
   ```bash
   # Check RDS endpoint accessibility
   kubectl run -it --rm debug --image=postgres:15 -- psql -h litellm-instance-1.cmru28caiqsp.us-east-1.rds.amazonaws.com -U litellm -d litellm
   ```

3. **Bedrock Permission Issues**
   ```bash
   # Check service account annotations
   kubectl get sa litellm -n litellm -o yaml

   # Test IAM role assumption
   kubectl exec -it deployment/litellm -n litellm -- aws sts get-caller-identity
   ```

## Next Steps

1. **Kargo Integration**: Add to Kargo pipeline for automated promotions
2. **External Access**: Configure Istio ingress
3. **Monitoring**: Add Prometheus metrics and Grafana dashboards
4. **Security**: Implement proper secret management
5. **Multi-Model**: Add more Bedrock models (Claude, Titan, etc.)

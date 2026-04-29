# ArgoCD Deployment

This directory contains Helm-based ArgoCD deployment configurations for the Kargo EKS cluster.

## 📁 Files

- `namespace.yaml` - ArgoCD namespace definition
- `values.yaml` - Helm values for ArgoCD configuration
- `deploy.sh` - Deployment script using Helm
- `uninstall.sh` - Uninstallation script
- `README.md` - This documentation

## 🔒 Security Configuration

- **IP Restriction**: Access is limited to `24.130.139.84/32`
- **AWS Load Balancer**: Uses ALB with SSL redirect
- **Admin Password**: Default is `admin123` (change immediately after deployment)

## 🚀 Quick Deploy

```bash
# Ensure you're connected to the right cluster
kubectl config current-context

# Deploy ArgoCD
cd k8s/argocd
./deploy.sh
```

## 🎯 Access ArgoCD

1. Wait for the ALB to be provisioned (5-10 minutes)
2. Get the ALB hostname:
   ```bash
   kubectl get ingress argocd-server -n argocd
   ```
3. Access via the provided URL with:
   - **Username**: `admin`
   - **Password**: `admin123`

## 🔧 Post-Deployment Steps

### 1. Change Admin Password
```bash
# Get current password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Login with argocd CLI
argocd login <ALB_HOSTNAME>

# Change password
argocd account update-password
```

### 2. Add Git Repositories
Via ArgoCD UI:
- Go to Settings > Repositories
- Add your Git repositories for application deployments

### 3. Configure RBAC (Optional)
Edit `values.yaml` to modify RBAC policies and redeploy:
```bash
helm upgrade argocd argo/argo-cd -n argocd -f values.yaml
```

## 📊 Monitoring

```bash
# Check pod status
kubectl get pods -n argocd

# Check ingress status
kubectl get ingress -n argocd

# View ArgoCD server logs
kubectl logs -n argocd deployment/argocd-server

# Check all ArgoCD resources
kubectl get all -n argocd
```

## 🔍 Troubleshooting

### ALB Not Accessible
1. Verify AWS Load Balancer Controller is running:
   ```bash
   kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
   ```

2. Check ingress annotations:
   ```bash
   kubectl describe ingress argocd-server -n argocd
   ```

### Pods Not Starting
1. Check resource limits and node capacity
2. Verify node groups are running:
   ```bash
   kubectl get nodes
   ```

### IP Access Issues
- Ensure your current IP is `24.130.139.84`
- Check ALB security groups in AWS console

## 🗑️ Uninstall

```bash
./uninstall.sh
```

To completely remove including namespace:
```bash
kubectl delete namespace argocd
```

## 🔗 Useful Links

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD Helm Chart](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)

## 📝 Configuration Details

### Helm Values Highlights
- **Ingress**: ALB with IP restriction
- **Resources**: Optimized for development environment
- **Security**: RBAC configured with admin/readonly roles
- **TLS**: SSL redirect enabled (configure certificate in values.yaml)

### Default Repositories
- ArgoCD example apps
- Argo Helm chart repository

Modify `values.yaml` to add your own repositories and adjust configuration as needed.

# Kargo Configuration

This directory contains Kargo configuration for GitOps promotions between dev and staging environments.

## Installation

Run the installation script:
```bash
./install-kargo.sh
```

## Architecture

**Promotion Pipeline:**
```
ECR Image → Warehouse → Dev Stage → Staging Stage
```

- **Warehouse**: Tracks new container images from ECR
- **Dev Stage**: Automatically deploys from main branch
- **Staging Stage**: Manual promotion from dev

## Files

- `project.yaml` - Kargo project configuration
- `warehouse.yaml` - Tracks ECR container images
- `stages.yaml` - Dev and staging stage definitions
- `install-kargo.sh` - Installation script

## Usage

1. **Install Kargo**: Run `./install-kargo.sh`

2. **Access UI**:
   Open: https://kargo-dev.hamedstock.com
   (Exposed via Istio Gateway - same IP restrictions as other apps)

3. **Promote to Staging**:
   - View dev stage in Kargo UI
   - Click "Promote" to move changes to staging
   - Kargo will update the staging ArgoCD application

## ArgoCD Integration

Kargo works with these ArgoCD applications:
- `fastapi-app-dev` (dev cluster)
- `fastapi-app-staging` (staging cluster)

When you promote in Kargo, it updates the image tag in the staging application automatically.

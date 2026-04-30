# AWS Bedrock + LiteLLM Implementation Plan

## Project Overview

Deploy AWS Bedrock integration with LiteLLM on existing EKS clusters, following GitOps practices and integrating with the current ArgoCD + Kargo pipeline.

## Goals
- Multi-model AI API gateway using LiteLLM
- Access to all available AWS Bedrock models
- Internal and external API access via Istio
- Full GitOps integration (dev → staging promotion)
- Authentication, monitoring, and observability
- Production-ready deployment

---

## Implementation Steps

### Step 1: Foundation & Planning ⏳
**Objective:** Set up infrastructure foundation for Bedrock access

**Tasks:**
- [ ] Create Terraform module structure (`infrastructure/terraform/bedrock/`)
- [ ] Set up IAM roles and policies for Bedrock model access
- [ ] Configure IRSA (IAM Roles for Service Accounts) for EKS integration
- [ ] Test basic AWS Bedrock API connectivity
- [ ] Document available Bedrock models and regions

**Deliverables:**
- `infrastructure/terraform/bedrock/` module
- IAM roles with least-privilege Bedrock access
- Test script to verify Bedrock connectivity
- Environment-specific configurations (dev/staging)

**Duration:** 1-2 hours

---

### Step 2: Basic LiteLLM Deployment ⏳
**Objective:** Deploy LiteLLM to dev cluster with basic functionality

**Tasks:**
- [ ] Create Kubernetes manifests for LiteLLM
- [ ] Configure LiteLLM for initial Bedrock models (Claude 3, Titan)
- [ ] Set up service account with IRSA
- [ ] Deploy to dev cluster manually
- [ ] Test internal API endpoints
- [ ] Verify model switching and basic functionality

**Deliverables:**
- `k8s/litellm/base/` Kustomize manifests
- LiteLLM configuration for Bedrock models
- Working API within dev cluster
- Basic health checks and readiness probes

**Duration:** 2-3 hours

---

### Step 3: External Access & Security 🔒
**Objective:** Enable external access with proper security controls

**Tasks:**
- [ ] Create Istio Gateway and VirtualService
- [ ] Configure external domain (e.g., `litellm-dev.hamedstock.com`)
- [ ] Implement API key authentication
- [ ] Set up TLS termination
- [ ] Test external API access
- [ ] Configure IP restrictions (matching existing setup)

**Deliverables:**
- `k8s/istio/litellm/` Istio configurations
- External API endpoint with HTTPS
- API key management system
- Security policies and access controls

**Duration:** 2-3 hours

---

### Step 4: GitOps Integration 🔄
**Objective:** Integrate with existing ArgoCD + Kargo pipeline

**Tasks:**
- [ ] Create ArgoCD Application for LiteLLM
- [ ] Set up Kustomize overlays for dev/staging
- [ ] Configure Kargo warehouse and stages
- [ ] Add LiteLLM to promotion pipeline
- [ ] Test automated deployment and promotion
- [ ] Update CI/CD workflows

**Deliverables:**
- ArgoCD Application manifests
- Kustomize overlays (`k8s/litellm/overlays/{dev,stg}/`)
- Kargo pipeline configuration
- Automated dev → staging promotion
- Documentation for deployment process

**Duration:** 3-4 hours

---

### Step 5: Multi-Model & Production 🚀
**Objective:** Add all Bedrock models and deploy to staging

**Tasks:**
- [ ] Configure all available Bedrock models
- [ ] Add model-specific configurations and limits
- [ ] Deploy to staging cluster
- [ ] Set up CloudWatch logging and monitoring
- [ ] Configure resource limits and autoscaling
- [ ] Load testing and performance validation

**Deliverables:**
- Complete model catalog (Claude, Llama, Titan, Cohere, etc.)
- Staging environment deployment
- Monitoring and alerting setup
- Performance benchmarks
- Resource optimization

**Duration:** 3-4 hours

---

### Step 6: Advanced Features ⭐
**Objective:** Production-ready features and observability

**Tasks:**
- [ ] Implement rate limiting and quotas
- [ ] Add request/response caching
- [ ] Set up comprehensive metrics (Prometheus/Grafana)
- [ ] Configure log aggregation and analysis
- [ ] Add request tracing and debugging
- [ ] Create operational runbooks
- [ ] Security audit and hardening

**Deliverables:**
- Rate limiting policies
- Caching layer configuration
- Full observability stack
- Operational documentation
- Security review results
- Performance optimization

**Duration:** 4-5 hours

---

## Technical Architecture

### Infrastructure Components
```
┌─────────────────────────────────────────────────────┐
│                AWS Bedrock Models                   │
│  Claude 3 | Llama | Titan | Cohere | AI21 | ...    │
└─────────────────────┬───────────────────────────────┘
                      │ IAM Roles + Policies
                      ▼
┌─────────────────────────────────────────────────────┐
│               LiteLLM Gateway                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   │
│  │    Dev      │ │   Staging   │ │    Prod     │   │
│  │ EKS Cluster │ │ EKS Cluster │ │ EKS Cluster │   │
│  └─────────────┘ └─────────────┘ └─────────────┘   │
└─────────────────────┬───────────────────────────────┘
                      │ Istio Gateway
                      ▼
┌─────────────────────────────────────────────────────┐
│          External API Access (HTTPS)               │
│     litellm-dev.hamedstock.com                     │
│     litellm-stg.hamedstock.com                     │
└─────────────────────────────────────────────────────┘
```

### GitOps Flow
```
Code Push → ECR Build → Kargo Detection → ArgoCD Sync
    ↓           ↓            ↓              ↓
  GitHub   →  Container  →  Dev Stage  →  K8s Deploy
                            ↓
                       Manual Promote
                            ↓
                       Staging Stage → K8s Deploy
```

---

## File Structure
```
kargo-argocd/
├── infrastructure/terraform/bedrock/
│   ├── main.tf              # Bedrock IAM resources
│   ├── variables.tf         # Input variables
│   ├── outputs.tf          # Module outputs
│   ├── versions.tf         # Provider versions
│   └── env/
│       ├── dev.tfvars      # Dev environment config
│       └── stg.tfvars      # Staging environment config
├── k8s/litellm/
│   ├── base/               # Base Kustomize manifests
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap.yaml
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/            # Dev-specific overrides
│       └── stg/            # Staging-specific overrides
├── k8s/istio/litellm/
│   ├── gateway.yaml        # Istio Gateway
│   ├── virtualservice.yaml # Routing rules
│   └── security.yaml      # AuthZ policies
└── k8s/argocd/applications/
    └── litellm.yaml        # ArgoCD Application
```

---

## Success Criteria

### Step 1 Success
- [ ] IAM roles created and tested
- [ ] Bedrock API accessible from EKS

### Step 2 Success
- [ ] LiteLLM pod running in dev cluster
- [ ] Can call Claude/Titan models via internal API

### Step 3 Success
- [ ] External API accessible via HTTPS
- [ ] API key authentication working

### Step 4 Success
- [ ] ArgoCD deploys LiteLLM automatically
- [ ] Can promote dev → staging via Kargo

### Step 5 Success
- [ ] All Bedrock models available
- [ ] Staging deployment working
- [ ] Monitoring and logs operational

### Step 6 Success
- [ ] Production-ready feature set
- [ ] Full observability and operational readiness

---

## Notes & Decisions
- **Environment Strategy:** Start with dev, promote to staging, prepare for production
- **Security Approach:** IRSA + least privilege IAM, API keys, IP restrictions
- **Model Strategy:** Start with Claude 3 + Titan, expand to all available models
- **Monitoring Strategy:** CloudWatch + Prometheus + Grafana integration
- **GitOps Strategy:** Follow existing ArgoCD + Kargo pattern

---

## Progress Tracking
- [x] Plan created and documented
- [x] Step 1: Foundation & Planning ✅ COMPLETE
- [ ] Step 2: Basic LiteLLM Deployment
- [ ] Step 3: External Access & Security
- [ ] Step 4: GitOps Integration
- [ ] Step 5: Multi-Model & Production
- [ ] Step 6: Advanced Features

**Last Updated:** 2026-04-29
**Current Step:** Step 2 - Basic LiteLLM Deployment

### Step 1 Results ✅
- Terraform module created: `infrastructure/terraform/bedrock/`
- IAM Role: `arn:aws:iam::992382364873:role/dev-litellm-bedrock-role`
- IAM Policy: `dev-litellm-bedrock-policy`
- Model Access: `anthropic.claude-3-5-sonnet-20241022-v2:0`
- IRSA Configuration: Ready for `litellm:litellm-sa`

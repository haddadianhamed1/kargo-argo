# Kargo ArgoCD Repository

This repository contains a FastAPI application and related tooling for Kargo ArgoCD integration.

## Project Structure

```
kargo-argocd/
├── applications/              # FastAPI application directory
│   ├── main.py               # Main FastAPI application with 4 endpoints
│   ├── requirements.txt      # Python dependencies
│   ├── Dockerfile            # Container build configuration
│   ├── .dockerignore         # Docker build exclusions
│   ├── README.md             # Application-specific documentation
│   └── CLAUDE.md             # Application development context
├── infrastructure/           # Infrastructure as Code
│   ├── terraform/           # Terraform configurations
│   │   └── vpc/             # VPC networking setup
│   │       ├── env/         # Environment-specific configs
│   │       │   ├── dev.tfvars  # Development settings
│   │       │   └── stg.tfvars  # Staging settings
│   │       └── *.tf         # VPC module files
│   └── cluster/             # EKS cluster configurations
│       ├── kargo-dev-eks.yaml   # Development cluster
│       └── kargo-stg-eks.yaml   # Staging cluster
├── k8s/                      # Kubernetes manifests
│   ├── app/                 # Application deployments
│   │   ├── base/           # Base Kustomize manifests
│   │   └── overlays/       # Environment overlays (dev/stg)
│   ├── argocd/             # ArgoCD Helm configuration
│   ├── istio/              # Istio service mesh setup
│   └── kargo/              # Kargo GitOps pipeline
├── scripts/                  # Custom validation scripts
│   ├── check_branch_name.py  # Branch naming validator
│   └── check_commit_msg.py   # Commit message validator
├── .github/                  # GitHub templates and workflows
│   ├── pull_request_template.md  # PR template
│   └── workflows/
│       ├── branch-name-check.yml     # Branch/commit validation workflow
│       └── claude-code-review.yml    # AI-powered code review workflow
├── .pre-commit-config.yaml   # Pre-commit hooks configuration
└── CLAUDE.md                 # This file - repository documentation
```

## Applications Directory

The `applications/` directory contains a FastAPI web service with four endpoints:

- **GET /hiv1** - Returns "hiv1"
- **GET /hiv2** - Returns "hiv2"
- **GET /hamed** - Returns "hamed"
- **GET /test2** - Returns "test2"

### Running the FastAPI Application

```bash
cd applications
pip install -r requirements.txt
python main.py
```

The application will be available at http://localhost:8000 with:
- Interactive API docs at `/docs` (Swagger UI)
- Alternative docs at `/redoc` (ReDoc)

### Docker Support

The application includes Docker support for containerized deployment:

```bash
cd applications
docker build -t fastapi-app .
docker run -p 8000:8000 fastapi-app
```

## Jira Integration

This repository is integrated with Jira for task and requirement management.

### Jira Project Details
- **Project Name**: Demo
- **Project Key**: DEMO
- **Instance**: haddadianapplication.atlassian.net
- **Access**: Via Claude Code MCP integration

### Available Issue Types
- 📋 **Task** (DEMO-XXX) - Small, distinct pieces of work
- 📖 **Story** (DEMO-XXX) - User functionality and features
- 🐛 **Bug** (DEMO-XXX) - Problems or errors to fix
- 🎯 **Epic** (DEMO-XXX) - Large features spanning multiple stories/tasks
- 📝 **Subtask** (DEMO-XXX) - Components of larger tasks

### Creating Tickets with Claude Code
When working with Claude Code, you can create Jira tickets directly:

```
Example: "Create a Jira ticket for implementing user authentication feature"
```

Claude will create the ticket and provide the ticket number for branch naming.

### Example Workflow
```bash
# 1. Create Jira ticket first (via Claude or Jira UI)
# Ticket created: DEMO-127 "Add user dashboard feature"

# 2. Create branch with ticket number
git checkout -b feat/DEMO-127-user-dashboard

# 3. Make changes and commit with ticket reference
git commit -m "feat(dashboard): add user dashboard component (DEMO-127)"

# 4. Push and create PR with ticket reference
git push origin feat/DEMO-127-user-dashboard
# PR Title: "feat(dashboard): add user dashboard component (DEMO-127)"
# PR Description: "Closes DEMO-127 - Implements user dashboard with..."
```

## Complete GitOps Pipeline

This repository implements a complete GitOps pipeline with automated promotion between environments using Kargo, ArgoCD, and Kubernetes.

### Infrastructure Overview

**🏗️ Infrastructure Stack:**
- **AWS EKS**: Managed Kubernetes clusters (dev/staging)
- **Terraform**: Infrastructure as Code for VPC, subnets, security groups
- **Istio**: Service mesh for traffic management and external access
- **ArgoCD**: GitOps continuous deployment
- **Kargo**: GitOps promotion engine for environment progression
- **ECR**: Container registry for application images

### Environment Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     GitOps Pipeline                            │
├─────────────────────────────────────────────────────────────────┤
│  Git → ECR → Kargo Warehouse → Dev Stage → Staging Stage       │
│   ↓      ↓         ↓             ↓           ↓                 │
│ Code → Image → Detection → Auto-Deploy → Manual Promotion     │
└─────────────────────────────────────────────────────────────────┘

Environment Separation:
┌──────────────────┐    ┌──────────────────┐
│   Dev Cluster    │    │ Staging Cluster  │
│ kargo-dev-eks    │    │ kargo-stg-eks    │
│ 10.10.0.0/16     │    │ 10.20.0.0/16     │
│                  │    │                  │
│ Auto-Deploy ✓    │    │ Manual Promote   │
│ Single AZ        │    │ Multi-AZ HA      │
│ Cost Optimized   │    │ Production-Like  │
└──────────────────┘    └──────────────────┘
```

### GitOps Services Access

**🌐 External Access (via Istio + ALB):**
- **FastAPI Dev**: https://app-dev.hamedstock.com
- **ArgoCD**: https://[ALB-URL] (LoadBalancer)
- **Kargo**: https://kargo-dev.hamedstock.com

**🔐 Access Restrictions:**
- IP restriction: `24.130.139.84/32`
- HTTPS termination at ALB
- Internal service mesh routing

### Kargo Promotion Pipeline

**📦 Promotion Flow:**
```
1. Code Push → GitHub
2. Docker Build → ECR Registry
3. Kargo Warehouse → Image Detection
4. Dev Stage → Automatic Deployment (ArgoCD)
5. Manual Promotion → Staging Stage (via Kargo UI)
6. Staging Deployment → ArgoCD Updates
```

**🎯 Kargo Configuration:**
- **Project**: `kargo-argocd`
- **Warehouse**: Tracks ECR images `992382364873.dkr.ecr.us-east-1.amazonaws.com/kargo-argocd`
- **Dev Stage**: Auto-deploys from main branch
- **Staging Stage**: Manual promotion for safety
- **UI Access**: https://kargo-dev.hamedstock.com

### ArgoCD Integration

**📱 ArgoCD Applications:**
- `fastapi-app-dev` → Dev cluster deployment
- `fastapi-app-staging` → Staging cluster deployment

**🔄 Application Sources:**
- **Git Repository**: https://github.com/hamedhaddadian/kargo-argocd
- **Manifests**: `k8s/app/overlays/{dev,stg}/`
- **Image Updates**: Automated via Kargo promotions

### Infrastructure Components

**🏗️ Terraform Modules:**
- `infrastructure/terraform/vpc/` - VPC, subnets, security groups
- `infrastructure/cluster/` - EKS cluster configurations
- Environment-specific tfvars for dev/staging

**☸️ Kubernetes Resources:**
- `k8s/app/` - Application manifests with Kustomize overlays
- `k8s/istio/` - Istio configurations and ingress
- `k8s/argocd/` - ArgoCD Helm configurations
- `k8s/kargo/` - Kargo installation and pipeline configs

**🚀 Deployment Scripts:**
- `k8s/istio/deploy-istio.sh` - Istio installation
- `k8s/argocd/deploy.sh` - ArgoCD deployment
- `k8s/kargo/install-kargo.sh` - Kargo + dependencies

## Complete Development Workflow

### 🔄 End-to-End Process

**1. Create Jira Ticket**
```bash
# Via Claude Code MCP integration or Jira UI
# Creates: DEMO-XXX with requirements and acceptance criteria
```

**2. Development Setup**
```bash
# Pull latest main
git checkout main
git pull origin main

# Create feature branch (lowercase, include ticket)
git checkout -b feature/demo-123-add-new-endpoint
```

**3. Code Implementation**
```bash
# Make changes following acceptance criteria
# Update documentation as needed
# Test locally

# Commit with conventional format + ticket reference
git add .
git commit -m "feat(api): add new endpoint (DEMO-123)"
```

**4. Push and Validate**
```bash
# Push branch
git push -u origin feature/demo-123-add-new-endpoint

# Pre-commit hooks validate:
# - Branch name format
# - Commit message format
# - Code formatting (Black, Flake8)
# - YAML syntax
```

**5. Pull Request Process**
```bash
# Create PR targeting main branch
# Claude Code Review automatically runs
# Title: "feat(api): add new endpoint (DEMO-123)"
# Description: Include "Closes DEMO-123"
```

**6. Review and Merge**
```bash
# Claude reviews for:
# - Security issues
# - Bugs and code quality
# - Kubernetes/Terraform patterns
# - Deployment safety

# After approval and merge to main:
# - New Docker image builds
# - Pushes to ECR registry
```

**7. GitOps Deployment**
```bash
# Kargo automatically:
# 1. Detects new ECR image
# 2. Updates dev ArgoCD application
# 3. Deploys to dev cluster
# 4. Available at: https://app-dev.hamedstock.com

# Manual promotion to staging:
# 1. Access Kargo UI: https://kargo-dev.hamedstock.com
# 2. View dev stage status
# 3. Click "Promote" to staging
# 4. Deploys to staging cluster
```

**8. Jira Completion**
```bash
# Update Jira ticket:
# - Mark as "Done"
# - Add implementation details
# - Reference deployed endpoints
```

### 🛠️ Development Tools

**Required Setup:**
```bash
# Pre-commit hooks
pip install pre-commit
pre-commit install

# Terraform (for infrastructure)
tfswitch

# Kubernetes tools
kubectl
eksctl
helm

# AWS CLI
aws configure
```

**Testing Locally:**
```bash
# FastAPI application
cd applications
pip install -r requirements.txt
python main.py
# Access: http://localhost:8000

# Docker testing
docker build -t fastapi-app .
docker run -p 8000:8000 fastapi-app
```

## Repository Configuration

The repository includes development workflow configuration with pre-commit hooks, validation scripts, GitHub integration, and Jira tracking.

### Development Workflow Setup

1. **Install pre-commit hooks** (recommended for all contributors):
```bash
# Install pre-commit
pip install pre-commit
pre-commit install
```

2. **Jira-Driven Development Workflow**:

**Step 1: Create Jira Ticket First**
- Before starting any feature or task, create a ticket in the **Demo** Jira project (DEMO)
- Use appropriate issue type: Task, Story, Bug, Epic, or Subtask
- Include clear description, acceptance criteria, and requirements

**Step 2: Branch Naming with Ticket Number**
- Always use the Jira ticket number in branch names for traceability
- Format: `{type}/{ticket-number}-{brief-description}` (ALL LOWERCASE)

**Required Patterns:**
- `feature/demo-123-add-user-authentication` - New features
- `bugfix/demo-124-fix-login-redirect` - Bug fixes
- `hotfix/demo-125-security-patch` - Urgent fixes
- `release/v1.2.0` - Release branches

**Examples:**
- `feature/demo-123-add-user-authentication`
- `bugfix/demo-124-fix-login-redirect`
- `hotfix/demo-125-security-patch`
- `chore/demo-126-update-dependencies`

**Step 3: Link Code to Requirements**
- Branch name automatically links commits to Jira ticket
- Pull request title should reference ticket: `feat(auth): add user authentication (DEMO-123)`
- Include ticket link in PR description

3. **Commit message format** (conventional commits with ticket reference):
```
type(scope): description (TICKET-NUMBER)

Examples:
feat(api): add new endpoint (DEMO-123)
fix(auth): resolve login issue (DEMO-124)
docs: update README (DEMO-125)
```

### Automated Validation

- **Pre-commit hooks**: Validate branch names, commit messages, and code formatting
- **GitHub Actions**: Automated validation on pull requests
- **Code formatting**: Black and Flake8 for Python code consistency

### Claude AI Code Review

**Official Anthropic Claude Code Action** for automated code reviews via `.github/workflows/claude-code-review.yml`:

**Enterprise Features:**
- **Intelligent Detection**: Auto-responds to @claude mentions in PRs and issues
- **Code Review & Analysis**: Comprehensive security, performance, and quality analysis
- **Code Implementation**: Can suggest and implement code changes directly
- **Interactive Assistant**: Responds to questions and requests in comments
- **Progress Tracking**: Visual progress indicators for long-running tasks
- **Multi-Trigger Support**: Automatic, manual, and @claude comment triggers

**Advanced Capabilities:**
- **Smart Context**: Understands project structure and codebase patterns
- **Security Focus**: Identifies vulnerabilities and security concerns
- **Performance Optimization**: Suggests efficiency improvements
- **Best Practices**: Enforces coding standards and conventions
- **Documentation**: Improves code clarity and commenting
- **Architecture Guidance**: Recommends design pattern improvements

**Configuration:**
- **Official Action**: `anthropics/claude-code-action@v1`
- **Model**: Latest Claude 3.5 Sonnet with continuous updates
- **Triggers**:
  - Automatic: PR creation and updates
  - Manual: GitHub Actions workflow dispatch
  - Interactive: @claude mentions in comments
- **Output**: Smart sticky comments with real-time updates

**Setup Requirements:**
- `ANTHROPIC_API_KEY` secret configured in repository settings
- `id-token: write` permission for OIDC authentication
- Maintained and supported by Anthropic team

### Pull Request Process

- **Create from Jira ticket branch** (e.g., `feat/DEMO-123-feature-name`)
- **Include ticket reference** in PR title and description
- Use the provided PR template (`.github/pull_request_template.md`)
- **Link to Jira ticket** for context and requirements
- Ensure all checks pass (branch name, commit messages, formatting)
- Follow the checklist in the PR template

**PR Title Format:**
```
type(scope): description (DEMO-XXX)
```

**PR Description Should Include:**
- Jira ticket link: `Closes DEMO-XXX` or `Relates to DEMO-XXX`
- Summary of changes made
- Testing approach
- Screenshots/demos if applicable

## Development

This is a Python-based project using FastAPI for web services. The application is designed to be lightweight and follows standard FastAPI patterns.

### Dependencies

**Application Dependencies:**
- FastAPI: Modern, fast web framework for building APIs
- Uvicorn: ASGI server for running FastAPI applications

**Development Dependencies:**
- pre-commit: Git pre-commit hooks framework
- black: Python code formatter
- flake8: Python linting tool

**Repository Tooling:**
- Custom validation scripts for branch names and commit messages
- Docker support for containerized deployment
- GitHub Actions workflows for automated validation

## Purpose

This repository is designed for Kargo ArgoCD integration, featuring:

- **FastAPI Web Service**: Lightweight API with HIV-related endpoints
- **Development Workflow**: Comprehensive tooling for code quality and consistency
- **Containerization**: Docker support for deployment flexibility
- **CI/CD Integration**: GitHub Actions for automated validation
- **Developer Experience**: Pre-commit hooks and standardized processes

The repository demonstrates best practices for Python web service development with proper validation, formatting, and deployment configuration.

# GitHub Environments Setup Guide

This document explains how to configure GitHub Environments for the progressive deployment strategy used in this repository.

## 🌍 Environment Strategy

**Progressive Deployment Flow:**
1. **Development** → Auto-deploy on push to main
2. **Staging** → Deploy after dev succeeds (requires approval)
3. **Production** → Deploy after staging succeeds (requires approval)

## ⚙️ GitHub Environment Configuration

### Required Environments

You need to create the following environments in your GitHub repository settings:

#### 1. Development Environment
- **Name**: `dev`
- **Protection Rules**: None (auto-deploy)
- **Secrets**: Inherit repository secrets
- **Variables**: None required

#### 2. Staging Environment
- **Name**: `staging`
- **Protection Rules**:
  - ✅ Required reviewers (1-2 people)
  - ✅ Prevent administrators from bypassing protection rules
- **Secrets**: Inherit repository secrets
- **Variables**: None required
- **Environment URL**: `https://console.aws.amazon.com/vpc/home?region=us-east-1`

#### 3. Production Environment
- **Name**: `production`
- **Protection Rules**:
  - ✅ Required reviewers (2-3 people minimum)
  - ✅ Prevent administrators from bypassing protection rules
  - ✅ Wait timer: 5 minutes (optional)
- **Secrets**: Inherit repository secrets or use production-specific secrets
- **Variables**: None required
- **Environment URL**: `https://console.aws.amazon.com/vpc/home?region=us-east-1`

#### 4. Destroy Environments (Optional)
- **Name**: `dev-destroy`, `staging-destroy`, `production-destroy`
- **Protection Rules**:
  - ✅ Required reviewers (more restrictive than deploy)
- **Purpose**: Extra safety for destruction operations

## 🔧 Setup Instructions

### Step 1: Access Repository Settings
1. Go to your GitHub repository
2. Click **Settings** tab
3. Navigate to **Environments** in the left sidebar

### Step 2: Create Development Environment
1. Click **New environment**
2. Name: `dev`
3. Click **Configure environment**
4. **Protection rules**: Leave empty (no approval needed)
5. Click **Save protection rules**

### Step 3: Create Staging Environment
1. Click **New environment**
2. Name: `staging`
3. Click **Configure environment**
4. **Protection rules**:
   - Check **Required reviewers**
   - Add 1-2 reviewers (team leads, senior engineers)
   - Check **Prevent administrators from bypassing required reviewers**
5. **Environment URL**: `https://console.aws.amazon.com/vpc/home?region=us-east-1`
6. Click **Save protection rules**

### Step 4: Create Production Environment
1. Click **New environment**
2. Name: `production`
3. Click **Configure environment**
4. **Protection rules**:
   - Check **Required reviewers**
   - Add 2-3 reviewers (must include senior engineers/architects)
   - Check **Prevent administrators from bypassing required reviewers**
   - Optional: **Wait timer** of 5 minutes for reflection time
5. **Environment URL**: `https://console.aws.amazon.com/vpc/home?region=us-east-1`
6. Click **Save protection rules**

### Step 5: Configure Reviewers
Add appropriate team members as reviewers for each environment:

**Staging Reviewers:**
- Platform engineers
- Team leads
- DevOps engineers

**Production Reviewers:**
- Senior platform engineers
- Solution architects
- Team leads or managers
- Security team members (if required)

## 🚀 Deployment Workflows

### Automatic Deployment (Main Branch)
```
Push to main → Plan (dev/stg/prd) → Deploy dev → [Approval] → Deploy staging → [Approval] → Deploy production
```

1. **Developer pushes to main**
2. **Terraform Plan** runs for all environments
3. **Development** deploys automatically
4. **Staging** waits for approval
5. **Production** waits for staging + approval

### Manual Deployment (Workflow Dispatch)
```
Manual trigger → Plan (selected env) → [Approval] → Deploy (selected env)
```

1. Go to **Actions** → **Terraform Infrastructure**
2. Click **Run workflow**
3. Select target environment and action
4. Approval required for staging/production

### Emergency Rollback
```
Manual trigger → Destroy workflow → [Multiple Approvals] → Destroy resources
```

1. Use workflow dispatch with `destroy` action
2. Multiple approvals required for destruction
3. Consider state rollback as alternative

## 📋 Approval Process

### Staging Approval
**Who:** 1-2 team members
**Criteria:**
- [ ] Development deployment successful
- [ ] Plan output reviewed and approved
- [ ] No security concerns identified
- [ ] Change aligns with sprint goals

### Production Approval
**Who:** 2-3 senior team members
**Criteria:**
- [ ] Staging deployment successful and tested
- [ ] Plan output thoroughly reviewed
- [ ] Security review completed
- [ ] Performance impact assessed
- [ ] Rollback plan documented
- [ ] Business stakeholders informed
- [ ] Change window approved

## 🔐 Security Considerations

### Environment Isolation
- Each environment uses separate AWS state files
- Cross-environment contamination prevented by design
- Environment-specific CIDR ranges prevent conflicts

### Access Control
- **Dev**: Open access for development team
- **Staging**: Restricted approval process
- **Production**: Strict approval with multiple reviewers

### Secrets Management
```yaml
# Repository Secrets (inherited by all environments)
AWS_ACCESS_KEY_ID: <Development/Shared AWS access key>
AWS_SECRET_ACCESS_KEY: <Development/Shared AWS secret>

# Environment-specific secrets (optional)
# Override at environment level for production
AWS_ACCESS_KEY_ID: <Production-specific AWS access key>
AWS_SECRET_ACCESS_KEY: <Production-specific AWS secret>
```

## 📊 Monitoring and Alerting

### GitHub Notifications
- **Development**: No notifications (silent deploy)
- **Staging**: Approval request notifications
- **Production**: Approval request + deployment notifications

### Slack Integration (Recommended)
```yaml
# Add to workflow for notifications
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Production deployment ${{ job.status }}'
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

## 🛠️ Troubleshooting

### Common Issues

#### Approval Stuck in Pending
- Check reviewer availability
- Verify reviewer has repository access
- Check email notifications are enabled

#### Deployment Fails After Approval
- Review Terraform plan output
- Check AWS credentials and permissions
- Verify S3 backend accessibility

#### Can't Approve Own Deployment
- By design - approvers must be different from requester
- Add additional reviewers to environment

### Emergency Procedures

#### Bypass Protection Rules (Emergency Only)
1. Repository admin can temporarily disable protection rules
2. Deploy emergency fix
3. Re-enable protection rules immediately
4. Document incident for review

#### State File Corruption
1. Access S3 backend directly
2. Restore from S3 version history
3. Re-run terraform plan to verify state
4. Document recovery process

## 📚 References

- **GitHub Environments**: [GitHub Docs](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- **Terraform Workflows**: [HashiCorp Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- **AWS VPC**: [AWS VPC User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/)

## 🔄 Migration from Multi-Branch

If migrating from a multi-branch strategy:

1. **Merge feature branches** to main
2. **Configure environments** as described above
3. **Update branch protection** rules for main
4. **Archive old deployment** branches
5. **Train team** on new approval workflow

This single-branch + environments approach provides better control, clearer audit trails, and simplified branch management while maintaining safety through approval gates.

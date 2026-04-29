# Kargo ArgoCD Repository

This repository contains a FastAPI application and related tooling for Kargo ArgoCD integration.

## Project Structure

```
kargo-argocd/
├── applications/              # FastAPI application directory
│   ├── main.py               # Main FastAPI application with HIV endpoints
│   ├── requirements.txt      # Python dependencies
│   ├── Dockerfile            # Container build configuration
│   ├── .dockerignore         # Docker build exclusions
│   ├── README.md             # Application-specific documentation
│   └── CLAUDE.md             # Application development context
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

The `applications/` directory contains a FastAPI web service with two endpoints:

- **GET /hiv1** - Returns "hiv1"
- **GET /hiv2** - Returns "hiv2"

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
- Format: `{type}/{ticket-number}-{brief-description}`

Examples:
- `feat/DEMO-123-add-user-authentication` - New features
- `bugfix/DEMO-124-fix-login-redirect` - Bug fixes
- `hotfix/DEMO-125-security-patch` - Urgent fixes
- `chore/DEMO-126-update-dependencies` - Maintenance tasks

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

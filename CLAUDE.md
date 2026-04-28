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

## Repository Configuration

The repository includes development workflow configuration with pre-commit hooks, validation scripts, and GitHub integration.

### Development Workflow Setup

1. **Install pre-commit hooks** (recommended for all contributors):
```bash
# Install pre-commit
pip install pre-commit
pre-commit install
```

2. **Branch naming conventions**:
- `feature/description` - New features
- `bugfix/description` - Bug fixes
- `hotfix/description` - Urgent fixes
- `release/version` - Release branches

3. **Commit message format** (conventional commits):
```
type(scope): description

Examples:
feat(api): add new endpoint
fix(auth): resolve login issue
docs: update README
```

### Automated Validation

- **Pre-commit hooks**: Validate branch names, commit messages, and code formatting
- **GitHub Actions**: Automated validation on pull requests
- **Code formatting**: Black and Flake8 for Python code consistency

### Claude AI Code Review

**Automated AI-powered code reviews** on every pull request via `.github/workflows/claude-code-review.yml`:

**Review Coverage:**
- **Code Quality**: Best practices, patterns, and maintainability
- **Security Analysis**: Vulnerability detection and security concerns
- **Performance**: Optimization opportunities and efficiency improvements
- **Bug Detection**: Potential issues and edge cases
- **Documentation**: Code clarity and commenting suggestions
- **Architecture**: Design patterns and structural improvements

**Configuration:**
- **Model**: Claude 3.5 Sonnet for comprehensive analysis
- **Trigger**: Automatic on PR creation and updates
- **Output**: Detailed markdown comments with actionable feedback
- **Cost Control**: Skips reviews for PRs larger than 5000 lines

**Setup Requirements:**
- `ANTHROPIC_API_KEY` secret configured in repository settings
- Proper GitHub permissions for PR commenting

### Pull Request Process

- Use the provided PR template (`.github/pull_request_template.md`)
- Ensure all checks pass (branch name, commit messages, formatting)
- Follow the checklist in the PR template

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

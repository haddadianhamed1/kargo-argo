# Kargo ArgoCD SDLC Pipeline

A comprehensive Software Development Life Cycle (SDLC) pipeline implementation featuring FastAPI application development with automated validation, code quality enforcement, and CI/CD integration.

## 🏗️ Project Overview

This repository demonstrates a complete SDLC pipeline with:

- **FastAPI Web Service** - RESTful API with containerization
- **Automated Code Quality** - Pre-commit hooks and validation
- **AI-Powered Code Reviews** - Claude automatically reviews all pull requests
- **Standardized Workflows** - Branch naming and commit conventions
- **CI/CD Integration** - GitHub Actions for automated validation
- **Developer Experience** - Comprehensive tooling and documentation

## 📁 Project Structure

```
kargo-argocd/
├── applications/              # FastAPI application
│   ├── main.py               # API endpoints (/hiv1, /hiv2)
│   ├── requirements.txt      # Python dependencies
│   ├── Dockerfile           # Container configuration
│   └── README.md            # Application documentation
├── scripts/                  # SDLC validation scripts
│   ├── check_branch_name.py  # Branch naming validator
│   └── check_commit_msg.py   # Commit message validator
├── .github/                  # GitHub integration
│   ├── pull_request_template.md  # PR template
│   └── workflows/
│       ├── branch-name-check.yml     # Branch/commit validation
│       └── claude-code-review.yml    # AI code review workflow
├── .pre-commit-config.yaml   # Pre-commit hooks
└── CLAUDE.md                # Development documentation
```

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd kargo-argocd

# Install development dependencies
pip install pre-commit

# Install pre-commit hooks
pre-commit install
pre-commit install --hook-type commit-msg
```

### 2. Run the Application

```bash
# Local development
cd applications
pip install -r requirements.txt
python main.py

# Docker deployment
docker build -t kargo-app applications/
docker run -p 8000:8000 kargo-app
```

### 3. Access the API

- **Application**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Alternative Docs**: http://localhost:8000/redoc

**Endpoints:**
- `GET /hiv1` → Returns "hiv1"
- `GET /hiv2` → Returns "hiv2"

## 🔄 SDLC Workflow

### Branch Naming Convention

Follow these patterns for consistent branch management:

```bash
feature/add-authentication     # New features
bugfix/fix-login-error        # Bug fixes
hotfix/security-patch         # Urgent fixes
release/v1.2.0               # Release preparation
```

### Commit Message Format

Use conventional commits for automated changelog generation:

```bash
feat(api): add new authentication endpoint
fix(auth): resolve token validation issue
docs: update API documentation
chore: update dependencies
```

**Format**: `type(scope): description`

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Development Process

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature
   ```

2. **Develop with Validation**
   - Pre-commit hooks automatically validate:
     - Branch naming
     - Commit messages
     - Code formatting (Black)
     - Linting (Flake8)
     - YAML syntax
     - Trailing whitespace

3. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat(api): add new endpoint"
   ```

4. **Create Pull Request**
   - Use provided PR template
   - Automated validation runs
   - Code review process

5. **Merge to Main**
   - All checks must pass
   - Review approval required

## 🛡️ Quality Assurance

### AI-Powered Code Reviews

**Claude Automated Reviews** on every pull request:

- ✅ **Code Quality Analysis** - Best practices and patterns
- ✅ **Security Assessment** - Vulnerability detection
- ✅ **Performance Review** - Optimization opportunities
- ✅ **Maintainability Check** - Readability and structure
- ✅ **Bug Detection** - Potential issues identification
- ✅ **Constructive Feedback** - Actionable improvement suggestions

### Pre-commit Hooks

Automatic validation before each commit:

- **Branch Name Validation** - Enforce naming conventions
- **Commit Message Validation** - Conventional commit format
- **Code Formatting** - Black formatter for Python
- **Linting** - Flake8 for code quality
- **File Validation** - YAML syntax, trailing whitespace

### GitHub Actions

Automated validation on pull requests:

- Branch name validation
- Commit message validation
- Automated PR commenting for violations

### Testing Pre-commit Hooks

```bash
# Test all hooks on existing files
pre-commit run --all-files

# Test specific hook
pre-commit run check-branch-name

# Manual validation
python3 scripts/check_branch_name.py
python3 scripts/check_commit_msg.py commit_msg_file.txt
```

## 🐳 Containerization

The application includes Docker support for consistent deployment:

```dockerfile
# Build and run
docker build -t kargo-app applications/
docker run -p 8000:8000 kargo-app
```

**Features:**
- Multi-stage build optimization
- Python 3.11 slim base image
- Proper layer caching
- Security best practices

## 📋 Pull Request Template

Standardized PR template ensures consistency:

- **Summary** - Brief description of changes
- **Type of Change** - Bug fix, feature, breaking change
- **Testing** - Test coverage and validation
- **Deployment Notes** - Migration or configuration requirements
- **Checklist** - Quality assurance items

## 🔧 Configuration Files

- **`.pre-commit-config.yaml`** - Pre-commit hooks configuration
- **`applications/Dockerfile`** - Container build instructions
- **`.github/workflows/`** - GitHub Actions workflows
- **`.github/pull_request_template.md`** - PR template

## 📚 Documentation

- **`README.md`** - This file (project overview)
- **`CLAUDE.md`** - Detailed development documentation
- **`applications/README.md`** - Application-specific docs
- **`applications/CLAUDE.md`** - Application development context

## 🛠️ Development Tools

### Required Tools

- **Python 3.11+** - Application runtime
- **pre-commit** - Git hooks framework
- **Docker** - Containerization (optional)

### IDE Integration

The project works with any Python IDE. Recommended extensions:

- **Python** - Language support
- **Black Formatter** - Code formatting
- **Flake8** - Linting
- **Docker** - Container support

## 📈 Benefits of This SDLC Pipeline

1. **Code Quality** - Automated formatting and linting
2. **Consistency** - Standardized naming and commit formats
3. **Early Detection** - Pre-commit validation prevents issues
4. **Documentation** - Comprehensive PR templates and docs
5. **CI/CD Ready** - GitHub Actions integration
6. **Developer Experience** - Clear workflows and automation
7. **Scalability** - Easily extensible for larger teams

## 🤝 Contributing

1. Follow branch naming conventions
2. Use conventional commit messages
3. Ensure all pre-commit hooks pass
4. Fill out PR template completely
5. Wait for automated validation to pass
6. Address review feedback

## 📄 License

This project demonstrates SDLC pipeline implementation for educational and development purposes.

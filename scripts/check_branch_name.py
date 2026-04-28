#!/usr/bin/env python3
"""
Branch name validation script for pre-commit hooks.
Ensures branch names follow conventional naming patterns.
"""

import os
import re
import subprocess
import sys
from typing import List


def get_current_branch() -> str:
    """Get the current git branch name."""
    # First check if we're in GitHub Actions
    github_head_ref = os.environ.get('GITHUB_HEAD_REF')
    if github_head_ref:
        return github_head_ref

    # Fallback to git command for local development
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        print("Error: Unable to determine current branch")
        return ""


def validate_branch_name(branch_name: str) -> tuple[bool, str]:
    """
    Validate branch name against naming conventions.

    Allowed patterns:
    - feature/description
    - bugfix/description
    - hotfix/description
    - release/version
    - main
    - master
    - develop
    """

    # Allow main branches
    if branch_name in ["main", "master", "develop"]:
        return True, ""

    # Define allowed patterns
    patterns = [
        r"^feature/[a-z0-9-]+$",
        r"^bugfix/[a-z0-9-]+$",
        r"^hotfix/[a-z0-9-]+$",
        r"^release/v?\d+\.\d+(\.\d+)?$",
    ]

    for pattern in patterns:
        if re.match(pattern, branch_name):
            return True, ""

    error_msg = f"""
Invalid branch name: '{branch_name}'

Branch names must follow one of these patterns:
  - feature/description (e.g., feature/add-authentication)
  - bugfix/description (e.g., bugfix/fix-login-error)
  - hotfix/description (e.g., hotfix/security-patch)
  - release/version (e.g., release/v1.2.0)

Special branches (main, master, develop) are also allowed.

Branch names should use lowercase letters, numbers, and hyphens only.
"""

    return False, error_msg


def main() -> int:
    """Main execution function."""
    branch_name = get_current_branch()

    if not branch_name:
        return 1

    is_valid, error_message = validate_branch_name(branch_name)

    if not is_valid:
        print(error_message)
        return 1

    print(f"✓ Branch name '{branch_name}' is valid")
    return 0


if __name__ == "__main__":
    sys.exit(main())

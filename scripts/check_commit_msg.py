#!/usr/bin/env python3
"""
Commit message validation script for pre-commit hooks.
Ensures commit messages follow conventional commit format.
"""

import re
import sys
from pathlib import Path
from typing import List, Tuple


def read_commit_message(commit_msg_file: str) -> str:
    """Read the commit message from the file."""
    try:
        with open(commit_msg_file, 'r', encoding='utf-8') as f:
            return f.read().strip()
    except FileNotFoundError:
        print(f"Error: Commit message file '{commit_msg_file}' not found")
        return ""


def validate_commit_message(message: str) -> Tuple[bool, str]:
    """
    Validate commit message against conventional commit format.

    Expected format: type(scope): description

    Allowed types:
    - feat: A new feature
    - fix: A bug fix
    - docs: Documentation only changes
    - style: Changes that don't affect code meaning
    - refactor: Code change that neither fixes bug nor adds feature
    - test: Adding missing tests or correcting existing tests
    - chore: Changes to build process or auxiliary tools
    """

    # Skip validation for merge commits
    if message.startswith("Merge "):
        return True, ""

    # Skip validation for revert commits
    if message.startswith("Revert "):
        return True, ""

    # Define the conventional commit pattern
    pattern = r"^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}"

    if not re.match(pattern, message):
        error_msg = f"""
Invalid commit message format: '{message[:50]}...'

Commit messages must follow the conventional commit format:
  type(scope): description

Types:
  - feat: A new feature
  - fix: A bug fix
  - docs: Documentation only changes
  - style: Changes that don't affect code meaning
  - refactor: Code change that neither fixes bug nor adds feature
  - test: Adding missing tests or correcting existing tests
  - chore: Changes to build process or auxiliary tools

Examples:
  - feat(auth): add login functionality
  - fix(api): resolve timeout issue
  - docs: update README with installation steps
  - chore: update dependencies

The description should be concise (max 50 characters for first line).
"""
        return False, error_msg

    # Check if description starts with lowercase (conventional style)
    desc_match = re.search(r": (.)", message)
    if desc_match and desc_match.group(1).isupper():
        warning_msg = f"""
Warning: Description should start with lowercase letter.
Current: '{message}'
Suggested: '{message.replace(desc_match.group(1), desc_match.group(1).lower(), 1)}'
"""
        print(warning_msg)

    return True, ""


def main() -> int:
    """Main execution function."""
    if len(sys.argv) < 2:
        print("Usage: check_commit_msg.py <commit_msg_file>")
        return 1

    commit_msg_file = sys.argv[1]
    commit_message = read_commit_message(commit_msg_file)

    if not commit_message:
        return 1

    # Only validate the first line (subject line)
    subject_line = commit_message.split('\n')[0]

    is_valid, error_message = validate_commit_message(subject_line)

    if not is_valid:
        print(error_message)
        return 1

    print(f"✓ Commit message format is valid")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""
Pre-commit hook to validate Terraform configuration if Terraform is installed.
"""

import os
import subprocess
import sys
from pathlib import Path

def check_terraform_available():
    """Check if terraform command is available."""
    try:
        subprocess.run(['terraform', '--version'],
                      capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def find_terraform_dirs():
    """Find all directories containing .tf files."""
    terraform_dirs = set()

    # Look for .tf files in infrastructure directory
    infrastructure_path = Path('infrastructure')
    if infrastructure_path.exists():
        for tf_file in infrastructure_path.rglob('*.tf'):
            terraform_dirs.add(tf_file.parent)

    return terraform_dirs

def validate_terraform_dir(tf_dir):
    """Validate Terraform configuration in a directory."""
    print(f"🔍 Validating Terraform in {tf_dir}")

    try:
        # Change to terraform directory
        original_dir = os.getcwd()
        os.chdir(tf_dir)

        # Check if .terraform exists, if not, try to initialize
        if not Path('.terraform').exists():
            print(f"  ⚠️  No .terraform directory found. Skipping validation for {tf_dir}")
            print(f"     Run 'terraform init' in {tf_dir} to enable validation")
            return True

        # Run terraform validate
        result = subprocess.run(['terraform', 'validate'],
                              capture_output=True, text=True)

        os.chdir(original_dir)

        if result.returncode == 0:
            print(f"  ✅ Terraform validation passed for {tf_dir}")
            return True
        else:
            print(f"  ❌ Terraform validation failed for {tf_dir}")
            print(f"     Error: {result.stderr}")
            return False

    except Exception as e:
        os.chdir(original_dir)
        print(f"  ❌ Error validating {tf_dir}: {e}")
        return False

def format_terraform_dir(tf_dir):
    """Format Terraform files in a directory."""
    try:
        original_dir = os.getcwd()
        os.chdir(tf_dir)

        result = subprocess.run(['terraform', 'fmt', '-check'],
                              capture_output=True, text=True)

        os.chdir(original_dir)

        if result.returncode == 0:
            print(f"  ✅ Terraform formatting check passed for {tf_dir}")
            return True
        else:
            print(f"  📝 Terraform files need formatting in {tf_dir}")
            print(f"     Run 'terraform fmt' in {tf_dir} to fix formatting")

            # Auto-format if files need formatting
            os.chdir(tf_dir)
            subprocess.run(['terraform', 'fmt'], capture_output=True)
            os.chdir(original_dir)
            print(f"  ✅ Terraform files auto-formatted in {tf_dir}")
            return True

    except Exception as e:
        os.chdir(original_dir)
        print(f"  ❌ Error formatting {tf_dir}: {e}")
        return False

def main():
    """Main function to run Terraform checks."""
    print("🚀 Running Terraform pre-commit checks...")

    # Check if terraform is available
    if not check_terraform_available():
        print("⚠️  Terraform not found in PATH. Skipping Terraform validation.")
        print("   Install Terraform from https://terraform.io to enable validation.")
        return 0  # Don't fail the commit if terraform isn't installed

    print("✅ Terraform found!")

    # Find terraform directories
    terraform_dirs = find_terraform_dirs()

    if not terraform_dirs:
        print("ℹ️  No Terraform files found. Skipping validation.")
        return 0

    print(f"📁 Found {len(terraform_dirs)} Terraform directories")

    all_passed = True

    for tf_dir in sorted(terraform_dirs):
        print(f"\n📂 Processing {tf_dir}")

        # Format check and auto-format
        if not format_terraform_dir(tf_dir):
            all_passed = False
            continue

        # Validate configuration
        if not validate_terraform_dir(tf_dir):
            all_passed = False

    if all_passed:
        print("\n🎉 All Terraform checks passed!")
        return 0
    else:
        print("\n❌ Some Terraform checks failed!")
        return 1

if __name__ == '__main__':
    sys.exit(main())

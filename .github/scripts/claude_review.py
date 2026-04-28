#!/usr/bin/env python3
"""
Claude Code Review Script
Secure implementation for automated code reviews using Claude API.
"""

import os
import json
import sys
import requests
from anthropic import Anthropic


def get_claude_review(diff_content, changed_files, pr_title, pr_description):
    """Get code review from Claude with proper error handling"""
    api_key = os.environ.get('ANTHROPIC_API_KEY')
    if not api_key:
        return "⚠️ Error: ANTHROPIC_API_KEY not configured"

    try:
        client = Anthropic(api_key=api_key)

        prompt = f"""You are an experienced code reviewer. Please review this pull request and provide constructive feedback.

**Pull Request Title:** {pr_title}

**Description:** {pr_description}

**Changed Files:** {changed_files}

**Code Diff:**
```diff
{diff_content}
```

Please provide a thorough code review focusing on:
1. Code quality and best practices
2. Security concerns
3. Performance considerations
4. Maintainability and readability
5. Potential bugs or issues
6. Suggestions for improvement

Format your review as markdown with clear sections. Be constructive and helpful. If the code looks good, say so and highlight what's done well.

Start your review with a brief summary, then provide detailed feedback organized by file or concern area."""

        response = client.messages.create(
            model="claude-3-5-sonnet-20241022",
            max_tokens=4000,
            timeout=60.0,
            messages=[{"role": "user", "content": prompt}]
        )
        return response.content[0].text
    except Exception as e:
        return f"⚠️ Error getting Claude review: {str(e)}"


def post_github_comment(review_text, pr_number, repo_owner, repo_name, github_token):
    """Post review as GitHub comment with proper error handling"""
    try:
        url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/issues/{pr_number}/comments"

        comment_body = f"""## 🤖 Claude Code Review

{review_text}

---
*Automated review by Claude via GitHub Actions*
"""

        headers = {
            'Authorization': f'token {github_token}',
            'Accept': 'application/vnd.github.v3+json',
        }

        response = requests.post(
            url,
            headers=headers,
            data=json.dumps({'body': comment_body}),
            timeout=30
        )

        if response.status_code == 201:
            return True
        else:
            print(f"Failed to post comment: {response.status_code} - {response.text}")
            return False

    except Exception as e:
        print(f"Error posting comment: {str(e)}")
        return False


def main():
    """Main execution with comprehensive error handling"""
    try:
        # Read files safely
        try:
            with open('pr_diff.txt', 'r', encoding='utf-8') as f:
                diff_content = f.read()
        except FileNotFoundError:
            print("Error: pr_diff.txt not found")
            sys.exit(1)

        try:
            with open('changed_files.txt', 'r', encoding='utf-8') as f:
                changed_files = f.read()
        except FileNotFoundError:
            print("Error: changed_files.txt not found")
            sys.exit(1)

        # Get environment variables safely
        pr_title = os.environ.get('PR_TITLE', 'No title')
        pr_description = os.environ.get('PR_DESCRIPTION', 'No description')
        pr_number = os.environ.get('PR_NUMBER', '')
        repo_owner = os.environ.get('REPO_OWNER', '')
        repo_name = os.environ.get('REPO_NAME', '')
        github_token = os.environ.get('GITHUB_TOKEN', '')

        # Validate required environment variables
        if not all([pr_number, repo_owner, repo_name, github_token]):
            print("Error: Missing required environment variables")
            sys.exit(1)

        # Skip if diff is too large (> 5000 lines to avoid API limits)
        if len(diff_content.split('\n')) > 5000:
            review_text = """⚠️ **Pull request too large for automated review**

This PR contains too many changes for automated review. Please consider:
1. Breaking it into smaller PRs
2. Manual review by team members
3. Focus on critical changes first"""
        else:
            # Get Claude's review
            print("Getting Claude review...")
            review_text = get_claude_review(diff_content, changed_files, pr_title, pr_description)

        # Post to GitHub
        success = post_github_comment(
            review_text,
            pr_number,
            repo_owner,
            repo_name,
            github_token
        )

        if success:
            print("✅ Claude review posted successfully!")
        else:
            print("❌ Failed to post review")
            sys.exit(1)

    except Exception as e:
        print(f"❌ Unexpected error: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()

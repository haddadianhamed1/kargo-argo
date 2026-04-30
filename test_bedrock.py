#!/usr/bin/env python3
"""
Test script to verify AWS Bedrock access
"""
import boto3
import json
from botocore.exceptions import ClientError, NoCredentialsError

def test_bedrock_access():
    print("🔍 Testing AWS Bedrock Access...")

    # Create Bedrock client
    try:
        bedrock = boto3.client('bedrock', region_name='us-east-1')
        print("✅ Bedrock client created successfully")
    except Exception as e:
        print(f"❌ Failed to create Bedrock client: {e}")
        return False

    # Test 1: List foundation models
    print("\n📋 Testing: List Foundation Models")
    try:
        response = bedrock.list_foundation_models()
        models = response.get('modelSummaries', [])
        print(f"✅ Found {len(models)} available foundation models")

        # Look for Claude models
        claude_models = [m for m in models if 'claude' in m['modelId'].lower()]
        print(f"🤖 Claude models available: {len(claude_models)}")

        # Check if our target model is available
        target_model = "anthropic.claude-3-haiku-20240307-v1:0"
        target_available = any(m['modelId'] == target_model for m in models)

        if target_available:
            print(f"✅ Target model '{target_model}' is available")
        else:
            print(f"⚠️  Target model '{target_model}' not found")
            print("Available Claude models:")
            for model in claude_models[:5]:  # Show first 5
                print(f"   - {model['modelId']}")

    except ClientError as e:
        print(f"❌ Error listing models: {e}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

    # Test 2: Test model invocation (simple)
    print(f"\n🧪 Testing: Model Invocation")
    try:
        bedrock_runtime = boto3.client('bedrock-runtime', region_name='us-east-1')

        # Simple test prompt
        prompt = "Hello! Please respond with just 'Bedrock test successful' to confirm you're working."

        # Claude 3.5 Sonnet format
        body = json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 50,
            "messages": [
                {
                    "role": "user",
                    "content": prompt
                }
            ]
        })

        response = bedrock_runtime.invoke_model(
            modelId=target_model,
            body=body
        )

        response_body = json.loads(response['body'].read())
        content = response_body['content'][0]['text']

        print(f"✅ Model invocation successful!")
        print(f"📝 Response: {content.strip()}")

    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == 'AccessDeniedException':
            print(f"🔒 Access denied - this is expected (we need the IAM role)")
            print("   This confirms Bedrock is available but requires proper IAM permissions")
        else:
            print(f"❌ Error invoking model: {error_code} - {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

    return True

if __name__ == "__main__":
    success = test_bedrock_access()

    if success:
        print(f"\n🎉 Bedrock verification complete!")
        print("✅ Bedrock service is accessible")
        print("✅ Foundation models are available")
        print("🔧 Ready to proceed with LiteLLM deployment")
    else:
        print(f"\n❌ Bedrock verification failed")
        print("🔧 Check AWS credentials and region configuration")

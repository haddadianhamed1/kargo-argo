#!/usr/bin/env python3
"""
Test script for LiteLLM with DeepSeek R1 on AWS Bedrock
"""
from openai import OpenAI
import json


client = OpenAI(
    api_key="Skye12luna3$",
    base_url="https://litellm-dev.hamedstock.com/v1",
)

response = client.chat.completions.create(
    model="deepseek-r1",
    messages=[
        {"role": "user", "content": "Say hello from LiteLLM what is the name of your model?."}
    ],
    max_tokens=1000,
)

print(response.choices[0].message.content)

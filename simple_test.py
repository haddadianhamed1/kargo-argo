#!/usr/bin/env python3
"""
Simple LiteLLM test exactly as requested
"""
from openai import OpenAI

client = OpenAI(
    api_key="Skye12luna3$",
    base_url="https://litellm-dev.hamedstock.com/v1",
)

response = client.chat.completions.create(
    model="deepseek-r1",
    messages=[
        {"role": "user", "content": "Say hello and introduce the model being called"}
    ],
    max_tokens=1000,
)

print(response.choices[0].message.content)

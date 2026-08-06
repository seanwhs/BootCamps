# AI Tutorial Series: Developer Edition
# Appendix A: API Reference & Cheat Sheets

**Quick reference for all major AI APIs, providers, and common operations—keep this handy while building.**

---

## Table of Contents

1. [Provider Quick Reference](#provider-quick-reference)
2. [OpenAI API Reference](#openai-api-reference)
3. [Anthropic Claude API Reference](#anthropic-claude-api-reference)
4. [Google Gemini API Reference](#google-gemini-api-reference)
5. [Ollama API Reference](#ollama-api-reference)
6. [Common Operations Cheat Sheet](#common-operations-cheat-sheet)
7. [Prompt Engineering Templates](#prompt-engineering-templates)
8. [Function Calling Reference](#function-calling-reference)
9. [Embedding Models Reference](#embedding-models-reference)
10. [Vector Database Quick Reference](#vector-database-quick-reference)

---

## Provider Quick Reference

| Provider | API Base URL | Authentication | Key Format | Pricing Model |
|----------|--------------|----------------|------------|---------------|
| **OpenAI** | `https://api.openai.com/v1` | Bearer Token | `sk-...` | Pay per token |
| **Anthropic** | `https://api.anthropic.com/v1` | x-api-key | `sk-ant-...` | Pay per token |
| **Google** | `https://generativelanguage.googleapis.com/v1` | API Key | `AIza...` | Pay per token |
| **Ollama** | `http://localhost:11434` | None | None | Free (local) |
| **OpenRouter** | `https://openrouter.ai/api/v1` | Bearer Token | `sk-or-...` | Pay per token |
| **Azure OpenAI** | `https://{resource}.openai.azure.com` | API Key | `{key}` | Pay per token |

### Model Pricing (as of 2024)

| Model | Provider | Input ($/1M tokens) | Output ($/1M tokens) | Context Window |
|-------|----------|---------------------|----------------------|----------------|
| **gpt-4o** | OpenAI | $5.00 | $15.00 | 128K |
| **gpt-4o-mini** | OpenAI | $0.150 | $0.600 | 128K |
| **gpt-3.5-turbo** | OpenAI | $0.50 | $1.50 | 16K |
| **claude-3.5-sonnet** | Anthropic | $3.00 | $15.00 | 200K |
| **claude-3-haiku** | Anthropic | $0.25 | $1.25 | 200K |
| **gemini-1.5-pro** | Google | $2.50 | $7.50 | 2M |
| **gemini-1.5-flash** | Google | $0.35 | $1.05 | 1M |
| **llama3.2** | Ollama (local) | Free | Free | 128K |

---

## OpenAI API Reference

### Chat Completions

```python
from openai import OpenAI

client = OpenAI(api_key="sk-...")

response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Hello!"}
    ],
    temperature=0.7,
    max_tokens=500,
    top_p=1.0,
    frequency_penalty=0.0,
    presence_penalty=0.0,
    stream=False,
    n=1,
    seed=None,
    stop=None,
    tools=None
)

# Access response
response.choices[0].message.content
response.usage.total_tokens
response.usage.prompt_tokens
response.usage.completion_tokens
```

### Parameters Explained

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `model` | str | Required | Model to use |
| `messages` | list | Required | Conversation history |
| `temperature` | float | 1.0 | 0-2, controls randomness |
| `max_tokens` | int | None | Maximum output tokens |
| `top_p` | float | 1.0 | 0-1, nucleus sampling |
| `frequency_penalty` | float | 0.0 | -2.0 to 2.0 |
| `presence_penalty` | float | 0.0 | -2.0 to 2.0 |
| `stream` | bool | False | Stream response |
| `n` | int | 1 | Number of completions |
| `seed` | int | None | Deterministic generation |
| `stop` | str/list | None | Stop sequences |
| `tools` | list | None | Function definitions |

### Streaming Example

```python
stream = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": "Tell me a story"}],
    stream=True
)

for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="")
```

### Embeddings

```python
response = client.embeddings.create(
    model="text-embedding-3-small",
    input="Your text here",
    dimensions=1536  # Optional for text-embedding-3 models
)

embedding = response.data[0].embedding
tokens = response.usage.total_tokens
```

### Models Available

| Model | Type | Use Case |
|-------|------|----------|
| `gpt-4o` | Chat | Best quality, multimodal |
| `gpt-4o-mini` | Chat | Fast, cheap, good quality |
| `gpt-3.5-turbo` | Chat | Legacy, cheap |
| `text-embedding-3-small` | Embedding | 1536 dimensions, cheap |
| `text-embedding-3-large` | Embedding | 3072 dimensions, best quality |
| `dall-e-3` | Image | Image generation |
| `tts-1` | Audio | Text-to-speech |

---

## Anthropic Claude API Reference

### Messages API

```python
from anthropic import Anthropic

client = Anthropic(api_key="sk-ant-...")

response = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    system="You are a helpful assistant.",
    messages=[
        {"role": "user", "content": "Hello!"}
    ],
    temperature=0.7,
    max_tokens=500,
    top_p=1.0,
    stream=False
)

# Access response
response.content[0].text
response.usage.input_tokens
response.usage.output_tokens
```

### Parameters Explained

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | str | Claude model to use |
| `system` | str | System prompt (separate from messages) |
| `messages` | list | Conversation messages |
| `temperature` | float | 0.0-1.0, controls randomness |
| `max_tokens` | int | Maximum output tokens |
| `top_p` | float | 0.0-1.0, nucleus sampling |
| `stream` | bool | Stream response |

### Models Available

| Model | Use Case |
|-------|----------|
| `claude-3-5-sonnet-20241022` | Best quality |
| `claude-3-opus-20240229` | Highest capability |
| `claude-3-haiku-20240307` | Fastest, cheapest |

### Streaming Example

```python
stream = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    messages=[{"role": "user", "content": "Tell me a story"}],
    max_tokens=500,
    stream=True
)

for chunk in stream:
    if chunk.type == "content_block_delta":
        if chunk.delta.text:
            print(chunk.delta.text, end="")
```

---

## Google Gemini API Reference

### Chat API

```python
import google.generativeai as genai

genai.configure(api_key="AIza...")

model = genai.GenerativeModel("gemini-1.5-flash")

response = model.generate_content(
    "Hello!",
    generation_config=genai.types.GenerationConfig(
        temperature=0.7,
        max_output_tokens=500,
        top_p=0.95
    )
)

print(response.text)
```

### Chat with History

```python
chat = model.start_chat(history=[
    {"role": "user", "parts": "Hello"},
    {"role": "model", "parts": "Hi there!"}
])

response = chat.send_message("What's the weather?")
print(response.text)
```

### Parameters Explained

| Parameter | Description |
|-----------|-------------|
| `temperature` | 0.0-2.0, controls randomness |
| `max_output_tokens` | Maximum output tokens |
| `top_p` | 0.0-1.0, nucleus sampling |
| `top_k` | 1-40, top-K sampling |

### Models Available

| Model | Use Case |
|-------|----------|
| `gemini-1.5-pro` | Best quality, 2M context |
| `gemini-1.5-flash` | Fast, cheap, 1M context |

---

## Ollama API Reference

### Chat API

```python
import ollama

response = ollama.chat(
    model="llama3.2",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Hello!"}
    ],
    options={
        "temperature": 0.7,
        "num_predict": 500,
        "top_p": 0.9
    }
)

print(response["message"]["content"])
```

### Streaming Example

```python
stream = ollama.chat(
    model="llama3.2",
    messages=[{"role": "user", "content": "Tell me a story"}],
    stream=True
)

for chunk in stream:
    print(chunk["message"]["content"], end="")
```

### Parameters Explained

| Parameter | Description |
|-----------|-------------|
| `model` | Model name |
| `messages` | Conversation messages |
| `options.temperature` | 0.0-2.0, controls randomness |
| `options.num_predict` | Maximum tokens to generate |
| `options.top_p` | 0.0-1.0, nucleus sampling |
| `options.top_k` | Top-K sampling |

### Popular Models

| Model | Size | Use Case |
|-------|------|----------|
| `llama3.2` | 3B | Fast, general purpose |
| `llama3.2:7b` | 7B | Good quality |
| `mistral` | 7B | Good reasoning |
| `gemma2` | 9B | Good general purpose |
| `phi3` | 3.8B | Lightweight, efficient |

---

## Common Operations Cheat Sheet

### 1. Count Tokens

```python
import tiktoken

# OpenAI tokenizer
encoding = tiktoken.encoding_for_model("gpt-4o-mini")
tokens = len(encoding.encode("Your text here"))

# Or use the token counter from the tutorial
from token_counter import TokenCounter
counter = TokenCounter("gpt-4o-mini")
token_count = counter.count_tokens("Your text here")
```

### 2. Calculate Cost

```python
def calculate_cost(model, prompt_tokens, completion_tokens):
    pricing = {
        "gpt-4o-mini": {"input": 0.150, "output": 0.600},
        "gpt-4o": {"input": 5.00, "output": 15.00},
    }
    p = pricing.get(model, {"input": 0, "output": 0})
    return (prompt_tokens/1e6 * p["input"]) + (completion_tokens/1e6 * p["output"])

# Example
cost = calculate_cost("gpt-4o-mini", 1000, 200)
print(f"Cost: ${cost:.4f}")
```

### 3. Parse JSON Response

```python
import json

def parse_ai_json(response_text):
    try:
        return json.loads(response_text)
    except json.JSONDecodeError:
        # Try to extract JSON from markdown
        import re
        json_match = re.search(r'```json\s*(.*?)\s*```', response_text, re.DOTALL)
        if json_match:
            return json.loads(json_match.group(1))
        # Try to find JSON in text
        json_match = re.search(r'\{.*\}', response_text, re.DOTALL)
        if json_match:
            return json.loads(json_match.group())
        return {"error": "Could not parse JSON", "raw": response_text}
```

### 4. Rate Limit Handling

```python
import time
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=30)
)
def call_api_with_retry():
    # Your API call here
    pass
```

### 5. Safe Environment Variables

```python
import os
from dotenv import load_dotenv

load_dotenv()

def get_api_key(provider):
    key_map = {
        "openai": "OPENAI_API_KEY",
        "anthropic": "ANTHROPIC_API_KEY",
        "google": "GOOGLE_API_KEY"
    }
    key = os.getenv(key_map.get(provider))
    if not key:
        raise ValueError(f"API key for {provider} not found")
    return key
```

---

## Prompt Engineering Templates

### 1. General Chat Template

```python
chat_template = """
You are {role} with {experience} years of experience.
You communicate in a {tone} manner.
{additional_context}

User: {question}
Assistant:"""
```

### 2. Structured Extraction Template

```python
extraction_template = """
Extract the following fields from the text:
{fields}

Text:
{text}

Return as JSON object.

Output:
"""
```

### 3. Chain-of-Thought Template

```python
cot_template = """
Question: {question}

Let's solve this step by step:

Step 1: {step1}
Step 2: {step2}
Step 3: {step3}
Step 4: {step4}

Answer:"""
```

### 4. Few-Shot Template

```python
few_shot_template = """
Task: {task}

Examples:
{examples}

Now process:
Input: {input}
Output:"""
```

### 5. Code Review Template

```python
code_review_template = """
Review this code:

```{language}
{code}
```

Provide feedback on:
1. Correctness
2. Performance
3. Readability
4. Security

Review:
"""
```

---

## Function Calling Reference

### Defining a Function

```python
from function_definition import FunctionDefinition, Parameter, ParameterType

def get_weather(location: str, unit: str = "celsius") -> dict:
    # Implementation
    return {"temperature": 22, "condition": "sunny"}

function = FunctionDefinition(
    name="get_weather",
    description="Get current weather for a location",
    parameters=[
        Parameter(
            name="location",
            type=ParameterType.STRING,
            description="City name",
            required=True
        ),
        Parameter(
            name="unit",
            type=ParameterType.STRING,
            description="Temperature unit",
            enum=["celsius", "fahrenheit"],
            default="celsius"
        )
    ],
    handler=get_weather
)
```

### OpenAI Function Schema

```python
tool_schema = {
    "type": "function",
    "function": {
        "name": "get_weather",
        "description": "Get current weather for a location",
        "parameters": {
            "type": "object",
            "properties": {
                "location": {
                    "type": "string",
                    "description": "City name"
                },
                "unit": {
                    "type": "string",
                    "enum": ["celsius", "fahrenheit"],
                    "description": "Temperature unit"
                }
            },
            "required": ["location"]
        }
    }
}
```

---

## Embedding Models Reference

### OpenAI Embeddings

| Model | Dimensions | Cost ($/1M tokens) | Use Case |
|-------|------------|-------------------|----------|
| `text-embedding-3-small` | 1536 | $0.02 | General purpose |
| `text-embedding-3-large` | 3072 | $0.13 | Highest accuracy |
| `text-embedding-ada-002` | 1536 | $0.02 | Legacy |

### Open Source Embeddings

| Model | Dimensions | Size | Use Case |
|-------|------------|------|----------|
| `BAAI/bge-large-en-v1.5` | 1024 | 1.3GB | High quality |
| `sentence-transformers/all-MiniLM-L6-v2` | 384 | 80MB | Lightweight |
| `intfloat/e5-large-v2` | 1024 | 1.3GB | Search, retrieval |

### Similarity Functions

```python
import numpy as np

def cosine_similarity(a, b):
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

def euclidean_distance(a, b):
    return np.linalg.norm(a - b)

def dot_product_similarity(a, b):
    return np.dot(a, b)
```

---

## Vector Database Quick Reference

### ChromaDB (Local)

```python
import chromadb
from chromadb.utils import embedding_functions

# Initialize
client = chromadb.Client()
collection = client.create_collection(
    name="documents",
    embedding_function=embedding_functions.OpenAIEmbeddingFunction(
        api_key="sk-...",
        model_name="text-embedding-3-small"
    )
)

# Add documents
collection.add(
    documents=["Text 1", "Text 2"],
    metadatas=[{"source": "file1"}, {"source": "file2"}],
    ids=["id1", "id2"]
)

# Query
results = collection.query(
    query_texts=["Search query"],
    n_results=5,
    where={"source": "file1"}
)
```

### FAISS (Library)

```python
import faiss
import numpy as np

# Create index
dimension = 1536
index = faiss.IndexFlatL2(dimension)

# Add vectors
vectors = np.array(embeddings).astype('float32')
index.add(vectors)

# Search
query_vector = np.array(query_embedding).astype('float32').reshape(1, -1)
distances, indices = index.search(query_vector, k=5)
```

### pgvector (PostgreSQL)

```sql
-- Enable extension
CREATE EXTENSION vector;

-- Create table with vector column
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    content TEXT,
    embedding VECTOR(1536)
);

-- Insert
INSERT INTO documents (content, embedding)
VALUES ('Text', '[0.1, 0.2, ...]');

-- Search
SELECT * FROM documents
ORDER BY embedding <-> '[0.1, 0.2, ...]'
LIMIT 5;
```

---

## Common Error Codes

### OpenAI Errors

| Code | Meaning | Solution |
|------|---------|----------|
| 429 | Rate limit exceeded | Wait, use exponential backoff |
| 401 | Invalid API key | Check your API key |
| 400 | Bad request | Check your parameters |
| 404 | Model not found | Use a valid model name |
| 500 | Server error | Retry with backoff |

### Anthropic Errors

| Code | Meaning | Solution |
|------|---------|----------|
| 429 | Rate limit | Wait and retry |
| 401 | Invalid API key | Check your API key |
| 400 | Bad request | Check parameters |
| 529 | Overloaded | Retry with backoff |

### Common Solutions

```python
# Generic retry with exponential backoff
import time
import random

def retry_with_backoff(func, max_retries=3):
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise e
            delay = (2 ** attempt) + random.random()
            time.sleep(delay)
```

---

## Quick CLI Commands

### Environment Setup

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Install dependencies
pip install openai anthropic google-generativeai
pip install python-dotenv tiktoken chromadb
pip install fastapi uvicorn aiohttp

# Save dependencies
pip freeze > requirements.txt
```

### Running Servers

```bash
# FastAPI server
uvicorn app:app --host 0.0.0.0 --port 8000 --reload

# Ollama server
ollama serve

# ChromaDB server
chroma run --path ./chroma_data
```

### Testing

```bash
# Run tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=./ --cov-report=html

# Run a specific test
pytest tests/test_app.py -v
```

---

## Quick Reference: Response Times

| Model | Average Latency | 95th Percentile |
|-------|----------------|-----------------|
| gpt-4o-mini | 200-500ms | 800ms |
| gpt-4o | 500-1500ms | 2500ms |
| claude-3.5-sonnet | 600-1800ms | 3000ms |
| gemini-1.5-flash | 300-800ms | 1200ms |
| llama3.2 (local) | 100-300ms | 500ms |

---

## Quick Reference: Token Costs (gpt-4o-mini)

| Operation | Tokens | Cost |
|-----------|--------|------|
| Simple Q&A | ~200 | $0.00003 |
| Chat (10 turns) | ~2000 | $0.0003 |
| Document Summary (10K words) | ~15,000 | $0.0023 |
| Full Book (100K words) | ~150,000 | $0.0225 |

---

## Debugging Checklist

- [ ] API key is valid and has credits
- [ ] Model name is correct
- [ ] Parameters are within allowed ranges
- [ ] Context window not exceeded
- [ ] Rate limits not hit
- [ ] Network connectivity
- [ ] Environment variables set
- [ ] Dependencies installed correctly

---

**End of Appendix A**


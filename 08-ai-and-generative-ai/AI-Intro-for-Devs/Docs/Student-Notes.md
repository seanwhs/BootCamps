# AI Tutorial Series: Developer Edition
# Student Notes

**Comprehensive note-taking companion for the AI Tutorial Series—with guided notes, key concepts, code snippets, and personal reflections for each module.**

---

## Table of Contents

1. [How to Use These Notes](#how-to-use-these-notes)
2. [Phase 1: Understanding How LLMs Actually Work](#phase-1-understanding-how-llms-actually-work)
3. [Phase 2: Prompt Engineering & Model APIs](#phase-2-prompt-engineering--model-apis)
4. [Phase 3: AI Tool Use & Function Calling](#phase-3-ai-tool-use--function-calling)
5. [Phase 4: Retrieval-Augmented Generation (RAG)](#phase-4-retrieval-augmented-generation-rag)
6. [Phase 5: Agentic AI Systems](#phase-5-agentic-ai-systems)
7. [Phase 6: AI Application Engineering](#phase-6-ai-application-engineering)
8. [Phase 7: Production AI Architecture](#phase-7-production-ai-architecture)
9. [Appendix: Quick Reference](#appendix-quick-reference)

---

## How to Use These Notes

### Note-Taking Structure

Each module includes:
1. **Key Concepts** — Important ideas to remember
2. **Code Snippets** — Essential code to reference
3. **My Notes** — Space for your personal notes
4. **Questions** — Space to note questions for later
5. **Key Takeaways** — Summary of the module

### Symbols Used

| Symbol | Meaning |
|--------|---------|
| ⭐ | Critical concept to remember |
| 💡 | Practical tip or insight |
| ⚠️ | Warning or common pitfall |
| 🔥 | Important code snippet |
| ❓ | Question to investigate |
| 📝 | Personal note space |

---

## Phase 1: Understanding How LLMs Actually Work

### Module 1: Introduction to Generative AI

#### Key Concepts

```
⭐ LLMs are pattern-matching machines, not "thinking" entities
⭐ The Transformer architecture (2017) made modern LLMs possible
⭐ Different models (GPT, Claude, Gemini) have different strengths
⭐ System prompts control behavior more than user prompts
⭐ Temperature controls randomness in generation
```

#### Important Definitions

**AI (Artificial Intelligence):** ___________________________________________________

**ML (Machine Learning):** ___________________________________________________

**DL (Deep Learning):** ___________________________________________________

**Generative AI:** ___________________________________________________

**LLM (Large Language Model):** ___________________________________________________

**Transformer:** ___________________________________________________

**Attention Mechanism:** ___________________________________________________

#### Code Snippets

🔥 **First API Call**

```python
from openai import OpenAI
client = OpenAI(api_key="sk-...")

response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Explain what an LLM is."}
    ],
    temperature=0.7,
    max_tokens=200
)

print(response.choices[0].message.content)
```

🔥 **Streaming Response**

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

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- LLMs predict the next token based on patterns in training data
- The Transformer architecture processes all words simultaneously
- Different models are different tools for different jobs
- Every API call has a cost—manage token usage carefully
- System prompts set the "persona" for the AI

---

### Module 2: Tokens & Embeddings

#### Key Concepts

```
⭐ Tokens are chunks of text—different from words
⭐ Embeddings are vectors that capture meaning
⭐ Cosine similarity measures semantic similarity
⭐ Embeddings are the foundation of RAG
⭐ Token count = cost (less tokens = cheaper)
```

#### Important Definitions

**Token:** ___________________________________________________

**Tokenization:** ___________________________________________________

**Embedding:** ___________________________________________________

**Cosine Similarity:** ___________________________________________________

**Semantic Search:** ___________________________________________________

#### Token Counts (Rough Estimates)

| Text | Tokens |
|------|--------|
| 1 English word | ~1.3 tokens |
| 1 Chinese character | ~1 token |
| 100 words | ~75 tokens |
| 1 page of text | ~300 tokens |
| 1 book (300 pages) | ~90,000 tokens |

#### Code Snippets

🔥 **Count Tokens**

```python
import tiktoken

encoding = tiktoken.encoding_for_model("gpt-4o-mini")
tokens = len(encoding.encode("Your text here"))
print(f"Tokens: {tokens}")
```

🔥 **Generate Embeddings**

```python
from openai import OpenAI
client = OpenAI()

response = client.embeddings.create(
    model="text-embedding-3-small",
    input="Your text here"
)

embedding = response.data[0].embedding
print(f"Embedding dimension: {len(embedding)}")
```

🔥 **Cosine Similarity**

```python
import numpy as np

def cosine_similarity(a, b):
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

similarity = cosine_similarity(embedding1, embedding2)
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Tokens are the units LLMs process (not words)
- Embeddings convert meaning to numbers
- Similar meanings = similar embeddings
- Cosine similarity is the standard measure
- Embeddings enable semantic search and RAG

---

### Module 3: How LLM Inference Works

#### Key Concepts

```
⭐ LLMs predict one token at a time
⭐ Temperature controls creativity (0 = greedy, >1 = random)
⭐ Top-K limits candidate tokens
⭐ Top-P dynamically filters candidates
⭐ Hallucinations happen when patterns don't match reality
```

#### Important Definitions

**Inference:** ___________________________________________________

**Logits:** ___________________________________________________

**Softmax:** ___________________________________________________

**Temperature:** ___________________________________________________

**Top-K:** ___________________________________________________

**Top-P (Nucleus Sampling):** ___________________________________________________

**Hallucination:** ___________________________________________________

#### Parameter Reference

| Parameter | Range | Effect |
|-----------|-------|--------|
| Temperature | 0.0 – 2.0 | Controls randomness |
| Top-K | 1 – N | Limit candidates |
| Top-P | 0.0 – 1.0 | Dynamic filtering |
| Max Tokens | 1 – context | Response length |

#### Use Case Guide

| Use Case | Temperature | Top-P |
|----------|-------------|-------|
| Data Extraction | 0.0 | 1.0 |
| Factual Q&A | 0.3 | 0.9 |
| General Chat | 0.7 | 0.9 |
| Creative Writing | 0.9 | 0.95 |
| Brainstorming | 1.0 | 1.0 |
| Code Generation | 0.0 | 1.0 |

#### Code Snippets

🔥 **Controlling Temperature**

```python
# Deterministic (temperature = 0)
response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": "Tell me a joke"}],
    temperature=0.0  # Always picks most likely token
)

# Creative (temperature = 1.0)
response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": "Tell me a joke"}],
    temperature=1.0  # More random, creative
)
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- LLMs predict the next token (one at a time)
- Temperature controls how creative/deterministic responses are
- Top-K and Top-P refine token selection
- Hallucinations are the model making things up
- Lower temperature = fewer hallucinations
- Choose parameters based on your use case

---

### Module 4: Context Windows & Memory

#### Key Concepts

```
⭐ Context window = how much the model can "remember"
⭐ Exceeding the window = error or lost memory
⭐ Manage memory with truncation, sliding windows, summarization
⭐ Different models have different context sizes
⭐ Token usage = cost (manage it carefully)
```

#### Context Window Comparison

| Model | Context Window | Pages of Text |
|-------|---------------|---------------|
| GPT-3.5 | 16,384 | ~40 |
| GPT-4-Turbo | 128,000 | ~300 |
| GPT-4o | 128,000 | ~300 |
| Claude 3.5 | 200,000 | ~500 |
| Gemini 1.5 | 2,000,000 | ~5,000 |
| Llama 3 | 128,000 | ~300 |

#### Memory Management Strategies

**1. Truncation:** Drop oldest messages

```python
messages = messages[-10:]  # Keep last 10 messages
```

**2. Sliding Window:** Keep recent + system

```python
messages = [system_prompt] + messages[-10:]
```

**3. Summarization:** Condense old messages

```python
summary = summarize_with_llm(old_messages)
messages = [summary] + recent_messages
```

**4. Hierarchical Memory:** Multiple levels

```python
# Level 1: Immediate context (last 5 messages)
# Level 2: Recent history (summarized)
# Level 3: Long-term memory (vector database)
```

#### Code Snippets

🔥 **Simple Chatbot with Memory**

```python
messages = [
    {"role": "system", "content": "You are a helpful assistant."}
]

while True:
    user_input = input("You: ")
    messages.append({"role": "user", "content": user_input})
    
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=messages,
        max_tokens=200
    )
    
    assistant_response = response.choices[0].message.content
    print(f"Assistant: {assistant_response}")
    messages.append({"role": "assistant", "content": assistant_response})
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Context window limits how much the model can "remember"
- Every message adds tokens to the context
- Memory management is essential for long conversations
- Different strategies work for different use cases
- Plan your context usage before building your app

---

## Phase 2: Prompt Engineering & Model APIs

### Module 5: AI APIs

#### Key Concepts

```
⭐ Different providers have different APIs, features, and pricing
⭐ Rate limits require careful management
⭐ Costs vary significantly between models
⭐ Route tasks to the right model for cost optimization
⭐ Always have fallback strategies
```

#### Provider Comparison

| Feature | OpenAI | Anthropic | Google | Ollama |
|---------|--------|-----------|--------|--------|
| Models | GPT-4, GPT-3.5 | Claude 3.5 | Gemini | Llama, Mistral |
| Pricing | Per token | Per token | Per token | Free |
| Streaming | ✅ | ✅ | ✅ | ✅ |
| Function Calling | ✅ | ✅ | ✅ | Limited |
| Vision | ✅ | ✅ | ✅ | Limited |

#### Cost Optimization Strategies

| Strategy | Savings | How |
|----------|---------|-----|
| Model Selection | 50-90% | Use cheaper models for simple tasks |
| Prompt Optimization | 20-40% | Shorten prompts, remove redundancy |
| Caching | 30-90% | Cache identical requests |
| Batching | 10-30% | Batch multiple requests together |

#### Code Snippets

🔥 **Multi-Provider Client**

```python
from openai import OpenAI
from anthropic import Anthropic
import google.generativeai as genai

class AIClient:
    def __init__(self, provider="openai"):
        self.provider = provider
        if provider == "openai":
            self.client = OpenAI()
        elif provider == "anthropic":
            self.client = Anthropic()
        elif provider == "google":
            genai.configure(api_key="...")
            self.client = genai
    
    def generate(self, prompt):
        if self.provider == "openai":
            response = self.client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[{"role": "user", "content": prompt}]
            )
            return response.choices[0].message.content
        # Add other providers...
```

🔥 **Rate Limit Handling**

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

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Different providers have different strengths
- Rate limits require careful management
- Choose the right model for cost and quality
- Always implement retry logic
- Monitor your usage and costs

---

### Module 6: Prompt Engineering Fundamentals

#### Key Concepts

```
⭐ System prompts set the AI's persona and behavior
⭐ Chain-of-Thought forces step-by-step reasoning
⭐ Few-shot examples improve performance
⭐ Self-consistency finds consensus across responses
⭐ Templates make prompts reusable and maintainable
```

#### The Three Elements of a Good Prompt

1. **Role:** Who should answer?
2. **Task:** What to do?
3. **Conditions:** How to output?

#### Prompt Templates

**1. General Chat**
```
You are {role} with {experience} years of experience.
User: {question}
Assistant:
```

**2. Structured Extraction**
```
Extract {fields} from the text: {text}
Return as JSON.
```

**3. Chain-of-Thought**
```
Question: {question}
Let's think step by step:
Step 1:
Step 2:
Step 3:
Answer:
```

**4. Few-Shot**
```
Examples:
{examples}
Now process: {input}
```

#### Code Snippets

🔥 **System Prompt Design**

```python
system_prompts = {
    "helpful": "You are a helpful assistant.",
    "expert": "You are an expert consultant with 20 years of experience.",
    "creative": "You are a creative writer with a flair for storytelling.",
    "technical": "You are a senior software engineer providing technical guidance."
}

# Use different personas for different tasks
def get_response(prompt, persona="helpful"):
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": system_prompts[persona]},
            {"role": "user", "content": prompt}
        ]
    )
    return response.choices[0].message.content
```

🔥 **Chain-of-Thought**

```python
# Without CoT (may be wrong)
prompt = "What is 23 * 17?"

# With CoT (more accurate)
prompt = """
What is 23 * 17?
Let's think step by step:
Step 1: 23 * 10 = 230
Step 2: 23 * 7 = 161
Step 3: 230 + 161 = 391

Answer: 391
"""
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- System prompts control the AI's persona
- Chain-of-Thought improves accuracy on reasoning tasks
- Few-shot examples improve consistency
- Self-consistency helps find the right answer
- Templates make prompts reusable

---

### Module 7: Structured Outputs

#### Key Concepts

```
⭐ Structured outputs turn LLMs into data processing systems
⭐ JSON is the most common structured format
⭐ JSON Schema validates data quality
⭐ Schemas define required fields and types
⭐ Error handling is essential for reliable extraction
```

#### Common Structured Output Formats

| Format | Use Case | Example |
|--------|----------|---------|
| JSON | Most common | `{"name": "John", "age": 32}` |
| JSON Schema | Validation | `{"type": "object", "properties": {...}}` |
| XML | Enterprise | `<person><name>John</name></person>` |

#### Code Snippets

🔥 **JSON Mode**

```python
response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": prompt}],
    response_format={"type": "json_object"}
)

data = json.loads(response.choices[0].message.content)
```

🔥 **Schema Validation**

```python
schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer", "minimum": 0},
        "email": {"type": "string", "format": "email"}
    },
    "required": ["name", "age"]
}

def validate_data(data, schema):
    # Validate against schema
    import jsonschema
    jsonschema.validate(data, schema)
```

🔥 **Email Parser**

```python
def parse_email(email_text):
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": "Extract structured data from the email."},
            {"role": "user", "content": email_text}
        ],
        response_format={"type": "json_object"}
    )
    
    data = json.loads(response.choices[0].message.content)
    return data
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Structured outputs enable automation and integration
- JSON with schemas ensures data quality
- Error handling is essential for production systems
- Different parsers for different use cases
- Validation catches data quality issues

---

### Module 8: Multimodal AI

#### Key Concepts

```
⭐ Multimodal AI processes text, images, and audio
⭐ Vision models understand and describe images
⭐ OCR extracts text from images and documents
⭐ Speech-to-text converts audio to text
⭐ Text-to-speech converts text to audio
```

#### Multimodal Capabilities

| Capability | Input | Output | Use Case |
|------------|-------|--------|----------|
| Vision | Image | Text | Image description, visual QA |
| OCR | Image | Text | Document digitization |
| Speech-to-Text | Audio | Text | Transcription |
| Text-to-Speech | Text | Audio | Voice synthesis |
| Image Generation | Text | Image | Content creation |

#### Code Snippets

🔥 **Vision Understanding**

```python
import base64

def analyze_image(image_path):
    with open(image_path, "rb") as f:
        image_data = base64.b64encode(f.read()).decode()
    
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "user", "content": [
                {"type": "text", "text": "What do you see in this image?"},
                {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{image_data}"}}
            ]}
        ]
    )
    
    return response.choices[0].message.content
```

🔥 **Speech-to-Text**

```python
audio_file = open("speech.mp3", "rb")
response = client.audio.transcriptions.create(
    model="whisper-1",
    file=audio_file
)
print(response.text)
```

🔥 **Image Generation**

```python
response = client.images.generate(
    model="dall-e-3",
    prompt="A serene mountain lake at sunset",
    n=1,
    size="1024x1024"
)

image_url = response.data[0].url
print(image_url)
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Multimodal AI extends AI beyond text
- Vision models can analyze and describe images
- OCR digitizes documents and images
- Speech-to-text enables voice interfaces
- Image generation creates visual content

---

## Phase 3: AI Tool Use & Function Calling

### Module 9: Function Calling

#### Key Concepts

```
⭐ Function calling gives LLMs real-world capabilities
⭐ Functions are defined with JSON schemas
⭐ LLMs generate function calls based on user queries
⭐ Tools execute functions and return results
⭐ Error handling is crucial for reliability
```

#### Function Calling Flow

```
User Query → LLM → Function Call → Tool Execution → Result → LLM → Response
```

#### Code Snippets

🔥 **Defining a Tool**

```python
tools = [
    {
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
                        "default": "celsius"
                    }
                },
                "required": ["location"]
            }
        }
    }
]
```

🔥 **Executing a Tool**

```python
# User query
user_input = "What's the weather in London?"

response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": user_input}],
    tools=tools
)

# Check for tool call
if response.choices[0].message.tool_calls:
    tool_call = response.choices[0].message.tool_calls[0]
    if tool_call.function.name == "get_weather":
        args = json.loads(tool_call.function.arguments)
        weather = get_weather(args["location"], args.get("unit", "celsius"))
```

🔥 **Tool Registry**

```python
class ToolRegistry:
    def __init__(self):
        self.tools = {}
    
    def register(self, name, handler, schema):
        self.tools[name] = {"handler": handler, "schema": schema}
    
    def execute(self, name, args):
        if name in self.tools:
            return self.tools[name]["handler"](**args)
        raise ValueError(f"Tool not found: {name}")
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Function calling extends LLM capabilities
- Tools are defined with JSON schemas
- LLMs decide when to call tools
- Execute tools and return results
- Error handling is essential

---

### Module 10: Tool Orchestration

#### Key Concepts

```
⭐ Orchestration coordinates multiple tools
⭐ Sequential execution handles dependencies
⭐ Parallel execution improves performance
⭐ Error recovery ensures reliability
⭐ Workflows automate complex tasks
```

#### Orchestration Patterns

**1. Sequential:** Tools run one after another

```python
result1 = tool1.execute()
result2 = tool2.execute(result1)
result3 = tool3.execute(result2)
```

**2. Parallel:** Tools run simultaneously

```python
results = await asyncio.gather(
    tool1.execute(),
    tool2.execute(),
    tool3.execute()
)
```

**3. Conditional:** Tools run based on conditions

```python
if condition:
    result = tool1.execute()
else:
    result = tool2.execute()
```

**4. Loop:** Tools run repeatedly

```python
while not condition_met:
    result = tool.execute()
    condition_met = check_condition(result)
```

#### Code Snippets

🔥 **Sequential Workflow**

```python
def execute_workflow(steps, initial_context=None):
    context = initial_context or {}
    
    for step in steps:
        # Prepare arguments with context
        args = {k: context.get(v) if isinstance(v, str) and v.startswith('$') else v 
                for k, v in step['args'].items()}
        
        # Execute step
        result = step['tool'](**args)
        
        # Update context
        context[step['name']] = result
    
    return context
```

🔥 **Parallel Execution**

```python
from concurrent.futures import ThreadPoolExecutor

def execute_parallel(tasks):
    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = {executor.submit(t['tool'], **t['args']): t for t in tasks}
        results = []
        
        for future in futures:
            try:
                result = future.result()
                results.append({"success": True, "result": result})
            except Exception as e:
                results.append({"success": False, "error": str(e)})
        
        return results
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Orchestration coordinates multiple tools
- Sequential execution handles dependencies
- Parallel execution improves performance
- Error recovery ensures reliability
- Workflows automate complex tasks

---

### Module 11: Model Context Protocol (MCP)

#### Key Concepts

```
⭐ MCP standardizes AI-tool integration
⭐ Resources provide data and content
⭐ Prompts are reusable templates
⭐ Tools are executable functions
⭐ Servers expose capabilities, clients discover them
```

#### MCP Components

| Component | Description | Example |
|-----------|-------------|---------|
| **Client** | AI application | Chatbot, agent |
| **Server** | Service provider | File server, database |
| **Resources** | Data | Files, records |
| **Prompts** | Templates | Email templates |
| **Tools** | Functions | Query, update |

#### MCP Architecture

```
Client → Transport (Stdio/SSE/WebSocket) → Server
                                           → Resources
                                           → Prompts
                                           → Tools
```

#### Code Snippets

🔥 **MCP Server**

```python
from mcp import Server, Tool

server = Server(name="my-server")

@server.resource("file:///data/report.txt")
def get_report():
    return "Report content"

@server.prompt("greeting")
def greeting_prompt(name):
    return f"Hello, {name}!"

@server.tool()
def calculate(expression: str) -> float:
    return eval(expression)

server.run()
```

🔥 **MCP Client**

```python
from mcp import Client

client = Client("my-client")
client.connect("my-server")

# List resources
resources = client.list_resources()

# Read a resource
content = client.read_resource("file:///data/report.txt")

# Call a tool
result = client.call_tool("calculate", {"expression": "2 + 3"})
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- MCP standardizes AI-tool integration
- Resources provide data
- Prompts are reusable templates
- Tools are executable functions
- Security is built into the protocol

---

## Phase 4: Retrieval-Augmented Generation (RAG)

### Module 12: Embeddings & Vector Databases

#### Key Concepts

```
⭐ Embeddings convert text to semantic vectors
⭐ Similar vectors have similar meanings
⭐ Vector databases store and search embeddings
⭐ Chunking prepares documents for embedding
⭐ Cosine similarity measures semantic similarity
```

#### Vector Databases

| Database | Type | Best For |
|----------|------|----------|
| Chroma | Embedded | Development |
| Pinecone | Cloud | Production |
| FAISS | Library | Research |
| Weaviate | Hybrid | Complex data |
| pgvector | PostgreSQL extension | PostgreSQL users |

#### Chunking Strategies

| Strategy | Pros | Cons |
|----------|------|------|
| Fixed Size | Simple | May break semantic units |
| Sentence | Preserves meaning | Inconsistent sizes |
| Paragraph | Natural units | May be too large |
| Semantic | Best coherence | Complex to implement |

#### Code Snippets

🔥 **Document Chunking**

```python
def chunk_document(text, chunk_size=500):
    sentences = re.split(r'(?<=[.!?])\s+', text)
    
    chunks = []
    current_chunk = []
    current_size = 0
    
    for sentence in sentences:
        words = sentence.split()
        if current_size + len(words) > chunk_size:
            chunks.append(" ".join(current_chunk))
            current_chunk = []
            current_size = 0
        
        current_chunk.extend(words)
        current_size += len(words)
    
    if current_chunk:
        chunks.append(" ".join(current_chunk))
    
    return chunks
```

🔥 **Vector Store**

```python
class VectorStore:
    def __init__(self):
        self.vectors = []
        self.metadata = []
    
    def add(self, vector, metadata):
        self.vectors.append(vector)
        self.metadata.append(metadata)
    
    def search(self, query_vector, top_k=5):
        scores = [cosine_similarity(query_vector, v) for v in self.vectors]
        indices = np.argsort(scores)[::-1][:top_k]
        return [(self.metadata[i], scores[i]) for i in indices]
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Embeddings convert meaning to numbers
- Vector databases enable semantic search
- Chunking is essential for RAG
- Different strategies work for different content
- Cosine similarity measures semantic closeness

---

### Module 13: Building a RAG Pipeline

#### Key Concepts

```
⭐ Document ingestion processes and stores knowledge
⭐ Retrieval finds relevant information for queries
⭐ Context construction builds optimal prompts
⭐ Generation produces accurate, cited responses
⭐ Citations build trust and enable verification
```

#### RAG Pipeline Stages

1. **Document Ingestion:** Process and store documents
2. **Retrieval:** Find relevant chunks
3. **Context Construction:** Build prompt with sources
4. **Generation:** Produce answer with citations
5. **Citation:** Attribute sources

#### Code Snippets

🔥 **Complete RAG Pipeline**

```python
class RAGPipeline:
    def __init__(self):
        self.vector_store = VectorStore()
        self.llm = OpenAI()
    
    def ingest(self, documents):
        for doc in documents:
            chunks = chunk_document(doc)
            embeddings = get_embeddings(chunks)
            for chunk, embedding in zip(chunks, embeddings):
                self.vector_store.add(embedding, {"text": chunk})
    
    def query(self, question):
        # 1. Retrieve
        query_embedding = get_embedding(question)
        results = self.vector_store.search(query_embedding, top_k=5)
        
        # 2. Build context
        context = "\n".join([r[0]["text"] for r in results])
        
        # 3. Generate
        response = self.llm.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "Answer based on the context."},
                {"role": "user", "content": f"Context: {context}\n\nQuestion: {question}"}
            ]
        )
        
        return response.choices[0].message.content
```

🔥 **Citation System**

```python
def add_citations(response, sources):
    # Add source references to response
    cited_response = response
    for i, source in enumerate(sources, 1):
        cited_response += f"\n[Source {i}]: {source['source']}"
    
    return cited_response
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- RAG combines retrieval with generation
- Document ingestion is the first step
- Retrieval finds relevant information
- Context construction is crucial
- Citations build trust

---

### Module 14: Advanced RAG

#### Key Concepts

```
⭐ Hybrid search = keyword + semantic for better recall
⭐ Context compression = fit more information in context
⭐ Parent-child retrieval = precision + context
⭐ Knowledge graphs = relationships and connections
⭐ Optimization = continuous improvement
```

#### Advanced Techniques

| Technique | What It Does | Impact |
|-----------|--------------|--------|
| Hybrid Search | Keyword + semantic | High recall |
| Context Compression | Summarizes chunks | Better utilization |
| Parent-Child Retrieval | Finds chunks, returns documents | Better coherence |
| Knowledge Graphs | Adds relationship data | Richer answers |
| Re-ranking | Optimizes retrieval order | Better precision |

#### Code Snippets

🔥 **Hybrid Search**

```python
def hybrid_search(query, top_k=10):
    # Semantic search
    semantic_results = semantic_search(query, top_k=top_k*2)
    
    # Keyword search (BM25)
    keyword_results = keyword_search(query, top_k=top_k*2)
    
    # Combine scores
    combined = {}
    for doc, score in semantic_results:
        combined[doc] = score * 0.7
    for doc, score in keyword_results:
        combined[doc] = combined.get(doc, 0) + score * 0.3
    
    return sorted(combined.items(), key=lambda x: x[1], reverse=True)[:top_k]
```

🔥 **Context Compression**

```python
def compress_context(chunks, max_tokens=2000):
    # Extract key sentences
    compressed = []
    for chunk in chunks:
        sentences = chunk.split('. ')
        # Keep first sentence and sentences with important keywords
        important = [sentences[0]]
        for sent in sentences[1:]:
            if any(kw in sent.lower() for kw in ["important", "key", "critical"]):
                important.append(sent)
        compressed.append('. '.join(important))
    
    return compressed
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Hybrid search combines keyword and semantic
- Context compression fits more information
- Parent-child retrieval provides better context
- Knowledge graphs add relationships
- Optimization is continuous

---

## Phase 5: Agentic AI Systems

### Module 15: AI Agents

#### Key Concepts

```
⭐ Agents plan, execute, and reflect
⭐ Memory stores and retrieves information
⭐ Tools extend agent capabilities
⭐ Reflection enables self-improvement
⭐ Goal decomposition handles complexity
```

#### Agent Components

| Component | Description | Example |
|-----------|-------------|---------|
| Planning | Break down goals | "To write a report..." |
| Reasoning | Think through problems | "If X, then Y..." |
| Memory | Remember past interactions | "User prefers concise answers" |
| Tool Use | Use external tools | Weather API, calculator |
| Reflection | Evaluate and improve | "My response was too long" |
| Learning | Adapt over time | "User likes technical details" |

#### Code Snippets

🔥 **Simple Agent**

```python
class SimpleAgent:
    def __init__(self):
        self.memory = []
    
    def run(self, goal):
        # 1. Plan
        plan = self.plan(goal)
        
        # 2. Execute
        for step in plan:
            result = self.execute(step)
            self.memory.append(result)
        
        # 3. Reflect
        reflection = self.reflect(self.memory)
        
        return self.synthesize(self.memory, reflection)
    
    def plan(self, goal):
        # Break goal into steps
        return ["step1", "step2", "step3"]
    
    def execute(self, step):
        # Execute a step
        return f"Executed {step}"
    
    def reflect(self, memory):
        # Evaluate performance
        return "Good execution"
```

🔥 **Reflection System**

```python
def reflect(action, result):
    prompt = f"""
    Action: {action}
    Result: {result}
    
    Evaluate:
    1. What went well?
    2. What could be improved?
    3. What did you learn?
    4. Score (1-10)
    """
    
    response = llm.generate(prompt)
    return response
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Agents plan, execute, and reflect
- Memory is essential for learning
- Tools extend capabilities
- Reflection enables improvement
- Goal decomposition handles complexity

---

### Module 16: Multi-Agent Systems (A2A)

#### Key Concepts

```
⭐ Multiple agents collaborate on complex tasks
⭐ Coordinators plan and delegate
⭐ Workers execute specific tasks
⭐ Communication enables coordination
⭐ Hierarchical teams provide structure
```

#### Communication Patterns

| Pattern | Description | Use Case |
|---------|-------------|----------|
| Hierarchical | Coordinator delegates | Clear structure |
| Peer-to-Peer | Direct communication | Collaborative problems |
| Broadcast | One sends to all | Information sharing |
| Pipeline | Sequential handoff | Step-by-step workflows |
| Swarm | Decentralized | Emergent problems |

#### Code Snippets

🔥 **Coordinator Agent**

```python
class Coordinator:
    def __init__(self):
        self.workers = []
    
    def register_worker(self, worker):
        self.workers.append(worker)
    
    def assign_task(self, task):
        # Find best worker
        best_worker = None
        best_score = -1
        
        for worker in self.workers:
            score = worker.match(task)
            if score > best_score:
                best_score = score
                best_worker = worker
        
        return best_worker.execute(task)
```

🔥 **Worker Agent**

```python
class Worker:
    def __init__(self, name, capabilities):
        self.name = name
        self.capabilities = capabilities
        self.status = "idle"
    
    def match(self, task):
        # Score based on capability match
        return sum(1 for cap in self.capabilities if cap in task.required_capabilities)
    
    def execute(self, task):
        self.status = "busy"
        result = self.do_work(task)
        self.status = "idle"
        return result
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Multiple agents collaborate on complex tasks
- Coordinators plan and delegate
- Workers execute specific tasks
- Communication enables coordination
- Different structures suit different problems

---

### Module 17: Agent Memory

#### Key Concepts

```
⭐ Short-term memory holds immediate context
⭐ Long-term memory stores persistent knowledge
⭐ Episodic memory recalls specific events
⭐ Semantic memory stores general knowledge
⭐ Pruning keeps memory efficient
```

#### Memory Types

| Type | Duration | Purpose |
|------|----------|---------|
| Short-Term | Minutes | Immediate reasoning |
| Long-Term | Permanent | Persistent knowledge |
| Episodic | Permanent | Event recall |
| Semantic | Permanent | General facts |

#### Code Snippets

🔥 **Short-Term Memory**

```python
class ShortTermMemory:
    def __init__(self, max_size=20):
        self.memory = deque(maxlen=max_size)
    
    def add(self, item):
        self.memory.append(item)
    
    def retrieve(self, top_k=5):
        return list(self.memory)[-top_k:]
```

🔥 **Long-Term Memory (Vector Database)**

```python
class LongTermMemory:
    def __init__(self):
        self.store = VectorStore()
    
    def add(self, content, metadata):
        embedding = get_embedding(content)
        self.store.add(embedding, {"content": content, "metadata": metadata})
    
    def retrieve(self, query, top_k=5):
        query_embedding = get_embedding(query)
        return self.store.search(query_embedding, top_k=top_k)
```

🔥 **Memory Consolidation**

```python
def consolidate_memories(short_term, long_term):
    # Move important memories from short-term to long-term
    for item in short_term.memory:
        if item.importance > 0.8:
            long_term.add(item.content, item.metadata)
    
    # Clear short-term
    short_term.clear()
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Different memory types serve different purposes
- Short-term memory holds immediate context
- Long-term memory stores persistent knowledge
- Episodic memory recalls specific events
- Semantic memory stores general knowledge
- Pruning keeps memory efficient

---

## Phase 6: AI Application Engineering

### Module 18: Asynchronous AI Programming

#### Key Concepts

```
⭐ Async programming maximizes I/O efficiency
⭐ Non-blocking calls improve throughput
⭐ Streaming provides real-time user experience
⭐ Concurrency handles multiple requests
⭐ SSE is great for server-to-client streaming
```

#### Async vs Sync

| Aspect | Synchronous | Asynchronous |
|--------|-------------|--------------|
| Response Time | Sequential | Parallel |
| Throughput | Limited by I/O | I/O-bound scaling |
| Resource Usage | Idle waiting | Full utilization |

#### Code Snippets

🔥 **Async AI Client**

```python
import asyncio
from openai import AsyncOpenAI

async def generate_response(prompt):
    client = AsyncOpenAI()
    response = await client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}]
    )
    return response.choices[0].message.content

async def main():
    prompts = ["What is AI?", "What is ML?", "What is NLP?"]
    tasks = [generate_response(p) for p in prompts]
    results = await asyncio.gather(*tasks)
    
    for prompt, result in zip(prompts, results):
        print(f"{prompt}\n{result}\n")

asyncio.run(main())
```

🔥 **SSE Server (FastAPI)**

```python
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
import json

app = FastAPI()

@app.get("/stream")
async def stream(prompt: str):
    async def generate():
        async for chunk in client.stream_generate(prompt):
            yield f"data: {json.dumps({'chunk': chunk})}\n\n"
    
    return StreamingResponse(
        generate(),
        media_type="text/event-stream"
    )
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Async programming maximizes I/O efficiency
- Non-blocking calls improve throughput
- Streaming provides real-time user experience
- Concurrency handles multiple requests
- SSE is great for web streaming

---

### Module 19: Resilient AI Systems

#### Key Concepts

```
⭐ Retries handle transient failures gracefully
⭐ Circuit breakers prevent cascading failures
⭐ Timeouts prevent hanging operations
⭐ Rate limiting prevents overwhelming services
⭐ Bulkheads isolate failures
```

#### Resilience Patterns

| Pattern | Problem Solved | How It Works |
|---------|---------------|--------------|
| Retry | Transient failures | Retry with backoff |
| Circuit Breaker | Cascading failures | Stop requests after failures |
| Timeout | Hanging operations | Cancel after time limit |
| Rate Limiting | Overwhelming services | Limit request rate |
| Bulkhead | Resource exhaustion | Isolate components |

#### Code Snippets

🔥 **Retry with Exponential Backoff**

```python
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

🔥 **Circuit Breaker**

```python
class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=30):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failure_count = 0
        self.state = "closed"
        self.last_failure = None
    
    def execute(self, func):
        if self.state == "open":
            if time.time() - self.last_failure > self.recovery_timeout:
                self.state = "half-open"
            else:
                raise Exception("Circuit is open")
        
        try:
            result = func()
            if self.state == "half-open":
                self.state = "closed"
                self.failure_count = 0
            return result
        except Exception as e:
            self.failure_count += 1
            self.last_failure = time.time()
            if self.failure_count >= self.failure_threshold:
                self.state = "open"
            raise e
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Retries handle transient failures
- Circuit breakers prevent cascading failures
- Timeouts prevent hanging operations
- Rate limiting prevents overwhelming services
- Bulkheads isolate failures

---

### Module 20: AI Observability

#### Key Concepts

```
⭐ Logging captures structured events
⭐ Tracing tracks request flows
⭐ Metrics measure system performance
⭐ Cost monitoring tracks spending
⭐ Latency analysis identifies bottlenecks
```

#### Observability Pillars

1. **Logging:** Structured events
2. **Tracing:** Request flows
3. **Metrics:** Measurements

#### Code Snippets

🔥 **Structured Logger**

```python
import json
import logging
from datetime import datetime

class StructuredLogger:
    def __init__(self, name):
        self.logger = logging.getLogger(name)
    
    def log(self, level, message, **kwargs):
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "level": level,
            "message": message,
            **kwargs
        }
        self.logger.info(json.dumps(log_entry))
```

🔥 **Token & Cost Monitor**

```python
class CostMonitor:
    def __init__(self):
        self.usage = {"tokens": 0, "cost": 0}
    
    def track(self, model, prompt_tokens, completion_tokens):
        pricing = {
            "gpt-4o-mini": {"input": 0.00000015, "output": 0.00000060}
        }
        
        cost = (prompt_tokens * pricing[model]["input"] +
                completion_tokens * pricing[model]["output"])
        
        self.usage["tokens"] += prompt_tokens + completion_tokens
        self.usage["cost"] += cost
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Logging captures structured events
- Tracing tracks request flows
- Metrics measure system performance
- Cost monitoring tracks spending
- Latency analysis identifies bottlenecks

---

### Module 21: AI Security

#### Key Concepts

```
⭐ Prompt injection is a primary attack vector
⭐ Jailbreaks attempt to bypass safety measures
⭐ Data leakage exposes sensitive information
⭐ Tool abuse can cause system damage
⭐ Multiple layers of security are essential
```

#### Common Attack Vectors

| Attack Type | Description | Example |
|-------------|-------------|---------|
| Prompt Injection | Malicious instructions | "Ignore previous instructions..." |
| Jailbreak | Circumventing safety | "Act as DAN (Do Anything Now)" |
| Data Leakage | Exposing sensitive info | "What's in your training data?" |
| Tool Abuse | Misusing tools | "Delete all files" |

#### Code Snippets

🔥 **Prompt Injection Detector**

```python
class PromptInjectionDetector:
    def __init__(self):
        self.patterns = [
            r"(?i)ignore\s+(?:all\s+)?(?:previous|prior|above)\s+instructions",
            r"(?i)you\s+are\s+now\s+an?\s+administrator",
            r"(?i)system\s+prompt",
        ]
    
    def detect(self, text):
        matches = []
        for pattern in self.patterns:
            if re.search(pattern, text):
                matches.append(pattern)
        
        return {"is_injection": len(matches) > 0, "matches": matches}
```

🔥 **Data Leakage Protector**

```python
class DataLeakageProtector:
    def __init__(self):
        self.patterns = {
            "email": r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
            "phone": r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b',
            "ssn": r'\b\d{3}-\d{2}-\d{4}\b',
            "api_key": r'(sk-\w{20,})'
        }
    
    def redact(self, text):
        for name, pattern in self.patterns.items():
            text = re.sub(pattern, f"[REDACTED_{name}]", text)
        return text
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Prompt injection is a primary attack vector
- Jailbreaks attempt to bypass safety measures
- Data leakage exposes sensitive information
- Tool abuse can cause system damage
- Multiple layers of security are essential

---

## Phase 7: Production AI Architecture

### Module 22: AI System Architecture

#### Key Concepts

```
⭐ Gateways provide unified entry points
⭐ Routers enable intelligent model selection
⭐ Caches reduce costs and latency
⭐ Load balancers distribute traffic
⭐ Fallback ensures availability
```

#### Architecture Components

| Component | Purpose |
|-----------|---------|
| AI Gateway | Authentication, rate limiting |
| Model Router | Cost/quality optimization |
| Response Cache | Reduce costs |
| Load Balancer | Distribute traffic |
| Model Fallback | Ensure availability |

#### Code Snippets

🔥 **Model Router**

```python
class ModelRouter:
    def __init__(self):
        self.models = {
            "gpt-4o-mini": {"cost": 0.001, "quality": 0.7, "speed": 0.9},
            "gpt-4o": {"cost": 0.030, "quality": 0.95, "speed": 0.6}
        }
    
    def route(self, task, strategy="balanced"):
        if strategy == "cost":
            return min(self.models, key=lambda x: self.models[x]["cost"])
        elif strategy == "quality":
            return max(self.models, key=lambda x: self.models[x]["quality"])
        else:
            # Balanced: combine cost and quality
            scores = {}
            for name, model in self.models.items():
                scores[name] = model["quality"] - model["cost"] * 10
            return max(scores, key=scores.get)
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Gateways provide unified entry points
- Routers enable intelligent model selection
- Caches reduce costs and latency
- Load balancers distribute traffic
- Fallback ensures availability

---

### Module 23: Deployment

#### Key Concepts

```
⭐ Containerization ensures consistency
⭐ Orchestration handles scaling
⭐ Serverless is cost-effective for sporadic workloads
⭐ CI/CD enables fast, reliable deployment
⭐ Health checks monitor service health
```

#### Deployment Options

| Option | Best For |
|--------|----------|
| Docker | Development, testing |
| Kubernetes | Production, large-scale |
| Serverless | Sporadic workloads |
| GPU Instances | Model training |

#### Code Snippets

🔥 **Dockerfile**

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

🔥 **Kubernetes Deployment**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ai-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ai-service
  template:
    metadata:
      labels:
        app: ai-service
    spec:
      containers:
      - name: ai-service
        image: ai-service:latest
        ports:
        - containerPort: 8000
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Containerization ensures consistency
- Orchestration handles scaling
- Serverless is cost-effective for sporadic workloads
- CI/CD enables fast, reliable deployment
- Health checks monitor service health

---

### Module 24: AI Evaluation & Continuous Improvement

#### Key Concepts

```
⭐ Benchmarking measures absolute performance
⭐ A/B testing compares alternatives
⭐ LLM-as-a-Judge provides automated quality scoring
⭐ Feedback loops enable continuous improvement
⭐ Regression testing prevents regressions
```

#### Evaluation Methods

| Method | What It Measures |
|--------|------------------|
| Benchmarking | Absolute performance |
| A/B Testing | Relative performance |
| LLM-as-a-Judge | Quality at scale |
| Feedback Loops | Real-world impact |
| Regression Testing | Stability |

#### Code Snippets

🔥 **LLM-as-a-Judge**

```python
def evaluate_with_llm(query, response, criteria):
    prompt = f"""
    Evaluate the following response based on the criteria:
    
    Query: {query}
    Response: {response}
    
    Criteria: {criteria}
    
    Score from 1-10 with reasoning:
    """
    
    result = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}]
    )
    
    return result.choices[0].message.content
```

🔥 **A/B Testing**

```python
class ABTest:
    def __init__(self, variants):
        self.variants = variants
        self.impressions = {v: 0 for v in variants}
        self.conversions = {v: 0 for v in variants}
    
    def assign(self, user_id):
        # Weighted random assignment
        variant = random.choice(self.variants)
        self.impressions[variant] += 1
        return variant
    
    def record_conversion(self, variant):
        self.conversions[variant] += 1
    
    def get_results(self):
        return {
            v: {
                "impressions": self.impressions[v],
                "conversions": self.conversions[v],
                "conversion_rate": self.conversions[v] / self.impressions[v] if self.impressions[v] > 0 else 0
            }
            for v in self.variants
        }
```

#### My Notes

📝 **Personal Takeaways:**

```
____________________________________________________________________________
____________________________________________________________________________
____________________________________________________________________________
```

❓ **Questions to Investigate:**

```
____________________________________________________________________________
____________________________________________________________________________
```

#### Key Takeaways

- Benchmarking measures absolute performance
- A/B testing compares alternatives
- LLM-as-a-Judge provides automated quality scoring
- Feedback loops enable continuous improvement
- Regression testing prevents regressions

---

## Appendix: Quick Reference

### Important Commands

```bash
# Python environment
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Docker
docker build -t ai-service .
docker run -p 8000:8000 ai-service

# Kubernetes
kubectl apply -f deployment.yaml
kubectl get pods
kubectl logs -f pod-name
kubectl rollout undo deployment/ai-service
```

### Common Python Packages

| Package | Purpose | Installation |
|---------|---------|--------------|
| openai | OpenAI API | `pip install openai` |
| anthropic | Anthropic API | `pip install anthropic` |
| chromadb | Vector database | `pip install chromadb` |
| tiktoken | Token counting | `pip install tiktoken` |
| numpy | Numerical operations | `pip install numpy` |
| fastapi | Web API | `pip install fastapi uvicorn` |
| python-dotenv | Environment | `pip install python-dotenv` |

### API Key Management

| Provider | Key Name | Status |
|----------|----------|--------|
| OpenAI | OPENAI_API_KEY | |
| Anthropic | ANTHROPIC_API_KEY | |
| Google | GOOGLE_API_KEY | |

### Emergency Contact

```
Course: AI Tutorial Series: Developer Edition
Instructor: _________________________
Contact: _________________________
```

---

**End of Student Notes**

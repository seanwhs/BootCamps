# Primer 25: Generative AI and Large Language Models (LLMs)

## Overview

This primer provides a comprehensive introduction to Generative AI and Large Language Models (LLMs)—the technology behind ChatGPT, Claude, and other AI systems that can generate human-like text, images, and more. Understanding these concepts is essential for leveraging the latest advances in AI.

---

## 1. Introduction to Generative AI

### What is Generative AI?

```
┌─────────────────────────────────────────────────────────────────┐
│              WHAT IS GENERATIVE AI?                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Generative AI creates new content (text, images, audio, etc.) │
│  instead of just analyzing or classifying existing data.       │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Traditional AI: Predict or Classify                   │  │
│  │  Input → Model → Output (label, category, value)        │  │
│  │  Example: Is this email spam? → Yes/No                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Generative AI: Create New Content                     │  │
│  │  Input → Model → Output (new text, image, audio)        │  │
│  │  Example: Write a poem about AI → "Roses are red..."   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Types of Generative AI

```
┌─────────────────────────────────────────────────────────────────┐
│              TYPES OF GENERATIVE AI                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Large Language Models (LLMs)                                  │
│  └── Generate text, code, translations                        │
│  └── Examples: GPT-4, Claude, LLaMA                           │
│                                                                 │
│  Image Generation                                              │
│  └── Generate images from text descriptions                   │
│  └── Examples: DALL-E, Stable Diffusion, Midjourney           │
│                                                                 │
│  Audio Generation                                              │
│  └── Generate music, speech, sound effects                    │
│  └── Examples: AudioLM, MusicGen, Whisper                     │
│                                                                 │
│  Video Generation                                              │
│  └── Generate videos from text or images                      │
│  └── Examples: Sora, Make-A-Video                             │
│                                                                 │
│  Multi-modal Generation                                        │
│  └── Generate across multiple modalities                      │
│  └── Examples: GPT-4V, Gemini, CLIP                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Large Language Models (LLMs)

### How LLMs Work

```
┌─────────────────────────────────────────────────────────────────┐
│              HOW LLMS WORK                                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Training                                                    │
│     └── Learn from massive text dataset                        │
│     └── Predict next token in sequence                        │
│     └── Learn patterns, grammar, reasoning                    │
│                                                                 │
│  2. Architecture (Transformer)                                 │
│     └── Self-attention: Understand relationships between words│
│     └── Positional encoding: Understand word order            │
│     └── Multi-head attention: Multiple perspectives           │
│                                                                 │
│  3. Inference                                                   │
│     └── Input text → Tokenize → Generate output token by token│
│     └── Temperature controls randomness                       │
│     └── Top-p sampling selects from top probability mass      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### LLM Architecture (Simplified)

```python
class SimplifiedTransformer:
    """
    Simplified transformer architecture for education.
    """
    
    def __init__(self, vocab_size, d_model=512, n_heads=8, n_layers=6):
        self.vocab_size = vocab_size
        self.d_model = d_model
        self.n_heads = n_heads
        self.n_layers = n_layers
        
        # Embedding layer
        self.token_embedding = nn.Embedding(vocab_size, d_model)
        self.position_encoding = self._create_position_encoding()
        
        # Transformer layers
        self.layers = nn.ModuleList([
            TransformerLayer(d_model, n_heads)
            for _ in range(n_layers)
        ])
        
        # Output layer
        self.output_layer = nn.Linear(d_model, vocab_size)
    
    def _create_position_encoding(self, max_len=512):
        """Create sinusoidal position encoding."""
        pe = torch.zeros(max_len, self.d_model)
        position = torch.arange(0, max_len, dtype=torch.float).unsqueeze(1)
        div_term = torch.exp(
            torch.arange(0, self.d_model, 2).float() *
            (-np.log(10000.0) / self.d_model)
        )
        pe[:, 0::2] = torch.sin(position * div_term)
        pe[:, 1::2] = torch.cos(position * div_term)
        return pe
    
    def forward(self, x):
        # Embed tokens
        x = self.token_embedding(x)
        
        # Add position encoding
        seq_len = x.size(1)
        x = x + self.position_encoding[:seq_len, :]
        
        # Pass through transformer layers
        for layer in self.layers:
            x = layer(x)
        
        # Output
        return self.output_layer(x)

class TransformerLayer(nn.Module):
    """Single transformer layer with self-attention and feedforward."""
    
    def __init__(self, d_model, n_heads, d_ff=2048, dropout=0.1):
        super().__init__()
        self.self_attention = nn.MultiheadAttention(d_model, n_heads, dropout=dropout)
        self.feed_forward = nn.Sequential(
            nn.Linear(d_model, d_ff),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_ff, d_model)
        )
        self.layer_norm1 = nn.LayerNorm(d_model)
        self.layer_norm2 = nn.LayerNorm(d_model)
        self.dropout = nn.Dropout(dropout)
    
    def forward(self, x):
        # Self-attention with residual
        attn_output, _ = self.self_attention(x, x, x)
        x = self.layer_norm1(x + self.dropout(attn_output))
        
        # Feed-forward with residual
        ff_output = self.feed_forward(x)
        x = self.layer_norm2(x + self.dropout(ff_output))
        
        return x
```

---

## 3. Using LLMs via API

### Working with OpenAI API

```python
import openai
import os
from typing import List, Dict, Optional

class LLMClient:
    """
    Client for interacting with LLM APIs.
    """
    
    def __init__(self, provider='openai', model='gpt-4', api_key=None):
        self.provider = provider
        self.model = model
        self.api_key = api_key or os.getenv('OPENAI_API_KEY')
        self.client = openai.OpenAI(api_key=self.api_key)
    
    def chat(
        self,
        messages: List[Dict[str, str]],
        temperature: float = 0.7,
        max_tokens: int = 1000,
        stream: bool = False
    ) -> str:
        """
        Send a chat request to the LLM.
        
        Args:
            messages: List of message dicts with 'role' and 'content'
            temperature: Randomness (0-1)
            max_tokens: Maximum tokens to generate
            stream: Whether to stream the response
        
        Returns:
            str: Generated response
        """
        response = self.client.chat.completions.create(
            model=self.model,
            messages=messages,
            temperature=temperature,
            max_tokens=max_tokens,
            stream=stream
        )
        
        if stream:
            return self._handle_stream(response)
        
        return response.choices[0].message.content
    
    def _handle_stream(self, stream_response):
        """Handle streaming response."""
        full_text = ""
        for chunk in stream_response:
            if chunk.choices[0].delta.content:
                content = chunk.choices[0].delta.content
                print(content, end='')
                full_text += content
        return full_text
    
    def generate_completion(
        self,
        prompt: str,
        temperature: float = 0.7,
        max_tokens: int = 1000
    ) -> str:
        """
        Generate a completion for a prompt.
        
        Args:
            prompt: Input prompt
            temperature: Randomness (0-1)
            max_tokens: Maximum tokens to generate
        
        Returns:
            str: Generated text
        """
        return self.chat([
            {'role': 'user', 'content': prompt}
        ], temperature, max_tokens)
    
    def generate_structured_output(
        self,
        prompt: str,
        schema: Dict,
        temperature: float = 0.3
    ) -> Dict:
        """
        Generate structured output following a schema.
        
        Args:
            prompt: Input prompt
            schema: JSON schema for output
            temperature: Randomness (0-1)
        
        Returns:
            dict: Structured output
        """
        # This uses function calling or JSON mode
        messages = [
            {'role': 'system', 'content': f"""
                Output must be a valid JSON object matching this schema:
                {schema}
            """},
            {'role': 'user', 'content': prompt}
        ]
        
        response = self.client.chat.completions.create(
            model=self.model,
            messages=messages,
            temperature=temperature,
            response_format={'type': 'json_object'}
        )
        
        import json
        return json.loads(response.choices[0].message.content)

# Example usage
llm = LLMClient(model='gpt-3.5-turbo')

# Simple chat
response = llm.chat([
    {'role': 'system', 'content': 'You are a helpful assistant.'},
    {'role': 'user', 'content': 'What is machine learning?'}
])
print(response)

# Structured output
schema = {
    'type': 'object',
    'properties': {
        'summary': {'type': 'string'},
        'sentiment': {'type': 'string', 'enum': ['positive', 'negative', 'neutral']},
        'key_points': {'type': 'array', 'items': {'type': 'string'}}
    }
}

structured = llm.generate_structured_output(
    "Analyze this customer review: 'The product is amazing! Great value for money.'",
    schema
)
print(structured)
```

### Working with Hugging Face

```python
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch

class HuggingFaceLLM:
    """
    Client for running open-source LLMs locally.
    """
    
    def __init__(self, model_name='gpt2'):
        self.model_name = model_name
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModelForCausalLM.from_pretrained(model_name).to(self.device)
        
        # Add padding token if not present
        if self.tokenizer.pad_token is None:
            self.tokenizer.pad_token = self.tokenizer.eos_token
    
    def generate(
        self,
        prompt: str,
        max_length: int = 100,
        temperature: float = 0.7,
        top_p: float = 0.9,
        do_sample: bool = True
    ) -> str:
        """
        Generate text from a prompt.
        
        Args:
            prompt: Input prompt
            max_length: Maximum length of generated text
            temperature: Randomness
            top_p: Nucleus sampling parameter
            do_sample: Whether to sample or use greedy decoding
        
        Returns:
            str: Generated text
        """
        # Tokenize
        inputs = self.tokenizer.encode(prompt, return_tensors='pt').to(self.device)
        
        # Generate
        with torch.no_grad():
            outputs = self.model.generate(
                inputs,
                max_length=max_length,
                temperature=temperature,
                top_p=top_p,
                do_sample=do_sample,
                pad_token_id=self.tokenizer.eos_token_id
            )
        
        # Decode
        generated_text = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
        
        return generated_text
    
    def chat(
        self,
        messages: List[Dict[str, str]],
        max_length: int = 200,
        temperature: float = 0.7
    ) -> str:
        """
        Simple chat interface.
        
        Args:
            messages: List of message dicts
            max_length: Maximum length of response
            temperature: Randomness
        
        Returns:
            str: Generated response
        """
        # Format messages for prompt
        prompt = "\n".join([
            f"{msg['role']}: {msg['content']}"
            for msg in messages
        ])
        prompt += "\nassistant: "
        
        return self.generate(prompt, max_length, temperature)

# Example with Llama (simplified)
# llm = HuggingFaceLLM('meta-llama/Llama-2-7b-chat-hf')
```

---

## 4. Prompt Engineering

### Prompting Techniques

```python
class PromptEngineer:
    """
    Prompt engineering utilities for LLMs.
    """
    
    @staticmethod
    def zero_shot(prompt: str) -> str:
        """
        Zero-shot prompting: No examples provided.
        """
        return prompt
    
    @staticmethod
    def few_shot(prompt: str, examples: List[tuple]) -> str:
        """
        Few-shot prompting: Provide examples.
        
        Args:
            prompt: Target prompt
            examples: List of (input, output) examples
        
        Returns:
            str: Prompt with examples
        """
        few_shot_prompt = ""
        
        for i, (example_input, example_output) in enumerate(examples):
            few_shot_prompt += f"Example {i+1}:\n"
            few_shot_prompt += f"Input: {example_input}\n"
            few_shot_prompt += f"Output: {example_output}\n\n"
        
        few_shot_prompt += f"Now answer:\n{prompt}"
        
        return few_shot_prompt
    
    @staticmethod
    def chain_of_thought(prompt: str, reasoning_steps: List[str]) -> str:
        """
        Chain-of-thought prompting: Show reasoning steps.
        
        Args:
            prompt: Target prompt
            reasoning_steps: List of reasoning steps
        
        Returns:
            str: Prompt with reasoning
        """
        cot_prompt = f"{prompt}\n\nLet's think step by step:\n"
        
        for i, step in enumerate(reasoning_steps):
            cot_prompt += f"{i+1}. {step}\n"
        
        cot_prompt += f"\n{len(reasoning_steps) + 1}. Therefore, the answer is:"
        
        return cot_prompt
    
    @staticmethod
    def self_consistency(prompt: str, n_samples: int = 3) -> str:
        """
        Self-consistency: Generate multiple reasoning paths.
        
        Args:
            prompt: Target prompt
            n_samples: Number of reasoning paths
        
        Returns:
            str: Multiple reasoning prompts
        """
        prompts = []
        for i in range(n_samples):
            sc_prompt = f"{prompt}\n\nReasoning {i+1}: Let's think step by step..."
            prompts.append(sc_prompt)
        
        return prompts
    
    @staticmethod
    def role_prompt(role: str, task: str) -> str:
        """
        Role prompting: Assign a role to the LLM.
        
        Args:
            role: Role description
            task: Task description
        
        Returns:
            str: Role prompt
        """
        return f"You are a {role}. {task}"
    
    @staticmethod
    def context_prompt(context: str, question: str) -> str:
        """
        Context-based prompting: Provide context for question answering.
        
        Args:
            context: Background information
            question: Question to answer
        
        Returns:
            str: Context prompt
        """
        return f"Context: {context}\n\nQuestion: {question}\n\nAnswer:"

# Example usage
engineer = PromptEngineer()

# Few-shot prompting
examples = [
    ("I love this product!", "positive"),
    ("This is terrible.", "negative"),
    ("It's okay, nothing special.", "neutral")
]

prompt = engineer.few_shot(
    "The customer service was excellent!",
    examples
)

# Chain-of-thought
cot_prompt = engineer.chain_of_thought(
    "If a train travels at 60 mph for 3 hours, how far does it travel?",
    ["The train travels at 60 miles per hour", 
     "It travels for 3 hours",
     "Distance = speed × time"]
)

# Role prompting
role_prompt = engineer.role_prompt(
    "senior data scientist with 10 years of experience",
    "Explain the concept of overfitting in simple terms."
)
```

---

## 5. Retrieval-Augmented Generation (RAG)

### RAG Implementation

```python
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import FAISS
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.chains import RetrievalQA
from langchain.chat_models import ChatOpenAI

class RAGSystem:
    """
    Retrieval-Augmented Generation system.
    """
    
    def __init__(self, llm=None, embedding_model=None):
        self.llm = llm or ChatOpenAI(model='gpt-3.5-turbo')
        self.embeddings = embedding_model or OpenAIEmbeddings()
        self.vectorstore = None
        self.qa_chain = None
    
    def index_documents(self, documents: List[str], chunk_size=500):
        """
        Index documents for retrieval.
        
        Args:
            documents: List of documents to index
            chunk_size: Size of text chunks
        """
        # Split documents into chunks
        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=chunk_size,
            chunk_overlap=50
        )
        chunks = text_splitter.create_documents(documents)
        
        # Create vector store
        self.vectorstore = FAISS.from_documents(chunks, self.embeddings)
        
        # Create QA chain
        self.qa_chain = RetrievalQA.from_chain_type(
            llm=self.llm,
            chain_type="stuff",
            retriever=self.vectorstore.as_retriever(search_kwargs={"k": 3})
        )
        
        print(f"Indexed {len(chunks)} chunks from {len(documents)} documents")
    
    def query(self, question: str) -> str:
        """
        Query the RAG system.
        
        Args:
            question: User question
        
        Returns:
            str: Generated answer
        """
        if self.qa_chain is None:
            return "No documents indexed. Call index_documents first."
        
        return self.qa_chain.run(question)
    
    def add_documents(self, documents: List[str]):
        """
        Add documents to existing index.
        
        Args:
            documents: List of documents to add
        """
        if self.vectorstore is None:
            self.index_documents(documents)
            return
        
        # Split documents into chunks
        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=500,
            chunk_overlap=50
        )
        chunks = text_splitter.create_documents(documents)
        
        # Add to existing vectorstore
        self.vectorstore.add_documents(chunks)
        
        print(f"Added {len(chunks)} chunks from {len(documents)} documents")
```

### Simple RAG Pipeline

```python
class SimpleRAG:
    """
    Simple RAG implementation.
    """
    
    def __init__(self, llm_client):
        self.llm_client = llm_client
        self.documents = []
        self.embeddings = []
    
    def add_documents(self, documents):
        """Add documents to the knowledge base."""
        self.documents.extend(documents)
        # In practice, you'd compute and store embeddings here
    
    def retrieve(self, query, k=3):
        """
        Retrieve relevant documents.
        
        Args:
            query: User query
            k: Number of documents to retrieve
        
        Returns:
            list: Retrieved documents
        """
        # In practice, you'd compute query embedding and compare
        # with document embeddings
        return self.documents[:k]
    
    def generate(self, query):
        """
        Generate answer using RAG.
        
        Args:
            query: User query
        
        Returns:
            str: Generated answer
        """
        # Retrieve relevant documents
        docs = self.retrieve(query)
        
        # Construct prompt with context
        context = "\n\n".join(docs)
        prompt = f"""Use the following context to answer the question.
        
Context:
{context}

Question: {query}

Answer:"""
        
        # Generate answer
        return self.llm_client.generate_completion(prompt)

# Example usage
rag = SimpleRAG(llm_client=llm_client)

# Add documents
rag.add_documents([
    "Machine learning is a subset of AI that enables systems to learn from data.",
    "Deep learning uses neural networks with multiple layers.",
    "LLMs are trained on massive text datasets to predict the next token."
])

# Query
answer = rag.generate("What is machine learning?")
print(answer)
```

---

## Quick Reference: LLMs and Generative AI

### Model Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│  MODEL       │ PARAMETERS │ CONTEXT  │ BEST FOR               │
├──────────────┼────────────┼──────────┼────────────────────────┤
│  GPT-4       │ ~1.7T      │ 128K     │ Complex reasoning      │
│  GPT-3.5     │ ~175B      │ 16K      │ General purpose        │
│  Claude 3    │ Unknown    │ 200K     │ Long context           │
│  Gemini      │ Unknown    │ 1M       │ Multi-modal            │
│  LLaMA 2     │ 7-70B      │ 4K       │ Open-source            │
│  Mistral     │ 7B         │ 32K      │ Efficiency             │
└─────────────────────────────────────────────────────────────────┘
```

### Prompt Engineering Techniques

```
┌─────────────────────────────────────────────────────────────────┐
│  TECHNIQUE               │ USE CASE                           │
├──────────────────────────┼────────────────────────────────────┤
│  Zero-shot               │ Simple tasks, no examples          │
│  Few-shot                │ New tasks, pattern learning        │
│  Chain-of-Thought        │ Complex reasoning                 │
│  Self-Consistency        │ Robust reasoning                  │
│  Role Prompting          │ Expert knowledge needed           │
│  Context Prompting       │ Question answering                │
│  System Prompt           │ Setting behavior and constraints  │
│  Few-shot with CoT       │ Complex tasks with examples       │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers the essential concepts of Generative AI and Large Language Models. You now understand:

1. **Generative AI**: Creating new content
2. **LLMs**: How they work and architectures
3. **Using LLMs**: API and local implementations
4. **Prompt engineering**: Techniques for better outputs
5. **RAG**: Retrieval-augmented generation

**Next Steps:**
1. Practice prompting with different techniques
2. Build a simple RAG system
3. Explore open-source LLMs
4. Create structured output with LLMs
5. Proceed to Part 1 of the series

---

*End of Primer 25*

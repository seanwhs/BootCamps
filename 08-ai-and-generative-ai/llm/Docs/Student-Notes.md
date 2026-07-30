# Student Notes: Beneath the Surface — Demystifying LLMs, Transformers, and Distillation

## Comprehensive Lecture Notes for the Complete Series

---

# HOW TO USE THESE NOTES

These notes are designed to be your companion throughout the series. Each section corresponds to a module and contains:

- **📝 Key Concepts** - The most important ideas to remember
- **🔑 Key Takeaways** - Bullet points summarizing each section
- **📊 Diagrams** - Visual representations of concepts (described textually)
- **💡 Important Insights** - Critical understanding points
- **🔗 Connections** - How concepts link together
- **⚠️ Common Pitfalls** - Mistakes to avoid
- **❓ Questions to Ask** - Prompts for deeper thinking

**Pro Tip:** Use these notes alongside the workbook. Take additional notes in the margins or in a separate notebook.

---

# MODULE 0: INTRODUCTION

## Section 0.1: The AI Landscape

### Key Concepts

**The Pace of Change:**
- 2017: Transformer introduced
- 2018: BERT, GPT-1
- 2019: GPT-2
- 2020: GPT-3 (175B parameters)
- 2022: ChatGPT
- 2023: GPT-4, Claude, Llama
- 2024: Open-source models rival closed ones

**The Problem:**
- Most developers only use APIs (surface-level)
- Don't understand what's happening under the hood
- Can't make informed decisions about AI

### Key Takeaways

1. The AI field moves at breakneck speed
2. Understanding fundamentals is your competitive advantage
3. Most developers are API wrapper users, not AI builders

### Important Insights

> "LLMs are prediction engines, not brains. Understanding this demystifies everything."

> "JavaScript is where AI meets the world - web apps, serverless, edge computing."

---

## Section 0.2: The Mental Model

### The Core Insight

**LLMs are statistical pattern predictors.**

```
INPUT: "The cat sat on the"
         ↓
Tokenize → ["The", "cat", "sat", "on", "the"]
         ↓
Embed → Process → Predict
         ↓
OUTPUT: "mat" (35% probability)
```

### Three Key Layers

1. **Data Layer**: How text becomes numbers
   - Tokenization → IDs → Embeddings

2. **Architecture Layer**: How numbers are processed
   - Attention → Transformers → Generation

3. **Optimization Layer**: How models are compressed
   - Distillation → Quantization → Deployment

### Key Takeaways

1. Everything in LLMs is about predicting the next token
2. There are three layers of understanding: data, architecture, optimization
3. JavaScript developers can (and should) understand AI internals

---

## Section 0.3: What You'll Build

### Ultimate Architecture

```
Raw Text → Tokenization → Embeddings → Vectors
                                    ↓
                      Self-Attention → Multi-Head → Generation
                                    ↓
                      Teacher Model → Student Model (Distillation)
                                    ↓
                      Express API → Model Serving → Production
```

### Key Takeaways

1. Everything connects together
2. Build piece by piece
3. Each module builds on the previous one

### Questions to Ask

- What happens when you send a prompt to ChatGPT?
- Why do different models produce different outputs?
- How does a model "learn" from training data?

---

# MODULE 1: ANATOMY OF AN LLM

## Section 1.1: Why Text → Numbers?

### Key Concepts

**The Problem:**
- Computers don't understand words
- Need numerical representations
- ASCII isn't good enough (no semantic meaning)

**The Solution:**
- Learn meaningful numerical representations (embeddings)
- Similar words have similar vectors
- Relationships are captured in vector space

### Key Takeaways

1. Text must be converted to numbers for neural networks
2. Embeddings capture semantic meaning
3. Similar words cluster together in embedding space

### Important Insights

> "Embeddings are the bridge between human language and machine computation."

> "Word2Vec showed that 'king - man + woman ≈ queen' - relationships are encoded in vector arithmetic."

---

## Section 1.2: Tokenization

### Three Approaches

| Approach | Pros | Cons |
|----------|------|------|
| Character-level | No unknown tokens | Too many tokens, no meaning |
| Word-level | Fewer tokens, semantic meaning | Unknown words break |
| Subword (BPE) | Best balance | More complex |

### BPE Algorithm

1. Start with character-level tokens
2. Count frequencies of adjacent pairs
3. Merge the most frequent pair
4. Repeat until target vocabulary size

**Example:**
```
"lower lower low low"
→ "lo" (merge) → "low" (merge) → "lowe" (merge) → "lower"
```

### Special Tokens

| Token | Purpose |
|-------|---------|
| [BOS] | Beginning of sequence |
| [EOS] | End of sequence |
| [PAD] | Padding for batching |
| [UNK] | Unknown token |
| [SEP] | Separator |
| [MASK] | Masked language modeling |

### Key Takeaways

1. BPE balances vocabulary size and coverage
2. Special tokens control model behavior
3. Tokenization is the first step in the pipeline

### Common Pitfalls

- Not handling unknown tokens
- Forgetting special tokens
- Too small or too large vocabulary

---

## Section 1.3: Embeddings

### The Embedding Matrix

```
Vocabulary × Embedding Dimension
[tokens × dims] = [1000 × 64]
```

### Properties of Embeddings

1. **Semantic neighborhoods**: Similar words cluster
2. **Vector arithmetic**: king - man + woman ≈ queen
3. **Dimensionality**: Higher = more nuance, more compute

### Cosine Similarity

```
cos(θ) = (A · B) / (||A|| · ||B||)
```

- 1 = identical direction (very similar)
- 0 = orthogonal (unrelated)
- -1 = opposite direction

### Key Takeaways

1. Embeddings map tokens to high-dimensional vectors
2. Cosine similarity measures semantic similarity
3. Embedding space reveals semantic relationships

### Important Insights

> "The embedding space is like a map of concepts. Similar concepts are near each other."

> "Higher dimensions capture more nuance but require more compute."

---

## Section 1.4: Pre-training vs Alignment

### Two Phases

**Phase 1: Pre-training**
- Objective: Next token prediction
- Data: Massive corpora (trillions of tokens)
- Result: Base model that predicts text patterns

**Phase 2: Alignment**
- Objective: Follow instructions, be helpful
- Data: Instruction-answer pairs, human feedback
- Methods: Instruction tuning, RLHF
- Result: ChatGPT-style assistant

### Key Takeaways

1. Pre-training learns language patterns
2. Alignment learns behavior and helpfulness
3. Both are necessary for modern LLMs

### Questions to Ask

- Why do we need both pre-training and alignment?
- What happens if you skip alignment?
- How does RLHF work?

---

# MODULE 2: THE TRANSFORMER REVOLUTION

## Section 2.1: The Context Problem

### RNN Limitations

1. **Sequential processing**: Can't parallelize
2. **Vanishing gradients**: Can't learn long-range dependencies
3. **Limited context**: ~100 tokens max

### The Transformer Solution

1. **Parallel processing**: All tokens simultaneously
2. **Global context**: Any token connects to any other
3. **Long-range dependencies**: No information loss over distance

### Key Takeaways

1. RNNs struggled with long sequences
2. Transformers enable parallel, global reasoning
3. Attention solved the long-range dependency problem

### Important Insights

> "RNNs are like reading a book with a small notepad. Transformers are like having the whole book open."

---

## Section 2.2: Self-Attention

### The Components

- **Q (Query)**: "What am I looking for?"
- **K (Key)**: "What information is available?"
- **V (Value)**: "What is the actual content?"

### The Formula

```
Attention(Q,K,V) = softmax(Q × K^T / √d_k) × V
```

### The Process

1. Compute scores: Q × K^T
2. Scale: ÷ √d_k (stabilizes gradients)
3. Softmax: converts to probabilities
4. Multiply: weights × V

### Key Takeaways

1. Attention computes relevance between tokens
2. Scaling prevents vanishing gradients
3. Softmax converts scores to weights

### Common Pitfalls

- Forgetting to scale (causes vanishing gradients)
- Not handling very long sequences (memory issues)

---

## Section 2.3: Multi-Head Attention

### Why Multiple Heads?

- Each head learns different patterns
- Head 1: Syntax (subject-verb)
- Head 2: Semantics (word meaning)
- Head 3: Long-range dependencies
- Head 4: Positional relationships

### The Formula

```
MultiHead(Q,K,V) = Concat(head_1, ..., head_h) × W_O
where head_i = Attention(Q × W_Q_i, K × W_K_i, V × W_V_i)
```

### Key Takeaways

1. Multiple heads capture different relationship types
2. Heads are independent and parallel
3. Concatenation combines the insights

### Important Insights

> "Each attention head is like a different expert analyzing the data."

---

## Section 2.4: Positional Encodings

### The Problem

Attention is order-agnostic: "cat sat the" = "sat cat the"

### The Solution

Add position information to token embeddings.

### Sinusoidal Encodings

```
PE(pos, 2i) = sin(pos / 10000^(2i/d_model))
PE(pos, 2i+1) = cos(pos / 10000^(2i/d_model))
```

### Properties

1. **Deterministic**: Same position = same encoding
2. **Continuous**: Small position change = small encoding change
3. **No parameters**: Doesn't need training

### Key Takeaways

1. Positional encodings preserve order information
2. Sinusoidal encodings are deterministic and parameter-free
3. Alternative: Learned positional embeddings

---

## Section 2.5: Complete Transformer Block

### Architecture

```
Input → Multi-Head Attention → Add & Normalize
      → Feed-Forward → Add & Normalize
      → Output
```

### Components

1. **Multi-Head Attention**: Captures relationships
2. **Feed-Forward**: Learns patterns
3. **Add & Normalize**: Residual connections + layer norm

### Key Takeaways

1. Transformer blocks stack to form deep networks
2. Residual connections prevent vanishing gradients
3. Layer norm stabilizes training

---

## Section 2.6: Generation

### Autoregressive Generation

```
Step 1: ["The"] → Predict "quick"
Step 2: ["The", "quick"] → Predict "brown"
Step 3: ["The", "quick", "brown"] → Predict "fox"
... continue until EOS
```

### Sampling Strategies

| Strategy | Description | Use Case |
|----------|-------------|----------|
| Greedy | Always pick most likely | Factual tasks |
| Temperature | Scale logits | Control creativity |
| Top-K | Keep K most likely | Balance quality/diversity |
| Top-P | Keep cumulative P | Dynamic, adaptive |

### Key Takeaways

1. Generation is token-by-token
2. Sampling strategies control output quality
3. Temperature affects randomness

---

# MODULE 3: KNOWLEDGE DISTILLATION

## Section 3.1: The Compression Problem

### Why Compress?

| Metric | Large Model | Small Model |
|--------|-------------|-------------|
| Parameters | 175B | 7B |
| Memory | 700GB | 28GB |
| Speed | Slow | Fast |
| Cost | High | Low |

### Key Takeaways

1. Large models are expensive and slow
2. Small models are fast but less capable
3. Distillation bridges the gap

### Important Insights

> "You don't always need the biggest model. Sometimes a smaller, distilled model is perfect for the job."

---

## Section 3.2: Teacher-Student Paradigm

### The Setup

**Teacher:**
- Large, pre-trained
- High quality
- Slow, expensive

**Student:**
- Smaller architecture
- Learning from teacher
- Fast, cheap

### The Process

1. Teacher processes input → soft targets
2. Student processes same input → predictions
3. Student learns to match teacher's soft targets
4. Combined with supervised learning

### Key Takeaways

1. Teacher provides soft targets
2. Student learns to mimic teacher
3. Combined loss balances distillation and supervision

---

## Section 3.3: Soft Targets and Dark Knowledge

### Hard vs Soft Targets

**Hard Labels (One-Hot):**
```
Dog: [1, 0, 0, 0, 0]  ← Only the correct class
Wolf: [0, 1, 0, 0, 0]  ← Information lost
```

**Soft Targets (Probabilities):**
```
Dog: [0.85, 0.08, 0.04, 0.02, 0.01]  ← Rich information!
Wolf: [0.08, 0.82, 0.06, 0.03, 0.01]  ← Similarity revealed
```

### Dark Knowledge

- Relationships between classes
- "Dogs are similar to wolves"
- "Dogs are less similar to cats"
- "Dogs are very different from cars"

### Key Takeaways

1. Soft targets carry rich information
2. Dark knowledge reveals class relationships
3. Student learns more than just the label

### Important Insights

> "Hard labels tell you what something is. Soft targets tell you what something is similar to."

---

## Section 3.4: Temperature Scaling

### The Formula

```
p_i = exp(z_i / T) / ∑ exp(z_j / T)
```

### Temperature Effects

| Temperature | Effect |
|-------------|--------|
| T → 0 | One-hot (deterministic) |
| T = 1 | Standard softmax |
| T → ∞ | Uniform (maximum uncertainty) |

### Why T > 1

- Softens the distribution
- Reveals dark knowledge
- Teacher's "intuition" becomes visible

### Key Takeaways

1. Temperature controls softness of targets
2. Higher temperature reveals more dark knowledge
3. T = 2-5 is typical for distillation

---

## Section 3.5: Distillation Loss

### Combined Loss

```
L = α × L_distillation + (1-α) × L_supervised

L_distillation = T² × D_KL(P_teacher_T || P_student_T)
L_supervised = CrossEntropy(y_true, P_student)
```

### Components

- **α**: Distillation weight (0.7-0.9)
- **T**: Temperature (2-5)
- **T²**: Scaling factor for gradients

### Key Takeaways

1. Combined loss balances two objectives
2. Distillation loss learns teacher's "intuition"
3. Supervised loss learns hard labels

---

## Section 3.6: Other Compression Methods

### Comparison

| Method | Compression | Quality Loss | Training Required |
|--------|-------------|--------------|-------------------|
| Distillation | 3-10x | 5-15% | Yes |
| Quantization (INT8) | 2-4x | 1-5% | No |
| Quantization (4-bit) | 4-8x | 3-10% | No/Yes |
| Pruning | 1.5-3x | 5-20% | Yes |

### Combined Pipeline

1. Train teacher (BF16)
2. Distill to student (BF16)
3. Quantize student (INT8/4-bit)

### Key Takeaways

1. Combine methods for maximum compression
2. Distillation then quantization is common
3. Each method has different trade-offs

---

# MODULE 4: PRODUCTION DEPLOYMENT

## Section 4.1: Production Architecture

### The Components

```
Client → Express API Server → Generation Engine → Model Runtime
```

### Server Responsibilities

1. **API**: Accept requests, return responses
2. **Middleware**: Logging, auth, rate limiting
3. **Generation**: Tokenization, sampling, decoding
4. **Model Runtime**: Actual inference

### Key Takeaways

1. Production systems are layered
2. Each layer has specific responsibilities
3. Monitoring and reliability are critical

### Important Insights

> "Production AI is about reliability, latency, and cost, not just accuracy."

---

## Section 4.2: KV Cache

### The Problem

Without KV cache:
- Step 1: Process all tokens
- Step 2: Process all tokens (recompute!)
- Step 3: Process all tokens (recompute again!)
- Complexity: O(n²)

### The Solution

With KV cache:
- Step 1: Process all tokens, store K,V
- Step 2: Only process new token, reuse K,V
- Step 3: Only process new token, reuse K,V
- Complexity: O(n)

### Speedup

Up to 10x for long sequences!

### What's Stored

- K (Key) matrices for each token
- V (Value) matrices for each token
- Avoids recomputing past tokens

### Key Takeaways

1. KV cache dramatically speeds up generation
2. Stores keys and values from previous tokens
3. O(n²) → O(n) complexity

### Common Pitfalls

- Cache growing too large (LRU eviction needed)
- Not invalidating cache when parameters change
- Cache misses causing slow generation

---

## Section 4.3: Generation Parameters

### The Parameters

| Parameter | Range | Description |
|-----------|-------|-------------|
| maxTokens | 1-2048 | Maximum tokens to generate |
| temperature | 0-2 | Randomness level |
| topK | 0-100 | Only keep K most likely |
| topP | 0-1 | Keep cumulative P |
| repetitionPenalty | 1-2 | Penalize repetition |

### Presets

| Preset | Temperature | topK | topP | Use Case |
|--------|-------------|------|------|----------|
| Creative | 1.2 | 60 | 0.95 | Stories, poems |
| Balanced | 0.8 | 40 | 0.90 | Most tasks |
| Factual | 0.3 | 10 | 0.80 | Q&A, facts |

### Key Takeaways

1. Parameters control output quality
2. Different tasks need different settings
3. Presets provide good starting points

---

## Section 4.4: Express API Server

### Basic Setup

```javascript
const server = new ProductionServer({
    port: 3000,
    modelDir: './models/distillation_demo',
    maxTokens: 100,
    temperature: 0.8
});

await server.initialize();
server.start();
```

### Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| /health | GET | Status check |
| /api/generate | POST | Generate text |
| /api/generate/stream | POST | Stream generation |
| /api/models | GET | List models |
| /api/stats | GET | Server statistics |

### Key Takeaways

1. Express provides a clean API layer
2. Health checks enable monitoring
3. Streaming enables real-time generation

---

## Section 4.5: Middleware

### The Stack

1. **Security**: Helmet, CORS
2. **Rate Limiting**: Prevent abuse
3. **Logging**: Request tracking
4. **Performance Monitoring**: Response times
5. **Error Handling**: Structured errors

### Key Takeaways

1. Middleware handles cross-cutting concerns
2. Rate limiting protects your server
3. Monitoring enables observability

---

## Section 4.6: Monitoring and Scaling

### Key Metrics

**Performance:**
- Latency (p50, p90, p99)
- Tokens per second
- Queue depth

**Resource Usage:**
- CPU utilization
- Memory (weights + KV cache)
- Network I/O

**Quality:**
- Generation length
- Repetition rate
- Client satisfaction

### Scaling Considerations

| Scale | Users | Requests/Min | Infrastructure |
|-------|-------|--------------|----------------|
| Dev | 1-10 | 1-10 | Single instance, 2GB |
| Small | 10-100 | 10-100 | 2 instances, 8GB each |
| Medium | 100-1000 | 100-1000 | LB, 4-8 instances |
| Large | 1000+ | 1000+ | Auto-scaling, distributed cache |

### Key Takeaways

1. Monitor everything
2. Scale based on demand
3. Cache aggressively

### Deployment Checklist

**Security:**
- [ ] Environment variables for secrets
- [ ] CORS configured
- [ ] Rate limiting active
- [ ] Input validation

**Performance:**
- [ ] KV cache enabled
- [ ] Compression middleware
- [ ] Load testing completed

**Reliability:**
- [ ] Error handling
- [ ] Graceful shutdown
- [ ] Health checks
- [ ] Monitoring setup

---

# SUMMARY CHEAT SHEETS

## Cheat Sheet 1: Tokenization

```
┌─────────────────────────────────────────────────────────────┐
│  TOKENIZATION                                               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  BPE Algorithm:                                             │
│  1. Start with characters                                  │
│  2. Find most frequent pair                               │
│  3. Merge pair                                            │
│  4. Repeat until target vocab size                        │
│                                                              │
│  Special Tokens:                                            │
│  [BOS] [EOS] [PAD] [UNK] [SEP] [MASK]                    │
│                                                              │
│  Vocabulary:                                                │
│  Token ↔ ID mapping                                       │
│  Includes special tokens + subwords                       │
│                                                              │
│  Example:                                                  │
│  "playing" → ["play", "ing"]                              │
│  "chatgpt" → ["chat", "gpt"]                              │
└─────────────────────────────────────────────────────────────┘
```

## Cheat Sheet 2: Embeddings

```
┌─────────────────────────────────────────────────────────────┐
│  EMBEDDINGS                                                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Embedding Matrix:                                          │
│  [vocab_size × embedding_dim]                              │
│                                                              │
│  Cosine Similarity:                                         │
│  cos(θ) = (A·B) / (||A||·||B||)                           │
│  • 1 = identical                                          │
│  • 0 = unrelated                                          │
│  • -1 = opposite                                          │
│                                                              │
│  Properties:                                                │
│  • Similar words cluster                                   │
│  • Vector arithmetic works                                │
│  • Higher dims = more nuance                              │
│                                                              │
│  Example:                                                  │
│  king - man + woman ≈ queen                               │
└─────────────────────────────────────────────────────────────┘
```

## Cheat Sheet 3: Attention

```
┌─────────────────────────────────────────────────────────────┐
│  ATTENTION                                                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Formula:                                                   │
│  Attention(Q,K,V) = softmax(Q·K^T/√d_k)·V                │
│                                                              │
│  Components:                                                │
│  Q: Query ("What am I looking for?")                       │
│  K: Key ("What information is available?")                 │
│  V: Value ("What's the content?")                          │
│                                                              │
│  Multi-Head:                                                │
│  Multiple heads in parallel                               │
│  Each learns different patterns                           │
│  Concatenate and project                                  │
│                                                              │
│  Causal Mask:                                               │
│  Prevents looking at future tokens                        │
│  Enables autoregressive generation                        │
└─────────────────────────────────────────────────────────────┘
```

## Cheat Sheet 4: Distillation

```
┌─────────────────────────────────────────────────────────────┐
│  DISTILLATION                                               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Teacher-Student:                                           │
│  Teacher: Large, accurate, slow                           │
│  Student: Small, learning, fast                           │
│                                                              │
│  Soft Targets:                                              │
│  Probability distributions vs one-hot                    │
│  Carry "dark knowledge"                                   │
│                                                              │
│  Temperature:                                               │
│  T > 1: Softer distribution                               │
│  T < 1: Sharper distribution                              │
│  T = 2-5: Typical for distillation                        │
│                                                              │
│  Combined Loss:                                             │
│  L = α·D_KL(P_T||P_S) + (1-α)·CE(y_true, P_S)           │
│  • α: Distillation weight (0.7-0.9)                       │
│  • D_KL: KL divergence                                    │
│  • CE: Cross-entropy                                      │
└─────────────────────────────────────────────────────────────┘
```

## Cheat Sheet 5: Production

```
┌─────────────────────────────────────────────────────────────┐
│  PRODUCTION                                                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  KV Cache:                                                  │
│  Stores K and V from previous tokens                      │
│  O(n²) → O(n) speedup                                    │
│  LRU eviction when full                                   │
│                                                              │
│  Generation Parameters:                                     │
│  maxTokens: Maximum length                                │
│  temperature: Randomness (0-2)                           │
│  topK: Keep K most likely                                │
│  topP: Keep cumulative P                                 │
│  repetitionPenalty: Penalize repeats                     │
│                                                              │
│  API Endpoints:                                             │
│  GET /health                                              │
│  POST /api/generate                                       │
│  POST /api/generate/stream                               │
│  GET /api/models                                         │
│  GET /api/stats                                          │
│                                                              │
│  Monitoring:                                                │
│  • Latency (p50, p90, p99)                                │
│  • Tokens per second                                      │
│  • Memory usage                                           │
│  • Cache hit rate                                         │
│  • Queue depth                                            │
└─────────────────────────────────────────────────────────────┘
```

---

# GLOSSARY

## A

**Attention**: A mechanism that allows a model to focus on relevant parts of the input when making predictions.

**Autoregressive**: Generating output token by token, where each new token depends on all previous tokens.

## B

**BPE (Byte-Pair Encoding)**: A tokenization algorithm that merges the most frequent pairs of tokens to create subword units.

**Batch Size**: The number of examples processed together in a single training step.

## C

**Causal Mask**: A mask that prevents attention from looking at future tokens, used in decoder-only transformers.

**Conditional Probability**: The probability of an event given that another event has occurred.

**Cosine Similarity**: A measure of similarity between two vectors based on the angle between them.

**Cross-Attention**: Attention where queries come from one sequence (decoder) and keys/values come from another (encoder).

**Cross-Entropy**: A loss function that measures the difference between two probability distributions.

## D

**Dark Knowledge**: The rich information in soft targets that reveals relationships between classes.

**Decoder-Only**: A transformer architecture that only uses the decoder stack (e.g., GPT).

**Distillation**: Training a smaller model to mimic a larger model's behavior.

**Dropout**: A regularization technique that randomly drops neurons during training.

## E

**Embedding**: A dense vector representation of a token that captures semantic meaning.

**Encoder-Decoder**: A transformer architecture that uses both encoder and decoder stacks (e.g., original Transformer).

**Entropy**: A measure of uncertainty in a probability distribution.

**Epoch**: One complete pass through the training data.

## F

**Feed-Forward**: A neural network layer with two linear transformations and a non-linear activation.

**Fine-tuning**: Training a pre-trained model on a specific task with additional data.

## G

**Gradient**: The direction of steepest increase in the loss function.

**Gradient Descent**: An optimization algorithm that updates parameters in the direction of steepest descent.

**Greedy Sampling**: Always choosing the most likely next token.

## H

**Hard Labels**: One-hot labels that only indicate the correct class.

## K

**KL Divergence**: A measure of difference between two probability distributions.

**KV Cache**: Storing key and value matrices to avoid recomputation during generation.

## L

**Layer Norm**: Normalizing activations across the feature dimension.

**Learning Rate**: The step size in gradient descent.

**Loss Function**: A measure of how well the model is performing.

## M

**Masked Attention**: Attention that masks out certain positions (e.g., future tokens in causal attention).

**Matrix Multiplication**: The core operation in neural networks, transforming input vectors.

**Multi-Head Attention**: Multiple parallel attention heads that capture different relationship patterns.

## O

**One-Hot**: A vector with a 1 at the index of the correct class and 0s elsewhere.

## P

**Perplexity**: A measure of how "surprised" the model is by the data (lower = better).

**Positional Encoding**: Adding position information to token embeddings.

**Pre-training**: Training a model on a large corpus for next token prediction.

**Pruning**: Removing unimportant weights from a model.

## Q

**Quantization**: Reducing the precision of weights and activations (e.g., FP32 → INT8).

**Query (Q)**: In attention, the query asks "what am I looking for?"

## R

**ReLU**: Rectified Linear Unit activation function (max(0, x)).

**Residual Connection**: Adding the input to the output of a layer to prevent vanishing gradients.

**RNN**: Recurrent Neural Network, sequential processing.

## S

**Self-Attention**: Attention where Q, K, and V all come from the same sequence.

**Soft Targets**: Probability distributions from a teacher model.

**Softmax**: A function that converts logits to probabilities.

**Special Tokens**: Tokens that control model behavior (e.g., [BOS], [EOS]).

**Supervised Loss**: Loss computed using hard labels (cross-entropy).

## T

**Temperature**: A parameter that controls the softness of a distribution.

**Token**: A unit of text (character, word, or subword).

**Tokenizer**: A system that converts text to tokens.

**Transformer**: The architecture that uses attention to process sequences.

## V

**Vocabulary**: The set of all tokens the model knows.

## X

**Xavier Initialization**: A weight initialization technique that scales weights to maintain variance.

---

**[END OF STUDENT NOTES]**

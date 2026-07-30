# Appendix E: Math and Theory Reference — LLMs, Transformers, and Distillation

This appendix provides comprehensive mathematical foundations and theoretical explanations for the concepts used throughout the series. Use this as a reference when you need to understand the "why" behind the code.

---

## E.1 Tokenization Mathematics

### Byte-Pair Encoding (BPE) Algorithm

**Mathematical Formulation:**

Given a corpus C, BPE iteratively merges the most frequent pair of adjacent tokens:

```
Initialize: V = {all characters in C}
While |V| < target_vocab_size:
    For each pair (a,b) of adjacent tokens in V:
        count(a,b) = frequency of (a,b) in C
    (a*,b*) = argmax count(a,b)
    Add ab* to V
    Replace all occurrences of (a*,b*) with ab* in C
```

**Example Calculation:**

```
Corpus: "lower lower low low"
Step 1: Count pairs
  "lo": 4, "ow": 2, "we": 2, "er": 2, etc.
  Merge "lo" → "lo"

Step 2: Count pairs with new tokens
  "low": 3, "lo": 1, ...
  Merge "lo"+"w" → "low"

Step 3: Continue until vocabulary size reached
```

### Entropy and Information Theory

**Shannon Entropy:**

```
H(X) = -∑ P(x) * log₂(P(x))
```

Where H(X) is the entropy of random variable X, and P(x) is the probability of outcome x.

**Cross-Entropy:**

```
H(p,q) = -∑ p(x) * log(q(x))
```

Where p is the true distribution and q is the predicted distribution.

**Perplexity:**

```
PPL = 2^(-H(p,q))
```

Perplexity measures how "surprised" the model is by the data. Lower perplexity = better model.

---

## E.2 Embedding Mathematics

### Word Embeddings

**Embedding Matrix:**

An embedding matrix E ∈ ℝ^(V×d) maps token IDs to vectors:
- V = vocabulary size
- d = embedding dimension

```
E[i] = embedding of token i
```

**Cosine Similarity:**

```
cos(θ) = (A · B) / (||A|| * ||B||)
       = (∑ A_i * B_i) / (√(∑ A_i²) * √(∑ B_i²))
```

Where A and B are embedding vectors.

**Properties of Embedding Space:**

1. **Semantic neighborhoods**: Similar words cluster together
2. **Analogical relationships**: king - man + woman ≈ queen
3. **Vector arithmetic**: Embeddings support addition/subtraction

### GloVe / Word2Vec Objective

**Skip-gram Objective:**

```
J(θ) = (1/T) * ∑_{t=1}^T ∑_{-m≤j≤m, j≠0} log P(w_{t+j}|w_t)
```

Where w_t is the target word, w_{t+j} is the context word, and m is the window size.

---

## E.3 Transformer Mathematics

### Attention Mechanism

**Scaled Dot-Product Attention:**

```
Attention(Q, K, V) = softmax(QK^T / √d_k) * V
```

Where:
- Q ∈ ℝ^(n×d_k): Query matrix
- K ∈ ℝ^(n×d_k): Key matrix
- V ∈ ℝ^(n×d_v): Value matrix
- n = sequence length
- d_k = key dimension
- d_v = value dimension

**Scaling Factor (√d_k):**

The scaling factor prevents the dot products from growing too large, which would push the softmax into regions with extremely small gradients.

**Attention Weight Distribution:**

```
α_ij = softmax(Q_i · K_j^T / √d_k)
```

Where α_ij is the attention weight from position i to position j.

### Multi-Head Attention

**Mathematical Definition:**

```
MultiHead(Q, K, V) = Concat(head_1, ..., head_h) * W_O

where head_i = Attention(Q * W_Q_i, K * W_K_i, V * W_V_i)
```

**Dimensions:**
- Q, K, V ∈ ℝ^(n×d_model)
- W_Q_i ∈ ℝ^(d_model × d_k)
- W_K_i ∈ ℝ^(d_model × d_k)
- W_V_i ∈ ℝ^(d_model × d_v)
- W_O ∈ ℝ^(h*d_v × d_model)

**Number of Parameters:**

```
Params = h * (d_model * d_k + d_model * d_k + d_model * d_v) + (h*d_v) * d_model
      = h * d_model * (2*d_k + d_v) + h*d_v*d_model
```

### Positional Encoding

**Sinusoidal Encoding:**

```
PE(pos, 2i) = sin(pos / 10000^(2i/d_model))
PE(pos, 2i+1) = cos(pos / 10000^(2i/d_model))
```

**Properties:**

1. **Deterministic**: Same position always gets same encoding
2. **Continuous**: Small changes in position = small changes in encoding
3. **Relative position**: PE(pos+k) can be represented as linear function of PE(pos)

**Linear Relationship:**

```
PE(pos+k) = PE(pos) * T(k)
```

Where T(k) is a linear transformation matrix.

### Feed-Forward Network

**Layer Definition:**

```
FFN(x) = max(0, xW_1 + b_1)W_2 + b_2
```

Where:
- W_1 ∈ ℝ^(d_model × d_ff)
- W_2 ∈ ℝ^(d_ff × d_model)
- d_ff typically = 4 * d_model

**GELU Activation (Modern Transformers):**

```
GELU(x) = x * Φ(x)
```

Where Φ(x) is the cumulative distribution function of the standard normal distribution.

### Layer Normalization

**Definition:**

```
LN(x) = γ * (x - μ) / √(σ² + ε) + β
```

Where:
- μ = mean(x) = (1/d) * ∑ x_i
- σ² = variance(x) = (1/d) * ∑ (x_i - μ)²
- γ, β are learned parameters
- ε is a small constant for numerical stability

---

## E.4 Knowledge Distillation Mathematics

### Temperature Scaling

**Softmax with Temperature:**

```
p_i = exp(z_i / T) / ∑ exp(z_j / T)
```

Where:
- z_i = logit for class i
- T = temperature parameter

**Temperature Effects:**

| Temperature | Effect |
|-------------|--------|
| T → 0 | Distribution approaches one-hot (deterministic) |
| T = 1 | Standard softmax |
| T → ∞ | Distribution becomes uniform |

### Distillation Loss

**KL Divergence:**

```
D_KL(P || Q) = ∑ P_i * log(P_i / Q_i)
```

Where P is the teacher distribution and Q is the student distribution.

**Combined Loss:**

```
L = α * L_distillation + (1 - α) * L_supervised

L_distillation = T² * D_KL(P_teacher_T || P_student_T)
L_supervised = CrossEntropy(y_true, P_student)
```

Where:
- α is the distillation weight
- T² is the scaling factor for gradients
- P_teacher_T = softmax(z_teacher / T)
- P_student_T = softmax(z_student / T)

**Gradient Analysis:**

```
∂L/∂z_student = (1/T) * (P_student_T - P_teacher_T) + (1-α) * (P_student - y_true)
```

The T² factor ensures gradients from distillation loss have similar magnitude to supervised loss.

### Dark Knowledge

**Definition:** The rich information contained in the teacher's soft targets beyond the hard labels.

**Information Content of Soft Targets:**

```
I = -∑ P_teacher * log(P_teacher)
```

Higher entropy = more dark knowledge transferred.

**Why Dark Knowledge Matters:**

```
Example: Image classification
Hard label: "This is a dog"
Soft targets reveal:
- Dog: 0.85 (high confidence)
- Wolf: 0.08 (similarity to wolves)
- Fox: 0.04 (similarity to foxes)
- Cat: 0.01 (less similar)
- Car: 0.001 (very different)

The student learns relationships between classes, not just the label.
```

---

## E.5 Generation Mathematics

### Temperature Sampling

**Probability Distribution:**

```
p_i = exp(z_i / T) / ∑ exp(z_j / T)
```

**Effect of Temperature:**

| T | Distribution | Use Case |
|---|--------------|----------|
| T < 0.5 | Sharp (deterministic) | Factual, unambiguous tasks |
| T = 0.5-1.0 | Balanced | Most tasks |
| T = 1.0-1.5 | Smoothed | Creative tasks |
| T > 1.5 | Near-uniform | Highly creative, random |

### Top-K Sampling

**Algorithm:**

```
1. Sort probabilities descending
2. Keep only top K probabilities
3. Renormalize over top K
4. Sample from renormalized distribution
```

**Formula:**

```
p'_i = p_i / ∑_{j∈topK} p_j, if i ∈ topK
p'_i = 0, otherwise
```

### Top-P (Nucleus) Sampling

**Algorithm:**

```
1. Sort probabilities descending
2. Accumulate probabilities until sum ≥ P
3. Keep tokens in the cumulative set
4. Renormalize over selected tokens
5. Sample from renormalized distribution
```

**Formula:**

```
S = {i | cumulative_sum(P_sorted) ≥ P}
p'_i = p_i / ∑_{j∈S} p_j, if i ∈ S
p'_i = 0, otherwise
```

### Repetition Penalty

**Application:**

```
p_i(t+1) = p_i(t) / (penalty^{count_i})
```

Where count_i is the number of times token i has appeared in the generated sequence.

**Effect:**
- Penalty > 1: Reduces probability of repeated tokens
- Penalty = 1: No penalty
- Penalty < 1: Encourages repetition (rarely used)

---

## E.6 Optimization Mathematics

### Gradient Descent

**Parameter Update:**

```
θ_new = θ_old - η * ∇L(θ_old)
```

Where:
- η = learning rate
- ∇L(θ) = gradient of loss with respect to parameters

### Adam Optimizer

**Update Rules:**

```
m_t = β₁ * m_{t-1} + (1 - β₁) * g_t
v_t = β₂ * v_{t-1} + (1 - β₂) * g_t²

m̂_t = m_t / (1 - β₁ᵗ)
v̂_t = v_t / (1 - β₂ᵗ)

θ_t = θ_{t-1} - η * m̂_t / (√v̂_t + ε)
```

Where:
- g_t = gradient at step t
- β₁, β₂ = momentum parameters (typically 0.9, 0.999)
- ε = small constant for numerical stability

### Xavier/Glorot Initialization

**Weights Initialization:**

```
W ∼ N(0, √(2 / (n_in + n_out)))
```

Where n_in and n_out are the input and output dimensions.

**Rationale:** Maintains variance of activations and gradients across layers.

---

## E.7 Memory and Performance Mathematics

### Memory Requirements

**Model Weights Memory:**

```
Memory_weights = (parameters * precision) / 8^3 GB
```

Example: 70B parameters at FP16 (2 bytes)
```
Memory = 70B * 2 / 8^3 = 70 * 10^9 * 2 / 8^3 = 70 * 10^9 / 4 = 17.5 GB
```

**KV Cache Memory per Token:**

```
Memory_KV = 2 * batch_size * seq_len * d_model * precision * num_layers
```

Example: batch_size=1, seq_len=100, d_model=4096, num_layers=32, FP16
```
Memory = 2 * 1 * 100 * 4096 * 2 * 32 / 8^3 = 2 * 100 * 4096 * 2 * 32 / 8^3 = 2 * 100 * 4096 / 4 = 8192 bytes ≈ 8KB per token
```

### Inference Time Complexity

**Without KV Cache:**

```
O(n² * d_model)
```

Where n = sequence length

**With KV Cache:**

```
O(n * d_model)
```

**Speedup:**

```
Speedup = n / 1 = n
```

For long sequences, KV caching provides near-linear speedup.

### Decoding Strategies

| Strategy | Time Complexity | Quality |
|----------|-----------------|---------|
| Greedy | O(n) | Medium |
| Beam Search | O(k*n) | High |
| Sampling | O(n) | Medium |
| Temperature | O(n) | Varies |
| Top-K/Top-P | O(n * log(k)) | High |

Where k is beam width or top-K value.

---

## E.8 Distillation vs Quantization vs Pruning

### Comparison Table

| Method | Memory Reduction | Quality Loss | Training Required | Implementation Complexity |
|--------|-----------------|--------------|-------------------|--------------------------|
| **Distillation** | 3-10x | 5-15% | Yes | High |
| **Quantization (INT8)** | 2-4x | 1-5% | No | Low |
| **Quantization (4-bit)** | 4-8x | 3-10% | No/Yes | Medium |
| **Pruning** | 1.5-3x | 5-20% | Yes | Medium |
| **Distillation + Quantization** | 6-30x | 10-25% | Yes | High |

### Combined Techniques

**Typical Pipeline:**

```
1. Train large teacher model (BF16)
2. Distill to medium student (BF16)
3. Prune unimportant connections
4. Quantize weights to INT8/4-bit
5. Final fine-tuning to recover quality
```

**Memory Reduction Example:**

```
Starting: 70B parameters @ FP32 (280 GB)
After Distillation: 7B parameters @ FP32 (28 GB)
After Quantization: 7B parameters @ INT8 (7 GB)
After 4-bit: 7B parameters @ 4-bit (3.5 GB)

Total reduction: 280 GB → 3.5 GB (80x compression)
```

---

## E.9 Attention Visualization Mathematics

### Attention Map

**Definition:**

```
A_ij = attention weight from position i to position j
```

Where A ∈ ℝ^(n×n) and ∑_j A_ij = 1 for all i.

### Visualization Techniques

**1. Heatmap:**

Color intensity indicates attention weight:

```
White/High = High attention
Black/Low = Low attention
```

**2. Sankey Diagram:**

Flows from each position to all others:

```
pos_i → pos_j with thickness proportional to A_ij
```

**3. Rolling Heatmap:**

Display attention evolution over generation steps.

### Entropy of Attention

**Attention Entropy:**

```
H(A_i) = -∑_j A_ij * log(A_ij)
```

- High entropy = distributed attention (model looks at many positions)
- Low entropy = focused attention (model looks at few positions)

**Interpretation:**
- Early layers: Often have higher entropy (general patterns)
- Later layers: Often have lower entropy (specific patterns)

---

## E.10 Probability and Statistics Reference

### Probability Distributions

**Uniform Distribution:**

```
P(x) = 1/n, for x ∈ {1, ..., n}
```

**Normal Distribution:**

```
P(x) = (1 / √(2πσ²)) * exp(-(x-μ)² / (2σ²))
```

**Softmax Distribution:**

```
P(i) = exp(z_i) / ∑ exp(z_j)
```

### Statistical Measures

**Mean:**

```
μ = (1/n) * ∑ x_i
```

**Variance:**

```
σ² = (1/n) * ∑ (x_i - μ)²
```

**Standard Deviation:**

```
σ = √σ²
```

**Covariance:**

```
Cov(X,Y) = (1/n) * ∑ (x_i - μ_x) * (y_i - μ_y)
```

### Sampling Techniques

**Categorical Sampling:**

```
Given probabilities p = [p_1, p_2, ..., p_n]
1. Generate random r ∼ Uniform(0,1)
2. Return smallest k such that ∑_{i=1}^k p_i ≥ r
```

**Gumbel-Max Trick:**

```
argmax_i (z_i + G_i)

Where G_i ∼ Gumbel(0,1)
```

---

## E.11 Quick Math Reference Card

```javascript
// QUICK REFERENCE - MATH FORMULAS

// Attention
Attention(Q,K,V) = softmax(QK^T / √d_k) * V

// Multi-Head
MultiHead(Q,K,V) = Concat(head_1,...,head_h) * W_O

// Positional Encoding
PE(pos,2i) = sin(pos / 10000^(2i/d_model))
PE(pos,2i+1) = cos(pos / 10000^(2i/d_model))

// Feed-Forward
FFN(x) = max(0, xW_1 + b_1)W_2 + b_2

// Layer Norm
LN(x) = γ * (x - μ) / √(σ² + ε) + β

// Distillation
L = α * T² * D_KL(P_teacher_T || P_student_T) + (1-α) * CrossEntropy(y_true, P_student)

// Sampling
p_i = exp(z_i / T) / ∑ exp(z_j / T)

// Entropy
H(X) = -∑ P(x) * log(P(x))

// KL Divergence
D_KL(P || Q) = ∑ P_i * log(P_i / Q_i)

// Cosine Similarity
cos(θ) = (A · B) / (||A|| * ||B||)

// Gradient Descent
θ_new = θ_old - η * ∇L(θ_old)

// Adam
m_t = β₁ * m_{t-1} + (1-β₁)*g_t
v_t = β₂ * v_{t-1} + (1-β₂)*g_t²
θ_t = θ_{t-1} - η * m̂_t / (√v̂_t + ε)
```

---

## E.12 Further Reading

### Recommended Papers

1. **Attention Is All You Need** (Vaswani et al., 2017)
   - Introduces the Transformer architecture

2. **BERT: Pre-training of Deep Bidirectional Transformers** (Devlin et al., 2018)
   - Bidirectional training objective

3. **Language Models are Few-Shot Learners** (Brown et al., 2020)
   - GPT-3, scaling laws

4. **Distilling the Knowledge in a Neural Network** (Hinton et al., 2015)
   - Knowledge distillation fundamentals

5. **LoRA: Low-Rank Adaptation** (Hu et al., 2021)
   - Efficient fine-tuning

6. **QLoRA: Efficient Finetuning of Quantized LLMs** (Dettmers et al., 2023)
   - Quantization + LoRA

7. **FlashAttention** (Dao et al., 2022)
   - Efficient attention implementation

### Online Resources

- **The Illustrated Transformer** (jalammar.github.io)
- **Distill.pub** - Visual explanations of ML
- **3Blue1Brown** - Neural network visualizations
- **Stanford CS224N** - NLP with Deep Learning

---

**[END OF APPENDIX E]**

# Real-Time Progress Log

```
[GENERATED] Appendix E: Math and Theory Reference

DOCUMENTED:
  ✅ Tokenization Mathematics (BPE, Entropy)
  ✅ Embedding Mathematics (Vectors, Cosine Similarity)
  ✅ Transformer Mathematics (Attention, Multi-Head, Positional)
  ✅ Distillation Mathematics (Temperature, KL Divergence, Dark Knowledge)
  ✅ Generation Mathematics (Sampling, Top-K, Top-P)
  ✅ Optimization Mathematics (Gradient Descent, Adam, Initialization)
  ✅ Memory and Performance Mathematics
  ✅ Distillation vs Quantization vs Pruning
  ✅ Attention Visualization Mathematics
  ✅ Probability and Statistics Reference
  ✅ Quick Math Reference Card
  ✅ Further Reading

STATUS: Appendix E COMPLETE

# Appendix E: Neural Networks Cheat Sheet

## Quick Reference for Architectures, Activations, and Training

### The Target

This appendix provides a comprehensive, quick-reference cheat sheet for neural network concepts used in machine learning. It's designed to be a practical reference for building, training, and debugging neural networks.

### The Concept

Neural networks are the workhorses of modern machine learning. This cheat sheet puts all the essential architectures, activation functions, and training techniques in one place.

**Why this matters**: When you're designing neural networks, debugging training, or reading papers, you need quick access to these concepts. This reference helps you:
- Choose the right architecture
- Select appropriate activation functions
- Debug training issues
- Understand modern deep learning techniques

### Network Architectures

#### Feedforward Neural Network (MLP)

```
Architecture:
Input → Dense → Activation → Dense → Activation → ... → Output

Forward Pass:
z⁽¹⁾ = W⁽¹⁾x + b⁽¹⁾
a⁽¹⁾ = g₁(z⁽¹⁾)
z⁽²⁾ = W⁽²⁾a⁽¹⁾ + b⁽²⁾
a⁽²⁾ = g₂(z⁽²⁾)
...
ŷ = a⁽ᴸ⁾

Backward Pass:
δ⁽ᴸ⁾ = (ŷ - y) ⊙ g'_L(z⁽ᴸ⁾)
δ⁽ˡ⁾ = (W⁽ˡ⁺¹⁾)ᵀδ⁽ˡ⁺¹⁾ ⊙ g'_l(z⁽ˡ⁾)
∂L/∂W⁽ˡ⁾ = δ⁽ˡ⁾(a⁽ˡ⁻¹⁾)ᵀ
∂L/∂b⁽ˡ⁾ = δ⁽ˡ⁾
```

#### Convolutional Neural Network (CNN)

```
Architecture:
Input → Conv → Activation → Pool → Conv → Activation → Pool → ... → Flatten → Dense → Output

Convolution:
(f * g)[i,j] = ΣₘΣₙ f[m,n]g[i-m, j-n]

Pooling:
Max Pooling: output = max(window)
Average Pooling: output = mean(window)

Common Patterns:
Conv → BatchNorm → ReLU → Conv → BatchNorm → ReLU → MaxPool
```

#### Recurrent Neural Network (RNN)

```
Architecture:
Input → RNN Cell → ... → Output

RNN Cell:
h_t = tanh(W_hh h_{t-1} + W_xh x_t + b_h)
y_t = W_hy h_t + b_y

LSTM Cell:
f_t = σ(W_f · [h_{t-1}, x_t] + b_f)    # Forget gate
i_t = σ(W_i · [h_{t-1}, x_t] + b_i)    # Input gate
C̃_t = tanh(W_C · [h_{t-1}, x_t] + b_C)  # Candidate
C_t = f_t * C_{t-1} + i_t * C̃_t        # Cell state
o_t = σ(W_o · [h_{t-1}, x_t] + b_o)    # Output gate
h_t = o_t * tanh(C_t)                  # Hidden state

GRU Cell:
z_t = σ(W_z · [h_{t-1}, x_t])         # Update gate
r_t = σ(W_r · [h_{t-1}, x_t])         # Reset gate
h̃_t = tanh(W · [r_t * h_{t-1}, x_t])  # Candidate
h_t = (1 - z_t) * h_{t-1} + z_t * h̃_t # New hidden
```

#### Transformer Architecture

```
Architecture:
Input → Embedding → Positional Encoding → Multi-Head Attention → Add & Norm → 
  Feed Forward → Add & Norm → ... → Output

Multi-Head Attention:
Attention(Q, K, V) = softmax(QK^T/√d_k)V
MultiHead(Q, K, V) = Concat(head₁, ..., head_h)W_O
where head_i = Attention(QW_i^Q, KW_i^K, VW_i^V)

Positional Encoding:
PE(pos, 2i) = sin(pos/10000^(2i/d_model))
PE(pos, 2i+1) = cos(pos/10000^(2i/d_model))
```

### Activation Functions

#### Common Activations

| Function | Formula | Range | Derivative | Pros | Cons |
|----------|---------|-------|------------|------|------|
| Sigmoid | `1/(1+e^{-x})` | (0,1) | `a(1-a)` | Probabilities | Vanishing gradient |
| Tanh | `(e^x-e^{-x})/(e^x+e^{-x})` | (-1,1) | `1-a²` | Zero-centered | Vanishing gradient |
| ReLU | `max(0, x)` | [0,∞) | `1 if x>0 else 0` | Fast, no vanish | Dead neurons |
| Leaky ReLU | `max(αx, x)` | (-∞,∞) | `1 if x>0 else α` | No dead | Additional param |
| ELU | `x if x>0 else α(e^x-1)` | (-α,∞) | `1 if x>0 else a+α` | Smooth, no dead | Expensive |
| Swish | `x·sigmoid(βx)` | (-∞,∞) | `β·sigmoid(βx)(1+x·sigmoid(βx))` | Smooth, non-monotonic | Expensive |
| GELU | `x·Φ(x)` | (-∞,∞) | `Φ(x) + x·φ(x)` | Smooth, non-monotonic | Expensive |

#### Activation Selection Guide

| Use Case | Recommended | Alternative |
|----------|-------------|-------------|
| Hidden layers | ReLU | Leaky ReLU, ELU |
| Output (regression) | Linear | Tanh (bounded) |
| Output (binary) | Sigmoid | - |
| Output (multi-class) | Softmax | - |
| Deep networks | ReLU/Swish | ELU, GELU |
| Transformers | GELU | Swish |
| RNNs | Tanh | ReLU (with care) |

### Weight Initialization

#### Common Initialization Methods

| Method | Distribution | Scale | Use Case |
|--------|--------------|-------|----------|
| Random Uniform | `U(-scale, scale)` | | Simple |
| Random Normal | `N(0, σ²)` | | Simple |
| Xavier/Glorot | Uniform: `[-√(6/(n_in+n_out)), √(6/(n_in+n_out))]` | `2/(n_in+n_out)` | Tanh/Sigmoid |
| He/Kaiming | Normal: `N(0, √(2/n_in))` | `2/n_in` | ReLU |
| Orthogonal | Orthogonal matrix | | RNNs/LSTMs |
| Identity | Identity matrix | | Deep networks |

#### Initialization Formulas

```
Xavier (tanh/sigmoid):
Var(W) = 2 / (n_in + n_out)

He (ReLU):
Var(W) = 2 / n_in

LeCun (tanh):
Var(W) = 1 / n_in

Uniform Xavier:
W ~ U(-√(6/(n_in+n_out)), √(6/(n_in+n_out)))

Normal Xavier:
W ~ N(0, √(2/(n_in+n_out)))

Normal He:
W ~ N(0, √(2/n_in))
```

### Regularization Techniques

#### Weight Regularization

| Type | Formula | Effect | Use Case |
|------|---------|--------|----------|
| L2 | `λ/2 · ||w||²` | Shrink weights | General |
| L1 | `λ · ||w||₁` | Sparse weights | Feature selection |
| Elastic Net | `λ₁||w||₁ + λ₂/2||w||²` | Combine L1/L2 | Both |
| Weight Decay | `w = w - α∇L - αλw` | Same as L2 | Standard |

#### Dropout

```
Training:
mask = Bernoulli(p)  # p = keep probability
output = input * mask / p

Inference:
output = input  # Scale factor included

Variants:
- Standard Dropout: drop random neurons
- Spatial Dropout: drop entire feature maps
- DropConnect: drop weights, not activations
- Variational Dropout: same mask per sample
```

#### Batch Normalization

```
Forward Pass:
μ_B = (1/m)Σx_i
σ²_B = (1/m)Σ(x_i - μ_B)²
x̂_i = (x_i - μ_B)/√(σ²_B + ε)
y_i = γx̂_i + β

During Training:
- Track running mean and variance
- Use batch statistics

During Inference:
- Use running mean and variance

Benefits:
- Faster training (higher learning rates)
- Reduces internal covariate shift
- Has slight regularization effect
- Less sensitive to initialization
```

#### Layer Normalization

```
Forward Pass:
μ = (1/d)Σx_i
σ² = (1/d)Σ(x_i - μ)²
x̂_i = (x_i - μ)/√(σ² + ε)
y_i = γx̂_i + β

Comparison:
- LayerNorm: Normalizes across features
- BatchNorm: Normalizes across batch
- LayerNorm: Works for RNNs/Transformers
- LayerNorm: No dependency on batch size
```

### Optimizers

#### Comparison Table

| Optimizer | LR | Momentum | Adaptive | Memory | Use Case |
|-----------|----|----------|----------|--------|----------|
| SGD | Manual | No | No | Low | Simple |
| SGD+M | Manual | Yes | No | Low | General |
| AdaGrad | Manual | No | Yes | Medium | Sparse data |
| RMSProp | Manual | Yes | Yes | Medium | RNNs |
| Adam | Auto | Yes | Yes | Medium | General |
| AdamW | Auto | Yes | Yes | Medium | General |
| Nadam | Auto | Yes | Yes | Medium | General |

#### Optimizer Updates

```
SGD:
θ_{t+1} = θ_t - α∇L(θ_t)

Momentum:
v_t = βv_{t-1} + α∇L(θ_t)
θ_{t+1} = θ_t - v_t

Nesterov:
v_t = βv_{t-1} + α∇L(θ_t - βv_{t-1})
θ_{t+1} = θ_t - v_t

AdaGrad:
g_t = g_{t-1} + ∇L(θ_t)²
θ_{t+1} = θ_t - α/√(g_t+ε)·∇L(θ_t)

RMSProp:
g_t = βg_{t-1} + (1-β)∇L(θ_t)²
θ_{t+1} = θ_t - α/√(g_t+ε)·∇L(θ_t)

Adam:
m_t = β₁m_{t-1} + (1-β₁)∇L(θ_t)
v_t = β₂v_{t-1} + (1-β₂)∇L(θ_t)²
m̂_t = m_t/(1-β₁^t)
v̂_t = v_t/(1-β₂^t)
θ_{t+1} = θ_t - α m̂_t/(√v̂_t + ε)
```

### Training Techniques

#### Learning Rate Schedules

| Schedule | Formula | Use |
|----------|---------|-----|
| Constant | `α_t = α₀` | Baseline |
| Step Decay | `α_t = α₀γ^{⌊t/T⌋}` | Step drops |
| Exponential | `α_t = α₀e^{-kt}` | Smooth decay |
| Cosine | `α_t = α₀/2(1+cos(πt/T))` | Cyclical |
| Warmup | `α_t = α₀·min(1, t/T_w)` | Start small |
| Linear | `α_t = α₀(1 - t/T)` | Linear decay |

#### Gradient Clipping

```
Clip by value:
g = clip(g, -threshold, threshold)

Clip by norm:
if ||g|| > threshold:
    g = g * threshold / ||g||

Why clip:
- Prevents exploding gradients
- Stabilizes training
- Works well with RNNs
```

#### Early Stopping

```
Procedure:
1. Train on training set
2. Evaluate on validation set each epoch
3. Track best validation performance
4. Stop when validation stops improving
5. Restore best model

Patience:
Number of epochs to wait before stopping
Typical: 5-20 epochs
```

### Common Training Issues

#### Vanishing Gradients

```
Symptoms:
- Gradients near 0
- Early layers don't learn
- Loss not decreasing

Causes:
- Deep networks
- Sigmoid/tanh activations
- Poor initialization

Solutions:
- Use ReLU/Swish activations
- He initialization
- Batch/Layer normalization
- Skip connections
- Better optimizers (Adam)
```

#### Exploding Gradients

```
Symptoms:
- Gradients very large
- NaN loss
- Weight growth

Causes:
- Deep networks
- Poor initialization
- High learning rate

Solutions:
- Gradient clipping
- Smaller learning rate
- Better initialization
- Weight decay
- Batch normalization
```

#### Dead Neurons

```
Symptoms:
- Neurons never activate
- Output always 0
- Gradients 0

Causes:
- ReLU with negative inputs
- Poor initialization
- High learning rate

Solutions:
- Leaky ReLU, ELU
- Proper initialization
- Lower learning rate
- Batch normalization
```

#### Overfitting

```
Symptoms:
- Train accuracy high
- Test accuracy low
- Large gap

Causes:
- Too complex model
- Too little data
- Not enough regularization

Solutions:
- Regularization (L2, dropout)
- Early stopping
- More data (augmentation)
- Simplify architecture
- Reduce model size
```

### Transfer Learning

```
Approaches:

1. Feature Extraction:
   - Freeze pre-trained weights
   - Train new classifier
   - Use as feature extractor

2. Fine-tuning:
   - Start with pre-trained weights
   - Unfreeze all/some layers
   - Continue training

3. Domain Adaptation:
   - Pre-train on source domain
   - Adapt to target domain

Common Architectures for Transfer:
- Image: ResNet, VGG, EfficientNet
- Text: BERT, GPT, RoBERTa
- Audio: WaveNet, Wav2Vec
```

### Common Architecture Patterns

#### Skip Connections

```
Residual Block:
output = F(x) + x
where F is conv/activation layers

Dense Block:
output = [x₁, x₂, ..., xₙ]
where each layer connects to all previous

Benefits:
- Better gradient flow
- Allows deeper networks
- Ensures learning at least identity
```

#### Bottleneck Design

```
1x1 Conv (reduce channels) → 3x3 Conv → 1x1 Conv (expand channels)

Benefits:
- Reduced computation
- More parameters per FLOP
- Better information flow
```

#### Attention Mechanisms

```
Self-Attention:
Attention(Q, K, V) = softmax(QK^T/√d_k)V

Multi-Head:
Concat(head₁, ..., head_h)W_O

Benefits:
- Global receptive field
- Flexible input size
- Better long-range dependencies
```

### Quick Reference: Common Layer Sizes

```
Input Layer:   n_features
Hidden Layer:  64, 128, 256, 512, 1024
Output Layer:  n_classes (classification) or 1 (regression)

General Rule:
- Start with 1-2 hidden layers
- Size: between input and output
- Increase depth for complex problems
- Use powers of 2 for GPU efficiency
```

---

**[END OF APPENDIX E]**

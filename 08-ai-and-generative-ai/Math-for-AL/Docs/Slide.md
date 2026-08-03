# Comprehensive Slide Outline: Mathematics for Machine Learning
## A Pragmatic Engineering Curriculum

---

# PART 0: INTRODUCTION & COURSE OVERVIEW

## Section 0.1: Welcome & Course Philosophy
**Slides: 1-5**

### Slide 1: Title Slide
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                   MATHEMATICS FOR MACHINE LEARNING
                    A Pragmatic Engineering Curriculum
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

                  [Course Logo/Visual Placeholder]

                        Code-Heavy · Production-Focused
                      From Foundations to Deployment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Welcome students. Explain that this course bridges the gap between abstract mathematical theory and production-grade machine learning. Designed specifically for software engineers, it bypasses heavy academic proofs in favor of applied frameworks required to understand data structures, optimize parameters, and interpret model behaviors from scratch.

**Key Talking Points**:
- This is not a traditional math course—it's a practical engineering curriculum
- Every mathematical concept will be implemented in working Python code
- By the end, students will build a complete ML system from scratch
- No prior ML experience required—just basic Python and high school algebra

### Slide 2: The Gap We're Bridging
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    THE GAP WE'RE BRIDGING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────┐
    │                     THE PROBLEM                          │
    ├─────────────────────────────────────────────────────────┤
    │                                                          │
    │   ❌ Math textbooks: Abstract, no code                   │
    │   ❌ ML tutorials: Black boxes, no math                 │
    │   ❌ Research papers: Too dense, inaccessible           │
    │                                                          │
    └─────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────┐
    │                  OUR SOLUTION                           │
    ├─────────────────────────────────────────────────────────┤
    │                                                          │
    │   ✅ Math explained with analogies                      │
    │   ✅ Every concept coded from scratch                    │
    │   ✅ Production-ready implementations                   │
    │   ✅ Real ML system as final deliverable                │
    │                                                          │
    └─────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Explain the fundamental problem: most ML education either focuses entirely on theory without practical implementation, or teaches high-level frameworks without explaining what's happening under the hood. This course solves both problems simultaneously.

**Key Talking Points**:
- Machine learning isn't magic—it's engineering with mathematical tools
- The goal is to understand what happens inside PyTorch/TensorFlow, not just use them
- You'll graduate from "framework user" to "ML engineer"

### Slide 3: Course Learning Objectives
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                 LEARNING OBJECTIVES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    By the end of this course, you will be able to:

    ┌─────────────────────────────────────────────────────────┐
    │  1. 🎯 IMPLEMENT ALGORITHMS FROM SCRATCH               │
    │     └─ No high-level frameworks—pure Python + NumPy   │
    ├─────────────────────────────────────────────────────────┤
    │  2. 🎯 UNDERSTAND ML MATHEMATICS                       │
    │     └─ Linear algebra, calculus, probability          │
    ├─────────────────────────────────────────────────────────┤
    │  3. 🎯 BUILD PRODUCTION SYSTEMS                        │
    │     └─ End-to-end pipeline, deployment-ready          │
    ├─────────────────────────────────────────────────────────┤
    │  4. 🎯 READ RESEARCH PAPERS                            │
    │     └─ Understand notation and implement algorithms   │
    ├─────────────────────────────────────────────────────────┤
    │  5. 🎯 DEBUG & OPTIMIZE ML CODE                       │
    │     └─ Understand what goes wrong and why             │
    └─────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Slide 4: Ultimate Architecture - What You'll Build
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            THE ULTIMATE ARCHITECTURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                     YOUR ML PIPELINE                        │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │  ┌──────────────────────────────────────────────────────┐   │
    │  │               DATA LAYER                            │   │
    │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐ │   │
    │  │  │ DataLoader   │  │  Preprocess  │  │  Tensor  │ │   │
    │  │  └──────────────┘  └──────────────┘  └──────────┘ │   │
    │  └──────────────────────────────────────────────────────┘   │
    │                                                              │
    │  ┌──────────────────────────────────────────────────────┐   │
    │  │            TRANSFORMATION LAYER                     │   │
    │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐ │   │
    │  │  │ Matrix Ops   │  │   SVD/PCA   │  │   SVD    │ │   │
    │  │  └──────────────┘  └──────────────┘  └──────────┘ │   │
    │  └──────────────────────────────────────────────────────┘   │
    │                                                              │
    │  ┌──────────────────────────────────────────────────────┐   │
    │  │             OPTIMIZATION LAYER                      │   │
    │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐ │   │
    │  │  │ Loss Funcs   │  │ Grad Descent │  │ Backprop │ │   │
    │  │  └──────────────┘  └──────────────┘  └──────────┘ │   │
    │  └──────────────────────────────────────────────────────┘   │
    │                                                              │
    │  ┌──────────────────────────────────────────────────────┐   │
    │  │            PROBABILISTIC LAYER                      │   │
    │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐ │   │
    │  │  │ Distributions│  │ Bayes' Thm  │  │ Evaluation│ │   │
    │  │  └──────────────┘  └──────────────┘  └──────────┘ │   │
    │  └──────────────────────────────────────────────────────┘   │
    │                                                              │
    │  ┌──────────────────────────────────────────────────────┐   │
    │  │             APPLICATION LAYER                       │   │
    │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐ │   │
    │  │  │  Logistic    │  │  Inference   │  │  Eval    │ │   │
    │  │  │  Regression  │  │  Pipeline    │  │  Pipeline│ │   │
    │  │  └──────────────┘  └──────────────┘  └──────────┘ │   │
    │  └──────────────────────────────────────────────────────┘   │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Walk through each layer. Explain that this is what we'll build piece by piece. The final deliverable is a complete system .

**Key Talking Points**:
- Each layer corresponds to one part of the course
- The layers are independent but work together
- This architecture is used in production ML systems

### Slide 5: Course Structure at a Glance
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
              COURSE STRUCTURE AT A GLANCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ╭───────────────────────────────────────────────────────────────╮
    │  PART 1: LINEAR ALGEBRA — The Language of Data              │
    │  ───────────────────────────────────────────────────────────  │
    │  Modules: 3-4    │  Duration: ~12 hours                     │
    │  Focus: Vectors, Matrices, Tensors, SVD, PCA                │
    ├───────────────────────────────────────────────────────────────┤
    │  PART 2: CALCULUS — The Engine of Optimization              │
    │  ───────────────────────────────────────────────────────────  │
    │  Modules: 3-4    │  Duration: ~12 hours                     │
    │  Focus: Derivatives, Gradients, Backpropagation             │
    ├───────────────────────────────────────────────────────────────┤
    │  PART 3: PROBABILITY & STATISTICS — Handling Uncertainty    │
    │  ───────────────────────────────────────────────────────────  │
    │  Modules: 3-4    │  Duration: ~12 hours                     │
    │  Focus: Distributions, Bayes, MLE, Model Evaluation         │
    ├───────────────────────────────────────────────────────────────┤
    │  PART 4: APPLIED NUMERICAL METHODS — From Math to Code      │
    │  ───────────────────────────────────────────────────────────  │
    │  Modules: 3-4    │  Duration: ~12 hours                     │
    │  Focus: Stability, Performance, Complete Pipeline           │
    ╰───────────────────────────────────────────────────────────────╯

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Total: ~48 hours of content + ~30-40 hours of coding
    Final Project: Production-Ready ML System
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Provide a roadmap overview. Explain that while we present this as one series, students should pace themselves. Each part builds on the previous ones .

---

# PART 1: LINEAR ALGEBRA — THE LANGUAGE OF DATA

## Section 1.0: Linear Algebra Overview
**Slides: 6-8**

### Slide 6: Why Linear Algebra?
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
              WHY LINEAR ALGEBRA?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                    THE ANALOGY                              │
    │                                                              │
    │   Imagine describing a house you want to buy:               │
    │   • 2,000 sq ft • 3 bedrooms • 2 bathrooms                  │
    │                                                              │
    │   This is a VECTOR!                                         │
    │                                                              │
    │   A dataset is a collection of vectors → a MATRIX!          │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              WHY THIS MATTERS FOR ML                       │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ✓ Data is represented as vectors & matrices               │
    │   ✓ Transformations are matrix multiplications              │
    │   ✓ Similarity is dot products                              │
    │   ✓ Dimensionality reduction = SVD/PCA                     │
    │   ✓ Neural networks = matrix multiplications               │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Linear algebra is the language of data. Every dataset is a matrix. Every ML model is a transformation of that matrix. This is why linear algebra is foundational .

### Slide 7: Linear Algebra Roadmap
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                 LINEAR ALGEBRA ROADMAP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ╭─────────────────────────────────────────────────────────────╮
    │  MODULE 1: VECTORS — The Atoms of Data                     │
    │  ─────────────────────────────────────────────────────────  │
    │  • Vector operations (add, subtract, scale)                │
    │  • Dot products (similarity)                               │
    │  • Norms (magnitude)                                       │
    │  • Distances                                               │
    │  [CODE: Complete Vector class + tests]                    │
    ├─────────────────────────────────────────────────────────────┤
    │  MODULE 2: MATRICES — Datasets in 2D                      │
    │  ─────────────────────────────────────────────────────────  │
    │  • Matrix operations (add, multiply, transpose)           │
    │  • Matrix-vector multiplication                           │
    │  • Matrix inversion and determinants                      │
    │  • Special matrices (identity, diagonal, symmetric)      │
    │  [CODE: Complete Matrix class + tests]                   │
    ├─────────────────────────────────────────────────────────────┤
    │  MODULE 3: TENSORS & DECOMPOSITIONS                       │
    │  ─────────────────────────────────────────────────────────  │
    │  • Tensors (3D+ data)                                    │
    │  • Eigenvalues & eigenvectors                             │
    │  • Singular Value Decomposition (SVD)                    │
    │  • Principal Component Analysis (PCA)                    │
    │  [CODE: Tensor, SVD, PCA implementations]                │
    ├─────────────────────────────────────────────────────────────┤
    │  MODULE 4: REFERENCE — Linear Algebra in Practice         │
    │  ─────────────────────────────────────────────────────────  │
    │  • Numerical stability                                    │
    │  • Performance optimization                               │
    │  • Common pitfalls                                       │
    │  • Production utilities                                  │
    ╰─────────────────────────────────────────────────────────────╯

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Slide 8: Key Linear Algebra Concepts
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                KEY LINEAR ALGEBRA CONCEPTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │  CONCEPT          │  ML APPLICATION                        │
    ├─────────────────────────────────────────────────────────────┤
    │  Vectors          │  Data points, features    │
    │  Matrices         │  Datasets, transformations             │
    │  Dot Product      │  Similarity, weighted sums             │
    │  Matrix Multiply  │  Forward pass in neural nets           │
    │  Transpose        │  Data preparation, gradients           │
    │  Determinant      │  Matrix invertibility                  │
    │  Eigenvalues      │  PCA, covariance structure             │
    │  SVD              │  Dimensionality reduction, denoising   │
    │  PCA              │  Feature extraction, visualization     │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                    KEY FORMULAS                            │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │  Dot Product:      u·v = Σ u_i v_i                        │
    │  L2 Norm:          ||v||₂ = √(Σ v_i²)                     │
    │  Matrix Multiply:  (AB)_ij = Σ_k A_ik B_kj               │
    │  SVD:              A = UΣV^T                              │
    │  PCA Projection:   T = X_c V                              │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Section 1.1: Vectors — The Atoms of Data
**Slides: 9-15**

### Slide 9: What is a Vector?
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    WHAT IS A VECTOR?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                      DEFINITION                             │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   A vector is an ordered list of numbers:                   │
    │                                                              │
    │   v = [v₁, v₂, v₃, ..., vₙ]                               │
    │                                                              │
    │   Each number is a component or coordinate.                 │
    │   The number of components is the dimension.                │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                REAL-WORLD EXAMPLES                          │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   House:         [2000, 3, 2]  (sqft, beds, baths)        │
    │   RGB Color:     [255, 128, 0] (red, green, blue)         │
    │   Word Embedding: [0.2, -0.5, 0.8, ...]                   │
    │   Image:         [pixel₁, pixel₂, ...]                    │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                   PYTHON IMPLEMENTATION                     │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   v = Vector([2000, 3, 2])                                 │
    │   v.size  # 3                                              │
    │   v[0]    # 2000                                           │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Start with the simplest concept. A vector is just a list of numbers, but in ML it represents a data point. Every row in your dataset is a vector .

### Slide 10: Vector Operations
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                 VECTOR OPERATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌──────────────────────────────────────────────────────────────┐
    │  OPERATION     │  FORMULA            │  CODE               │
    ├──────────────────────────────────────────────────────────────┤
    │  Addition      │  (u+v)_i = u_i+v_i │  u + v              │
    │  Subtraction   │  (u-v)_i = u_i-v_i │  u - v              │
    │  Scalar Mult.  │  (c·v)_i = c·v_i   │  c * v              │
    │  Scalar Div.   │  (v/c)_i = v_i/c   │  v / c              │
    │  Dot Product   │  u·v = Σ u_i v_i   │  u.dot(v)           │
    │  L2 Norm       │  ||v||₂ = √(Σ v_i²)│  v.norm(2)          │
    │  L1 Norm       │  ||v||₁ = Σ|v_i|   │  v.norm(1)          │
    │  Normalization │  v̂ = v/||v||₂      │  v.normalize()      │
    └──────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │               KEY INSIGHTS                                  │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   • Addition combines data points                           │
    │   • Dot product measures similarity           │
    │   • Norm measures magnitude                                 │
    │   • Normalization creates unit vectors                     │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Walk through each operation. Show code examples. Emphasize that dot product is the foundation of many ML operations (similarity, weighted sums, attention).

### Slide 11: Dot Product — Measuring Similarity
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
              DOT PRODUCT — MEASURING SIMILARITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                 THE FORMULA                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   u·v = u₁v₁ + u₂v₂ + ... + uₙvₙ                        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                 THE INTUITION                               │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   House 1: [2000, 3, 2]                                    │
    │   House 2: [1500, 2, 1]                                    │
    │                                                              │
    │   dot = 2000*1500 + 3*2 + 2*1 = 3,000,008                 │
    │   (Larger value = more similar)                           │
    │                                                              │
    │   (Normalized dot product = cosine similarity)             │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              ML APPLICATIONS                                │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ✓ Linear regression: y = w·x + b                        │
    │   ✓ Neural networks: z = w·x + b                          │
    │   ✓ Word embeddings: cosine similarity                    │
    │   ✓ Recommendation systems: user-item similarity          │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: The dot product is the most important vector operation in ML. Show how it's used in linear regression, neural networks, and similarity metrics.

### Slide 12: Vector Norms — Measuring Magnitude
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            VECTOR NORMS — MEASURING MAGNITUDE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │   NORM         │  FORMULA            │  ML USE             │
    ├─────────────────────────────────────────────────────────────┤
    │   L1           │  ||v||₁ = Σ|v_i|   │  Lasso regression  │
    │   L2           │  ||v||₂ = √(Σv_i²) │  Ridge reg., SGD  │
    │   L∞           │  ||v||∞ = max|v_i| │  Gradient clipping │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                 VISUAL INTUITION                            │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   v = [3, 4]                                                │
    │                                                              │
    │   L1 Norm: |3| + |4| = 7                                   │
    │   L2 Norm: √(9 + 16) = 5                                   │
    │   L∞ Norm: max(3, 4) = 4                                   │
    │                                                              │
    │   [Visual: Triangle with sides 3 and 4]                    │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                   CODE                                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   v = Vector([3, 4])                                       │
    │   v.norm(1)   # 7.0                                       │
    │   v.norm(2)   # 5.0                                       │
    │   v.norm(float('inf'))  # 4.0                             │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Norms measure magnitude. L2 is the Euclidean norm. L1 is robust to outliers. L∞ is the maximum component. Each has different ML applications .

### Slide 13: Vector Spaces and Basis
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            VECTOR SPACES AND BASIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                VECTOR SPACE                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   A vector space is a set of vectors that is closed        │
    │   under addition and scalar multiplication.                 │
    │                                                              │
    │   Example: ℝ² = all 2D vectors                              │
    │   Example: ℝ³ = all 3D vectors                              │
    │   Example: ℝⁿ = all n-dimensional vectors                  │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                BASIS VECTORS                                │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   A basis is a set of vectors that spans the space         │
    │   and is linearly independent.                              │
    │                                                              │
    │   Standard basis in ℝ²:                                    │
    │   e₁ = [1, 0], e₂ = [0, 1]                                │
    │                                                              │
    │   Any vector can be written as:                            │
    │   v = a·e₁ + b·e₂                                         │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              WHY THIS MATTERS                              │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ✓ Different bases = different perspectives on data       │
    │   ✓ PCA finds optimal basis                                │
    │   ✓ Basis change = data transformation                    │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Vector spaces and basis are abstract but important. Explain that PCA essentially finds the optimal basis for representing data .

### Slide 14: Code Demo — Vector Operations
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          CODE DEMO — VECTOR OPERATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    >>> from src.linear_algebra import Vector
    >>> 
    >>> v1 = Vector([1, 2, 3])
    >>> v2 = Vector([4, 5, 6])
    >>> 
    >>> # Addition
    >>> v1 + v2
    Vector([5.0, 7.0, 9.0])
    >>> 
    >>> # Dot product (similarity)
    >>> v1.dot(v2)
    32.0  # 1*4 + 2*5 + 3*6
    >>> 
    >>> # Norm (magnitude)
    >>> v1.norm(2)
    3.7416573867739413
    >>> 
    >>> # Normalization (unit vector)
    >>> v1.normalize()
    Vector([0.2673, 0.5345, 0.8018])
    >>> 
    >>> # Distance between vectors
    >>> v1.distance(v2, 2)
    5.196152422706632

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Live demo. Show the complete Vector class. Run tests. Verify all operations work.

### Slide 15: Verification — Testing Vectors
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            VERIFICATION — TESTING VECTORS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    # Run the tests
    $ pytest tests/test_linear_algebra.py -v

    ==================== test session starts ====================
    collected 18 items

    tests/test_linear_algebra.py::TestVector::test_initialization PASSED
    tests/test_linear_algebra.py::TestVector::test_add PASSED
    tests/test_linear_algebra.py::TestVector::test_sub PASSED
    tests/test_linear_algebra.py::TestVector::test_scalar_multiplication PASSED
    tests/test_linear_algebra.py::TestVector::test_dot_product PASSED
    tests/test_linear_algebra.py::TestVector::test_norm PASSED
    tests/test_linear_algebra.py::TestVector::test_distance PASSED
    tests/test_linear_algebra.py::TestVector::test_normalize PASSED
    tests/test_linear_algebra.py::TestVector::test_mean PASSED
    tests/test_linear_algebra.py::TestVector::test_variance PASSED

    ==================== 18 passed in 0.12s ====================

    ┌─────────────────────────────────────────────────────────────┐
    │                    ✓ ALL TESTS PASS                       │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Show test output. Emphasize the importance of testing in production ML.

---

## Section 1.2: Matrices — Datasets in 2D
**Slides: 16-22**

### Slide 16: What is a Matrix?
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    WHAT IS A MATRIX?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                      DEFINITION                             │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   A matrix is a 2D array of numbers:                        │
    │                                                              │
    │         ┌                    ┐                              │
    │         │ a₁₁  a₁₂  ...  a₁ₙ│                              │
    │         │ a₂₁  a₂₂  ...  a₂ₙ│                              │
    │    A =  │  ⋮    ⋮    ⋱   ⋮ │                              │
    │         │ aₘ₁  aₘ₂  ...  aₘₙ│                              │
    │         └                    ┘                              │
    │                                                              │
    │   Shape: m rows × n columns                                │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              REAL-WORLD EXAMPLES                            │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Dataset: Each row = one sample, each column = one feature │
    │   [2000, 3, 2]     House 1                                │
    │   [1500, 2, 1]     House 2                                │
    │   [1800, 3, 2]     House 3                                │
    │   [2200, 4, 3]     House 4                                │
    │                                                              │
    │   Shape: 4 rows (houses) × 3 columns (features)            │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Matrices are how we represent datasets in ML. Each row is a sample, each column is a feature. This is the standard data format .

### Slide 17: Matrix Operations
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                 MATRIX OPERATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌──────────────────────────────────────────────────────────────┐
    │  OPERATION        │  RESULT SHAPE    │  CODE               │
    ├──────────────────────────────────────────────────────────────┤
    │  Addition         │  Same as input  │  A + B              │
    │  Subtraction      │  Same as input  │  A - B              │
    │  Scalar Multiply  │  Same as input  │  c * A              │
    │  Transpose        │  (n, m)         │  A.T                │
    │  Matrix Multiply  │  (m, p)         │  A @ B              │
    │  Matrix-Vector    │  (m,)           │  A.vector_dot(v)    │
    │  Inverse          │  (n, n)         │  A.inverse()        │
    │  Determinant      │  scalar         │  A.determinant()    │
    └──────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                 MATRIX MULTIPLICATION                       │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   A ∈ ℝ^(m×n), B ∈ ℝ^(n×p)                                │
    │   (AB)_ij = Σ_k A_ik B_kj                                 │
    │                                                              │
    │   Example:                                                  │
    │   [1, 2] @ [5, 6] = [19, 22]                              │
    │   [3, 4]   [7, 8]   [43, 50]                              │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Matrix multiplication is the workhorse of ML. Forward pass in neural nets is matrix multiplication. Show dimension rules.

### Slide 18: Matrix Transpose and Its Importance
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            MATRIX TRANSPOSE AND ITS IMPORTANCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                    TRANSPOSE                                │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   (A^T)_ij = A_ji                                          │
    │                                                              │
    │   [1, 2, 3]^T = [1]                                        │
    │   [4, 5, 6]     [2]                                       │
    │                  [3]                                       │
    │                  [4]                                       │
    │                  [5]                                       │
    │                  [6]                                       │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              WHY TRANSPOSE MATTERS                         │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ✓ Prepare data for matrix multiplication                 │
    │   ✓ Compute covariance: X^T X                             │
    │   ✓ Gradient computation: X^T (ŷ - y)                     │
    │   ✓ PCA projections                                        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                   CODE                                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   A = Matrix([[1, 2, 3], [4, 5, 6]])                      │
    │   A.T  # Matrix([[1, 4], [2, 5], [3, 6]])                 │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Transpose is essential. Show how it's used in gradient descent and covariance computation.

### Slide 19: Special Matrices
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                 SPECIAL MATRICES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │  MATRIX          │  DEFINITION       │  ML USE            │
    ├─────────────────────────────────────────────────────────────┤
    │  Identity        │  I_ij = 1 if i=j │  Starting point    │
    │  Diagonal        │  D_ij = 0 if i≠j │  Scaling           │
    │  Symmetric       │  A = A^T         │  Covariance        │
    │  Orthogonal      │  Q^T Q = I       │  PCA, rotations    │
    │  Positive Def.   │  x^T A x > 0     │  Covariance        │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                 IDENTITY MATRIX                             │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   I = [1, 0, 0]                                            │
    │       [0, 1, 0]                                            │
    │       [0, 0, 1]                                            │
    │                                                              │
    │   AI = IA = A  (multiplicative identity)                  │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                   CODE                                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Matrix.identity(3)  # 3x3 identity matrix               │
    │   Matrix.zeros(3, 4)  # 3x4 zero matrix                   │
    │   Matrix.ones(3, 4)   # 3x4 ones matrix                   │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Slide 20: Matrix Inversion and Solving Systems
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            MATRIX INVERSION AND SOLVING SYSTEMS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                    INVERSE                                  │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   A^{-1} is the matrix such that:                          │
    │                                                              │
    │   A · A^{-1} = A^{-1} · A = I                             │
    │                                                              │
    │   Only defined for square, invertible matrices.            │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │               SOLVING LINEAR SYSTEMS                        │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Ax = b  →  x = A^{-1} b                                 │
    │                                                              │
    │   This is the closed-form solution to linear regression!   │
    │                                                              │
    │   w = (X^T X)^{-1} X^T y                                  │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                   CODE                                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   A = Matrix([[1, 2], [3, 4]])                            │
    │   A.inverse()                                              │
    │   # Matrix([[-2.0, 1.0], [1.5, -0.5]])                    │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Matrix inversion is used in the closed-form solution for linear regression. Show the normal equation. Note that for large data, we use iterative methods (gradient descent) instead .

### Slide 21: Code Demo — Matrix Operations
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          CODE DEMO — MATRIX OPERATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    >>> from src.linear_algebra import Matrix, Vector
    >>> 
    >>> # Create dataset (4 houses, 3 features each)
    >>> data = Matrix([
    ...     [2000, 3, 2],
    ...     [1500, 2, 1],
    ...     [1800, 3, 2],
    ...     [2200, 4, 3]
    ... ])
    >>> 
    >>> # Extract features (columns)
    >>> sqft = data.col(0)  # [2000, 1500, 1800, 2200]
    >>> bedrooms = data.col(1)  # [3, 2, 3, 4]
    >>> 
    >>> # Matrix multiplication
    >>> data.T @ data  # Gram matrix (feature correlations)
    Matrix([[...]])
    >>> 
    >>> # Standardize data
    >>> data.standardize()  # Mean 0, variance 1
    >>> 
    >>> # Compute covariance
    >>> cov = data.T @ data / (data.rows - 1)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Live demo. Show the complete Matrix class. Demonstrate covariance computation and standardization.

### Slide 22: Verification — Testing Matrices
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            VERIFICATION — TESTING MATRICES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    # Run all linear algebra tests
    $ pytest tests/test_linear_algebra.py -v

    ==================== test session starts ====================
    collected 36 items

    tests/test_linear_algebra.py::TestVector::test_initialization PASSED
    tests/test_linear_algebra.py::TestVector::test_norm PASSED
    ...
    tests/test_linear_algebra.py::TestMatrix::test_initialization PASSED
    tests/test_linear_algebra.py::TestMatrix::test_multiplication PASSED
    tests/test_linear_algebra.py::TestMatrix::test_inverse PASSED
    tests/test_linear_algebra.py::TestMatrix::test_transpose PASSED

    ==================== 36 passed in 0.23s ====================

    ┌─────────────────────────────────────────────────────────────┐
    │                    ✓ ALL TESTS PASS                       │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Section 1.3: Decompositions — SVD and PCA
**Slides: 23-30**

### Slide 23: Eigenvalues and Eigenvectors
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            EIGENVALUES AND EIGENVECTORS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                 THE EQUATION                                │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Av = λv                                                  │
    │                                                              │
    │   A: Matrix                                                │
    │   v: Eigenvector (direction that doesn't change)           │
    │   λ: Eigenvalue (scaling factor)                           │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                 THE INTUITION                               │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Think of A as a transformation:                          │
    │                                                              │
    │   • Eigenvector = direction of pure stretching             │
    │   • Eigenvalue = amount of stretching                      │
    │                                                              │
    │   Example: PCA finds directions of maximum variance        │
    │   (these are eigenvectors of the covariance matrix)        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              ML APPLICATIONS                                │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ✓ Principal Component Analysis                           │
    │   ✓ PageRank (Google's algorithm)                          │
    │   ✓ Covariance structure analysis                          │
    │   ✓ Stability analysis                                     │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Eigenvalues and eigenvectors are the foundation of PCA. They tell us the "directions of maximum variance" in our data .

### Slide 24: Singular Value Decomposition (SVD)
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            SINGULAR VALUE DECOMPOSITION (SVD)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              THE DECOMPOSITION                              │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   A = U Σ V^T                                             │
    │                                                              │
    │   • U: Left singular vectors (m × m, orthogonal)           │
    │   • Σ: Singular values (m × n, diagonal)                  │
    │   • V: Right singular vectors (n × n, orthogonal)         │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              WHY SVD IS POWERFUL                            │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ✓ Works on ANY matrix (not just square)                  │
    │   ✓ Reveals intrinsic dimension of data                    │
    │   ✓ Numerically stable                                     │
    │   ✓ Foundation of PCA                                      │
    │   ✓ Used in recommender systems                            │
    │   ✓ Used in image compression                              │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                   CODE                                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   U, S, Vt = Decomposition.svd(A)                         │
    │   # A ≈ U @ S @ Vt                                        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: SVD is the Swiss Army knife of linear algebra. It works on any matrix and reveals hidden structure .

### Slide 25: Understanding SVD — Visual Intuition
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           UNDERSTANDING SVD — VISUAL INTUITION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              WHAT SVD TELLS US                              │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   1. U columns = principal directions in original space    │
    │   2. V columns = principal directions in feature space     │
    │   3. Σ = importance of each direction                      │
    │                                                              │
    │   The singular values (σ₁ ≥ σ₂ ≥ σ₃ ≥ ...) tell us        │
    │   how much variance is in each direction.                  │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              VISUAL EXAMPLE                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   σ₁ = 25.4  │  σ₂ = 1.3  │  σ₃ = 0.0                    │
    │                                                              │
    │   First singular value is much larger!                      │
    │   → Data is approximately 1-dimensional                    │
    │   → We can reduce dimension with minimal loss              │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                 LOW-RANK APPROXIMATION                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   A ≈ U_k Σ_k V_k^T                                       │
    │                                                              │
    │   Keep only top k singular values.                         │
    │   This is the optimal low-rank approximation!              │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: The singular values tell us the importance of each component. This is the foundation of dimensionality reduction .

### Slide 26: Principal Component Analysis (PCA)
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            PRINCIPAL COMPONENT ANALYSIS (PCA)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              THE PROBLEM                                    │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   High-dimensional data is hard to visualize and process.  │
    │                                                              │
    │   Example: 100 features × 1000 samples                     │
    │   → Can we represent this with 2 features?                 │
    │   → YES! PCA does exactly this.                           │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              THE ALGORITHM                                  │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   1. Center the data: X_c = X - μ                         │
    │   2. Compute SVD: X_c = U Σ V^T                           │
    │   3. Components: V (right singular vectors)               │
    │   4. Project: T = X_c V_k                                 │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              WHY PCA MATTERS                                │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ✓ Dimensionality reduction                               │
    │   ✓ Visualization (reduce to 2D/3D)                        │
    │   ✓ Noise reduction                                        │
    │   ✓ Feature extraction                                     │
    │   ✓ Faster models (fewer features)                        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: PCA is the most important application of SVD. It's used in almost every ML pipeline .

### Slide 27: PCA Explained Variance
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
              PCA — EXPLAINED VARIANCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              EXPLAINED VARIANCE RATIO                       │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   For each component i:                                     │
    │                                                              │
    │   explained_variance_i = σ_i² / Σ σ_j²                    │
    │                                                              │
    │   This tells us how much variance each component captures. │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                VISUAL EXAMPLE                               │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ┌──────────────────────────────────────────────────────┐ │
    │   │  Component 1: 96.3% of variance                     │ │
    │   │  Component 2: 3.7% of variance                      │ │
    │   │  Component 3: 0.0% of variance                      │ │
    │   └──────────────────────────────────────────────────────┘ │
    │                                                              │
    │   → We can reduce from 3D to 2D while keeping 100% of     │
    │     the meaningful variance!                               │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              CHOOSING K (NUMBER OF COMPONENTS)              │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   • Look for "elbow" in explained variance plot            │
    │   • Choose k that captures 95% variance                    │
    │   • Rule of thumb: keep cumulative variance > 90%          │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: The explained variance tells us how many components to keep. This is a crucial practical decision .

### Slide 28: Code Demo — SVD and PCA
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            CODE DEMO — SVD AND PCA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    >>> from src.linear_algebra import Matrix, Decomposition
    >>> 
    >>> # Create dataset
    >>> data = Matrix([
    ...     [2.5, 2.4], [0.5, 0.7], [2.2, 2.9],
    ...     [1.9, 2.2], [3.1, 3.0], [2.3, 2.7],
    ...     [2.0, 1.6], [1.0, 1.1], [1.5, 1.6], [1.1, 0.9]
    ... ])
    >>> 
    >>> # SVD
    >>> U, S, Vt = Decomposition.svd(data)
    >>> singular_values = [S[i, i] for i in range(min(S.rows, S.cols))]
    >>> print(f"Singular values: {singular_values}")
    Singular values: [25.4624, 1.2907]
    >>> 
    >>> # PCA: reduce to 1 dimension
    >>> projected, components, explained = Decomposition.pca(data, 1)
    >>> print(f"Explained variance: {explained[0]:.4f}")
    Explained variance: 0.9632

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Live demo. Show SVD and PCA in action. Demonstrate the explained variance ratio.

### Slide 29: PCA Visualization
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
              PCA VISUALIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              BEFORE PCA (2D ORIGINAL DATA)                  │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   [Scatter plot of 2D data points]                         │
    │                                                              │
    │   Data is 2D, but most variance is along one direction.    │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              AFTER PCA (1D PROJECTION)                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   [Scatter plot of 1D projected data]                      │
    │                                                              │
    │   Data is reduced to 1D while preserving 96% of variance!  │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              RECONSTRUCTION FROM PCA                        │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Original: [2.5, 2.4]                                     │
    │   Reconstructed: [2.43, 2.46] (very close!)                │
    │                                                              │
    │   → We can almost perfectly reconstruct from 1D!           │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Show the visual impact of PCA. Explain how reconstruction works.

### Slide 30: Verification — Testing Decompositions
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            VERIFICATION — TESTING DECOMPOSITIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    >>> # Test SVD
    >>> A = Matrix([[1, 2], [3, 4]])
    >>> U, S, Vt = Decomposition.svd(A)
    >>> reconstruction = U @ S @ Vt
    >>> 
    >>> # Should match original
    >>> reconstruction == A  # True
    True
    >>> 
    >>> # Test PCA on Iris-like dataset
    >>> X = Matrix([...])  # 4D data
    >>> projected, comps, explained = Decomposition.pca(X, 2)
    >>> 
    >>> # Check shape
    >>> projected.shape  # (n_samples, 2)
    (150, 2)
    >>> 
    >>> # Check explained variance sum
    >>> sum(explained)  # Should be close to 1.0
    0.995

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

# PART 2: CALCULUS — THE ENGINE OF OPTIMIZATION

## Section 2.0: Calculus Overview
**Slides: 31-33**

### Slide 31: Why Calculus?
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    WHY CALCULUS?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                 THE BIG IDEA                                │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Calculus = The Mathematics of Change                     │
    │                                                              │
    │   In ML, we use calculus to:                               │
    │                                                              │
    │   ✓ Measure how wrong our model is (loss)                  │
    │   ✓ Figure out how to improve it (gradient)                │
    │   ✓ Update parameters to reduce error (optimization)       │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │           THE LEARNING LOOP                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Forward Pass: ŷ = f(X, w)                               │
    │   Compute Loss: L = MSE(ŷ, y)                             │
    │   Compute Gradient: ∂L/∂w (how to change weights)          │
    │   Update: w = w - α·∂L/∂w                                 │
    │   Repeat!                                                   │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                KEY INSIGHT                                  │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Learning = Finding the minimum of a function             │
    │   Calculus gives us the tools to find minima efficiently   │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Calculus is how ML models learn. The entire learning process is gradient-based optimization. Show the learning loop .

### Slide 32: Calculus Roadmap
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                 CALCULUS ROADMAP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ╭─────────────────────────────────────────────────────────────╮
    │  MODULE 1: DERIVATIVES — Measuring Change                 │
    │  ─────────────────────────────────────────────────────────  │
    │  • Numerical derivatives                                    │
    │  • Analytical derivatives                                   │
    │  • Partial derivatives                                      │
    │  • Gradient computation                                     │
    │  [CODE: Derivatives class + tests]                        │
    ├─────────────────────────────────────────────────────────────┤
    │  MODULE 2: OPTIMIZATION — The Learning Algorithm          │
    │  ─────────────────────────────────────────────────────────  │
    │  • Gradient descent                                        │
    │  • Stochastic gradient descent                             │
    │  • Mini-batch gradient descent                             │
    │  • Momentum                                                │
    │  • Adam                                                    │
    │  [CODE: Optimization class + tests]                      │
    ├─────────────────────────────────────────────────────────────┤
    │  MODULE 3: BACKPROPAGATION — The Chain Rule in Action    │
    │  ─────────────────────────────────────────────────────────  │
    │  • Chain rule                                              │
    │  • Computational graphs                                   │
    │  • Backpropagation algorithm                              │
    │  • Neural network training                                │
    │  [CODE: Neural Network class + tests]                    │
    ╰─────────────────────────────────────────────────────────────╯

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Roadmap through the calculus section. Show how each module builds on the previous .

### Slide 33: Key Calculus Concepts
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                KEY CALCULUS CONCEPTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │  CONCEPT          │  ML APPLICATION                        │
    ├─────────────────────────────────────────────────────────────┤
    │  Derivative       │  Rate of change of loss with weights  │
    │  Partial Deriv.   │  How each weight affects loss         │
    │  Gradient         │  Direction to reduce loss │
    │  Gradient Descent │  Learning algorithm      │
    │  Chain Rule       │  Backpropagation         │
    │  Hessian          │  Second-order optimization           │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                   KEY FORMULAS                              │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │  Derivative:       f'(x) = lim_{h→0} (f(x+h)-f(x))/h     │
    │  Gradient:         ∇f = [∂f/∂x₁, ∂f/∂x₂, ...]            │
    │  Chain Rule:       dz/dx = (dz/dy)(dy/dx)                │
    │  GD Update:        w_{t+1} = w_t - α∇L(w_t)              │
    │  Backpropagation: δ^{(l)} = (W^{(l+1)})^T δ^{(l+1)}     │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Show the key formulas. Explain that these are the foundation of learning in ML .

---

## Section 2.1: Derivatives — Measuring Change
**Slides: 34-40**

### Slide 34: What is a Derivative?
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    WHAT IS A DERIVATIVE?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                 THE ANALOGY                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Driving a car:                                            │
    │   • Speed = derivative of position                         │
    │   • Acceleration = derivative of speed                     │
    │                                                              │
    │   In ML:                                                    │
    │   • Loss = function of weights                              │
    │   • Derivative = how much loss changes with weights        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                MATHEMATICAL DEFINITION                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   f'(x) = lim_{h→0} (f(x+h) - f(x)) / h                  │
    │                                                              │
    │   Interpretations:                                          │
    │   • Slope of the tangent line                              │
    │   • Rate of change                                         │
    │   • Sensitivity of f to changes in x                      │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              ML APPLICATION                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   L(w) = (1/2n) ||Xw - y||²                               │
    │   ∂L/∂w = (1/n) X^T (Xw - y)                             │
    │                                                              │
    │   This tells us how to change w to reduce loss!            │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: The derivative is the foundation of optimization. Show the driving analogy. Explain that in ML, we're constantly computing derivatives .

### Slide 35: Numerical vs Analytical Derivatives
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            NUMERICAL VS ANALYTICAL DERIVATIVES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              NUMERICAL DERIVATIVE                           │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   f'(x) ≈ (f(x+h) - f(x-h)) / (2h)                        │
    │                                                              │
    │   PROS: Works on any function                              │
    │   CONS: Slow, numerical errors                             │
    │   USE: Gradient checking, debugging                        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              ANALYTICAL DERIVATIVE                          │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   f'(x) = exact mathematical derivative                   │
    │                                                              │
    │   PROS: Fast, exact                                       │
    │   CONS: Requires derivation, only for known functions      │
    │   USE: Production training                                 │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                   CODE                                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   # Numerical derivative                                   │
    │   Derivatives.numerical_derivative_1d(np.sin, 0)          │
    │   # 1.0                                                    │
    │                                                              │
    │   # Analytical derivative                                  │
    │   Derivatives.derivative_cos(0)  # -sin(0) = 0           │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Numerical derivatives are useful for debugging and validation. Analytical derivatives are used in production .

### Slide 36: Partial Derivatives and Gradients
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            PARTIAL DERIVATIVES AND GRADIENTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              PARTIAL DERIVATIVE                             │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ∂f/∂x_i = derivative with respect to x_i                │
    │              holding all other variables constant          │
    │                                                              │
    │   Example: f(x, y) = x² + y²                               │
    │   ∂f/∂x = 2x, ∂f/∂y = 2y                                 │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                 GRADIENT                                    │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ∇f = [∂f/∂x₁, ∂f/∂x₂, ..., ∂f/∂xₙ]                    │
    │                                                              │
    │   • Vector of all partial derivatives                       │
    │   • Points in direction of steepest ascent                 │
    │   • Negative gradient = steepest descent      │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              ML APPLICATION                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   In neural networks:                                       │
    │   • Weights: w₁, w₂, ..., wₙ                             │
    │   • Gradient: ∇L(w) = [∂L/∂w₁, ∂L/∂w₂, ...]             │
    │   • Update: w = w - α∇L(w)                               │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: The gradient is the most important concept in ML optimization. It tells us which direction to move .

### Slide 37: Common Derivative Rules in ML
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
              COMMON DERIVATIVE RULES IN ML
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              POWER RULE                                     │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   d/dx(x^n) = n·x^{n-1}                                    │
    │   Example: d/dx(x²) = 2x, d/dx(x³) = 3x²                 │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              CHAIN RULE                                     │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   d/dx(f(g(x))) = f'(g(x))·g'(x)                          │
    │                                                              │
    │   Example: d/dx((x+1)²) = 2(x+1)·1 = 2x+2                │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              DERIVATIVES OF COMMON FUNCTIONS               │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   d/dx(σ(x)) = σ(x)(1-σ(x))         # Sigmoid             │
    │   d/dx(tanh(x)) = 1 - tanh²(x)      # Tanh                │
    │   d/dx(ReLU(x)) = 1 if x>0 else 0   # ReLU               │
    │   d/dx(softmax_i) = s_i(δ_ij - s_j) # Softmax            │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: The chain rule is the foundation of backpropagation. Show how it applies to neural networks .

### Slide 38: Gradient of Common ML Functions
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            GRADIENT OF COMMON ML FUNCTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              LINEAR REGRESSION                              │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Loss: L = (1/2n) ||Xw - y||²                            │
    │   Gradient: ∇L = (1/n) X^T (Xw - y)                      │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              LOGISTIC REGRESSION                            │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Loss: L = -[y log(p) + (1-y) log(1-p)]                  │
    │   Gradient: ∇L = X^T (p - y)                              │
    │                                                              │
    │   Where p = sigmoid(Xw)                                    │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              NEURAL NETWORK LAYER                           │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Forward: z = W^T a + b, a_out = g(z)                    │
    │   Backward: δ = g'(z) ⊙ ∂L/∂a_out                        │
    │   ∂L/∂W = a δ^T, ∂L/∂b = δ                               │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: These are the gradients used in practice. Show how each is derived.

### Slide 39: Code Demo — Derivatives
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            CODE DEMO — DERIVATIVES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    >>> from src.calculus import Derivatives
    >>> from src.linear_algebra import Vector
    >>> import math
    >>> 
    >>> # Numerical derivative of square function at x=3
    >>> Derivatives.numerical_derivative_1d(lambda x: x**2, 3)
    6.000000000009876  # Should be 6
    >>> 
    >>> # Gradient of sum of squares
    >>> def f(v):
    ...     return sum(x**2 for x in v)
    >>> v = Vector([1, 2, 3])
    >>> grad = Derivatives.numerical_gradient_nd(f, v)
    >>> grad  # Should be [2, 4, 6]
    Vector([1.9999999, 4.0000000, 6.0000000])
    >>> 
    >>> # Sigmoid derivative at x=0
    >>> Derivatives.derivative_sigmoid(0)
    0.25
    >>> 
    >>> # Gradient checking
    >>> def grad_f(v):
    ...     return Vector([2*x for x in v])
    >>> Derivatives.gradient_check(f, grad_f, v)
    True

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Live demo. Show numerical derivatives, gradients, and gradient checking.

### Slide 40: Verification — Testing Derivatives
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            VERIFICATION — TESTING DERIVATIVES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    $ pytest tests/test_calculus.py -v

    ==================== test session starts ====================
    collected 9 items

    tests/test_calculus.py::TestDerivatives::test_numerical_derivative PASSED
    tests/test_calculus.py::TestDerivatives::test_gradient PASSED
    tests/test_calculus.py::TestDerivatives::test_chain_rule PASSED
    tests/test_calculus.py::TestDerivatives::test_hessian PASSED
    tests/test_calculus.py::TestDerivatives::test_gradient_check PASSED
    tests/test_calculus.py::TestDerivatives::test_activation_derivatives PASSED

    ==================== 6 passed in 0.45s ====================

    ┌─────────────────────────────────────────────────────────────┐
    │                    ✓ ALL TESTS PASS                       │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Section 2.2: Optimization — The Learning Algorithm
**Slides: 41-47**

### Slide 41: Gradient Descent Overview
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            GRADIENT DESCENT OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                 THE ANALOGY                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Imagine you're blindfolded on a mountain                │
    │   • You need to find the lowest point                     │
    │   • You feel the slope with your feet                     │
    │   • You take a step in the steepest downward direction     │
    │                                                              │
    │   That's gradient descent!                                 │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              THE ALGORITHM                                  │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   while not converged:                                     │
    │       gradient = compute_gradient(loss, weights, data)    │
    │       weights = weights - learning_rate * gradient        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              KEY INSIGHT                                    │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   This simple loop is the foundation of almost ALL        │
    │   machine learning!                                        │
    │                                                              │
    │   • Linear regression ✓                                    │
    │   • Logistic regression ✓                                  │
    │   • Neural networks ✓                                      │
    │   • Deep learning ✓                                        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Gradient descent is the most important algorithm in ML. This simple loop powers everything .

### Slide 42: Learning Rate and Convergence
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            LEARNING RATE AND CONVERGENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              LEARNING RATE (α)                              │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   w_{t+1} = w_t - α·∇L(w_t)                              │
    │                                                              │
    │   α controls the step size:                                │
    │   • Too large: overshoot, diverge                         │
    │   • Too small: slow convergence                           │
    │   • Just right: efficient learning                        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              CONVERGENCE SCENARIOS                          │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   [Learning Rate Too Large] → Loss oscillates/increases   │
    │   [Learning Rate Too Small] → Loss decreases slowly       │
    │   [Learning Rate Just Right] → Loss decreases smoothly    │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              TYPICAL VALUES                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   • Standard: 0.01, 0.001, 0.0001                         │
    │   • Start with 0.01 and adjust                            │
    │   • Use learning rate schedules for best results           │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: The learning rate is the most important hyperparameter. Show visual examples of different learning rates .

### Slide 43: Batch GD vs SGD vs Mini-Batch
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            BATCH GD vs SGD vs MINI-BATCH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              BATCH GRADIENT DESCENT                         │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Uses ALL data for each gradient step                     │
    │   • Accurate gradient                                      │
    │   • Slow for large datasets                               │
    │   • Memory intensive                                       │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              STOCHASTIC GRADIENT DESCENT (SGD)              │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Uses ONE data point for each gradient step               │
    │   • Fast updates                                           │
    │   • Noisy gradient                                         │
    │   • Can escape local minima                               │
    │   • Most common in deep learning                          │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              MINI-BATCH GRADIENT DESCENT                    │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Uses a SMALL BATCH of data for each step                │
    │   • Best of both worlds                                    │
    │   • Less noise than SGD                                    │
    │   • Faster than batch GD                                  │
    │   • Typical batch size: 32, 64, 128, 256                 │
    │   • Most practical choice!                                │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Explain the tradeoffs. Mini-batch GD is the most common in practice .

### Slide 44: Advanced Optimizers — Momentum and Adam
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            ADVANCED OPTIMIZERS — MOMENTUM AND ADAM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              GRADIENT DESCENT WITH MOMENTUM                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   v = βv + α∇L(w)                                         │
    │   w = w - v                                                │
    │                                                              │
    │   β controls momentum (typically 0.9)                      │
    │   • Accelerates through flat regions                       │
    │   • Smoother convergence                                   │
    │   • Like a ball rolling downhill                          │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              ADAM OPTIMIZER                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   m = β₁m + (1-β₁)g (momentum)                           │
    │   v = β₂v + (1-β₂)g² (adaptive LR)                       │
    │   w = w - α·m̂/(√v̂ + ε)                                  │
    │                                                              │
    │   • Most popular optimizer in deep learning               │
    │   • Combines momentum + adaptive learning rates           │
    │   • Works well for most problems                          │
    │   • β₁=0.9, β₂=0.999, ε=1e-8                            │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Momentum and Adam are the most common advanced optimizers. Explain how they improve convergence .

### Slide 45: Code Demo — Gradient Descent
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            CODE DEMO — GRADIENT DESCENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    >>> from src.calculus import GradientDescent
    >>> from src.linear_algebra import Vector
    >>> 
    >>> # Define loss: f(w) = w₁² + w₂²
    >>> def f(w):
    ...     return sum(x**2 for x in w)
    >>> 
    >>> def grad_f(w):
    ...     return Vector([2*x for x in w])
    >>> 
    >>> # Batch gradient descent
    >>> w = Vector([5.0, 3.0])
    >>> final_w, history = GradientDescent.batch_gradient_descent(
    ...     f, grad_f, w,
    ...     learning_rate=0.1,
    ...     num_iterations=100
    ... )
    >>> 
    >>> # Should converge to (0, 0)
    >>> final_w
    Vector([0.0000, 0.0000])
    >>> 
    >>> # With momentum
    >>> final_w, history = GradientDescent.gradient_descent_with_momentum(
    ...     f, grad_f, w, learning_rate=0.1, momentum=0.9
    ... )
    >>> 
    >>> # Adam optimizer
    >>> final_w, history = GradientDescent.adam_optimizer(
    ...     f, grad_f, w, learning_rate=0.1
    ... )

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Live demo. Show different optimizers converging.

### Slide 46: Learning Rate Schedules
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            LEARNING RATE SCHEDULES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              WHY CHANGE LEARNING RATE?                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   • Start with larger steps to make progress               │
    │   • Reduce steps to fine-tune at the end                   │
    │   • Helps escape local minima                              │
    │   • Leads to better convergence                           │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              COMMON SCHEDULES                               │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   • Step Decay: α_t = α₀·γ^{⌊t/T⌋}                       │
    │   • Exponential: α_t = α₀·e^{-kt}                         │
    │   • Cosine: α_t = α₀/2(1 + cos(πt/T))                    │
    │   • Warmup: α_t = α₀·min(1, t/T_w)                       │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                   CODE                                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   # Exponential decay                                       │
    │   lr = GradientDescent.exponential_decay(0.01, epoch, 0.1)│
    │                                                              │
    │   # Step decay                                              │
    │   lr = GradientDescent.step_decay(0.01, epoch, 0.5, 10)   │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Learning rate schedules are important for production training. Explain the tradeoffs .

### Slide 47: Verification — Testing Optimization
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            VERIFICATION — TESTING OPTIMIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    $ pytest tests/test_optimization.py -v

    ==================== test session starts ====================
    collected 7 items

    tests/test_optimization.py::test_batch_gradient_descent PASSED
    tests/test_optimization.py::test_momentum PASSED
    tests/test_optimization.py::test_adam PASSED
    tests/test_optimization.py::test_line_search PASSED
    tests/test_optimization.py::test_rosenbrock PASSED
    tests/test_optimization.py::test_mini_batch PASSED

    ==================== 6 passed in 1.23s ====================

    ┌─────────────────────────────────────────────────────────────┐
    │                    ✓ ALL TESTS PASS                       │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Section 2.3: Backpropagation — The Chain Rule in Action
**Slides: 48-53**

### Slide 48: The Chain Rule
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    THE CHAIN RULE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                 THE RULE                                    │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   d/dx(f(g(x))) = f'(g(x))·g'(x)                          │
    │                                                              │
    │   In words: The derivative of a composite function is      │
    │   the derivative of the outer function times the          │
    │   derivative of the inner function.                        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              INTUITION                                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   f(g(x)) = (x+1)²                                        │
    │   g(x) = x+1, f(g) = g²                                   │
    │                                                              │
    │   f'(g(x)) = 2g(x) = 2(x+1)                               │
    │   g'(x) = 1                                                │
    │   f'(x) = 2(x+1)·1 = 2x+2                                │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              WHY IT MATTERS FOR ML                          │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Neural networks are COMPOSITE functions!                 │
    │                                                              │
    │   ŷ = g₃(W₃·g₂(W₂·g₁(W₁x + b₁) + b₂) + b₃)              │
    │                                                              │
    │   The chain rule lets us compute ∂L/∂w for ALL weights!   │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: The chain rule is the mathematical foundation of backpropagation. Show how it applies to neural networks .

### Slide 49: Computational Graphs
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            COMPUTATIONAL GRAPHS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              WHAT IS A COMPUTATIONAL GRAPH?                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   A computational graph is a directed graph where:         │
    │   • Nodes = operations                                     │
    │   • Edges = data flow                                      │
    │   • Forward pass = left to right                          │
    │   • Backward pass = right to left                         │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              EXAMPLE: y = (x + 2)²                          │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   x → [+] → (y) → [²] → z                                 │
    │        ↑                                                   │
    │        2                                                   │
    │                                                              │
    │   Forward: y = x + 2, z = y²                              │
    │   Backward: dz/dy = 2y, dy/dx = 1 → dz/dx = 2y·1         │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              WHY THIS MATTERS                               │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   • Every neural network is a computational graph          │
    │   • Forward pass computes outputs                          │
    │   • Backward pass computes gradients                       │
    │   • This is what PyTorch/TensorFlow do!                   │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Computational graphs are the foundation of automatic differentiation. Show examples .

### Slide 50: Backpropagation Algorithm
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            BACKPROPAGATION ALGORITHM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              THE ANALOGY                                   │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Baking a cake:                                           │
    │   • Forward: Mix ingredients → bake → cake               │
    │   • Taste: Is it too sweet?                                │
    │   • Backward: Which ingredient to adjust?                 │
    │                                                              │
    │   Same as neural networks!                                 │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              THE ALGORITHM                                  │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   1. FORWARD PASS: Compute predictions                     │
    │      a⁰ = x                                               │
    │      zˡ = Wˡa^{l-1} + bˡ                                 │
    │      aˡ = gˡ(zˡ)                                         │
    │                                                              │
    │   2. COMPUTE LOSS: L = loss(ŷ, y)                         │
    │                                                              │
    │   3. BACKWARD PASS: Propagate error backwards             │
    │      δᴸ = ∇ₐL ⊙ g'ᴸ(zᴸ)                                  │
    │      δˡ = (W^{l+1})^T δ^{l+1} ⊙ g'ˡ(zˡ)                 │
    │      ∂L/∂Wˡ = δˡ(a^{l-1})^T                               │
    │      ∂L/∂bˡ = δˡ                                         │
    │                                                              │
    │   4. UPDATE: Wˡ = Wˡ - α·∂L/∂Wˡ                         │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Walk through the algorithm step by step. Show the matrix equations .

### Slide 51: Backpropagation Visualized
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            BACKPROPAGATION VISUALIZED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              FORWARD PASS                                   │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   x → Layer1 → Layer2 → Layer3 → ŷ                      │
    │         ↓        ↓        ↓                               │
    │        a¹       a²       a³                              │
    │                                                              │
    │   Predictions flow forward.                                 │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              LOSS COMPUTATION                               │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   x → Layer1 → Layer2 → Layer3 → ŷ → Loss               │
    │                                                              │
    │   Compare predictions to targets.                           │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              BACKWARD PASS                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   x ← Layer1 ← Layer2 ← Layer3 ← Loss                    │
    │         ↑        ↑        ↑                               │
    │        δ¹       δ²       δ³                              │
    │                                                              │
    │   Gradients flow backward.                                  │
    │   δˡ = (W^{l+1})^T δ^{l+1} ⊙ g'ˡ(zˡ)                    │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Visual representation of forward and backward passes. Show how gradients flow backward .

### Slide 52: Code Demo — Neural Network
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            CODE DEMO — NEURAL NETWORK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    >>> from src.models import NeuralNetwork
    >>> from src.linear_algebra import Matrix
    >>> 
    >>> # XOR problem
    >>> X = Matrix([[0, 0], [0, 1], [1, 0], [1, 1]])
    >>> y = Matrix([[0], [1], [1], [0]])
    >>> 
    >>> # Create network: 2 inputs → 4 hidden → 1 output
    >>> nn = NeuralNetwork(
    ...     layer_sizes=[2, 4, 1],
    ...     learning_rate=0.1,
    ...     num_epochs=200,
    ...     random_seed=42
    ... )
    >>> 
    >>> # Train
    >>> nn.fit(X, y)
    Epoch 10: loss=0.2281, accuracy=0.75
    Epoch 50: loss=0.0752, accuracy=1.00
    Epoch 100: loss=0.0451, accuracy=1.00
    >>> 
    >>> # Predict
    >>> predictions = nn.predict(X)
    >>> print(predictions)
    [0.0234, 0.9821, 0.9812, 0.0123]
    >>> 
    >>> # The network learned XOR perfectly!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Live demo of neural network training on XOR. Show how backpropagation enables learning .

### Slide 53: Verification — Testing Neural Networks
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            VERIFICATION — TESTING NEURAL NETWORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    $ pytest tests/test_neural_network.py -v

    ==================== test session starts ====================
    collected 4 items

    tests/test_neural_network.py::test_xor_problem PASSED
    tests/test_neural_network.py::test_linear_regression PASSED
    tests/test_neural_network.py::test_classification PASSED
    tests/test_neural_network.py::test_gradient_check PASSED

    ==================== 4 passed in 3.45s ====================

    ┌─────────────────────────────────────────────────────────────┐
    │                    ✓ ALL TESTS PASS                       │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

# PART 3: PROBABILITY & STATISTICS — HANDLING UNCERTAINTY

## Section 3.0: Probability Overview
**Slides: 54-56**

### Slide 54: Why Probability?
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    WHY PROBABILITY?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                 THE PROBLEM                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Data is noisy!                                           │
    │                                                              │
    │   • Measurements are imperfect                             │
    │   • Samples may not be representative                      │
    │   • Outcomes aren't always certain                         │
    │                                                              │
    │   We need a way to model UNCERTAINTY.                      │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              THE SOLUTION                                   │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Probability Theory = The Mathematics of Uncertainty       │
    │                                                              │
    │   • Quantify uncertainty (probability)                     │
    │   • Model data generation (distributions)                  │
    │   • Update beliefs (Bayesian inference)                    │
    │   • Make optimal decisions (decision theory)              │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              ML APPLICATIONS                                │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ✓ Classification (Naive Bayes)                           │
    │   ✓ Model evaluation (MLE, AIC, BIC)                      │
    │   ✓ Uncertainty quantification (confidence intervals)     │
    │   ✓ Generative models (Gaussian mixtures)                 │
    │   ✓ Bayesian optimization                                 │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Probability is how we handle uncertainty in ML. It's essential for classification, evaluation, and decision-making .

### Slide 55: Probability Roadmap
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                 PROBABILITY ROADMAP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ╭─────────────────────────────────────────────────────────────╮
    │  MODULE 1: PROBABILITY THEORY & DISTRIBUTIONS             │
    │  ─────────────────────────────────────────────────────────  │
    │  • Basic probability concepts                              │
    │  • Discrete distributions (Bernoulli, Binomial, Poisson)  │
    │  • Continuous distributions (Gaussian, Exponential)      │
    │  • Statistical moments (mean, variance)                   │
    │  [CODE: Distributions class + tests]                     │
    ├─────────────────────────────────────────────────────────────┤
    │  MODULE 2: BAYES' THEOREM & CLASSIFICATION               │
    │  ─────────────────────────────────────────────────────────  │
    │  • Conditional probability                                │
    │  • Bayes' Theorem                                         │
    │  • Naive Bayes classifier                                 │
    │  • Maximum Likelihood Estimation (MLE)                   │
    │  [CODE: Bayes, NaiveBayes, MLE]                         │
    ├─────────────────────────────────────────────────────────────┤
    │  MODULE 3: MODEL EVALUATION & BIAS-VARIANCE              │
    │  ─────────────────────────────────────────────────────────  │
    │  • Bias-variance tradeoff       │
    │  • Model selection (AIC, BIC)                            │
    │  • Cross-validation                                      │
    │  • Performance metrics                                   │
    │  [CODE: Evaluation metrics, Cross-validation]           │
    ╰─────────────────────────────────────────────────────────────╯

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Slide 56: Key Probability Concepts
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                KEY PROBABILITY CONCEPTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │  CONCEPT          │  ML APPLICATION                        │
    ├─────────────────────────────────────────────────────────────┤
    │  Probability      │  Uncertainty quantification           │
    │  Conditional P.   │  Classification (P(class|features))   │
    │  Bayes' Theorem   │  Naive Bayes, Bayesian inference      │
    │  Distributions    │  Data modeling                        │
    │  MLE              │  Parameter estimation    │
    │  Bias-Variance    │  Model selection        │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                   KEY FORMULAS                              │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │  Bayes' Rule:    P(A|B) = P(B|A)P(A)/P(B)                │
    │  Gaussian PDF:   f(x) = 1/(σ√2π)·exp(-(x-μ)²/(2σ²))     │
    │  MLE:            θ̂ = argmax_θ P(data|θ)                 │
    │  MAP:            θ̂ = argmax_θ P(θ|data)                 │
    │  Bias-Variance:  Error = Bias² + Variance + Noise        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Section 3.1: Probability Theory & Distributions
**Slides: 57-62**

### Slide 57: Basic Probability
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                BASIC PROBABILITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              DEFINITION                                     │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Probability = Measure of likelihood (0 to 1)            │
    │                                                              │
    │   • P(A) = 0: Impossible                                   │
    │   • P(A) = 1: Certain                                     │
    │   • P(A) = 0.5: Equally likely                            │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              KEY RULES                                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Complement:     P(A^c) = 1 - P(A)                       │
    │   Union:          P(A∪B) = P(A) + P(B) - P(A∩B)          │
    │   Conditional:    P(A|B) = P(A∩B)/P(B)                   │
    │   Independence:   P(A∩B) = P(A)P(B)                      │
    │   Total Prob.:    P(B) = ΣP(B|A_i)P(A_i)                 │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              EXAMPLE                                        │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Spam detection:                                          │
    │   • P(Spam) = 0.3 (prior)                                 │
    │   • P(Word|Spam) = 0.8 (likelihood)                      │
    │   • P(Word) = 0.3 (evidence)                              │
    │   • P(Spam|Word) = 0.8×0.3/0.3 = 0.8 (posterior)        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Probability fundamentals. Use the spam detection example to show Bayes' rule in action .

### Slide 58: Discrete vs Continuous Distributions
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            DISCRETE VS CONTINUOUS DISTRIBUTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              DISCRETE DISTRIBUTIONS                         │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Values are countable: 0, 1, 2, 3, ...                   │
    │                                                              │
    │   • Bernoulli: Coin flip (binary)                          │
    │   • Binomial: Number of heads in n flips                  │
    │   • Poisson: Count of rare events                         │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              CONTINUOUS DISTRIBUTIONS                       │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Values can be any number in a range                     │
    │                                                              │
    │   • Gaussian (Normal): Bell curve            │
    │   • Exponential: Time between events                      │
    │   • Uniform: Constant probability                         │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              COMMON ML DISTRIBUTIONS                        │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Gaussian: Error terms, features            │
    │   Bernoulli: Binary labels                                 │
    │   Multinomial: Multi-class labels                          │
    │   Exponential: Wait times, survival                        │
    │   Dirichlet: Topic models                                  │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Explain the difference between discrete and continuous. Show examples of each .

### Slide 59: Gaussian (Normal) Distribution
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            GAUSSIAN (NORMAL) DISTRIBUTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              THE FORMULA                                    │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   f(x|μ,σ) = (1/(σ√(2π)))·exp(-(x-μ)²/(2σ²))             │
    │                                                              │
    │   μ = mean (center of distribution)                        │
    │   σ = standard deviation (spread)                          │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                68-95-99.7 RULE                              │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   • 68% of data within μ ± 1σ                             │
    │   • 95% of data within μ ± 2σ                             │
    │   • 99.7% of data within μ ± 3σ                           │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              ML APPLICATIONS                                │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ✓ Assumption in linear regression (errors are Gaussian)  │
    │   ✓ Feature distribution (normalization)     │
    │   ✓ Prior distribution in Bayesian methods                │
    │   ✓ Central Limit Theorem basis                           │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: The Gaussian is the most important distribution in ML. Show the 68-95-99.7 rule .

### Slide 60: Bayesian Inference
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                BAYESIAN INFERENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              BAYES' THEOREM                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   P(A|B) = P(B|A)·P(A) / P(B)                            │
    │              ──────────                                    │
    │               Evidence                                     │
    │                                                              │
    │   Posterior = Likelihood × Prior / Evidence               │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              THE INTUITION                                  │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Before seeing data: We have PRIOR beliefs               │
    │   After seeing data: We update beliefs (POSTERIOR)        │
    │                                                              │
    │   Example:                                                 │
    │   • Prior: 1% of people have a disease                    │
    │   • Test: 90% accurate                                     │
    │   • Posterior: After positive test, probability           │
    │     is much higher!                                       │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              ML APPLICATIONS                                │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ✓ Naive Bayes classifier                                 │
    │   ✓ Bayesian optimization                                 │
    │   ✓ Bayesian neural networks                              │
    │   ✓ Hyperparameter tuning                                 │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Bayes' Theorem is fundamental for classification and updating beliefs. Show the medical test example .

### Slide 61: Code Demo — Distributions
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            CODE DEMO — DISTRIBUTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    >>> from src.probability import GaussianDistribution, BernoulliDistribution
    >>> from src.linear_algebra import Vector
    >>> 
    >>> # Gaussian distribution
    >>> g = GaussianDistribution(0.0, 1.0)
    >>> g.pdf(0.0)  # 0.3989 (height of bell curve at center)
    0.3989422804014327
    >>> g.cdf(0.0)  # 0.5 (50% of data below mean)
    0.5
    >>> g.sample(5)  # Random samples
    Vector([0.234, -0.847, -0.219, 1.251, 0.942])
    >>> 
    >>> # Bernoulli distribution
    >>> b = BernoulliDistribution(0.7)
    >>> b.pmf(1)  # P(X=1) = 0.7
    0.7
    >>> b.sample(10)  # Binary samples
    Vector([1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 0.0, 1.0])
    >>> 
    >>> # MLE estimation
    >>> data = Vector([1, 0, 1, 1, 0, 1, 0, 1])
    >>> from src.probability import Statistics
    >>> p = Statistics.mle_bernoulli(data)  # 5/8 = 0.625
    0.625

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Live demo. Show Gaussian and Bernoulli distributions. Demonstrate MLE estimation .

### Slide 62: Verification — Testing Distributions
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            VERIFICATION — TESTING DISTRIBUTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    $ pytest tests/test_probability.py -v

    ==================== test session starts ====================
    collected 12 items

    tests/test_probability.py::TestDistributions::test_gaussian PASSED
    tests/test_probability.py::TestDistributions::test_bernoulli PASSED
    tests/test_probability.py::TestDistributions::test_binomial PASSED
    tests/test_probability.py::TestDistributions::test_exponential PASSED
    tests/test_probability.py::TestStatistics::test_mean_variance PASSED
    tests/test_probability.py::TestStatistics::test_mle PASSED
    tests/test_probability.py::TestStatistics::test_bayes PASSED

    ==================== 7 passed in 0.56s ====================

    ┌─────────────────────────────────────────────────────────────┐
    │                    ✓ ALL TESTS PASS                       │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Section 3.2: Bayes' Theorem & Classification
**Slides: 63-68**

### Slide 63: Conditional Probability and Bayes
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            CONDITIONAL PROBABILITY AND BAYES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              CONDITIONAL PROBABILITY                        │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   P(A|B) = Probability of A given B                       │
    │                                                              │
    │   Example: P(Rain|Cloudy) = Probability of rain given     │
    │   it's cloudy. This is much higher than P(Rain)!          │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              BAYES' THEOREM                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   P(A|B) = P(B|A)·P(A) / P(B)                            │
    │                                                              │
    │   • P(A|B): Posterior (what we want)                      │
    │   • P(B|A): Likelihood (how likely B is given A)         │
    │   • P(A): Prior (our initial belief)                     │
    │   • P(B): Evidence (normalizing constant)                │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              ODDS FORM                                     │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Posterior Odds = Prior Odds × Likelihood Ratio           │
    │   P(A|B)/P(not A|B) = P(A)/P(not A) × P(B|A)/P(B|not A)  │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Conditional probability and Bayes are the foundation of classification .

### Slide 64: Naive Bayes Classifier
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                NAIVE BAYES CLASSIFIER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              THE "NAIVE" ASSUMPTION                         │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Features are INDEPENDENT given the class.                 │
    │                                                              │
    │   P(x₁, x₂, ..., xₙ|y) = P(x₁|y)·P(x₂|y)·...·P(xₙ|y)    │
    │                                                              │
    │   This is naive but WORKS IN PRACTICE!                    │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              THE ALGORITHM                                  │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   For each class c:                                        │
    │   1. Compute prior: P(c)                                  │
    │   2. Compute likelihood: P(features|c)                   │
    │   3. Compute posterior: P(c|features) ∝ P(c)·ΠP(f_i|c)  │
    │   4. Choose class with highest posterior                   │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              WHEN TO USE                                    │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ✓ Text classification (spam detection)                   │
    │   ✓ High-dimensional data                                 │
    │   ✓ Small datasets                                        │
    │   ✓ When interpretability matters                         │
    │   ✓ Quick baseline model                                 │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Naive Bayes is simple but effective. Explain the independence assumption and why it works .

### Slide 65: Gaussian Naive Bayes
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                GAUSSIAN NAIVE BAYES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              THE MODEL                                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   For each feature j and class c:                          │
    │   x_j | y=c ~ N(μ_jc, σ_jc²)                             │
    │                                                              │
    │   • μ_jc = mean of feature j in class c                   │
    │   • σ_jc² = variance of feature j in class c              │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              TRAINING                                       │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   1. Compute class priors: P(c) = n_c / n                 │
    │   2. For each class, feature:                             │
    │      μ_jc = (1/n_c) Σ_{i:y_i=c} x_ij                    │
    │      σ_jc² = (1/n_c) Σ_{i:y_i=c} (x_ij - μ_jc)²         │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              PREDICTION                                     │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   P(c|x) ∝ P(c)·Π_j (1/(σ_jc√(2π)))·exp(-(x_j-μ_jc)²/(2σ_jc²))│
    │                                                              │
    │   Choose argmax_c P(c|x)                                  │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Gaussian Naive Bayes is the most common variant for continuous features. Show the math .

### Slide 66: Code Demo — Naive Bayes
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            CODE DEMO — NAIVE BAYES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    >>> from src.probability import GaussianNaiveBayes
    >>> from src.linear_algebra import Matrix, Vector
    >>> import random
    >>> 
    >>> # Generate synthetic data: two Gaussian clusters
    >>> X_data = []
    >>> y_data = []
    >>> 
    >>> # Class 0: centered at (0, 0)
    >>> for _ in range(50):
    ...     X_data.append([random.gauss(0, 1), random.gauss(0, 1)])
    ...     y_data.append(0.0)
    >>> 
    >>> # Class 1: centered at (5, 5)
    >>> for _ in range(50):
    ...     X_data.append([random.gauss(5, 1), random.gauss(5, 1)])
    ...     y_data.append(1.0)
    >>> 
    >>> X = Matrix(X_data)
    >>> y = Vector(y_data)
    >>> 
    >>> # Train classifier
    >>> nb = GaussianNaiveBayes()
    >>> nb.fit(X, y)
    >>> 
    >>> # Predict test points
    >>> test = Matrix([[0.5, 0.5], [5.5, 5.5]])
    >>> predictions = nb.predict(test)
    >>> print(predictions)
    Vector([0.0, 1.0])  # Correct!
    >>> 
    >>> # Get probabilities
    >>> probs = nb.predict_proba(test)
    >>> print(probs)
    [[0.932, 0.068], [0.012, 0.988]]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Live demo. Show training and prediction with confidence scores.

### Slide 67: MLE vs MAP
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    MLE vs MAP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              MAXIMUM LIKELIHOOD ESTIMATION (MLE)            │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   θ̂_MLE = argmax_θ P(data|θ)                             │
    │                                                              │
    │   • Finds parameters that make data most likely           │
    │   • No prior needed                                      │
    │   • Asymptotically optimal                                │
    │   • Used in most ML algorithms               │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              MAXIMUM A POSTERIORI (MAP)                     │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   θ̂_MAP = argmax_θ P(θ|data)                              │
    │         = argmax_θ P(data|θ)·P(θ)                        │
    │                                                              │
    │   • Incorporates prior knowledge                           │
    │   • Regularizes against overfitting                       │
    │   • Bayesian approach                                     │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              WHEN TO USE                                    │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   MLE: Large data, minimal prior knowledge                │
    │   MAP: Small data, known prior, regularization            │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Explain the difference between MLE and MAP. Show how MAP corresponds to regularization .

### Slide 68: Verification — Testing Bayes
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            VERIFICATION — TESTING BAYES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    $ pytest tests/test_bayes.py -v

    ==================== test session starts ====================
    collected 6 items

    tests/test_bayes.py::test_gaussian_naive_bayes PASSED
    tests/test_bayes.py::test_bernoulli_naive_bayes PASSED
    tests/test_bayes.py::test_cross_validation PASSED
    tests/test_bayes.py::test_mle_gaussian PASSED
    tests/test_bayes.py::test_mle_linear_regression PASSED
    tests/test_bayes.py::test_bootstrap PASSED

    ==================== 6 passed in 1.23s ====================

    ┌─────────────────────────────────────────────────────────────┐
    │                    ✓ ALL TESTS PASS                       │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Section 3.3: Model Evaluation and Bias-Variance
**Slides: 69-74**

### Slide 69: The Bias-Variance Tradeoff
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            THE BIAS-VARIANCE TRADEOFF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              THE DECOMPOSITION                              │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Expected Test Error = Bias² + Variance + Noise           │
    │                                                              │
    │   • Bias: Error from oversimplifying         │
    │   • Variance: Error from overfitting         │
    │   • Noise: Irreducible error in data                      │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              THE ANALOGY                                    │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Archery:                                                  │
    │   • Low Bias = Aiming at the target                       │
    │   • Low Variance = Consistent aim                         │
    │   • Good = Low bias AND low variance                     │
    │                                                              │
    │   Machine Learning:                                        │
    │   • Underfitting = High bias, low variance               │
    │   • Overfitting = Low bias, high variance                │
    │   • Good fit = Balanced                                  │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              VISUALIZED                                    │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Model Complexity →                                        │
    │   Low (Underfit)      Optimal      High (Overfit)          │
    │   Bias:    High                    Low                     │
    │   Variance: Low                    High                    │
    │   Total Error: High    Low          High                   │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: The bias-variance tradeoff is fundamental to ML. Explain with the archery analogy .

### Slide 70: Learning Curves
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                LEARNING CURVES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              WHAT ARE LEARNING CURVES?                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Learning curves plot error vs training set size         │
    │                                                              │
    │   • Training error: Decreases with more data              │
    │   • Validation error: Decreases, then flattens           │
    │   • Gap: Difference between training and validation      │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              DIAGNOSING PROBLEMS                            │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   HIGH BIAS (Underfitting):                                │
    │   • Train error high, validation error high               │
    │   • Gap small                                             │
    │   • Solution: More complex model                         │
    │                                                              │
    │   HIGH VARIANCE (Overfitting):                            │
    │   • Train error low, validation error high               │
    │   • Gap large                                             │
    │   • Solution: More data, regularization                  │
    │                                                              │
    │   GOOD FIT:                                                │
    │   • Both errors low and converging                       │
    │   • Gap small                                             │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Learning curves help diagnose bias vs variance issues. Show examples .

### Slide 71: Cross-Validation
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                CROSS-VALIDATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              WHY CROSS-VALIDATION?                          │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   • We need to estimate performance on unseen data        │
    │   • Using the same data for training AND testing          │
    │     gives overly optimistic results                       │
    │   • Cross-validation solves this!                         │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              K-FOLD CROSS-VALIDATION                        │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   1. Split data into k folds                               │
    │   2. For each fold:                                        │
    │      • Train on k-1 folds                                  │
    │      • Validate on held-out fold                          │
    │   3. Average results                                      │
    │                                                              │
    │   [Diagram: Data split into k equal parts]                │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              TYPICAL CHOICES                                │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   k=5: Common, good balance                               │
    │   k=10: More reliable, more computation                   │
    │   k=n (LOOCV): Maximum bias, very expensive               │
    │   Stratified: Preserves class proportions                │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Cross-validation is essential for model evaluation. Show the k-fold process .

### Slide 72: Model Selection — AIC and BIC
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            MODEL SELECTION — AIC AND BIC
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              AIC (Akaike Information Criterion)             │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   AIC = -2·log(L) + 2·k                                    │
    │                                                              │
    │   • k = number of parameters                              │
    │   • L = likelihood of the model                          │
    │   • Lower AIC = better model                             │
    │   • Penalizes complexity (2k)                            │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              BIC (Bayesian Information Criterion)           │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   BIC = -2·log(L) + k·log(n)                               │
    │                                                              │
    │   • n = number of samples                                 │
    │   • Stricter penalty than AIC                            │
    │   • Lower BIC = better model                             │
    │   • Used for model comparison                            │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              AIC vs BIC                                     │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   AIC: Lower penalty, favors more complex models           │
    │   BIC: Higher penalty, favors simpler models              │
    │   AIC: Better for prediction                              │
    │   BIC: Better for explanation                            │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: AIC and BIC are used for model selection. Explain the tradeoffs .

### Slide 73: Code Demo — Evaluation
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            CODE DEMO — EVALUATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    >>> from src.probability import ModelMetrics, BiasVarianceAnalysis
    >>> from src.models import NeuralNetwork
    >>> from src.linear_algebra import Matrix, Vector
    >>> 
    >>> # Generate data
    >>> X_data = [[random.random()*10] for _ in range(200)]
    >>> y_data = [[2*x[0] + 3 + random.gauss(0, 0.5)] for x in X_data]
    >>> X = Matrix(X_data)
    >>> y = Matrix(y_data)
    >>> 
    >>> # Train model
    >>> model = NeuralNetwork([1, 4, 1], learning_rate=0.01, num_epochs=50)
    >>> model.fit(X, y)
    >>> 
    >>> # Evaluate
    >>> preds = model.predict(X)
    >>> 
    >>> mse = ModelMetrics.mse(preds.col(0), y.col(0))
    >>> r2 = ModelMetrics.r2_score(preds.col(0), y.col(0))
    >>> 
    >>> print(f"MSE: {mse:.4f}, R²: {r2:.4f}")
    MSE: 0.0234, R²: 0.9876
    >>> 
    >>> # Bias-variance analysis
    >>> result = BiasVarianceAnalysis.decompose_bias_variance(preds, y)
    >>> print(f"Bias²: {result['bias_squared']:.4f}")
    >>> print(f"Variance: {result['variance']:.4f}")

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Live demo. Show model evaluation with metrics and bias-variance analysis.

### Slide 74: Verification — Testing Evaluation
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            VERIFICATION — TESTING EVALUATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    $ pytest tests/test_evaluation.py -v

    ==================== test session starts ====================
    collected 5 items

    tests/test_evaluation.py::test_accuracy PASSED
    tests/test_evaluation.py::test_confusion_matrix PASSED
    tests/test_evaluation.py::test_precision_recall_f1 PASSED
    tests/test_evaluation.py::test_bias_variance PASSED
    tests/test_evaluation.py::test_learning_curve PASSED

    ==================== 5 passed in 0.89s ====================

    ┌─────────────────────────────────────────────────────────────┐
    │                    ✓ ALL TESTS PASS                       │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

# PART 4: APPLIED NUMERICAL METHODS — FROM MATH TO CODE

## Section 4.0: Numerical Methods Overview
**Slides: 75-77**

### Slide 75: Why Numerical Methods?
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                WHY NUMERICAL METHODS?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                 THE PROBLEM                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Math is beautiful. But computers have limits.            │
    │                                                              │
    │   • Floating point errors                                  │
    │   • Overflow/underflow                                     │
    │   • Catastrophic cancellation                              │
    │   • Ill-conditioned problems                              │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              THE SOLUTION                                   │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Numerical Methods = Math that works on computers         │
    │                                                              │
    │   • Stable algorithms                                      │
    │   • Efficient computation                                  │
    │   • Safe operations                                       │
    │   • Production-ready code                                 │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              KEY INSIGHT                                    │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   In research: "Does the math work?"                       │
    │   In production: "Does the code work on real data?"        │
    │                                                              │
    │   Numerical methods bridge this gap!                       │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Numerical methods make math work on real computers. This is the bridge between theory and practice .

### Slide 76: Numerical Methods Roadmap
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                NUMERICAL METHODS ROADMAP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ╭─────────────────────────────────────────────────────────────╮
    │  MODULE 1: NUMERICAL STABILITY                             │
    │  ─────────────────────────────────────────────────────────  │
    │  • Floating point precision                                │
    │  • Safe operations (exp, log, division)                   │
    │  • Log-sum-exp trick                                      │
    │  • Stable softmax                                         │
    │  • Gradient clipping                                      │
    │  [CODE: Stability utilities + tests]                     │
    ├─────────────────────────────────────────────────────────────┤
    │  MODULE 2: PERFORMANCE OPTIMIZATION                       │
    │  ─────────────────────────────────────────────────────────  │
    │  • Vectorization                                         │
    │  • Memory efficiency                                     │
    │  • Batch processing                                      │
    │  • Caching                                               │
    │  [CODE: Performance utilities + tests]                  │
    ├─────────────────────────────────────────────────────────────┤
    │  MODULE 3: COMPLETE PIPELINE                             │
    │  ─────────────────────────────────────────────────────────  │
    │  • End-to-end ML pipeline                                 │
    │  • Data preprocessing                                   │
    │  • Model training                                        │
    │  • Evaluation                                           │
    │  • Deployment                                           │
    │  [CODE: CompletePipeline + production scripts]         │
    ╰─────────────────────────────────────────────────────────────╯

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Slide 77: Key Numerical Concepts
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                KEY NUMERICAL CONCEPTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │  CONCEPT          │  ML APPLICATION                        │
    ├─────────────────────────────────────────────────────────────┤
    │  Log-Sum-Exp      │  Stable softmax                       │
    │  Gradient Clipping│  Stable training                      │
    │  Vectorization    │  Fast computation                    │
    │  Condition Number │  Matrix stability                    │
    │  Regularization   │  Prevent overfitting                 │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                   KEY FORMULAS                              │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │  Log-Sum-Exp:    log(Σexp(v)) = max(v) + log(Σexp(v-max))│
    │  Gradient Clip:  g = g·min(1, threshold/||g||)           │
    │  Pseudo-Inverse: A^+ = V·Σ^+·U^T                         │
    │  Ridge:          (X^T X + λI)^{-1} X^T y                │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Section 4.1: Numerical Stability
**Slides: 78-83**

### Slide 78: Floating Point Issues
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                FLOATING POINT ISSUES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              WHAT IS FLOATING POINT?                        │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Computers represent numbers in binary scientific notation│
    │                                                              │
    │   • Finite precision (32-bit or 64-bit)                    │
    │   • Cannot represent all real numbers exactly             │
    │   • Small errors accumulate!                              │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              COMMON ISSUES                                  │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   • Overflow: exp(1000) → Inf                             │
    │   • Underflow: exp(-1000) → 0                             │
    │   • Cancellation: (1+1e-16) - 1 = 0 (should be 1e-16)    │
    │   • NaN: 0/0, ∞ - ∞                                       │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              CONSEQUENCES IN ML                             │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   • Softmax: exp(large) → Inf → NaN                       │
    │   • Loss: log(0) → -Inf → NaN                            │
    │   • Gradient: vanishing/exploding                         │
    │   • Matrix inverse: singular → unstable                   │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Floating point errors are inevitable. Show examples and their impact on ML .

### Slide 79: Safe Operations
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                SAFE OPERATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              SAFE EXP                                       │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   def safe_exp(x, max_val=700):                            │
    │       if x > max_val: return exp(max_val)                 │
    │       if x < -max_val: return 0                           │
    │       return exp(x)                                       │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              SAFE LOG                                       │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   def safe_log(x, eps=1e-12):                              │
    │       return log(max(x, eps))                             │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              SAFE DIVISION                                  │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   def safe_div(a, b, eps=1e-12):                           │
    │       if abs(b) < eps:                                    │
    │           return a * (1/eps) if a >= 0 else -a * (1/eps)  │
    │       return a / b                                        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Safe operations prevent NaN and Inf. Show implementations .

### Slide 80: Log-Sum-Exp Trick
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                LOG-SUM-EXP TRICK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              THE PROBLEM                                    │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   • Need to compute: log(Σ exp(v_i))                      │
    │   • If v_i are large, exp overflows                        │
    │   • If v_i are small, exp underflows                      │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              THE SOLUTION                                   │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   log(Σ exp(v_i)) = max(v) + log(Σ exp(v_i - max(v)))     │
    │                                                              │
    │   Why it works:                                             │
    │   • v_i - max(v) ≤ 0                                      │
    │   • All exp terms are in [0, 1]                           │
    │   • No overflow!                                          │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              APPLICATION                                     │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ✓ Stable softmax                                          │
    │   ✓ Log-likelihood                                         │
    │   ✓ Cross-entropy loss                                     │
    │   ✓ Any log-of-sum                                         │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: The log-sum-exp trick is essential for numerical stability in ML .

### Slide 81: Stable Softmax
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                STABLE SOFTMAX
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              UNSTABLE SOFTMAX                               │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   def softmax(x):                                          │
    │       return exp(x) / sum(exp(x))                          │
    │                                                              │
    │   Problem: exp(100) = Inf → NaN                           │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              STABLE SOFTMAX                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   def stable_softmax(x):                                   │
    │       max_val = max(x)                                    │
    │       exp_x = exp(x - max_val)                            │
    │       return exp_x / sum(exp_x)                           │
    │                                                              │
    │   • x - max_val ≤ 0                                      │
    │   • No overflow!                                          │
    │   • Numerically stable                                   │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              WHY IT MATTERS                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   Softmax is used in:                                      │
    │   • Multi-class classification                            │
    │   • Attention mechanisms                                  │
    │   • Probability distributions                            │
    │                                                              │
    │   Stable softmax ensures it works on real data!            │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Show the difference between unstable and stable softmax. This is a common pitfall .

### Slide 82: Code Demo — Numerical Stability
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            CODE DEMO — NUMERICAL STABILITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    >>> from src.numerical import SafeMath, NumericalStability
    >>> from src.linear_algebra import Vector
    >>> import math
    >>> 
    >>> # Safe exp
    >>> SafeMath.safe_exp(1000)  # 1.0 (capped)
    1.0
    >>> 
    >>> # Safe log
    >>> SafeMath.safe_log(0)  # math.log(1e-12) = -27.63
    -27.631021115928548
    >>> 
    >>> # Log-sum-exp trick
    >>> v = Vector([100, 101, 102])
    >>> SafeMath.log_sum_exp(v)  # Stable!
    102.40760591344767
    >>> 
    >>> # Stable softmax
    >>> soft = SafeMath.stable_softmax(v)
    >>> sum(soft[i] for i in range(soft.size))  # Sums to 1
    1.0
    >>> 
    >>> # Gradient clipping
    >>> g = Vector([100, 100, 100])
    >>> clipped = NumericalStability.clip_gradient(g, max_norm=1.0)
    >>> clipped.norm(2)  # 1.0
    1.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Live demo. Show safe operations and gradient clipping in action.

### Slide 83: Verification — Testing Numerical Methods
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            VERIFICATION — TESTING NUMERICAL METHODS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    $ pytest tests/test_numerical.py -v

    ==================== test session starts ====================
    collected 8 items

    tests/test_numerical.py::test_safe_exp PASSED
    tests/test_numerical.py::test_safe_log PASSED
    tests/test_numerical.py::test_log_sum_exp PASSED
    tests/test_numerical.py::test_stable_softmax PASSED
    tests/test_numerical.py::test_gradient_clipping PASSED
    tests/test_numerical.py::test_condition_number PASSED

    ==================== 6 passed in 0.45s ====================

    ┌─────────────────────────────────────────────────────────────┐
    │                    ✓ ALL TESTS PASS                       │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Section 4.2: Complete Pipeline
**Slides: 84-90**

### Slide 84: The Complete Pipeline Architecture
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            THE COMPLETE PIPELINE ARCHITECTURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              END-TO-END ML PIPELINE                         │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌────────┐ │
    │   │  Data   │ → │  Pre-   │ → │  Model  │ → │  Eval  │ │
    │   │  Load   │    │ process │    │  Train  │    │        │ │
    │   └─────────┘    └─────────┘    └─────────┘    └────────┘ │
    │        │              │              │            │         │
    │        ↓              ↓              ↓            ↓         │
    │   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌────────┐ │
    │   │  Raw    │    │  Clean  │    │  Model  │    │  Results│ │
    │   │  Data   │    │  Data   │    │  File   │    │         │ │
    │   └─────────┘    └─────────┘    └─────────┘    └────────┘ │
    │                                                              │
    │   ┌─────────────────────────────────────────────────────┐  │
    │   │  Deployment: API Server → Docker → Cloud           │  │
    │   └─────────────────────────────────────────────────────┘  │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              COMPONENTS                                     │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   • DataPipeline: Loading, preprocessing, splitting       │
    │   • ModelPipeline: Training, validation, tuning           │
    │   • CompletePipeline: End-to-end orchestration            │
    │   • API Server: Production serving                        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Show the complete pipeline architecture. Each component handles a specific concern .

### Slide 85: Data Pipeline
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                DATA PIPELINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              DATA PIPELINE COMPONENTS                       │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   1. Loading: Read data from CSV, JSON, database          │
    │   2. Validation: Check schema, data types                │
    │   3. Missing Values: Impute or remove                    │
    │   4. Scaling: Standardize or Min-Max                    │
    │   5. Feature Engineering: Polynomial, interaction       │
    │   6. Splitting: Train, validation, test                 │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              CODE EXAMPLE                                   │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   data_pipeline = DataPipeline(random_seed=42)             │
    │                                                              │
    │   # Load and preprocess                                     │
    │   X, y = data_pipeline.load_data(data, labels)            │
    │   X = data_pipeline.handle_missing_values(X, 'mean')      │
    │   X = data_pipeline.scale_data(X, 'standardize')          │
    │                                                              │
    │   # Split                                                   │
    │   X_train, X_val, X_test, y_train, y_val, y_test =        │
    │       data_pipeline.split_data(X, y, 0.7, 0.15, 0.15)    │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Data preprocessing is often 80% of the work in ML projects .

### Slide 86: Model Pipeline
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                MODEL PIPELINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              MODEL PIPELINE COMPONENTS                      │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   1. Model Selection: Choose algorithm                     │
    │   2. Training: Fit model to data                         │
    │   3. Hyperparameter Tuning: Grid or random search         │
    │   4. Cross-validation: k-fold validation                 │
    │   5. Evaluation: Compute metrics                           │
    │   6. Persistence: Save trained model                      │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              CODE EXAMPLE                                   │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   model = NeuralNetwork([X_train.cols, 32, 1])            │
    │   model_pipeline = ModelPipeline(model)                   │
    │                                                              │
    │   # Train                                                   │
    │   train_metrics = model_pipeline.train(X_train, y_train)  │
    │                                                              │
    │   # Validate                                                │
    │   val_metrics = model_pipeline.validate(X_val, y_val)     │
    │                                                              │
    │   # Cross-validate                                          │
    │   cv_results = model_pipeline.cross_validate(X, y, k=5)  │
    │                                                              │
    │   # Save                                                    │
    │   model_pipeline.save('model.pkl')                         │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: The model pipeline orchestrates training, validation, and persistence .

### Slide 87: Complete Pipeline in Action
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            COMPLETE PIPELINE IN ACTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    >>> from src.pipeline import CompleteMLPipeline
    >>> from src.linear_algebra import Matrix
    >>> import random
    >>> 
    >>> # Generate data
    >>> X_data = [[random.random()*10 for _ in range(5)] for _ in range(1000)]
    >>> y_data = [[2*sum(x) + random.gauss(0, 0.5)] for x in X_data]
    >>> X = Matrix(X_data)
    >>> y = Matrix(y_data)
    >>> 
    >>> # Create pipeline with config
    >>> config = {
    ...     'model': {
    ...         'layer_sizes': [32, 16],
    ...         'learning_rate': 0.01,
    ...         'num_epochs': 50,
    ...         'batch_size': 32
    ...     }
    ... }
    >>> 
    >>> pipeline = CompleteMLPipeline(config)
    >>> 
    >>> # Run everything
    >>> results = pipeline.run(X, y)
    >>> 
    >>> # Print report
    >>> print(pipeline.generate_report())

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Show the complete pipeline running from end to end.

### Slide 88: Production Deployment
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                PRODUCTION DEPLOYMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              DEPLOYMENT OPTIONS                             │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   1. API Server: REST API for predictions                  │
    │   2. Batch Inference: Predict on large datasets            │
    │   3. Streaming: Real-time predictions                     │
    │   4. Embedded: On-device inference                        │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              API SERVER                                     │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   # Start the API server                                    │
    │   python -c "                                              │
    │   from src.api import serve                                │
    │   serve('models/production/latest.pkl', port=8000)       │
    │   "                                                        │
    │                                                              │
    │   # Health check                                            │
    │   curl http://localhost:8000/health                       │
    │                                                              │
    │   # Predictions                                             │
    │   curl -X POST http://localhost:8000/predict \            │
    │        -H "Content-Type: application/json" \              │
    │        -d '{"features": [[1, 2, 3, 4, 5]]}'              │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Show how to deploy the model as an API server .

### Slide 89: Docker and Containerization
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            DOCKER AND CONTAINERIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              DOCKERFILE                                     │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   FROM python:3.9-slim                                    │
    │   WORKDIR /app                                            │
    │   COPY requirements.txt .                                 │
    │   RUN pip install -r requirements.txt                    │
    │   COPY src/ ./src/                                       │
    │   COPY scripts/ ./scripts/                               │
    │   COPY config.yaml ./                                    │
    │   EXPOSE 8000                                            │
    │   CMD ["python", "scripts/run_pipeline.py"]             │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              DOCKER COMMANDS                                │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   # Build image                                             │
    │   docker build -t ml-mathematics .                         │
    │                                                              │
    │   # Run container                                           │
    │   docker run -p 8000:8000 ml-mathematics                   │
    │                                                              │
    │   # With data volume                                        │
    │   docker run -v $(pwd)/data:/app/data ml-mathematics       │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Docker makes deployment reproducible. Show the Dockerfile .

### Slide 90: CI/CD Pipeline
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                CI/CD PIPELINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              GITHUB ACTIONS WORKFLOW                        │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   name: CI/CD Pipeline                                     │
    │                                                              │
    │   on: push to main                                        │
    │                                                              │
    │   jobs:                                                    │
    │     test:                                                  │
    │       runs-on: ubuntu-latest                              │
    │       steps:                                              │
    │         - checkout code                                    │
    │         - install dependencies                             │
    │         - run tests                                        │
    │         - check coverage                                   │
    │                                                              │
    │     build:                                                 │
    │       needs: test                                         │
    │       steps:                                              │
    │         - build Docker image                              │
    │         - push to registry                                │
    │                                                              │
    │     deploy:                                                │
    │       needs: build                                        │
    │       steps:                                              │
    │         - deploy to production                            │
    │         - run health checks                               │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: CI/CD automates testing and deployment. Show the workflow .

---

# PART 5: COURSE CONCLUSION & RESOURCES

## Section 5.0: Summary and Next Steps
**Slides: 91-95**

### Slide 91: What You've Built
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                WHAT YOU'VE BUILT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              COMPLETE ML SYSTEM                             │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   ✅ Linear Algebra: Vectors, Matrices, Tensors            │
    │   ✅ Calculus: Derivatives, Gradients, Backprop           │
    │   ✅ Probability: Distributions, Bayes, MLE               │
    │   ✅ Numerical Methods: Stability, Performance            │
    │   ✅ Neural Networks: From scratch                       │
    │   ✅ Complete Pipeline: End-to-end system                │
    │   ✅ Production: API, Docker, CI/CD                      │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              45+ FILES | 10,000+ LINES | 80+ TESTS        │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   This is a PRODUCTION-READY ML system!                    │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Instructor Notes**: Recap what students have built. This is a significant accomplishment .

### Slide 92: Key Skills Acquired
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                KEY SKILLS ACQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │  SKILL                  │  WHAT YOU CAN NOW DO             │
    ├─────────────────────────────────────────────────────────────┤
    │  Linear Algebra         │  Implement any matrix op, PCA   │
    │  Calculus               │  Compute gradients, optimize    │
    │  Probability            │  Build Bayesian models         │
    │  Neural Networks        │  Build and train from scratch  │
    │  Production ML          │  Deploy and monitor models     │
    │  System Design          │  Build end-to-end pipelines    │
    │  Debugging              │  Find and fix numerical issues │
    │  Performance            │  Optimize ML code             │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                    KEY INSIGHT                              │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   You are now a Machine Learning Engineer —                │
    │   not just a user of ML, but someone who can build it!    │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Slide 93: Where to Go From Here
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                WHERE TO GO FROM HERE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │               NEXT STEPS                                    │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   1. 📚 Deepen Your Knowledge                              │
    │      • Read research papers                               │
    │      • Implement new algorithms                           │
    │      • Study advanced topics                              │
    │                                                              │
    │   2. 🚀 Build Projects                                     │
    │      • Apply skills to real problems                     │
    │      • Build end-to-end solutions                        │
    │      • Contribute to open source                         │
    │                                                              │
    │   3. 🎯 Specialize                                         │
    │      • Deep Learning                                      │
    │      • NLP                                                │
    │      • Computer Vision                                    │
    │      • Reinforcement Learning                             │
    │                                                              │
    │   4. 🌟 Stay Curious                                       │
    │      • Follow ML research                                │
    │      • Join ML communities                               │
    │      • Teach others                                      │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Slide 94: Recommended Resources
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                RECOMMENDED RESOURCES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │              BOOKS                                          │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   📖 "Mathematics for Machine Learning" - Deisenroth       │
    │   📖 "Deep Learning" - Goodfellow, Bengio, Courville      │
    │   📖 "Pattern Recognition and ML" - Bishop                │
    │   📖 "Elements of Statistical Learning" - Hastie et al.   │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              ONLINE COURSES                                 │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   • Coursera: Mathematics for Machine Learning             │
    │   • DeepLearning.AI: Deep Learning Specialization         │
    │   • Fast.ai: Practical Deep Learning                     │
    │   • Stanford CS229: Machine Learning                     │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │              COMMUNITIES                                    │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │   • r/MachineLearning                                     │
    │   • r/learnmachinelearning                               │
    │   • Kaggle                                               │
    │   • GitHub                                                │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Slide 95: Thank You!
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    THANK YOU!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │                                                              │
    │           🎉 Congratulations! 🎉                            │
    │                                                              │
    │     You've completed the journey from mathematical         │
    │       theory to production-ready code!                     │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                                                              │
    │   Remember:                                                 │
    │   • Understanding > Memorizing                             │
    │   • First principles > Black boxes                         │
    │   • Production > Prototypes                                │
    │   • Keep learning, keep building!                         │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                                                              │
    │         📧 Questions? Connect with the community!          │
    │         🌐 https://github.com/[your-repo]                 │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

# APPENDICES (Reference Slides)

## Appendix A: Mathematical Notation Reference
**Slides: A1-A5**

### A1: Common Mathematical Symbols
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            COMMON MATHEMATICAL SYMBOLS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │  SYMBOL     │  NAME              │  MEANING                │
    ├─────────────────────────────────────────────────────────────┤
    │  ∈          │  Element of        │  x ∈ ℝ                 │
    │  ℝ          │  Real numbers      │  All real numbers      │
    │  Σ          │  Summation         │  Sum over indices      │
    │  Π          │  Product           │  Product over indices  │
    │  ∂          │  Partial derivative│  ∂f/∂x                 │
    │  ∇          │  Gradient          │  Vector of derivatives│
    │  σ          │  Sigma             │  Standard deviation    │
    │  μ          │  Mu                │  Mean                  │
    │  λ          │  Lambda            │  Regularization        │
    │  θ          │  Theta             │  Parameters            │
    └─────────────────────────────────────────────────────────────┘
```

## Appendix B: Linear Algebra Reference
**Slides: B1-B5**

### B1: Vector Operations Quick Reference
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            VECTOR OPERATIONS QUICK REFERENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │  OPERATION     │  FORMULA                     │  CODE      │
    ├─────────────────────────────────────────────────────────────┤
    │  Dot Product   │  u·v = Σ u_i v_i            │  u.dot(v)  │
    │  L2 Norm       │  ||v||₂ = √(Σ v_i²)        │  v.norm(2) │
    │  L1 Norm       │  ||v||₁ = Σ|v_i|           │  v.norm(1) │
    │  Distance      │  ||u-v||₂                  │  u.dist(v) │
    │  Normalization │  v̂ = v/||v||₂              │  v.norm()  │
    └─────────────────────────────────────────────────────────────┘
```

## Appendix C: Calculus Reference
**Slides: C1-C5**

### C1: Derivative Rules Quick Reference
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            DERIVATIVE RULES QUICK REFERENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │  RULE            │  FORMULA                                 │
    ├─────────────────────────────────────────────────────────────┤
    │  Power           │  d/dx(x^n) = n·x^{n-1}                 │
    │  Chain           │  d/dx(f(g(x))) = f'(g(x))·g'(x)       │
    │  Product         │  d/dx(f·g) = f'·g + f·g'              │
    │  Sigmoid         │  d/dx(σ) = σ(1-σ)                     │
    │  Tanh            │  d/dx(tanh) = 1-tanh²                  │
    │  ReLU            │  d/dx(ReLU) = 1 if x>0 else 0        │
    └─────────────────────────────────────────────────────────────┘
```

## Appendix D: Probability Reference
**Slides: D1-D5**

### D1: Key Probability Formulas
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            KEY PROBABILITY FORMULAS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ┌─────────────────────────────────────────────────────────────┐
    │  RULE            │  FORMULA                                 │
    ├─────────────────────────────────────────────────────────────┤
    │  Bayes           │  P(A|B) = P(B|A)P(A)/P(B)              │
    │  Gaussian PDF    │  f(x) = 1/(σ√2π)·exp(-(x-μ)²/(2σ²))   │
    │  Entropy         │  H(P) = -Σ p_i log(p_i)               │
    │  KL Divergence   │  D_KL(P||Q) = Σ p_i log(p_i/q_i)      │
    │  MLE             │  θ̂ = argmax_θ P(data|θ)              │
    └─────────────────────────────────────────────────────────────┘
```

---

**[END OF SLIDE OUTLINE]**

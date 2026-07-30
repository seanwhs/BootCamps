# References and Resources: Beneath the Surface — Demystifying LLMs, Transformers, and Distillation

## Comprehensive Reference Guide for Further Learning

---

# HOW TO USE THIS REFERENCE GUIDE

This reference guide contains:
- **📚 Core Papers** - Foundational research papers you should read
- **📖 Books** - Recommended books for deeper understanding
- **🌐 Online Resources** - Websites, blogs, and tutorials
- **🔧 Libraries & Tools** - Production-ready implementations
- **🎓 Courses** - Structured learning opportunities
- **📊 Datasets** - Training and evaluation data
- **🖥️ JavaScript Resources** - AI/ML in JavaScript ecosystem
- **📝 Cheat Sheets** - Quick reference summaries
- **🤝 Communities** - Where to connect with others
- **📋 Glossary** - Complete term reference

---

# SECTION 1: CORE RESEARCH PAPERS

## Foundational Papers (Must Read)

### Attention and Transformers

**1. "Attention Is All You Need" (2017)**
- **Authors**: Vaswani et al.
- **Conference**: NeurIPS 2017
- **Significance**: Introduced the Transformer architecture, replaced RNNs/LSTMs
- **Key Concepts**: Self-attention, multi-head attention, positional encodings
- **Citation**: Vaswani, A., et al. (2017). Attention is all you need. Advances in Neural Information Processing Systems, 30.
- **Link**: https://arxiv.org/abs/1706.03762
- **Why Read**: This is the paper that started it all. Understanding this paper is essential for understanding modern LLMs.

**2. "BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding" (2018)**
- **Authors**: Devlin et al.
- **Conference**: NAACL 2018
- **Significance**: Introduced bidirectional pre-training, masked language modeling
- **Key Concepts**: MLM, NSP, bidirectional attention
- **Citation**: Devlin, J., et al. (2018). BERT: Pre-training of deep bidirectional transformers for language understanding. arXiv preprint arXiv:1810.04805.
- **Link**: https://arxiv.org/abs/1810.04805
- **Why Read**: Understand how bidirectional pre-training works and why it was revolutionary.

**3. "Language Models are Few-Shot Learners" (GPT-3) (2020)**
- **Authors**: Brown et al.
- **Conference**: NeurIPS 2020
- **Significance**: Showed scaling laws, few-shot learning capabilities
- **Key Concepts**: Scaling laws, in-context learning, few-shot prompting
- **Citation**: Brown, T. B., et al. (2020). Language models are few-shot learners. Advances in Neural Information Processing Systems, 33.
- **Link**: https://arxiv.org/abs/2005.14165
- **Why Read**: Understand the power of scaling and why larger models perform better.

### Knowledge Distillation

**4. "Distilling the Knowledge in a Neural Network" (2015)**
- **Authors**: Hinton, Vinyals, Dean
- **Conference**: NIPS 2014 Workshop
- **Significance**: Introduced knowledge distillation, soft targets, temperature
- **Key Concepts**: Teacher-student, soft targets, dark knowledge, temperature
- **Citation**: Hinton, G., Vinyals, O., & Dean, J. (2015). Distilling the knowledge in a neural network. arXiv preprint arXiv:1503.02531.
- **Link**: https://arxiv.org/abs/1503.02531
- **Why Read**: This is the foundational paper on distillation that we built upon in Part 3.

### Advanced Topics

**5. "LoRA: Low-Rank Adaptation of Large Language Models" (2021)**
- **Authors**: Hu et al.
- **Conference**: ICLR 2022
- **Significance**: Efficient fine-tuning of large models
- **Key Concepts**: Low-rank adaptation, parameter-efficient fine-tuning
- **Citation**: Hu, E. J., et al. (2021). LoRA: Low-rank adaptation of large language models. arXiv preprint arXiv:2106.09685.
- **Link**: https://arxiv.org/abs/2106.09685
- **Why Read**: Learn how to fine-tune large models efficiently.

**6. "FlashAttention: Fast and Memory-Efficient Exact Attention" (2022)**
- **Authors**: Dao et al.
- **Conference**: NeurIPS 2022
- **Significance**: IO-aware attention implementation
- **Key Concepts**: Tiling, recomputation, IO-awareness
- **Citation**: Dao, T., et al. (2022). FlashAttention: Fast and memory-efficient exact attention with IO-awareness. Advances in Neural Information Processing Systems, 35.
- **Link**: https://arxiv.org/abs/2205.14135
- **Why Read**: Understand how to implement attention efficiently for production.

**7. "QLoRA: Efficient Finetuning of Quantized LLMs" (2023)**
- **Authors**: Dettmers et al.
- **Conference**: NeurIPS 2023
- **Significance**: Quantization + LoRA for efficient fine-tuning
- **Key Concepts**: 4-bit quantization, NF4, double quantization
- **Citation**: Dettmers, T., et al. (2023). QLoRA: Efficient finetuning of quantized LLMs. arXiv preprint arXiv:2305.14314.
- **Link**: https://arxiv.org/abs/2305.14314
- **Why Read**: Learn how to combine quantization and fine-tuning.

---

## Survey Papers (Broader Context)

**8. "A Survey of Large Language Models" (2023)**
- **Authors**: Zhao et al.
- **Journal**: arXiv preprint
- **Significance**: Comprehensive survey of LLMs
- **Key Concepts**: Architecture, training, evaluation, applications
- **Link**: https://arxiv.org/abs/2303.18223

**9. "Transformers in Vision: A Survey" (2022)**
- **Authors**: Khan et al.
- **Journal**: ACM Computing Surveys
- **Significance**: Transformer applications in computer vision
- **Link**: https://arxiv.org/abs/2101.01169

**10. "Efficient Transformers: A Survey" (2020)**
- **Authors**: Tay et al.
- **Conference**: ACM Computing Surveys
- **Significance**: Efficiency improvements for transformers
- **Link**: https://arxiv.org/abs/2009.06732

---

# SECTION 2: BOOKS

## Deep Learning Fundamentals

**1. "Deep Learning" by Ian Goodfellow, Yoshua Bengio, Aaron Courville**
- **Year**: 2016
- **Publisher**: MIT Press
- **Significance**: The "Deep Learning Bible" - comprehensive coverage
- **Key Topics**: Neural networks, backpropagation, optimization, CNNs, RNNs
- **Link**: https://www.deeplearningbook.org/
- **Difficulty**: Advanced
- **Why Read**: The definitive textbook on deep learning.

**2. "Pattern Recognition and Machine Learning" by Christopher Bishop**
- **Year**: 2006
- **Publisher**: Springer
- **Significance**: Classic textbook on ML fundamentals
- **Key Topics**: Probability, distributions, linear models, neural networks
- **Difficulty**: Intermediate-Advanced

**3. "Machine Learning: A Probabilistic Perspective" by Kevin Murphy**
- **Year**: 2012
- **Publisher**: MIT Press
- **Significance**: Comprehensive ML textbook
- **Key Topics**: Bayesian methods, graphical models, deep learning
- **Difficulty**: Advanced

## NLP and Transformers

**4. "Speech and Language Processing" by Daniel Jurafsky, James H. Martin**
- **Year**: 2023 (3rd Edition)
- **Publisher**: Stanford University
- **Significance**: The NLP "Bible" - comprehensive coverage
- **Key Topics**: Tokenization, language modeling, transformers, generation
- **Link**: https://web.stanford.edu/~jurafsky/slp3/
- **Difficulty**: Intermediate
- **Why Read**: The most comprehensive NLP textbook available.

**5. "Transformers for Natural Language Processing" by Denis Rothman**
- **Year**: 2021
- **Publisher**: Packt Publishing
- **Significance**: Practical transformer implementation guide
- **Key Topics**: BERT, GPT, T5, attention mechanisms
- **Difficulty**: Beginner-Intermediate

**6. "Natural Language Processing with Transformers" by Lewis Tunstall, Leandro von Werra, Thomas Wolf**
- **Year**: 2022
- **Publisher**: O'Reilly Media
- **Significance**: Practical transformers with Hugging Face
- **Key Topics**: Hugging Face, transformers, fine-tuning, deployment
- **Difficulty**: Intermediate

## JavaScript and AI

**7. "JavaScript for Machine Learning" by Daniel Pressel**
- **Year**: 2022
- **Publisher**: O'Reilly Media
- **Significance**: ML in JavaScript ecosystem
- **Key Topics**: TensorFlow.js, ML basics, deployment
- **Difficulty**: Intermediate

**8. "Practical Machine Learning in JavaScript" by Charlie Gerard**
- **Year**: 2021
- **Publisher**: Manning Publications
- **Significance**: Hands-on JS ML projects
- **Key Topics**: TensorFlow.js, mobile ML, browser ML
- **Difficulty**: Intermediate

---

# SECTION 3: ONLINE RESOURCES

## Tutorials and Courses

### Free Resources

**1. Hugging Face Course**
- **URL**: https://huggingface.co/learn/nlp-course
- **Content**: Transformers, fine-tuning, NLP tasks
- **Format**: Interactive tutorials with code
- **Difficulty**: Beginner-Intermediate

**2. Stanford CS224N: NLP with Deep Learning**
- **URL**: https://web.stanford.edu/class/cs224n/
- **Content**: NLP fundamentals, transformers, pre-training
- **Format**: Video lectures, slides, assignments
- **Difficulty**: Advanced

**3. Fast.ai Practical Deep Learning**
- **URL**: https://course.fast.ai/
- **Content**: Practical deep learning, top-down approach
- **Format**: Video lectures, code notebooks
- **Difficulty**: Beginner-Intermediate

**4. CS25: Transformers United**
- **URL**: https://web.stanford.edu/class/cs25/
- **Content**: Comprehensive transformer course
- **Format**: Video lectures, readings
- **Difficulty**: Advanced

**5. The Illustrated Transformer**
- **URL**: https://jalammar.github.io/illustrated-transformer/
- **Content**: Visual explanation of transformers
- **Format**: Blog post with illustrations
- **Difficulty**: Beginner

**6. The Annotated Transformer**
- **URL**: https://nlp.seas.harvard.edu/2018/04/03/attention.html
- **Content**: Complete transformer implementation with comments
- **Format**: Code walkthrough
- **Difficulty**: Intermediate

### Paid Resources

**7. DeepLearning.AI Courses**
- **URL**: https://www.deeplearning.ai/
- **Content**: NLP, transformers, LLM courses
- **Format**: Video lectures, assignments
- **Difficulty**: Intermediate

**8. OpenAI Developer Resources**
- **URL**: https://platform.openai.com/docs
- **Content**: API documentation, best practices
- **Format**: Documentation, tutorials
- **Difficulty**: Beginner-Intermediate

---

## Blogs and Publications

**9. Distill.pub**
- **URL**: https://distill.pub/
- **Content**: Interactive, visual ML explanations
- **Key Articles**: "Attention and Augmented Recurrent Neural Networks", "Visualizing Neural Networks"
- **Format**: Interactive articles

**10. Jay Alammar's Blog**
- **URL**: https://jalammar.github.io/
- **Content**: Visual explanations of ML concepts
- **Key Articles**: "The Illustrated Transformer", "The Illustrated BERT", "The Illustrated GPT-2"
- **Format**: Blog posts with illustrations

**11. Lilian Weng's Blog**
- **URL**: https://lilianweng.github.io/
- **Content**: Deep learning, NLP, LLMs
- **Key Articles**: "Attention? Attention!", "The Transformer Family", "Prompt Engineering"
- **Format**: Technical blog posts

**12. Andrej Karpathy's Blog**
- **URL**: https://karpathy.ai/
- **Content**: AI, ML, deep learning
- **Key Articles**: "A Recipe for Training Neural Networks", "The Unreasonable Effectiveness of RNNs"
- **Format**: Blog posts

**13. Hugging Face Blog**
- **URL**: https://huggingface.co/blog
- **Content**: Latest NLP research, tutorials
- **Format**: Technical blog posts

**14. OpenAI Blog**
- **URL**: https://openai.com/blog
- **Content**: Research announcements, technical insights
- **Format**: Blog posts

---

# SECTION 4: LIBRARIES AND TOOLS

## JavaScript/Node.js Libraries

### Core Libraries

**1. Transformers.js**
- **URL**: https://github.com/xenova/transformers.js
- **Description**: Hugging Face transformers in JavaScript
- **Features**: Pre-trained models, tokenization, generation
- **Install**: `npm install @xenova/transformers`
- **Usage**: Browser and Node.js

**2. TensorFlow.js**
- **URL**: https://www.tensorflow.org/js
- **Description**: Google's ML library for JavaScript
- **Features**: Deep learning, training, inference
- **Install**: `npm install @tensorflow/tfjs`
- **Usage**: Browser and Node.js

**3. ONNX Runtime Web**
- **URL**: https://onnxruntime.ai/
- **Description**: Cross-platform inference
- **Features**: Model optimization, quantization
- **Install**: `npm install onnxruntime-node`
- **Usage**: Node.js

**4. WebLLM**
- **URL**: https://github.com/mlc-ai/web-llm
- **Description**: Run LLMs in the browser
- **Features**: WebGPU, WebAssembly
- **Usage**: Browser

### Utility Libraries

**5. NumJS**
- **URL**: https://github.com/nicolaspanel/numjs
- **Description**: NumPy-like arrays for JavaScript
- **Features**: N-dimensional arrays, math operations
- **Install**: `npm install numjs`

**6. ndarray**
- **URL**: https://github.com/scijs/ndarray
- **Description**: N-dimensional arrays
- **Features**: Flexible array operations
- **Install**: `npm install ndarray`

**7. MathJS**
- **URL**: https://mathjs.org/
- **Description**: Comprehensive math library
- **Features**: Matrices, statistics, probability
- **Install**: `npm install mathjs`

---

## Python Libraries (for Reference)

**8. Hugging Face Transformers**
- **URL**: https://github.com/huggingface/transformers
- **Description**: The most popular transformers library
- **Features**: Pre-trained models, tokenizers, pipelines

**9. PyTorch**
- **URL**: https://pytorch.org/
- **Description**: Deep learning framework
- **Features**: Automatic differentiation, GPU acceleration

**10. TensorFlow**
- **URL**: https://www.tensorflow.org/
- **Description**: Google's deep learning framework
- **Features**: Keras, distributed training

**11. ONNX**
- **URL**: https://onnx.ai/
- **Description**: Open Neural Network Exchange
- **Features**: Model interoperability, optimization

---

## Infrastructure Tools

**12. vLLM**
- **URL**: https://github.com/vllm-project/vllm
- **Description**: High-throughput LLM serving
- **Features**: Paged attention, continuous batching

**13. Text Generation Inference (TGI)**
- **URL**: https://github.com/huggingface/text-generation-inference
- **Description**: Production LLM serving
- **Features**: Hugging Face optimized serving

**14. Llama.cpp**
- **URL**: https://github.com/ggerganov/llama.cpp
- **Description**: Efficient LLM inference in C++
- **Features**: Quantization, CPU inference

**15. Ollama**
- **URL**: https://ollama.ai/
- **Description**: Local LLM deployment
- **Features**: Easy model management

**16. LangChain.js**
- **URL**: https://github.com/hwchase17/langchainjs
- **Description**: LLM application development
- **Features**: Chains, agents, memory

---

# SECTION 5: DATASETS

## Pre-training Datasets

**1. Common Crawl**
- **URL**: https://commoncrawl.org/
- **Description**: Web crawl data (petabytes)
- **Use Case**: Large-scale pre-training

**2. The Pile**
- **URL**: https://pile.eleuther.ai/
- **Description**: 825GB of diverse text
- **Use Case**: Pre-training, research

**3. C4 (Colossal Clean Crawled Corpus)**
- **URL**: https://www.tensorflow.org/datasets/catalog/c4
- **Description**: Cleaned Common Crawl
- **Use Case**: Pre-training

**4. BookCorpus**
- **URL**: Various sources
- **Description**: 11,000+ free books
- **Use Case**: Pre-training

## Fine-tuning Datasets

**5. SQuAD (Stanford Question Answering Dataset)**
- **URL**: https://rajpurkar.github.io/SQuAD-explorer/
- **Description**: Question answering dataset
- **Use Case**: QA fine-tuning

**6. GLUE Benchmark**
- **URL**: https://gluebenchmark.com/
- **Description**: 9 NLU tasks
- **Use Case**: NLU evaluation

**7. SuperGLUE**
- **URL**: https://super.gluebenchmark.com/
- **Description**: Advanced NLU benchmark
- **Use Case**: NLU evaluation

**8. Stanford Natural Language Inference (SNLI)**
- **URL**: https://nlp.stanford.edu/projects/snli/
- **Description**: NLI dataset
- **Use Case**: NLI training

**9. MultiNLI**
- **URL**: https://cims.nyu.edu/~sbowman/multinli/
- **Description**: NLI dataset
- **Use Case**: NLI training

## Instruction Tuning Datasets

**10. OpenAssistant Conversations**
- **URL**: https://huggingface.co/datasets/OpenAssistant/oasst1
- **Description**: Human conversations
- **Use Case**: Instruction tuning

**11. Alpaca Dataset**
- **URL**: https://github.com/tatsu-lab/stanford_alpaca
- **Description**: 52K instruction-following examples
- **Use Case**: Instruction tuning

**12. Dolly Dataset**
- **URL**: https://huggingface.co/datasets/databricks/databricks-dolly-15k
- **Description**: 15K instruction examples
- **Use Case**: Instruction tuning

---

# SECTION 6: JAVASCRIPT AI/ML RESOURCES

## Tutorials and Guides

**1. TensorFlow.js Tutorials**
- **URL**: https://www.tensorflow.org/js/tutorials
- **Content**: Hands-on TF.js tutorials

**2. Transformers.js Examples**
- **URL**: https://github.com/xenova/transformers.js/tree/main/examples
- **Content**: Complete transformer examples

**3. Machine Learning for Web Developers**
- **URL**: https://developers.google.com/machine-learning/crash-course
- **Content**: ML fundamentals for web devs

**4. The AI in JavaScript Series**
- **URL**: Various sources
- **Content**: Comprehensive JS AI tutorial

## Code Repositories

**5. Awesome AI/ML in JavaScript**
- **URL**: https://github.com/ascorbic/awesome-js-ai
- **Content**: Curated list of JS AI resources

**6. ML5.js**
- **URL**: https://ml5js.org/
- **Description**: Friendly ML library for creative coding

**7. Brain.js**
- **URL**: https://brain.js.org/
- **Description**: Neural network library

**8. Node.js AI Examples**
- **URL**: Various GitHub repos
- **Description**: Production-ready examples

---

# SECTION 7: COMMUNITIES

## Online Communities

### General AI/ML

**1. Hugging Face Community**
- **URL**: https://huggingface.co/community
- **Focus**: NLP, transformers, LLMs
- **Format**: Discussions, models, spaces

**2. r/MachineLearning**
- **URL**: https://www.reddit.com/r/MachineLearning/
- **Focus**: ML research, news, discussions
- **Format**: Reddit

**3. r/LocalLLaMA**
- **URL**: https://www.reddit.com/r/LocalLLaMA/
- **Focus**: Local LLM deployment
- **Format**: Reddit

**4. AI Stack Exchange**
- **URL**: https://ai.stackexchange.com/
- **Focus**: Q&A for AI
- **Format**: Q&A

### JavaScript AI/ML

**5. TensorFlow.js Community**
- **URL**: https://github.com/tensorflow/tfjs/discussions
- **Focus**: TF.js discussions
- **Format**: GitHub discussions

**6. Transformers.js Discord**
- **URL**: https://discord.com/invite/hugging-face
- **Focus**: Transformers in JS
- **Format**: Discord

**7. Node.js AI Discord**
- **URL**: Various
- **Focus**: AI/ML in Node.js
- **Format**: Discord

## Events and Conferences

**8. NeurIPS**
- **URL**: https://neurips.cc/
- **Focus**: ML research
- **Format**: Conference

**9. ICML**
- **URL**: https://icml.cc/
- **Focus**: ML research
- **Format**: Conference

**10. ICLR**
- **URL**: https://iclr.cc/
- **Focus**: ML research
- **Format**: Conference

**11. EMNLP**
- **URL**: https://emnlp.org/
- **Focus**: NLP research
- **Format**: Conference

**12. ACL**
- **URL**: https://www.aclweb.org/
- **Focus**: NLP research
- **Format**: Conference

---

# SECTION 8: CHEAT SHEETS

## Mathematics Cheat Sheet

```
┌─────────────────────────────────────────────────────────────┐
│  LINEAR ALGEBRA                                             │
├─────────────────────────────────────────────────────────────┤
│  Vector: [v₁, v₂, ..., vₙ]                                │
│  Dot Product: v·w = ∑ vᵢwᵢ                                │
│  Norm: ||v|| = √(∑ vᵢ²)                                   │
│  Cosine Similarity: cos(θ) = (v·w)/(||v||·||w||)          │
│  Matrix Multiplication: (A×B)ᵢⱼ = ∑ Aᵢₖ Bₖⱼ              │
│  Transpose: (Aᵀ)ᵢⱼ = Aⱼᵢ                                  │
│                                                              │
│  PROBABILITY                                                 │
│  P(A) = favorable / total                                   │
│  P(A|B) = P(A∩B) / P(B)                                    │
│  Entropy: H(X) = -∑ P(x) log P(x)                          │
│  KL Divergence: D_KL(P||Q) = ∑ P(x) log(P(x)/Q(x))        │
│  Cross-Entropy: H(P,Q) = -∑ P(x) log Q(x)                 │
│                                                              │
│  ATTENTION                                                   │
│  Attention(Q,K,V) = softmax(QK^T/√d_k)V                    │
│  Multi-Head: Concat(head₁,...,headₕ)W_O                    │
│                                                              │
│  DISTILLATION                                                │
│  L = α·D_KL(P_T||P_S) + (1-α)·CE(y_true, P_S)            │
│  p_i = exp(z_i/T) / ∑ exp(z_j/T)                           │
└─────────────────────────────────────────────────────────────┘
```

---

# SECTION 9: GLOSSARY

## Complete Term Reference

### A

**Attention**: A mechanism that allows a model to focus on relevant parts of the input when making predictions. Computes relevance between tokens using Query, Key, Value matrices.

**Autoregressive**: Generating output token by token, where each new token depends on all previous tokens. Used in GPT-style models.

### B

**Batch Size**: The number of examples processed together in a single training step. Affects training stability and memory usage.

**BPE (Byte-Pair Encoding)**: A tokenization algorithm that iteratively merges the most frequent adjacent token pairs to create subword units. Balances vocabulary size and coverage.

### C

**Causal Mask**: A mask that prevents tokens from attending to future tokens in the sequence. Used in decoder-only transformers for autoregressive generation.

**Cross-Attention**: Attention where queries come from one sequence (decoder) and keys/values come from another (encoder). Used in encoder-decoder architectures.

**Cross-Entropy**: A loss function that measures the difference between two probability distributions. Used as supervised loss in classification.

**Cosine Similarity**: A measure of similarity between two vectors based on the cosine of the angle between them. Range: -1 to 1.

### D

**Dark Knowledge**: The rich information in soft targets that reveals relationships between classes. Helps students generalize better.

**Decoder-Only**: A transformer architecture that uses only the decoder stack. Used in GPT, Llama, and most modern LLMs.

**Distillation**: Training a smaller model (student) to mimic a larger model's (teacher) behavior using soft targets.

**Dropout**: A regularization technique that randomly drops neurons during training to prevent overfitting.

### E

**Embedding**: A dense vector representation of a token that captures semantic meaning. Learned during training.

**Encoder-Decoder**: A transformer architecture that uses both encoder and decoder stacks. Used in the original Transformer for translation.

**Entropy**: A measure of uncertainty in a probability distribution. Higher entropy = more uncertainty.

**Epoch**: One complete pass through the training data.

### F

**Feed-Forward**: A neural network layer with two linear transformations and a non-linear activation (usually ReLU). Used in transformer blocks.

**Fine-tuning**: Training a pre-trained model on a specific task with additional labeled data.

### G

**Gradient**: The direction of steepest increase in the loss function. Used in optimization.

**Gradient Descent**: An optimization algorithm that updates parameters in the direction of steepest descent.

**Greedy Sampling**: Always choosing the most likely next token. Fast but deterministic.

### K

**KL Divergence (Kullback-Leibler Divergence)**: A measure of difference between two probability distributions. Used as distillation loss.

**KV Cache**: Storing key and value matrices from previous tokens to avoid recomputation during generation. Reduces complexity from O(n²) to O(n).

### L

**Layer Normalization**: Normalizing activations across the feature dimension to stabilize training.

**Learning Rate**: The step size in gradient descent. Controls how much parameters change per update.

**Loss Function**: A measure of how well the model is performing. The objective to minimize during training.

### M

**Masked Attention**: Attention that masks out certain positions (e.g., future tokens in causal attention).

**Matrix Multiplication**: The core operation in neural networks, transforming input vectors using weight matrices.

**Multi-Head Attention**: Multiple parallel attention heads that capture different relationship patterns (syntax, semantics, long-range).

### O

**One-Hot**: A vector with a 1 at the index of the correct class and 0s elsewhere. Used as hard labels.

### P

**Perplexity**: A measure of how "surprised" the model is by the data. Lower perplexity = better performance.

**Positional Encoding**: Adding position information to token embeddings to preserve order in transformers.

**Pre-training**: Training a model on a large corpus for next token prediction. Learns language patterns.

**Pruning**: Removing unimportant weights from a model to reduce size.

### Q

**Quantization**: Reducing the precision of weights and activations (e.g., FP32 → INT8). Reduces memory and speeds up inference.

**Query (Q)**: In attention, the query asks "what am I looking for?"

### R

**ReLU (Rectified Linear Unit)**: Activation function: max(0, x). Most common hidden layer activation.

**Residual Connection**: Adding the input to the output of a layer to prevent vanishing gradients. Key to training deep networks.

**RNN (Recurrent Neural Network)**: Sequential processing model. Replaced by transformers.

### S

**Self-Attention**: Attention where Q, K, and V all come from the same sequence.

**Soft Targets**: Probability distributions from a teacher model. Carry "dark knowledge" about class relationships.

**Softmax**: A function that converts logits to probabilities. Outputs sum to 1.

**Special Tokens**: Tokens that control model behavior: [BOS], [EOS], [PAD], [UNK], [SEP], [MASK].

**Supervised Loss**: Loss computed using hard labels. Typically cross-entropy.

### T

**Temperature**: A parameter that controls the softness of a distribution. Higher T = softer/more uniform.

**Token**: A unit of text (character, word, or subword). The basic unit of processing.

**Transformer**: The architecture that uses attention to process sequences in parallel.

### V

**Value (V)**: In attention, the value contains the actual content to be weighted.

**Vocabulary**: The set of all tokens the model knows.

---

# SECTION 10: FURTHER READING

## Advanced Topics to Explore

### 1. Quantization
- GPTQ: https://arxiv.org/abs/2210.17323
- AWQ: https://arxiv.org/abs/2306.00978
- Bitsandbytes: https://github.com/TimDettmers/bitsandbytes

### 2. Efficient Attention
- FlashAttention: https://arxiv.org/abs/2205.14135
- FlashAttention-2: https://arxiv.org/abs/2307.08691
- PagedAttention: https://arxiv.org/abs/2309.06180

### 3. Model Compression
- DistilBERT: https://arxiv.org/abs/1910.01108
- TinyBERT: https://arxiv.org/abs/1909.10351
- MobileBERT: https://arxiv.org/abs/2004.02984

### 4. Fine-tuning
- LoRA: https://arxiv.org/abs/2106.09685
- QLoRA: https://arxiv.org/abs/2305.14314
- AdaLoRA: https://arxiv.org/abs/2303.10512

### 5. Reinforcement Learning
- RLHF: https://arxiv.org/abs/2203.02155
- PPO: https://arxiv.org/abs/1707.06347
- DPO: https://arxiv.org/abs/2305.18290

### 6. Retrieval-Augmented Generation
- RAG: https://arxiv.org/abs/2005.11401
- Self-RAG: https://arxiv.org/abs/2310.11511
- ReAct: https://arxiv.org/abs/2210.03629

### 7. Long Context
- Longformer: https://arxiv.org/abs/2004.05150
- BigBird: https://arxiv.org/abs/2007.14062
- Mamba: https://arxiv.org/abs/2312.00752

### 8. Multi-modal
- CLIP: https://arxiv.org/abs/2103.00020
- LLaVA: https://arxiv.org/abs/2304.08485
- GPT-4V: https://openai.com/research/gpt-4v-system-card

### 9. Agent Systems
- AutoGPT: https://github.com/Significant-Gravitas/AutoGPT
- BabyAGI: https://github.com/yoheinakajima/babyagi
- LangChain: https://langchain.com/

### 10. Open Source Models
- GPT-2: https://github.com/openai/gpt-2
- GPT-3: https://github.com/openai/gpt-3
- Llama: https://github.com/meta-llama/llama
- Mistral: https://github.com/mistralai/mistral-src
- Falcon: https://github.com/tiiuae/falcon

---

# QUICK REFERENCE CARD

```
┌─────────────────────────────────────────────────────────────────┐
│  KEY PAPERS                                                     │
├─────────────────────────────────────────────────────────────────┤
│  • Attention Is All You Need (2017)                           │
│  • BERT (2018)                                                │
│  • GPT-3 (2020)                                               │
│  • Distilling the Knowledge (2015)                            │
│  • FlashAttention (2022)                                      │
│  • LoRA (2021)                                                │
│  • QLoRA (2023)                                               │
├─────────────────────────────────────────────────────────────────┤
│  KEY LIBRARIES                                                  │
├─────────────────────────────────────────────────────────────────┤
│  • Transformers.js (JS)                                       │
│  • TensorFlow.js (JS)                                         │
│  • Hugging Face Transformers (Python)                         │
│  • vLLM (Python)                                              │
│  • Llama.cpp (C++)                                            │
│  • LangChain.js (JS)                                          │
├─────────────────────────────────────────────────────────────────┤
│  KEY RESOURCES                                                  │
├─────────────────────────────────────────────────────────────────┤
│  • Hugging Face Course                                        │
│  • Stanford CS224N                                            │
│  • Fast.ai                                                    │
│  • The Illustrated Transformer                                │
│  • Distill.pub                                                │
├─────────────────────────────────────────────────────────────────┤
│  KEY COMMUNITIES                                                │
├─────────────────────────────────────────────────────────────────┤
│  • Hugging Face Community                                     │
│  • r/MachineLearning                                          │
│  • r/LocalLLaMA                                               │
│  • Transformers.js Discord                                    │
│  • AI Stack Exchange                                          │
└─────────────────────────────────────────────────────────────────┘
```

---

**[END OF REFERENCES AND RESOURCES]**

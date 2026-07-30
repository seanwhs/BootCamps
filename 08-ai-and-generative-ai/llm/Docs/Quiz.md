# Quiz and Test Bank: Beneath the Surface — Demystifying LLMs, Transformers, and Distillation

## Comprehensive Assessment Package with Answer Keys

---

# HOW TO USE THIS TEST BANK

This test bank contains:
- **📝 Module Quizzes** - Short assessments for each module (10-15 questions)
- **📋 Midterm Exam** - Comprehensive test covering Modules 0-2
- **📋 Final Exam** - Comprehensive test covering all modules
- **📊 Answer Keys** - Detailed explanations for all questions
- **🎯 Question Types** - Multiple choice, true/false, fill-in-the-blank, short answer, coding questions
- **⭐ Difficulty Levels** - Basic (1), Intermediate (2), Advanced (3)

---

# MODULE 0: INTRODUCTION QUIZ

## Questions

### Multiple Choice

**1. What is an LLM fundamentally?**
- A) A thinking brain that understands meaning
- B) A statistical pattern predictor
- C) A database of facts
- D) A search engine

**2. Which of these is NOT a phase in this series?**
- A) Tokenization and embeddings
- B) Transformer architecture
- C) Quantum computing
- D) Knowledge distillation

**3. What is the primary reason for using JavaScript in this series?**
- A) It's faster than Python
- B) JavaScript is where AI meets the world
- C) It has better AI libraries
- D) It's easier to learn

**4. What are the three layers of understanding in this series?**
- A) Data, Architecture, Optimization
- B) Input, Processing, Output
- C) Training, Testing, Deployment
- D) Theory, Practice, Production

**5. What is the core mental model of an LLM?**
- A) It thinks like a human brain
- B) It predicts the next token
- C) It searches a database
- D) It translates languages

**6. Which of these is a prerequisite for this series?**
- A) Python programming
- B) Advanced calculus
- C) Modern JavaScript
- D) Machine learning degree

**7. What is the estimated total time for this series?**
- A) 5 hours
- B) 10 hours
- C) 28 hours
- D) 100 hours

**8. What is the ultimate architecture students build?**
- A) A chat application
- B) A tokenizer only
- C) A complete LLM system from text to deployment
- D) A database system

### True/False

**9. True or False: LLMs are "thinking brains" that understand meaning like humans.**

**10. True or False: This series only covers using APIs, not building models.**

**11. True or False: The series is designed for JavaScript/Node.js developers.**

**12. True or False: You need a GPU to complete this series.**

### Fill-in-the-Blank

**13. LLMs are __________ engines, not __________ brains.**

**14. The series covers four phases: text understanding, __________, distillation, and production deployment.**

**15. The three key layers are: Data, __________, and Optimization.**

---

## Answer Key — Module 0

1. **B** - LLMs are statistical pattern predictors that output probabilities over next tokens.

2. **C** - Quantum computing is not covered; the phases are tokenization, transformer, distillation, and production.

3. **B** - JavaScript is where AI meets the world through web apps, serverless, and edge computing.

4. **A** - The three layers are Data (text → numbers), Architecture (processing), and Optimization (compression).

5. **B** - LLMs predict the next token based on previous context.

6. **C** - Modern JavaScript (ES6+, async/await) is required.

7. **C** - ~28 hours total (10 hours reading, 18 hours coding).

8. **C** - Students build a complete LLM system from text processing to production deployment.

9. **False** - LLMs are prediction engines, not thinking brains.

10. **False** - This series builds models from scratch, not just using APIs.

11. **True** - The series is specifically designed for JavaScript/Node.js developers.

12. **False** - All code runs on CPU; GPU is optional for larger models.

13. **statistical prediction; thinking**

14. **transformer**

15. **Architecture**

---

# MODULE 1: ANATOMY OF AN LLM QUIZ

## Questions

### Multiple Choice

**1. Why can't we feed raw text directly into a neural network?**
- A) Text is too long
- B) Computers don't understand words
- C) Text is too slow to process
- D) Text is always ambiguous

**2. What is the main advantage of BPE tokenization?**
- A) It's the fastest method
- B) It balances vocabulary size and coverage
- C) It uses the least memory
- D) It's easiest to implement

**3. What are special tokens used for?**
- A) Making text colorful
- B) Controlling model behavior
- C) Speeding up computation
- D) Reducing vocabulary size

**4. What does an embedding matrix represent?**
- A) Tokens × Vocabulary size
- B) Tokens × Embedding dimension
- C) Vocabulary × Embedding dimension
- D) None of the above

**5. What does cosine similarity measure?**
- A) The distance between vectors
- B) The angle between vectors
- C) The difference between vectors
- D) The product of vectors

**6. What is "semantic space"?**
- A) A physical location for AI models
- B) A high-dimensional space where embeddings live
- C) A type of neural network
- D) A database of words

**7. What is the purpose of pre-training?**
- A) To teach the model to follow instructions
- B) To learn language patterns through next-token prediction
- C) To compress the model
- D) To deploy the model

**8. What is the difference between pre-training and alignment?**
- A) Pre-training is for small models; alignment is for large models
- B) Pre-training learns language; alignment learns behavior
- C) Pre-training is faster; alignment is slower
- D) There is no difference

**9. What happens when an unknown token is encountered?**
- A) The model crashes
- B) The token is ignored
- C) The token is mapped to [UNK]
- D) The model generates a new token

**10. What is the typical embedding dimension for modern LLMs?**
- A) 8-16
- B) 32-64
- C) 64-512
- D) 1024-4096

**11. Which of these is NOT a type of tokenization?**
- A) Character-level
- B) Word-level
- C) Sentence-level
- D) Subword-level

**12. What is the relationship between tokenization and embeddings?**
- A) They are the same thing
- B) Tokenization creates IDs; embeddings convert IDs to vectors
- C) Embeddings create IDs; tokenization converts IDs to vectors
- D) They are unrelated

**13. How does BPE handle the "unknown token" problem?**
- A) It ignores unknown tokens
- B) It splits unknown words into known subwords
- C) It uses a special [UNK] token
- D) Both B and C

**14. What is the purpose of the [PAD] token?**
- A) To indicate the start of a sequence
- B) To make sequences uniform length for batching
- C) To indicate the end of a sequence
- D) To handle unknown tokens

### Fill-in-the-Blank

**15. BPE stands for __________ __________ Encoding.**

**16. __________ tokens are special tokens that control model behavior.**

**17. Cosine similarity ranges from __________ to __________.**

**18. The embedding matrix has shape [__________ × __________].**

**19. __________ is the phase where a model learns language patterns through next-token prediction.**

---

## Answer Key — Module 1

1. **B** - Computers only understand numbers; text must be converted.

2. **B** - BPE balances vocabulary size (fewer tokens) and coverage (handles unknown words).

3. **B** - Special tokens control behavior (start/end, padding, unknown, etc.).

4. **C** - The embedding matrix is Vocabulary × Embedding dimension.

5. **B** - Cosine similarity measures the angle between vectors.

6. **B** - Semantic space is the high-dimensional embedding space where concepts are represented.

7. **B** - Pre-training learns language patterns through next-token prediction on massive corpora.

8. **B** - Pre-training learns language patterns; alignment learns behavior and helpfulness.

9. **C** - Unknown tokens are mapped to the [UNK] token.

10. **D** - Modern LLMs use 1024-4096 dimensions.

11. **C** - Sentence-level is not a standard tokenization approach.

12. **B** - Tokenization converts text to IDs; embeddings convert IDs to vectors.

13. **D** - BPE splits unknown words into known subwords and can use [UNK] fallback.

14. **B** - [PAD] ensures all sequences in a batch have the same length.

15. **Byte-Pair**

16. **Special**

17. **-1; 1**

18. **Vocabulary; Embedding Dimension**

19. **Pre-training**

---

# MODULE 2: TRANSFORMER REVOLUTION QUIZ

## Questions

### Multiple Choice

**1. What problem does the attention mechanism solve?**
- A) It makes models faster
- B) It enables long-range dependencies
- C) It reduces memory usage
- D) All of the above

**2. What do Q, K, and V represent in attention?**
- A) Question, Knowledge, Value
- B) Query, Key, Value
- C) Quality, Knowledge, Velocity
- D) None of the above

**3. What is the purpose of scaling in attention?**
- A) To make computation faster
- B) To prevent vanishing gradients
- C) To reduce memory usage
- D) To increase accuracy

**4. Why do we need multiple attention heads?**
- A) To make the model faster
- B) To capture different relationship patterns
- C) To reduce memory usage
- D) To simplify the architecture

**5. What is the purpose of positional encodings?**
- A) To speed up computation
- B) To preserve order information
- C) To reduce memory usage
- D) To improve accuracy

**6. What does the causal mask do?**
- A) Speeds up computation
- B) Prevents looking at future tokens
- C) Reduces memory usage
- D) Improves accuracy

**7. What is the formula for self-attention?**
- A) softmax(Q × K^T / √d_k) × V
- B) softmax(Q × V^T / √d_k) × K
- C) tanh(Q × K^T / √d_k) × V
- D) relu(Q × K^T / √d_k) × V

**8. What is the difference between greedy and temperature sampling?**
- A) Greedy is faster
- B) Greedy always picks the most likely token
- C) Temperature is more accurate
- D) There is no difference

**9. What is the purpose of residual connections in transformers?**
- A) To speed up computation
- B) To prevent vanishing gradients
- C) To reduce memory usage
- D) To improve accuracy

**10. What is the difference between sinusoidal and learned positional encodings?**
- A) Sinusoidal is faster
- B) Sinusoidal is deterministic; learned is trainable
- C) Learned is faster
- D) There is no difference

**11. What is the typical number of layers in modern LLMs?**
- A) 1-3
- B) 6-12
- C) 12-96
- D) 1000+

**12. What does Top-K sampling do?**
- A) Keeps only the K most likely tokens
- B) Keeps tokens with cumulative probability K
- C) Removes K tokens
- D) Adds K tokens

**13. What is the purpose of layer normalization?**
- A) To speed up computation
- B) To stabilize training
- C) To reduce memory usage
- D) To improve accuracy

### Fill-in-the-Blank

**14. The attention formula is Attention(Q,K,V) = __________ × V.**

**15. __________ encodings use sin and cos functions to add position information.**

**16. Multi-head attention concatenates multiple __________.**

**17. __________ sampling always picks the most likely token.**

**18. The causal mask prevents looking at __________ tokens.**

---

## Answer Key — Module 2

1. **D** - Attention enables parallel processing, global context, and long-range dependencies.

2. **B** - Q = Query, K = Key, V = Value.

3. **B** - Scaling by √d_k prevents gradients from becoming too small.

4. **B** - Different heads capture different patterns (syntax, semantics, etc.).

5. **B** - Attention is order-agnostic; positional encodings add order information.

6. **B** - Causal mask prevents tokens from attending to future tokens.

7. **A** - The correct formula is softmax(Q × K^T / √d_k) × V.

8. **B** - Greedy always picks the most likely token; temperature adds randomness.

9. **B** - Residual connections prevent vanishing gradients in deep networks.

10. **B** - Sinusoidal encodings are deterministic and parameter-free; learned encodings are trainable.

11. **C** - Modern LLMs have 12-96 layers (GPT-3 has 96).

12. **A** - Top-K keeps only the K most likely tokens.

13. **B** - Layer norm stabilizes training by normalizing activations.

14. **softmax(Q × K^T / √d_k)**

15. **Positional (or Sinusoidal)**

16. **heads**

17. **Greedy**

18. **future**

---

# MODULE 3: KNOWLEDGE DISTILLATION QUIZ

## Questions

### Multiple Choice

**1. What is the main goal of knowledge distillation?**
- A) To make models faster
- B) To compress models while preserving quality
- C) To reduce training time
- D) All of the above

**2. What are "soft targets"?**
- A) One-hot labels
- B) Probability distributions from the teacher
- C) Raw logits
- D) Weight matrices

**3. What is "dark knowledge"?**
- A) Information not available in the data
- B) Relationships between classes revealed in soft targets
- C) Secret model parameters
- D) Hidden training data

**4. Why do we use temperature scaling in distillation?**
- A) To speed up training
- B) To reveal hidden patterns in the teacher's predictions
- C) To reduce memory usage
- D) To improve accuracy

**5. What is the distillation loss formula?**
- A) L = α·D_KL(P_T||P_S) + (1-α)·CE(y_true, P_S)
- B) L = α·MSE(P_T,P_S) + (1-α)·CE(y_true, P_S)
- C) L = α·D_KL(P_T||P_S) + (1-α)·MSE(y_true, P_S)
- D) L = α·CE(P_T,P_S) + (1-α)·D_KL(y_true, P_S)

**6. What does α represent in distillation?**
- A) Learning rate
- B) Distillation weight (0.7-0.9)
- C) Temperature
- D) Batch size

**7. How does distillation differ from quantization?**
- A) Distillation trains a smaller model; quantization reduces precision
- B) Distillation reduces precision; quantization trains a smaller model
- C) They are the same thing
- D) They are opposite processes

**8. What is the typical compression ratio from distillation?**
- A) 1.5x
- B) 3-10x
- C) 100x
- D) 1000x

**9. What is the role of the teacher model?**
- A) To be fast and efficient
- B) To provide soft targets for the student
- C) To replace the student
- D) To train the student on hard labels

**10. What is the combined loss in distillation?**
- A) Only distillation loss
- B) Only supervised loss
- C) Both distillation and supervised losses
- D) Neither distillation nor supervised losses

**11. What happens when temperature T → 0 in distillation?**
- A) The distribution becomes uniform
- B) The distribution becomes one-hot
- C) The distribution becomes standard softmax
- D) The distribution becomes random

**12. What is the purpose of the T² scaling factor?**
- A) To speed up computation
- B) To maintain gradient magnitudes
- C) To reduce memory usage
- D) To improve accuracy

**13. Which compression method gives the best quality retention?**
- A) Distillation
- B) Quantization
- C) Pruning
- D) All are equally good

### Fill-in-the-Blank

**14. In distillation, the __________ model provides soft targets to the __________ model.**

**15. Soft targets reveal __________ knowledge about relationships between classes.**

**16. Higher temperature in distillation makes the distribution __________ (softer/more uniform).**

**17. The combined loss uses α to balance __________ and __________ losses.**

**18. Distillation can be combined with __________ for even greater compression.**

---

## Answer Key — Module 3

1. **D** - Distillation makes models smaller, faster, and cheaper while preserving quality.

2. **B** - Soft targets are probability distributions from the teacher.

3. **B** - Dark knowledge is the relationships between classes revealed in soft targets.

4. **B** - Higher temperature reveals hidden patterns (dark knowledge) in the teacher's predictions.

5. **A** - The correct formula is L = α·D_KL(P_T||P_S) + (1-α)·CE(y_true, P_S).

6. **B** - α is the distillation weight, typically 0.7-0.9.

7. **A** - Distillation trains a smaller model; quantization reduces precision of weights.

8. **B** - Distillation typically achieves 3-10x compression.

9. **B** - The teacher provides soft targets for the student to learn from.

10. **C** - The combined loss uses both distillation (KL) and supervised (CE) losses.

11. **B** - T → 0 makes the distribution one-hot (deterministic).

12. **B** - T² maintains gradient magnitudes for balanced training.

13. **A** - Distillation gives the best quality retention.

14. **teacher; student**

15. **dark**

16. **softer**

17. **distillation; supervised**

18. **quantization**

---

# MODULE 4: PRODUCTION DEPLOYMENT QUIZ

## Questions

### Multiple Choice

**1. What is the purpose of KV caching?**
- A) To store model weights
- B) To avoid recomputing past tokens
- C) To reduce model size
- D) To improve accuracy

**2. What is the complexity improvement from KV caching?**
- A) O(n²) → O(n)
- B) O(n) → O(1)
- C) O(n²) → O(n²)
- D) O(n) → O(n²)

**3. What does the temperature parameter control?**
- A) Model size
- B) Randomness in generation
- C) Training speed
- D) Memory usage

**4. What's the difference between Top-K and Top-P sampling?**
- A) Top-K keeps K most likely tokens; Top-P keeps cumulative probability P
- B) Top-K keeps cumulative probability K; Top-P keeps P most likely tokens
- C) They are the same
- D) Top-K is for training; Top-P is for inference

**5. Why do we need rate limiting in production?**
- A) To speed up the server
- B) To prevent abuse and ensure fair usage
- C) To reduce memory usage
- D) To improve accuracy

**6. What does the [PAD] token do in production?**
- A) It indicates the start of a sequence
- B) It makes sequences uniform length for batching
- C) It indicates the end of a sequence
- D) It handles unknown tokens

**7. What is the typical latency for generation with KV cache?**
- A) < 1ms
- B) < 100ms
- C) < 1s
- D) < 10s

**8. What is the purpose of the /health endpoint?**
- A) To generate text
- B) To check server status
- C) To list models
- D) To get statistics

**9. What happens when the KV cache is full?**
- A) The server crashes
- B) The oldest entry is evicted (LRU)
- C) New entries are ignored
- D) All entries are cleared

**10. Which is NOT a generation parameter?**
- A) maxTokens
- B) temperature
- C) batchSize
- D) topP

**11. What is the purpose of repetition penalty?**
- A) To speed up generation
- B) To reduce repetition in outputs
- C) To increase accuracy
- D) To reduce memory usage

**12. What does throughput measure?**
- A) Time per request
- B) Requests per second
- C) Memory usage
- D) Model size

**13. What is the recommended batch size for inference?**
- A) 1
- B) 8-32
- C) 128-256
- D) 1024+

**14. Why is monitoring important in production?**
- A) To track performance and detect issues
- B) To speed up the server
- C) To reduce costs
- D) To improve accuracy

**15. What does the /api/stats endpoint provide?**
- A) Model parameters
- B) Server and model statistics
- C) Generated text
- D) Training data

### Fill-in-the-Blank

**16. KV cache stores __________ and __________ matrices from previous tokens.**

**17. Higher temperature in generation makes outputs __________ (more/less random).**

**18. The __________ endpoint checks server status.**

**19. Rate limiting prevents __________ and ensures fair usage.**

**20. __________ is the measure of requests per second the server can handle.**

---

## Answer Key — Module 4

1. **B** - KV cache stores key and value matrices to avoid recomputing past tokens.

2. **A** - KV caching reduces complexity from O(n²) to O(n).

3. **B** - Temperature controls randomness in generation (0-2).

4. **A** - Top-K keeps K most likely tokens; Top-P keeps tokens with cumulative probability P.

5. **B** - Rate limiting prevents abuse and ensures fair usage.

6. **B** - [PAD] makes sequences uniform length for batching.

7. **B** - With KV cache, typical latency is < 100ms.

8. **B** - /health checks server status.

9. **B** - Oldest entries are evicted (LRU - Least Recently Used).

10. **C** - batchSize is a training parameter, not a generation parameter.

11. **B** - Repetition penalty reduces repetition in outputs.

12. **B** - Throughput is requests per second.

13. **A** - Batch size 1 is typical for inference (though batching can improve throughput).

14. **A** - Monitoring tracks performance and detects issues.

15. **B** - /api/stats provides server and model statistics.

16. **Key; Value**

17. **more**

18. **/health**

19. **abuse**

20. **Throughput**

---

# MIDTERM EXAM

## Comprehensive Exam (Modules 0-2)

### Part A: Multiple Choice (40 questions, 1 point each)

**1. What is an LLM fundamentally?**
- A) A thinking brain
- B) A statistical pattern predictor
- C) A database of facts
- D) A search engine

**2. What is the first step in text processing for LLMs?**
- A) Embedding
- B) Tokenization
- C) Attention
- D) Prediction

**3. What is the main advantage of BPE tokenization?**
- A) It's fastest
- B) Balances vocabulary size and coverage
- C) Uses least memory
- D) Easiest to implement

**4. What does an embedding matrix represent?**
- A) Tokens × Vocabulary
- B) Tokens × Embedding dimension
- C) Vocabulary × Embedding dimension
- D) None of the above

**5. What does cosine similarity measure?**
- A) Distance between vectors
- B) Angle between vectors
- C) Difference between vectors
- D) Product of vectors

**6. What is the purpose of pre-training?**
- A) Teach model to follow instructions
- B) Learn language patterns
- C) Compress the model
- D) Deploy the model

**7. What problem does attention solve?**
- A) Makes models faster
- B) Enables long-range dependencies
- C) Reduces memory usage
- D) All of the above

**8. What do Q, K, V represent?**
- A) Question, Knowledge, Value
- B) Query, Key, Value
- C) Quality, Knowledge, Velocity
- D) None of the above

**9. What is the purpose of scaling in attention?**
- A) Make computation faster
- B) Prevent vanishing gradients
- C) Reduce memory usage
- D) Increase accuracy

**10. Why do we need multiple attention heads?**
- A) Make model faster
- B) Capture different patterns
- C) Reduce memory
- D) Simplify architecture

**11. What is the purpose of positional encodings?**
- A) Speed up computation
- B) Preserve order information
- C) Reduce memory
- D) Improve accuracy

**12. What does the causal mask do?**
- A) Speed up computation
- B) Prevent looking at future tokens
- C) Reduce memory
- D) Improve accuracy

**13. What is the attention formula?**
- A) softmax(Q × K^T / √d_k) × V
- B) softmax(Q × V^T / √d_k) × K
- C) tanh(Q × K^T / √d_k) × V
- D) relu(Q × K^T / √d_k) × V

**14. What is the difference between greedy and temperature sampling?**
- A) Greedy is faster
- B) Greedy always picks the most likely
- C) Temperature is more accurate
- D) No difference

**15. What is the purpose of residual connections?**
- A) Speed up computation
- B) Prevent vanishing gradients
- C) Reduce memory
- D) Improve accuracy

**16. What is the typical embedding dimension?**
- A) 8-16
- B) 32-64
- C) 64-512
- D) 1024-4096

**17. Which is NOT a type of tokenization?**
- A) Character-level
- B) Word-level
- C) Sentence-level
- D) Subword-level

**18. What happens to unknown tokens?**
- A) Model crashes
- B) Token is ignored
- C) Mapped to [UNK]
- D) Model generates new token

**19. What is the purpose of [PAD]?**
- A) Start sequence
- B) Make sequences uniform length
- C) End sequence
- D) Handle unknown tokens

**20. What is the difference between sinusoidal and learned positional encodings?**
- A) Sinusoidal is faster
- B) Sinusoidal is deterministic; learned is trainable
- C) Learned is faster
- D) No difference

**21. What is the typical number of layers in modern LLMs?**
- A) 1-3
- B) 6-12
- C) 12-96
- D) 1000+

**22. What does Top-K sampling do?**
- A) Keeps K most likely
- B) Keeps cumulative probability K
- C) Removes K tokens
- D) Adds K tokens

**23. What is the purpose of layer normalization?**
- A) Speed up computation
- B) Stabilize training
- C) Reduce memory
- D) Improve accuracy

**24. What is the difference between pre-training and alignment?**
- A) Pre-training is for small models; alignment for large
- B) Pre-training learns language; alignment learns behavior
- C) Pre-training is faster; alignment is slower
- D) No difference

**25. What is "dark knowledge"?**
- A) Information not in data
- B) Relationships between classes in soft targets
- C) Secret model parameters
- D) Hidden training data

**26. What is the distillation loss formula?**
- A) L = α·D_KL(P_T||P_S) + (1-α)·CE(y_true, P_S)
- B) L = α·MSE(P_T,P_S) + (1-α)·CE(y_true, P_S)
- C) L = α·D_KL(P_T||P_S) + (1-α)·MSE(y_true, P_S)
- D) L = α·CE(P_T,P_S) + (1-α)·D_KL(y_true, P_S)

**27. What does α represent in distillation?**
- A) Learning rate
- B) Distillation weight
- C) Temperature
- D) Batch size

**28. How does distillation differ from quantization?**
- A) Distillation trains smaller model; quantization reduces precision
- B) Distillation reduces precision; quantization trains smaller model
- C) Same thing
- D) Opposite processes

**29. What is the typical compression ratio from distillation?**
- A) 1.5x
- B) 3-10x
- C) 100x
- D) 1000x

**30. What is the role of the teacher model?**
- A) Be fast and efficient
- B) Provide soft targets
- C) Replace student
- D) Train student on hard labels

**31. What is the combined loss in distillation?**
- A) Only distillation
- B) Only supervised
- C) Both distillation and supervised
- D) Neither

**32. What happens when T → 0?**
- A) Distribution becomes uniform
- B) Distribution becomes one-hot
- C) Becomes standard softmax
- D) Becomes random

**33. What is the purpose of the T² scaling?**
- A) Speed up computation
- B) Maintain gradient magnitudes
- C) Reduce memory
- D) Improve accuracy

**34. Which compression method gives best quality retention?**
- A) Distillation
- B) Quantization
- C) Pruning
- D) All equal

**35. What is the purpose of special tokens?**
- A) Make text colorful
- B) Control model behavior
- C) Speed up computation
- D) Reduce vocabulary

**36. What is "semantic space"?**
- A) Physical location
- B) High-dimensional embedding space
- C) Type of network
- D) Database of words

**37. What is the relationship between tokenization and embeddings?**
- A) Same thing
- B) Tokenization creates IDs; embeddings convert to vectors
- C) Embeddings create IDs; tokenization converts to vectors
- D) Unrelated

**38. What is the purpose of the [BOS] token?**
- A) End sequence
- B) Start sequence
- C) Padding
- D) Unknown tokens

**39. What does RMSprop do?**
- A) Speeds up computation
- B) Adapts learning rates per parameter
- C) Reduces memory
- D) Improves accuracy

**40. What is the difference between attention and self-attention?**
- A) Attention is faster
- B) Self-attention uses Q,K,V from same sequence
- C) Attention is more accurate
- D) No difference

### Part B: True/False (20 questions, 1 point each)

**41. LLMs are "thinking brains" that understand meaning.**

**42. Transformers process all tokens simultaneously.**

**43. BPE is the tokenization method used in most modern LLMs.**

**44. Higher embedding dimension always means better performance.**

**45. Multi-head attention uses different weights for each head.**

**46. Positional encodings are only needed for training, not inference.**

**47. The causal mask prevents looking at future tokens.**

**48. Greedy sampling always produces the best outputs.**

**49. Residual connections help prevent vanishing gradients.**

**50. Layer normalization is used in transformers.**

**51. Soft targets are one-hot labels.**

**52. Higher temperature reveals more dark knowledge.**

**53. Distillation requires more training data than pre-training.**

**54. Quantization reduces precision of weights.**

**55. Pruning removes unimportant weights.**

**56. Distillation gives better quality than quantization.**

**57. The T² scaling factor is optional in distillation.**

**58. Students learn from teacher's logits, not probabilities.**

**59. Distillation is only used for vision tasks.**

**60. Modern LLMs use transformers.**

### Part C: Fill-in-the-Blank (20 questions, 1 point each)

**61. BPE stands for __________.**

**62. The attention formula is Attention(Q,K,V) = __________ × V.**

**63. Cosine similarity ranges from __________ to __________.**

**64. __________ encodings use sin and cos functions.**

**65. The causal mask prevents looking at __________ tokens.**

**66. In distillation, the __________ provides soft targets.**

**67. The combined loss uses α to balance __________ and __________ losses.**

**68. Higher temperature makes the distribution __________.**

**69. __________ is the phase where the model learns language patterns.**

**70. Multi-head attention concatenates multiple __________.**

**71. The embedding matrix has shape [__________ × __________].**

**72. __________ sampling always picks the most likely token.**

**73. Special tokens control __________ behavior.**

**74. The __________ token handles unknown words.**

**75. Pre-training is for __________; alignment is for __________.**

**76. The [PAD] token makes sequences __________ length.**

**77. The __________ mask prevents looking at future tokens.**

**78. Distillation compresses models by __________x.**

**79. __________ is reducing precision of weights.**

**80. __________ removes unimportant weights.**

### Part D: Short Answer (10 questions, 2 points each)

**81. Explain why text must be converted to numbers for neural networks.**

**82. Describe the BPE tokenization algorithm and why it's effective.**

**83. Explain how the attention mechanism works and why it's important.**

**84. What is the purpose of multi-head attention?**

**85. Describe the difference between positional encodings and learned embeddings.**

**86. Explain the teacher-student paradigm in distillation.**

**87. What are soft targets and why are they important?**

**88. Explain how temperature affects distillation.**

**89. Describe the difference between distillation, quantization, and pruning.**

**90. Why are residual connections important in transformers?**

### Part E: Coding (2 questions, 10 points each)

**91. Implement a simple attention function in JavaScript.**

```javascript
// Write a function that computes self-attention
// Input: Q, K, V matrices (2D arrays)
// Output: { output: 2D array, weights: 2D array }

function selfAttention(Q, K, V) {
    // Your code here
}
```

**92. Implement a training step for distillation.**

```javascript
// Write a function that computes the combined loss
// Input: student_logits, teacher_probs, target_ids, config
// Output: { total_loss, distillation_loss, supervised_loss }

function combinedLoss(studentLogits, teacherProbs, targetIds, config) {
    // Your code here
}
```

---

## Midterm Exam Answer Key

### Part A: Multiple Choice

1. B
2. B
3. B
4. C
5. B
6. B
7. D
8. B
9. B
10. B
11. B
12. B
13. A
14. B
15. B
16. D
17. C
18. C
19. B
20. B
21. C
22. A
23. B
24. B
25. B
26. A
27. B
28. A
29. B
30. B
31. C
32. B
33. B
34. A
35. B
36. B
37. B
38. B
39. B
40. B

### Part B: True/False

41. False
42. True
43. True
44. False
45. True
46. False
47. True
48. False
49. True
50. True
51. False
52. True
53. False
54. True
55. True
56. True
57. False
58. False
59. False
60. True

### Part C: Fill-in-the-Blank

61. Byte-Pair Encoding
62. softmax(Q × K^T / √d_k)
63. -1, 1
64. Positional (or Sinusoidal)
65. future
66. teacher
67. distillation, supervised
68. softer
69. Pre-training
70. heads
71. Vocabulary, Embedding Dimension
72. Greedy
73. model
74. [UNK]
75. language patterns, behavior
76. uniform
77. causal
78. 3-10
79. Quantization
80. Pruning

### Part D: Short Answer

**81.** Neural networks operate on numbers, not words. Text must be converted to numerical representations that preserve semantic meaning.

**82.** BPE starts with character-level tokens, repeatedly merges the most frequent adjacent pair, and continues until target vocabulary size is reached. It's effective because it balances vocabulary size and coverage, handling unknown words by splitting them into known subwords.

**83.** Attention computes relevance between tokens using Q, K, V matrices. It's important because it enables global reasoning, parallel processing, and long-range dependencies.

**84.** Multi-head attention allows the model to capture different types of relationships (syntax, semantics, long-range, positional) simultaneously.

**85.** Positional encodings are deterministic (sinusoidal functions) and add position information. Learned embeddings are trainable parameters that learn position representations from data.

**86.** The teacher (large model) provides soft targets to the student (small model). The student learns to mimic the teacher's behavior through distillation.

**87.** Soft targets are probability distributions from the teacher. They carry "dark knowledge" about relationships between classes, helping the student generalize better.

**88.** Higher temperature softens the distribution, revealing more dark knowledge. Lower temperature makes the distribution sharper, focusing on the most likely classes.

**89.** Distillation trains a smaller model; quantization reduces precision (FP32→INT8); pruning removes unimportant weights. Distillation gives best quality, quantization requires no training, pruning is simple.

**90.** Residual connections add the input to the output of a layer, preventing vanishing gradients in deep networks by providing a direct path for gradients.

### Part E: Coding

**91. Self-Attention Implementation:**

```javascript
function selfAttention(Q, K, V) {
    const d_k = Q[0].length;
    const scale = Math.sqrt(d_k);
    
    // Compute Q × K^T
    const K_T = K[0].map((_, colIdx) => K.map(row => row[colIdx]));
    const scores = Q.map(qRow => 
        K_T.map(kCol => {
            let sum = 0;
            for (let i = 0; i < qRow.length; i++) {
                sum += qRow[i] * kCol[i];
            }
            return sum / scale;
        })
    );
    
    // Apply softmax
    const weights = scores.map(row => {
        const max = Math.max(...row);
        const exp = row.map(v => Math.exp(v - max));
        const sum = exp.reduce((a, b) => a + b, 0);
        return exp.map(v => v / sum);
    });
    
    // Multiply by V
    const output = weights.map(row => {
        const out = [];
        for (let j = 0; j < V[0].length; j++) {
            let sum = 0;
            for (let i = 0; i < row.length; i++) {
                sum += row[i] * V[i][j];
            }
            out.push(sum);
        }
        return out;
    });
    
    return { output, weights };
}
```

**92. Combined Loss Implementation:**

```javascript
function combinedLoss(studentLogits, teacherProbs, targetIds, config) {
    const temperature = config.temperature || 2.0;
    const alpha = config.alpha || 0.7;
    
    // Compute distillation loss (KL divergence)
    const studentProbs = studentLogits.map(row => {
        const scaled = row.map(l => l / temperature);
        const max = Math.max(...scaled);
        const exp = scaled.map(v => Math.exp(v - max));
        const sum = exp.reduce((a, b) => a + b, 0);
        return exp.map(v => v / sum);
    });
    
    let distLoss = 0;
    let count = 0;
    for (let i = 0; i < studentProbs.length; i++) {
        if (i >= teacherProbs.length) break;
        let kl = 0;
        for (let j = 0; j < teacherProbs[i].length; j++) {
            if (teacherProbs[i][j] > 0 && studentProbs[i][j] > 0) {
                kl += teacherProbs[i][j] * Math.log(teacherProbs[i][j] / studentProbs[i][j]);
            }
        }
        distLoss += kl;
        count++;
    }
    distLoss = distLoss / count;
    
    // Compute supervised loss (cross-entropy)
    let supLoss = 0;
    count = 0;
    for (let i = 0; i < studentLogits.length - 1; i++) {
        const targetId = targetIds[i + 1];
        const probs = studentLogits[i].map(l => {
            const max = Math.max(...studentLogits[i]);
            const exp = studentLogits[i].map(v => Math.exp(v - max));
            const sum = exp.reduce((a, b) => a + b, 0);
            return exp.map(v => v / sum);
        });
        supLoss -= Math.log(probs[targetId] + 1e-8);
        count++;
    }
    supLoss = supLoss / count;
    
    const totalLoss = alpha * distLoss + (1 - alpha) * supLoss;
    
    return {
        totalLoss,
        distillationLoss: distLoss,
        supervisedLoss: supLoss,
        alpha,
        temperature
    };
}
```

---

# FINAL EXAM

## Comprehensive Exam (All Modules)

### Part A: Multiple Choice (60 questions, 1 point each)

**1. What is an LLM fundamentally?**
- A) A thinking brain
- B) A statistical pattern predictor
- C) A database of facts
- D) A search engine

**2. What is the first step in text processing for LLMs?**
- A) Embedding
- B) Tokenization
- C) Attention
- D) Prediction

**3. What is the main advantage of BPE?**
- A) It's fastest
- B) Balances vocabulary and coverage
- C) Uses least memory
- D) Easiest to implement

**4. What does an embedding matrix represent?**
- A) Tokens × Vocabulary
- B) Tokens × Embedding dimension
- C) Vocabulary × Embedding dimension
- D) None of the above

**5. What does cosine similarity measure?**
- A) Distance between vectors
- B) Angle between vectors
- C) Difference between vectors
- D) Product of vectors

**6. What is the purpose of pre-training?**
- A) Teach model to follow instructions
- B) Learn language patterns
- C) Compress the model
- D) Deploy the model

**7. What problem does attention solve?**
- A) Makes models faster
- B) Enables long-range dependencies
- C) Reduces memory usage
- D) All of the above

**8. What do Q, K, V represent?**
- A) Question, Knowledge, Value
- B) Query, Key, Value
- C) Quality, Knowledge, Velocity
- D) None of the above

**9. What is the purpose of scaling in attention?**
- A) Make computation faster
- B) Prevent vanishing gradients
- C) Reduce memory usage
- D) Increase accuracy

**10. Why do we need multiple attention heads?**
- A) Make model faster
- B) Capture different patterns
- C) Reduce memory
- D) Simplify architecture

**11. What is the purpose of positional encodings?**
- A) Speed up computation
- B) Preserve order information
- C) Reduce memory
- D) Improve accuracy

**12. What does the causal mask do?**
- A) Speed up computation
- B) Prevent looking at future tokens
- C) Reduce memory
- D) Improve accuracy

**13. What is the attention formula?**
- A) softmax(Q × K^T / √d_k) × V
- B) softmax(Q × V^T / √d_k) × K
- C) tanh(Q × K^T / √d_k) × V
- D) relu(Q × K^T / √d_k) × V

**14. What is the difference between greedy and temperature sampling?**
- A) Greedy is faster
- B) Greedy always picks the most likely
- C) Temperature is more accurate
- D) No difference

**15. What is the purpose of residual connections?**
- A) Speed up computation
- B) Prevent vanishing gradients
- C) Reduce memory
- D) Improve accuracy

**16. What is the typical embedding dimension?**
- A) 8-16
- B) 32-64
- C) 64-512
- D) 1024-4096

**17. Which is NOT a type of tokenization?**
- A) Character-level
- B) Word-level
- C) Sentence-level
- D) Subword-level

**18. What happens to unknown tokens?**
- A) Model crashes
- B) Token is ignored
- C) Mapped to [UNK]
- D) Model generates new token

**19. What is the purpose of [PAD]?**
- A) Start sequence
- B) Make sequences uniform length
- C) End sequence
- D) Handle unknown tokens

**20. What is the difference between sinusoidal and learned positional encodings?**
- A) Sinusoidal is faster
- B) Sinusoidal is deterministic; learned is trainable
- C) Learned is faster
- D) No difference

**21. What is the typical number of layers in modern LLMs?**
- A) 1-3
- B) 6-12
- C) 12-96
- D) 1000+

**22. What does Top-K sampling do?**
- A) Keeps K most likely
- B) Keeps cumulative probability K
- C) Removes K tokens
- D) Adds K tokens

**23. What is the purpose of layer normalization?**
- A) Speed up computation
- B) Stabilize training
- C) Reduce memory
- D) Improve accuracy

**24. What is the difference between pre-training and alignment?**
- A) Pre-training is for small models; alignment for large
- B) Pre-training learns language; alignment learns behavior
- C) Pre-training is faster; alignment is slower
- D) No difference

**25. What is "dark knowledge"?**
- A) Information not in data
- B) Relationships between classes in soft targets
- C) Secret model parameters
- D) Hidden training data

**26. What is the distillation loss formula?**
- A) L = α·D_KL(P_T||P_S) + (1-α)·CE(y_true, P_S)
- B) L = α·MSE(P_T,P_S) + (1-α)·CE(y_true, P_S)
- C) L = α·D_KL(P_T||P_S) + (1-α)·MSE(y_true, P_S)
- D) L = α·CE(P_T,P_S) + (1-α)·D_KL(y_true, P_S)

**27. What does α represent in distillation?**
- A) Learning rate
- B) Distillation weight
- C) Temperature
- D) Batch size

**28. How does distillation differ from quantization?**
- A) Distillation trains smaller model; quantization reduces precision
- B) Distillation reduces precision; quantization trains smaller model
- C) Same thing
- D) Opposite processes

**29. What is the typical compression ratio from distillation?**
- A) 1.5x
- B) 3-10x
- C) 100x
- D) 1000x

**30. What is the role of the teacher model?**
- A) Be fast and efficient
- B) Provide soft targets
- C) Replace student
- D) Train student on hard labels

**31. What is the combined loss in distillation?**
- A) Only distillation
- B) Only supervised
- C) Both distillation and supervised
- D) Neither

**32. What happens when T → 0?**
- A) Distribution becomes uniform
- B) Distribution becomes one-hot
- C) Becomes standard softmax
- D) Becomes random

**33. What is the purpose of the T² scaling?**
- A) Speed up computation
- B) Maintain gradient magnitudes
- C) Reduce memory
- D) Improve accuracy

**34. Which compression method gives best quality retention?**
- A) Distillation
- B) Quantization
- C) Pruning
- D) All equal

**35. What is the purpose of special tokens?**
- A) Make text colorful
- B) Control model behavior
- C) Speed up computation
- D) Reduce vocabulary

**36. What is "semantic space"?**
- A) Physical location
- B) High-dimensional embedding space
- C) Type of network
- D) Database of words

**37. What is the relationship between tokenization and embeddings?**
- A) Same thing
- B) Tokenization creates IDs; embeddings convert to vectors
- C) Embeddings create IDs; tokenization converts to vectors
- D) Unrelated

**38. What is the purpose of the [BOS] token?**
- A) End sequence
- B) Start sequence
- C) Padding
- D) Unknown tokens

**39. What is the purpose of KV caching?**
- A) To store model weights
- B) To avoid recomputing past tokens
- C) To reduce model size
- D) To improve accuracy

**40. What is the complexity improvement from KV caching?**
- A) O(n²) → O(n)
- B) O(n) → O(1)
- C) O(n²) → O(n²)
- D) O(n) → O(n²)

**41. What does the temperature parameter control?**
- A) Model size
- B) Randomness in generation
- C) Training speed
- D) Memory usage

**42. What's the difference between Top-K and Top-P?**
- A) Top-K keeps K most likely; Top-P keeps cumulative probability P
- B) Top-K keeps cumulative probability K; Top-P keeps P most likely
- C) They are the same
- D) Top-K is for training; Top-P is for inference

**43. Why do we need rate limiting?**
- A) To speed up the server
- B) To prevent abuse and ensure fair usage
- C) To reduce memory usage
- D) To improve accuracy

**44. What is the typical latency with KV cache?**
- A) < 1ms
- B) < 100ms
- C) < 1s
- D) < 10s

**45. What is the purpose of /health?**
- A) To generate text
- B) To check server status
- C) To list models
- D) To get statistics

**46. What happens when KV cache is full?**
- A) Server crashes
- B) Oldest entry is evicted (LRU)
- C) New entries are ignored
- D) All entries are cleared

**47. Which is NOT a generation parameter?**
- A) maxTokens
- B) temperature
- C) batchSize
- D) topP

**48. What is the purpose of repetition penalty?**
- A) Speed up generation
- B) Reduce repetition
- C) Increase accuracy
- D) Reduce memory

**49. What does throughput measure?**
- A) Time per request
- B) Requests per second
- C) Memory usage
- D) Model size

**50. What is the recommended batch size for inference?**
- A) 1
- B) 8-32
- C) 128-256
- D) 1024+

**51. Why is monitoring important?**
- A) Track performance and detect issues
- B) Speed up the server
- C) Reduce costs
- D) Improve accuracy

**52. What does /api/stats provide?**
- A) Model parameters
- B) Server and model statistics
- C) Generated text
- D) Training data

**53. What is the role of the student model?**
- A) Be large and accurate
- B) Learn from teacher's soft targets
- C) Replace teacher
- D) Train teacher

**54. What is cross-entropy used for?**
- A) Distillation loss
- B) Supervised loss
- C) Both distillation and supervised
- D) Neither

**55. What is KL divergence used for?**
- A) Distillation loss
- B) Supervised loss
- C) Both distillation and supervised
- D) Neither

**56. What is the purpose of the [SEP] token?**
- A) Start sequence
- B) Separate segments
- C) End sequence
- D) Unknown tokens

**57. What is the purpose of the [EOS] token?**
- A) Start sequence
- B) Separate segments
- C) End sequence
- D) Unknown tokens

**58. What is the purpose of the [MASK] token?**
- A) Start sequence
- B) Masked language modeling
- C) End sequence
- D) Unknown tokens

**59. What is the difference between attention and self-attention?**
- A) Attention is faster
- B) Self-attention uses Q,K,V from same sequence
- C) Attention is more accurate
- D) No difference

**60. What is the purpose of feed-forward networks in transformers?**
- A) Speed up computation
- B) Learn patterns in data
- C) Reduce memory
- D) Improve accuracy

### Part B: True/False (30 questions, 1 point each)

**61. LLMs are "thinking brains" that understand meaning.**

**62. Transformers process all tokens simultaneously.**

**63. BPE is the tokenization method used in most modern LLMs.**

**64. Higher embedding dimension always means better performance.**

**65. Multi-head attention uses different weights for each head.**

**66. Positional encodings are only needed for training, not inference.**

**67. The causal mask prevents looking at future tokens.**

**68. Greedy sampling always produces the best outputs.**

**69. Residual connections help prevent vanishing gradients.**

**70. Layer normalization is used in transformers.**

**71. Soft targets are one-hot labels.**

**72. Higher temperature reveals more dark knowledge.**

**73. Distillation requires more training data than pre-training.**

**74. Quantization reduces precision of weights.**

**75. Pruning removes unimportant weights.**

**76. Distillation gives better quality than quantization.**

**77. The T² scaling factor is optional in distillation.**

**78. Students learn from teacher's logits, not probabilities.**

**79. Distillation is only used for vision tasks.**

**80. Modern LLMs use transformers.**

**81. KV cache stores model weights.**

**82. KV cache speeds up generation by avoiding recomputation.**

**83. Temperature controls randomness in generation.**

**84. Top-K and Top-P are the same.**

**85. Rate limiting prevents abuse.**

**86. The /health endpoint checks server status.**

**87. LRU eviction is used when cache is full.**

**88. batchSize is a generation parameter.**

**89. Repetition penalty reduces repetition.**

**90. Throughput is measured in requests per second.**

### Part C: Fill-in-the-Blank (30 questions, 1 point each)

**91. BPE stands for __________.**

**92. The attention formula is Attention(Q,K,V) = __________ × V.**

**93. Cosine similarity ranges from __________ to __________.**

**94. __________ encodings use sin and cos functions.**

**95. The causal mask prevents looking at __________ tokens.**

**96. In distillation, the __________ provides soft targets.**

**97. The combined loss uses α to balance __________ and __________ losses.**

**98. Higher temperature makes the distribution __________.**

**99. __________ is the phase where the model learns language patterns.**

**100. Multi-head attention concatenates multiple __________.**

**101. The embedding matrix has shape [__________ × __________].**

**102. __________ sampling always picks the most likely token.**

**103. Special tokens control __________ behavior.**

**104. The __________ token handles unknown words.**

**105. Pre-training is for __________; alignment is for __________.**

**106. The [PAD] token makes sequences __________ length.**

**107. The __________ mask prevents looking at future tokens.**

**108. Distillation compresses models by __________x.**

**109. __________ is reducing precision of weights.**

**110. __________ removes unimportant weights.**

**111. KV cache stores __________ and __________ matrices.**

**112. KV cache improves complexity from __________ to __________.**

**113. __________ controls randomness in generation.**

**114. Top-K keeps the __________ most likely tokens.**

**115. Top-P keeps tokens with cumulative probability __________.**

**116. Rate limiting prevents __________.**

**117. The __________ endpoint checks server status.**

**118. LRU stands for __________.**

**119. batchSize is a __________ parameter.**

**120. Throughput is measured in __________.**

### Part D: Short Answer (15 questions, 2 points each)

**121. Explain why text must be converted to numbers for neural networks.**

**122. Describe the BPE tokenization algorithm and why it's effective.**

**123. Explain how the attention mechanism works and why it's important.**

**124. What is the purpose of multi-head attention?**

**125. Describe the difference between positional encodings and learned embeddings.**

**126. Explain the teacher-student paradigm in distillation.**

**127. What are soft targets and why are they important?**

**128. Explain how temperature affects distillation.**

**129. Describe the difference between distillation, quantization, and pruning.**

**130. Why are residual connections important in transformers?**

**131. What is KV caching and why is it important?**

**132. Explain the difference between Top-K and Top-P sampling.**

**133. Why do we need rate limiting in production?**

**134. What metrics should you monitor in production?**

**135. Describe the production architecture for serving LLMs.**

### Part E: Coding (3 questions, 10 points each)

**136. Implement a complete attention function.**

```javascript
function selfAttention(Q, K, V, mask = null, scale = null) {
    // Your code here
}
```

**137. Implement a distillation training step.**

```javascript
function distillationStep(student, teacher, tokenIds, config) {
    // Your code here
}
```

**138. Implement the KV cache get/set methods.**

```javascript
class KVCache {
    get(key) {
        // Your code here
    }
    set(key, keys, values, sequenceLength) {
        // Your code here
    }
}
```

---

## Final Exam Answer Key

### Part A: Multiple Choice

1. B
2. B
3. B
4. C
5. B
6. B
7. D
8. B
9. B
10. B
11. B
12. B
13. A
14. B
15. B
16. D
17. C
18. C
19. B
20. B
21. C
22. A
23. B
24. B
25. B
26. A
27. B
28. A
29. B
30. B
31. C
32. B
33. B
34. A
35. B
36. B
37. B
38. B
39. B
40. A
41. B
42. A
43. B
44. B
45. B
46. B
47. C
48. B
49. B
50. A
51. A
52. B
53. B
54. B
55. A
56. B
57. C
58. B
59. B
60. B

### Part B: True/False

61. False
62. True
63. True
64. False
65. True
66. False
67. True
68. False
69. True
70. True
71. False
72. True
73. False
74. True
75. True
76. True
77. False
78. False
79. False
80. True
81. False
82. True
83. True
84. False
85. True
86. True
87. True
88. False
89. True
90. True

### Part C: Fill-in-the-Blank

91. Byte-Pair Encoding
92. softmax(Q × K^T / √d_k)
93. -1, 1
94. Positional (or Sinusoidal)
95. future
96. teacher
97. distillation, supervised
98. softer
99. Pre-training
100. heads
101. Vocabulary, Embedding Dimension
102. Greedy
103. model
104. [UNK]
105. language patterns, behavior
106. uniform
107. causal
108. 3-10
109. Quantization
110. Pruning
111. Key, Value
112. O(n²), O(n)
113. Temperature
114. K
115. P
116. abuse
117. /health
118. Least Recently Used
119. training
120. requests per second

### Part D: Short Answer

**121.** Neural networks operate on numbers, not words. Text must be converted to numerical representations that preserve semantic meaning.

**122.** BPE starts with character-level tokens, repeatedly merges the most frequent adjacent pair, and continues until target vocabulary size is reached. It's effective because it balances vocabulary size and coverage, handling unknown words by splitting them into known subwords.

**123.** Attention computes relevance between tokens using Q, K, V matrices. It's important because it enables global reasoning, parallel processing, and long-range dependencies.

**124.** Multi-head attention allows the model to capture different types of relationships (syntax, semantics, long-range, positional) simultaneously.

**125.** Positional encodings are deterministic (sinusoidal functions) and add position information. Learned embeddings are trainable parameters that learn position representations from data.

**126.** The teacher (large model) provides soft targets to the student (small model). The student learns to mimic the teacher's behavior through distillation.

**127.** Soft targets are probability distributions from the teacher. They carry "dark knowledge" about relationships between classes, helping the student generalize better.

**128.** Higher temperature softens the distribution, revealing more dark knowledge. Lower temperature makes the distribution sharper, focusing on the most likely classes.

**129.** Distillation trains a smaller model; quantization reduces precision (FP32→INT8); pruning removes unimportant weights. Distillation gives best quality, quantization requires no training, pruning is simple.

**130.** Residual connections add the input to the output of a layer, preventing vanishing gradients in deep networks by providing a direct path for gradients.

**131.** KV caching stores key and value matrices from previous tokens, avoiding recomputation. This reduces complexity from O(n²) to O(n), dramatically speeding up generation.

**132.** Top-K keeps the K most likely tokens. Top-P keeps the smallest set of tokens with cumulative probability P. Top-P is more adaptive as it adjusts to the distribution shape.

**133.** Rate limiting prevents abuse by limiting requests per client. It ensures fair usage and protects the server from overload.

**134.** Key metrics: latency (p50, p90, p99), tokens per second, memory usage, cache hit rate, queue depth, error rate.

**135.** Production architecture: Client → Express API → Middleware (logging, auth, rate limiting) → Generation Engine (KV cache, sampling) → Model Runtime → Response.

### Part E: Coding

**136. Self-Attention Implementation:**

```javascript
function selfAttention(Q, K, V, mask = null, scale = null) {
    const d_k = Q[0].length;
    const scaleFactor = scale || Math.sqrt(d_k);
    
    // Q × K^T
    const K_T = K[0].map((_, colIdx) => K.map(row => row[colIdx]));
    const scores = Q.map(qRow => 
        K_T.map(kCol => {
            let sum = 0;
            for (let i = 0; i < qRow.length; i++) {
                sum += qRow[i] * kCol[i];
            }
            return sum / scaleFactor;
        })
    );
    
    // Apply mask if provided
    let maskedScores = scores;
    if (mask) {
        maskedScores = scores.map((row, i) => 
            row.map((val, j) => mask[i][j] ? val : -1e9)
        );
    }
    
    // Softmax
    const weights = maskedScores.map(row => {
        const max = Math.max(...row);
        const exp = row.map(v => Math.exp(v - max));
        const sum = exp.reduce((a, b) => a + b, 0);
        return exp.map(v => v / sum);
    });
    
    // Multiply by V
    const output = weights.map(row => {
        const out = [];
        for (let j = 0; j < V[0].length; j++) {
            let sum = 0;
            for (let i = 0; i < row.length; i++) {
                sum += row[i] * V[i][j];
            }
            out.push(sum);
        }
        return out;
    });
    
    return { output, weights };
}
```

**137. Distillation Training Step:**

```javascript
function distillationStep(student, teacher, tokenIds, config) {
    const temperature = config.temperature || 2.0;
    const alpha = config.alpha || 0.7;
    
    // Get teacher soft targets
    const teacherOutput = teacher.getSoftTargets(tokenIds, temperature);
    
    // Forward pass through student
    const studentOutput = student.forward(tokenIds);
    const studentLogits = studentOutput.logits;
    
    // Compute distillation loss (KL divergence)
    const studentProbs = studentLogits.map(row => {
        const scaled = row.map(l => l / temperature);
        const max = Math.max(...scaled);
        const exp = scaled.map(v => Math.exp(v - max));
        const sum = exp.reduce((a, b) => a + b, 0);
        return exp.map(v => v / sum);
    });
    
    let distLoss = 0;
    let count = 0;
    for (let i = 0; i < studentProbs.length; i++) {
        if (i >= teacherOutput.probabilities.length) break;
        let kl = 0;
        for (let j = 0; j < teacherOutput.probabilities[i].length; j++) {
            if (teacherOutput.probabilities[i][j] > 0 && studentProbs[i][j] > 0) {
                kl += teacherOutput.probabilities[i][j] * 
                      Math.log(teacherOutput.probabilities[i][j] / studentProbs[i][j]);
            }
        }
        distLoss += kl;
        count++;
    }
    distLoss = count > 0 ? distLoss / count : 0;
    
    // Compute supervised loss (cross-entropy)
    let supLoss = 0;
    count = 0;
    for (let i = 0; i < studentLogits.length - 1; i++) {
        const targetId = tokenIds[i + 1];
        const probs = studentLogits[i].map(l => {
            const max = Math.max(...studentLogits[i]);
            const exp = studentLogits[i].map(v => Math.exp(v - max));
            const sum = exp.reduce((a, b) => a + b, 0);
            return exp.map(v => v / sum);
        });
        supLoss -= Math.log(probs[targetId] + 1e-8);
        count++;
    }
    supLoss = count > 0 ? supLoss / count : 0;
    
    const totalLoss = alpha * distLoss + (1 - alpha) * supLoss;
    
    return {
        totalLoss,
        distillationLoss: distLoss,
        supervisedLoss: supLoss,
        alpha,
        temperature
    };
}
```

**138. KV Cache Implementation:**

```javascript
class KVCache {
    get(key) {
        this.stats.totalRequests++;
        
        const entry = this.cache.get(key);
        if (!entry) {
            this.stats.misses++;
            return null;
        }
        
        // Check TTL
        if (Date.now() - entry.timestamp > this.ttl * 1000) {
            this.cache.delete(key);
            this._updateLRU(key, false);
            this.stats.misses++;
            return null;
        }
        
        this._updateLRU(key, true);
        this.stats.hits++;
        
        return {
            keys: entry.keys,
            values: entry.values,
            sequenceLength: entry.sequenceLength
        };
    }
    
    set(key, keys, values, sequenceLength) {
        // Evict if full
        if (this.cache.size >= this.maxSize) {
            this._evictLRU();
        }
        
        this.cache.set(key, {
            keys: keys,
            values: values,
            sequenceLength: sequenceLength,
            timestamp: Date.now()
        });
        
        this._updateLRU(key, true);
        this.stats.cacheSize = this.cache.size;
    }
}
```

---

# GRADING RUBRIC

## Final Exam Grading (200 points total)

| Section | Questions | Points per Question | Total Points |
|---------|-----------|-------------------|--------------|
| A: Multiple Choice | 60 | 1 | 60 |
| B: True/False | 30 | 1 | 30 |
| C: Fill-in-the-Blank | 30 | 1 | 30 |
| D: Short Answer | 15 | 2 | 30 |
| E: Coding | 3 | 10 | 30 |
| **Total** | **138** | - | **180** |

*Note: 20 points are for comprehensive answers and code quality*

### Grade Scale

| Percentage | Grade |
|------------|-------|
| 90-100% | A |
| 80-89% | B |
| 70-79% | C |
| 60-69% | D |
| <60% | F |

---

**[END OF QUIZ AND TEST BANK]**


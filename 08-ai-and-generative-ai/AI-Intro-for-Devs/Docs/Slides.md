# AI Tutorial Series: Developer Edition
# Comprehensive Slide Outline

**A complete, expanded slide deck outline for teaching the AI Tutorial Series as an instructor-led or self-paced course.**

---

## Course Overview

| Attribute | Details |
|-----------|---------|
| **Course Title** | AI Tutorial Series: Developer Edition |
| **Target Audience** | Software engineers (1-5 years experience), technical product managers |
| **Prerequisites** | Basic Python, command line, REST APIs, JSON |
| **Format** | Instructor-led training (ILT) or self-paced |
| **Total Duration** | 7 Phases × 3-4 hours = ~24-28 hours of instruction |
| **Delivery Method** | Lectures + hands-on coding + capstone projects |
| **Key Materials** | Slide decks, code repositories, hands-on exercises, capstone project templates |

---

## PHASE 1: Understanding How LLMs Actually Work
### Module 1: Introduction to Generative AI

#### Slide 1: Title Slide
**Phase 1: Understanding How LLMs Actually Work**
- Subtitle: From "AI Magic" to Engineering Reality
- Module 1: Introduction to Generative AI
- Duration: ~45 minutes
- Key Takeaway: Build the correct mental model of what AI actually is

#### Slide 2: Course Introduction
- Welcome to the AI Tutorial Series: Developer Edition
- What this series is: a code-first, hands-on journey
- What this series is NOT: theoretical academic course
- The roadmap: 7 phases, 24 modules, 8 capstone projects

#### Slide 3: The Problem This Course Solves
- The common pattern: read blog post → copy code → hit wall → feel stuck
- Between "beginner tutorials" and "research papers" lies the gap
- You will learn by building, not just reading 
- "Understand by building" philosophy

#### Slide 4: What You'll Build (Ultimate Architecture)
- AI Gateway Layer: routing, caching, authentication, rate limiting
- Core AI Services: chat, RAG, function calling, agent orchestration
- Memory & Knowledge: vector DB, semantic cache, knowledge graphs
- External Systems: LLM providers, APIs, data sources

#### Slide 5: Target Audience
- Software engineers with 1-5 years experience
- Technical product managers and engineering managers
- What you need: Python, command line, Git, REST APIs, JSON
- What you don't need: machine learning theory, linear algebra, neural networks

#### Slide 6: What Is AI? (Overview)
- Artificial Intelligence: simulation of human intelligence in machines
- The long-standing question: Can machines think? 
- The "AI effect": what was once called AI becomes "just software"
- Machines can act intelligently without "thinking" like humans 

#### Slide 7: Evolution from NLP to Generative AI
- 1960s-1980s: Rule-based systems → "If this, then that"
- 1990s-2000s: Statistical NLP → word counts, probabilities
- 2010s: Deep Learning NLP → neural networks learning patterns
- 2018-Present: Generative AI → creating new text, understanding context

#### Slide 8: The Key Breakthrough: The Transformer
- "Attention Is All You Need" (Vaswani et al., 2017) 
- Process all words simultaneously, not sequentially
- Attention: understand how each word relates to every other word
- Foundation of every major LLM: GPT, Claude, Gemini, Llama

#### Slide 9: Popular Model Families
- GPT (OpenAI): GPT-3.5, GPT-4, GPT-4o → general purpose, reasoning
- Claude (Anthropic): Claude 3, 3.5 → safety, reasoning, analysis
- Gemini (Google): Gemini Pro, Ultra → multimodal, integration
- Llama (Meta): Llama 2, 3 → open-source, custom deployment
- Mistral (Mistral AI): Mistral 7B, Mixtral → open-source, efficiency

#### Slide 10: LLMs Are Pattern-Matching Machines
- The core principle: prediction of the next token 
- Smartphone autocomplete on a massive scale 
- Trained on vast amounts of text to learn statistical patterns
- NOT "thinking" or "understanding"—pattern recognition and continuation

#### Slide 11: Demo: Your First API Call
- Set up OpenAI API key
- The "Hello World" of AI development
- Understanding the response structure
- Token usage and cost implications

#### Slide 12: System Prompts Change Behavior
- System prompt = job description / persona
- The same question with different system prompts yields different answers
- This is one of the most powerful prompt engineering techniques 

#### Slide 13: Streaming Responses
- Real-time vs. batch generation
- User experience benefits
- Implementation pattern: generator functions
- When to use streaming vs. complete responses

#### Slide 14: Key Takeaways
- LLMs are pattern-matching machines, not "thinking" entities
- Transformers made modern AI possible
- Different models are different tools for different jobs
- API calls cost money—understand token usage
- System prompts control behavior

---

### Module 2: Tokens & Embeddings

#### Slide 1: Title Slide
**Module 2: Tokens & Embeddings**
- How text becomes numbers
- Duration: ~1 hour

#### Slide 2: The Building Blocks Analogy
- Characters = too small to build with efficiently
- Words = convenient but limited
- Tokens = the sweet spot
- Embeddings = the instruction manual
- Computers don't understand words—they understand numbers

#### Slide 3: What Are Tokens?
- A token is the smallest unit of text an LLM processes
- A token can be a word: "cat" → ["cat"]
- A token can be part of a word: "running" → ["run", "ning"]
- A token can be punctuation: "." → ["."]
- A token can be a space: " " → [" "]

#### Slide 4: Why Not Just Words?
- ~500,000 words in English
- Words have variations: run, runs, running, ran
- Some languages don't use spaces
- Solution: 50,000-100,000 balanced token vocabulary

#### Slide 5: Tokenization Algorithms
- BPE (Byte-Pair Encoding): iteratively merges frequent character pairs 
  - Start with characters, merge most frequent pairs
  - Used by GPT models, RoBERTa
- SentencePiece: treats spaces as characters
  - Treats text as stream of Unicode characters
  - Used by T5, Llama, Gemma

#### Slide 6: Token Counting Demo
- Count tokens with tiktoken
- Visualize token boundaries
- Compare tokenization across models
- Understand token limits and pricing

#### Slide 7: What Are Embeddings?
- Embedding: a vector (list of numbers) representing meaning
- "cat" → [0.123, -0.456, 0.789, 0.234, -0.567, ...] (1536 numbers)
- Similar meanings have similar vectors
- Embeddings capture semantic meaning mathematically

#### Slide 8: Why Embeddings Are Powerful
- Semantic similarity: "cat" is close to "kitten", far from "airplane"
- Mathematical operations: "king" - "man" + "woman" ≈ "queen"
- Search: find documents that mean the same thing, not just words
- Clustering: group similar content automatically

#### Slide 9: Cosine Similarity
- Measures similarity between vectors
- The angle between vectors—smaller angle = more similar
- Range: -1 (opposite) to 1 (identical)
- For text embeddings: typically 0 to 1
- Formula: cosine_similarity(A, B) = (A · B) / (||A|| × ||B||)

#### Slide 10: Embedding Models Comparison
| Model | Dimensions | Cost ($/1M tokens) | Use Case |
|-------|------------|-------------------|----------|
| text-embedding-3-small | 1536 | $0.02 | General purpose |
| text-embedding-3-large | 3072 | $0.13 | Highest accuracy |
| text-embedding-ada-002 | 1536 | $0.02 | Legacy |
| BAAI/bge-large-en-v1.5 | 1024 | Free (local) | Open source |
| sentence-transformers/all-MiniLM-L6-v2 | 384 | Free (local) | Lightweight |

#### Slide 11: Demo: Generate Embeddings
- Generating embeddings for text chunks
- Understanding embedding properties
- Visualizing embedding dimensions
- Token usage and cost

#### Slide 12: Demo: Semantic Similarity
- Compare embeddings of different texts
- "cat" vs. "dog" vs. "airplane"
- Similarity scores in real-time
- Understanding the semantic space

#### Slide 13: Demo: Semantic Search
- Building a basic semantic search engine
- Querying with meaning, not just keywords
- Matching semantically related documents
- Finding relevant content by meaning

#### Slide 14: The "King - Man + Woman" Demo
- Mathematical operations in embedding space
- Demonstrates semantic relationships
- Encoded in the vectors: gender, relationships
- Why this is so powerful for understanding language

#### Slide 15: Key Takeaways
- Tokens are chunks of text—different from words
- Different models use different tokenizers
- Token count = cost (less tokens = cheaper)
- Embeddings capture meaning in vector form
- Similar meanings = similar embeddings
- Cosine similarity measures semantic similarity
- Embeddings are the foundation of RAG

---

### Module 3: How LLM Inference Works

#### Slide 1: Title Slide
**Module 3: How LLM Inference Works**
- Peeking under the hood of text generation
- Duration: ~1 hour

#### Slide 2: The Prediction Machine Analogy
- Game: "What comes next?" 
- "The cat sat on the..." → "mat" (most likely), "floor", "roof", "moon"
- LLM does this at scale, for every token
- The model calculates probability of every possible next token

#### Slide 3: The Complete Inference Process
- Step 1: Input Processing → Tokens → Embeddings
- Step 2: Forward Pass → Logits (raw scores for each token)
- Step 3: Softmax → Probabilities (0 to 1, sum to 1)
- Step 4: Sampling Strategy → Temperature, Top-K, Top-P
- Step 5: Choose Next Token → Sample from distribution or pick highest
- Step 6: Append and Repeat → Add token and continue

#### Slide 4: Temperature: The Creativity Dial 
- Temperature = 0.0: Greedy, deterministic, boring
- Temperature = 0.5: Balanced, mostly likely tokens
- Temperature = 1.0: Creative, broader distribution
- Temperature = 1.5+: Highly creative, often nonsensical
- Math: P(token) = softmax(logits / temperature)

#### Slide 5: Temperature Use Cases
| Temperature | Use Case | Example |
|-------------|----------|---------|
| 0.0 | Code generation, data extraction | "Extract the email from this text" |
| 0.3 | Factual answers, Q&A | "What is the capital of France?" |
| 0.7 | General chat, creative writing | "Write a story about a robot" |
| 1.0 | Brainstorming, poetry | "Write a poem about AI" |

#### Slide 6: Top-K: Limiting Candidates
- Consider only the K most likely tokens
- K = 5: only top 5 tokens considered
- Removes absurdly unlikely tokens
- Speeds up generation
- Prevents the model from going off the rails

#### Slide 7: Top-P (Nucleus Sampling)
- Dynamic filtering: keep tokens until cumulative probability reaches P%
- Top-P = 0.9: include tokens until 90% probability mass is reached
- Adapts to the situation—more flexible than Top-K
- If probabilities spread out, includes more tokens
- If probabilities concentrated, includes fewer tokens

#### Slide 8: The Combined Effect
- Temperature changes the shape of the distribution
- Top-K removes all but the top K tokens
- Top-P further filters to the top P% of probability mass
- Sampling chooses one token from the remaining distribution
- Different combinations for different use cases

#### Slide 9: Demo: Temperature Experiments
- Generate text with temperature 0.0, 0.5, 1.0, 1.5
- See how output changes
- Understand the trade-off between creativity and coherence
- Observe the "greedy" vs "random" behavior

#### Slide 10: Demo: Top-P Experiments
- Generate text with Top-P 0.3, 0.5, 0.7, 0.9, 1.0
- Observe how it affects output
- Understand the impact on token selection
- Compare different sampling strategies

#### Slide 11: Hallucinations Explained 
- What are hallucinations? AI generating incorrect information confidently
- "Worst AI lie" - AI is confidently wrong 
- Real-world examples: Air Canada chatbot case (2024), lawyer using fake cases 
- Why they happen:
  1. Model is a pattern-matching machine
  2. Training data imperfections
  3. Confidence mismatches
  4. Out-of-distribution prompts

#### Slide 12: How to Reduce Hallucinations 
- Lower temperature → more deterministic
- Use RAG → ground the model in facts
- Chain-of-Thought → force step-by-step reasoning
- Self-consistency → generate multiple times, choose most common
- Better prompts → be explicit about facts
- Verification → cross-check with external systems

#### Slide 13: Key Takeaways
- LLMs predict the next token (one at a time) 
- Temperature controls creativity (0 = greedy, >1 = random)
- Top-K limits token candidates (faster, more focused)
- Top-P dynamically filters candidates (more natural)
- Hallucinations happen when patterns don't match reality
- Lower temperature = less hallucination
- Choose parameters based on use case

---

### Module 4: Context Windows & Memory

#### Slide 1: Title Slide
**Module 4: Context Windows & Memory**
- Understanding the "short-term memory" of LLMs
- Duration: ~1 hour

#### Slide 2: The Whiteboard Analogy
- Context Window = size of the whiteboard 
- Input Tokens = everything on the whiteboard
- Output Tokens = what you write in response
- Total Tokens = everything on the whiteboard at once
- When you write too much, you must erase old information

#### Slide 3: Context Window Comparison
| Model | Context Window | Approximate Pages of Text |
|-------|---------------|---------------------------|
| GPT-3.5 | 16,384 | ~40 pages |
| GPT-4-Turbo | 128,000 | ~300 pages |
| GPT-4o | 128,000 | ~300 pages |
| Claude 3.5 | 200,000 | ~500 pages |
| Gemini 1.5 | 2,000,000 | ~5,000 pages |
| Llama 3 | 128,000 | ~300 pages |

#### Slide 4: Tokens vs. Characters
- Approximate: 1 token ≈ 4 characters in English
- 1 token ≈ 0.75 words in English
- Japanese/Chinese: 1 token ≈ 1-3 characters 
- Context window capacity varies by language

#### Slide 5: What Happens When You Exceed Context
- API rejects the request (most common)
- Model truncates input (oldest messages dropped)
- Model's performance degrades
- You lose important context
- Your application crashes

#### Slide 6: Memory Management Strategies 
1. **Truncation:** Drop oldest messages—simple but loses context
2. **Sliding Window:** Keep recent messages—better for ongoing conversations
3. **Summarization:** Condense old messages—preserves key info, expensive
4. **Hierarchical Memory:** Multiple levels of memory—best retention, complex

#### Slide 7: Truncation
- Keep only the last N messages
- messages = messages[-max_messages:]
- Pro: simple, fast
- Con: loses important context

#### Slide 8: Sliding Window
- Keep system prompt + last N messages + current question
- Keep system prompt + recent messages
- Pro: keeps recent context
- Con: loses long-term memory

#### Slide 9: Summarization
- Condense old messages into a summary
- summary = summarize_with_llm(old_messages)
- Pro: preserves key information
- Con: expensive (calls LLM), loses details

#### Slide 10: Hierarchical Memory
- Level 1: Immediate context (last N messages)
- Level 2: Recent history (summarized)
- Level 3: Long-term memory (vector database)
- Pro: best retention
- Con: complex, expensive

#### Slide 11: Demo: Simple Chatbot
- Build a chatbot with conversation history
- Track token usage in real-time
- See what happens when you exceed the context window
- Implement basic memory management

#### Slide 12: Demo: Context Overflow Detector
- Detect when you're approaching context limits
- Visualize token usage
- Predict when overflow will occur
- Implement automatic truncation

#### Slide 13: Demo: Token Usage Tracker
- Track token usage across requests
- Calculate costs in real-time
- Budget monitoring and alerts
- Understand usage patterns

#### Slide 14: Key Takeaways
- Context window = how much the model can "remember"
- Every message adds tokens to the context
- Exceeding the window = error or lost memory
- Memory management is essential for long conversations
- Strategies: truncate, slide, summarize, prioritize
- Different models have different context sizes
- Token usage = cost (manage it carefully)

---

## PHASE 2: Prompt Engineering & Model APIs
### Module 5: AI APIs

#### Slide 1: Title Slide
**Phase 2: Prompt Engineering & Model APIs**
- Module 5: AI APIs
- Duration: ~1 hour

#### Slide 2: The Restaurant Analogy
- Each restaurant = API provider (OpenAI, Anthropic, Google)
- Menu = API endpoints
- Ordering system = authentication
- Delivery times = latency
- Pricing = cost
- Your app = unified ordering system

#### Slide 3: Provider Comparison
| Feature | OpenAI | Anthropic | Google | Ollama |
|---------|--------|-----------|--------|--------|
| Models | GPT-4, GPT-3.5 | Claude 3.5 | Gemini | Llama, Mistral |
| Pricing | Per token | Per token | Per token | Free |
| Streaming | ✅ | ✅ | ✅ | ✅ |
| Function Calling | ✅ | ✅ | ✅ | Limited |
| Vision | ✅ | ✅ | ✅ | Limited |
| Context Window | 128K | 200K | 2M | Varies |

#### Slide 4: Authentication Methods
- OpenAI: `Authorization: Bearer sk-...`
- Anthropic: `x-api-key: sk-ant-...`
- Google: `?key=AIza...` or Bearer token
- Ollama: None (local)
- OpenRouter: `Authorization: Bearer sk-or-...`

#### Slide 5: Rate Limits: The Hidden Constraint
- Types: RPM (requests/minute), TPM (tokens/minute)
- What happens: HTTP 429 Too Many Requests
- Handle with: exponential backoff, retry with jitter, queue requests, circuit breaker
- Monitor usage to avoid hitting limits

#### Slide 6: Cost Optimization Strategies
| Strategy | Savings | How |
|----------|---------|-----|
| Model Selection | 50-90% | Cheaper models for simple tasks |
| Prompt Optimization | 20-40% | Shorten prompts, remove redundancy |
| Caching | 30-90% | Cache identical requests |
| Batching | 10-30% | Batch multiple requests together |

#### Slide 7: Model Pricing (as of 2024)
| Model | Input ($/1M tokens) | Output ($/1M tokens) |
|-------|---------------------|----------------------|
| gpt-4o | $5.00 | $15.00 |
| gpt-4o-mini | $0.150 | $0.600 |
| gpt-3.5-turbo | $0.50 | $1.50 |
| claude-3.5-sonnet | $3.00 | $15.00 |
| claude-3-haiku | $0.25 | $1.25 |
| gemini-1.5-pro | $2.50 | $7.50 |
| gemini-1.5-flash | $0.35 | $1.05 |

#### Slide 8: Demo: Multi-Provider Client
- Build a unified client for multiple providers
- Same interface for all providers
- Provider-agnostic application design
- Switch providers with a single configuration change

#### Slide 9: Demo: Streaming Responses
- Real-time text generation
- User experience benefits
- Implementation with generator functions
- Server-Sent Events (SSE) for web applications

#### Slide 10: Demo: Rate Limit Manager
- Implement token bucket algorithm
- Exponential backoff with jitter
- Circuit breaker pattern
- Request queuing

#### Slide 11: Demo: Cost Optimizer
- Estimate costs for different models
- Choose the cheapest model for each task
- Budget management and alerts
- Usage forecasting

#### Slide 12: Key Takeaways
- Different providers have different APIs, features, and pricing
- A unified client abstracts these differences
- Rate limits require careful management
- Costs vary significantly between models
- Route tasks to the right model for cost optimization
- Always have fallback strategies

---

### Module 6: Prompt Engineering Fundamentals

#### Slide 1: Title Slide
**Module 6: Prompt Engineering Fundamentals**
- Communicating effectively with LLMs
- Duration: ~1.5 hours

#### Slide 2: The Interviewer Analogy
- System prompt = job description and instructions
- User prompt = the specific question
- Assistant message = the response
- Few-shot examples = showing examples of good answers
- Chain-of-Thought = asking the expert to "think out loud"

#### Slide 3: The Four Types of Prompts
| Type | What It Is | Example |
|------|------------|---------|
| **System** | Instructions about how to behave | "You are a helpful assistant. Be concise." |
| **User** | The actual question or task | "What is the capital of France?" |
| **Assistant** | Previous responses (for context) | "The capital of France is Paris." |
| **Tool** | Function definitions | `{"name": "get_weather", ...}` |

#### Slide 4: Good vs. Bad Prompts 
- Bad prompt: "Write an email" (too vague)
- Good prompt: "Write a polite email to Tanaka-san about rescheduling the Wednesday meeting"
- AI is "super capable but can't read the room" 
- Be specific: who, what, tone, format
- You can always follow up with "make it shorter" or "bullet points"

#### Slide 5: The 3 Elements of a Good Prompt 
1. **Role:** Who should answer? (e.g., "You are a veteran sales manager")
2. **Task:** What to do? (e.g., "Create a proposal draft")
3. **Conditions:** How to output? (e.g., "Bullet points", "3 items", "within 300 characters")

#### Slide 6: System Prompt Templates
- Helpful Assistant: clear, accurate, respectful
- Expert Consultant: strategic advice, direct, confident
- Creative Writer: vivid, imaginative, descriptive
- Technical Expert: precise, technical, code examples
- Teacher: patient, simple explanations, analogies

#### Slide 7: Chain-of-Thought (CoT) 
- Ask the AI to show its reasoning step by step
- Significantly improves accuracy on reasoning tasks 
- "Let's think step by step" unlocks reasoning capabilities 
- Example: "Solve this step by step: 1. Start with 3 apples..."

#### Slide 8: Few-Shot Learning 
- Provide examples of the desired input-output format
- The model generalizes from examples with no weight updates 
- Example: "Input: 'John, 32' → Output: {'name': 'John', 'age': 32}"
- Dramatically improves consistency and format adherence

#### Slide 9: Self-Consistency
- Generate multiple responses and take the most consistent one
- Example: Generate 3 responses, take the most common
- Improves accuracy for critical decisions
- Increases cost (3× tokens)

#### Slide 10: Prompt Templates
- Reusable prompt structures
- Variables: {{variable}}
- Conditionals: {% if variable %}content{% endif %}
- Loops: {% for item in items %}content{% endfor %}
- Filters: {{variable|upper}}, {{variable|truncate:100}}

#### Slide 11: Demo: System Prompt Designer
- Compare different system prompts
- Test different personas
- Analyze effectiveness
- Get recommendations for different use cases

#### Slide 12: Demo: Chain-of-Thought
- Compare standard vs. CoT prompts
- Math problems, logical reasoning
- See the improvement in accuracy
- Understand when to use CoT

#### Slide 13: Demo: Few-Shot Learning
- Zero-shot vs. few-shot comparison
- See how examples improve performance
- Different tasks: classification, extraction
- Understand when to use few-shot

#### Slide 14: Demo: Prompt Playground
- Interactive prompt testing
- System prompt switching
- Temperature adjustment
- Template usage

#### Slide 15: Key Takeaways
- System prompts set the AI's persona and behavior
- User prompts are the actual questions/tasks
- Chain-of-Thought forces step-by-step reasoning
- Few-shot examples improve performance
- Self-consistency finds consensus across responses
- Templates make prompts reusable and maintainable

---

### Module 7: Structured Outputs

#### Slide 1: Title Slide
**Module 7: Structured Outputs**
- Getting data, not just text
- Duration: ~1.5 hours

#### Slide 2: The Data Entry Clerk Analogy
- Without structure: paragraphs of text, manual extraction needed
- With structure: a form with labeled fields, clean data every time
- LLMs are the same—give them a structure and get reliable data

#### Slide 3: Why Structured Outputs Matter
- Reliability: consistent format every time
- Automation: direct integration with databases
- Validation: type checking and schema validation
- Cost: shorter, more precise prompts
- Debugging: clear, parseable errors

#### Slide 4: Common Formats
- JSON (Most Common): `{"name": "John", "age": 32}`
- JSON Schema: defines the expected structure
- XML: `<person><name>John</name></person>`

#### Slide 5: Techniques for Structured Outputs
| Technique | How It Works | Pros | Cons |
|-----------|--------------|------|------|
| JSON Mode | API enforces JSON | Reliable, fast | Limited models |
| Prompt Engineering | Ask for JSON explicitly | Works with any model | Sometimes fails |
| Schema Validation | Validate after generation | Ensures quality | Extra processing |
| Function Calling | Use tool definitions | Structured, typed | API support needed |

#### Slide 6: JSON Schema Validation
- Define the expected structure
- Type checking: string, integer, number, boolean, array, object
- Required fields
- Format validation: email, date, uri
- Range validation: minimum, maximum

#### Slide 7: Demo: Email Parser
- Extract structured data from emails
- Sender, recipients, subject, body
- Actions, entities, sentiment, urgency
- Integration with email systems

#### Slide 8: Demo: Resume Parser
- Extract structured data from resumes
- Personal info, experience, education
- Skills, certifications, projects
- Integration with HR systems

#### Slide 9: Demo: Invoice Extractor
- Extract structured data from invoices
- Invoice details, vendor, customer
- Line items, totals, payment terms
- Integration with accounting systems

#### Slide 10: Key Takeaways
- Structured outputs turn LLMs into data processing
- JSON is the most common structured format
- JSON Schema validates data quality
- Schemas define required fields and types
- Type coercion handles common conversion issues
- Error reporting helps debug parsing issues

---

### Module 8: Multimodal AI

#### Slide 1: Title Slide
**Module 8: Multimodal AI**
- Images, audio, and beyond
- Duration: ~1 hour

#### Slide 2: The Sensory Analogy
- Humans process text (language), images (visual), sounds (audio)
- Multimodal AI does the same
- Enable applications that understand the world more like humans do
- Process and generate across multiple data types

#### Slide 3: Multimodal Model Types
| Type | Models | Input | Output | Use Cases |
|------|--------|-------|--------|-----------|
| Vision-Language | GPT-4o, Gemini, Claude 3.5 | Image + Text | Text | Image description, visual QA |
| Text-to-Image | DALL-E, Stable Diffusion | Text | Image | Image generation, art |
| Speech-to-Text | Whisper | Audio | Text | Transcription, captions |
| Text-to-Speech | ElevenLabs, TTS | Text | Audio | Voice synthesis |

#### Slide 4: Vision Understanding
- Image classification: what's in the image?
- Object detection: where are specific objects?
- Image captioning: describe the image in text
- Visual Q&A: answer questions about images
- OCR: extract text from images

#### Slide 5: Audio Processing
- Speech recognition: transcribe spoken words
- Speaker diarization: identify who's speaking
- Language identification: detect the language
- Sentiment analysis: detect emotion in speech

#### Slide 6: Image Generation
- Text-to-image: create images from descriptions
- Image-to-image: transform existing images
- Inpainting: fill in missing parts
- Style transfer: apply artistic styles

#### Slide 7: Demo: Vision Understanding
- Analyze images with multimodal models
- Describe image content
- Answer questions about images
- Extract text from images (OCR)

#### Slide 8: Demo: Speech-to-Text
- Transcribe audio with Whisper
- Language detection
- Translation
- Timestamp generation

#### Slide 9: Demo: Image Generation
- Generate images from text prompts
- Different styles and sizes
- Quality control
- Multiple variations

#### Slide 10: Key Takeaways
- Multimodal AI processes text, images, and audio
- Vision models understand and describe images
- OCR extracts text from images and documents
- Speech-to-text converts audio to text
- Text-to-speech converts text to audio
- Image generation creates images from text

---

## PHASE 3: AI Tool Use & Function Calling
### Module 9: Function Calling

#### Slide 1: Title Slide
**Phase 3: AI Tool Use & Function Calling**
- Module 9: Function Calling
- Duration: ~1.5 hours

#### Slide 2: The Chef Analogy
- LLM = master chef creating amazing recipes
- Assistant 1 (Weather Tool) = checks the weather
- Assistant 2 (Calculator Tool) = scales recipes
- Assistant 3 (Database Tool) = looks up ingredient prices
- Assistant 4 (Email Tool) = sends the final recipe
- Function calling = the LLM orchestrating these assistants

#### Slide 3: What Is Function Calling?
- LLM recognizes when a function needs to be called
- LLM generates a properly formatted function call
- Your code executes the function
- The result is incorporated into the conversation

#### Slide 4: Function Calling Flow
- Define the functions: `def get_weather(location)`
- Define the tool schemas: JSON descriptions of the functions
- User asks a question: "What's the weather in Paris?"
- LLM decides to call the function
- Execute the function
- Return the result to the LLM
- LLM generates a natural language response

#### Slide 5: Function Schemas
```json
{
  "type": "function",
  "function": {
    "name": "get_weather",
    "description": "Get current weather for a location",
    "parameters": {
      "type": "object",
      "properties": {
        "location": {"type": "string", "description": "City name"}
      },
      "required": ["location"]
    }
  }
}
```

#### Slide 6: Tool Registry
- Register functions with their schemas
- List available functions
- Get function schemas for the LLM
- Execute functions by name

#### Slide 7: Demo: Calculator Tool
- Safe mathematical expression evaluation
- Supported operations: +, -, *, /, power, sqrt, trig, log
- Precision control
- Error handling for invalid expressions

#### Slide 8: Demo: Weather Tool
- Get weather for any location
- Multiple temperature units
- Weather conditions, humidity, wind
- Fallback: simulated weather data

#### Slide 9: Demo: SQL Query Tool
- Safe SQL execution
- Query validation
- Result formatting
- Table schema inspection

#### Slide 10: Demo: Email Sender Tool
- Send emails via SMTP
- Multiple recipients (to, cc, bcc)
- HTML and plain text
- Attachment support

#### Slide 11: Key Takeaways
- Function calling gives LLMs real-world capabilities
- Functions are defined with JSON schemas
- LLMs generate function calls based on user queries
- Tools execute functions and return results
- Results are incorporated into the conversation
- Error handling is crucial for reliability

---

### Module 10: Tool Orchestration

#### Slide 1: Title Slide
**Module 10: Tool Orchestration**
- Coordinating multiple tools
- Duration: ~1 hour

#### Slide 2: The Orchestra Conductor Analogy
- Each musician = a tool (weather, calculator, database, email)
- The conductor = the orchestrator (you or the AI)
- Sheet music = the workflow (sequence of steps)
- The performance = the execution (actual work)

#### Slide 3: Orchestration Patterns
1. **Sequential:** Tools run one after another
2. **Parallel:** Tools run simultaneously
3. **Conditional:** Tools run based on conditions
4. **Loop:** Tools run repeatedly until condition met

#### Slide 4: Orchestration Challenges
- Dependencies: tools need data from other tools
- Error handling: tools can fail
- Timeouts: tools can hang
- Concurrency: race conditions
- State management: tracking progress
- Monitoring: understanding what's happening

#### Slide 5: Demo: Sequential Execution
- Execute tools in a specific order
- Pass data between steps
- Conditional execution
- Error handling

#### Slide 6: Demo: Parallel Execution
- Execute multiple tools simultaneously
- Thread pool management
- Result aggregation
- Performance optimization

#### Slide 7: Demo: Error Recovery
- Retry with exponential backoff
- Fallback mechanisms
- Graceful degradation
- Error classification

#### Slide 8: Demo: Workflow Builder
- Build complex workflows step by step
- Conditional and loop steps
- Data passing between steps
- Workflow templates

#### Slide 9: Key Takeaways
- Orchestration coordinates multiple tools
- Sequential execution handles dependencies
- Parallel execution improves performance
- Error recovery ensures reliability
- Workflows automate complex tasks

---

### Module 11: Model Context Protocol (MCP)

#### Slide 1: Title Slide
**Module 11: Model Context Protocol (MCP)**
- Standardizing AI-tool integration
- Duration: ~1 hour

#### Slide 2: The USB-C Analogy
- Before MCP: every device had a different charger
- After MCP: one protocol works with all AI applications
- Tools are discoverable and interoperable
- Security is built in
- The ecosystem grows together

#### Slide 3: What is MCP?
- Open protocol for AI-tool integration
- Standardizes how AI applications discover and use tools
- Components: Client, Server, Resources, Prompts, Tools
- Transports: Stdio, SSE, WebSocket

#### Slide 4: MCP Architecture
- MCP Client = AI application
- MCP Transport = Stdio / SSE / WebSocket
- MCP Server = service exposing capabilities
- Resources = data (files, database records)
- Prompts = reusable templates
- Tools = executable functions

#### Slide 5: MCP Capabilities
- **Resources:** Data the server can provide
  - Files, database records, API endpoints
  - Example: `file:///data/report.pdf`
- **Prompts:** Reusable templates
  - Example: "analyze_data" with parameters
- **Tools:** Executable functions
  - Example: "query_database" with parameters

#### Slide 6: MCP Transports
| Transport | Description | Use Case |
|-----------|-------------|----------|
| **Stdio** | Standard input/output | Local processes, CLI tools |
| **SSE** | Server-Sent Events | Web applications, streaming |
| **WebSocket** | WebSocket protocol | Real-time bidirectional |

#### Slide 7: Demo: MCP Server
- Expose tools, resources, and prompts
- Handle requests
- Discover capabilities
- Security considerations

#### Slide 8: Demo: MCP Client
- Connect to MCP servers
- Discover capabilities
- Read resources
- Get prompts
- Call tools

#### Slide 9: Security Considerations
- Authentication: verify client identity
- Authorization: control access
- Data Privacy: protect sensitive data
- Tool Abuse: prevent misuse
- Injection: prevent injection attacks

#### Slide 10: Key Takeaways
- MCP standardizes AI-tool integration
- Resources provide data and content
- Prompts are reusable templates
- Tools are executable functions
- Servers expose capabilities
- Clients discover and use capabilities
- Security is built into the protocol

---

## PHASE 4: Retrieval-Augmented Generation (RAG)
### Module 12: Embeddings & Vector Databases

#### Slide 1: Title Slide
**Phase 4: Retrieval-Augmented Generation (RAG)**
- Module 12: Embeddings & Vector Databases
- Duration: ~1.5 hours

#### Slide 2: The Library Analogy
- Books = documents (PDFs, websites, emails)
- Chapters = document chunks
- Card Catalog = vector database
- Librarian = retrieval system
- Search Query = user question

#### Slide 3: What Are Vector Databases?
- Specialized databases for storing and searching high-dimensional vectors
- Data: vectors (arrays of numbers)
- Search: similarity search
- Indexing: Approximate Nearest Neighbor (ANN)
- Query: vector similarity

#### Slide 4: Popular Vector Databases
| Database | Type | Key Features | Best For |
|----------|------|--------------|----------|
| **Chroma** | Embedded | Simple, Python-native | Development |
| **Pinecone** | Cloud | Managed, scalable | Production |
| **FAISS** | Library | Fast, efficient | Research |
| **Weaviate** | Hybrid | Graph + vector | Complex data |
| **pgvector** | PostgreSQL extension | SQL integration | PostgreSQL users |

#### Slide 5: Chunking Strategies
| Strategy | Description | Pros | Cons |
|----------|-------------|------|------|
| **Fixed Size** | Split by token count | Simple, predictable | May break semantic units |
| **Sentence** | Split by sentences | Preserves meaning | Inconsistent sizes |
| **Paragraph** | Split by paragraphs | Natural units | May be too large |
| **Semantic** | Split by meaning | Best coherence | Complex to implement |
| **Recursive** | Try different separators | Flexible, robust | Can be slow |

#### Slide 6: Embedding Models Comparison
| Model | Dimensions | Cost ($/1M tokens) | Use Case |
|-------|------------|-------------------|----------|
| text-embedding-3-small | 1536 | $0.02 | General purpose |
| text-embedding-3-large | 3072 | $0.13 | Highest accuracy |
| BAAI/bge-large-en-v1.5 | 1024 | Free (local) | Open source |
| all-MiniLM-L6-v2 | 384 | Free (local) | Lightweight |

#### Slide 7: Demo: Document Chunker
- Split documents into chunks
- Multiple chunking strategies
- Token counting
- Metadata preservation

#### Slide 8: Demo: Embedding Generator
- Generate embeddings for text chunks
- Batch processing
- Cost tracking
- Embedding properties

#### Slide 9: Demo: Vector Store
- Store embeddings with metadata
- Similarity search
- Metadata filtering
- Persistence to disk

#### Slide 10: Demo: Semantic Search
- Search by meaning, not just keywords
- Cosine similarity
- Hybrid search
- Result ranking

#### Slide 11: Key Takeaways
- Embeddings convert text to semantic vectors
- Similar vectors have similar meanings
- Vector databases store and search embeddings
- Chunking prepares documents for embedding
- Cosine similarity measures semantic similarity
- Metadata filters refine search results

---

### Module 13: Building a RAG Pipeline

#### Slide 1: Title Slide
**Module 13: Building a RAG Pipeline**
- End-to-end retrieval-augmented generation
- Duration: ~2 hours

#### Slide 2: The Research Assistant Analogy
- You = LLM (good at synthesis, not memorization)
- Research assistant = retrieval system
- Library = knowledge base (vector database)
- Notes = retrieved chunks of text
- Citations = source attribution

#### Slide 3: RAG Pipeline Components
1. **Document Ingestion:** Process and store documents
2. **Retrieval:** Find relevant chunks
3. **Context Construction:** Build optimal prompt
4. **Generation:** Produce final answer
5. **Citation:** Attribute sources

#### Slide 4: RAG Quality Factors
| Factor | Impact | How to Optimize |
|--------|--------|-----------------|
| Chunk Quality | High | Use semantic chunking |
| Embedding Quality | High | Use best embedding model |
| Retrieval Quality | Very High | Tune Top-K, use re-ranking |
| Context Window | Medium | Stay within limits |
| Prompt Design | High | Clear instructions |
| Model Choice | High | Use capable models |

#### Slide 5: Demo: Document Ingestion
- Process documents from various sources
- Chunk documents
- Generate embeddings
- Store in vector database

#### Slide 6: Demo: Retrieval Engine
- Find relevant documents for queries
- Semantic search
- Metadata filtering
- Re-ranking

#### Slide 7: Demo: Context Builder
- Build optimal context for LLM responses
- Token-aware construction
- Source attribution
- Context trimming

#### Slide 8: Demo: RAG Generator
- Generate responses with citations
- Context-aware generation
- Citation extraction
- Source tracking

#### Slide 9: Demo: Complete RAG Pipeline
- End-to-end RAG system
- Document ingestion
- Query processing
- Response with citations

#### Slide 10: Demo: Citation System
- Track and display citations
- Source tracking
- Citation formatting
- Reference management

#### Slide 11: Key Takeaways
- Document ingestion processes and stores knowledge
- Retrieval finds relevant information for queries
- Context construction builds optimal prompts
- Generation produces accurate, cited responses
- Citations build trust and enable verification

---

### Module 14: Advanced RAG

#### Slide 1: Title Slide
**Module 14: Advanced RAG**
- Taking RAG to the next level
- Duration: ~1.5 hours

#### Slide 2: The Detective Analogy
- Basic RAG = looking through files for keywords
- Hybrid Search = keyword + meaning
- Context Compression = summarizing long documents
- Parent-Child Retrieval = find clue, pull whole file
- Knowledge Graphs = mapping relationships

#### Slide 3: Advanced RAG Techniques Compared
| Technique | What It Does | Impact |
|-----------|--------------|--------|
| **Hybrid Search** | Keyword + semantic | High recall |
| **Context Compression** | Summarizes retrieved chunks | Better utilization |
| **Parent-Child Retrieval** | Finds chunks, returns documents | Better coherence |
| **Knowledge Graphs** | Adds relationship data | Richer answers |
| **Re-ranking** | Optimizes retrieval order | Better precision |

#### Slide 4: Hybrid Search
- Semantic search (embeddings) = misses exact matches
- Keyword search (BM25) = misses meaning
- Solution: combine both
- Hybrid Score = (Semantic Score × α) + (Keyword Score × (1 - α))

#### Slide 5: Context Compression
- Problem: Retrieved chunks may contain irrelevant information
- Solution: Summarize or extract key information
- Extractive: keep important sentences
- Abstractive: use LLM to summarize
- Key Points: extract bullet points

#### Slide 6: Parent-Child Retrieval
- Problem: Small chunks lack context
- Solution: Retrieve small chunks (children) but return large chunks (parents)
- Children: precise, small
- Parents: contextual, large
- Search: find relevant children
- Return: parents containing those children

#### Slide 7: Knowledge Graph Integration
- Entities and relationships
- Graph traversal
- Context enrichment
- Query expansion

#### Slide 8: Demo: Hybrid Search Engine
- Combine keyword and semantic search
- Score fusion (RRF, weighted)
- Query expansion
- Performance tuning

#### Slide 9: Demo: Context Compressor
- Extractive summarization
- Abstractive summarization
- Key point extraction
- Token-aware compression

#### Slide 10: Demo: Parent-Child Retriever
- Parent and child chunk creation
- Multi-level retrieval
- Context preservation
- Relationship tracking

#### Slide 11: Demo: RAG Optimizer
- Parameter grid search
- Performance evaluation
- Optimal parameter selection
- A/B testing

#### Slide 12: Key Takeaways
- Hybrid search = keyword + semantic for better recall
- Context compression = fit more information in context
- Parent-child retrieval = precision + context
- Knowledge graphs = relationships and connections
- Optimization = continuous improvement

---

## PHASE 5: Agentic AI Systems
### Module 15: AI Agents

#### Slide 1: Title Slide
**Phase 5: Agentic AI Systems**
- Module 15: AI Agents
- Duration: ~2 hours

#### Slide 2: The Employee Analogy
- Simple AI (Chatbot) = an intern who answers questions
- AI Agent = a senior employee who:
  1. Understands the goal you give them
  2. Plans how to achieve it
  3. Breaks it into manageable tasks
  4. Executes tasks using available tools
  5. Reflects on their work and improves
  6. Remembers what they've done before

#### Slide 3: What Makes an AI Agent?
| Component | Description | Example |
|-----------|-------------|---------|
| **Planning** | Break down goals into steps | "To write a report, I need to research, outline, write, and edit" |
| **Reasoning** | Think through problems | "If X, then Y, but if Z, then I should do W" |
| **Memory** | Remember past interactions | "The user prefers concise answers" |
| **Tool Use** | Use external tools | Weather API, calculator, database |
| **Reflection** | Evaluate and improve | "My previous response was too long, let me shorten it" |
| **Learning** | Adapt over time | "I've learned that this user likes technical details" |

#### Slide 4: Agent Frameworks Comparison
| Framework | Strengths | Use Cases |
|-----------|-----------|-----------|
| **LangGraph** | Graph-based, flexible | Complex multi-step agents |
| **AutoGen** | Multi-agent conversations | Collaborative problem-solving |
| **CrewAI** | Role-based teams | Task delegation |
| **OpenAI Agents SDK** | Production-ready | Enterprise applications |

#### Slide 5: Agent Types
- **Reactive:** Responds to events → simple automation
- **Proactive:** Takes initiative → complex tasks
- **Collaborative:** Works with others → team-based problems
- **Learning:** Improves over time → long-term applications
- **Hybrid:** Combines approaches → most real-world applications

#### Slide 6: Demo: Simple Agent
- Goal understanding
- Basic planning
- Step execution
- Memory management

#### Slide 7: Demo: Planning Engine
- Goal decomposition
- Dependency management
- Parallel planning
- Plan validation

#### Slide 8: Demo: Reflection System
- Self-evaluation
- Criticism and improvement
- Iterative refinement
- Quality scoring

#### Slide 9: Demo: Tool-Using Agent
- Tool registration
- Tool selection
- Tool execution
- Result interpretation

#### Slide 10: Demo: Goal Decomposition
- Break down complex goals
- Priority assignment
- Dependency detection
- Execution order

#### Slide 11: Key Takeaways
- Agents plan, execute, and reflect
- Memory stores and retrieves information
- Tools extend agent capabilities
- Reflection enables self-improvement
- Goal decomposition handles complexity
- Frameworks provide structure

---

### Module 16: Multi-Agent Systems (A2A)

#### Slide 1: Title Slide
**Module 16: Multi-Agent Systems (A2A)**
- Teams of AI agents working together
- Duration: ~1.5 hours

#### Slide 2: The Team Analogy
- Project Manager = Coordinator Agent (plans, delegates, tracks)
- Developers = Worker Agents (write code, fix bugs)
- Designers = Worker Agents (create UI/UX)
- QA Engineers = Worker Agents (test, validate)
- DevOps = Worker Agents (deploy, monitor)

#### Slide 3: Communication Patterns
| Pattern | Description | When to Use |
|---------|-------------|-------------|
| **Hierarchical** | Coordinator delegates | Clear structure |
| **Peer-to-Peer** | Direct communication | Collaborative problems |
| **Broadcast** | One sends to all | Information sharing |
| **Pipeline** | Sequential handoff | Step-by-step workflows |
| **Swarm** | Decentralized collaboration | Emergent problems |

#### Slide 4: Team Structures
- **Centralized:** One coordinator → clear leadership, single point of failure
- **Decentralized:** Peer-to-peer → resilient, coordination overhead
- **Hybrid:** Balanced → complex to manage
- **Hierarchical:** Multiple levels → scalable, communication overhead

#### Slide 5: Demo: Coordinator Agent
- Orchestrate work across agents
- Task decomposition
- Agent assignment
- Progress tracking
- Result aggregation

#### Slide 6: Demo: Worker Agent
- Perform specific tasks
- Capability reporting
- Progress updates
- Communication
- Status management

#### Slide 7: Demo: Communication Protocol
- Agent-to-agent messaging
- Direct messaging
- Broadcast
- Pub/Sub
- Request/Response

#### Slide 8: Demo: Hierarchical Team
- Multi-level organization
- Delegation chain
- Escalation
- Performance tracking

#### Slide 9: Demo: Swarm System
- Decentralized coordination
- Emergent behavior
- Self-organization
- Consensus building

#### Slide 10: Key Takeaways
- Multiple agents collaborate on complex tasks
- Coordinators plan and delegate
- Workers execute specific tasks
- Communication enables coordination
- Hierarchical teams provide structure
- Swarms enable decentralized problem-solving

---

### Module 17: Agent Memory

#### Slide 1: Title Slide
**Module 17: Agent Memory**
- Building agents that learn and remember
- Duration: ~1.5 hours

#### Slide 2: The Human Memory Analogy
- Short-Term Memory = last few minutes (conversation context)
- Long-Term Memory = facts learned over years (knowledge)
- Episodic Memory = specific events experienced (meeting with a client)
- Semantic Memory = general knowledge (how a car works)

#### Slide 3: Memory Types Compared
| Type | Duration | Capacity | Purpose | Example |
|------|----------|----------|---------|---------|
| **Short-Term** | Minutes | Limited (context window) | Immediate reasoning | "User just asked about Python" |
| **Long-Term** | Permanent | Unlimited (vector DB) | Persistent knowledge | "User prefers concise answers" |
| **Episodic** | Permanent | Unlimited | Event recall | "User mentioned they're from Boston" |
| **Semantic** | Permanent | Unlimited | General facts | "Python is a programming language" |

#### Slide 4: Memory Operations
- **Store:** Save new information → every interaction
- **Retrieve:** Find relevant memories → before reasoning
- **Prune:** Remove old/irrelevant → when memory is full
- **Consolidate:** Move to long-term → periodic
- **Forget:** Remove outdated info → when knowledge changes

#### Slide 5: Memory Retrieval Strategies
- **Recency:** Most recent first → short-term context
- **Relevance:** Semantic similarity → finding related knowledge
- **Frequency:** Most accessed first → commonly used facts
- **Importance:** Priority-based → critical information
- **Temporal:** Time-based → historical context

#### Slide 6: Demo: Short-Term Memory
- Sliding window of recent interactions
- Context preservation
- Priority-based retention
- Automatic pruning

#### Slide 7: Demo: Long-Term Memory
- Vector-based storage
- Semantic search
- Metadata filtering
- Persistence

#### Slide 8: Demo: Episodic Memory
- Event storage with timestamps
- Temporal retrieval
- Episode grouping
- Event importance scoring

#### Slide 9: Demo: Semantic Memory
- Concept storage
- Relationship tracking
- Knowledge graph
- Concept retrieval

#### Slide 10: Demo: Memory Pruning
- Age-based pruning
- Importance-based pruning
- Recency-based pruning
- Consolidation

#### Slide 11: Key Takeaways
- Short-term memory holds immediate context
- Long-term memory stores persistent knowledge
- Episodic memory recalls specific events
- Semantic memory stores general knowledge
- Pruning keeps memory efficient
- Consolidation moves STM → LTM
- Complete memory systems enable learning agents

---

## PHASE 6: AI Application Engineering
### Module 18: Asynchronous AI Programming

#### Slide 1: Title Slide
**Phase 6: AI Application Engineering**
- Module 18: Asynchronous AI Programming
- Duration: ~1.5 hours

#### Slide 2: The Restaurant Analogy
- Synchronous (Blocking) = one chef cooking one order at a time
- Asynchronous (Non-blocking) = multiple chefs working on different orders
- Concurrent = multiple orders in progress at once
- Parallel = multiple chefs working on the same order together

#### Slide 3: Async vs Sync Performance
| Metric | Synchronous | Asynchronous |
|--------|-------------|--------------|
| Response Time | Sequential (N × time) | Parallel (~time) |
| Throughput | Limited by I/O | I/O-bound scaling |
| Resource Usage | Idle waiting | Full utilization |
| Complexity | Simple | Moderate |

#### Slide 4: Async AI Patterns
| Pattern | Description | Use Case |
|---------|-------------|----------|
| **Fire and Forget** | Send request, don't wait | Logging, analytics |
| **Request-Response** | Wait for response | User queries |
| **Streaming** | Get response in chunks | Chat, generation |
| **Batching** | Process multiple at once | Batch inference |
| **Parallel** | Multiple independent requests | Data processing |

#### Slide 5: Async Technologies
| Technology | Purpose | Best For |
|------------|---------|----------|
| **asyncio** | Python async framework | Python applications |
| **FastAPI** | Async web framework | API servers |
| **aiohttp** | Async HTTP client | API calls |
| **WebSockets** | Bidirectional communication | Real-time apps |
| **SSE** | Server-sent events | Streaming responses |

#### Slide 6: Demo: Async AI Client
- Non-blocking API calls
- Connection pooling
- Timeout handling
- Retry logic

#### Slide 7: Demo: Streaming Handler
- Real-time streaming
- Event-based handling
- Buffer management
- Progress tracking

#### Slide 8: Demo: Concurrent Processor
- Concurrent processing
- Rate limiting
- Priority queuing
- Result aggregation

#### Slide 9: Demo: SSE Server
- Server-Sent Events
- Real-time web streaming
- Event-based communication
- Client-side integration

#### Slide 10: Demo: WebSocket Server
- Bidirectional communication
- Real-time AI
- Connection management
- Broadcast capabilities

#### Slide 11: Key Takeaways
- Async programming maximizes I/O efficiency
- Non-blocking calls improve throughput
- Streaming provides real-time user experience
- Concurrency handles multiple requests
- SSE is great for server-to-client streaming
- WebSocket enables bidirectional communication

---

### Module 19: Resilient AI Systems

#### Slide 1: Title Slide
**Module 19: Resilient AI Systems**
- Building robust, fault-tolerant applications
- Duration: ~1.5 hours

#### Slide 2: The Building Analogy
- Retries = backup materials
- Circuit Breaker = fire door
- Timeouts = fire alarms
- Rate Limiting = limiting people entering
- Bulkheads = separate rooms
- Graceful Degradation = building still functional

#### Slide 3: Resilience Patterns
| Pattern | Problem Solved | How It Works |
|---------|---------------|--------------|
| **Retry** | Transient failures | Retry with backoff |
| **Circuit Breaker** | Cascading failures | Stop requests after failures |
| **Timeout** | Hanging operations | Cancel after time limit |
| **Rate Limiting** | Overwhelming services | Limit request rate |
| **Bulkhead** | Resource exhaustion | Isolate components |
| **Fallback** | Unavailable service | Use alternative |

#### Slide 4: Retry Strategies
| Strategy | Delay Pattern | Use Case |
|----------|---------------|----------|
| **Fixed** | Constant delay | Simple retries |
| **Linear** | Linearly increasing | Moderate failures |
| **Exponential** | Doubling delay | Network failures |
| **Exponential + Jitter** | Doubling + random | Production systems |

#### Slide 5: Circuit Breaker States
- **CLOSED:** Normal operation → requests flow
- **OPEN:** Circuit is open (failing) → requests blocked
- **HALF-OPEN:** Testing if service recovered → limited requests
- State transitions based on failure/success thresholds

#### Slide 6: Demo: Retry System
- Exponential backoff with jitter
- Configurable retry count
- Error filtering
- Callback support

#### Slide 7: Demo: Circuit Breaker
- Failure threshold
- Recovery timeout
- Half-open state
- Success threshold
- State change callbacks

#### Slide 8: Demo: Timeout Manager
- Timeout handling
- Context manager
- Custom timeout handlers
- Async support

#### Slide 9: Demo: Rate Limiter
- Token bucket algorithm
- Configurable rate and capacity
- Burst handling
- Multiple limiters

#### Slide 10: Demo: Resilient AI Client
- All resilience patterns
- Production-ready client
- Statistics and monitoring
- Performance tracking

#### Slide 11: Key Takeaways
- Retries handle transient failures gracefully
- Circuit breakers prevent cascading failures
- Timeouts prevent hanging operations
- Rate limiting prevents overwhelming services
- Bulkheads isolate failures
- Production AI systems must be resilient

---

### Module 20: AI Observability

#### Slide 1: Title Slide
**Module 20: AI Observability**
- Understanding what your AI system is doing
- Duration: ~1.5 hours

#### Slide 2: The Dashboard Analogy
- Logging = the black box recording everything
- Tracing = the flight path showing where you've been
- Metrics = the instrument panel showing speed, altitude, fuel
- Monitoring = the warning lights and alerts
- Dashboards = the cockpit display showing everything

#### Slide 3: Observability vs. Monitoring
| Aspect | Monitoring | Observability |
|--------|------------|---------------|
| **What** | Known unknowns | Unknown unknowns |
| **How** | Pre-defined metrics | Explore and discover |
| **Scope** | System health | System understanding |
| **Output** | Dashboards, alerts | Insights, debugging |

#### Slide 4: Key AI Metrics
| Metric | What It Measures | Why It Matters |
|--------|------------------|----------------|
| **Token Usage** | Tokens processed | Cost, context limits |
| **Cost** | Money spent | Budget, optimization |
| **Latency** | Response time | User experience |
| **Error Rate** | Failed requests | Reliability |
| **Success Rate** | Successful requests | Quality |
| **Prompt Version** | Which prompt used | A/B testing |

#### Slide 5: Observability Tools
| Tool | Focus | Key Features |
|------|-------|--------------|
| **LangSmith** | AI-specific | Tracing, evaluation |
| **OpenTelemetry** | General | Standardized telemetry |
| **Helicone** | AI APIs | Cost tracking |
| **Weights & Biases** | ML | Experiment tracking |
| **Phoenix** | LLM | Tracing, evaluation |

#### Slide 6: Demo: Structured Logger
- JSON-formatted logs
- Log levels
- Context propagation
- Log rotation

#### Slide 7: Demo: Tracing System
- Request flow tracking
- Span creation
- Parent-child relationships
- Attribute tracking

#### Slide 8: Demo: Token & Cost Monitor
- Real-time cost tracking
- Token counting
- Budget alerts
- Usage forecasting

#### Slide 9: Demo: Latency Analyzer
- Performance measurement
- Percentile calculations
- SLA monitoring
- Anomaly detection

#### Slide 10: Demo: Prompt Versioning
- Version creation
- Version comparison
- A/B testing support
- Rollback

#### Slide 11: Key Takeaways
- Logging captures structured events
- Tracing tracks request flows
- Metrics measure system performance
- Cost monitoring tracks spending
- Latency analysis identifies bottlenecks
- Prompt versioning tracks changes

---

### Module 21: AI Security

#### Slide 1: Title Slide
**Module 21: AI Security**
- Protecting AI systems from attacks
- Duration: ~1.5 hours

#### Slide 2: The Bank Vault Analogy
- Prompt Injection = tricking the guard
- Jailbreak = finding a way to override the system
- Data Leakage = reading documents through the window
- Tool Abuse = using the bank's own systems against it
- Guardrails = the security guards, cameras, and alarms

#### Slide 3: Common AI Attack Vectors
| Attack Type | Description | Example |
|-------------|-------------|---------|
| **Prompt Injection** | Malicious instructions | "Ignore previous instructions and..." |
| **Jailbreak** | Circumventing safety | "Act as DAN (Do Anything Now)" |
| **Data Leakage** | Exposing sensitive info | "What's in your training data?" |
| **Tool Abuse** | Misusing available tools | "Delete all files using the file tool" |
| **Denial of Service** | Overwhelming the system | Sending huge prompts repeatedly |

#### Slide 4: Prompt Injection Patterns
- Instruction Override: "Ignore previous instructions"
- Role Playing: "Act as an administrator"
- Context Poisoning: "Assume this is true..."
- Token Smuggling: Using encoded malicious text
- Delimiter Bypass: Using special characters

#### Slide 5: Security Best Practices
| Practice | Why | How |
|----------|-----|-----|
| **Input Sanitization** | Remove malicious content | Filter dangerous patterns |
| **Output Validation** | Prevent data leakage | Check for sensitive data |
| **Principle of Least Privilege** | Limit damage | Minimal permissions |
| **Rate Limiting** | Prevent DoS | Limit request frequency |
| **Monitoring** | Detect attacks | Log and alert |
| **Regular Audits** | Find vulnerabilities | Security reviews |

#### Slide 6: Demo: Prompt Injection Detector
- Pattern-based detection
- Heuristic analysis
- Contextual detection
- Score-based blocking

#### Slide 7: Demo: Jailbreak Prevention
- Known jailbreak pattern detection
- Contextual analysis
- Role-play detection
- Constraint bypass detection

#### Slide 8: Demo: Data Leakage Protector
- PII detection (email, phone, SSN)
- API key detection
- Credit card detection
- Password detection

#### Slide 9: Demo: Secret Manager
- Encrypted storage
- Secret rotation
- Access logging
- Expiration

#### Slide 10: Demo: Tool Abuse Prevention
- Tool call validation
- Argument sanitization
- Permission checking
- Rate limiting per tool

#### Slide 11: Key Takeaways
- Prompt injection is a primary attack vector
- Jailbreaks attempt to bypass safety measures
- Data leakage exposes sensitive information
- Tool abuse can cause system damage
- Multiple layers of security are essential
- Input validation prevents attacks
- Output filtering prevents leakage

---

## PHASE 7: Production AI Architecture
### Module 22: AI System Architecture

#### Slide 1: Title Slide
**Phase 7: Production AI Architecture**
- Module 22: AI System Architecture
- Duration: ~1.5 hours

#### Slide 2: The Airport Analogy
- AI Gateway = main terminal
- Model Router = flight schedule
- Response Cache = baggage claim
- Load Balancer = air traffic control
- Model Fallback = backup runway
- Multi-Model Strategy = different airlines

#### Slide 3: Architecture Components
| Component | Purpose | Key Features |
|-----------|---------|--------------|
| **AI Gateway** | Unified entry point | Authentication, rate limiting, logging |
| **Model Router** | Intelligent routing | Cost/quality optimization |
| **Response Cache** | Reduce costs | Semantic caching, TTL |
| **Load Balancer** | Distribute traffic | Health checks, weighted routing |
| **Model Fallback** | Ensure availability | Automatic failover |
| **Multi-Model Strategy** | Optimize decisions | Cost-quality tradeoffs |

#### Slide 4: Routing Strategies
| Strategy | Description | When to Use |
|----------|-------------|-------------|
| **Round Robin** | Distribute evenly | Equal load balancing |
| **Weighted** | Weighted distribution | Different capacities |
| **Cost-Based** | Cheapest first | Cost optimization |
| **Quality-Based** | Best quality first | Quality optimization |
| **Context-Aware** | Based on task | Task-specific routing |
| **Dynamic** | Real-time optimization | Variable conditions |

#### Slide 5: Caching Strategies
| Strategy | Description | Benefits |
|----------|-------------|----------|
| **Exact Match** | Identical queries | Simple, effective |
| **Semantic** | Similar meaning | Higher cache hit rate |
| **TTL-Based** | Time-based expiry | Freshness control |
| **LRU** | Least recently used | Memory efficiency |
| **Hybrid** | Multiple strategies | Best of both |

#### Slide 6: Demo: AI Gateway
- Authentication
- Rate limiting
- Request routing
- Response transformation
- API key management

#### Slide 7: Demo: Model Router
- Context-aware routing
- Cost optimization
- Quality optimization
- Weighted routing

#### Slide 8: Demo: Response Cache
- Semantic similarity caching
- TTL-based expiry
- Cache hit tracking
- Memory management

#### Slide 9: Demo: Load Balancer
- Round robin
- Weighted distribution
- Health checks
- Auto-scaling

#### Slide 10: Demo: Model Fallback
- Multi-tier fallback
- Automatic failover
- Degraded mode
- Recovery detection

#### Slide 11: Key Takeaways
- Gateways provide unified entry points
- Routers enable intelligent model selection
- Caches reduce costs and latency
- Load balancers distribute traffic
- Fallback ensures availability
- Multi-model strategies optimize cost/quality

---

### Module 23: Deployment

#### Slide 1: Title Slide
**Module 23: Deployment**
- Getting AI into production
- Duration: ~1.5 hours

#### Slide 2: The Delivery Service Analogy
- Docker = delivery boxes (consistent packaging)
- Kubernetes = dispatch system (orchestrating drivers)
- Serverless = on-demand delivery (only when needed)
- GPU Deployment = high-performance vehicles
- CI/CD = the automated kitchen

#### Slide 3: Deployment Options
| Option | Pros | Cons | Best For |
|--------|------|------|----------|
| **Docker** | Consistency, portable | Manual management | Development |
| **Kubernetes** | Scalability, self-healing | Complex | Production |
| **Serverless** | Cost-effective, auto-scaling | Cold starts | Sporadic workloads |
| **GPU Instances** | High performance | Expensive | Model training |

#### Slide 4: Key Deployment Concepts
- **Containerization:** Package app with dependencies
- **Orchestration:** Manage containers at scale
- **CI/CD:** Automated build and deploy
- **Infrastructure as Code:** Define infrastructure in code
- **Health Checks:** Monitor service health
- **Rollbacks:** Revert bad deployments

#### Slide 5: Deployment Best Practices
| Practice | Why | How |
|----------|-----|-----|
| **Immutable Infrastructure** | No configuration drift | Rebuild, don't patch |
| **Canary Deployments** | Gradual rollout | Test with small traffic |
| **Blue-Green Deployments** | Zero downtime | Two identical environments |
| **Health Checks** | Detect failures | Liveness, readiness probes |
| **Secrets Management** | Secure credentials | Encrypted secrets |

#### Slide 6: Demo: Dockerized AI Service
- Containerization
- Dockerfile
- Build and run
- Health checks

#### Slide 7: Demo: Kubernetes Deployment
- Deployment manifests
- Service definitions
- Ingress configuration
- Horizontal Pod Autoscaling

#### Slide 8: Demo: Serverless AI Function
- AWS Lambda function
- Event-driven execution
- Auto-scaling
- Cold start mitigation

#### Slide 9: Demo: GPU Deployment
- GPU-optimized containers
- Node selection
- Resource allocation
- Model caching

#### Slide 10: Demo: CI/CD Pipeline
- Automated build and test
- Container registry
- Deployment automation
- Rollback capabilities

#### Slide 11: Key Takeaways
- Containerization ensures consistency
- Orchestration handles scaling
- Serverless is cost-effective for sporadic workloads
- GPU deployments are for high-performance AI
- CI/CD enables fast, reliable deployment
- Health checks monitor service health
- Rollback ensures safety

---

### Module 24: AI Evaluation & Continuous Improvement

#### Slide 1: Title Slide
**Module 24: AI Evaluation & Continuous Improvement**
- Measuring and improving AI systems
- Duration: ~1.5 hours

#### Slide 2: The Quality Control Analogy
- Benchmarking = testing against standards
- A/B Testing = comparing two production lines
- LLM-as-a-Judge = an automated inspector
- Feedback Loops = learning from customer returns
- Regression Testing = ensuring new changes don't break things

#### Slide 3: Evaluation Methods
| Method | What It Measures | Pros | Cons |
|--------|------------------|------|------|
| **Benchmarking** | Absolute performance | Standardized | May not reflect real use |
| **A/B Testing** | Relative performance | Real-world data | Requires traffic |
| **LLM-as-a-Judge** | Quality at scale | Cost-effective | May have biases |
| **Feedback Loops** | Real-world impact | Continuous | Slow to see results |
| **Regression Testing** | Stability | Prevents regressions | Manual effort |

#### Slide 4: Key Evaluation Metrics
| Metric | What It Measures | Target |
|--------|------------------|--------|
| **Accuracy** | Correctness | > 90% |
| **Relevance** | Relevance to query | > 0.8 |
| **Coherence** | Logical flow | > 0.7 |
| **Safety** | Harmful content | < 1% |
| **Latency** | Speed | < 1000ms |
| **Cost** | Expense | Minimize |

#### Slide 5: Continuous Improvement Process
1. Collect Data → 2. Measure Performance → 3. Identify Issues
4. Prioritize Improvements → 5. Implement Changes
6. Test → 7. Deploy → 8. Monitor → 9. Repeat

#### Slide 6: Demo: Benchmarking Framework
- Standardized test suites
- Performance metrics
- Comparative analysis
- Historical tracking

#### Slide 7: Demo: A/B Testing System
- Variant assignment
- Traffic splitting
- Metrics collection
- Statistical analysis

#### Slide 8: Demo: LLM-as-a-Judge
- Automated scoring
- Consistency checking
- Bias detection
- Multi-dimensional evaluation

#### Slide 9: Demo: Feedback Loop Engine
- Feedback collection
- Analysis and insights
- Improvement suggestions
- Performance tracking

#### Slide 10: Demo: Regression Testing System
- Test case management
- Automated regression detection
- Baseline comparison
- Failure reporting

#### Slide 11: Key Takeaways
- Benchmarking measures absolute performance
- A/B testing compares alternatives
- LLM-as-a-Judge provides automated quality scoring
- Feedback loops enable continuous improvement
- Regression testing prevents regressions
- Evaluation must be continuous, not one-time

---

## Appendices

### Appendix A: API Reference & Cheat Sheets

#### Slide 1: Provider Quick Reference
- OpenAI, Anthropic, Google, Ollama, OpenRouter
- Authentication methods
- Key formats
- Pricing models

#### Slide 2: Common Operations Cheat Sheet
- Count tokens
- Calculate cost
- Parse JSON response
- Rate limit handling
- Safe environment variables

#### Slide 3: Prompt Engineering Templates
- General chat template
- Structured extraction template
- Chain-of-Thought template
- Few-shot template
- Code review template

#### Slide 4: Function Calling Reference
- Function definition
- Parameter definition
- Schema generation
- Tool registry

#### Slide 5: Embedding Models Reference
- OpenAI embeddings
- Open source embeddings
- Similarity functions
- Vector database quick reference

---

### Appendix B: Glossary of Terms

#### Slide 1: A–C
- Agent, Agentic AI, API, API Key
- Attention Mechanism, Async/Await
- Benchmarking, BPE, Bulkhead
- Caching, Chain-of-Thought, Chunking
- Circuit Breaker, CI/CD, Context Window

#### Slide 2: D–F
- Deep Learning, Deployment, Docker
- Embedding, Episodic Memory, Evaluation
- Exponential Backoff, FAISS, Fallback
- Feedback Loop, Few-Shot Learning, Function Calling

#### Slide 3: G–L
- Generative AI, Goal Decomposition, GPU
- Graceful Degradation, Guardrails
- Hallucination, Hybrid Search
- Inference, Jailbreak, JSON
- Jitter, Kubernetes, Latency, LLM
- LLM-as-a-Judge, Load Balancer, Logging

#### Slide 4: M–R
- Machine Learning, Max Tokens, MCP
- Memory (Agent), Memory Pruning, Metadata
- Metrics, Model Router, Multi-Agent System
- Multimodal AI, NLP, Neural Network
- Next-Token Prediction, Observability
- OCR, Orchestration, Parent-Child Retrieval

#### Slide 5: S–Z
- Sampling, Semantic Memory, Semantic Search
- SentencePiece, Serverless, SSE
- Short-Term Memory, Structured Output
- System Prompt, Temperature, Token
- Tokenization, Tool Call, Top-K, Top-P
- Tracing, Transformer, Truncation
- Vector, Vector Database, Vision Model
- WebSocket, Workflow, Zero-Shot Learning

---

### Appendix C: Common Patterns & Anti-Patterns

#### Slide 1: Prompt Engineering Patterns
- Chain-of-Thought → for reasoning, math
- Few-Shot Learning → for structured output
- Role Prompting → for consistent persona
- Self-Consistency → for critical decisions
- Structured Output → for data extraction

#### Slide 2: RAG & Retrieval Patterns
- Hybrid Search → combine semantic + keyword
- Parent-Child Retrieval → precision + context
- Query Expansion → improve recall
- Context Compression → fit more information

#### Slide 3: Agent Patterns
- Tool Orchestration → complex multi-step tasks
- Reflection & Self-Correction → improve quality
- Hierarchical Planning → complex dependencies

#### Slide 4: Architecture Patterns
- Circuit Breaker → prevent cascading failures
- Exponential Backoff with Jitter → network calls
- Bulkhead Pattern → isolate resources
- Cache First, API Second → cost optimization

#### Slide 5: Common Anti-Patterns
- The "Be Helpful" Trap → vague system prompts
- Over-Engineering Prompts → too long, complex
- Assuming Model Knowledge → no context provided
- Over-Chunking → losing context
- Too Many Tools → confusing the agent
- No Fallback → single point of failure
- No Observability → flying blind

---

### Appendix D: Deployment Checklist & Troubleshooting

#### Slide 1: Pre-Deployment Checklist
- Code quality: reviews, tests, linting
- Environment: variables, secrets, dependencies
- Configuration: model selection, logging, metrics
- Docker build, local test

#### Slide 2: Deployment Checklist
- Container registry, Kubernetes manifests
- Storage, networking, GPU support
- ConfigMap, Secrets, environment
- Replicas, HPA, resource limits

#### Slide 3: Post-Deployment Checklist
- Liveness, readiness, startup probes
- Logs, metrics, alerts, dashboards
- Authentication, authorization, rate limiting
- Input validation, output filtering

#### Slide 4: Common Issues & Solutions
- Rate Limit Exceeded → exponential backoff 
- Context Window Exceeded → truncate or summarize
- High Latency → faster model, streaming
- High Costs → cheaper model, caching
- Hallucinations → RAG, guardrails 
- Tool Execution Failures → validation, retries

#### Slide 5: Debugging Techniques
- Structured logging
- Distributed tracing
- Health checks
- Performance profiling

---

### Appendix E: Further Learning Resources

#### Slide 1: Books
- "Deep Learning" (Goodfellow, Bengio, Courville)
- "Speech and Language Processing" (Jurafsky, Martin)
- "Natural Language Processing with Transformers" (Tunstall et al.)
- "Designing Machine Learning Systems" (Huyen)
- "Building Machine Learning Powered Applications" (Ameisen)

#### Slide 2: Online Courses
- CS224N: NLP with Deep Learning (Stanford) 
- Deep Learning Specialization (Coursera)
- Hugging Face NLP Course
- Fast.ai Practical Deep Learning
- DeepLearning.AI LLM courses

#### Slide 3: Research Papers
- "Attention Is All You Need" (Vaswani et al., 2017) 
- "Language Models are Few-Shot Learners" (Brown et al., 2020)
- "Retrieval-Augmented Generation" (Lewis et al., 2020)
- "ReAct: Synergizing Reasoning and Acting" (Yao et al., 2022)

#### Slide 4: Blogs & Newsletters
- The Batch (DeepLearning.AI)
- Hugging Face Blog, OpenAI Blog, Anthropic Blog
- LangChain Blog, Pinecone Blog
- TLDR AI, AI Weekly

#### Slide 5: Tools & Frameworks
- LLM APIs: OpenAI, Anthropic, Google, Ollama 
- Development: LangChain, LangGraph, AutoGen, CrewAI
- Vector DB: Chroma, Pinecone, FAISS, pgvector
- Observability: LangSmith, Helicone, OpenTelemetry
- Deployment: Docker, Kubernetes, Terraform

#### Slide 6: Communities
- r/MachineLearning, r/LocalLLaMA
- Hugging Face Discord, LangChain Discord
- OpenAI Developer Forum
- MLOps Community

---

## Capstone Project Overview

#### Slide 1: Capstone Projects
- Apply all concepts from the course
- 8 complete projects to build
- Real-world applications
- Production-ready solutions

#### Slide 2: Project 1: AI Chatbot with Memory
- Persistent conversational assistant
- Embeddings and vector storage
- Short-term and long-term memory

#### Slide 3: Project 2: Private Knowledge Assistant (RAG)
- Enterprise search across documents
- PDFs, documentation, internal knowledge
- Citations and source tracking

#### Slide 4: Project 3: AI Coding Assistant
- Code generation, explanation, debugging
- Repository-aware assistance
- Function calling and tool use

#### Slide 5: Project 4: Autonomous Research Agent
- Multi-agent system for research
- Synthesis and structured reports
- Citations and source attribution

#### Slide 6: Project 5: Document Intelligence Platform
- OCR, structured extraction
- Classification and summarization
- Business document processing

#### Slide 7: Project 6: Customer Support Copilot
- AI-powered support assistant
- CRM and ticketing integration
- Knowledge base integration

#### Slide 8: Project 7: AI Workflow Automation Engine
- Tool-calling agents orchestrating tasks
- Email, databases, calendars, APIs
- Complex workflow automation

#### Slide 9: Project 8: Enterprise AI Platform
- RAG, MCP, agent orchestration
- Observability, security
- Scalable deployment

---

## Course Conclusion

#### Slide 1: What You've Learned
- How LLMs work (tokens, embeddings, inference, context)
- Prompt engineering and model APIs
- Tool use and function calling
- Retrieval-Augmented Generation (RAG)
- Agentic AI systems
- AI application engineering (async, resilience, observability, security)
- Production AI architecture (architecture, deployment, evaluation)

#### Slide 2: Next Steps
- Build Capstone Projects → Apply your skills
- Contribute to Open Source → Share your knowledge
- Stay Updated → AI evolves rapidly
- Build Something Amazing → Use your new skills

#### Slide 3: Thank You & Final Q&A
- Thank you for completing the course
- Questions and discussion
- Resources for continued learning
- Contact information

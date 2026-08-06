# AI Tutorial Series: Developer Edition
# Appendix C: Common Patterns & Anti-Patterns

**A practical guide to what works (and what doesn't) when building AI applications.**

---

## Table of Contents

1. [Introduction to Patterns](#introduction-to-patterns)
2. [Patterns: Prompt Engineering](#patterns-prompt-engineering)
3. [Patterns: RAG & Retrieval](#patterns-rag--retrieval)
4. [Patterns: Agents & Tool Use](#patterns-agents--tool-use)
5. [Patterns: Architecture & Deployment](#patterns-architecture--deployment)
6. [Anti-Patterns: Prompt Engineering](#anti-patterns-prompt-engineering)
7. [Anti-Patterns: RAG & Retrieval](#anti-patterns-rag--retrieval)
8. [Anti-Patterns: Agents & Tool Use](#anti-patterns-agents--tool-use)
9. [Anti-Patterns: Architecture & Deployment](#anti-patterns-architecture--deployment)
10. [Quick Reference: Pattern Selection](#quick-reference-pattern-selection)

---

## Introduction to Patterns

### What Are Patterns?

**Design patterns** are proven solutions to common problems. In AI development, patterns help you:
- Solve recurring challenges
- Avoid common mistakes
- Build more maintainable systems
- Make better architectural decisions

### What Are Anti-Patterns?

**Anti-patterns** are common solutions that seem reasonable but actually cause problems. Recognizing them helps you:
- Avoid costly mistakes
- Recognize warning signs
- Build more robust systems

---

## Patterns: Prompt Engineering

### 1. Chain-of-Thought (CoT)

**Problem:** Complex reasoning tasks (math, logic, multi-step problems) often produce incorrect results with simple prompts.

**Solution:** Ask the model to show its reasoning step by step.

```python
# Good - Chain-of-Thought
prompt = """
Question: If I have 3 apples, buy 2 more, then give away 1, how many do I have?

Let's solve step by step:
1. Start with: 3 apples
2. Buy 2 more: 3 + 2 = 5 apples
3. Give away 1: 5 - 1 = 4 apples

Answer: 4 apples
"""

# Bad - Direct answer (more likely to be wrong)
prompt = """
Question: If I have 3 apples, buy 2 more, then give away 1, how many do I have?
Answer:
"""
```

**When to use:** Math problems, logic puzzles, multi-step reasoning, any task requiring step-by-step thinking.

**Effectiveness:** High. Significantly improves accuracy on reasoning tasks.

---

### 2. Few-Shot Learning

**Problem:** The model doesn't understand the format or style you want.

**Solution:** Provide examples of the desired input-output format.

```python
# Good - Few-shot with examples
prompt = """
Extract the name, age, and job from each sentence.

Example 1:
Input: "John, 32, works as a software engineer"
Output: {"name": "John", "age": 32, "job": "software engineer"}

Example 2:
Input: "Sarah is a 28-year-old doctor"
Output: {"name": "Sarah", "age": 28, "job": "doctor"}

Now extract:
Input: "Mike, a 45-year-old teacher"
Output:
"""

# Bad - Zero-shot (format may be inconsistent)
prompt = """
Extract name, age, and job from: "Mike, a 45-year-old teacher"
"""
```

**When to use:** Structured output, classification, data extraction, format-sensitive tasks.

**Effectiveness:** High. Dramatically improves consistency and format adherence.

---

### 3. Role Prompting (Persona)

**Problem:** Generic responses lack the right tone, expertise, or perspective.

**Solution:** Give the AI a specific persona or role.

```python
# Good - Specific role
system_prompt = """
You are Dr. Sarah Chen, a leading AI researcher with 20 years of experience.
You explain complex concepts clearly using analogies.
You are patient, encouraging, and always cite your sources.
"""

# Bad - Generic persona
system_prompt = "You are a helpful assistant."
```

**When to use:** Customer support, expert consultation, creative writing, education.

**Effectiveness:** High. Dramatically changes tone, depth, and style of responses.

---

### 4. Self-Consistency

**Problem:** Single responses can be unreliable or inconsistent.

**Solution:** Generate multiple responses and take the most consistent one.

```python
# Good - Self-consistency
def get_consistent_answer(question, n=3):
    responses = []
    for _ in range(n):
        response = llm.generate(question, temperature=0.7)
        responses.append(response)
    
    # Find most common answer
    from collections import Counter
    answer_counts = Counter(responses)
    return answer_counts.most_common(1)[0][0]

# Bad - Single response
answer = llm.generate(question)
```

**When to use:** Critical decisions, factual questions, any case where accuracy is paramount.

**Effectiveness:** Medium-High. Improves accuracy but increases cost.

---

### 5. Structured Output

**Problem:** LLMs return inconsistent, hard-to-parse text.

**Solution:** Enforce a specific output format (JSON, XML) with schema validation.

```python
# Good - Structured output with schema
prompt = """
Return ONLY valid JSON with this schema:
{
    "name": "string",
    "age": "integer",
    "job": "string"
}

Text: "John Smith, 32, software engineer"
JSON:
"""

# Bad - Free text output
prompt = "Extract the information from: John Smith, 32, software engineer"
```

**When to use:** Data extraction, API integration, database operations, any machine-readable output.

**Effectiveness:** Very High. Essential for production systems.

---

## Patterns: RAG & Retrieval

### 6. Hybrid Search

**Problem:** Semantic search (embeddings) misses exact matches. Keyword search misses meaning.

**Solution:** Combine both semantic and keyword search with score fusion.

```python
# Good - Hybrid search
def hybrid_search(query, top_k=10):
    semantic_results = semantic_search(query, top_k=top_k*2)
    keyword_results = keyword_search(query, top_k=top_k*2)
    
    # Combine with weighted scores
    combined = {}
    for doc, score in semantic_results:
        combined[doc] = score * 0.7
    for doc, score in keyword_results:
        combined[doc] = combined.get(doc, 0) + score * 0.3
    
    # Return top_k results
    return sorted(combined.items(), key=lambda x: x[1], reverse=True)[:top_k]

# Bad - Single search method
results = semantic_search(query)  # May miss exact matches
# OR
results = keyword_search(query)   # May miss meaning
```

**When to use:** Most RAG systems. Especially when queries contain specific terms.

**Effectiveness:** High. Improves both recall and precision.

---

### 7. Parent-Child Retrieval

**Problem:** Small chunks lack context. Large chunks are less precise.

**Solution:** Retrieve small chunks (children) but return larger chunks (parents).

```python
# Good - Parent-child retrieval
def retrieve_with_context(query):
    # Find relevant child chunks
    child_results = vector_search(query, top_k=10)
    
    # Get their parent documents
    parent_ids = set([r.parent_id for r in child_results])
    parents = [get_parent(p) for p in parent_ids]
    
    return parents  # Returns full context

# Bad - Single-level retrieval
results = vector_search(query)  # Chunks may lack context
```

**When to use:** Long documents, semantic chunking, any case where context matters.

**Effectiveness:** High. Provides both precision and context.

---

### 8. Query Expansion

**Problem:** Short queries may not capture all relevant information.

**Solution:** Expand the query with related terms or variations.

```python
# Good - Query expansion
def expand_query(query):
    # Use LLM to generate related terms
    expanded = llm.generate(f"Generate 5 related search terms for: {query}")
    return query + " " + expanded

# Bad - Original query only
results = search(query)
```

**When to use:** Short queries, broad search, information retrieval.

**Effectiveness:** Medium. Improves recall but may reduce precision.

---

### 9. Context Compression

**Problem:** Retrieved chunks may exceed token limits or contain irrelevant information.

**Solution:** Compress chunks through summarization or extraction.

```python
# Good - Context compression
def compress_context(chunks, max_tokens=2000):
    # Extract key sentences or summarize
    compressed = []
    for chunk in chunks:
        summary = summarize(chunk, max_tokens=100)
        compressed.append(summary)
    return compressed

# Bad - Use all chunks (may exceed token limit)
context = "\n".join(chunks)
```

**When to use:** Large documents, limited context windows, cost optimization.

**Effectiveness:** High. Fits more relevant information in context.

---

## Patterns: Agents & Tool Use

### 10. Tool Orchestration

**Problem:** Single tools are not enough for complex tasks.

**Solution:** Orchestrate multiple tools in sequences or parallel workflows.

```python
# Good - Tool orchestration
def execute_workflow(goal):
    # Plan
    steps = planner.plan(goal)
    
    # Execute in sequence
    for step in steps:
        tool = get_tool(step.tool)
        result = tool.execute(step.args)
        context.update(result)
    
    return synthesize(context)

# Bad - Single tool execution
result = one_tool.execute(task)
```

**When to use:** Complex multi-step tasks, workflows, business processes.

**Effectiveness:** Very High. Enables truly autonomous agents.

---

### 11. Reflection & Self-Correction

**Problem:** Agents make mistakes and don't learn from them.

**Solution:** Add a reflection step where the agent evaluates and improves its work.

```python
# Good - Reflection
def run_with_reflection(task):
    # Initial attempt
    result = agent.execute(task)
    
    # Reflect
    reflection = agent.reflect(result)
    
    # Improve
    if reflection.score < 0.8:
        improved = agent.improve(result, reflection)
        return improved
    
    return result

# Bad - One-shot execution
result = agent.execute(task)
```

**When to use:** Complex reasoning, creative tasks, quality-critical operations.

**Effectiveness:** High. Dramatically improves output quality.

---

### 12. Hierarchical Planning

**Problem:** Flat plans don't handle complex dependencies.

**Solution:** Use hierarchical planning with sub-goals and dependencies.

```python
# Good - Hierarchical planning
def hierarchical_plan(goal):
    # Top-level plan
    high_level = decompose(goal)
    
    # For each sub-goal, create detailed plan
    detailed_plans = []
    for sub_goal in high_level:
        detailed = decompose(sub_goal)
        detailed_plans.append(detailed)
    
    return detailed_plans

# Bad - Flat plan
plan = [step1, step2, step3]  # Ignores dependencies
```

**When to use:** Complex tasks with dependencies, large-scale projects.

**Effectiveness:** High. Essential for complex agentic systems.

---

## Patterns: Architecture & Deployment

### 13. Circuit Breaker

**Problem:** Failing services can cause cascading failures.

**Solution:** Stop requests to failing services after a threshold of failures.

```python
# Good - Circuit breaker
class CircuitBreaker:
    def execute(self, func):
        if self.state == OPEN:
            if time.time() - self.last_failure > self.timeout:
                self.state = HALF_OPEN
            else:
                raise Exception("Circuit is open")
        
        try:
            result = func()
            if self.state == HALF_OPEN:
                self.success_count += 1
                if self.success_count >= self.success_threshold:
                    self.state = CLOSED
            return result
        except Exception:
            self.failure_count += 1
            if self.failure_count >= self.failure_threshold:
                self.state = OPEN
                self.last_failure = time.time()
            raise

# Bad - No circuit breaker
result = failing_api_call()  # Continues to fail, wasting resources
```

**When to use:** All external API calls, database operations, network services.

**Effectiveness:** Very High. Prevents cascading failures.

---

### 14. Exponential Backoff with Jitter

**Problem:** Immediate retries on failure cause more load (thundering herd).

**Solution:** Retry with increasing delays and random jitter.

```python
# Good - Exponential backoff with jitter
def retry_with_backoff(func, max_retries=5):
    for attempt in range(max_retries):
        try:
            return func()
        except:
            delay = (2 ** attempt) + random.random()
            time.sleep(delay)
    raise Exception("All retries failed")

# Bad - Immediate retry
def retry_immediate(func):
    for _ in range(3):
        try:
            return func()
        except:
            pass  # Immediate retry with no delay
    raise Exception("All retries failed")
```

**When to use:** All network calls, API requests, external services.

**Effectiveness:** High. Reduces load during failures.

---

### 15. Bulkhead Pattern

**Problem:** One service's failure can exhaust shared resources.

**Solution:** Isolate resources by service or component.

```python
# Good - Bulkhead isolation
class Bulkhead:
    def __init__(self, max_concurrent):
        self.max_concurrent = max_concurrent
        self.active = 0
        
    def execute(self, func):
        if self.active >= self.max_concurrent:
            raise Exception("Bulkhead full")
        
        self.active += 1
        try:
            return func()
        finally:
            self.active -= 1

# Bad - Shared resources
class BadService:
    def execute(self, func):
        return func()  # No isolation
```

**When to use:** Resource-constrained systems, multiple services sharing resources.

**Effectiveness:** Medium-High. Prevents resource exhaustion.

---

### 16. Cache First, API Second

**Problem:** Repeated identical queries waste time and money.

**Solution:** Check cache before making expensive API calls.

```python
# Good - Cache first
def get_response(prompt):
    cached = cache.get(prompt)
    if cached:
        return cached
    
    response = llm.generate(prompt)
    cache.set(prompt, response)
    return response

# Bad - Always call API
def get_response(prompt):
    return llm.generate(prompt)  # Expensive every time
```

**When to use:** Frequently asked questions, common queries, cost optimization.

**Effectiveness:** Very High. Reduces cost and latency significantly.

---

## Anti-Patterns: Prompt Engineering

### 1. The "Be Helpful" Trap

**Problem:** Vague system prompts like "Be helpful" lead to generic, unhelpful responses.

```python
# Bad - Too vague
system_prompt = "You are a helpful assistant."

# Good - Specific and actionable
system_prompt = """
You are a helpful assistant with these guidelines:
1. Always provide specific examples
2. If you don't know something, say so clearly
3. Structure responses with bullet points
4. Keep responses under 200 words
"""
```

**Why it's bad:** The model doesn't know what "helpful" means in your context.

**Fix:** Be specific about what "helpful" looks like.

---

### 2. Over-Engineering Prompts

**Problem:** Extremely long, complex prompts that confuse the model.

```python
# Bad - Over-engineered
prompt = """
You must absolutely under no circumstances...
Remember to follow these 47 rules...
Also ensure that you consider these 25 edge cases...
Never forget the 12 constraints...
"""

# Good - Concise and clear
prompt = """
Follow these 5 key guidelines:
1. Be concise
2. Use examples
3. Cite sources
4. Be honest about uncertainty
5. Stay on topic
"""
```

**Why it's bad:** The model loses focus on what matters.

**Fix:** Keep prompts focused on the most important 3-5 instructions.

---

### 3. Assuming Model Knowledge

**Problem:** Assuming the model knows about recent events or private information.

```python
# Bad - Assuming knowledge
prompt = "What happened in the AI conference yesterday?"

# Good - Provide context
prompt = """
Based on this article about yesterday's AI conference:
[ARTICLE TEXT]
What were the key takeaways?
"""
```

**Why it's bad:** Models have a knowledge cutoff date and no access to private information.

**Fix:** Provide context when the model may not know the information.

---

### 4. Inconsistent Formatting

**Problem:** Asking for structured output without specifying the format.

```python
# Bad - Inconsistent format
prompt = "Extract the name and age from: John Smith, 32"
# Output might be: "Name: John Smith, Age: 32"
# or: "John Smith is 32 years old"
# or: {"name": "John Smith", "age": 32}

# Good - Explicit format
prompt = """
Extract the name and age as JSON:
{"name": "...", "age": ...}
Text: John Smith, 32
"""
```

**Why it's bad:** Inconsistent outputs are hard to parse.

**Fix:** Always specify the exact format you want.

---

## Anti-Patterns: RAG & Retrieval

### 5. Over-Chunking

**Problem:** Making chunks too small, losing context and meaning.

```python
# Bad - Too small
chunks = [word for word in text.split()]  # Word-level chunks

# Good - Appropriate size
chunker = DocumentChunker(chunk_size=500, chunk_overlap=50)
chunks = chunker.chunk_document(text)
```

**Why it's bad:** Small chunks lose context, making retrieval less meaningful.

**Fix:** Use chunks of 300-1000 tokens with overlap.

---

### 6. Under-Chunking

**Problem:** Making chunks too large, reducing retrieval precision.

```python
# Bad - Too large
chunks = [text]  # Whole document as one chunk

# Good - Appropriate size
chunker = DocumentChunker(chunk_size=500)
chunks = chunker.chunk_document(text)
```

**Why it's bad:** Large chunks reduce precision and may exceed context windows.

**Fix:** Use chunks of 300-1000 tokens.

---

### 7. No Metadata Filtering

**Problem:** Retrieving irrelevant documents based on metadata.

```python
# Bad - No filtering
results = vector_search(query)  # Returns all documents

# Good - Metadata filtering
results = vector_search(
    query,
    filter_metadata={"source": "knowledge_base", "date": {"gte": "2024-01-01"}}
)
```

**Why it's bad:** Returns irrelevant or outdated information.

**Fix:** Use metadata filters to narrow retrieval scope.

---

## Anti-Patterns: Agents & Tool Use

### 8. Too Many Tools

**Problem:** Giving the agent too many tools, causing confusion.

```python
# Bad - Too many tools
tools = [weather, calculator, email, database, search, translate, 
         calendar, news, stocks, images, pdf, etc.]

# Good - Limited, focused set
tools = [weather, database, email]  # Only what's needed
```

**Why it's bad:** The agent struggles to choose the right tool.

**Fix:** Limit tools to what's necessary for the task.

---

### 9. No Tool Validation

**Problem:** Accepting tool calls without validating arguments.

```python
# Bad - No validation
def execute_tool(tool_name, args):
    return tools[tool_name](**args)  # Dangerous!

# Good - Validation
def execute_tool(tool_name, args):
    # Validate schema
    validate_against_schema(tool_name, args)
    # Check permissions
    check_permissions(user, tool_name)
    # Sanitize args
    args = sanitize(args)
    return tools[tool_name](**args)
```

**Why it's bad:** Opens the door to injection attacks and abuse.

**Fix:** Always validate and sanitize tool calls.

---

## Anti-Patterns: Architecture & Deployment

### 10. No Fallback

**Problem:** Relying on a single model with no backup.

```python
# Bad - Single point of failure
def get_response(prompt):
    return primary_model.generate(prompt)  # If this fails, everything fails

# Good - Multiple fallbacks
def get_response(prompt):
    try:
        return primary_model.generate(prompt)
    except:
        try:
            return backup_model.generate(prompt)
        except:
            return cache.get(prompt) or "Service temporarily unavailable"
```

**Why it's bad:** Single point of failure.

**Fix:** Always have fallback strategies.

---

### 11. No Observability

**Problem:** Deploying AI without monitoring, logging, or metrics.

```python
# Bad - No observability
result = llm.generate(prompt)
return result

# Good - Full observability
def handle_request(prompt):
    start = time.time()
    log.info("Request started", prompt=prompt)
    
    try:
        result = llm.generate(prompt)
        log.info("Request completed", 
                 latency=time.time()-start,
                 tokens=result.usage)
        return result
    except Exception as e:
        log.error("Request failed", error=str(e))
        raise
```

**Why it's bad:** You can't debug, optimize, or understand your system.

**Fix:** Implement logging, metrics, and monitoring from day one.

---

### 12. Manual Everything

**Problem:** Doing everything manually instead of automating.

```python
# Bad - Manual deployment
# 1. Build image manually
# 2. Upload manually
# 3. Deploy manually
# 4. Monitor manually

# Good - Automated pipeline
# 1. CI/CD triggers on push
# 2. Tests run automatically
# 3. Build and deploy automatically
# 4. Monitoring alerts automatically
```

**Why it's bad:** Manual processes are slow, error-prone, and unscalable.

**Fix:** Automate everything with CI/CD pipelines.

---

## Quick Reference: Pattern Selection

### When to Use Each Pattern

| Pattern | Best For | When Not To Use |
|---------|----------|-----------------|
| **Chain-of-Thought** | Reasoning, math, logic | Simple factual questions |
| **Few-Shot Learning** | Structured output, classification | Open-ended creative tasks |
| **Role Prompting** | Consistent persona, expertise | Generic, factual queries |
| **Self-Consistency** | Critical decisions, accuracy | Cost-sensitive applications |
| **Structured Output** | Data extraction, APIs | Free-form conversation |
| **Hybrid Search** | RAG systems | Simple retrieval tasks |
| **Parent-Child Retrieval** | Long documents, context | Short documents |
| **Tool Orchestration** | Complex workflows | Single, simple tasks |
| **Reflection** | Quality-critical tasks | Simple, low-stakes tasks |
| **Circuit Breaker** | All API calls | Local operations |
| **Exponential Backoff** | All network calls | Local operations |
| **Bulkhead** | Resource sharing | Isolated services |
| **Cache First** | Frequent queries | One-time queries |

### Pattern Anti-Pattern Cheat Sheet

| Do ✅ | Don't ❌ |
|-------|----------|
| Be specific in prompts | Use vague instructions |
| Provide examples | Assume the model knows everything |
| Validate tool calls | Accept tool calls without validation |
| Use structured outputs | Accept inconsistent formats |
| Implement fallbacks | Rely on a single point of failure |
| Add observability | Deploy without monitoring |
| Automate deployments | Do everything manually |
| Use hybrid search | Rely on a single search method |
| Provide context in RAG | Use chunks that are too small/large |
| Implement reflection | Execute agents without self-correction |

---

**End of Appendix C**

# AI Tutorial Series: Developer Edition
# Appendix D: Deployment Checklist & Troubleshooting

**A practical guide to deploying AI applications successfully and troubleshooting common issues.**

---

## Table of Contents

1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Deployment Checklist](#deployment-checklist)
3. [Post-Deployment Checklist](#post-deployment-checklist)
4. [Common Issues & Solutions](#common-issues--solutions)
5. [Environment-Specific Issues](#environment-specific-issues)
6. [Performance Issues](#performance-issues)
7. [Cost Issues](#cost-issues)
8. [Security Issues](#security-issues)
9. [Debugging Techniques](#debugging-techniques)
10. [Quick Reference: Commands](#quick-reference-commands)

---

## Pre-Deployment Checklist

### Code Quality
- [ ] **Code Review** — All code has been reviewed
- [ ] **Tests** — Unit tests pass (run `pytest`)
- [ ] **Integration Tests** — Integration tests pass
- [ ] **Linting** — Code style checks pass (run `flake8`, `black`)
- [ ] **Type Checking** — Type hints verified (run `mypy`)
- [ ] **Security Scan** — No known vulnerabilities (run `bandit`, `safety`)

### Environment Setup
- [ ] **Environment Variables** — All required env vars are defined
- [ ] **Secrets** — Secrets are stored securely (not in code)
- [ ] **Dependencies** — All dependencies are pinned
- [ ] **Python Version** — Correct Python version specified
- [ ] **Docker** — Dockerfile is optimized and tested

### Configuration
- [ ] **Model Selection** — Appropriate model chosen for workload
- [ ] **Configuration Files** — All config files are validated
- [ ] **Logging** — Log levels configured correctly
- [ ] **Metrics** — Monitoring metrics defined

### Dependencies
- [ ] **requirements.txt** — All dependencies listed
- [ ] **Docker Build** — Image builds successfully
- [ ] **Local Test** — Application runs locally
- [ ] **Resource Estimates** — CPU/memory requirements estimated

---

## Deployment Checklist

### Infrastructure
- [ ] **Container Registry** — Image pushed to registry
- [ ] **Kubernetes Manifests** — All manifests validated
- [ ] **Storage** — Persistent volumes configured (if needed)
- [ ] **Networking** — Ingress/Service configured
- [ ] **GPU Support** — GPU nodes configured (if needed)

### Kubernetes Deployment
```bash
# Validate manifests
kubectl apply --dry-run=client -f deployment.yaml
kubectl apply --dry-run=client -f service.yaml
kubectl apply --dry-run=client -f ingress.yaml

# Apply manifests
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

# Check deployment status
kubectl rollout status deployment/ai-service -n ai-apps
kubectl get pods -n ai-apps
kubectl get services -n ai-apps
```

### Configuration
- [ ] **ConfigMap** — ConfigMap is applied
- [ ] **Secrets** — Secrets are applied (base64 encoded)
- [ ] **Environment** — Environment variables are correct
- [ ] **Model Cache** — Model cache is pre-loaded (if applicable)

### Scaling
- [ ] **Replicas** — Appropriate number of replicas
- [ ] **HPA** — Horizontal Pod Autoscaler configured
- [ ] **Resource Limits** — CPU/memory limits set
- [ ] **GPU Resources** — GPU resources specified (if needed)

---

## Post-Deployment Checklist

### Health Checks
- [ ] **Liveness Probe** — Health check endpoint responds
- [ ] **Readiness Probe** — Service is ready to receive traffic
- [ ] **Startup Probe** — Service starts within expected time
- [ ] **Logs** — No error logs at startup
- [ ] **Metrics** — Metrics are being collected

```bash
# Check health endpoints
curl http://localhost:8000/health
curl http://localhost:8000/ready
curl http://localhost:8000/metrics

# Check logs
kubectl logs -f deployment/ai-service -n ai-apps
kubectl logs -f deployment/ai-service -n ai-apps --tail=100
```

### Monitoring
- [ ] **Logging** — Logs are being collected
- [ ] **Tracing** — Traces are being collected
- [ ] **Metrics** — Metrics are being collected
- [ ] **Alerting** — Alerts are configured
- [ ] **Dashboards** — Dashboards are set up

### Security
- [ ] **Authentication** — API authentication is working
- [ ] **Authorization** — Permissions are correct
- [ ] **Rate Limiting** — Rate limits are enforced
- [ ] **Input Validation** — Inputs are being validated
- [ ] **Output Filtering** — Outputs are being filtered

### Performance
- [ ] **Latency** — Latency is within expected range
- [ ] **Throughput** — Throughput meets requirements
- [ ] **Error Rate** — Error rate is acceptable
- [ ] **Resource Usage** — CPU/memory usage is stable
- [ ] **Cost** — Cost is within budget

---

## Common Issues & Solutions

### 1. Rate Limit Exceeded (HTTP 429)

**Symptoms:**
- API returns 429 Too Many Requests
- Requests are failing intermittently

**Causes:**
- Hitting provider rate limits
- Too many concurrent requests
- Not using exponential backoff

**Solutions:**
```python
# Implement exponential backoff with retry
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(5),
    wait=wait_exponential(multiplier=1, min=2, max=30)
)
def make_api_call():
    return client.generate(prompt)

# Implement rate limiting
from rate_limiter import RateLimiter
limiter = RateLimiter(rate=10, capacity=10)
if limiter.allow_request():
    make_api_call()
```

### 2. Context Window Exceeded

**Symptoms:**
- Error: "This model's maximum context length is X tokens"
- Responses are truncated

**Causes:**
- Too many tokens in prompt + history
- Not managing conversation history

**Solutions:**
```python
# Truncate conversation history
def truncate_history(messages, max_tokens=8000):
    while count_tokens(messages) > max_tokens:
        messages.pop(1)  # Remove oldest non-system message
    return messages

# Summarize old messages
def summarize_history(messages):
    old = messages[1:-5]  # Keep system + last 5 messages
    summary = summarize_with_llm(old)
    return [messages[0]] + [{"role": "system", "content": summary}] + messages[-5:]
```

### 3. High Latency

**Symptoms:**
- Responses take more than 3-5 seconds
- User experience is poor

**Causes:**
- Using a slow model
- Network latency
- Large payloads
- Under-provisioned resources

**Solutions:**
```python
# Use a faster model
model = "gpt-4o-mini"  # Fast, cheap

# Stream responses
stream = client.generate(prompt, stream=True)
for chunk in stream:
    send_to_user(chunk)

# Cache common responses
cached = cache.get(prompt)
if cached:
    return cached

# Optimize prompts (shorter = faster)
# Remove unnecessary instructions, shorten context
```

### 4. High Costs

**Symptoms:**
- Monthly bill is higher than expected
- Token usage is increasing rapidly

**Causes:**
- Using expensive models
- Processing too many tokens
- Not caching responses
- Not optimizing prompts

**Solutions:**
```python
# Use cheaper model
model = "gpt-4o-mini"  # 33x cheaper than gpt-4o

# Implement caching
def get_response(prompt):
    cached = cache.get(prompt)
    if cached:
        return cached
    
    response = llm.generate(prompt)
    cache.set(prompt, response)
    return response

# Optimize prompts
# - Remove redundant text
# - Use concise instructions
# - Truncate unnecessary context

# Monitor costs
from cost_monitor import CostMonitor
monitor = CostMonitor()
monitor.track(model, prompt_tokens, completion_tokens)
```

### 5. Hallucinations

**Symptoms:**
- Responses contain false information
- Model makes up facts

**Causes:**
- Asking about things outside knowledge base
- Open-ended prompts
- No grounding in facts

**Solutions:**
```python
# Use RAG to ground responses
def generate_with_rag(query):
    context = retrieve_context(query)
    prompt = f"Based on: {context}\nAnswer: {query}"
    return llm.generate(prompt)

# Add guardrails
guardrails = [
    "Only answer based on the provided context",
    "If you don't know, say 'I don't know'",
    "Cite sources when possible"
]

# Lower temperature
response = llm.generate(prompt, temperature=0.3)  # More deterministic
```

### 6. Tool Execution Failures

**Symptoms:**
- Agent tool calls fail
- Tool returns unexpected results

**Causes:**
- Tool arguments are invalid
- Tool errors
- Network issues

**Solutions:**
```python
# Validate tool arguments
def validate_tool_args(tool_name, args):
    schema = get_tool_schema(tool_name)
    validate_against_schema(args, schema)

# Add error handling
def execute_tool(tool_name, args):
    try:
        return tools[tool_name](**args)
    except Exception as e:
        return {"error": str(e)}

# Implement retries
def execute_with_retry(tool_name, args, max_retries=3):
    for i in range(max_retries):
        try:
            return tools[tool_name](**args)
        except:
            time.sleep(2 ** i)  # Exponential backoff
    raise Exception("Tool execution failed")
```

---

## Environment-Specific Issues

### Local Development

**Issue:** "ModuleNotFoundError"
**Solution:**
```bash
# Install dependencies
pip install -r requirements.txt

# Or use virtual environment
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**Issue:** "Port already in use"
**Solution:**
```bash
# Find process using port 8000
lsof -i :8000
kill -9 <PID>

# Or use different port
uvicorn app:app --port 8001
```

### Docker

**Issue:** "Docker build fails"
**Solution:**
```bash
# Check Dockerfile syntax
docker build -t ai-service:latest .

# View build logs
docker build --progress=plain -t ai-service:latest .

# Clean Docker cache
docker system prune -f
```

**Issue:** "Container exits immediately"
**Solution:**
```bash
# Check logs
docker logs <container_id>

# Run interactively
docker run -it ai-service:latest /bin/bash

# Check environment variables
docker run -it ai-service:latest env
```

### Kubernetes

**Issue:** "Pod stuck in CrashLoopBackOff"
**Solution:**
```bash
# Check pod logs
kubectl logs <pod_name> -n ai-apps

# Describe pod for events
kubectl describe pod <pod_name> -n ai-apps

# Check previous logs (if pod restarted)
kubectl logs <pod_name> -n ai-apps --previous
```

**Issue:** "ImagePullBackOff"
**Solution:**
```bash
# Check image name
kubectl describe pod <pod_name> -n ai-apps

# Ensure image exists in registry
docker pull <image_name>

# Check image pull secrets
kubectl get secrets -n ai-apps
```

---

## Performance Issues

### 1. Slow Response Times

**Troubleshooting Steps:**
1. Check model latency
2. Check network latency
3. Check resource utilization
4. Check request size

**Diagnostics:**
```python
# Measure latency
import time
start = time.time()
response = llm.generate(prompt)
latency = time.time() - start
print(f"Latency: {latency*1000:.2f}ms")

# Profile endpoints
from fastapi import Request
@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response
```

### 2. High CPU/Memory Usage

**Troubleshooting Steps:**
1. Check if resource limits are set
2. Check if there are memory leaks
3. Check if requests are too large

**Solutions:**
```yaml
# Kubernetes resource limits
resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "1Gi"
    cpu: "500m"

# Python memory optimization
# Use generators for large datasets
def process_large_data(data):
    for item in data:  # Generator, not list
        yield process(item)

# Limit concurrent requests
from semaphore import Semaphore
semaphore = Semaphore(10)
async with semaphore:
    response = await llm.generate(prompt)
```

---

## Cost Issues

### 1. Unexpected High Costs

**Troubleshooting Steps:**
1. Check token usage
2. Check model selection
3. Check for unnecessary API calls

**Diagnostics:**
```python
# Track token usage
from cost_monitor import CostMonitor
monitor = CostMonitor()
monitor.track(model, prompt_tokens, completion_tokens)

# Log cost per request
def log_cost(model, prompt_tokens, completion_tokens):
    cost = calculate_cost(model, prompt_tokens, completion_tokens)
    logger.info(f"Request cost: ${cost:.4f}")
    return cost

# Set budget alerts
if total_cost > budget_threshold:
    alert("Cost threshold exceeded")
```

### 2. Model Too Expensive

**Solution:**
```python
# Use cheaper model for simple tasks
def get_model_for_task(task_type):
    if task_type in ["simple_qa", "classification"]:
        return "gpt-4o-mini"
    elif task_type in ["complex_reasoning"]:
        return "gpt-4o"
    else:
        return "gpt-4o-mini"

# Use fallback model
def generate_with_fallback(prompt):
    try:
        return expensive_model.generate(prompt)
    except Exception:
        return cheap_model.generate(prompt)
```

---

## Security Issues

### 1. Prompt Injection

**Symptoms:**
- Model ignores system prompt
- Model produces harmful content

**Solutions:**
```python
# Input validation
from injection_detector import PromptInjectionDetector
detector = PromptInjectionDetector()

def validate_prompt(prompt):
    result = detector.detect(prompt)
    if result["is_injection"]:
        raise ValueError("Prompt injection detected")
    return prompt

# Output filtering
from leakage_protector import DataLeakageProtector
protector = DataLeakageProtector()

def filter_output(output):
    return protector.redact(output)
```

### 2. Data Leakage

**Symptoms:**
- API keys in responses
- Personal information exposed

**Solutions:**
```python
# Redact sensitive data
def redact_output(text):
    patterns = [
        (r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', '[EMAIL]'),
        (r'\b\d{3}-\d{2}-\d{4}\b', '[SSN]'),
        (r'(sk-\w{20,})', '[API_KEY]'),
    ]
    for pattern, replacement in patterns:
        text = re.sub(pattern, replacement, text)
    return text

# Implement output filtering
from output_filter import OutputFilter
filter = OutputFilter()
filter.add_rule("no_api_keys", r'sk-\w+', "API key detected")
filter.add_rule("no_pii", r'\b\d{3}-\d{2}-\d{4}\b', "SSN detected")
```

---

## Debugging Techniques

### 1. Logging

```python
# Structured logging
import logging

logger = logging.getLogger(__name__)

# Add context
logger.info(
    "Request processed",
    extra={
        "request_id": request_id,
        "model": model,
        "latency_ms": latency,
        "tokens": tokens
    }
)

# Use different log levels
logger.debug("Detailed debug info")
logger.info("Normal operation")
logger.warning("Warning: Something is off")
logger.error("Error occurred")
logger.critical("Critical failure")
```

### 2. Tracing

```python
# Implement distributed tracing
from tracer import Tracer

tracer = Tracer()

def handle_request(request):
    with tracer.start_span("handle_request"):
        with tracer.start_span("validate"):
            validate(request)
        
        with tracer.start_span("generate"):
            response = llm.generate(request.prompt)
        
        with tracer.start_span("post_process"):
            result = post_process(response)
        
        return result
```

### 3. Health Checks

```python
# Implement health checks
@app.get("/health")
def health():
    # Check dependencies
    llm_healthy = check_llm()
    db_healthy = check_db()
    cache_healthy = check_cache()
    
    return {
        "status": "healthy" if all([llm_healthy, db_healthy, cache_healthy]) else "unhealthy",
        "llm": llm_healthy,
        "db": db_healthy,
        "cache": cache_healthy
    }
```

---

## Quick Reference: Commands

### Docker Commands

```bash
# Build
docker build -t ai-service:latest .
docker build --no-cache -t ai-service:latest .

# Run
docker run -p 8000:8000 ai-service:latest
docker run -e OPENAI_API_KEY=sk-... ai-service:latest
docker run -d --name ai-service ai-service:latest

# Debug
docker logs ai-service
docker logs -f ai-service
docker exec -it ai-service /bin/bash

# Cleanup
docker stop ai-service
docker rm ai-service
docker rmi ai-service:latest
```

### Kubernetes Commands

```bash
# Apply
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

# Check
kubectl get pods -n ai-apps
kubectl get services -n ai-apps
kubectl get ingresses -n ai-apps
kubectl get hpa -n ai-apps

# Debug
kubectl logs -f deployment/ai-service -n ai-apps
kubectl describe pod ai-service-xxxx -n ai-apps
kubectl exec -it ai-service-xxxx -n ai-apps -- /bin/bash

# Rollback
kubectl rollout undo deployment/ai-service -n ai-apps
kubectl rollout status deployment/ai-service -n ai-apps

# Delete
kubectl delete -f deployment.yaml
kubectl delete namespace ai-apps
```

### Testing Commands

```bash
# Run tests
pytest tests/
pytest tests/ -v
pytest tests/test_app.py -v

# Coverage
pytest tests/ --cov=./ --cov-report=html
pytest tests/ --cov=./ --cov-report=term

# Linting
flake8 app.py tests/
black --check app.py tests/
mypy app.py tests/
```

### Monitoring Commands

```bash
# Check logs
tail -f logs/app.log
grep ERROR logs/app.log

# Check metrics
curl http://localhost:8000/metrics
curl http://localhost:8000/debug/pprof/

# Check resources
kubectl top pods -n ai-apps
kubectl top nodes
```

---

**End of Appendix D**

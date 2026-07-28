# Primer 18: Model Optimization and Acceleration

## Overview

This primer provides a comprehensive guide to model optimization and acceleration—techniques for making ML models faster, smaller, and more efficient without sacrificing accuracy. Understanding these concepts is essential for deploying models in production, especially on edge devices with limited resources.

---

## 1. Why Model Optimization Matters

### The Optimization Challenge

```
┌─────────────────────────────────────────────────────────────────┐
│              THE OPTIMIZATION CHALLENGE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Model Size vs Performance                                     │
│  └── Larger models perform better but are slower              │
│      • GPT-3: 175B parameters (too large for edge)             │
│      • MobileNet: 4M parameters (works on phones)             │
│      • Trade-off: Accuracy vs. Speed vs. Size                 │
│                                                                 │
│  Deployment Constraints                                        │
│  └── Different environments have different needs              │
│      • Cloud: Large models, high latency tolerance            │
│      • Edge: Small models, low latency, low power             │
│      • Mobile: Tiny models, battery-conscious                 │
│      • IoT: Ultra-tiny models, extremely constrained          │
│                                                                 │
│  Business Impact                                               │
│  └── Optimization affects cost and user experience            │
│      • Faster inference = lower infrastructure costs          │
│      • Smaller models = lower storage costs                   │
│      • Lower latency = better user experience                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Optimization Techniques Overview

```
┌─────────────────────────────────────────────────────────────────┐
│              OPTIMIZATION TECHNIQUES                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Model Compression                                              │
│  ├── Pruning: Remove unimportant weights                       │
│  ├── Quantization: Reduce precision (FP32 → INT8)             │
│  ├── Knowledge Distillation: Train smaller student            │
│  └── Architecture Search: Find efficient architectures        │
│                                                                 │
│  Inference Acceleration                                        │
│  ├── Batch Processing: Process multiple inputs together       │
│  ├── Caching: Reuse computations                              │
│  ├── Graph Optimization: Optimize computation graph           │
│  └── Hardware Acceleration: GPU, TPU, NPU                     │
│                                                                 │
│  Model Architecture                                            │
│  ├── Efficient Architectures: MobileNet, EfficientNet         │
│  ├── Depthwise Separable Convolutions                         │
│  ├── Attention Optimization: Sparse attention                 │
│  └── Neural Architecture Search: AutoML                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Model Pruning

### Magnitude Pruning

```python
import torch
import torch.nn as nn
import numpy as np

class Pruner:
    """Model pruning utilities."""
    
    def __init__(self, model):
        self.model = model
    
    def magnitude_prune(self, pruning_ratio=0.5):
        """
        Prune weights based on magnitude.
        
        Args:
            pruning_ratio: Ratio of weights to remove
        """
        parameters = []
        for name, param in self.model.named_parameters():
            if 'weight' in name:
                parameters.append((name, param))
        
        # Get all weights
        all_weights = torch.cat([p[1].view(-1) for p in parameters])
        threshold = torch.quantile(torch.abs(all_weights), pruning_ratio)
        
        # Apply pruning mask
        for name, param in parameters:
            mask = torch.abs(param) > threshold
            param.data *= mask.float()
        
        return self.model
    
    def structured_prune(self, pruning_ratio=0.3):
        """
        Prune entire neurons/channels.
        
        Args:
            pruning_ratio: Ratio of neurons to remove
        """
        # Calculate L1 norm per neuron
        for name, module in self.model.named_modules():
            if isinstance(module, nn.Linear):
                # For linear layers
                weights = module.weight.data
                l1_norms = torch.sum(torch.abs(weights), dim=1)
                threshold = torch.quantile(l1_norms, pruning_ratio)
                
                # Keep neurons with high L1 norm
                keep_indices = l1_norms > threshold
                module.weight.data = weights[keep_indices]
                
                if module.bias is not None:
                    module.bias.data = module.bias.data[keep_indices]
        
        return self.model

# Example usage
model = create_model()
pruner = Pruner(model)
pruned_model = pruner.magnitude_prune(pruning_ratio=0.3)
```

### Iterative Pruning

```python
def iterative_pruning(model, train_loader, val_loader, prune_ratio=0.1, epochs=5):
    """
    Iteratively prune and fine-tune model.
    
    Args:
        model: Model to prune
        train_loader: Training data
        val_loader: Validation data
        prune_ratio: Ratio to prune each iteration
        epochs: Fine-tuning epochs between prunes
    
    Returns:
        nn.Module: Pruned model
    """
    pruner = Pruner(model)
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    
    for iteration in range(5):
        # Prune
        pruner.magnitude_prune(prune_ratio)
        
        # Fine-tune
        for epoch in range(epochs):
            model.train()
            for batch_idx, (data, target) in enumerate(train_loader):
                optimizer.zero_grad()
                output = model(data)
                loss = nn.CrossEntropyLoss()(output, target)
                loss.backward()
                optimizer.step()
        
        # Evaluate
        model.eval()
        val_loss = 0
        correct = 0
        with torch.no_grad():
            for data, target in val_loader:
                output = model(data)
                val_loss += nn.CrossEntropyLoss()(output, target).item()
                pred = output.argmax(dim=1, keepdim=True)
                correct += pred.eq(target.view_as(pred)).sum().item()
        
        accuracy = 100. * correct / len(val_loader.dataset)
        print(f"Iteration {iteration}: Accuracy: {accuracy:.2f}%")
    
    return model
```

---

## 3. Quantization

### Post-Training Quantization

```python
import torch
import torch.quantization as quant

def quantize_model(model, calibration_loader):
    """
    Apply post-training quantization.
    
    Args:
        model: Model to quantize
        calibration_loader: Data for calibration
    
    Returns:
        nn.Module: Quantized model
    """
    # Prepare model for quantization
    model.eval()
    model.qconfig = torch.quantization.get_default_qconfig('fbgemm')
    
    # Fuse layers (for better quantization)
    torch.quantization.fuse_modules(model, [['conv1', 'bn1', 'relu1']], inplace=True)
    
    # Prepare and calibrate
    model_prepared = torch.quantization.prepare(model)
    
    # Calibrate with sample data
    with torch.no_grad():
        for batch in calibration_loader:
            model_prepared(batch)
    
    # Convert to quantized model
    model_quantized = torch.quantization.convert(model_prepared)
    
    return model_quantized

# Quantization-aware training
def quantization_aware_training(model, train_loader, epochs=5):
    """
    Train with quantization awareness.
    
    Args:
        model: Model to train
        train_loader: Training data
        epochs: Number of epochs
    
    Returns:
        nn.Module: Quantization-aware trained model
    """
    # Prepare for quantization-aware training
    model.qconfig = torch.quantization.get_default_qat_qconfig('fbgemm')
    
    # Fuse layers
    torch.quantization.fuse_modules(model, [['conv1', 'bn1', 'relu1']], inplace=True)
    
    model_prepared = torch.quantization.prepare_qat(model)
    
    # Training
    optimizer = torch.optim.Adam(model_prepared.parameters(), lr=0.001)
    
    for epoch in range(epochs):
        model_prepared.train()
        for batch_idx, (data, target) in enumerate(train_loader):
            optimizer.zero_grad()
            output = model_prepared(data)
            loss = nn.CrossEntropyLoss()(output, target)
            loss.backward()
            optimizer.step()
    
    # Convert to quantized model
    model_quantized = torch.quantization.convert(model_prepared)
    
    return model_quantized
```

### Dynamic Quantization

```python
def dynamic_quantize_model(model):
    """
    Apply dynamic quantization.
    
    Args:
        model: Model to quantize
    
    Returns:
        nn.Module: Dynamically quantized model
    """
    # Dynamic quantization for LSTM, Linear layers
    quantized_model = torch.quantization.quantize_dynamic(
        model,
        {nn.Linear, nn.LSTM, nn.GRU},
        dtype=torch.qint8
    )
    
    return quantized_model

def compare_model_size(model, quantized_model):
    """
    Compare model sizes.
    
    Args:
        model: Original model
        quantized_model: Quantized model
    
    Returns:
        dict: Size comparison
    """
    import io
    
    # Save models
    buffer_original = io.BytesIO()
    torch.save(model.state_dict(), buffer_original)
    size_original = buffer_original.getbuffer().nbytes
    
    buffer_quantized = io.BytesIO()
    torch.save(quantized_model.state_dict(), buffer_quantized)
    size_quantized = buffer_quantized.getbuffer().nbytes
    
    return {
        'original_size_mb': size_original / 1024 / 1024,
        'quantized_size_mb': size_quantized / 1024 / 1024,
        'compression_ratio': size_original / size_quantized,
        'size_reduction_pct': (1 - size_quantized / size_original) * 100
    }
```

---

## 4. Knowledge Distillation

### Teacher-Student Training

```python
class DistillationLoss(nn.Module):
    """Knowledge distillation loss."""
    
    def __init__(self, temperature=4.0, alpha=0.5):
        """
        Initialize distillation loss.
        
        Args:
            temperature: Temperature for softening
            alpha: Weight for distillation loss
        """
        super().__init__()
        self.temperature = temperature
        self.alpha = alpha
        self.ce_loss = nn.CrossEntropyLoss()
        self.kl_loss = nn.KLDivLoss(reduction='batchmean')
    
    def forward(self, student_logits, teacher_logits, targets):
        """
        Compute distillation loss.
        
        Args:
            student_logits: Student model outputs
            teacher_logits: Teacher model outputs
            targets: Ground truth labels
        
        Returns:
            torch.Tensor: Combined loss
        """
        # Hard label loss
        hard_loss = self.ce_loss(student_logits, targets)
        
        # Soft label loss (distillation)
        soft_teacher = nn.functional.softmax(teacher_logits / self.temperature, dim=1)
        soft_student = nn.functional.log_softmax(student_logits / self.temperature, dim=1)
        
        distill_loss = self.kl_loss(soft_student, soft_teacher) * (self.temperature ** 2)
        
        # Combine losses
        return self.alpha * hard_loss + (1 - self.alpha) * distill_loss

def distill_knowledge(teacher, student, train_loader, epochs=10, temperature=4.0, alpha=0.5):
    """
    Perform knowledge distillation.
    
    Args:
        teacher: Teacher model (larger, trained)
        student: Student model (smaller, to train)
        train_loader: Training data
        epochs: Number of epochs
        temperature: Temperature for softening
        alpha: Weight for distillation loss
    
    Returns:
        nn.Module: Trained student model
    """
    # Freeze teacher
    teacher.eval()
    
    # Optimizer and loss
    optimizer = torch.optim.Adam(student.parameters(), lr=0.001)
    criterion = DistillationLoss(temperature=temperature, alpha=alpha)
    
    student.train()
    for epoch in range(epochs):
        total_loss = 0
        for batch_idx, (data, target) in enumerate(train_loader):
            optimizer.zero_grad()
            
            # Get teacher predictions
            with torch.no_grad():
                teacher_output = teacher(data)
            
            # Get student predictions
            student_output = student(data)
            
            # Compute distillation loss
            loss = criterion(student_output, teacher_output, target)
            
            loss.backward()
            optimizer.step()
            
            total_loss += loss.item()
        
        avg_loss = total_loss / len(train_loader)
        print(f"Epoch {epoch+1}/{epochs}, Loss: {avg_loss:.4f}")
    
    return student
```

### Self-Distillation

```python
def self_distillation(model, train_loader, epochs=10):
    """
    Self-distillation: train with predictions from earlier epochs.
    
    Args:
        model: Model to train
        train_loader: Training data
        epochs: Number of epochs
    
    Returns:
        nn.Module: Trained model
    """
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    criterion = nn.CrossEntropyLoss()
    
    # Store predictions from previous epochs
    previous_outputs = []
    
    for epoch in range(epochs):
        model.train()
        total_loss = 0
        
        for batch_idx, (data, target) in enumerate(train_loader):
            optimizer.zero_grad()
            output = model(data)
            
            # Hard loss
            hard_loss = criterion(output, target)
            
            # Soft loss (self-distillation)
            if previous_outputs:
                # Average previous predictions
                avg_output = torch.stack(previous_outputs).mean(dim=0)
                soft_loss = nn.KLDivLoss(reduction='batchmean')(
                    nn.functional.log_softmax(output / 4.0, dim=1),
                    nn.functional.softmax(avg_output / 4.0, dim=1)
                ) * (4.0 ** 2)
                
                loss = 0.5 * hard_loss + 0.5 * soft_loss
            else:
                loss = hard_loss
            
            loss.backward()
            optimizer.step()
            
            total_loss += loss.item()
        
        # Store output for next epoch
        with torch.no_grad():
            model.eval()
            epoch_outputs = []
            for data, _ in train_loader:
                epoch_outputs.append(model(data))
            previous_outputs = epoch_outputs
        
        avg_loss = total_loss / len(train_loader)
        print(f"Epoch {epoch+1}/{epochs}, Loss: {avg_loss:.4f}")
    
    return model
```

---

## 5. Inference Optimization

### Batch Processing

```python
def batch_inference(model, data, batch_size=32):
    """
    Run inference in batches.
    
    Args:
        model: Model for inference
        data: Input data
        batch_size: Batch size
    
    Returns:
        np.ndarray: Predictions
    """
    model.eval()
    predictions = []
    
    with torch.no_grad():
        for i in range(0, len(data), batch_size):
            batch = data[i:i+batch_size]
            output = model(batch)
            predictions.append(output.numpy())
    
    return np.concatenate(predictions, axis=0)

def benchmark_batch_sizes(model, data, batch_sizes=None):
    """
    Benchmark inference speed for different batch sizes.
    
    Args:
        model: Model to benchmark
        data: Input data
        batch_sizes: List of batch sizes to test
    
    Returns:
        dict: Benchmark results
    """
    if batch_sizes is None:
        batch_sizes = [1, 2, 4, 8, 16, 32, 64]
    
    import time
    results = {
        'batch_sizes': [],
        'times': [],
        'throughputs': []
    }
    
    for batch_size in batch_sizes:
        total_time = 0
        n_batches = max(1, 100 // batch_size)
        
        for i in range(n_batches):
            batch = data[:batch_size]
            
            start_time = time.time()
            model(batch)
            elapsed = time.time() - start_time
            
            total_time += elapsed
        
        avg_time = total_time / n_batches
        throughput = batch_size / avg_time
        
        results['batch_sizes'].append(batch_size)
        results['times'].append(avg_time)
        results['throughputs'].append(throughput)
        
        print(f"Batch Size: {batch_size}, Time: {avg_time*1000:.2f}ms, Throughput: {throughput:.2f} samples/sec")
    
    return results
```

### Graph Optimization

```python
def optimize_graph(model, sample_input):
    """
    Optimize model computation graph.
    
    Args:
        model: Model to optimize
        sample_input: Sample input for tracing
    
    Returns:
        nn.Module: Optimized model
    """
    # Trace model
    traced_model = torch.jit.trace(model, sample_input)
    
    # Optimize
    optimized_model = torch.jit.optimize_for_inference(traced_model)
    
    return optimized_model

def benchmark_speed(model, data, n_iterations=100):
    """
    Benchmark inference speed.
    
    Args:
        model: Model to benchmark
        data: Input data
        n_iterations: Number of iterations
    
    Returns:
        dict: Benchmark results
    """
    import time
    
    # Warm up
    for _ in range(10):
        model(data)
    
    # Benchmark
    start_time = time.time()
    for _ in range(n_iterations):
        model(data)
    elapsed = time.time() - start_time
    
    avg_time = elapsed / n_iterations
    
    return {
        'total_time': elapsed,
        'avg_time_ms': avg_time * 1000,
        'iterations_per_second': n_iterations / elapsed
    }
```

---

## 6. Hardware Acceleration

### GPU Acceleration

```python
def setup_gpu():
    """
    Setup GPU for acceleration.
    
    Returns:
        torch.device: Device to use
    """
    if torch.cuda.is_available():
        device = torch.device('cuda')
        print(f"Using GPU: {torch.cuda.get_device_name(0)}")
        print(f"Memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f} GB")
    else:
        device = torch.device('cpu')
        print("Using CPU")
    
    return device

def profile_gpu_usage():
    """
    Profile GPU memory usage.
    
    Returns:
        dict: GPU memory statistics
    """
    import torch
    
    if torch.cuda.is_available():
        return {
            'allocated': torch.cuda.memory_allocated() / 1024**3,
            'reserved': torch.cuda.memory_reserved() / 1024**3,
            'max_allocated': torch.cuda.max_memory_allocated() / 1024**3
        }
    return {}
```

### ONNX Export

```python
def export_to_onnx(model, sample_input, output_path='model.onnx'):
    """
    Export model to ONNX format.
    
    Args:
        model: Model to export
        sample_input: Sample input
        output_path: Output file path
    """
    model.eval()
    
    torch.onnx.export(
        model,
        sample_input,
        output_path,
        export_params=True,
        opset_version=11,
        do_constant_folding=True,
        input_names=['input'],
        output_names=['output'],
        dynamic_axes={
            'input': {0: 'batch_size'},
            'output': {0: 'batch_size'}
        }
    )
    
    print(f"Model exported to: {output_path}")

def load_onnx_model(model_path='model.onnx'):
    """
    Load ONNX model.
    
    Args:
        model_path: Path to ONNX model
    
    Returns:
        onnxruntime.InferenceSession: Inference session
    """
    import onnxruntime as ort
    
    # Create inference session
    session = ort.InferenceSession(model_path)
    
    return session

def run_onnx_inference(session, input_data):
    """
    Run inference with ONNX model.
    
    Args:
        session: ONNX inference session
        input_data: Input data
    
    Returns:
        np.ndarray: Predictions
    """
    input_name = session.get_inputs()[0].name
    output_name = session.get_outputs()[0].name
    
    result = session.run([output_name], {input_name: input_data.numpy()})
    
    return result[0]
```

---

## Quick Reference: Model Optimization

### Optimization Techniques Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│  TECHNIQUE     │ SPEED ↑ │ SIZE ↓ │ ACCURACY │ COMPLEXITY    │
├────────────────┼─────────┼────────┼──────────┼───────────────┤
│  Pruning       │ Medium  │ High   │ Medium   │ Medium        │
│  Quantization  │ High    │ Very   │ Medium   │ Medium        │
│  Distillation  │ High    │ Very   │ High     │ High          │
│  Architecture  │ Very    │ Very   │ High     │ Very High     │
│  Batch         │ Very    │ Low    │ None     │ Low           │
│  Graph Opt     │ High    │ Low    │ None     │ Low           │
└─────────────────────────────────────────────────────────────────┘
```

### Speed-Size-Accuracy Tradeoffs

```
┌─────────────────────────────────────────────────────────────────┐
│  SCENARIO      │ PRIORITY      │ RECOMMENDED TECHNIQUES       │
├────────────────┼───────────────┼──────────────────────────────┤
│  Cloud API     │ Accuracy      │ None (full model)            │
│  Web App       │ Speed         │ Quantization, Graph Opt      │
│  Mobile App    │ Size + Speed  │ Pruning + Quantization       │
│  Edge Device   │ Size          │ Distillation + Quantization  │
│  IoT Device    │ Ultra-small   │ Architecture Search          │
│  Real-time     │ Speed         │ Batch + Graph Opt            │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers the essential concepts of model optimization and acceleration. You now understand:

1. **Why optimization matters**: Deployment constraints, business impact
2. **Model pruning**: Magnitude, structured, iterative
3. **Quantization**: Post-training, quantization-aware, dynamic
4. **Knowledge distillation**: Teacher-student, self-distillation
5. **Inference optimization**: Batch processing, graph optimization
6. **Hardware acceleration**: GPU, ONNX, TensorRT

**Next Steps:**
1. Try pruning your models
2. Experiment with quantization
3. Implement knowledge distillation
4. Optimize inference speed
5. Proceed to Part 1 of the series

---

*End of Primer 18*

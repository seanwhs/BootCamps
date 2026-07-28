# Primer 29: Knowledge Distillation and Model Compression

## Overview

This primer provides an in-depth exploration of knowledge distillation and model compression techniques—methods for creating smaller, faster, and more efficient models while preserving performance. Understanding these techniques is essential for deploying models in resource-constrained environments.

---

## 1. Introduction to Knowledge Distillation

### What is Knowledge Distillation?

```
┌─────────────────────────────────────────────────────────────────┐
│              WHAT IS KNOWLEDGE DISTILLATION?                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Knowledge Distillation transfers knowledge from a large,      │
│  complex model (teacher) to a smaller, simpler model (student).│
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    TRAINING PROCESS                     │  │
│  │                                                         │  │
│  │  Teacher Model (Large) ──▶ Soft Predictions ─┐         │  │
│  │                         │                     │         │  │
│  │  Student Model (Small) ──▶ Hard Predictions ─┤         │  │
│  │                         │                     │         │  │
│  │                         └───▶ Distillation Loss ─┘       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  The student learns from:                                      │
│  1. Ground truth labels (hard targets)                         │
│  2. Teacher's soft predictions (soft targets)                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Why Knowledge Distillation?

```
┌─────────────────────────────────────────────────────────────────┐
│              WHY KNOWLEDGE DISTILLATION?                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Model Size Reduction                                        │
│     └── Large models (GPT-3: 175B params) → Small models       │
│     └── DistilBERT: 40% smaller, 97% performance               │
│                                                                 │
│  2. Inference Speed                                             │
│     └── Smaller models are faster to run                       │
│     └── Suitable for real-time applications                    │
│                                                                 │
│  3. Edge Deployment                                             │
│     └── Run on mobile phones, IoT devices                      │
│     └── Lower power consumption                                │
│                                                                 │
│  4. Ensemble Compression                                        │
│     └── Compress ensemble of models into one                   │
│     └── Distill multiple teachers                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Distillation Types

```
┌─────────────────────────────────────────────────────────────────┐
│              DISTILLATION TYPES                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Offline Distillation                                           │
│  └── Teacher is pre-trained, frozen                            │
│  └── Standard approach                                         │
│  └── Example: DistilBERT                                        │
│                                                                 │
│  Online Distillation                                            │
│  └── Teacher and student trained together                      │
│  └── Teacher can learn from student too                        │
│  └── Example: Deep Mutual Learning                             │
│                                                                 │
│  Self-Distillation                                              │
│  └── Same model serves as teacher and student                  │
│  └── Model learns from its own predictions                     │
│  └── Example: Born-again networks                              │
│                                                                 │
│  Multi-Teacher Distillation                                     │
│  └── Multiple teachers contribute knowledge                    │
│  └── Ensemble knowledge transfer                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Knowledge Distillation Implementation

### Basic Distillation

```python
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import DataLoader

class DistillationLoss(nn.Module):
    """
    Knowledge distillation loss.
    
    Combines hard loss (cross-entropy) and soft loss (KL divergence).
    """
    
    def __init__(self, temperature=4.0, alpha=0.5):
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
        # Hard loss (ground truth)
        hard_loss = self.ce_loss(student_logits, targets)
        
        # Soft loss (distillation)
        soft_teacher = F.softmax(teacher_logits / self.temperature, dim=1)
        soft_student = F.log_softmax(student_logits / self.temperature, dim=1)
        distill_loss = self.kl_loss(soft_student, soft_teacher) * (self.temperature ** 2)
        
        # Combine
        return self.alpha * hard_loss + (1 - self.alpha) * distill_loss

class DistillationTrainer:
    """
    Knowledge distillation trainer.
    """
    
    def __init__(
        self,
        teacher_model,
        student_model,
        train_loader,
        val_loader,
        device='cpu',
        temperature=4.0,
        alpha=0.5,
        lr=0.001,
        epochs=100
    ):
        self.teacher = teacher_model.to(device)
        self.student = student_model.to(device)
        self.train_loader = train_loader
        self.val_loader = val_loader
        self.device = device
        self.temperature = temperature
        self.alpha = alpha
        self.lr = lr
        self.epochs = epochs
        
        # Freeze teacher
        for param in self.teacher.parameters():
            param.requires_grad = False
        
        self.teacher.eval()
        
        # Optimizer for student
        self.optimizer = torch.optim.Adam(student_model.parameters(), lr=lr)
        self.criterion = DistillationLoss(temperature, alpha)
    
    def train_epoch(self):
        """Train for one epoch."""
        self.student.train()
        total_loss = 0
        
        for batch_idx, (data, target) in enumerate(self.train_loader):
            data, target = data.to(self.device), target.to(self.device)
            
            self.optimizer.zero_grad()
            
            # Teacher predictions
            with torch.no_grad():
                teacher_output = self.teacher(data)
            
            # Student predictions
            student_output = self.student(data)
            
            # Loss
            loss = self.criterion(student_output, teacher_output, target)
            
            loss.backward()
            self.optimizer.step()
            
            total_loss += loss.item()
        
        return total_loss / len(self.train_loader)
    
    def validate(self):
        """Validate the student model."""
        self.student.eval()
        correct = 0
        total = 0
        
        with torch.no_grad():
            for data, target in self.val_loader:
                data, target = data.to(self.device), target.to(self.device)
                output = self.student(data)
                pred = output.argmax(dim=1)
                correct += (pred == target).sum().item()
                total += target.size(0)
        
        return correct / total
    
    def train(self):
        """Full training loop."""
        print("Starting knowledge distillation...")
        
        for epoch in range(self.epochs):
            train_loss = self.train_epoch()
            val_acc = self.validate()
            
            if (epoch + 1) % 10 == 0:
                print(f"Epoch {epoch+1}/{self.epochs}, "
                      f"Train Loss: {train_loss:.4f}, "
                      f"Val Acc: {val_acc:.4f}")
        
        print("Distillation complete!")
        return self.student
```

### Advanced Distillation with Temperature Annealing

```python
class AdaptiveDistillationLoss(nn.Module):
    """
    Adaptive distillation loss with temperature annealing.
    """
    
    def __init__(self, initial_temp=10.0, final_temp=2.0, total_epochs=100):
        super().__init__()
        self.initial_temp = initial_temp
        self.final_temp = final_temp
        self.total_epochs = total_epochs
        self.current_epoch = 0
        self.ce_loss = nn.CrossEntropyLoss()
        self.kl_loss = nn.KLDivLoss(reduction='batchmean')
    
    def update_temperature(self, epoch):
        """Annealing schedule for temperature."""
        self.current_epoch = epoch
        progress = epoch / self.total_epochs
        self.temperature = self.initial_temp - progress * (self.initial_temp - self.final_temp)
        self.alpha = 0.9 - progress * 0.4  # Reduce distillation weight over time
    
    def forward(self, student_logits, teacher_logits, targets):
        temperature = self.temperature
        
        # Hard loss
        hard_loss = self.ce_loss(student_logits, targets)
        
        # Soft loss
        soft_teacher = F.softmax(teacher_logits / temperature, dim=1)
        soft_student = F.log_softmax(student_logits / temperature, dim=1)
        distill_loss = self.kl_loss(soft_student, soft_teacher) * (temperature ** 2)
        
        return self.alpha * hard_loss + (1 - self.alpha) * distill_loss
```

### Multi-Teacher Distillation

```python
class MultiTeacherDistillation(nn.Module):
    """
    Distillation from multiple teachers.
    """
    
    def __init__(self, temperatures=None, alphas=None):
        super().__init__()
        self.temperatures = temperatures or [4.0, 4.0, 4.0]
        self.alphas = alphas or [0.3, 0.3, 0.3]
        self.ce_loss = nn.CrossEntropyLoss()
        self.kl_loss = nn.KLDivLoss(reduction='batchmean')
    
    def forward(self, student_logits, teacher_logits_list, targets):
        """
        Compute multi-teacher distillation loss.
        
        Args:
            student_logits: Student outputs
            teacher_logits_list: List of teacher outputs
            targets: Ground truth labels
        """
        # Hard loss
        hard_loss = self.ce_loss(student_logits, targets)
        
        # Soft loss from each teacher
        distill_loss = 0
        for i, (teacher_logits, temp) in enumerate(zip(teacher_logits_list, self.temperatures)):
            soft_teacher = F.softmax(teacher_logits / temp, dim=1)
            soft_student = F.log_softmax(student_logits / temp, dim=1)
            distill_loss += self.alphas[i] * self.kl_loss(soft_student, soft_teacher) * (temp ** 2)
        
        # Average distillation loss
        distill_loss = distill_loss / sum(self.alphas)
        
        return hard_loss + distill_loss
```

---

## 3. Model Compression Techniques

### Pruning

```python
class ModelPruner:
    """
    Model pruning utilities.
    """
    
    @staticmethod
    def magnitude_prune(model, pruning_ratio=0.3):
        """
        Prune weights by magnitude.
        
        Args:
            model: PyTorch model
            pruning_ratio: Fraction of weights to prune
        
        Returns:
            nn.Module: Pruned model
        """
        # Get all weights
        all_weights = []
        for name, param in model.named_parameters():
            if 'weight' in name and param.requires_grad:
                all_weights.append(param.view(-1))
        
        if not all_weights:
            return model
        
        all_weights = torch.cat(all_weights)
        threshold = torch.quantile(torch.abs(all_weights), pruning_ratio)
        
        # Apply mask
        for name, param in model.named_parameters():
            if 'weight' in name and param.requires_grad:
                mask = torch.abs(param) > threshold
                param.data *= mask.float()
        
        return model
    
    @staticmethod
    def structured_prune(model, pruning_ratio=0.3, layer_type=nn.Linear):
        """
        Prune entire neurons/channels.
        
        Args:
            model: PyTorch model
            pruning_ratio: Fraction to prune
            layer_type: Type of layer to prune
        
        Returns:
            nn.Module: Pruned model
        """
        for name, module in model.named_modules():
            if isinstance(module, layer_type):
                # Compute L1 norm per neuron
                weights = module.weight.data
                l1_norms = torch.sum(torch.abs(weights), dim=1)
                threshold = torch.quantile(l1_norms, pruning_ratio)
                
                # Keep neurons with high L1 norm
                keep_indices = l1_norms > threshold
                module.weight.data = weights[keep_indices]
                
                if module.bias is not None:
                    module.bias.data = module.bias.data[keep_indices]
        
        return model
    
    @staticmethod
    def iterative_prune(model, train_loader, val_loader, pruning_ratio=0.1, iterations=5):
        """
        Iteratively prune and fine-tune.
        
        Args:
            model: PyTorch model
            train_loader: Training data
            val_loader: Validation data
            pruning_ratio: Prune ratio per iteration
            iterations: Number of iterations
        
        Returns:
            nn.Module: Pruned model
        """
        for i in range(iterations):
            # Prune
            ModelPruner.magnitude_prune(model, pruning_ratio)
            
            # Fine-tune
            ModelPruner._fine_tune(model, train_loader, val_loader, epochs=5)
            
            print(f"Iteration {i+1}: Pruned {pruning_ratio*100:.1f}%")
        
        return model
    
    @staticmethod
    def _fine_tune(model, train_loader, val_loader, epochs=5):
        """Helper: fine-tune after pruning."""
        optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
        criterion = nn.CrossEntropyLoss()
        
        model.train()
        for epoch in range(epochs):
            for data, target in train_loader:
                optimizer.zero_grad()
                output = model(data)
                loss = criterion(output, target)
                loss.backward()
                optimizer.step()
```

### Quantization

```python
class Quantizer:
    """
    Model quantization utilities.
    """
    
    @staticmethod
    def post_training_quantization(model, calibration_loader):
        """
        Apply post-training quantization.
        
        Args:
            model: PyTorch model
            calibration_loader: Data for calibration
        
        Returns:
            nn.Module: Quantized model
        """
        model.eval()
        
        # Prepare for quantization
        model.qconfig = torch.quantization.get_default_qconfig('fbgemm')
        
        # Fuse layers if possible
        # This depends on model architecture
        # Example: torch.quantization.fuse_modules(model, [['conv1', 'bn1', 'relu1']])
        
        # Prepare and calibrate
        model_prepared = torch.quantization.prepare(model)
        
        # Calibrate
        with torch.no_grad():
            for batch in calibration_loader:
                model_prepared(batch)
        
        # Convert
        model_quantized = torch.quantization.convert(model_prepared)
        
        return model_quantized
    
    @staticmethod
    def quantization_aware_training(model, train_loader, epochs=5):
        """
        Quantization-aware training.
        
        Args:
            model: PyTorch model
            train_loader: Training data
            epochs: Number of epochs
        
        Returns:
            nn.Module: Quantized model
        """
        # Prepare for QAT
        model.qconfig = torch.quantization.get_default_qat_qconfig('fbgemm')
        model_prepared = torch.quantization.prepare_qat(model)
        
        # Training
        optimizer = torch.optim.Adam(model_prepared.parameters(), lr=0.001)
        criterion = nn.CrossEntropyLoss()
        
        model_prepared.train()
        for epoch in range(epochs):
            for data, target in train_loader:
                optimizer.zero_grad()
                output = model_prepared(data)
                loss = criterion(output, target)
                loss.backward()
                optimizer.step()
        
        # Convert
        model_quantized = torch.quantization.convert(model_prepared)
        
        return model_quantized
    
    @staticmethod
    def dynamic_quantization(model):
        """
        Dynamic quantization (weights only).
        
        Args:
            model: PyTorch model
        
        Returns:
            nn.Module: Quantized model
        """
        return torch.quantization.quantize_dynamic(
            model,
            {nn.Linear, nn.LSTM, nn.GRU},
            dtype=torch.qint8
        )
```

### Model Size Analysis

```python
class ModelAnalyzer:
    """
    Model analysis utilities.
    """
    
    @staticmethod
    def get_model_size(model):
        """
        Get model size in MB.
        
        Args:
            model: PyTorch model
        
        Returns:
            float: Size in MB
        """
        import io
        buffer = io.BytesIO()
        torch.save(model.state_dict(), buffer)
        size_bytes = buffer.getbuffer().nbytes
        return size_bytes / (1024 * 1024)
    
    @staticmethod
    def count_parameters(model):
        """
        Count trainable parameters.
        
        Args:
            model: PyTorch model
        
        Returns:
            int: Number of parameters
        """
        return sum(p.numel() for p in model.parameters() if p.requires_grad)
    
    @staticmethod
    def get_flops(model, input_size):
        """
        Estimate FLOPs.
        
        Args:
            model: PyTorch model
            input_size: Input shape
        
        Returns:
            int: Estimated FLOPs
        """
        # Simplified FLOPs estimation
        # In practice, use torchprofile or fvcore
        return 0
    
    @staticmethod
    def model_summary(model, input_size):
        """
        Generate model summary.
        
        Args:
            model: PyTorch model
            input_size: Input shape
        
        Returns:
            dict: Model summary
        """
        summary = {
            'parameters': ModelAnalyzer.count_parameters(model),
            'size_mb': ModelAnalyzer.get_model_size(model),
            'layers': len(list(model.modules())),
        }
        
        return summary
```

---

## 4. Distillation for Specific Architectures

### BERT Distillation (Simplified)

```python
class DistilBERT:
    """
    Distillation for BERT models.
    """
    
    def __init__(self, teacher_model, student_model, tokenizer):
        self.teacher = teacher_model
        self.student = student_model
        self.tokenizer = tokenizer
    
    def distill(
        self,
        text_data,
        labels=None,
        temperature=4.0,
        alpha=0.5,
        epochs=3,
        batch_size=16
    ):
        """
        Distill BERT knowledge.
        
        Args:
            text_data: Training texts
            labels: Optional labels
            temperature: Distillation temperature
            alpha: Distillation weight
            epochs: Number of epochs
            batch_size: Batch size
        """
        # Create dataloader
        from torch.utils.data import DataLoader, Dataset
        
        class TextDataset(Dataset):
            def __init__(self, texts, labels):
                self.texts = texts
                self.labels = labels
            
            def __len__(self):
                return len(self.texts)
            
            def __getitem__(self, idx):
                return self.texts[idx], self.labels[idx] if self.labels else None
        
        dataset = TextDataset(text_data, labels)
        dataloader = DataLoader(dataset, batch_size=batch_size, shuffle=True)
        
        # Distillation
        optimizer = torch.optim.Adam(self.student.parameters(), lr=2e-5)
        criterion = DistillationLoss(temperature, alpha)
        
        self.teacher.eval()
        self.student.train()
        
        for epoch in range(epochs):
            total_loss = 0
            
            for batch in dataloader:
                if labels is not None:
                    texts, targets = batch
                else:
                    texts = batch[0]
                    targets = None
                
                # Tokenize
                inputs = self.tokenizer(
                    texts,
                    padding=True,
                    truncation=True,
                    max_length=512,
                    return_tensors='pt'
                )
                
                # Teacher predictions
                with torch.no_grad():
                    teacher_outputs = self.teacher(**inputs)
                    teacher_logits = teacher_outputs.logits
                
                # Student predictions
                student_outputs = self.student(**inputs)
                student_logits = student_outputs.logits
                
                # Compute loss
                if targets is not None:
                    loss = criterion(student_logits, teacher_logits, targets)
                else:
                    # Unsupervised: only distillation
                    soft_teacher = F.softmax(teacher_logits / temperature, dim=1)
                    soft_student = F.log_softmax(student_logits / temperature, dim=1)
                    loss = F.kl_div(soft_student, soft_teacher) * (temperature ** 2)
                
                loss.backward()
                optimizer.step()
                optimizer.zero_grad()
                
                total_loss += loss.item()
            
            print(f"Epoch {epoch+1}, Loss: {total_loss/len(dataloader):.4f}")
```

---

## Quick Reference: Distillation and Compression

### Techniques Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│  TECHNIQUE      │ SIZE ↓ │ SPEED ↑ │ ACCURACY │ COMPLEXITY   │
├─────────────────┼────────┼─────────┼──────────┼──────────────┤
│  Distillation   │ High   │ High    │ High     │ High         │
│  Pruning        │ High   │ Medium  │ Medium   │ Medium       │
│  Quantization   │ Very   │ Very    │ Medium   │ Medium       │
│  All Together   │ Very   │ Very    │ Medium   │ Very High    │
└─────────────────────────────────────────────────────────────────┘
```

### Distillation Parameters

```
┌─────────────────────────────────────────────────────────────────┐
│  PARAMETER      │ EFFECT                │ RECOMMENDED VALUE  │
├─────────────────┼───────────────────────┼────────────────────┤
│  Temperature    │ Softness of targets   │ 2-10               │
│  Alpha          │ Distillation weight   │ 0.3-0.7            │
│  Student Size   │ Size vs performance   │ 10-50% of teacher │
│  Training Epochs│ More epochs = better  │ 2x teacher epochs │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers advanced knowledge distillation and model compression techniques. You now understand:

1. **Knowledge distillation**: Teacher-student learning
2. **Distillation types**: Offline, online, self, multi-teacher
3. **Pruning**: Magnitude, structured, iterative
4. **Quantization**: PTQ, QAT, dynamic
5. **Model analysis**: Size, parameters, FLOPs
6. **Architecture-specific**: BERT distillation

**Next Steps:**
1. Implement basic knowledge distillation
2. Try pruning your models
3. Experiment with quantization
4. Distill a BERT model
5. Proceed to Part 1 of the series

---

*End of Primer 29*

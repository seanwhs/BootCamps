# Primer 28: Model Interpretability and Explainable AI (XAI) – Advanced Techniques

## Overview

This primer provides an advanced exploration of model interpretability and Explainable AI (XAI). Building on the foundations in Primer 6, this primer covers state-of-the-art techniques for understanding complex models, including deep learning interpretability, counterfactual explanations, concept-based explanations, and feature visualization.

---

## 1. Advanced Interpretability Concepts

### The XAI Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                    XAI HIERARCHY                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Level 3: Causal Explanations                                  │
│  └── Why did this happen? Why not something else?             │
│      • Counterfactuals                                         │
│      • Causal inference                                        │
│      • What-if analysis                                       │
│                                                                 │
│  Level 2: Concept-Level Explanations                           │
│  └── What concepts is the model using?                        │
│      • Concept attribution                                     │
│      • Feature visualization                                   │
│      • Prototype explanations                                  │
│                                                                 │
│  Level 1: Instance-Level Explanations                          │
│  └── Why did the model make this prediction?                  │
│      • SHAP/LIME                                              │
│      • Integrated Gradients                                    │
│      • Grad-CAM                                               │
│                                                                 │
│  Level 0: Model-Level Explanations                             │
│  └── How does the model work overall?                         │
│      • Feature importance                                      │
│      • Surrogate models                                       │
│      • Model distillation                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### XAI Requirements

```
┌─────────────────────────────────────────────────────────────────┐
│                    XAI REQUIREMENTS                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Fidelity                                                       │
│  └── Explanation must accurately reflect model behavior       │
│                                                                 │
│  Interpretability                                               │
│  └── Explanation must be understandable to humans             │
│                                                                 │
│  Completeness                                                   │
│  └── Explanation must cover important factors                 │
│                                                                 │
│  Contrastiveness                                                │
│  └── Explanation should explain why not another outcome       │
│                                                                 │
│  Selectivity                                                    │
│  └── Explanation should be concise and focused                │
│                                                                 │
│  Consistency                                                    │
│  └── Similar inputs should have similar explanations          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Integrated Gradients

### Integrated Gradients Implementation

```python
import torch
import torch.nn as nn
import numpy as np
import matplotlib.pyplot as plt

class IntegratedGradients:
    """
    Integrated Gradients for feature attribution in neural networks.
    
    Implements: https://arxiv.org/abs/1703.01365
    """
    
    def __init__(self, model, device='cpu'):
        self.model = model
        self.device = device
        self.model.to(device)
    
    def generate(
        self,
        input_tensor,
        target_class=None,
        steps=50,
        baseline=None
    ):
        """
        Generate integrated gradients.
        
        Args:
            input_tensor: Input tensor
            target_class: Target class (None for max class)
            steps: Number of steps for integration
            baseline: Baseline (default: zeros)
        
        Returns:
            np.ndarray: Attributions
        """
        self.model.eval()
        
        # Set baseline
        if baseline is None:
            baseline = torch.zeros_like(input_tensor)
        
        # Get target class
        with torch.no_grad():
            output = self.model(input_tensor)
            if target_class is None:
                target_class = output.argmax().item()
        
        # Compute gradients at each step
        gradients = []
        for alpha in np.linspace(0, 1, steps):
            # Interpolate
            interpolated = baseline + alpha * (input_tensor - baseline)
            interpolated = interpolated.to(self.device)
            
            # Compute gradient
            interpolated.requires_grad = True
            output = self.model(interpolated)
            loss = output[0, target_class]
            self.model.zero_grad()
            loss.backward()
            grad = interpolated.grad.data.cpu().numpy()
            gradients.append(grad)
        
        # Average gradients
        avg_gradients = np.mean(gradients, axis=0)
        
        # Compute integrated gradients
        attributions = (input_tensor.cpu().numpy() - baseline.cpu().numpy()) * avg_gradients
        
        return attributions
    
    def visualize_attributions(self, input_tensor, attributions, title="Attributions"):
        """Visualize attributions as heatmap."""
        fig, axes = plt.subplots(1, 3, figsize=(15, 5))
        
        # Original image
        axes[0].imshow(input_tensor.squeeze().cpu().numpy())
        axes[0].set_title("Original")
        axes[0].axis('off')
        
        # Attributions
        axes[1].imshow(np.abs(attributions.squeeze()))
        axes[1].set_title("Attributions (abs)")
        axes[1].axis('off')
        
        # Overlay
        overlay = input_tensor.squeeze().cpu().numpy() * np.abs(attributions.squeeze())
        axes[2].imshow(overlay)
        axes[2].set_title("Overlay")
        axes[2].axis('off')
        
        plt.suptitle(title)
        plt.tight_layout()
        return fig
```

### SmoothGrad

```python
class SmoothGrad:
    """
    SmoothGrad for reducing noise in gradient-based explanations.
    
    Implements: https://arxiv.org/abs/1706.03825
    """
    
    def __init__(self, model, device='cpu'):
        self.model = model
        self.device = device
    
    def generate(
        self,
        input_tensor,
        target_class=None,
        n_samples=50,
        noise_level=0.1
    ):
        """
        Generate SmoothGrad attributions.
        
        Args:
            input_tensor: Input tensor
            target_class: Target class
            n_samples: Number of noise samples
            noise_level: Standard deviation of noise
        
        Returns:
            np.ndarray: Attributions
        """
        self.model.eval()
        
        # Get target class
        with torch.no_grad():
            output = self.model(input_tensor)
            if target_class is None:
                target_class = output.argmax().item()
        
        # Generate noisy samples and compute gradients
        gradients = []
        for _ in range(n_samples):
            # Add noise
            noise = torch.randn_like(input_tensor) * noise_level
            noisy_input = input_tensor + noise
            noisy_input = noisy_input.to(self.device)
            
            # Compute gradient
            noisy_input.requires_grad = True
            output = self.model(noisy_input)
            loss = output[0, target_class]
            self.model.zero_grad()
            loss.backward()
            grad = noisy_input.grad.data.cpu().numpy()
            gradients.append(grad)
        
        # Average gradients
        smooth_grad = np.mean(gradients, axis=0)
        
        return smooth_grad
```

---

## 3. Grad-CAM and Variants

### Grad-CAM for CNNs

```python
class GradCAM:
    """
    Grad-CAM for CNN visualization.
    
    Implements: https://arxiv.org/abs/1610.02391
    """
    
    def __init__(self, model, target_layer):
        """
        Initialize Grad-CAM.
        
        Args:
            model: PyTorch model
            target_layer: Layer to extract features from
        """
        self.model = model
        self.target_layer = target_layer
        self.gradients = None
        self.activations = None
        
        # Register hooks
        self._register_hooks()
    
    def _register_hooks(self):
        """Register forward and backward hooks."""
        def forward_hook(module, input, output):
            self.activations = output
        
        def backward_hook(module, grad_input, grad_output):
            self.gradients = grad_output[0]
        
        # Find target layer
        target_layer = self._find_layer(self.model, self.target_layer)
        target_layer.register_forward_hook(forward_hook)
        target_layer.register_backward_hook(backward_hook)
    
    def _find_layer(self, model, layer_name):
        """Find layer by name."""
        for name, module in model.named_modules():
            if name == layer_name:
                return module
        raise ValueError(f"Layer {layer_name} not found")
    
    def generate(self, input_tensor, target_class=None):
        """
        Generate Grad-CAM heatmap.
        
        Args:
            input_tensor: Input tensor
            target_class: Target class
        
        Returns:
            np.ndarray: Heatmap
        """
        self.model.eval()
        
        # Forward pass
        output = self.model(input_tensor)
        
        # Get target class
        if target_class is None:
            target_class = output.argmax().item()
        
        # Zero gradients
        self.model.zero_grad()
        
        # Backward pass
        loss = output[0, target_class]
        loss.backward(retain_graph=True)
        
        # Get gradients and activations
        gradients = self.gradients.cpu().data.numpy()
        activations = self.activations.cpu().data.numpy()
        
        # Global average pooling of gradients
        weights = np.mean(gradients[0], axis=(1, 2))
        
        # Weighted combination of activations
        cam = np.zeros(activations.shape[2:], dtype=np.float32)
        for i, w in enumerate(weights):
            cam += w * activations[0, i, :, :]
        
        # ReLU
        cam = np.maximum(cam, 0)
        
        # Normalize
        cam = cam - cam.min()
        cam = cam / (cam.max() + 1e-8)
        
        return cam
    
    def overlay_heatmap(self, image, heatmap, alpha=0.5):
        """
        Overlay heatmap on image.
        
        Args:
            image: Original image
            heatmap: Heatmap from generate()
            alpha: Transparency
        
        Returns:
            np.ndarray: Overlayed image
        """
        import cv2
        
        # Resize heatmap to image size
        heatmap = cv2.resize(heatmap, (image.shape[1], image.shape[0]))
        
        # Convert to colormap
        heatmap = np.uint8(255 * heatmap)
        heatmap = cv2.applyColorMap(heatmap, cv2.COLORMAP_JET)
        
        # Overlay
        overlayed = cv2.addWeighted(image, 1 - alpha, heatmap, alpha, 0)
        
        return overlayed
```

### Score-CAM

```python
class ScoreCAM:
    """
    Score-CAM for improved CAM explanations.
    
    Implements: https://arxiv.org/abs/1910.01279
    """
    
    def __init__(self, model, target_layer):
        self.model = model
        self.target_layer = target_layer
        self.activations = None
        self._register_hooks()
    
    def _register_hooks(self):
        """Register forward hook."""
        def forward_hook(module, input, output):
            self.activations = output
        
        target_layer = self._find_layer(self.model, self.target_layer)
        target_layer.register_forward_hook(forward_hook)
    
    def _find_layer(self, model, layer_name):
        for name, module in model.named_modules():
            if name == layer_name:
                return module
        raise ValueError(f"Layer {layer_name} not found")
    
    def generate(self, input_tensor, target_class=None):
        """
        Generate Score-CAM heatmap.
        
        Args:
            input_tensor: Input tensor
            target_class: Target class
        
        Returns:
            np.ndarray: Heatmap
        """
        self.model.eval()
        
        # Get target class
        with torch.no_grad():
            output = self.model(input_tensor)
            if target_class is None:
                target_class = output.argmax().item()
        
        # Get activations
        _ = self.model(input_tensor)
        activations = self.activations.cpu().data.numpy()[0]
        
        # Create masks for each channel
        masks = []
        for i in range(activations.shape[0]):
            mask = activations[i:i+1]
            mask = np.repeat(mask, input_tensor.shape[1], axis=0)
            mask = np.expand_dims(mask, axis=0)
            masks.append(mask)
        
        # Compute scores
        scores = []
        for mask in masks:
            masked_input = input_tensor * torch.FloatTensor(mask).to(input_tensor.device)
            with torch.no_grad():
                output = self.model(masked_input)
                score = output[0, target_class].item()
            scores.append(score)
        
        # Weighted combination
        weights = np.array(scores)
        weights = np.maximum(weights, 0)
        
        cam = np.zeros(activations.shape[1:], dtype=np.float32)
        for i, w in enumerate(weights):
            cam += w * activations[i]
        
        # Normalize
        cam = cam - cam.min()
        cam = cam / (cam.max() + 1e-8)
        
        return cam
```

---

## 4. Layer-wise Relevance Propagation (LRP)

### LRP Implementation

```python
class LRP:
    """
    Layer-wise Relevance Propagation for neural network explanations.
    
    Implements: https://doi.org/10.1371/journal.pone.0130140
    """
    
    def __init__(self, model, eps=1e-9):
        self.model = model
        self.eps = eps
        self.relevances = None
    
    def explain(self, input_tensor, target_class=None):
        """
        Generate LRP explanations.
        
        Args:
            input_tensor: Input tensor
            target_class: Target class
        
        Returns:
            np.ndarray: Relevance scores
        """
        self.model.eval()
        
        # Forward pass
        with torch.no_grad():
            output = self.model(input_tensor)
            if target_class is None:
                target_class = output.argmax().item()
        
        # Initialize relevance at output
        relevance = torch.zeros_like(output)
        relevance[0, target_class] = 1.0
        
        # Backward pass with LRP rules
        # This is a simplified version
        # In practice, you'd implement LRP for each layer type
        
        # Get layers in reverse order
        layers = list(self.model.children())
        modules = list(self.model.named_modules())
        modules = modules[1:]  # Skip the model itself
        
        # Process layers in reverse
        for name, module in reversed(modules):
            if isinstance(module, nn.Linear):
                relevance = self._lrp_linear(module, relevance)
            elif isinstance(module, nn.Conv2d):
                relevance = self._lrp_conv2d(module, relevance)
            elif isinstance(module, nn.ReLU):
                relevance = self._lrp_relu(relevance)
        
        self.relevances = relevance
        
        return relevance.cpu().numpy()
    
    def _lrp_linear(self, layer, relevance):
        """LRP for linear layer."""
        # Simplified: propagate relevance using weights
        weight = layer.weight.data
        # In practice, you'd need input activations
        return relevance
    
    def _lrp_conv2d(self, layer, relevance):
        """LRP for convolution layer."""
        # Simplified
        return relevance
    
    def _lrp_relu(self, relevance):
        """LRP for ReLU."""
        # ReLU doesn't change relevance
        return relevance
```

---

## 5. Counterfactual Explanations

### Counterfactual Generation

```python
import torch
import torch.optim as optim

class CounterfactualExplainer:
    """
    Generate counterfactual explanations.
    
    Finds minimal changes to input that would change the prediction.
    """
    
    def __init__(self, model, device='cpu'):
        self.model = model
        self.device = device
        self.model.to(device)
    
    def explain(
        self,
        input_tensor,
        target_class,
        desired_class,
        max_iterations=1000,
        learning_rate=0.01,
        weight_decay=0.001
    ):
        """
        Generate counterfactual explanation.
        
        Args:
            input_tensor: Input tensor
            target_class: Current predicted class
            desired_class: Desired class
            max_iterations: Maximum iterations
            learning_rate: Learning rate
            weight_decay: Weight decay for regularization
        
        Returns:
            tuple: (counterfactual, changes)
        """
        self.model.eval()
        
        # Clone input and make it trainable
        counterfactual = input_tensor.clone().to(self.device)
        counterfactual.requires_grad = True
        
        # Optimizer
        optimizer = optim.Adam([counterfactual], lr=learning_rate, weight_decay=weight_decay)
        
        for iteration in range(max_iterations):
            optimizer.zero_grad()
            
            # Forward pass
            output = self.model(counterfactual)
            
            # Loss: encourage desired class
            class_loss = -output[0, desired_class]
            
            # Distance loss: stay close to original
            distance_loss = torch.norm(counterfactual - input_tensor, p=2)
            
            # Total loss
            loss = class_loss + 0.1 * distance_loss
            
            loss.backward()
            optimizer.step()
            
            # Check if desired class achieved
            with torch.no_grad():
                pred = output.argmax().item()
                if pred == desired_class:
                    break
        
        # Compute changes
        changes = counterfactual - input_tensor
        
        return counterfactual.detach(), changes.detach()
    
    def explain_with_constraints(
        self,
        input_tensor,
        target_class,
        desired_class,
        constraints=None,
        max_iterations=1000
    ):
        """
        Generate counterfactual with constraints.
        
        Args:
            input_tensor: Input tensor
            target_class: Current class
            desired_class: Desired class
            constraints: Dictionary of feature constraints
            max_iterations: Maximum iterations
        
        Returns:
            tuple: (counterfactual, changes)
        """
        # Similar to explain() but with additional constraints
        # In practice, you'd add constraints to the loss function
        pass
```

---

## 6. Concept-Based Explanations

### Concept Activation Vectors (CAV)

```python
class ConceptActivationVectors:
    """
    Concept Activation Vectors (CAV) for concept-based explanations.
    
    Implements: https://arxiv.org/abs/1711.11279
    """
    
    def __init__(self, model, target_layer):
        self.model = model
        self.target_layer = target_layer
        self.activations = None
        self._register_hooks()
    
    def _register_hooks(self):
        """Register forward hook."""
        def forward_hook(module, input, output):
            self.activations = output
        
        target_layer = self._find_layer(self.model, self.target_layer)
        target_layer.register_forward_hook(forward_hook)
    
    def _find_layer(self, model, layer_name):
        for name, module in model.named_modules():
            if name == layer_name:
                return module
        raise ValueError(f"Layer {layer_name} not found")
    
    def create_cav(self, concept_examples, random_examples, n_samples=100):
        """
        Create Concept Activation Vector.
        
        Args:
            concept_examples: Examples of the concept
            random_examples: Random examples
            n_samples: Number of samples
        
        Returns:
            np.ndarray: CAV vector
        """
        self.model.eval()
        
        # Get activations for concept examples
        concept_activations = []
        for example in concept_examples[:n_samples]:
            _ = self.model(example)
            activations = self.activations.cpu().data.numpy().flatten()
            concept_activations.append(activations)
        
        # Get activations for random examples
        random_activations = []
        for example in random_examples[:n_samples]:
            _ = self.model(example)
            activations = self.activations.cpu().data.numpy().flatten()
            random_activations.append(activations)
        
        # Train linear classifier to distinguish concept
        from sklearn.linear_model import LogisticRegression
        
        X = np.vstack(concept_activations + random_activations)
        y = np.array([1]*len(concept_activations) + [0]*len(random_activations))
        
        classifier = LogisticRegression()
        classifier.fit(X, y)
        
        # CAV is the coefficient vector
        cav = classifier.coef_[0]
        
        return cav
    
    def directional_derivative(self, cav, input_tensor):
        """
        Compute directional derivative for a concept.
        
        Args:
            cav: Concept Activation Vector
            input_tensor: Input tensor
        
        Returns:
            float: Directional derivative
        """
        input_tensor.requires_grad = True
        _ = self.model(input_tensor)
        activations = self.activations.cpu().data.numpy().flatten()
        
        # Compute gradient of activations w.r.t input
        # Simplified: dot product of CAV with activation gradient
        
        return np.dot(cav, activations)
```

---

## Quick Reference: XAI Techniques

### XAI Methods Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│  METHOD             │ SPEED  │ FIDELITY │ INTERPRETABILITY    │
├─────────────────────┼────────┼──────────┼────────────────────┤
│  SHAP               │ Slow   │ High     │ High               │
│  LIME               │ Fast   │ Medium   │ High               │
│  Integrated Grad.   │ Medium │ High     │ Medium             │
│  Grad-CAM           │ Fast   │ Medium   │ High               │
│  LRP                │ Medium │ High     │ Medium             │
│  Counterfactuals    │ Slow   │ High     │ High               │
│  CAV                │ Slow   │ High     │ High               │
└─────────────────────────────────────────────────────────────────┘
```

### XAI Toolkits

```
┌─────────────────────────────────────────────────────────────────┐
│  TOOLKIT            │ BEST FOR               │ SUPPORT         │
├─────────────────────┼────────────────────────┼─────────────────┤
│  Captum             │ PyTorch               │ Active          │
│  InterpretML        │ General               │ Active          │
│  Alibi              │ General               │ Active          │
│  SHAP               │ General               │ Active          │
│  LIME               │ General               │ Active          │
│  TensorFlow Explain │ TensorFlow            │ Active          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers advanced XAI techniques. You now understand:

1. **XAI hierarchy**: From instance to causal explanations
2. **Integrated Gradients**: Gradient-based attribution
3. **Grad-CAM**: CNN visualization
4. **LRP**: Layer-wise relevance propagation
5. **Counterfactuals**: Minimal changes explanations
6. **Concept-based**: CAV for high-level concepts

**Next Steps:**
1. Implement Integrated Gradients
2. Visualize CNNs with Grad-CAM
3. Generate counterfactual explanations
4. Explore concept-based explanations
5. Proceed to Part 1 of the series

---

*End of Primer 28*

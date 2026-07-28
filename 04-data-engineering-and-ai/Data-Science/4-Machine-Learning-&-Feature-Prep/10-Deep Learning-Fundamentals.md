# Module 4.2: Supervised & Unsupervised Learning

## Part 10: Deep Learning Fundamentals

Welcome to the final part of Module 4.2! We've explored traditional machine learning algorithms—tree-based models and clustering. Now we dive into the deep end: neural networks. Deep learning has revolutionized fields from computer vision to natural language processing. We'll build a solid foundation using PyTorch, one of the most popular deep learning frameworks.

### The Target: A Complete Deep Learning System

By the end of this part, you'll have:
1. Understanding of neural network architecture
2. PyTorch tensor operations and autograd
3. Custom neural network layers
4. Training loops with optimization
5. Multiple activation and loss functions
6. GPU training support
7. Model evaluation and visualization
8. Integration with our existing pipeline

### The Concept: Understanding Neural Networks

Think of a neural network like a biological brain, but simplified:

**Neuron**: Like a cell that receives signals, processes them, and passes output to other cells.

**Layer**: A collection of neurons working in parallel.

**Network**: Multiple layers connected together.

**Forward Propagation**: Information flows from input to output, with each neuron transforming the data.

**Backpropagation**: Like learning from mistakes—the network adjusts its connections based on how wrong its predictions were.

#### The Architecture Evolution

```
Perceptron (1958)
    ↓
Multi-Layer Perceptron (MLP)
    ↓
Convolutional Neural Networks (1989)
    ↓
Recurrent Neural Networks (1990s)
    ↓
Transformers (2017)
    ↓
Large Language Models (2018+)
```

#### Why PyTorch?

1. **Dynamic computation graphs**: Build networks on the fly
2. **Pythonic**: Feels like writing Python, not a separate language
3. **GPU support**: Seamless CPU/GPU transition
4. **Community**: Huge ecosystem of tools and pretrained models
5. **Debugging**: Easy to inspect and debug

### The Implementation: Building Our Deep Learning System

#### Step 1: PyTorch Utils and Setup

**File:** `src/models/deep_utils.py`
**Path:** `ml-pipeline-project/src/models/deep_utils.py`

```python
"""
Utility functions for deep learning with PyTorch.
"""

import os
import numpy as np
import pandas as pd
from typing import Dict, List, Optional, Union, Any, Tuple
from loguru import logger
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader, TensorDataset
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

def setup_device(use_gpu: bool = True) -> torch.device:
    """
    Set up the computation device (GPU if available).
    
    Args:
        use_gpu: Whether to use GPU if available
        
    Returns:
        torch.device: Device to use
    """
    if use_gpu and torch.cuda.is_available():
        device = torch.device('cuda')
        logger.info(f"Using GPU: {torch.cuda.get_device_name(0)}")
    elif use_gpu and torch.backends.mps.is_available():
        device = torch.device('mps')
        logger.info("Using Apple MPS (Metal Performance Shaders)")
    else:
        device = torch.device('cpu')
        logger.info("Using CPU")
    
    return device

def set_seed(seed: int = 42):
    """
    Set random seeds for reproducibility.
    
    Args:
        seed: Random seed
    """
    import random
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(seed)
        torch.backends.cudnn.deterministic = True
        torch.backends.cudnn.benchmark = False
    
    logger.debug(f"Seeds set to {seed}")

class TensorDatasetWrapper(Dataset):
    """
    Wrapper for PyTorch Dataset with automatic conversion to tensors.
    """
    
    def __init__(
        self,
        X: Union[np.ndarray, torch.Tensor],
        y: Optional[Union[np.ndarray, torch.Tensor]] = None,
        transform: Optional[Any] = None
    ):
        """
        Initialize the dataset.
        
        Args:
            X: Feature matrix
            y: Target vector (optional)
            transform: Optional transforms
        """
        self.X = torch.tensor(X, dtype=torch.float32) if isinstance(X, np.ndarray) else X
        self.y = torch.tensor(y, dtype=torch.float32) if isinstance(y, np.ndarray) else y
        self.transform = transform
    
    def __len__(self) -> int:
        return len(self.X)
    
    def __getitem__(self, idx: int) -> Union[Tuple[torch.Tensor, torch.Tensor], torch.Tensor]:
        x = self.X[idx]
        if self.transform:
            x = self.transform(x)
        
        if self.y is not None:
            y = self.y[idx]
            return x, y
        
        return x

def create_dataloaders(
    X: Union[np.ndarray, torch.Tensor],
    y: Optional[Union[np.ndarray, torch.Tensor]] = None,
    test_size: float = 0.2,
    batch_size: int = 32,
    random_state: int = 42
) -> Tuple[DataLoader, DataLoader]:
    """
    Create train and test DataLoaders.
    
    Args:
        X: Feature matrix
        y: Target vector
        test_size: Proportion of test data
        batch_size: Batch size
        random_state: Random seed
        
    Returns:
        Tuple: (train_loader, test_loader)
    """
    # Split data
    if y is not None:
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=test_size, random_state=random_state
        )
        train_dataset = TensorDatasetWrapper(X_train, y_train)
        test_dataset = TensorDatasetWrapper(X_test, y_test)
    else:
        X_train, X_test = train_test_split(
            X, test_size=test_size, random_state=random_state
        )
        train_dataset = TensorDatasetWrapper(X_train)
        test_dataset = TensorDatasetWrapper(X_test)
    
    # Create dataloaders
    train_loader = DataLoader(
        train_dataset,
        batch_size=batch_size,
        shuffle=True,
        drop_last=False
    )
    test_loader = DataLoader(
        test_dataset,
        batch_size=batch_size,
        shuffle=False,
        drop_last=False
    )
    
    return train_loader, test_loader

class EarlyStopping:
    """
    Early stopping to prevent overfitting.
    
    Stops training when validation loss doesn't improve.
    
    Example:
        >>> early_stop = EarlyStopping(patience=10)
        >>> for epoch in range(epochs):
        ...     train_loss = train()
        ...     val_loss = evaluate()
        ...     if early_stop(val_loss):
        ...         break
    """
    
    def __init__(
        self,
        patience: int = 10,
        min_delta: float = 1e-4,
        restore_best_weights: bool = True
    ):
        """
        Initialize early stopping.
        
        Args:
            patience: Number of epochs to wait for improvement
            min_delta: Minimum improvement to count
            restore_best_weights: Whether to restore best weights
        """
        self.patience = patience
        self.min_delta = min_delta
        self.restore_best_weights = restore_best_weights
        
        self.counter = 0
        self.best_loss = None
        self.best_weights = None
        self.early_stop = False
    
    def __call__(self, val_loss: float, model: Optional[nn.Module] = None) -> bool:
        """
        Check if training should stop.
        
        Args:
            val_loss: Current validation loss
            model: Model to save weights from
            
        Returns:
            bool: True if training should stop
        """
        if self.best_loss is None:
            self.best_loss = val_loss
            if model is not None:
                self.best_weights = model.state_dict().copy()
            return False
        
        if val_loss < self.best_loss - self.min_delta:
            self.best_loss = val_loss
            self.counter = 0
            if model is not None:
                self.best_weights = model.state_dict().copy()
            return False
        else:
            self.counter += 1
            if self.counter >= self.patience:
                self.early_stop = True
                if self.restore_best_weights and model is not None and self.best_weights is not None:
                    model.load_state_dict(self.best_weights)
                return True
        
        return False
```

#### Step 2: Neural Network Architecture

**File:** `src/models/nn_architectures.py`
**Path:** `ml-pipeline-project/src/models/nn_architectures.py`

```python
"""
Neural network architectures for deep learning.
"""

from typing import Dict, List, Optional, Union, Any, Tuple
import torch
import torch.nn as nn
import torch.nn.functional as F
import math

class MLP(nn.Module):
    """
    Multi-Layer Perceptron (MLP) for classification and regression.
    
    A flexible feedforward neural network with configurable:
    - Number and size of hidden layers
    - Activation functions
    - Dropout for regularization
    - Batch normalization
    
    Example:
        >>> model = MLP(
        ...     input_dim=100,
        ...     hidden_dims=[64, 32],
        ...     output_dim=10,
        ...     activation='relu'
        ... )
        >>> output = model(torch.randn(32, 100))
    """
    
    def __init__(
        self,
        input_dim: int,
        hidden_dims: List[int],
        output_dim: int,
        activation: str = 'relu',
        dropout_rate: float = 0.0,
        use_batch_norm: bool = False,
        output_activation: Optional[str] = None
    ):
        """
        Initialize the MLP.
        
        Args:
            input_dim: Input dimension
            hidden_dims: List of hidden layer dimensions
            output_dim: Output dimension
            activation: Activation function name
            dropout_rate: Dropout rate (0 = no dropout)
            use_batch_norm: Whether to use batch normalization
            output_activation: Output activation function
        """
        super(MLP, self).__init__()
        
        self.input_dim = input_dim
        self.hidden_dims = hidden_dims
        self.output_dim = output_dim
        self.dropout_rate = dropout_rate
        self.use_batch_norm = use_batch_norm
        
        # Activation function
        self.activation = self._get_activation(activation)
        
        # Build layers
        layers = []
        prev_dim = input_dim
        
        for i, hidden_dim in enumerate(hidden_dims):
            # Linear layer
            layers.append(nn.Linear(prev_dim, hidden_dim))
            
            # Batch normalization
            if use_batch_norm:
                layers.append(nn.BatchNorm1d(hidden_dim))
            
            # Activation
            layers.append(self.activation)
            
            # Dropout
            if dropout_rate > 0:
                layers.append(nn.Dropout(dropout_rate))
            
            prev_dim = hidden_dim
        
        # Output layer
        layers.append(nn.Linear(prev_dim, output_dim))
        
        # Output activation
        if output_activation is not None:
            layers.append(self._get_activation(output_activation))
        
        self.layers = nn.Sequential(*layers)
        
        # Initialize weights
        self._initialize_weights()
    
    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """
        Forward pass.
        
        Args:
            x: Input tensor
            
        Returns:
            torch.Tensor: Output tensor
        """
        return self.layers(x)
    
    def _get_activation(self, name: str) -> nn.Module:
        """Get activation function by name."""
        activations = {
            'relu': nn.ReLU(),
            'leaky_relu': nn.LeakyReLU(0.1),
            'elu': nn.ELU(),
            'selu': nn.SELU(),
            'gelu': nn.GELU(),
            'sigmoid': nn.Sigmoid(),
            'tanh': nn.Tanh(),
            'softmax': nn.Softmax(dim=1),
            'identity': nn.Identity()
        }
        return activations.get(name.lower(), nn.ReLU())
    
    def _initialize_weights(self):
        """Initialize weights using He initialization."""
        for module in self.modules():
            if isinstance(module, nn.Linear):
                nn.init.kaiming_normal_(module.weight, mode='fan_in', nonlinearity='relu')
                if module.bias is not None:
                    nn.init.zeros_(module.bias)

class ResidualBlock(nn.Module):
    """
    Residual block with skip connection.
    
    Helps train deeper networks by allowing gradients to flow directly.
    """
    
    def __init__(
        self,
        dim: int,
        dropout_rate: float = 0.0,
        use_batch_norm: bool = True
    ):
        """
        Initialize residual block.
        
        Args:
            dim: Dimension of the block
            dropout_rate: Dropout rate
            use_batch_norm: Whether to use batch normalization
        """
        super(ResidualBlock, self).__init__()
        
        self.linear1 = nn.Linear(dim, dim)
        self.linear2 = nn.Linear(dim, dim)
        self.bn1 = nn.BatchNorm1d(dim) if use_batch_norm else nn.Identity()
        self.bn2 = nn.BatchNorm1d(dim) if use_batch_norm else nn.Identity()
        self.dropout = nn.Dropout(dropout_rate) if dropout_rate > 0 else nn.Identity()
        self.relu = nn.ReLU()
    
    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """Forward pass with residual connection."""
        residual = x
        
        out = self.linear1(x)
        out = self.bn1(out)
        out = self.relu(out)
        out = self.dropout(out)
        
        out = self.linear2(out)
        out = self.bn2(out)
        
        out = out + residual  # Skip connection
        out = self.relu(out)
        
        return out

class ResNet(nn.Module):
    """
    Residual Network with skip connections.
    
    Example:
        >>> model = ResNet(
        ...     input_dim=100,
        ...     hidden_dims=[64, 64, 64, 64],
        ...     output_dim=10,
        ...     num_blocks=4
        ... )
    """
    
    def __init__(
        self,
        input_dim: int,
        hidden_dims: List[int],
        output_dim: int,
        num_blocks: int = 3,
        dropout_rate: float = 0.0,
        use_batch_norm: bool = True
    ):
        """
        Initialize ResNet.
        
        Args:
            input_dim: Input dimension
            hidden_dims: Hidden layer dimensions
            output_dim: Output dimension
            num_blocks: Number of residual blocks
            dropout_rate: Dropout rate
            use_batch_norm: Whether to use batch normalization
        """
        super(ResNet, self).__init__()
        
        # Input projection
        self.input_proj = nn.Linear(input_dim, hidden_dims[0])
        self.input_bn = nn.BatchNorm1d(hidden_dims[0]) if use_batch_norm else nn.Identity()
        self.input_relu = nn.ReLU()
        
        # Residual blocks
        self.blocks = nn.ModuleList()
        for _ in range(num_blocks):
            for dim in hidden_dims:
                block = ResidualBlock(dim, dropout_rate, use_batch_norm)
                self.blocks.append(block)
        
        # Output layer
        self.output = nn.Linear(hidden_dims[-1], output_dim)
        
        # Initialize weights
        self._initialize_weights()
    
    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """Forward pass."""
        # Input projection
        x = self.input_proj(x)
        x = self.input_bn(x)
        x = self.input_relu(x)
        
        # Residual blocks
        for block in self.blocks:
            x = block(x)
        
        # Output
        x = self.output(x)
        
        return x
    
    def _initialize_weights(self):
        """Initialize weights."""
        for module in self.modules():
            if isinstance(module, nn.Linear):
                nn.init.kaiming_normal_(module.weight, mode='fan_in', nonlinearity='relu')
                if module.bias is not None:
                    nn.init.zeros_(module.bias)

class Autoencoder(nn.Module):
    """
    Autoencoder for unsupervised learning and dimensionality reduction.
    
    Example:
        >>> model = Autoencoder(input_dim=100, encoding_dim=16)
        >>> reconstructed = model(torch.randn(32, 100))
    """
    
    def __init__(
        self,
        input_dim: int,
        encoding_dim: int,
        hidden_dims: List[int] = None,
        activation: str = 'relu',
        dropout_rate: float = 0.0
    ):
        """
        Initialize autoencoder.
        
        Args:
            input_dim: Input dimension
            encoding_dim: Dimension of encoded representation
            hidden_dims: Hidden layer dimensions
            activation: Activation function
            dropout_rate: Dropout rate
        """
        super(Autoencoder, self).__init__()
        
        if hidden_dims is None:
            hidden_dims = [input_dim // 2, input_dim // 4]
        
        self.encoding_dim = encoding_dim
        
        # Encoder
        encoder_layers = []
        prev_dim = input_dim
        
        for dim in hidden_dims:
            encoder_layers.append(nn.Linear(prev_dim, dim))
            encoder_layers.append(self._get_activation(activation))
            if dropout_rate > 0:
                encoder_layers.append(nn.Dropout(dropout_rate))
            prev_dim = dim
        
        encoder_layers.append(nn.Linear(prev_dim, encoding_dim))
        self.encoder = nn.Sequential(*encoder_layers)
        
        # Decoder
        decoder_layers = []
        prev_dim = encoding_dim
        
        for dim in reversed(hidden_dims):
            decoder_layers.append(nn.Linear(prev_dim, dim))
            decoder_layers.append(self._get_activation(activation))
            if dropout_rate > 0:
                decoder_layers.append(nn.Dropout(dropout_rate))
            prev_dim = dim
        
        decoder_layers.append(nn.Linear(prev_dim, input_dim))
        self.decoder = nn.Sequential(*decoder_layers)
    
    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """Forward pass - encode then decode."""
        encoded = self.encoder(x)
        decoded = self.decoder(encoded)
        return decoded
    
    def encode(self, x: torch.Tensor) -> torch.Tensor:
        """Encode input to latent representation."""
        return self.encoder(x)
    
    def decode(self, z: torch.Tensor) -> torch.Tensor:
        """Decode latent representation back to original space."""
        return self.decoder(z)
    
    def _get_activation(self, name: str) -> nn.Module:
        """Get activation function by name."""
        activations = {
            'relu': nn.ReLU(),
            'leaky_relu': nn.LeakyReLU(0.1),
            'elu': nn.ELU(),
            'selu': nn.SELU(),
            'gelu': nn.GELU(),
            'sigmoid': nn.Sigmoid(),
            'tanh': nn.Tanh()
        }
        return activations.get(name.lower(), nn.ReLU())
```

#### Step 3: Training Engine

**File:** `src/models/trainer.py`
**Path:** `ml-pipeline-project/src/models/trainer.py`

```python
"""
Training engine for deep learning models.
"""

from typing import Dict, List, Optional, Union, Any, Tuple
from pathlib import Path
import time
import numpy as np
import pandas as pd
from loguru import logger
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
from sklearn.metrics import accuracy_score, f1_score, mean_squared_error, r2_score

from .deep_utils import setup_device, set_seed, EarlyStopping

class DeepTrainer:
    """
    Training engine for PyTorch models.
    
    Handles:
    - Training loop with progress tracking
    - Validation and early stopping
    - Learning rate scheduling
    - Model checkpointing
    - Metric computation
    - Device management
    
    Example:
        >>> trainer = DeepTrainer(
        ...     model=model,
        ...     criterion=nn.CrossEntropyLoss(),
        ...     optimizer=torch.optim.Adam(model.parameters(), lr=0.001)
        ... )
        >>> history = trainer.train(train_loader, val_loader, epochs=100)
    """
    
    def __init__(
        self,
        model: nn.Module,
        criterion: nn.Module,
        optimizer: optim.Optimizer,
        scheduler: Optional[optim.lr_scheduler._LRScheduler] = None,
        device: Optional[str] = None,
        use_gpu: bool = True,
        seed: int = 42
    ):
        """
        Initialize the trainer.
        
        Args:
            model: PyTorch model
            criterion: Loss function
            optimizer: Optimizer
            scheduler: Learning rate scheduler
            device: Device to use ('cpu', 'cuda', 'mps')
            use_gpu: Whether to use GPU if available
            seed: Random seed
        """
        self.model = model
        self.criterion = criterion
        self.optimizer = optimizer
        self.scheduler = scheduler
        
        # Setup device
        self.device = setup_device(use_gpu) if device is None else torch.device(device)
        self.model = self.model.to(self.device)
        
        # Set seed
        set_seed(seed)
        
        self.history = {
            'train_loss': [],
            'val_loss': [],
            'train_metrics': [],
            'val_metrics': []
        }
        
        logger.info(f"DeepTrainer initialized with device: {self.device}")
    
    def train(
        self,
        train_loader: DataLoader,
        val_loader: Optional[DataLoader] = None,
        epochs: int = 100,
        early_stopping: Optional[EarlyStopping] = None,
        checkpoint_dir: Optional[Path] = None,
        verbose: bool = True
    ) -> Dict[str, List[float]]:
        """
        Train the model.
        
        Args:
            train_loader: Training data loader
            val_loader: Validation data loader
            epochs: Number of epochs
            early_stopping: Early stopping callback
            checkpoint_dir: Directory to save checkpoints
            verbose: Whether to print progress
            
        Returns:
            Dict: Training history
        """
        logger.info(f"Starting training for {epochs} epochs")
        
        best_val_loss = float('inf')
        start_time = time.time()
        
        for epoch in range(epochs):
            # Training
            train_loss, train_metrics = self._train_epoch(train_loader)
            
            # Validation
            val_loss = None
            val_metrics = {}
            
            if val_loader is not None:
                val_loss, val_metrics = self._validate(val_loader)
            
            # Update history
            self.history['train_loss'].append(train_loss)
            if val_loss is not None:
                self.history['val_loss'].append(val_loss)
            
            # Update scheduler
            if self.scheduler is not None:
                if isinstance(self.scheduler, optim.lr_scheduler.ReduceLROnPlateau):
                    if val_loss is not None:
                        self.scheduler.step(val_loss)
                else:
                    self.scheduler.step()
            
            # Save checkpoint
            if checkpoint_dir is not None and val_loss is not None and val_loss < best_val_loss:
                best_val_loss = val_loss
                self.save_checkpoint(checkpoint_dir / 'best_model.pt')
            
            # Early stopping
            if early_stopping is not None and val_loss is not None:
                if early_stopping(val_loss, self.model):
                    logger.info(f"Early stopping at epoch {epoch+1}")
                    break
            
            # Print progress
            if verbose and (epoch + 1) % max(1, epochs // 10) == 0:
                elapsed = time.time() - start_time
                lr = self.optimizer.param_groups[0]['lr']
                
                metrics_str = ' '.join([f"{k}:{v:.4f}" for k, v in train_metrics.items()])
                val_str = f"val_loss:{val_loss:.4f}" if val_loss is not None else ""
                
                logger.info(
                    f"Epoch {epoch+1}/{epochs} | "
                    f"train_loss:{train_loss:.4f} | "
                    f"train_metrics:[{metrics_str}] | "
                    f"{val_str} | "
                    f"lr:{lr:.6f} | "
                    f"time:{elapsed:.1f}s"
                )
        
        logger.info(f"Training completed in {time.time() - start_time:.2f}s")
        return self.history
    
    def _train_epoch(self, loader: DataLoader) -> Tuple[float, Dict[str, float]]:
        """
        Train for one epoch.
        
        Args:
            loader: Data loader
            
        Returns:
            Tuple: (loss, metrics)
        """
        self.model.train()
        total_loss = 0.0
        all_preds = []
        all_targets = []
        
        for batch_idx, (data, targets) in enumerate(loader):
            data = data.to(self.device)
            targets = targets.to(self.device)
            
            # Forward pass
            outputs = self.model(data)
            loss = self.criterion(outputs, targets)
            
            # Backward pass
            self.optimizer.zero_grad()
            loss.backward()
            self.optimizer.step()
            
            total_loss += loss.item()
            
            # Store predictions for metrics
            if len(outputs.shape) > 1 and outputs.shape[1] > 1:
                preds = torch.argmax(outputs, dim=1)
            else:
                preds = outputs
            all_preds.extend(preds.cpu().detach().numpy())
            all_targets.extend(targets.cpu().detach().numpy())
        
        avg_loss = total_loss / len(loader)
        metrics = self._compute_metrics(all_targets, all_preds)
        
        return avg_loss, metrics
    
    def _validate(self, loader: DataLoader) -> Tuple[float, Dict[str, float]]:
        """
        Validate the model.
        
        Args:
            loader: Validation data loader
            
        Returns:
            Tuple: (loss, metrics)
        """
        self.model.eval()
        total_loss = 0.0
        all_preds = []
        all_targets = []
        
        with torch.no_grad():
            for data, targets in loader:
                data = data.to(self.device)
                targets = targets.to(self.device)
                
                outputs = self.model(data)
                loss = self.criterion(outputs, targets)
                
                total_loss += loss.item()
                
                if len(outputs.shape) > 1 and outputs.shape[1] > 1:
                    preds = torch.argmax(outputs, dim=1)
                else:
                    preds = outputs
                all_preds.extend(preds.cpu().numpy())
                all_targets.extend(targets.cpu().numpy())
        
        avg_loss = total_loss / len(loader)
        metrics = self._compute_metrics(all_targets, all_preds)
        
        return avg_loss, metrics
    
    def _compute_metrics(self, targets: List, preds: List) -> Dict[str, float]:
        """
        Compute performance metrics.
        
        Args:
            targets: True targets
            preds: Predictions
            
        Returns:
            Dict: Metrics
        """
        targets = np.array(targets)
        preds = np.array(preds)
        
        metrics = {}
        
        # Check if classification
        is_classification = len(np.unique(targets)) <= 10 and all(isinstance(x, (int, bool)) for x in targets)
        
        if is_classification:
            # Classification metrics
            metrics['accuracy'] = accuracy_score(targets, preds)
            try:
                metrics['f1'] = f1_score(targets, preds, average='weighted', zero_division=0)
            except:
                metrics['f1'] = 0.0
        else:
            # Regression metrics
            metrics['mse'] = mean_squared_error(targets, preds)
            metrics['rmse'] = np.sqrt(metrics['mse'])
            try:
                metrics['r2'] = r2_score(targets, preds)
            except:
                metrics['r2'] = 0.0
        
        return metrics
    
    def predict(self, loader: DataLoader) -> Tuple[np.ndarray, np.ndarray]:
        """
        Make predictions on data.
        
        Args:
            loader: Data loader
            
        Returns:
            Tuple: (predictions, targets)
        """
        self.model.eval()
        all_preds = []
        all_targets = []
        
        with torch.no_grad():
            for data, targets in loader:
                data = data.to(self.device)
                outputs = self.model(data)
                
                if len(outputs.shape) > 1 and outputs.shape[1] > 1:
                    preds = torch.argmax(outputs, dim=1)
                else:
                    preds = outputs
                
                all_preds.extend(preds.cpu().numpy())
                all_targets.extend(targets.cpu().numpy())
        
        return np.array(all_preds), np.array(all_targets)
    
    def predict_proba(self, loader: DataLoader) -> np.ndarray:
        """
        Predict probabilities.
        
        Args:
            loader: Data loader
            
        Returns:
            np.ndarray: Probabilities
        """
        self.model.eval()
        all_probs = []
        
        with torch.no_grad():
            for data, _ in loader:
                data = data.to(self.device)
                outputs = self.model(data)
                
                if len(outputs.shape) > 1 and outputs.shape[1] > 1:
                    probs = torch.softmax(outputs, dim=1)
                else:
                    probs = torch.sigmoid(outputs)
                
                all_probs.extend(probs.cpu().numpy())
        
        return np.array(all_probs)
    
    def save_checkpoint(self, filepath: Path):
        """
        Save model checkpoint.
        
        Args:
            filepath: Path to save
        """
        filepath = Path(filepath)
        filepath.parent.mkdir(parents=True, exist_ok=True)
        
        torch.save({
            'model_state_dict': self.model.state_dict(),
            'optimizer_state_dict': self.optimizer.state_dict(),
            'history': self.history
        }, filepath)
        
        logger.debug(f"Checkpoint saved to: {filepath}")
    
    def load_checkpoint(self, filepath: Path):
        """
        Load model checkpoint.
        
        Args:
            filepath: Path to load
        """
        filepath = Path(filepath)
        if not filepath.exists():
            logger.warning(f"Checkpoint not found: {filepath}")
            return
        
        checkpoint = torch.load(filepath, map_location=self.device)
        self.model.load_state_dict(checkpoint['model_state_dict'])
        self.optimizer.load_state_dict(checkpoint['optimizer_state_dict'])
        self.history = checkpoint['history']
        
        logger.info(f"Checkpoint loaded from: {filepath}")
```

### The Verification: Testing Our Deep Learning System

#### Test 1: Basic Neural Network

```bash
cat > test_deep_learning.py << 'EOF'
import numpy as np
import pandas as pd
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from src.models.nn_architectures import MLP
from src.models.trainer import DeepTrainer
from src.models.deep_utils import create_dataloaders, EarlyStopping
import torch
import torch.nn as nn
import torch.optim as optim

# Create dataset
X, y = make_classification(
    n_samples=1000,
    n_features=20,
    n_informative=10,
    n_redundant=5,
    n_classes=2,
    random_state=42
)

# Scale data
scaler = StandardScaler()
X = scaler.fit_transform(X)

# Split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

print("Dataset:")
print(f"  Train: {X_train.shape}")
print(f"  Test: {X_test.shape}")

# Create dataloaders
train_loader, test_loader = create_dataloaders(
    X_train, y_train, test_size=0.0, batch_size=32
)

# Create model
model = MLP(
    input_dim=X_train.shape[1],
    hidden_dims=[64, 32],
    output_dim=2,  # Binary classification
    activation='relu',
    dropout_rate=0.2,
    use_batch_norm=True
)

# Setup training
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.001)
scheduler = optim.lr_scheduler.ReduceLROnPlateau(
    optimizer, factor=0.5, patience=5
)
early_stopping = EarlyStopping(patience=10)

# Create trainer
trainer = DeepTrainer(
    model=model,
    criterion=criterion,
    optimizer=optimizer,
    scheduler=scheduler,
    use_gpu=True
)

# Train
print("\n" + "="*60)
print("Training Neural Network")
print("="*60)

history = trainer.train(
    train_loader,
    val_loader=None,  # No validation set for this test
    epochs=50,
    early_stopping=early_stopping,
    verbose=True
)

print(f"\nTraining completed. Final loss: {history['train_loss'][-1]:.4f}")

# Test model
print("\n" + "="*60)
print("Evaluation on Test Set")
print("="*60)

# Create test dataloader
test_dataset = torch.utils.data.TensorDataset(
    torch.tensor(X_test, dtype=torch.float32),
    torch.tensor(y_test, dtype=torch.long)
)
test_loader = torch.utils.data.DataLoader(
    test_dataset, batch_size=32, shuffle=False
)

# Predict
preds, targets = trainer.predict(test_loader)

# Calculate accuracy
accuracy = np.mean(preds == targets)
print(f"Test Accuracy: {accuracy:.4f}")

print("\n✅ Deep learning test complete!")
EOF

python test_deep_learning.py
```

#### Test 2: Autoencoder for Dimensionality Reduction

```bash
cat > test_autoencoder.py << 'EOF'
import numpy as np
import pandas as pd
from sklearn.datasets import load_wine
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from src.models.nn_architectures import Autoencoder
from src.models.trainer import DeepTrainer
from src.models.deep_utils import create_dataloaders
import torch
import torch.nn as nn
import torch.optim as optim

# Load data
wine = load_wine()
X = wine.data
y = wine.target

# Scale data
scaler = StandardScaler()
X = scaler.fit_transform(X)

# Split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

print(f"Data: {X.shape}")
print(f"Train: {X_train.shape}, Test: {X_test.shape}")

# Create dataloaders
train_loader, test_loader = create_dataloaders(
    X_train, y=None, test_size=0.0, batch_size=16
)

# Create autoencoder
autoencoder = Autoencoder(
    input_dim=X.shape[1],
    encoding_dim=8,
    hidden_dims=[16, 12],
    activation='relu',
    dropout_rate=0.1
)

# Setup training
criterion = nn.MSELoss()  # Reconstruction loss
optimizer = optim.Adam(autoencoder.parameters(), lr=0.001)
scheduler = optim.lr_scheduler.ReduceLROnPlateau(
    optimizer, factor=0.5, patience=5
)

# Create trainer
trainer = DeepTrainer(
    model=autoencoder,
    criterion=criterion,
    optimizer=optimizer,
    scheduler=scheduler,
    use_gpu=True
)

# Train
print("\n" + "="*60)
print("Training Autoencoder")
print("="*60)

history = trainer.train(
    train_loader,
    val_loader=None,
    epochs=50,
    verbose=True
)

print(f"\nTraining completed. Final loss: {history['train_loss'][-1]:.4f}")

# Test reconstruction
print("\n" + "="*60)
print("Reconstruction Quality")
print("="*60)

# Get some test data
test_data = torch.tensor(X_test[:10], dtype=torch.float32)
trainer.model.eval()
with torch.no_grad():
    reconstructed = trainer.model(test_data)

# Calculate reconstruction error
mse = torch.mean((test_data - reconstructed) ** 2).item()
print(f"Reconstruction MSE: {mse:.4f}")

# Encode to latent space
encoded = trainer.model.encode(test_data)
print(f"Encoded representation shape: {encoded.shape}")
print(f"Example encoded values: {encoded[0, :5].tolist()}")

print("\n✅ Autoencoder test complete!")
EOF

python test_autoencoder.py
```

#### Test 3: Full Integration with ResNet

```bash
cat > test_resnet.py << 'EOF'
import numpy as np
import pandas as pd
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from src.models.nn_architectures import ResNet
from src.models.trainer import DeepTrainer
from src.models.deep_utils import create_dataloaders, EarlyStopping
import torch
import torch.nn as nn
import torch.optim as optim

# Create larger dataset
X, y = make_classification(
    n_samples=2000,
    n_features=50,
    n_informative=25,
    n_redundant=10,
    n_classes=2,
    random_state=42
)

# Scale data
scaler = StandardScaler()
X = scaler.fit_transform(X)

# Split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

print(f"Data: {X.shape}")
print(f"Train: {X_train.shape}, Test: {X_test.shape}")

# Create dataloaders
train_loader, val_loader = create_dataloaders(
    X_train, y_train, test_size=0.2, batch_size=64
)

# Create ResNet
model = ResNet(
    input_dim=X_train.shape[1],
    hidden_dims=[64, 64, 128, 128],
    output_dim=2,
    num_blocks=3,
    dropout_rate=0.2,
    use_batch_norm=True
)

# Setup training
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.001)
scheduler = optim.lr_scheduler.ReduceLROnPlateau(
    optimizer, factor=0.5, patience=5
)
early_stopping = EarlyStopping(patience=10)

# Create trainer
trainer = DeepTrainer(
    model=model,
    criterion=criterion,
    optimizer=optimizer,
    scheduler=scheduler,
    use_gpu=True
)

# Train
print("\n" + "="*60)
print("Training ResNet")
print("="*60)

history = trainer.train(
    train_loader,
    val_loader=val_loader,
    epochs=100,
    early_stopping=early_stopping,
    verbose=True
)

print(f"\nTraining completed. Final train loss: {history['train_loss'][-1]:.4f}")
if history['val_loss']:
    print(f"Final validation loss: {history['val_loss'][-1]:.4f}")

# Test on test set
print("\n" + "="*60)
print("Test Set Evaluation")
print("="*60)

test_dataset = torch.utils.data.TensorDataset(
    torch.tensor(X_test, dtype=torch.float32),
    torch.tensor(y_test, dtype=torch.long)
)
test_loader = torch.utils.data.DataLoader(
    test_dataset, batch_size=64, shuffle=False
)

preds, targets = trainer.predict(test_loader)
accuracy = np.mean(preds == targets)
print(f"Test Accuracy: {accuracy:.4f}")

# Compare with standard MLP
print("\n" + "="*60)
print("Comparison with Standard MLP")
print("="*60)

from src.models.nn_architectures import MLP
mlp = MLP(
    input_dim=X_train.shape[1],
    hidden_dims=[128, 64, 32],
    output_dim=2,
    activation='relu',
    dropout_rate=0.2
)

mlp_optimizer = optim.Adam(mlp.parameters(), lr=0.001)
mlp_trainer = DeepTrainer(
    model=mlp,
    criterion=criterion,
    optimizer=mlp_optimizer,
    use_gpu=True
)

mlp_trainer.train(train_loader, val_loader, epochs=50, early_stopping=early_stopping)

# Evaluate MLP
mlp_preds, _ = mlp_trainer.predict(test_loader)
mlp_accuracy = np.mean(mlp_preds == targets)
print(f"MLP Test Accuracy: {mlp_accuracy:.4f}")

print(f"\nResNet improvement: {(accuracy - mlp_accuracy)*100:.2f}%")

print("\n✅ ResNet test complete!")
EOF

python test_resnet.py
```

### What Just Happened: Understanding Neural Networks

#### The Building Blocks

**Neurons**: The basic unit that receives inputs, applies a weight and bias, and passes through an activation function.

**Layers**: Collections of neurons. Types include:
- **Input Layer**: The first layer, matching input dimension
- **Hidden Layers**: Intermediate layers that learn representations
- **Output Layer**: The final layer, matching output dimension

**Activation Functions**: Non-linear transformations that allow the network to learn complex patterns:
- **ReLU**: f(x) = max(0, x) - Most common, fast
- **Sigmoid**: f(x) = 1/(1+e^(-x)) - Outputs between 0 and 1
- **Tanh**: f(x) = (e^x - e^(-x))/(e^x + e^(-x)) - Outputs between -1 and 1
- **Softmax**: Normalizes outputs to probabilities

**Loss Functions**: Measure how wrong the predictions are:
- **MSE**: Mean Squared Error - For regression
- **Cross-Entropy**: For classification
- **Binary Cross-Entropy**: For binary classification

**Optimizers**: Update weights to minimize loss:
- **SGD**: Stochastic Gradient Descent - Simple but slow
- **Adam**: Adaptive Moment Estimation - Most common, fast convergence
- **RMSprop**: Root Mean Square Propagation - Good for RNNs

#### Training Process

1. **Forward Pass**: Data flows through the network to produce predictions
2. **Loss Calculation**: Compare predictions to targets
3. **Backward Pass**: Compute gradients using backpropagation
4. **Weight Update**: Optimizer adjusts weights based on gradients

#### Key Concepts

**Overfitting**: Model learns noise rather than signal. Solutions:
- More data
- Dropout
- Regularization (L1/L2)
- Early stopping
- Batch normalization

**Vanishing/Exploding Gradients**: Gradients become too small or too large. Solutions:
- ReLU activation
- Batch normalization
- Residual connections

**Batch Size**: Number of samples processed at once:
- Larger: More stable, more memory
- Smaller: More frequent updates, more noise

**Learning Rate**: Step size for weight updates:
- Larger: Faster, may overshoot
- Smaller: Slower, more stable

### Summary

In this part, we've built a comprehensive deep learning system that:

1. **Sets up PyTorch** with GPU support and reproducibility
2. **Implements MLP** with configurable architecture
3. **Builds ResNet** with skip connections
4. **Creates Autoencoder** for unsupervised learning
5. **Provides training engine** with early stopping and checkpointing
6. **Handles data loading** with DataLoaders
7. **Computes metrics** for both classification and regression

### What's Next

We've completed Module 4.2! Next is Module 4.3: Model Validation & Hyperparameter Tuning, where we'll implement cross-validation strategies, comprehensive evaluation metrics, and advanced hyperparameter optimization with Optuna.

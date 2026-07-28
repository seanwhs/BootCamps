# Primer 30: Federated Learning

## Overview

This primer provides a comprehensive introduction to Federated Learning—a distributed machine learning approach that enables model training across decentralized data sources without sharing raw data. Understanding federated learning is essential for privacy-preserving ML applications in healthcare, finance, and other sensitive domains.

---

## 1. Introduction to Federated Learning

### What is Federated Learning?

```
┌─────────────────────────────────────────────────────────────────┐
│              WHAT IS FEDERATED LEARNING?                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Federated Learning trains models across decentralized         │
│  devices/servers without centralizing data.                    │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    CENTRALIZED ML                        │  │
│  │  All data → Central Server → Train Model                │  │
│  │  └── Data leaves devices                                │  │
│  │  └── Privacy concerns                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    FEDERATED LEARNING                    │  │
│  │  ┌─────────┐    ┌─────────┐    ┌─────────┐             │  │
│  │  │ Client 1│───▶│ Client 2│───▶│ Client 3│             │  │
│  │  │ (Data)  │    │ (Data)  │    │ (Data)  │             │  │
│  │  └────┬────┘    └────┬────┘    └────┬────┘             │  │
│  │       │              │              │                    │  │
│  │       └──────┬───────┴──────┬───────┘                    │  │
│  │              │              │                             │  │
│  │              ▼              ▼                             │  │
│  │     ┌─────────────────────────────┐                      │  │
│  │     │     Central Server          │                      │  │
│  │     │     (Aggregates Updates)    │                      │  │
│  │     └─────────────────────────────┘                      │  │
│  │                                                           │  │
│  │  └── Data stays on devices                                │  │
│  │  └── Privacy preserved                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Why Federated Learning?

```
┌─────────────────────────────────────────────────────────────────┐
│              WHY FEDERATED LEARNING?                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Privacy Protection                                             │
│  └── Data never leaves the device                             │
│  └── GDPR/CCPA compliance                                     │
│  └── Sensitive data protection                                │
│                                                                 │
│  Reduced Communication                                          │
│  └── Only model updates transmitted                            │
│  └── Lower bandwidth usage                                    │
│                                                                 │
│  Real-time Learning                                             │
│  └── Models learn from user behavior                           │
│  └── Continuous improvement                                   │
│                                                                 │
│  Regulatory Compliance                                          │
│  └── Healthcare (HIPAA)                                       │
│  └── Finance (PCI-DSS)                                        │
│                                                                 │
│  Edge Efficiency                                                │
│  └── Leverage edge devices                                     │
│  └── Reduce cloud costs                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Federated Learning Types

```
┌─────────────────────────────────────────────────────────────────┐
│              FEDERATED LEARNING TYPES                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Cross-Device FL                                                │
│  └── Large number of devices (millions)                        │
│  └── Unreliable connections                                    │
│  └── Example: Gboard keyboard                                  │
│                                                                 │
│  Cross-Silo FL                                                  │
│  └── Small number of organizations (2-100)                     │
│  └── Reliable connections                                      │
│  └── Example: Healthcare institutions                          │
│                                                                 │
│  Federated Transfer Learning                                    │
│  └── Different data distributions across clients              │
│  └── Labeled data on some clients                             │
│                                                                 │
│  Federated Reinforcement Learning                               │
│  └── Agents learn in different environments                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Federated Averaging (FedAvg)

### FedAvg Algorithm

```python
import torch
import torch.nn as nn
import numpy as np
from copy import deepcopy
from typing import List, Tuple, Dict

class FederatedAveraging:
    """
    Federated Averaging (FedAvg) algorithm.
    
    Implements: https://arxiv.org/abs/1602.05629
    """
    
    def __init__(
        self,
        model,
        num_clients,
        client_fraction=0.1,
        local_epochs=5,
        learning_rate=0.01
    ):
        """
        Initialize FedAvg.
        
        Args:
            model: Global model
            num_clients: Number of clients
            client_fraction: Fraction of clients per round
            local_epochs: Local training epochs
            learning_rate: Learning rate
        """
        self.global_model = model
        self.num_clients = num_clients
        self.client_fraction = client_fraction
        self.local_epochs = local_epochs
        self.learning_rate = learning_rate
        self.client_weights = None
    
    def select_clients(self, client_indices=None):
        """
        Select clients for this round.
        
        Args:
            client_indices: Specific clients to select
        
        Returns:
            list: Selected client indices
        """
        if client_indices is None:
            num_selected = max(1, int(self.num_clients * self.client_fraction))
            selected = np.random.choice(
                self.num_clients,
                num_selected,
                replace=False
            ).tolist()
        else:
            selected = client_indices
        
        return selected
    
    def aggregate(self, client_updates: List[Dict]):
        """
        Aggregate client updates.
        
        Args:
            client_updates: List of client model updates
        
        Returns:
            Dict: Aggregated weights
        """
        # Get total weights
        total_weights = sum(update['weight'] for update in client_updates)
        
        # Weighted average of model parameters
        aggregated_weights = {}
        for key in client_updates[0]['model_state'].keys():
            aggregated_weights[key] = torch.zeros_like(
                client_updates[0]['model_state'][key]
            )
            for update in client_updates:
                weight = update['weight'] / total_weights
                aggregated_weights[key] += weight * update['model_state'][key]
        
        return aggregated_weights
    
    def round(self, clients, client_data_loaders):
        """
        Perform one round of federated learning.
        
        Args:
            clients: List of client models
            client_data_loaders: List of client data loaders
        
        Returns:
            tuple: (global_model, client_updates)
        """
        selected_clients = self.select_clients()
        client_updates = []
        
        for client_idx in selected_clients:
            # Send global model to client
            client_model = clients[client_idx]
            client_model.load_state_dict(deepcopy(self.global_model.state_dict()))
            
            # Local training
            local_weights, local_update = self.local_train(
                client_model,
                client_data_loaders[client_idx]
            )
            
            client_updates.append({
                'model_state': local_update,
                'weight': len(client_data_loaders[client_idx].dataset)
            })
        
        # Aggregate updates
        aggregated_weights = self.aggregate(client_updates)
        
        # Update global model
        self.global_model.load_state_dict(aggregated_weights)
        
        return self.global_model, client_updates
    
    def local_train(self, model, data_loader):
        """
        Train model locally on client.
        
        Args:
            model: Client model
            data_loader: Client data
        
        Returns:
            tuple: (model_state, update)
        """
        # Save initial weights
        initial_state = deepcopy(model.state_dict())
        
        # Local training
        optimizer = torch.optim.SGD(model.parameters(), lr=self.learning_rate)
        criterion = nn.CrossEntropyLoss()
        
        model.train()
        for epoch in range(self.local_epochs):
            for batch_idx, (data, target) in enumerate(data_loader):
                optimizer.zero_grad()
                output = model(data)
                loss = criterion(output, target)
                loss.backward()
                optimizer.step()
        
        # Compute update
        final_state = model.state_dict()
        update = {}
        for key in initial_state.keys():
            update[key] = final_state[key] - initial_state[key]
        
        return final_state, update
```

### Building a Simple FL System

```python
class FederatedClient:
    """
    Client in federated learning system.
    """
    
    def __init__(self, client_id, model, data_loader):
        self.client_id = client_id
        self.model = model
        self.data_loader = data_loader
        self.global_model = None
    
    def receive_global_model(self, global_state):
        """Receive global model from server."""
        self.model.load_state_dict(deepcopy(global_state))
        self.global_model = deepcopy(global_state)
    
    def local_train(self, local_epochs=5, learning_rate=0.01):
        """Train locally."""
        optimizer = torch.optim.SGD(self.model.parameters(), lr=learning_rate)
        criterion = nn.CrossEntropyLoss()
        
        self.model.train()
        for epoch in range(local_epochs):
            for data, target in self.data_loader:
                optimizer.zero_grad()
                output = self.model(data)
                loss = criterion(output, target)
                loss.backward()
                optimizer.step()
        
        # Compute update
        update = {}
        for key in self.global_model.keys():
            update[key] = self.model.state_dict()[key] - self.global_model[key]
        
        return update
    
    def get_model_state(self):
        """Get current model state."""
        return self.model.state_dict()

class FederatedServer:
    """
    Server in federated learning system.
    """
    
    def __init__(self, global_model):
        self.global_model = global_model
        self.client_models = []
        self.client_weights = []
    
    def register_client(self, client):
        """Register a client with the server."""
        self.client_models.append(client)
    
    def aggregate(self, updates):
        """
        Aggregate client updates.
        
        Args:
            updates: List of client updates
        
        Returns:
            dict: Aggregated weights
        """
        # Simple average
        aggregated = {}
        for key in updates[0].keys():
            aggregated[key] = torch.zeros_like(updates[0][key])
            for update in updates:
                aggregated[key] += update[key]
            aggregated[key] /= len(updates)
        
        return aggregated
    
    def federated_round(self, selected_clients=None):
        """
        Perform one federated round.
        
        Args:
            selected_clients: Specific clients to use
        
        Returns:
            dict: Updated global model
        """
        # Select clients
        if selected_clients is None:
            selected_clients = self.client_models
        
        # Send global model to clients
        global_state = self.global_model.state_dict()
        for client in selected_clients:
            client.receive_global_model(global_state)
        
        # Local training
        updates = []
        for client in selected_clients:
            update = client.local_train()
            updates.append(update)
        
        # Aggregate updates
        aggregated = self.aggregate(updates)
        
        # Update global model
        self.global_model.load_state_dict(aggregated)
        
        return aggregated
```

---

## 3. Differential Privacy in Federated Learning

### Adding Differential Privacy

```python
class DifferentialPrivacy:
    """
    Differential privacy for federated learning.
    """
    
    def __init__(self, epsilon=1.0, delta=1e-5, clip_norm=1.0):
        self.epsilon = epsilon
        self.delta = delta
        self.clip_norm = clip_norm
    
    def clip_gradients(self, gradients):
        """
        Clip gradients to bound sensitivity.
        
        Args:
            gradients: Model gradients
        
        Returns:
            dict: Clipped gradients
        """
        clipped_grads = {}
        
        for key, grad in gradients.items():
            # Compute norm
            norm = torch.norm(grad)
            
            # Clip if norm exceeds threshold
            if norm > self.clip_norm:
                clipped_grads[key] = grad * (self.clip_norm / norm)
            else:
                clipped_grads[key] = grad
        
        return clipped_grads
    
    def add_noise(self, gradients):
        """
        Add Gaussian noise for differential privacy.
        
        Args:
            gradients: Model gradients
        
        Returns:
            dict: Noisy gradients
        """
        # Calculate noise scale
        noise_scale = self.clip_norm * np.sqrt(2 * np.log(1.25 / self.delta)) / self.epsilon
        
        noisy_grads = {}
        for key, grad in gradients.items():
            noise = torch.normal(0, noise_scale, grad.shape)
            noisy_grads[key] = grad + noise
        
        return noisy_grads
    
    def dp_aggregate(self, client_updates):
        """
        DP-aggregate client updates.
        
        Args:
            client_updates: List of client updates
        
        Returns:
            dict: DP-aggregated weights
        """
        # Clip updates
        clipped_updates = []
        for update in client_updates:
            clipped = self.clip_gradients(update)
            clipped_updates.append(clipped)
        
        # Average updates
        avg_update = {}
        for key in clipped_updates[0].keys():
            avg_update[key] = torch.zeros_like(clipped_updates[0][key])
            for update in clipped_updates:
                avg_update[key] += update[key]
            avg_update[key] /= len(clipped_updates)
        
        # Add noise
        noisy_update = self.add_noise(avg_update)
        
        return noisy_update
```

---

## 4. Federated Learning with PySyft

```python
# PySyft Federated Learning (Simplified Example)
"""
PySyft enables privacy-preserving ML with:
- Federated Learning
- Differential Privacy
- Secure Multi-Party Computation
- Homomorphic Encryption
"""

# Note: PySyft requires setup with virtual machines/docker
# This is a conceptual example

class PySyftFederated:
    """
    Conceptual PySyft federated learning.
    """
    
    def __init__(self, model):
        self.model = model
        self.workers = []
    
    def add_worker(self, worker_id, data):
        """Add a worker with data."""
        # In PySyft, workers are virtual nodes
        pass
    
    def federated_training(self, rounds=10, local_epochs=5):
        """
        Federated training with PySyft.
        
        Args:
            rounds: Number of federated rounds
            local_epochs: Local epochs per round
        """
        # Send model to workers
        # Each worker trains locally
        # Aggregate updates securely
        
        # In practice:
        # 1. Send model to workers
        # 2. Workers train on local data
        # 3. Workers send encrypted updates
        # 4. Server aggregates (with secure aggregation)
        # 5. Update global model
        pass
```

---

## 5. Federated Learning with Flower

```python
"""
Flower is a friendly federated learning framework.

pip install flwr
"""

import flwr as fl
from flwr.common import NDArrays, Scalar
from typing import Dict, List, Optional, Tuple
import torch
import torch.nn as nn

class FlowerClient:
    """
    Flower client implementation.
    """
    
    def __init__(self, model, train_loader, val_loader, cid):
        self.model = model
        self.train_loader = train_loader
        self.val_loader = val_loader
        self.cid = cid
    
    def get_parameters(self):
        """Get model parameters."""
        return [val.cpu().numpy() for val in self.model.state_dict().values()]
    
    def set_parameters(self, parameters):
        """Set model parameters."""
        params_dict = zip(self.model.state_dict().keys(), parameters)
        state_dict = {k: torch.tensor(v) for k, v in params_dict}
        self.model.load_state_dict(state_dict, strict=True)
    
    def fit(self, parameters, config):
        """Train model on local data."""
        self.set_parameters(parameters)
        
        # Local training
        optimizer = torch.optim.SGD(self.model.parameters(), lr=0.01)
        criterion = nn.CrossEntropyLoss()
        
        self.model.train()
        for epoch in range(5):  # Local epochs
            for data, target in self.train_loader:
                optimizer.zero_grad()
                output = self.model(data)
                loss = criterion(output, target)
                loss.backward()
                optimizer.step()
        
        # Return updated parameters
        return self.get_parameters(), len(self.train_loader.dataset), {}
    
    def evaluate(self, parameters, config):
        """Evaluate model on local validation data."""
        self.set_parameters(parameters)
        
        self.model.eval()
        correct = 0
        total = 0
        
        with torch.no_grad():
            for data, target in self.val_loader:
                output = self.model(data)
                pred = output.argmax(dim=1)
                correct += (pred == target).sum().item()
                total += target.size(0)
        
        accuracy = correct / total
        
        return float(accuracy), len(self.val_loader.dataset), {"accuracy": accuracy}

# Server setup (conceptual)
def start_flower_server():
    """Start Flower server."""
    # strategy = fl.server.strategy.FedAvg(...)
    # fl.server.start_server(strategy=strategy)
    pass

# Client setup (conceptual)
def start_flower_client():
    """Start Flower client."""
    # fl.client.start_client(...)
    pass
```

---

## Quick Reference: Federated Learning

### FL Framework Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│  FRAMEWORK    │ BEST FOR          │ COMPLEXITY │ FEATURES     │
├───────────────┼───────────────────┼────────────┼──────────────┤
│  PySyft       │ Research          │ High       │ DP, SMPC, HE │
│  Flower       │ Production        │ Medium     │ DP, Multi-GPU│
│  TensorFlow   │ TensorFlow users  │ Medium     │ DP           │
│  PyTorch FL   │ PyTorch users     │ Medium     │ Basic        │
│  OpenFL       │ Healthcare        │ Medium     │ DP           │
└─────────────────────────────────────────────────────────────────┘
```

### FL Considerations

```
┌─────────────────────────────────────────────────────────────────┐
│  CONSIDERATION   │ IMPACT                │ MITIGATION        │
├──────────────────┼───────────────────────┼───────────────────┤
│  Non-IID Data    │ Model performance     │ FedProx, SCAFFOLD │
│  Communication   │ Training speed        │ Compression       │
│  Privacy         │ Data leakage risk     │ DP, Secure Agg.  │
│  Client Dropout  │ Convergence           │ Robust Agg.      │
│  Heterogeneity   │ Model divergence      │ Personalized FL  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers the essential concepts of Federated Learning. You now understand:

1. **What is FL**: Decentralized, privacy-preserving training
2. **FedAvg**: Core algorithm for federated learning
3. **FL system**: Clients, server, aggregation
4. **Differential privacy**: Privacy preservation
5. **Frameworks**: PySyft, Flower

**Next Steps:**
1. Implement basic FedAvg
2. Try Flower framework
3. Add differential privacy
4. Explore non-IID scenarios
5. Proceed to Part 1 of the series

---

*End of Primer 30*

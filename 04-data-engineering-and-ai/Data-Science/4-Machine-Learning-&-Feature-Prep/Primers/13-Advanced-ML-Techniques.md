# Primer 13: Advanced ML Techniques

## Overview

This primer provides a comprehensive introduction to advanced machine learning techniques that go beyond the basics. It covers ensemble methods, advanced optimization, transfer learning, reinforcement learning, and other cutting-edge approaches. Understanding these techniques will expand your ML toolkit and enable you to tackle more complex problems.

---

## 1. Advanced Ensemble Methods

### Stacking (Stacked Generalization)

Stacking combines multiple models by training a meta-model on their predictions.

```
┌─────────────────────────────────────────────────────────────────┐
│                    STACKING ARCHITECTURE                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Level 0 (Base Models)           Level 1 (Meta-Model)          │
│                                                                 │
│  ┌─────────────┐                 ┌─────────────────────────┐   │
│  │  Model 1    │──▶ Predictions ─│                         │   │
│  └─────────────┘                  │                         │   │
│  ┌─────────────┐                 │  Meta-Model             │   │
│  │  Model 2    │──▶ Predictions ─│  (e.g., Logistic Reg)  │──▶ Final│
│  └─────────────┘                  │                         │   │
│  ┌─────────────┐                 │                         │   │
│  │  Model 3    │──▶ Predictions ─│                         │   │
│  └─────────────┘                 └─────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

```python
from sklearn.ensemble import StackingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.svm import SVC
from sklearn.ensemble import RandomForestClassifier

# Create base models
base_models = [
    ('rf', RandomForestClassifier(n_estimators=50, random_state=42)),
    ('svm', SVC(kernel='rbf', probability=True, random_state=42)),
    ('dt', DecisionTreeClassifier(max_depth=5, random_state=42))
]

# Create stacking classifier
stacking_model = StackingClassifier(
    estimators=base_models,
    final_estimator=LogisticRegression(),
    cv=5
)

# Train
stacking_model.fit(X_train, y_train)

# Predict
y_pred = stacking_model.predict(X_test)
y_proba = stacking_model.predict_proba(X_test)
```

### Blending

```python
def blend_predictions(models, X_train, y_train, X_test, X_val=None):
    """
    Blend predictions using validation set.
    
    Args:
        models: List of trained models
        X_train: Training data
        y_train: Training target
        X_test: Test data
        X_val: Validation data (if None, use cross-validation)
    
    Returns:
        tuple: Blended predictions, blend weights
    """
    from sklearn.linear_model import LinearRegression
    
    if X_val is None:
        # Use cross-validation to get OOF predictions
        from sklearn.model_selection import cross_val_predict
        blend_features = []
        for model in models:
            oof_preds = cross_val_predict(model, X_train, y_train, cv=5, method='predict_proba')[:, 1]
            blend_features.append(oof_preds)
        blend_features = np.column_stack(blend_features)
        
        # Train blender
        blender = LogisticRegression()
        blender.fit(blend_features, y_train)
        
        # Get test predictions
        test_features = np.column_stack([model.predict_proba(X_test)[:, 1] for model in models])
        blended_preds = blender.predict_proba(test_features)[:, 1]
        
        return blended_preds, blender.coef_[0]
    else:
        # Use validation set
        val_features = np.column_stack([model.predict_proba(X_val)[:, 1] for model in models])
        blender = LogisticRegression()
        blender.fit(val_features, y_val)
        
        test_features = np.column_stack([model.predict_proba(X_test)[:, 1] for model in models])
        blended_preds = blender.predict_proba(test_features)[:, 1]
        
        return blended_preds, blender.coef_[0]
```

### XGBoost Advanced Features

```python
import xgboost as xgb

# Custom objective function
def custom_objective(y_true, y_pred):
    """Custom objective for asymmetric costs."""
    grad = y_pred - y_true
    # Asymmetric gradient: penalize false negatives more
    grad[y_true == 1] *= 2.0
    hess = np.ones_like(y_true)
    return grad, hess

# Custom evaluation metric
def custom_eval(y_true, y_pred):
    """Custom evaluation metric (profit-based)."""
    # Assume: TP profit = $100, FP cost = $10
    from sklearn.metrics import confusion_matrix
    y_pred_binary = (y_pred > 0.5).astype(int)
    tn, fp, fn, tp = confusion_matrix(y_true, y_pred_binary).ravel()
    profit = tp * 100 - fp * 10
    return 'profit', profit

# Train with custom objective
model = xgb.XGBClassifier(
    n_estimators=100,
    max_depth=6,
    learning_rate=0.1,
    objective=custom_objective,
    random_state=42
)

# XGBoost with early stopping
model = xgb.XGBClassifier(
    n_estimators=1000,
    max_depth=6,
    learning_rate=0.1,
    early_stopping_rounds=10,
    eval_metric='logloss',
    random_state=42
)

model.fit(
    X_train, y_train,
    eval_set=[(X_val, y_val)],
    verbose=False
)

# XGBoost with monotonic constraints
model = xgb.XGBClassifier(
    n_estimators=100,
    max_depth=6,
    monotone_constraints=[1, -1, 0, 1]  # 1=increasing, -1=decreasing, 0=no constraint
)
```

### LightGBM Advanced Features

```python
import lightgbm as lgb

# LightGBM with categorical features
model = lgb.LGBMClassifier(
    n_estimators=100,
    max_depth=6,
    learning_rate=0.1,
    categorical_feature=['gender', 'city', 'contract_type'],
    random_state=42
)

# LightGBM with custom metric
def custom_metric(y_pred, y_true):
    """Custom profit-based metric."""
    y_pred_binary = (y_pred > 0.5).astype(int)
    tn, fp, fn, tp = confusion_matrix(y_true, y_pred_binary).ravel()
    profit = tp * 100 - fp * 10
    return 'profit', profit, True  # True = higher is better

model = lgb.LGBMClassifier(
    n_estimators=100,
    max_depth=6,
    learning_rate=0.1,
    metric=custom_metric,
    random_state=42
)

# LightGBM with feature importance
model.fit(X_train, y_train, feature_name=X_train.columns.tolist())
importance = pd.DataFrame({
    'feature': model.feature_name_,
    'importance': model.feature_importances_
}).sort_values('importance', ascending=False)
```

---

## 2. Advanced Optimization

### Bayesian Optimization with Optuna

```python
import optuna
from optuna.pruners import MedianPruner
from optuna.samplers import TPESampler

def objective(trial):
    """Optuna objective function."""
    # Suggest hyperparameters
    params = {
        'n_estimators': trial.suggest_int('n_estimators', 50, 500),
        'max_depth': trial.suggest_int('max_depth', 3, 12),
        'learning_rate': trial.suggest_float('learning_rate', 0.01, 0.3, log=True),
        'subsample': trial.suggest_float('subsample', 0.6, 1.0),
        'colsample_bytree': trial.suggest_float('colsample_bytree', 0.6, 1.0),
        'min_child_weight': trial.suggest_int('min_child_weight', 1, 10),
        'gamma': trial.suggest_float('gamma', 0, 5),
        'reg_alpha': trial.suggest_float('reg_alpha', 0, 1),
        'reg_lambda': trial.suggest_float('reg_lambda', 0, 1),
    }
    
    # Train model
    model = xgb.XGBClassifier(**params, random_state=42, n_jobs=-1)
    
    # Cross-validate
    from sklearn.model_selection import cross_val_score
    scores = cross_val_score(model, X_train, y_train, cv=5, scoring='roc_auc')
    
    return scores.mean()

# Create study with pruning
study = optuna.create_study(
    direction='maximize',
    sampler=TPESampler(seed=42),
    pruner=MedianPruner(
        n_startup_trials=5,
        n_warmup_steps=10,
        interval_steps=1
    )
)

# Optimize with timeout
study.optimize(objective, n_trials=100, timeout=3600)

# Get best parameters
best_params = study.best_params
print(f"Best score: {study.best_value:.4f}")
print(f"Best params: {best_params}")
```

### Hyperparameter Search Strategies

```python
# Hyperband
from optuna.pruners import HyperbandPruner

study = optuna.create_study(
    direction='maximize',
    pruner=HyperbandPruner(
        min_resource=1,
        max_resource=100,
        reduction_factor=3
    )
)

# Population Based Training (simplified)
def pbt_search():
    """Simulated PBT search."""
    population = []
    for i in range(10):
        # Random initialization
        params = {
            'n_estimators': np.random.randint(50, 300),
            'max_depth': np.random.randint(3, 10),
            'learning_rate': np.random.uniform(0.01, 0.3)
        }
        model = xgb.XGBClassifier(**params)
        score = cross_val_score(model, X_train, y_train, cv=3).mean()
        population.append((params, score))
    
    # Evolution rounds
    for round in range(5):
        # Sort by performance
        population.sort(key=lambda x: x[1], reverse=True)
        
        # Keep top 5, replace bottom 5 with variations of top performers
        for i in range(5, len(population)):
            # Copy from top performer with mutation
            parent = population[i % 5][0]
            child = parent.copy()
            
            # Mutate
            if np.random.random() > 0.5:
                child['n_estimators'] = int(child['n_estimators'] * np.random.uniform(0.8, 1.2))
            if np.random.random() > 0.5:
                child['max_depth'] = int(child['max_depth'] * np.random.uniform(0.8, 1.2))
            if np.random.random() > 0.5:
                child['learning_rate'] = child['learning_rate'] * np.random.uniform(0.8, 1.2)
            
            # Evaluate child
            model = xgb.XGBClassifier(**child)
            score = cross_val_score(model, X_train, y_train, cv=3).mean()
            population[i] = (child, score)
    
    return population[0]  # Best performer
```

---

## 3. Transfer Learning

### Pre-trained Models with PyTorch

```python
import torch
import torch.nn as nn
import torchvision.models as models
from torch.utils.data import DataLoader

def create_transfer_model(num_classes):
    """
    Create a transfer learning model using ResNet50.
    
    Args:
        num_classes: Number of output classes
    
    Returns:
        nn.Module: Transfer learning model
    """
    # Load pre-trained ResNet50
    model = models.resnet50(weights='IMAGENET1K_V1')
    
    # Freeze all layers
    for param in model.parameters():
        param.requires_grad = False
    
    # Replace final layer
    num_features = model.fc.in_features
    model.fc = nn.Sequential(
        nn.Linear(num_features, 512),
        nn.ReLU(),
        nn.Dropout(0.5),
        nn.Linear(512, num_classes)
    )
    
    return model

# Use with your data
model = create_transfer_model(num_classes=5)

# Training (only last layer)
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.fc.parameters(), lr=0.001)

def train_epoch(dataloader):
    model.train()
    for inputs, labels in dataloader:
        optimizer.zero_grad()
        outputs = model(inputs)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
```

### Fine-tuning

```python
def fine_tune_model(model, dataloader, epochs=10):
    """
    Fine-tune a pre-trained model.
    
    Args:
        model: Pre-trained model
        dataloader: DataLoader for fine-tuning
        epochs: Number of epochs
    """
    # Unfreeze some layers
    for param in model.layer4.parameters():
        param.requires_grad = True
    
    # Use smaller learning rate for fine-tuning
    optimizer = torch.optim.Adam([
        {'params': model.layer4.parameters(), 'lr': 1e-5},
        {'params': model.fc.parameters(), 'lr': 1e-4}
    ])
    
    criterion = nn.CrossEntropyLoss()
    
    for epoch in range(epochs):
        model.train()
        for inputs, labels in dataloader:
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
```

### Feature Extraction

```python
def extract_features(model, dataloader):
    """
    Extract features from a pre-trained model.
    
    Args:
        model: Pre-trained model
        dataloader: DataLoader for feature extraction
    
    Returns:
        np.ndarray: Extracted features
    """
    model.eval()
    features = []
    labels = []
    
    with torch.no_grad():
        for inputs, label in dataloader:
            # Extract features from penultimate layer
            # For ResNet50, this is after avgpool
            x = model.conv1(inputs)
            x = model.bn1(x)
            x = model.relu(x)
            x = model.maxpool(x)
            
            x = model.layer1(x)
            x = model.layer2(x)
            x = model.layer3(x)
            x = model.layer4(x)
            
            x = model.avgpool(x)
            x = torch.flatten(x, 1)
            
            features.append(x.numpy())
            labels.append(label.numpy())
    
    return np.vstack(features), np.hstack(labels)

# Use features with a classifier
features, labels = extract_features(model, dataloader)
from sklearn.ensemble import RandomForestClassifier
classifier = RandomForestClassifier()
classifier.fit(features, labels)
```

---

## 4. Reinforcement Learning Fundamentals

### Q-Learning

```python
import numpy as np
import random

class QLearningAgent:
    """
    Q-Learning agent for reinforcement learning.
    """
    
    def __init__(self, n_states, n_actions, learning_rate=0.1, discount=0.9, epsilon=0.1):
        self.n_states = n_states
        self.n_actions = n_actions
        self.lr = learning_rate
        self.discount = discount
        self.epsilon = epsilon
        
        # Initialize Q-table
        self.Q = np.zeros((n_states, n_actions))
    
    def get_action(self, state):
        """Choose action using epsilon-greedy policy."""
        if np.random.random() < self.epsilon:
            return random.randint(0, self.n_actions - 1)
        return np.argmax(self.Q[state])
    
    def update(self, state, action, reward, next_state):
        """Update Q-value using Bellman equation."""
        best_next = np.max(self.Q[next_state])
        td_target = reward + self.discount * best_next
        td_error = td_target - self.Q[state, action]
        self.Q[state, action] += self.lr * td_error
    
    def train(self, env, episodes=1000):
        """Train the agent."""
        rewards = []
        
        for episode in range(episodes):
            state = env.reset()
            total_reward = 0
            done = False
            
            while not done:
                action = self.get_action(state)
                next_state, reward, done, _ = env.step(action)
                self.update(state, action, reward, next_state)
                state = next_state
                total_reward += reward
            
            rewards.append(total_reward)
            
            # Decay epsilon
            self.epsilon = max(0.01, self.epsilon * 0.995)
        
        return rewards
```

### Policy Gradient (REINFORCE)

```python
class PolicyGradientAgent:
    """
    REINFORCE policy gradient agent.
    """
    
    def __init__(self, n_states, n_actions, learning_rate=0.01):
        self.n_states = n_states
        self.n_actions = n_actions
        self.lr = learning_rate
        
        # Simple linear policy: P(action) = softmax(W * state)
        self.W = np.random.randn(n_states, n_actions) * 0.01
        self.episode_states = []
        self.episode_actions = []
        self.episode_rewards = []
    
    def get_action_probs(self, state):
        """Get action probabilities."""
        scores = np.dot(state, self.W)
        exp_scores = np.exp(scores - np.max(scores))
        return exp_scores / np.sum(exp_scores)
    
    def get_action(self, state):
        """Sample action from policy."""
        probs = self.get_action_probs(state)
        action = np.random.choice(self.n_actions, p=probs)
        return action
    
    def store_transition(self, state, action, reward):
        """Store transition for training."""
        self.episode_states.append(state)
        self.episode_actions.append(action)
        self.episode_rewards.append(reward)
    
    def update_policy(self):
        """Update policy using REINFORCE."""
        # Calculate discounted rewards
        discounted_rewards = []
        running_reward = 0
        for reward in reversed(self.episode_rewards):
            running_reward = reward + 0.9 * running_reward
            discounted_rewards.insert(0, running_reward)
        
        # Normalize rewards
        discounted_rewards = np.array(discounted_rewards)
        discounted_rewards = (discounted_rewards - discounted_rewards.mean()) / (discounted_rewards.std() + 1e-8)
        
        # Update policy
        for i in range(len(self.episode_states)):
            state = self.episode_states[i]
            action = self.episode_actions[i]
            reward = discounted_rewards[i]
            
            # Gradient ascent
            probs = self.get_action_probs(state)
            grad = -probs
            grad[action] += 1
            grad = grad * reward
            
            self.W += self.lr * np.outer(state, grad)
        
        # Clear episode memory
        self.episode_states = []
        self.episode_actions = []
        self.episode_rewards = []
```

---

## 5. Deep Reinforcement Learning (DQN)

```python
import torch
import torch.nn as nn
import torch.optim as optim
import numpy as np
from collections import deque
import random

class DQN(nn.Module):
    """Deep Q-Network."""
    
    def __init__(self, n_states, n_actions, hidden_size=128):
        super(DQN, self).__init__()
        self.net = nn.Sequential(
            nn.Linear(n_states, hidden_size),
            nn.ReLU(),
            nn.Linear(hidden_size, hidden_size),
            nn.ReLU(),
            nn.Linear(hidden_size, n_actions)
        )
    
    def forward(self, x):
        return self.net(x)

class DQNAgent:
    """
    Deep Q-Network agent with experience replay.
    """
    
    def __init__(self, n_states, n_actions, learning_rate=0.001, epsilon=1.0, epsilon_min=0.01, epsilon_decay=0.995):
        self.n_states = n_states
        self.n_actions = n_actions
        self.epsilon = epsilon
        self.epsilon_min = epsilon_min
        self.epsilon_decay = epsilon_decay
        
        # Networks
        self.q_network = DQN(n_states, n_actions)
        self.target_network = DQN(n_states, n_actions)
        self.target_network.load_state_dict(self.q_network.state_dict())
        
        self.optimizer = optim.Adam(self.q_network.parameters(), lr=learning_rate)
        self.criterion = nn.MSELoss()
        
        # Replay memory
        self.memory = deque(maxlen=10000)
        self.batch_size = 64
    
    def get_action(self, state):
        """Choose action using epsilon-greedy policy."""
        if np.random.random() < self.epsilon:
            return random.randint(0, self.n_actions - 1)
        
        state = torch.FloatTensor(state).unsqueeze(0)
        q_values = self.q_network(state)
        return np.argmax(q_values.detach().numpy())
    
    def remember(self, state, action, reward, next_state, done):
        """Store experience in replay memory."""
        self.memory.append((state, action, reward, next_state, done))
    
    def replay(self):
        """Train the network using experience replay."""
        if len(self.memory) < self.batch_size:
            return
        
        # Sample batch
        batch = random.sample(self.memory, self.batch_size)
        states, actions, rewards, next_states, dones = zip(*batch)
        
        states = torch.FloatTensor(np.array(states))
        actions = torch.LongTensor(np.array(actions))
        rewards = torch.FloatTensor(np.array(rewards))
        next_states = torch.FloatTensor(np.array(next_states))
        dones = torch.BoolTensor(np.array(dones))
        
        # Current Q values
        current_q = self.q_network(states).gather(1, actions.unsqueeze(1))
        
        # Target Q values
        next_q = self.target_network(next_states).max(1)[0]
        target_q = rewards + (0.99 * next_q * ~dones)
        
        # Loss
        loss = self.criterion(current_q.squeeze(), target_q.detach())
        
        # Optimize
        self.optimizer.zero_grad()
        loss.backward()
        self.optimizer.step()
        
        # Decay epsilon
        self.epsilon = max(self.epsilon_min, self.epsilon * self.epsilon_decay)
    
    def update_target_network(self):
        """Update target network."""
        self.target_network.load_state_dict(self.q_network.state_dict())
```

---

## Quick Reference: Advanced ML

### Ensemble Methods

```
┌─────────────────────────────────────────────────────────────────┐
│  METHOD       │ BEST FOR                    │ COMPLEXITY      │
├────────────────┼─────────────────────────────┼─────────────────┤
│  Stacking     │ Complex problems            │ High            │
│  Blending     │ Large datasets              │ Medium          │
│  Voting       │ Simple ensemble             │ Low             │
│  Bagging      │ High variance               │ Medium          │
│  Boosting     │ High bias                   │ Medium          │
└─────────────────────────────────────────────────────────────────┘
```

### Optimization Strategies

```
┌─────────────────────────────────────────────────────────────────┐
│  STRATEGY     │ BEST FOR                    │ SPEED           │
├────────────────┼─────────────────────────────┼─────────────────┤
│  Grid Search  │ Small spaces                │ Slow            │
│  Random Search│ Large spaces                │ Fast            │
│  Bayesian     │ Expensive evaluation        │ Medium          │
│  Hyperband    │ Large spaces, early stop    │ Fast            │
│  PBT          │ Dynamic search              │ Slow            │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers advanced ML techniques. You now understand:

1. **Advanced ensembles**: Stacking, blending, custom objectives
2. **Advanced optimization**: Bayesian, Hyperband, PBT
3. **Transfer learning**: Pre-training, fine-tuning, feature extraction
4. **Reinforcement learning**: Q-Learning, Policy Gradient, DQN

**Next Steps:**
1. Experiment with stacking on your problems
2. Try Bayesian optimization
3. Explore transfer learning
4. Implement a simple RL agent
5. Proceed to Part 1 of the series

---

*End of Primer 13*

# Primer 16: Distributed Machine Learning

## Overview

This primer provides a comprehensive introduction to distributed machine learning—the techniques and tools for training and deploying ML models at scale across multiple machines. Understanding distributed ML is essential for handling large datasets, reducing training time, and building production-scale systems.

---

## 1. Why Distributed ML?

### The Scale Challenge

```
┌─────────────────────────────────────────────────────────────────┐
│                    THE SCALE CHALLENGE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Data Growth                                                    │
│  └── Datasets are growing exponentially                       │
│      • 2020: ~10GB per day per company                        │
│      • 2024: ~1TB+ per day per company                        │
│      • AI models: billions of parameters                      │
│                                                                 │
│  Model Growth                                                   │
│  └── Models are getting larger                                │
│      • BERT: 340M parameters                                  │
│      • GPT-3: 175B parameters                                 │
│      • GPT-4: 1.7T+ parameters (estimated)                    │
│                                                                 │
│  Compute Requirements                                           │
│  └── Training large models is expensive                       │
│      • Single GPU: too slow                                   │
│      • 1000+ GPUs: weeks of training                          │
│      • Cost: millions of dollars                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Types of Distributed ML

```
┌─────────────────────────────────────────────────────────────────┐
│                    TYPES OF DISTRIBUTED ML                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Data Parallelism                                               │
│  └── Split data across workers                                 │
│      • Same model on each worker                              │
│      • Each worker processes different data                   │
│      • Synchronize gradients across workers                   │
│                                                                 │
│  Model Parallelism                                              │
│  └── Split model across workers                               │
│      • Different parts of model on each worker                │
│      • Data passes through all workers                        │
│      • For models that don't fit in memory                    │
│                                                                 │
│  Pipeline Parallelism                                           │
│  └── Split model by layer                                     │
│      • Different layers on different workers                  │
│      • Mini-batch pipelining                                  │
│      • Reduces idle time                                      │
│                                                                 │
│  Hybrid Parallelism                                             │
│  └── Combine multiple strategies                              │
│      • Data + Model parallelism                               │
│      • Model + Pipeline parallelism                           │
│      • All three together                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Distributed Training with PyTorch

### PyTorch Distributed Data Parallel (DDP)

```python
import torch
import torch.nn as nn
import torch.distributed as dist
import torch.multiprocessing as mp
from torch.nn.parallel import DistributedDataParallel as DDP
from torch.utils.data import DataLoader, DistributedSampler

def setup_distributed(rank, world_size):
    """Set up distributed environment."""
    dist.init_process_group("nccl", rank=rank, world_size=world_size)

def cleanup_distributed():
    """Clean up distributed environment."""
    dist.destroy_process_group()

def train_ddp(rank, world_size, model, dataset, batch_size=32, epochs=10):
    """
    Train model using DDP.
    
    Args:
        rank: Process rank
        world_size: Number of processes
        model: Model to train
        dataset: Training dataset
        batch_size: Batch size per worker
        epochs: Number of epochs
    """
    # Setup
    setup_distributed(rank, world_size)
    
    # Move model to device
    device = torch.device(f"cuda:{rank}" if torch.cuda.is_available() else "cpu")
    model = model.to(device)
    model = DDP(model, device_ids=[rank] if torch.cuda.is_available() else None)
    
    # Create distributed sampler
    sampler = DistributedSampler(
        dataset,
        num_replicas=world_size,
        rank=rank,
        shuffle=True
    )
    
    # Create dataloader
    dataloader = DataLoader(
        dataset,
        batch_size=batch_size,
        sampler=sampler,
        num_workers=4,
        pin_memory=True
    )
    
    # Setup optimizer and loss
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    criterion = nn.CrossEntropyLoss()
    
    # Training loop
    for epoch in range(epochs):
        sampler.set_epoch(epoch)  # Shuffle data each epoch
        
        model.train()
        total_loss = 0
        
        for batch_idx, (data, target) in enumerate(dataloader):
            data, target = data.to(device), target.to(device)
            
            optimizer.zero_grad()
            output = model(data)
            loss = criterion(output, target)
            loss.backward()
            optimizer.step()
            
            total_loss += loss.item()
            
            if rank == 0 and batch_idx % 100 == 0:
                print(f"Epoch {epoch}, Batch {batch_idx}, Loss: {loss.item():.4f}")
        
        if rank == 0:
            avg_loss = total_loss / len(dataloader)
            print(f"Epoch {epoch}, Average Loss: {avg_loss:.4f}")
    
    cleanup_distributed()

# Launch training
def launch_ddp_training(world_size, model, dataset):
    """Launch DDP training with multiple processes."""
    mp.spawn(
        train_ddp,
        args=(world_size, model, dataset),
        nprocs=world_size,
        join=True
    )

# Example usage
world_size = torch.cuda.device_count() if torch.cuda.is_available() else 1
model = MyModel()
dataset = MyDataset()
launch_ddp_training(world_size, model, dataset)
```

### PyTorch Fully Sharded Data Parallel (FSDP)

```python
from torch.distributed.fsdp import FullyShardedDataParallel as FSDP
from torch.distributed.fsdp.wrap import transformer_auto_wrap_policy
from transformers import AutoModel

def setup_fsdp_model(model, device_id):
    """
    Setup model with FSDP.
    
    Args:
        model: Model to wrap
        device_id: Device ID
    
    Returns:
        FSDP model
    """
    # Auto wrap policy for transformer models
    from transformers.models.llama.modeling_llama import LlamaDecoderLayer
    
    auto_wrap_policy = functools.partial(
        transformer_auto_wrap_policy,
        transformer_layer_cls={LlamaDecoderLayer}
    )
    
    # Wrap model with FSDP
    fsdp_model = FSDP(
        model,
        auto_wrap_policy=auto_wrap_policy,
        device_id=device_id,
        sharding_strategy=ShardingStrategy.FULL_SHARD,
        cpu_offload=CPUOffload(offload_params=False)
    )
    
    return fsdp_model

def train_fsdp():
    """Train with FSDP."""
    # Setup distributed
    dist.init_process_group("nccl")
    
    # Get local rank
    local_rank = int(os.environ['LOCAL_RANK'])
    device = torch.device(f"cuda:{local_rank}")
    torch.cuda.set_device(local_rank)
    
    # Load model
    model = AutoModel.from_pretrained("meta-llama/Llama-2-7b-hf")
    model = setup_fsdp_model(model, device)
    
    # Training loop (simplified)
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-4)
    
    for epoch in range(epochs):
        for batch in dataloader:
            # Forward pass
            outputs = model(batch)
            loss = outputs.loss
            
            # Backward pass
            loss.backward()
            optimizer.step()
            optimizer.zero_grad()
    
    dist.destroy_process_group()
```

### Horovod (Integration with TensorFlow/PyTorch)

```python
import horovod.torch as hvd
from horovod.torch import DistributedOptimizer

def train_horovod():
    """Train with Horovod."""
    # Initialize Horovod
    hvd.init()
    
    # Setup device
    device = torch.device(f"cuda:{hvd.local_rank()}" if torch.cuda.is_available() else "cpu")
    
    # Create model
    model = MyModel().to(device)
    
    # Broadcast initial parameters
    hvd.broadcast_parameters(model.state_dict(), root_rank=0)
    
    # Create optimizer with Horovod
    optimizer = hvd.DistributedOptimizer(
        torch.optim.Adam(model.parameters(), lr=0.001),
        named_parameters=model.named_parameters()
    )
    
    # Create dataloader with Horovod
    train_dataset = MyDataset()
    train_sampler = torch.utils.data.distributed.DistributedSampler(
        train_dataset,
        num_replicas=hvd.size(),
        rank=hvd.rank()
    )
    train_loader = DataLoader(
        train_dataset,
        batch_size=32,
        sampler=train_sampler
    )
    
    # Training loop
    for epoch in range(epochs):
        for batch_idx, (data, target) in enumerate(train_loader):
            data, target = data.to(device), target.to(device)
            
            optimizer.zero_grad()
            output = model(data)
            loss = loss_fn(output, target)
            loss.backward()
            optimizer.step()
            
            if hvd.rank() == 0 and batch_idx % 100 == 0:
                print(f"Epoch {epoch}, Batch {batch_idx}, Loss: {loss.item():.4f}")
```

---

## 3. Distributed Training with TensorFlow

### TensorFlow Distributed Strategy

```python
import tensorflow as tf

def train_tf_distributed():
    """Train with TensorFlow distributed strategy."""
    # Setup strategy
    strategy = tf.distribute.MirroredStrategy()
    
    with strategy.scope():
        # Create model within strategy scope
        model = tf.keras.Sequential([
            tf.keras.layers.Dense(128, activation='relu'),
            tf.keras.layers.Dropout(0.2),
            tf.keras.layers.Dense(10, activation='softmax')
        ])
        
        model.compile(
            optimizer='adam',
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )
    
    # Create dataset
    dataset = tf.data.Dataset.from_tensor_slices((x_train, y_train))
    dataset = dataset.shuffle(10000).batch(32).prefetch(tf.data.AUTOTUNE)
    
    # Training
    model.fit(dataset, epochs=10)
    
    return model

def train_tf_multi_gpu(num_gpus=2):
    """Train with multiple GPUs."""
    strategy = tf.distribute.MirroredStrategy(devices=[f"/gpu:{i}" for i in range(num_gpus)])
    
    with strategy.scope():
        model = create_model()
        model.compile(optimizer='adam', loss='sparse_categorical_crossentropy')
    
    # Use larger batch size
    batch_size = 64 * num_gpus
    
    dataset = create_dataset().batch(batch_size)
    
    model.fit(dataset, epochs=10)
```

### TensorFlow Parameter Server

```python
def train_tf_parameter_server():
    """Train with TensorFlow parameter server strategy."""
    # Setup cluster
    cluster = {
        'chief': ['host1:2222'],
        'worker': ['host2:2222', 'host3:2222'],
        'ps': ['host4:2222', 'host5:2222']
    }
    
    # Configure strategy
    strategy = tf.distribute.experimental.ParameterServerStrategy(
        cluster_resolver=cluster,
        variable_partitioner=tf.distribute.experimental.partitioners.MinSizePartitioner(100)
    )
    
    with strategy.scope():
        model = create_model()
        model.compile(optimizer='adam', loss='categorical_crossentropy')
    
    # Training
    model.fit(
        x_train,
        y_train,
        batch_size=32,
        epochs=10,
        validation_data=(x_test, y_test)
    )
```

---

## 4. Distributed Data Processing

### Apache Spark for ML

```python
from pyspark.sql import SparkSession
from pyspark.ml.feature import VectorAssembler, StandardScaler
from pyspark.ml.classification import RandomForestClassifier
from pyspark.ml.evaluation import MulticlassClassificationEvaluator

def spark_ml_pipeline():
    """ML pipeline with Apache Spark."""
    # Create Spark session
    spark = SparkSession.builder \
        .appName("ML Pipeline") \
        .config("spark.driver.memory", "4g") \
        .config("spark.executor.memory", "8g") \
        .getOrCreate()
    
    # Load data
    df = spark.read.parquet("data/processed/large_dataset.parquet")
    
    # Feature engineering
    feature_cols = ['feature1', 'feature2', 'feature3', 'feature4']
    assembler = VectorAssembler(inputCols=feature_cols, outputCol="features")
    
    # Scaling
    scaler = StandardScaler(inputCol="features", outputCol="scaled_features", withStd=True, withMean=True)
    
    # Model
    rf = RandomForestClassifier(
        featuresCol="scaled_features",
        labelCol="label",
        numTrees=100,
        maxDepth=10
    )
    
    # Pipeline
    from pyspark.ml import Pipeline
    pipeline = Pipeline(stages=[assembler, scaler, rf])
    
    # Train
    model = pipeline.fit(df)
    
    return model
```

### Dask for Distributed Pandas

```python
import dask.dataframe as dd
from dask.distributed import Client
from dask_ml.model_selection import train_test_split
from dask_ml.preprocessing import StandardScaler
from dask_ml.xgboost import XGBClassifier

def train_dask_xgboost():
    """Train XGBoost with Dask."""
    # Setup client
    client = Client(n_workers=4, threads_per_worker=2)
    
    # Load data
    ddf = dd.read_parquet("data/processed/large_dataset.parquet")
    
    # Split features and target
    X = ddf.drop('target', axis=1)
    y = ddf['target']
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # Scale features
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Train XGBoost
    model = XGBClassifier(
        n_estimators=100,
        max_depth=6,
        learning_rate=0.1,
        tree_method='hist',
        n_jobs=-1
    )
    
    model.fit(X_train_scaled, y_train)
    
    # Predict
    y_pred = model.predict(X_test_scaled)
    
    return model
```

### Ray for Distributed ML

```python
import ray
from ray import train, tune
from ray.train.xgboost import XGBoostTrainer
from ray.data import from_pandas

def train_ray_xgboost():
    """Train XGBoost with Ray."""
    # Initialize Ray
    ray.init(address='auto', ignore_reinit_error=True)
    
    # Load data
    dataset = from_pandas(df)
    
    # Split dataset
    train_ds, val_ds = dataset.train_test_split(test_size=0.2)
    
    # Trainer
    trainer = XGBoostTrainer(
        label_column='target',
        params={
            'objective': 'binary:logistic',
            'eval_metric': ['logloss', 'error'],
            'max_depth': 6,
            'eta': 0.1,
            'n_estimators': 100,
            'subsample': 0.8,
            'colsample_bytree': 0.8
        },
        datasets={
            'train': train_ds,
            'validation': val_ds
        },
        num_workers=4,
        use_gpu=True
    )
    
    # Train
    result = trainer.fit()
    
    # Get best model
    model = result.checkpoint.to_model()
    
    return model
```

---

## 5. Model Parallelism

### Tensor Parallelism

```python
import torch
import torch.nn as nn

class TensorParallelLinear(nn.Module):
    """Linear layer with tensor parallelism."""
    
    def __init__(self, in_features, out_features, num_partitions=2):
        super().__init__()
        self.num_partitions = num_partitions
        self.out_features_per_partition = out_features // num_partitions
        
        # Create partitioned weights
        self.weights = nn.ParameterList([
            nn.Parameter(torch.randn(in_features, self.out_features_per_partition))
            for _ in range(num_partitions)
        ])
        self.biases = nn.ParameterList([
            nn.Parameter(torch.randn(self.out_features_per_partition))
            for _ in range(num_partitions)
        ])
    
    def forward(self, x):
        # Process each partition
        outputs = []
        for i in range(self.num_partitions):
            out = torch.matmul(x, self.weights[i]) + self.biases[i]
            outputs.append(out)
        
        # Concatenate results
        return torch.cat(outputs, dim=-1)

class TensorParallelMLP(nn.Module):
    """MLP with tensor parallelism."""
    
    def __init__(self, input_dim, hidden_dim, output_dim, num_partitions=2):
        super().__init__()
        self.layer1 = TensorParallelLinear(input_dim, hidden_dim, num_partitions)
        self.layer2 = TensorParallelLinear(hidden_dim, output_dim, num_partitions)
        self.relu = nn.ReLU()
    
    def forward(self, x):
        x = self.relu(self.layer1(x))
        x = self.layer2(x)
        return x

# Usage
model = TensorParallelMLP(1000, 2048, 10, num_partitions=2)
```

### Pipeline Parallelism

```python
class PipelineParallelModel(nn.Module):
    """Model with pipeline parallelism."""
    
    def __init__(self, num_stages=4, device_ids=None):
        super().__init__()
        self.num_stages = num_stages
        self.device_ids = device_ids or [i for i in range(num_stages)]
        
        # Create stages
        self.stages = nn.ModuleList()
        for i in range(num_stages):
            stage = nn.Sequential(
                nn.Linear(256, 256),
                nn.ReLU(),
                nn.Dropout(0.1)
            )
            self.stages.append(stage.to(f"cuda:{self.device_ids[i]}"))
    
    def forward(self, x):
        # Process sequentially through stages
        for i, stage in enumerate(self.stages):
            x = x.to(f"cuda:{self.device_ids[i]}")
            x = stage(x)
        return x

def pipeline_parallel_training(model, dataloader, epochs=10):
    """Pipeline parallel training loop."""
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    criterion = nn.CrossEntropyLoss()
    
    for epoch in range(epochs):
        for batch_idx, (data, target) in enumerate(dataloader):
            # Forward pass through pipeline
            data = data.to("cuda:0")
            output = model(data)
            
            # Loss computation
            loss = criterion(output, target.to(output.device))
            
            # Backward pass through pipeline stages
            loss.backward()
            
            # Step optimizer
            optimizer.step()
            optimizer.zero_grad()
```

---

## 6. Distributed Inference

### Model Sharding

```python
def shard_model_for_inference(model, num_replicas):
    """
    Shard model for distributed inference.
    
    Args:
        model: Model to shard
        num_replicas: Number of replicas
    
    Returns:
        list: Sharded models
    """
    import copy
    
    # Split layers
    layers = list(model.children())
    layers_per_replica = len(layers) // num_replicas
    
    sharded_models = []
    for i in range(num_replicas):
        start_idx = i * layers_per_replica
        end_idx = (i + 1) * layers_per_replica if i < num_replicas - 1 else len(layers)
        
        shard = nn.Sequential(*layers[start_idx:end_idx])
        sharded_models.append(shard)
    
    return sharded_models

def distributed_inference(model_shards, input_batch):
    """
    Run inference across sharded models.
    
    Args:
        model_shards: List of sharded models
        input_batch: Input batch
    
    Returns:
        torch.Tensor: Inference results
    """
    x = input_batch
    for shard in model_shards:
        x = shard(x)
    return x
```

### Serving with Triton

```python
# triton_config.pbtxt
name: "ensemble_model"
platform: "ensemble"
max_batch_size: 256

input [
  {
    name: "INPUT"
    data_type: TYPE_FP32
    dims: [ -1 ]
  }
]
output [
  {
    name: "OUTPUT"
    data_type: TYPE_FP32
    dims: [ -1 ]
  }
]

ensemble_scheduling {
  step [
    {
      model_name: "preprocessing"
      model_version: -1
      input_map { key: "INPUT" value: "INPUT" }
      output_map { key: "OUTPUT" value: "preprocessed" }
    },
    {
      model_name: "model"
      model_version: -1
      input_map { key: "INPUT" value: "preprocessed" }
      output_map { key: "OUTPUT" value: "predictions" }
    },
    {
      model_name: "postprocessing"
      model_version: -1
      input_map { key: "INPUT" value: "predictions" }
      output_map { key: "OUTPUT" value: "OUTPUT" }
    }
  ]
}
```

---

## Quick Reference: Distributed ML

### Frameworks Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│  FRAMEWORK   │ DATA PARALLEL │ MODEL PARALLEL │ EASE OF USE  │
├──────────────┼───────────────┼────────────────┼──────────────┤
│  PyTorch     │ Excellent     │ Good           │ Excellent    │
│  TensorFlow  │ Excellent     │ Good           │ Good         │
│  Horovod     │ Excellent     │ Limited        │ Good         │
│  Ray         │ Excellent     │ Good           │ Excellent    │
│  Spark       │ Excellent     │ Limited        │ Good         │
│  Dask        │ Excellent     │ Limited        │ Good         │
└─────────────────────────────────────────────────────────────────┘
```

### Scaling Strategies

```
┌─────────────────────────────────────────────────────────────────┐
│  STRATEGY    │ SCALABILITY │ MEMORY │ COMMUNICATION │          │
├──────────────┼─────────────┼────────┼───────────────┤          │
│  DDP         │ Linear      │ High   │ High          │          │
│  FSDP        │ Near Linear │ Low    │ High          │          │
│  Tensor      │ Sub-linear  │ Low    │ Low           │          │
│  Pipeline    │ Sub-linear  │ Low    │ Medium        │          │
│  Hybrid      │ Super-linear│ Low    │ High          │          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers the essential concepts of distributed machine learning. You now understand:

1. **Why distributed ML matters**: Scale challenges, data and model growth
2. **Types of parallelism**: Data, model, pipeline, hybrid
3. **PyTorch distributed**: DDP, FSDP, Horovod
4. **TensorFlow distributed**: MirroredStrategy, Parameter Server
5. **Distributed data processing**: Spark, Dask, Ray
6. **Model parallelism**: Tensor, pipeline
7. **Distributed inference**: Sharding, Triton

**Next Steps:**
1. Practice with DDP on multiple GPUs
2. Experiment with FSDP for large models
3. Try distributed data processing with Spark
4. Deploy models with distributed inference
5. Proceed to Part 1 of the series

---

*End of Primer 16*

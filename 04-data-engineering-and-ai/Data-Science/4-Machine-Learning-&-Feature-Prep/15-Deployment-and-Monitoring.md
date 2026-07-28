# Phase 4 Capstone: The End-to-End Predictive Pipeline

## Part 15: Deployment and Monitoring

Welcome to the final part of our series! We've built an entire machine learning pipeline from scratch—data ingestion, validation, feature engineering, model training, hyperparameter optimization, and a complete capstone project. Now we cross the finish line: deploying our model to production and monitoring its performance over time.

### The Target: A Production-Ready API and Monitoring System

By the end of this part, you'll have:
1. A FastAPI application serving predictions
2. Docker containerization for the API
3. Model versioning and management
4. Performance monitoring and drift detection
5. Logging and alerting
6. A complete deployment script
7. Health checks and testing
8. Production-ready documentation

### The Concept: From Model to Production

Think of deploying a model like launching a spacecraft:

**Development**: Building and testing in the lab (our notebooks and scripts)

**Deployment**: Launching into orbit (API endpoints)

**Monitoring**: Tracking performance and health (telemetry)

**Maintenance**: Regular updates and fixes (model retraining)

The goal is not just to deploy once, but to create a system that can be maintained, updated, and monitored continuously.

### The Implementation: Building the Deployment System

#### Step 1: The FastAPI Application

**File:** `src/api/app.py`
**Path:** `ml-pipeline-project/src/api/app.py`

```python
"""
FastAPI application for serving ML predictions.

This module provides:
- REST API endpoints for predictions
- Health checks
- Model management
- Request/response validation
- Comprehensive logging
"""

from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any, Union
import pandas as pd
import numpy as np
from loguru import logger
from pathlib import Path
import sys
import json
import time
from datetime import datetime

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from src.pipeline.builder import MLPipeline

# Create FastAPI app
app = FastAPI(
    title="Customer Churn Prediction API",
    description="API for predicting customer churn using the ML pipeline",
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global variables
_model = None
_model_info = {}
_model_loaded = False
_pipeline_path = "models/churn_pipeline.joblib"

# Request/Response Models
class PredictionRequest(BaseModel):
    """Request model for predictions."""
    features: Dict[str, Any] = Field(..., description="Feature values for prediction")
    
    class Config:
        schema_extra = {
            "example": {
                "features": {
                    "gender": "Female",
                    "SeniorCitizen": "0",
                    "Partner": "Yes",
                    "Dependents": "No",
                    "tenure": 12,
                    "PhoneService": "Yes",
                    "MultipleLines": "No",
                    "InternetService": "Fiber optic",
                    "OnlineSecurity": "No",
                    "OnlineBackup": "No",
                    "DeviceProtection": "No",
                    "TechSupport": "No",
                    "StreamingTV": "No",
                    "StreamingMovies": "No",
                    "Contract": "Month-to-month",
                    "PaperlessBilling": "Yes",
                    "PaymentMethod": "Electronic check",
                    "MonthlyCharges": 70.0,
                    "TotalCharges": 850.0
                }
            }
        }

class BatchPredictionRequest(BaseModel):
    """Request model for batch predictions."""
    features: List[Dict[str, Any]] = Field(..., description="List of feature dictionaries")

class PredictionResponse(BaseModel):
    """Response model for predictions."""
    prediction: Union[int, float]
    probability: Optional[float] = None
    timestamp: str
    model_version: str
    status: str

class BatchPredictionResponse(BaseModel):
    """Response model for batch predictions."""
    predictions: List[Union[int, float]]
    probabilities: Optional[List[float]] = None
    count: int
    timestamp: str
    model_version: str
    status: str

class HealthResponse(BaseModel):
    """Response model for health checks."""
    status: str
    model_loaded: bool
    model_version: Optional[str] = None
    timestamp: str
    uptime_seconds: float

# Model management functions
def load_model():
    """Load the ML model from disk."""
    global _model, _model_info, _model_loaded
    
    logger.info(f"Loading model from: {_pipeline_path}")
    
    try:
        # Load pipeline
        _model = MLPipeline(config={})
        _model.load(_pipeline_path)
        _model_loaded = True
        
        # Get model info
        summary = _model.get_summary()
        _model_info = {
            "version": "1.0.0",
            "model_type": summary.get('model_type', 'unknown'),
            "task": summary.get('task', 'unknown'),
            "features": summary.get('feature_names', []),
            "trained": summary.get('is_trained', False),
            "best_params": summary.get('best_params', {})
        }
        
        logger.info(f"Model loaded successfully: {_model_info['model_type']}")
        return True
        
    except Exception as e:
        logger.error(f"Failed to load model: {str(e)}")
        _model_loaded = False
        return False

def get_model():
    """Get the loaded model."""
    global _model, _model_loaded
    if not _model_loaded:
        load_model()
    if not _model_loaded:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Model not loaded"
        )
    return _model

@app.on_event("startup")
async def startup_event():
    """Load the model on startup."""
    logger.info("Starting up API...")
    load_model()

# API Endpoints
@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "message": "Customer Churn Prediction API",
        "version": "1.0.0",
        "docs": "/api/docs",
        "health": "/api/health"
    }

@app.get("/api/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint."""
    global _model_loaded, _model_info
    
    return HealthResponse(
        status="healthy" if _model_loaded else "unhealthy",
        model_loaded=_model_loaded,
        model_version=_model_info.get("version") if _model_info else None,
        timestamp=datetime.now().isoformat(),
        uptime_seconds=time.time() - startup_time if hasattr(app, 'startup_time') else 0
    )

@app.get("/api/model/info")
async def model_info():
    """Get model information."""
    if not _model_loaded:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    return {
        "model": _model_info,
        "loaded": _model_loaded
    }

@app.post("/api/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    """
    Make a single prediction.
    
    Args:
        request: Prediction request with features
        
    Returns:
        PredictionResponse: Prediction result
    """
    start_time = time.time()
    model = get_model()
    
    try:
        # Convert features to DataFrame
        df = pd.DataFrame([request.features])
        
        # Make prediction
        prediction = model.predict(df)
        prediction = int(prediction[0]) if len(prediction) > 0 else 0
        
        # Get probability if available
        probability = None
        try:
            proba = model.predict(df, return_proba=True)
            if proba is not None and len(proba) > 0:
                if len(proba.shape) > 1 and proba.shape[1] == 2:
                    probability = float(proba[0][1])
                else:
                    probability = float(proba[0])
        except:
            pass
        
        logger.info(f"Prediction made in {time.time() - start_time:.3f}s")
        
        return PredictionResponse(
            prediction=prediction,
            probability=probability,
            timestamp=datetime.now().isoformat(),
            model_version=_model_info.get("version", "unknown"),
            status="success"
        )
        
    except Exception as e:
        logger.error(f"Prediction failed: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Prediction failed: {str(e)}"
        )

@app.post("/api/predict/batch", response_model=BatchPredictionResponse)
async def predict_batch(request: BatchPredictionRequest):
    """
    Make batch predictions.
    
    Args:
        request: Batch prediction request
        
    Returns:
        BatchPredictionResponse: Batch prediction results
    """
    start_time = time.time()
    model = get_model()
    
    try:
        # Convert features to DataFrame
        df = pd.DataFrame(request.features)
        
        # Make predictions
        predictions = model.predict(df)
        predictions = [int(p) for p in predictions]
        
        # Get probabilities
        probabilities = None
        try:
            proba = model.predict(df, return_proba=True)
            if proba is not None:
                if len(proba.shape) > 1 and proba.shape[1] == 2:
                    probabilities = [float(p[1]) for p in proba]
                else:
                    probabilities = [float(p) for p in proba]
        except:
            pass
        
        logger.info(f"Batch prediction made in {time.time() - start_time:.3f}s for {len(predictions)} samples")
        
        return BatchPredictionResponse(
            predictions=predictions,
            probabilities=probabilities,
            count=len(predictions),
            timestamp=datetime.now().isoformat(),
            model_version=_model_info.get("version", "unknown"),
            status="success"
        )
        
    except Exception as e:
        logger.error(f"Batch prediction failed: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Batch prediction failed: {str(e)}"
        )

# Store startup time
startup_time = time.time()

# Run the app
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "src.api.app:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )
```

#### Step 2: Docker Configuration

**File:** `Dockerfile`
**Path:** `ml-pipeline-project/Dockerfile`

```dockerfile
# Dockerfile for ML Pipeline API

FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (for better caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p data/raw data/processed data/external models logs reports

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/api/health')" || exit 1

# Run the application
CMD ["uvicorn", "src.api.app:app", "--host", "0.0.0.0", "--port", "8000"]
```

**File:** `docker-compose.yml`
**Path:** `ml-pipeline-project/docker-compose.yml`

```yaml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      - ENVIRONMENT=production
      - LOG_LEVEL=INFO
    volumes:
      - ./models:/app/models
      - ./logs:/app/logs
      - ./data:/app/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Monitoring service (optional)
  # prometheus:
  #   image: prom/prometheus
  #   ports:
  #     - "9090:9090"
  #   volumes:
  #     - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
  #     - prometheus_data:/prometheus
  #   restart: unless-stopped

volumes:
  prometheus_data:
```

#### Step 3: Monitoring and Logging

**File:** `src/api/monitoring.py`
**Path:** `ml-pipeline-project/src/api/monitoring.py`

```python
"""
Monitoring and logging for the deployed model.

This module provides:
- Performance tracking
- Drift detection
- Logging utilities
- Alerting
"""

import json
import time
from pathlib import Path
from datetime import datetime
import pandas as pd
import numpy as np
from loguru import logger
from typing import Dict, List, Optional, Any
import pickle

class ModelMonitor:
    """
    Monitor deployed model performance and detect drift.
    
    This class tracks:
    - Prediction distributions
    - Feature distributions (data drift)
    - Performance metrics (when ground truth is available)
    - System metrics (latency, throughput)
    """
    
    def __init__(self, log_dir: str = "logs/monitoring"):
        """
        Initialize the monitor.
        
        Args:
            log_dir: Directory to store monitoring logs
        """
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(parents=True, exist_ok=True)
        
        # Initialize metrics
        self.prediction_history = []
        self.feature_history = []
        self.performance_history = []
        self.latency_history = []
        
        logger.info(f"ModelMonitor initialized with log_dir={log_dir}")
    
    def log_prediction(
        self,
        features: Dict[str, Any],
        prediction: Any,
        probability: Optional[float] = None,
        latency_ms: Optional[float] = None
    ):
        """
        Log a prediction request and response.
        
        Args:
            features: Input features
            prediction: Prediction output
            probability: Prediction probability (if available)
            latency_ms: Request latency in milliseconds
        """
        entry = {
            "timestamp": datetime.now().isoformat(),
            "features": features,
            "prediction": prediction,
            "probability": probability,
            "latency_ms": latency_ms
        }
        
        self.prediction_history.append(entry)
        
        # Log to file
        log_file = self.log_dir / f"predictions_{datetime.now().strftime('%Y%m%d')}.jsonl"
        with open(log_file, 'a') as f:
            json.dump(entry, f)
            f.write('\n')
        
        # Track latency
        if latency_ms is not None:
            self.latency_history.append(latency_ms)
    
    def log_ground_truth(self, prediction_id: str, true_value: Any):
        """
        Log ground truth for a previous prediction.
        
        Args:
            prediction_id: Identifier for the prediction
            true_value: True target value
        """
        # Implementation would depend on how predictions are tracked
        pass
    
    def detect_drift(
        self,
        reference_data: pd.DataFrame,
        current_data: pd.DataFrame,
        threshold: float = 0.05
    ) -> Dict[str, Any]:
        """
        Detect data drift between reference and current data.
        
        Args:
            reference_data: Reference data distribution
            current_data: Current data distribution
            threshold: Significance threshold for drift detection
            
        Returns:
            Dict: Drift detection results
        """
        from scipy import stats
        
        results = {
            "drift_detected": False,
            "features_with_drift": [],
            "drift_scores": {}
        }
        
        # For each numeric feature, perform KS test
        numeric_cols = current_data.select_dtypes(include=[np.number]).columns
        
        for col in numeric_cols:
            if col in reference_data.columns:
                ref_values = reference_data[col].dropna()
                cur_values = current_data[col].dropna()
                
                if len(ref_values) > 0 and len(cur_values) > 0:
                    # Kolmogorov-Smirnov test
                    ks_stat, p_value = stats.ks_2samp(ref_values, cur_values)
                    
                    results["drift_scores"][col] = {
                        "ks_stat": ks_stat,
                        "p_value": p_value,
                        "drift_detected": p_value < threshold
                    }
                    
                    if p_value < threshold:
                        results["features_with_drift"].append(col)
                        results["drift_detected"] = True
        
        # For categorical features, perform chi-square test
        cat_cols = current_data.select_dtypes(include=['object', 'category']).columns
        
        for col in cat_cols:
            if col in reference_data.columns:
                ref_values = reference_data[col].dropna()
                cur_values = current_data[col].dropna()
                
                if len(ref_values) > 0 and len(cur_values) > 0:
                    # Chi-square test
                    # Get value counts
                    ref_counts = ref_values.value_counts()
                    cur_counts = cur_values.value_counts()
                    
                    # Align categories
                    all_categories = set(ref_counts.index) | set(cur_counts.index)
                    ref_aligned = [ref_counts.get(cat, 0) for cat in all_categories]
                    cur_aligned = [cur_counts.get(cat, 0) for cat in all_categories]
                    
                    if sum(ref_aligned) > 0 and sum(cur_aligned) > 0:
                        chi2, p_value = stats.chisquare(cur_aligned, f_exp=ref_aligned)
                        
                        results["drift_scores"][col] = {
                            "chi2": chi2,
                            "p_value": p_value,
                            "drift_detected": p_value < threshold
                        }
                        
                        if p_value < threshold:
                            results["features_with_drift"].append(col)
                            results["drift_detected"] = True
        
        return results
    
    def get_performance_summary(self) -> Dict[str, Any]:
        """
        Get a summary of prediction performance.
        
        Returns:
            Dict: Performance summary
        """
        summary = {
            "total_predictions": len(self.prediction_history),
            "last_prediction": self.prediction_history[-1] if self.prediction_history else None,
            "latency": {
                "mean": np.mean(self.latency_history) if self.latency_history else None,
                "p95": np.percentile(self.latency_history, 95) if self.latency_history else None,
                "p99": np.percentile(self.latency_history, 99) if self.latency_history else None
            },
            "prediction_distribution": None
        }
        
        # Compute prediction distribution
        if self.prediction_history:
            predictions = [p['prediction'] for p in self.prediction_history]
            pred_df = pd.Series(predictions)
            summary["prediction_distribution"] = pred_df.value_counts().to_dict()
        
        return summary
    
    def generate_report(self, output_path: Optional[Path] = None) -> Dict[str, Any]:
        """
        Generate a monitoring report.
        
        Args:
            output_path: Path to save the report
            
        Returns:
            Dict: Monitoring report
        """
        report = {
            "timestamp": datetime.now().isoformat(),
            "summary": self.get_performance_summary(),
            "metrics": {
                "total_requests": len(self.prediction_history),
                "avg_latency_ms": np.mean(self.latency_history) if self.latency_history else None
            }
        }
        
        if output_path:
            with open(output_path, 'w') as f:
                json.dump(report, f, indent=2)
            logger.info(f"Report saved to: {output_path}")
        
        return report

# Global monitor instance
monitor = ModelMonitor()
```

#### Step 4: Deployment Script

**File:** `scripts/deploy.sh`
**Path:** `ml-pipeline-project/scripts/deploy.sh`

```bash
#!/bin/bash

# Deployment script for the ML pipeline API

set -e

echo "=========================================="
echo "ML Pipeline Deployment Script"
echo "=========================================="

# Configuration
APP_NAME="ml-pipeline-api"
IMAGE_NAME="ml-pipeline-api"
PORT=8000
ENVIRONMENT=${1:-production}

echo "Environment: $ENVIRONMENT"
echo "Port: $PORT"

# Check if model exists
if [ ! -f "models/churn_pipeline.joblib" ]; then
    echo "ERROR: Model not found at models/churn_pipeline.joblib"
    echo "Please train the model first with: python capstone/train_churn_model.py"
    exit 1
fi

echo "Model found: models/churn_pipeline.joblib"

# Stop existing container if running
if docker ps -a | grep -q $APP_NAME; then
    echo "Stopping existing container..."
    docker stop $APP_NAME 2>/dev/null || true
    docker rm $APP_NAME 2>/dev/null || true
fi

# Build Docker image
echo "Building Docker image..."
docker build -t $IMAGE_NAME .

# Run container
echo "Starting container..."
docker run -d \
    --name $APP_NAME \
    -p $PORT:$PORT \
    -v $(pwd)/models:/app/models \
    -v $(pwd)/logs:/app/logs \
    -e ENVIRONMENT=$ENVIRONMENT \
    --restart unless-stopped \
    $IMAGE_NAME

# Wait for container to be ready
echo "Waiting for container to be ready..."
sleep 5

# Check health
echo "Checking health..."
if curl -s -f "http://localhost:$PORT/api/health" > /dev/null; then
    echo "✅ Container is healthy!"
    echo "API available at: http://localhost:$PORT"
    echo "API docs at: http://localhost:$PORT/api/docs"
else
    echo "❌ Container health check failed"
    echo "Check logs with: docker logs $APP_NAME"
    exit 1
fi

echo "=========================================="
echo "Deployment complete!"
echo "=========================================="
```

#### Step 5: Test Client

**File:** `scripts/test_api.py`
**Path:** `ml-pipeline-project/scripts/test_api.py`

```python
"""
Test client for the deployed API.
"""

import requests
import json
import time
import random
import pandas as pd
from typing import Dict, Any
from loguru import logger

API_URL = "http://localhost:8000"

def test_health():
    """Test the health endpoint."""
    logger.info("Testing health endpoint...")
    response = requests.get(f"{API_URL}/api/health")
    logger.info(f"Status: {response.status_code}")
    logger.info(f"Response: {response.json()}")
    return response.status_code == 200

def test_predict():
    """Test the prediction endpoint."""
    logger.info("\nTesting prediction endpoint...")
    
    # Sample customer data
    sample_data = {
        "gender": "Female",
        "SeniorCitizen": "0",
        "Partner": "Yes",
        "Dependents": "No",
        "tenure": 12,
        "PhoneService": "Yes",
        "MultipleLines": "No",
        "InternetService": "Fiber optic",
        "OnlineSecurity": "No",
        "OnlineBackup": "No",
        "DeviceProtection": "No",
        "TechSupport": "No",
        "StreamingTV": "No",
        "StreamingMovies": "No",
        "Contract": "Month-to-month",
        "PaperlessBilling": "Yes",
        "PaymentMethod": "Electronic check",
        "MonthlyCharges": 70.0,
        "TotalCharges": 850.0
    }
    
    payload = {"features": sample_data}
    
    start_time = time.time()
    response = requests.post(
        f"{API_URL}/api/predict",
        json=payload
    )
    elapsed = time.time() - start_time
    
    logger.info(f"Status: {response.status_code}")
    logger.info(f"Time: {elapsed:.3f}s")
    
    if response.status_code == 200:
        result = response.json()
        logger.info(f"Prediction: {result['prediction']}")
        logger.info(f"Probability: {result.get('probability')}")
        logger.info(f"Model Version: {result.get('model_version')}")
        return True
    else:
        logger.error(f"Error: {response.text}")
        return False

def test_batch_predict():
    """Test the batch prediction endpoint."""
    logger.info("\nTesting batch prediction endpoint...")
    
    # Sample multiple customers
    sample_data = []
    for i in range(10):
        data = {
            "gender": random.choice(["Female", "Male"]),
            "SeniorCitizen": str(random.choice([0, 1])),
            "Partner": random.choice(["Yes", "No"]),
            "Dependents": random.choice(["Yes", "No"]),
            "tenure": random.randint(1, 72),
            "PhoneService": "Yes",
            "MultipleLines": random.choice(["Yes", "No"]),
            "InternetService": random.choice(["Fiber optic", "DSL", "No"]),
            "OnlineSecurity": random.choice(["Yes", "No"]),
            "OnlineBackup": random.choice(["Yes", "No"]),
            "DeviceProtection": random.choice(["Yes", "No"]),
            "TechSupport": random.choice(["Yes", "No"]),
            "StreamingTV": random.choice(["Yes", "No"]),
            "StreamingMovies": random.choice(["Yes", "No"]),
            "Contract": random.choice(["Month-to-month", "One year", "Two year"]),
            "PaperlessBilling": random.choice(["Yes", "No"]),
            "PaymentMethod": random.choice(["Electronic check", "Mailed check", "Bank transfer (automatic)", "Credit card (automatic)"]),
            "MonthlyCharges": random.uniform(20, 120),
            "TotalCharges": random.uniform(100, 6000)
        }
        sample_data.append(data)
    
    payload = {"features": sample_data}
    
    start_time = time.time()
    response = requests.post(
        f"{API_URL}/api/predict/batch",
        json=payload
    )
    elapsed = time.time() - start_time
    
    logger.info(f"Status: {response.status_code}")
    logger.info(f"Time: {elapsed:.3f}s")
    
    if response.status_code == 200:
        result = response.json()
        logger.info(f"Predictions: {len(result['predictions'])}")
        logger.info(f"Sample predictions: {result['predictions'][:5]}")
        return True
    else:
        logger.error(f"Error: {response.text}")
        return False

def main():
    """Run all tests."""
    logger.info("="*60)
    logger.info("API Test Client")
    logger.info("="*60)
    
    # Check if API is running
    try:
        response = requests.get(f"{API_URL}/api/health", timeout=5)
        logger.info("API is running!")
    except:
        logger.error("API is not running. Start with: docker-compose up -d")
        return
    
    # Run tests
    tests = [
        ("Health Check", test_health),
        ("Single Prediction", test_predict),
        ("Batch Prediction", test_batch_predict)
    ]
    
    passed = 0
    for name, test_fn in tests:
        logger.info(f"\n{'='*40}")
        logger.info(f"Test: {name}")
        logger.info(f"{'='*40}")
        
        try:
            if test_fn():
                passed += 1
                logger.info(f"✅ {name} passed")
            else:
                logger.error(f"❌ {name} failed")
        except Exception as e:
            logger.error(f"❌ {name} failed with error: {str(e)}")
    
    logger.info(f"\n{'='*60}")
    logger.info(f"Tests passed: {passed}/{len(tests)}")
    logger.info(f"{'='*60}")

if __name__ == "__main__":
    main()
```

### The Verification: Testing the Deployment

#### Step 1: Start the API

```bash
# Using Docker
docker-compose up -d

# Or using the deployment script
./scripts/deploy.sh

# Or directly with Python
python src/api/app.py
```

#### Step 2: Test the API

```bash
# Test the health endpoint
curl -s http://localhost:8000/api/health | python -m json.tool

# Test model info
curl -s http://localhost:8000/api/model/info | python -m json.tool

# Test a prediction
curl -X POST http://localhost:8000/api/predict \
  -H "Content-Type: application/json" \
  -d '{
    "features": {
      "gender": "Female",
      "SeniorCitizen": "0",
      "Partner": "Yes",
      "Dependents": "No",
      "tenure": 12,
      "PhoneService": "Yes",
      "MultipleLines": "No",
      "InternetService": "Fiber optic",
      "OnlineSecurity": "No",
      "OnlineBackup": "No",
      "DeviceProtection": "No",
      "TechSupport": "No",
      "StreamingTV": "No",
      "StreamingMovies": "No",
      "Contract": "Month-to-month",
      "PaperlessBilling": "Yes",
      "PaymentMethod": "Electronic check",
      "MonthlyCharges": 70.0,
      "TotalCharges": 850.0
    }
  }' | python -m json.tool

# Run the test client
python scripts/test_api.py
```

### What Just Happened: Understanding Deployment

#### The Deployment Architecture

Our deployment system consists of:

1. **FastAPI Application**: Handles HTTP requests and responses
2. **Model Pipeline**: Loads the trained model and makes predictions
3. **Docker Container**: Packages everything for consistent deployment
4. **Monitoring System**: Tracks performance and detects drift
5. **Health Checks**: Ensures the system is running properly

#### Key Design Decisions

**Why FastAPI?**
- Fast and modern (async support)
- Automatic OpenAPI documentation
- Built-in validation with Pydantic
- Easy to test and debug

**Why Docker?**
- Consistent environment
- Easy deployment
- Scalability
- Isolation

**Why Monitoring?**
- Detect performance degradation
- Identify data drift
- Track business impact
- Enable proactive maintenance

### Summary

In this final part, we've:

1. **Created a FastAPI application** for serving predictions
2. **Dockerized the application** for production deployment
3. **Added health checks** and monitoring
4. **Implemented request/response validation** with Pydantic
5. **Built a test client** for verifying the API
6. **Created deployment scripts** for easy deployment

### The Complete Journey

Over this 15-part series, we've built a complete production-grade machine learning pipeline from scratch:

1. **Project Setup** - Professional structure and dependencies
2. **Data Validation** - Schema enforcement and quality checks
3. **EDA** - Understanding data through visualization
4. **Imputation & Scaling** - Handling missing values and scaling
5. **Categorical Encoding** - Converting categories to numbers
6. **Feature Creation** - Building new features
7. **Dimensionality Reduction** - Reducing feature space
8. **Tree-Based Models** - Random Forest, XGBoost, LightGBM, CatBoost
9. **Unsupervised Learning** - Clustering and discovery
10. **Deep Learning** - Neural networks with PyTorch
11. **Cross-Validation** - Robust evaluation
12. **Hyperparameter Tuning** - Optimizing with Optuna
13. **Pipeline Construction** - Integrating everything
14. **Capstone Project** - Real-world application
15. **Deployment** - Production API

You now have the skills to build, deploy, and monitor production-grade machine learning systems. This is a rare and valuable skill set that puts you in the top tier of data science practitioners.

---

[COMPLETED: Part 15: Deployment and Monitoring]
[COMPLETED: Phase 4 Capstone]
[COMPLETED: Entire Series]

---

# Congratulations!

You've completed the entire "Mastering Machine Learning & Predictive Modeling: An End-to-End Pipeline Series"! You've built a complete, production-grade machine learning system from the ground up.

## What You've Accomplished

- ✅ Built a professional Python project structure
- ✅ Implemented data ingestion and validation
- ✅ Mastered exploratory data analysis
- ✅ Created advanced feature engineering pipelines
- ✅ Trained multiple model types (tree-based, deep learning)
- ✅ Implemented comprehensive validation and evaluation
- ✅ Performed hyperparameter optimization
- ✅ Built an end-to-end predictive pipeline
- ✅ Applied everything to a real-world capstone project
- ✅ Deployed the model as a production API

## Next Steps

1. **Practice on new datasets**: Apply what you've learned to different problems
2. **Explore advanced techniques**: Experiment with more complex models
3. **Optimize for performance**: Profile and optimize your code
4. **Build a portfolio**: Showcase your projects
5. **Share your knowledge**: Write about what you've learned
6. **Contribute to open source**: Give back to the community

## Final Words

Machine learning is a journey, not a destination. The field evolves rapidly, and there's always more to learn. But you now have a solid foundation that will serve you well as you continue to grow.

Thank you for following along with this comprehensive series. Your dedication to learning these skills puts you on a path to becoming an exceptional data scientist and machine learning engineer.

Happy building! 🚀

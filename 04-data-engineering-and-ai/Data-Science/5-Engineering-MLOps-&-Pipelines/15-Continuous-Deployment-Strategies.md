# Part 15: Continuous Deployment Strategies

## The Target: Production-Ready CI/CD for MLOps

In this final part, we'll implement continuous deployment strategies for our MLOps pipeline, including CI/CD pipelines, automated testing, blue-green deployments, and rollback capabilities. By the end, you'll have a production-grade deployment system.

## The Concept: MLOps CI/CD

Think of CI/CD like an automated airline:
- **Continuous Integration (CI)** = Pre-flight checks (testing code, data validation)
- **Continuous Delivery (CD)** = Boarding process (automated deployment to staging)
- **Continuous Deployment** = Takeoff (automatic deployment to production)
- **Blue-Green Deployment** = Two runways (zero-downtime switching)
- **Rollback** = Emergency landing (quickly revert to previous version)

## The Implementation: CI/CD System

### Step 1: Create GitHub Actions CI/CD Pipeline

```bash
cat > .github/workflows/mlops_ci_cd.yaml << 'EOF'
name: MLOps CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight

env:
  PYTHON_VERSION: '3.10'
  DVC_REMOTE: s3://mlops-pipeline-data
  MLFLOW_TRACKING_URI: http://mlflow-server:5000

jobs:
  # ============= TESTING =============
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        test_type: [unit, integration, e2e]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install pytest pytest-cov pytest-xdist
    
    - name: Run tests
      run: |
        if [ "${{ matrix.test_type }}" == "unit" ]; then
          pytest tests/unit -v --cov=src --cov-report=html --cov-report=xml
        elif [ "${{ matrix.test_type }}" == "integration" ]; then
          pytest tests/integration -v --cov=src --cov-report=html --cov-report=xml
        else
          pytest tests/e2e -v
        fi
    
    - name: Upload coverage report
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
        flags: ${{ matrix.test_type }}
        name: codecov-${{ matrix.test_type }}
    
    - name: Upload test results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-results-${{ matrix.test_type }}
        path: |
          htmlcov/
          pytest_report.html

  # ============= DATA VALIDATION =============
  validate_data:
    runs-on: ubuntu-latest
    needs: [test]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}
    
    - name: Install dependencies
      run: pip install -r requirements.txt
    
    - name: Setup DVC
      run: |
        dvc remote add --default s3_remote ${{ env.DVC_REMOTE }}
        dvc remote modify s3_remote access_key_id ${{ secrets.AWS_ACCESS_KEY_ID }}
        dvc remote modify s3_remote secret_access_key ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    
    - name: Pull data
      run: dvc pull
    
    - name: Validate data
      run: |
        python scripts/validate_data.py \
          --schema configs/data_schema.json \
          --threshold 0.05
    
    - name: Upload validation report
      uses: actions/upload-artifact@v3
      with:
        name: data-validation-report
        path: data/validation_report.json

  # ============= MODEL TRAINING =============
  train_model:
    runs-on: ubuntu-latest
    needs: [validate_data]
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}
    
    - name: Install dependencies
      run: pip install -r requirements.txt
    
    - name: Setup DVC
      run: |
        dvc remote add --default s3_remote ${{ env.DVC_REMOTE }}
        dvc remote modify s3_remote access_key_id ${{ secrets.AWS_ACCESS_KEY_ID }}
        dvc remote modify s3_remote secret_access_key ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    
    - name: Setup MLflow
      run: |
        export MLFLOW_TRACKING_URI=${{ env.MLFLOW_TRACKING_URI }}
    
    - name: Pull data
      run: dvc pull
    
    - name: Train model
      run: |
        python models/training/train_with_registry.py \
          --features data/processed/master_features.csv \
          --experiment "CI_CD_Pipeline" \
          --model_name "ci_cd_model" \
          --auto-stage
    
    - name: Upload model
      uses: actions/upload-artifact@v3
      with:
        name: trained-model
        path: models/registry/

  # ============= MODEL EVALUATION =============
  evaluate_model:
    runs-on: ubuntu-latest
    needs: [train_model]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}
    
    - name: Install dependencies
      run: pip install -r requirements.txt
    
    - name: Download model
      uses: actions/download-artifact@v3
      with:
        name: trained-model
        path: models/registry/
    
    - name: Evaluate model
      run: |
        python models/training/evaluate_model.py \
          --model models/registry/ci_cd_model.pkl \
          --features data/processed/master_features.csv \
          --output models/evaluation/ci_cd_report
    
    - name: Check performance
      run: |
        python scripts/check_model_performance.py \
          --report models/evaluation/ci_cd_report/summary.json \
          --threshold 0.85
    
    - name: Upload evaluation report
      uses: actions/upload-artifact@v3
      with:
        name: evaluation-report
        path: models/evaluation/ci_cd_report/

  # ============= STAGING DEPLOYMENT =============
  deploy_staging:
    runs-on: ubuntu-latest
    needs: [evaluate_model]
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    environment: staging
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}
    
    - name: Install dependencies
      run: pip install -r requirements.txt
    
    - name: Download model
      uses: actions/download-artifact@v3
      with:
        name: trained-model
        path: models/registry/
    
    - name: Deploy to staging
      run: |
        python scripts/deploy_model.py \
          --model models/registry/ci_cd_model.pkl \
          --environment staging \
          --endpoint http://staging-api.example.com
    
    - name: Test staging endpoint
      run: |
        python scripts/test_deployment.py \
          --endpoint http://staging-api.example.com/predict \
          --data tests/data/sample_input.json

  # ============= PRODUCTION DEPLOYMENT =============
  deploy_production:
    runs-on: ubuntu-latest
    needs: [deploy_staging]
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    environment: production
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}
    
    - name: Install dependencies
      run: pip install -r requirements.txt
    
    - name: Download model
      uses: actions/download-artifact@v3
      with:
        name: trained-model
        path: models/registry/
    
    - name: Blue-Green Deployment
      run: |
        python scripts/blue_green_deploy.py \
          --model models/registry/ci_cd_model.pkl \
          --environment production \
          --blue-green
    
    - name: Promote model in registry
      run: |
        python scripts/promote_model.py promote \
          --model ci_cd_model \
          --version 1 \
          --thresholds configs/model_thresholds.json
    
    - name: Verify deployment
      run: |
        python scripts/verify_deployment.py \
          --endpoint https://api.example.com \
          --tests tests/production_tests.json

  # ============= NOTIFICATIONS =============
  notify:
    runs-on: ubuntu-latest
    needs: [deploy_production]
    if: always()
    
    steps:
    - name: Send notification
      run: |
        python scripts/send_notification.py \
          --status ${{ job.status }} \
          --run-id ${{ github.run_id }} \
          --slack-webhook ${{ secrets.SLACK_WEBHOOK }}
EOF
```

### Step 2: Create Deployment Scripts

```bash
cat > scripts/deploy_model.py << 'EOF'
#!/usr/bin/env python
"""
Model deployment script with multiple deployment strategies.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import pickle
import json
import subprocess
import requests
import time
from datetime import datetime
import argparse
import logging
import mlflow
from src.utils.model_registry import ModelRegistryManager

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def deploy_to_rest_api(model_path: str, endpoint: str, port: int = 8000):
    """
    Deploy model as REST API.
    """
    logger.info(f"Deploying model to REST API at {endpoint}:{port}")
    
    # Load model
    with open(model_path, 'rb') as f:
        model_data = pickle.load(f)
    
    model = model_data['model']
    
    # Create FastAPI app
    app_code = f'''
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import numpy as np
import pickle
import json

app = FastAPI(title="ML Model API", version="1.0.0")

class PredictionRequest(BaseModel):
    features: list

class PredictionResponse(BaseModel):
    prediction: float
    confidence: float

# Load model
with open('{model_path}', 'rb') as f:
    model_data = pickle.load(f)
    model = model_data['model']
    scaler = model_data['scaler']
    feature_names = model_data.get('feature_names', [])

@app.get("/health")
async def health_check():
    return {{"status": "healthy", "timestamp": "{datetime.now().isoformat()}"}}

@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    try:
        # Validate input
        if len(request.features) != len(feature_names):
            raise HTTPException(status_code=400, 
                detail=f"Expected {len(feature_names)} features, got {len(request.features)}")
        
        # Preprocess
        features = np.array(request.features).reshape(1, -1)
        features_scaled = scaler.transform(features)
        
        # Predict
        prediction = model.predict(features_scaled)[0]
        confidence = model.predict_proba(features_scaled)[0][1] if hasattr(model, 'predict_proba') else None
        
        return PredictionResponse(
            prediction=float(prediction),
            confidence=float(confidence) if confidence is not None else 0.0
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port={port})
'''
    
    # Save app
    app_path = Path("models/deployment/api_app.py")
    app_path.parent.mkdir(parents=True, exist_ok=True)
    with open(app_path, 'w') as f:
        f.write(app_code)
    
    # Start service (in production, use proper process management)
    try:
        import uvicorn
        # In CI/CD, this would be handled by the platform
        logger.info(f"API service ready at {endpoint}")
    except:
        pass
    
    return {
        'status': 'success',
        'endpoint': endpoint,
        'port': port,
        'model_path': str(model_path),
        'deployed_at': datetime.now().isoformat()
    }


def deploy_to_batch(model_path: str, output_path: str, schedule: str = "0 0 * * *"):
    """
    Deploy model as batch prediction job.
    """
    logger.info(f"Deploying model for batch predictions at {output_path}")
    
    # Create batch prediction script
    batch_code = f'''
import pickle
import pandas as pd
from datetime import datetime
import json
from pathlib import Path
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load model
with open('{model_path}', 'rb') as f:
    model_data = pickle.load(f)
    model = model_data['model']
    scaler = model_data['scaler']
    feature_names = model_data.get('feature_names', [])

def run_batch_prediction():
    """Run batch predictions."""
    # Load data to predict (in production, load from database or file)
    data_path = Path("data/raw/batch_input.csv")
    
    if not data_path.exists():
        logger.error(f"Input file not found: {data_path}")
        return
    
    df = pd.read_csv(data_path)
    
    # Ensure features match
    available_features = [col for col in feature_names if col in df.columns]
    
    if len(available_features) != len(feature_names):
        logger.warning(f"Missing features: {{set(feature_names) - set(available_features)}}")
    
    # Predict
    X = df[available_features]
    X_scaled = scaler.transform(X)
    predictions = model.predict(X_scaled)
    
    # Add predictions to dataframe
    df['prediction'] = predictions
    df['confidence'] = model.predict_proba(X_scaled)[:, 1] if hasattr(model, 'predict_proba') else None
    
    # Save results
    output_path = Path("{output_path}")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output_path / f"batch_predictions_{{datetime.now().strftime('%Y%m%d_%H%M%S')}}.csv", index=False)
    
    logger.info(f"Batch predictions saved to {{output_path}}")

if __name__ == "__main__":
    run_batch_prediction()
'''
    
    # Save script
    batch_path = Path("models/deployment/batch_predict.py")
    batch_path.parent.mkdir(parents=True, exist_ok=True)
    with open(batch_path, 'w') as f:
        f.write(batch_code)
    
    # Create schedule configuration
    schedule_config = {
        'schedule': schedule,
        'script_path': str(batch_path),
        'output_path': output_path,
        'enabled': True
    }
    
    with open("models/deployment/batch_schedule.json", 'w') as f:
        json.dump(schedule_config, f, indent=2)
    
    return {
        'status': 'success',
        'output_path': output_path,
        'schedule': schedule,
        'script_path': str(batch_path),
        'deployed_at': datetime.now().isoformat()
    }


def main():
    parser = argparse.ArgumentParser(description="Deploy ML model")
    parser.add_argument("--model", type=str, required=True, help="Model path")
    parser.add_argument("--environment", type=str, default="staging", 
                       choices=["staging", "production"])
    parser.add_argument("--endpoint", type=str, help="API endpoint")
    parser.add_argument("--port", type=int, default=8000, help="API port")
    parser.add_argument("--deployment-type", type=str, default="api",
                       choices=["api", "batch", "both"])
    parser.add_argument("--schedule", type=str, default="0 0 * * *")
    parser.add_argument("--output", type=str, default="data/predictions/")
    
    args = parser.parse_args()
    
    results = {}
    
    if args.deployment_type in ["api", "both"]:
        endpoint = args.endpoint or f"http://localhost:{args.port}"
        results['api'] = deploy_to_rest_api(
            args.model,
            endpoint,
            args.port
        )
    
    if args.deployment_type in ["batch", "both"]:
        results['batch'] = deploy_to_batch(
            args.model,
            args.output,
            args.schedule
        )
    
    print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
EOF

chmod +x scripts/deploy_model.py
```

### Step 3: Create Blue-Green Deployment Script

```bash
cat > scripts/blue_green_deploy.py << 'EOF'
#!/usr/bin/env python
"""
Blue-Green deployment strategy for zero-downtime model updates.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import json
import pickle
import subprocess
import requests
import time
from datetime import datetime
import argparse
import logging
import shutil

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class BlueGreenDeployment:
    """
    Blue-Green deployment manager.
    Blue = Current production environment
    Green = New environment being deployed
    """
    
    def __init__(self, base_dir: str = "models/deployment"):
        self.base_dir = Path(base_dir)
        self.base_dir.mkdir(parents=True, exist_ok=True)
        
        self.blue_dir = self.base_dir / "blue"
        self.green_dir = self.base_dir / "green"
        
        self.active_file = self.base_dir / "active_env.json"
        self.blue_dir.mkdir(exist_ok=True)
        self.green_dir.mkdir(exist_ok=True)
    
    def get_active_environment(self) -> str:
        """Get the currently active environment."""
        if self.active_file.exists():
            with open(self.active_file, 'r') as f:
                data = json.load(f)
                return data.get('active', 'blue')
        return 'blue'
    
    def set_active_environment(self, env: str):
        """Set the active environment."""
        with open(self.active_file, 'w') as f:
            json.dump({
                'active': env,
                'updated_at': datetime.now().isoformat()
            }, f, indent=2)
    
    def deploy_to_green(self, model_path: str) -> bool:
        """
        Deploy new model to green environment.
        
        Args:
            model_path: Path to model file
            
        Returns:
            True if successful
        """
        logger.info("Deploying to green environment...")
        
        # Clear green directory
        if self.green_dir.exists():
            shutil.rmtree(self.green_dir)
        self.green_dir.mkdir()
        
        # Copy model
        shutil.copy2(model_path, self.green_dir / "model.pkl")
        
        # Copy scaler if exists
        scaler_path = Path(model_path).parent / "scaler.pkl"
        if scaler_path.exists():
            shutil.copy2(scaler_path, self.green_dir / "scaler.pkl")
        
        # Create service file
        self._create_service_file(self.green_dir)
        
        logger.info("Green environment prepared")
        return True
    
    def _create_service_file(self, env_dir: Path):
        """Create service configuration file."""
        service_config = {
            'model_path': str(env_dir / "model.pkl"),
            'scaler_path': str(env_dir / "scaler.pkl") if (env_dir / "scaler.pkl").exists() else None,
            'environment': 'green',
            'created_at': datetime.now().isoformat()
        }
        
        with open(env_dir / "service.json", 'w') as f:
            json.dump(service_config, f, indent=2)
    
    def test_green_environment(self) -> bool:
        """
        Test the green environment before switching.
        
        Returns:
            True if tests pass
        """
        logger.info("Testing green environment...")
        
        # Load model from green
        model_path = self.green_dir / "model.pkl"
        if not model_path.exists():
            logger.error("Model not found in green environment")
            return False
        
        try:
            with open(model_path, 'rb') as f:
                model_data = pickle.load(f)
            
            # Test prediction
            import numpy as np
            test_features = np.random.randn(10).tolist()
            
            # Try to predict
            model = model_data['model']
            scaler = model_data.get('scaler')
            
            if scaler:
                features = scaler.transform([test_features])
            else:
                features = [test_features]
            
            prediction = model.predict(features)
            
            logger.info(f"Test prediction successful: {prediction}")
            
            # Save test results
            with open(self.green_dir / "test_results.json", 'w') as f:
                json.dump({
                    'passed': True,
                    'test_features': test_features,
                    'prediction': prediction.tolist() if hasattr(prediction, 'tolist') else prediction,
                    'timestamp': datetime.now().isoformat()
                }, f, indent=2)
            
            return True
            
        except Exception as e:
            logger.error(f"Green environment test failed: {e}")
            return False
    
    def switch_to_green(self) -> bool:
        """
        Switch active environment from blue to green.
        
        Returns:
            True if successful
        """
        active = self.get_active_environment()
        logger.info(f"Switching from {active} to green...")
        
        # Get blue and green directories
        blue_dir = self.blue_dir if active == 'green' else self.green_dir
        green_dir = self.green_dir if active == 'blue' else self.blue_dir
        
        # Switch
        self.set_active_environment('green' if active == 'blue' else 'blue')
        
        # Update service
        self._update_service()
        
        logger.info("Switch complete")
        return True
    
    def _update_service(self):
        """Update service with new environment."""
        active = self.get_active_environment()
        env_dir = self.blue_dir if active == 'blue' else self.green_dir
        
        service_file = Path("models/deployment/active_service.json")
        with open(service_file, 'w') as f:
            json.dump({
                'active_environment': active,
                'model_path': str(env_dir / "model.pkl"),
                'updated_at': datetime.now().isoformat()
            }, f, indent=2)
    
    def rollback(self) -> bool:
        """
        Rollback to previous environment.
        
        Returns:
            True if successful
        """
        active = self.get_active_environment()
        logger.info(f"Rolling back from {active}")
        
        # Switch to the opposite
        new_active = 'blue' if active == 'green' else 'green'
        self.set_active_environment(new_active)
        self._update_service()
        
        logger.info(f"Rollback to {new_active} complete")
        return True
    
    def deploy(self, model_path: str, auto_switch: bool = True) -> Dict:
        """
        Full blue-green deployment.
        
        Args:
            model_path: Path to model
            auto_switch: Whether to automatically switch after testing
            
        Returns:
            Deployment results
        """
        results = {
            'deployment_id': datetime.now().strftime('%Y%m%d_%H%M%S'),
            'model_path': model_path,
            'timestamp': datetime.now().isoformat()
        }
        
        # Deploy to green
        if not self.deploy_to_green(model_path):
            results['status'] = 'failed'
            results['error'] = 'Failed to deploy to green'
            return results
        
        # Test green
        if not self.test_green_environment():
            results['status'] = 'failed'
            results['error'] = 'Green environment tests failed'
            return results
        
        # Switch if requested
        if auto_switch:
            if self.switch_to_green():
                results['status'] = 'success'
                results['environment'] = self.get_active_environment()
            else:
                results['status'] = 'failed'
                results['error'] = 'Failed to switch to green'
        else:
            results['status'] = 'ready'
            results['environment'] = 'green (ready to switch)'
        
        return results


def main():
    parser = argparse.ArgumentParser(description="Blue-Green deployment")
    parser.add_argument("--model", type=str, required=True, help="Model path")
    parser.add_argument("--environment", type=str, default="production")
    parser.add_argument("--no-switch", action="store_true", help="Don't auto-switch")
    parser.add_argument("--rollback", action="store_true", help="Rollback deployment")
    
    args = parser.parse_args()
    
    deployer = BlueGreenDeployment()
    
    if args.rollback:
        result = deployer.rollback()
        print(json.dumps({'action': 'rollback', 'success': result}, indent=2))
    else:
        result = deployer.deploy(args.model, not args.no_switch)
        print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
EOF

chmod +x scripts/blue_green_deploy.py
```

### Step 4: Create Production Verification Script

```bash
cat > scripts/verify_deployment.py << 'EOF'
#!/usr/bin/env python
"""
Production deployment verification and smoke testing.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import json
import requests
import time
from datetime import datetime
import argparse
import logging
import numpy as np

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class DeploymentVerifier:
    """Verifies production deployments."""
    
    def __init__(self, endpoint: str):
        self.endpoint = endpoint.rstrip('/')
        self.results = {
            'timestamp': datetime.now().isoformat(),
            'endpoint': endpoint,
            'tests': []
        }
    
    def test_health(self) -> bool:
        """Test health endpoint."""
        logger.info("Testing health endpoint...")
        
        try:
            response = requests.get(f"{self.endpoint}/health", timeout=5)
            success = response.status_code == 200
            
            self.results['tests'].append({
                'name': 'health_check',
                'passed': success,
                'status_code': response.status_code,
                'response': response.json() if success else None
            })
            
            logger.info(f"Health check: {'PASS' if success else 'FAIL'}")
            return success
            
        except Exception as e:
            self.results['tests'].append({
                'name': 'health_check',
                'passed': False,
                'error': str(e)
            })
            logger.error(f"Health check failed: {e}")
            return False
    
    def test_prediction(self, test_data: list = None) -> bool:
        """Test prediction endpoint."""
        logger.info("Testing prediction endpoint...")
        
        if test_data is None:
            # Generate test data
            test_data = np.random.randn(10).tolist()
        
        try:
            response = requests.post(
                f"{self.endpoint}/predict",
                json={'features': test_data},
                timeout=10
            )
            
            success = response.status_code == 200
            
            self.results['tests'].append({
                'name': 'prediction',
                'passed': success,
                'status_code': response.status_code,
                'input': test_data,
                'response': response.json() if success else None
            })
            
            logger.info(f"Prediction test: {'PASS' if success else 'FAIL'}")
            return success
            
        except Exception as e:
            self.results['tests'].append({
                'name': 'prediction',
                'passed': False,
                'error': str(e)
            })
            logger.error(f"Prediction test failed: {e}")
            return False
    
    def test_performance(self, iterations: int = 10) -> bool:
        """Test performance/latency."""
        logger.info(f"Testing performance with {iterations} requests...")
        
        latencies = []
        failures = 0
        
        for i in range(iterations):
            test_data = np.random.randn(10).tolist()
            
            try:
                start = time.time()
                response = requests.post(
                    f"{self.endpoint}/predict",
                    json={'features': test_data},
                    timeout=10
                )
                elapsed = (time.time() - start) * 1000  # Convert to ms
                
                if response.status_code == 200:
                    latencies.append(elapsed)
                else:
                    failures += 1
                    
            except Exception as e:
                failures += 1
                logger.warning(f"Request {i} failed: {e}")
        
        success = failures < (iterations * 0.2)  # Less than 20% failures
        
        avg_latency = np.mean(latencies) if latencies else float('inf')
        p95_latency = np.percentile(latencies, 95) if latencies else float('inf')
        
        self.results['tests'].append({
            'name': 'performance',
            'passed': success,
            'iterations': iterations,
            'failures': failures,
            'avg_latency_ms': avg_latency,
            'p95_latency_ms': p95_latency,
            'min_latency_ms': min(latencies) if latencies else None,
            'max_latency_ms': max(latencies) if latencies else None
        })
        
        logger.info(f"Performance test: {'PASS' if success else 'FAIL'}")
        logger.info(f"  Avg latency: {avg_latency:.2f}ms, P95: {p95_latency:.2f}ms")
        
        return success
    
    def run_tests(self, performance_iterations: int = 10) -> Dict:
        """Run all verification tests."""
        logger.info("Running deployment verification suite...")
        
        # 1. Health check
        health_ok = self.test_health()
        
        # 2. Prediction test
        prediction_ok = self.test_prediction()
        
        # 3. Performance test
        performance_ok = self.test_performance(performance_iterations)
        
        # Overall status
        all_ok = all([health_ok, prediction_ok, performance_ok])
        
        self.results['overall_status'] = 'PASS' if all_ok else 'FAIL'
        self.results['timestamp'] = datetime.now().isoformat()
        
        logger.info(f"Verification complete: {'PASS' if all_ok else 'FAIL'}")
        
        return self.results


def main():
    parser = argparse.ArgumentParser(description="Verify deployment")
    parser.add_argument("--endpoint", type=str, required=True, help="API endpoint")
    parser.add_argument("--tests", type=str, help="Tests JSON file")
    parser.add_argument("--iterations", type=int, default=10, help="Performance iterations")
    parser.add_argument("--output", type=str, default="deployment_verification.json")
    
    args = parser.parse_args()
    
    # Load test data if provided
    test_data = None
    if args.tests and Path(args.tests).exists():
        with open(args.tests, 'r') as f:
            test_config = json.load(f)
            test_data = test_config.get('test_data')
    
    verifier = DeploymentVerifier(args.endpoint)
    results = verifier.run_tests(args.iterations)
    
    # Save results
    with open(args.output, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(json.dumps(results, indent=2))
    
    sys.exit(0 if results['overall_status'] == 'PASS' else 1)


if __name__ == "__main__":
    main()
EOF

chmod +x scripts/verify_deployment.py
```

### Step 5: Create Test Files

```bash
cat > tests/production_tests.json << 'EOF'
{
  "test_data": [1.2, 3.4, 5.6, 7.8, 9.0, 1.1, 2.2, 3.3, 4.4, 5.5],
  "expected_range": [0, 1],
  "thresholds": {
    "accuracy": 0.85,
    "latency_ms": 100
  }
}
EOF

cat > tests/data/sample_input.json << 'EOF'
{
  "features": [1.2, 3.4, 5.6, 7.8, 9.0, 1.1, 2.2, 3.3, 4.4, 5.5]
}
EOF
```

### Step 6: Create Final Deployment Script

```bash
cat > scripts/deploy_production.sh << 'EOF'
#!/bin/bash
# Complete production deployment script

set -e

echo "=========================================="
echo "PRODUCTION DEPLOYMENT"
echo "=========================================="
echo "Started at: $(date)"

# Configuration
MODEL_PATH=${1:-"models/registry/best_model.pkl"}
ENVIRONMENT=${2:-"production"}
DEPLOYMENT_TYPE=${3:-"blue-green"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Step 1: Validating model${NC}"
if [ ! -f "$MODEL_PATH" ]; then
    echo -e "${RED}Model not found: $MODEL_PATH${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 2: Running tests${NC}"
pytest tests/integration/ -v || {
    echo -e "${RED}Tests failed${NC}"
    exit 1
}

echo -e "${YELLOW}Step 3: Deploying model${NC}"
if [ "$DEPLOYMENT_TYPE" == "blue-green" ]; then
    python scripts/blue_green_deploy.py \
        --model "$MODEL_PATH" \
        --environment "$ENVIRONMENT"
else
    python scripts/deploy_model.py \
        --model "$MODEL_PATH" \
        --environment "$ENVIRONMENT" \
        --deployment-type both
fi

echo -e "${YELLOW}Step 4: Verifying deployment${NC}"
sleep 5  # Wait for service to start

python scripts/verify_deployment.py \
    --endpoint https://api.example.com \
    --tests tests/production_tests.json \
    --output deployment_verification.json

# Check verification results
if grep -q '"overall_status": "PASS"' deployment_verification.json; then
    echo -e "${GREEN}✅ Deployment verified successfully${NC}"
else
    echo -e "${RED}❌ Deployment verification failed${NC}"
    
    # Rollback
    echo -e "${YELLOW}Rolling back...${NC}"
    python scripts/blue_green_deploy.py --rollback
    exit 1
fi

echo -e "${YELLOW}Step 5: Updating model registry${NC}"
python scripts/promote_model.py promote \
    --model predictive_maintenance_model \
    --version 1 \
    --thresholds configs/model_thresholds.json

echo -e "${YELLOW}Step 6: Cleanup${NC}"
# Clean old models if needed
python scripts/cleanup_models.py --keep-last 5

echo "=========================================="
echo -e "${GREEN}DEPLOYMENT COMPLETE${NC}"
echo "Time: $(date)"
echo "=========================================="
EOF

chmod +x scripts/deploy_production.sh
```

### Step 7: Run Complete Deployment

```bash
# Test the deployment locally
./scripts/deploy_production.sh models/registry/best_model.pkl production

# Run CI/CD pipeline (if using GitHub Actions)
# The pipeline will run automatically on push to main

# Or run manually
gh workflow run mlops_ci_cd.yaml
```

## The Verification: Testing CI/CD

### Verification 1: Check CI/CD Pipeline

```bash
# View GitHub Actions runs
gh run list

# Check specific run
gh run view <run-id>

# Download artifacts
gh run download <run-id>
```

### Verification 2: Test Blue-Green Deployment

```bash
# Deploy with blue-green
python scripts/blue_green_deploy.py --model models/registry/best_model.pkl

# Check active environment
cat models/deployment/active_env.json

# Rollback if needed
python scripts/blue_green_deploy.py --rollback
```

### Verification 3: Test Production Verification

```bash
# Run verification against production
python scripts/verify_deployment.py \
    --endpoint https://api.example.com \
    --iterations 20 \
    --output verification_report.json

# Check results
cat verification_report.json
```

## What We've Accomplished

You now have a complete CI/CD system for MLOps that includes:

1. **Continuous Integration** (testing, validation, linting)
2. **Continuous Deployment** (automated deployments)
3. **Blue-Green Deployments** (zero-downtime updates)
4. **Rollback Capabilities** (quick recovery from failures)
5. **Production Verification** (smoke tests and validation)
6. **GitHub Actions Integration** (automated pipeline)
7. **Model Registry Promotion** (automatic stage transitions)
8. **Performance Testing** (latency and throughput checks)

## The Complete MLOps Journey

You've now built a complete production-grade MLOps system:

```
┌────────────────────────────────────────────────────────────────┐
│                    COMPLETE MLOPS ARCHITECTURE                │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌──────────────────────────────────────────────────────┐    │
│  │              CI/CD PIPELINE (GitHub Actions)          │    │
│  │   Test → Validate → Train → Evaluate → Deploy        │    │
│  └──────────────────────────────────────────────────────┘    │
│                           │                                   │
│  ┌────────────────────────┼──────────────────────────┐      │
│  │                        ▼                          │      │
│  │         DAGSTER ORCHESTRATION                    │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌───────┐  │      │
│  │  │  Schedules   │  │   Sensors    │  │ Jobs  │  │      │
│  │  └──────────────┘  └──────────────┘  └───────┘  │      │
│  └──────────────────────────────────────────────────┘      │
│                           │                                   │
│  ┌────────────────────────┼──────────────────────────┐      │
│  │                        ▼                          │      │
│  │         DVC + MLflow + Model Registry             │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌───────┐  │      │
│  │  │ Data Version │  │ Experiments │  │ Models │  │      │
│  │  └──────────────┘  └──────────────┘  └───────┘  │      │
│  └──────────────────────────────────────────────────┘      │
│                           │                                   │
│  ┌────────────────────────┼──────────────────────────┐      │
│  │                        ▼                          │      │
│  │              DEPLOYMENT TARGETS                    │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌───────┐  │      │
│  │  │  REST API    │  │  Batch Jobs  │  │ Edge  │  │      │
│  │  └──────────────┘  └──────────────┘  └───────┘  │      │
│  └──────────────────────────────────────────────────┘      │
│                           │                                   │
│  ┌────────────────────────┼──────────────────────────┐      │
│  │                        ▼                          │      │
│  │              MONITORING & ALERTING                 │      │
│  │  ┌──────────────┐  ┌──────────────┐  ┌───────┐  │      │
│  │  │  Metrics     │  │  Logs        │  │ Alerts│  │      │
│  │  └──────────────┘  └──────────────┘  └───────┘  │      │
│  └──────────────────────────────────────────────────┘      │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Next Steps After This Series

Congratulations! You've completed the entire MLOps pipeline series. Here are suggestions for continuing your journey:

1. **Implement in production**: Deploy this system to your actual infrastructure
2. **Add more models**: Extend to multiple model types and use cases
3. **Scale horizontally**: Add distributed training and serving
4. **Add feature store**: Implement Feast or similar for feature management
5. **Add data quality monitoring**: Implement Great Expectations or similar
6. **Automate retraining**: Implement automatic retraining based on performance
7. **Add A/B testing**: Implement canary deployments and A/B testing
8. **Build custom dashboards**: Create specialized monitoring dashboards

---

*End of Part 15: Continuous Deployment Strategies*

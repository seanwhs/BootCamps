# Appendix B: Complete Command Reference

## The Target: Comprehensive CLI Commands Reference

This appendix provides a complete reference of all command-line interface (CLI) commands used throughout the series, organized by tool and use case. Use this as a quick reference when working with the MLOps pipeline.

## The Concept: Command Encyclopedia

Think of this as a pilot's checklist:
- **Pre-flight**: Setup and initialization commands
- **In-flight**: Execution and monitoring commands
- **Landing**: Deployment and cleanup commands
- **Emergency**: Troubleshooting and recovery commands

---

## 1. Git Commands

### Repository Setup
```bash
# Initialize a new repository
git init

# Clone an existing repository
git clone <repository-url>

# Add remote origin
git remote add origin <repository-url>

# View remote repositories
git remote -v
```

### Basic Operations
```bash
# Check status
git status

# Add files to staging
git add <file>                # Single file
git add .                     # All files in current directory
git add -A                    # All files in entire repository

# Commit changes
git commit -m "Commit message"
git commit -a -m "Message"    # Add and commit all tracked files

# View commit history
git log --oneline
git log --graph --oneline --all

# Push to remote
git push origin main
git push -u origin main       # Set upstream

# Pull from remote
git pull origin main

# Branch operations
git branch                    # List branches
git branch <branch-name>      # Create branch
git checkout <branch-name>    # Switch branch
git checkout -b <branch-name> # Create and switch
git merge <branch-name>       # Merge branch
git branch -d <branch-name>   # Delete branch
```

### Advanced Git
```bash
# Tagging
git tag <tag-name>
git tag -a <tag-name> -m "Message"
git push --tags

# Stashing
git stash
git stash list
git stash pop
git stash drop

# Reset and revert
git reset --hard <commit>     # Hard reset
git reset --soft <commit>     # Soft reset
git revert <commit>           # Revert commit

# Diff and blame
git diff
git diff --staged
git blame <file>
```

---

## 2. DVC Commands

### Initialization and Setup
```bash
# Initialize DVC
dvc init

# Configure remote storage
dvc remote add <name> <url>
dvc remote default <name>
dvc remote modify <name> <key> <value>

# List and check remotes
dvc remote list
dvc remote default

# Configure authentication
dvc remote modify <name> access_key_id <key>
dvc remote modify <name> secret_access_key <secret>
```

### Data Management
```bash
# Track data files
dvc add <file>                # Add single file
dvc add <directory>           # Add directory

# Check status
dvc status
dvc status --remote           # Check remote sync

# Push and pull data
dvc push                      # Push all
dvc push <file>.dvc           # Push specific file
dvc pull                      # Pull all
dvc pull <file>.dvc           # Pull specific file

# Checkout data
dvc checkout                  # Checkout all
dvc checkout <file>           # Checkout specific file

# List tracked files
dvc list
dvc list --all
dvc list --dvc-only

# Remove tracking
dvc remove <file>.dvc
```

### Pipeline Management
```bash
# Run pipeline
dvc repro                     # Run changed stages
dvc repro --force             # Force run all
dvc repro --single-item <stage> # Run single stage
dvc repro --dry               # Dry run

# Pipeline inspection
dvc dag                       # Show pipeline graph
dvc status                    # Check pipeline status
dvc diff                      # Show changes between commits

# Metrics
dvc metrics show
dvc metrics show --all
dvc metrics diff

# Experiments
dvc exp run                   # Run experiment
dvc exp list                  # List experiments
dvc exp show                  # Show experiment results
dvc exp diff                  # Compare experiments
```

### Cache Management
```bash
# Garbage collection
dvc gc                        # Clean unreferenced cache
dvc gc --workspace            # Clean workspace cache
dvc gc --all-commits          # Clean all commits

# Cache stats
dvc cache dir                 # Show cache directory
dvc cache local               # Show local cache info

# Import and export
dvc import <url> <out>        # Import data
dvc export <file> <out>       # Export data
```

---

## 3. MLflow Commands

### Server Management
```bash
# Start tracking UI
mlflow ui
mlflow ui --backend-store-uri <uri>
mlflow ui --host 0.0.0.0 --port 5000

# Start tracking server
mlflow server \
    --host 0.0.0.0 \
    --port 5000 \
    --backend-store-uri <uri> \
    --default-artifact-root <path>

# Configure server
export MLFLOW_TRACKING_URI=http://localhost:5000
```

### Experiment Management
```bash
# List experiments
mlflow experiments list

# Create experiment
mlflow experiments create --experiment-name <name>
mlflow experiments create --experiment-name <name> --artifact-location <path>

# Delete experiment
mlflow experiments delete --experiment-id <id>

# Rename experiment
mlflow experiments rename --experiment-id <id> --new-name <name>
```

### Run Management
```bash
# List runs
mlflow runs list --experiment-id <id>
mlflow runs list --experiment-name <name>

# Get run info
mlflow runs get --run-id <id>

# Delete run
mlflow runs delete --run-id <id>
```

### Model Management
```bash
# List models
mlflow models list

# Serve model
mlflow models serve -m <model-uri> -p <port>

# Predict with model
mlflow models predict -m <model-uri> -i <input-file>

# Build Docker image
mlflow models build-docker -m <model-uri> -n <image-name>
```

### Registry Management
```bash
# List registered models
mlflow registry list

# Get model version
mlflow registry get-model-version --name <name> --version <version>

# Transition model stage
mlflow registry transition-stage \
    --name <name> \
    --version <version> \
    --stage <stage>
```

---

## 4. Dagster Commands

### Server and Daemon
```bash
# Start webserver
dagster-webserver
dagster-webserver -f <file> -m <module>
dagster-webserver -p <port> --host <host>

# Start daemon
dagster-daemon run
dagster-daemon run -p <port>

# Run both (development)
dagster dev -f <file>
```

### Job Management
```bash
# Execute job
dagster job execute -f <file> -j <job>
dagster job execute -m <module> -j <job>
dagster job execute -f <file> -j <job> -c <config>

# List jobs
dagster job list -f <file>
dagster job list -m <module>

# Describe job
dagster job describe -f <file> -j <job>
dagster job describe -m <module> -j <job>

# Launch job
dagster job launch -f <file> -j <job>
```

### Schedule Management
```bash
# List schedules
dagster schedule list
dagster schedule list -m <module>

# Start schedule
dagster schedule start <schedule>
dagster schedule start <schedule> -m <module>

# Stop schedule
dagster schedule stop <schedule>
dagster schedule stop <schedule> -m <module>

# Preview schedule
dagster schedule preview <schedule>
dagster schedule preview <schedule> -m <module>
```

### Sensor Management
```bash
# List sensors
dagster sensor list
dagster sensor list -m <module>

# Start sensor
dagster sensor start <sensor>
dagster sensor start <sensor> -m <module>

# Stop sensor
dagster sensor stop <sensor>
dagster sensor stop <sensor> -m <module>

# Preview sensor
dagster sensor preview <sensor>
dagster sensor preview <sensor> -m <module>
```

### Asset Management
```bash
# List assets
dagster asset list
dagster asset list -m <module>

# Materialize assets
dagster asset materialize -a <asset>
dagster asset materialize -a <asset> -m <module>

# View asset lineage
dagster asset lineage <asset>
```

---

## 5. Python Package Management

### pip Commands
```bash
# Install packages
pip install <package>
pip install <package>==<version>
pip install -r requirements.txt

# Upgrade packages
pip install --upgrade <package>
pip install --upgrade -r requirements.txt

# Uninstall packages
pip uninstall <package>

# List installed packages
pip list
pip list --outdated
pip freeze

# Check dependencies
pip check
pip show <package>
```

### Virtual Environment
```bash
# Create virtual environment
python -m venv venv
python3 -m venv venv

# Activate environment
source venv/bin/activate          # Linux/macOS
venv\Scripts\activate              # Windows

# Deactivate
deactivate

# Export requirements
pip freeze > requirements.txt

# Install from requirements
pip install -r requirements.txt
```

---

## 6. AWS CLI Commands

### S3 Operations
```bash
# List buckets
aws s3 ls

# Create bucket
aws s3 mb s3://<bucket-name>

# List bucket contents
aws s3 ls s3://<bucket-name>
aws s3 ls s3://<bucket-name> --recursive

# Copy files
aws s3 cp <local> s3://<bucket>/<path>
aws s3 cp s3://<bucket>/<path> <local>

# Sync directories
aws s3 sync <local> s3://<bucket>/<path>
aws s3 sync s3://<bucket>/<path> <local>

# Delete files
aws s3 rm s3://<bucket>/<path>
aws s3 rm s3://<bucket>/<path> --recursive

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket <bucket> \
    --versioning-configuration Status=Enabled

# Get bucket region
aws s3api get-bucket-location --bucket <bucket>
```

### IAM Operations
```bash
# List users
aws iam list-users

# Create user
aws iam create-user --user-name <name>

# Create access key
aws iam create-access-key --user-name <name>

# List access keys
aws iam list-access-keys --user-name <name>

# Attach policy
aws iam attach-user-policy \
    --user-name <name> \
    --policy-arn <arn>
```

---

## 7. GCP CLI Commands (gcloud)

### Storage Operations
```bash
# List buckets
gsutil ls

# Create bucket
gsutil mb gs://<bucket-name>

# List bucket contents
gsutil ls gs://<bucket-name>
gsutil ls gs://<bucket-name>/**/*

# Copy files
gsutil cp <local> gs://<bucket>/<path>
gsutil cp gs://<bucket>/<path> <local>

# Sync directories
gsutil rsync <local> gs://<bucket>/<path>

# Delete files
gsutil rm gs://<bucket>/<path>
gsutil rm -r gs://<bucket>/<path>
```

### Authentication
```bash
# Login
gcloud auth login

# Set project
gcloud config set project <project-id>

# Get credentials
gcloud auth application-default login

# List accounts
gcloud auth list

# Activate service account
gcloud auth activate-service-account \
    --key-file <key-file>
```

---

## 8. Docker Commands

### Image Management
```bash
# Build image
docker build -t <image-name> .
docker build -t <image-name>:<tag> .

# List images
docker images
docker image ls

# Remove image
docker rmi <image-id>
docker rmi <image-name>:<tag>

# Tag image
docker tag <image> <registry>/<image>:<tag>

# Push image
docker push <registry>/<image>:<tag>
docker pull <registry>/<image>:<tag>
```

### Container Management
```bash
# Run container
docker run <image>
docker run -d <image>         # Detached mode
docker run -p 8080:80 <image> # Port mapping
docker run -v /host:/container <image> # Volume mount

# List containers
docker ps                     # Running
docker ps -a                  # All containers

# Stop container
docker stop <container>
docker kill <container>       # Force stop

# Remove container
docker rm <container>
docker rm -f <container>      # Force remove

# Execute in container
docker exec -it <container> <command>

# View logs
docker logs <container>
docker logs -f <container>    # Follow logs
```

### Docker Compose
```bash
# Start services
docker-compose up
docker-compose up -d          # Detached

# Stop services
docker-compose down
docker-compose down -v        # Remove volumes

# Build services
docker-compose build

# View logs
docker-compose logs
docker-compose logs -f

# Execute command
docker-compose exec <service> <command>

# List services
docker-compose ps
```

---

## 9. Kubernetes Commands (kubectl)

### Cluster Management
```bash
# Get cluster info
kubectl cluster-info

# Get nodes
kubectl get nodes
kubectl describe node <node>

# Get namespaces
kubectl get namespaces
kubectl create namespace <name>
```

### Deployment Management
```bash
# Apply configuration
kubectl apply -f <file>
kubectl apply -f <directory>/

# Get resources
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get all

# Describe resource
kubectl describe pod <pod>
kubectl describe deployment <deployment>

# Scale deployment
kubectl scale deployment <name> --replicas=<count>

# Update deployment
kubectl set image deployment/<name> <container>=<image>

# Rollback
kubectl rollout status deployment/<name>
kubectl rollout undo deployment/<name>
```

### Pod Management
```bash
# View logs
kubectl logs <pod>
kubectl logs -f <pod>        # Follow logs
kubectl logs <pod> -c <container>

# Execute in pod
kubectl exec -it <pod> -- <command>

# Port forwarding
kubectl port-forward <pod> <local>:<remote>

# Delete pod
kubectl delete pod <pod>
```

---

## 10. Testing Commands

### pytest
```bash
# Run all tests
pytest

# Run specific test file
pytest tests/test_file.py

# Run specific test function
pytest tests/test_file.py::test_function

# Run with coverage
pytest --cov=src
pytest --cov=src --cov-report=html
pytest --cov=src --cov-report=xml

# Run in parallel
pytest -n auto

# Run with verbose output
pytest -v
pytest -vv

# Run only failing tests
pytest --lf
pytest --ff

# Run with markers
pytest -m <marker>
pytest -m "not slow"
```

### Coverage
```bash
# Run coverage
coverage run -m pytest
coverage report
coverage html
coverage xml

# View coverage report
open htmlcov/index.html
```

---

## 11. Project-Specific Commands

### Data Generation
```bash
# Generate sensor data
python src/data/generate_sensor_data.py --hours 48
python src/data/generate_sensor_data.py --hours 168 --anomaly_rate 0.03
```

### Feature Engineering
```bash
# Build features
python src/features/build_features.py \
    --input data/raw/sensor_data_48h.csv \
    --output data/processed/features_48h.csv

# Build with custom windows
python src/features/build_features.py \
    --input data/raw/sensor_data_168h.csv \
    --output data/processed/features_168h.csv \
    --windows 5 10 30 60
```

### Model Training
```bash
# Basic training
python models/training/train_model.py \
    --features data/processed/features_48h.csv

# Full training with MLflow
python models/training/train_model_full.py \
    --features data/processed/features_48h.csv \
    --experiment "My_Experiment"

# Training with registry
python models/training/train_with_registry.py \
    --features data/processed/features_48h.csv \
    --model_name "my_model" \
    --auto-stage
```

### Pipeline Execution
```bash
# Run DVC pipeline
dvc repro

# Run Dagster pipeline
dagster job execute -f pipelines/master_pipeline.py -j master_mlops_pipeline

# Run monitoring pipeline
dagster job execute -f pipelines/monitoring_pipeline.py -j monitoring_pipeline

# Run all components
./scripts/run_master_pipeline.py
```

### Deployment
```bash
# Deploy model
python scripts/deploy_model.py --model models/registry/best_model.pkl --environment production

# Blue-green deployment
python scripts/blue_green_deploy.py --model models/registry/best_model.pkl

# Verify deployment
python scripts/verify_deployment.py --endpoint https://api.example.com

# Promote model
python scripts/promote_model.py promote --model my_model --version 1
```

### Monitoring
```bash
# Run monitoring
python scripts/monitor_pipeline.py

# Launch dashboard
streamlit run scripts/monitoring_dashboard.py

# Start MLflow UI
mlflow ui --backend-store-uri ./mlruns

# Start Dagster UI
dagster-webserver -f pipelines/
```

### Backup and Maintenance
```bash
# Backup data
./scripts/backup_data.sh

# Reset pipeline
./scripts/reset_pipeline.sh

# Clean cache
dvc gc --workspace

# Version pipeline
./scripts/version_pipeline.sh v1.0.0
```

---

## 12. Troubleshooting Commands

### Port Management
```bash
# Check port usage
lsof -i :5000                 # Linux/macOS
netstat -ano | findstr :5000  # Windows

# Kill process on port
kill -9 <PID>                 # Linux/macOS
taskkill /PID <PID> /F        # Windows

# Check service status
ps aux | grep <service>
systemctl status <service>
```

### Logs
```bash
# Tail logs
tail -f logs/pipeline.log
tail -f logs/alerts.txt

# View error logs
cat logs/errors/*.json
cat logs/failures/*.json

# Search logs
grep -r "ERROR" logs/
grep -r "failed" logs/
```

### Database
```bash
# Connect to SQLite
sqlite3 data/pipeline_metadata.db
.tables
.schema <table>

# Check MLflow DB
sqlite3 mlruns/mlflow.db
.tables
SELECT * FROM experiments;
SELECT * FROM runs LIMIT 10;
```

### System Health
```bash
# Check system resources
top
htop
df -h
free -h

# Check disk usage
du -sh .
du -sh * | sort -hr | head -10

# Check network
ping <host>
curl -I <url>
telnet <host> <port>
```

---

*End of Appendix B: Complete Command Reference*

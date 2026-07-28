# Quiz and Test Bank: MLOps Pipeline Engineering

## Comprehensive Assessment Questions with Answer Keys

---

# TABLE OF CONTENTS

**Part 0: Introduction to MLOps**
- Quiz 0.1: MLOps Fundamentals (10 questions)
- Quiz 0.2: Tools and Architecture (10 questions)

**Part 1: DVC (Data Version Control)**
- Quiz 1.1: DVC Basics (15 questions)
- Quiz 1.2: DVC Pipelines (15 questions)
- Quiz 1.3: Remote Storage (10 questions)
- Test 1: DVC Comprehensive (25 questions)

**Part 2: MLflow (Experiment Tracking)**
- Quiz 2.1: MLflow Basics (15 questions)
- Quiz 2.2: MLflow Tracking (15 questions)
- Quiz 2.3: Model Registry (10 questions)
- Test 2: MLflow Comprehensive (25 questions)

**Part 3: Dagster (Pipeline Orchestration)**
- Quiz 3.1: Dagster Basics (15 questions)
- Quiz 3.2: Assets and Ops (15 questions)
- Quiz 3.3: Schedules and Sensors (10 questions)
- Test 3: Dagster Comprehensive (25 questions)

**Part 4: Integration and Deployment**
- Quiz 4.1: Integration (10 questions)
- Quiz 4.2: Deployment (10 questions)
- Quiz 4.3: Monitoring (10 questions)
- Test 4: Integration Comprehensive (25 questions)

**Final Exam**
- Comprehensive Final (100 questions)

**Answer Keys**
- All Quiz and Test Answers

---

# PART 0: INTRODUCTION TO MLOPS

## Quiz 0.1: MLOps Fundamentals

**Instructions:** Choose the best answer for each question.

### Multiple Choice

**1. What does MLOps stand for?**
- A) Machine Learning Operations
- B) Model Lifecycle Operations
- C) Machine Language Operations
- D) Model Learning Operations

**2. Which of the following is NOT a key component of MLOps?**
- A) Data versioning
- B) Experiment tracking
- C) Front-end development
- D) Pipeline orchestration

**3. What percentage of ML projects never reach production?**
- A) 40%
- B) 60%
- C) 80%
- D) 90%

**4. What is the primary goal of MLOps?**
- A) Increase model accuracy
- B) Bridge the gap between research and production
- C) Reduce code complexity
- D) Increase team size

**5. Which of the following represents the correct MLOps lifecycle order?**
- A) Data Prep → Model Train → Model Eval → Model Deploy
- B) Model Train → Data Prep → Model Deploy → Model Eval
- C) Model Deploy → Model Train → Data Prep → Model Eval
- D) Model Eval → Model Deploy → Data Prep → Model Train

**6. The "Three Pillars of MLOps" include all of the following EXCEPT:**
- A) Data Versioning
- B) Experiment Tracking
- C) Front-end Development
- D) Pipeline Orchestration

**7. DVC is primarily used for:**
- A) Experiment tracking
- B) Data versioning
- C) Pipeline orchestration
- D) Model deployment

**8. MLflow is primarily used for:**
- A) Data versioning
- B) Experiment tracking
- C) Pipeline orchestration
- D) Containerization

**9. Dagster is primarily used for:**
- A) Data versioning
- B) Experiment tracking
- C) Pipeline orchestration
- D) Model serving

**10. The use case used throughout this series is:**
- A) Fraud detection
- B) Predictive maintenance
- C) Image classification
- D) Natural language processing

### True/False

**11. MLOps combines ML, DevOps, and Data Engineering.**
- ☐ True
- ☐ False

**12. Data versioning is optional in production ML systems.**
- ☐ True
- ☐ False

**13. Experiment tracking helps with reproducibility.**
- ☐ True
- ☐ False

**14. Pipeline orchestration is only needed for large datasets.**
- ☐ True
- ☐ False

**15. Model monitoring is important after deployment.**
- ☐ True
- ☐ False

---

## Quiz 0.2: Tools and Architecture

**Instructions:** Choose the best answer for each question.

### Multiple Choice

**1. Which tool is used for data versioning in this series?**
- A) Git
- B) DVC
- C) MLflow
- D) Dagster

**2. Which tool is used for experiment tracking?**
- A) DVC
- B) MLflow
- C) Dagster
- D) Docker

**3. Which tool is used for pipeline orchestration?**
- A) DVC
- B) MLflow
- C) Dagster
- D) Kubernetes

**4. What is the format of data used in the predictive maintenance example?**
- A) Images
- B) Text
- C) Sensor readings
- D) Audio

**5. The architecture diagram shows a typical MLOps system with which components?**
- A) Only data processing
- B) Only model training
- C) Complete lifecycle
- D) Only deployment

**6. Git is used for:**
- A) Data versioning
- B) Code versioning
- C) Experiment tracking
- D) Pipeline orchestration

**7. Docker is used for:**
- A) Experiment tracking
- B) Data versioning
- C) Containerization
- D) Pipeline orchestration

**8. Kubernetes is used for:**
- A) Container orchestration
- B) Experiment tracking
- C) Data versioning
- D) Pipeline definition

**9. The monitoring stack typically includes:**
- A) Prometheus and Grafana
- B) DVC and Git
- C) MLflow and Dagster
- D) Docker and Kubernetes

**10. Which environment variable is used for MLflow tracking URI?**
- A) MLFLOW_URI
- B) MLFLOW_TRACKING_URI
- C) MLFLOW_SERVER
- D) MLFLOW_HOST

### Fill in the Blank

**11. The three pillars of MLOps are: __________, __________, and __________.**

**12. DVC stands for: __________.**

**13. MLflow has four main components: __________, __________, __________, and __________.**

**14. Dagster is a modern __________ platform.**

**15. The predictive maintenance use case predicts __________ before they occur.**

---

# PART 1: DVC (DATA VERSION CONTROL)

## Quiz 1.1: DVC Basics

**Instructions:** Choose the best answer for each question.

### Multiple Choice

**1. What does DVC stand for?**
- A) Data Version Control
- B) Data Versioning Command
- C) Development Version Control
- D) Dataset Versioning Control

**2. How does DVC store data files?**
- A) Directly in Git
- B) In DVC cache
- C) In the cloud only
- D) In a database

**3. What is the command to initialize DVC?**
- A) `dvc start`
- B) `dvc init`
- C) `dvc create`
- D) `dvc setup`

**4. What file is created when you run `dvc add`?**
- A) `.dvc` file
- B) `.dvc` directory
- C) `.dvc` cache
- D) `.dvcignore`

**5. Where is the actual data stored when using DVC?**
- A) In the Git repository
- B) In .dvc/cache/
- C) In a separate database
- D) In the cloud

**6. What is the purpose of `dvc status`?**
- A) Check Git status
- B) Check DVC tracking status
- C) Check pipeline status
- D) All of the above

**7. The command `dvc push` does what?**
- A) Uploads code to Git
- B) Uploads data to remote storage
- C) Uploads models to registry
- D) Uploads logs to server

**8. The command `dvc pull` does what?**
- A) Downloads code from Git
- B) Downloads data from remote storage
- C) Downloads models from registry
- D) Downloads logs from server

**9. What is the command to restore data from cache?**
- A) `dvc restore`
- B) `dvc checkout`
- C) `dvc reset`
- D) `dvc revert`

**10. What is the purpose of `.dvcignore`?**
- A) Ignore files in Git
- B) Ignore files in DVC
- C) Ignore files in Docker
- D) Ignore files in MLflow

**11. What is the MD5 hash used for in DVC?**
- A) Identifying files
- B) Encrypting files
- C) Compressing files
- D) Sorting files

**12. How does DVC track changes to data?**
- A) By file name
- B) By MD5 hash
- C) By modification date
- D) By file size

**13. What is the command to show tracked files?**
- A) `dvc list`
- B) `dvc show`
- C) `dvc track`
- D) `dvc files`

**14. What is the command to remove tracking from a file?**
- A) `dvc remove`
- B) `dvc rm`
- C) `dvc delete`
- D) `dvc untrack`

**15. How do you tag a specific version in DVC?**
- A) `dvc tag`
- B) `dvc version`
- C) `dvc label`
- D) `dvc mark`

### True/False

**16. DVC can track files larger than Git's limits.**
- ☐ True
- ☐ False

**17. DVC stores data directly in the Git repository.**
- ☐ True
- ☐ False

**18. DVC is only for Python projects.**
- ☐ True
- ☐ False

**19. DVC requires a remote storage to function.**
- ☐ True
- ☐ False

**20. DVC works well with Git for version control.**
- ☐ True
- ☐ False

---

## Quiz 1.2: DVC Pipelines

**Instructions:** Choose the best answer for each question.

### Multiple Choice

**1. What file defines a DVC pipeline?**
- A) `.dvc/pipeline`
- B) `dvc.yaml`
- C) `pipeline.yaml`
- D) `dvc.config`

**2. What is the command to run a DVC pipeline?**
- A) `dvc run`
- B) `dvc execute`
- C) `dvc repro`
- D) `dvc pipeline`

**3. What does "DAG" stand for?**
- A) Data Aggregation Graph
- B) Directed Acyclic Graph
- C) Data Analysis Graph
- D) Dynamic Action Graph

**4. In a DVC pipeline, what are `deps`?**
- A) Deployments
- B) Dependencies
- C) Deprecations
- D) Descriptions

**5. In a DVC pipeline, what are `outs`?**
- A) Outputs
- B) Outside files
- C) Optional files
- D) Outdated files

**6. What is the purpose of `params` in a DVC pipeline?**
- A) Define parameters
- B) Define dependencies
- C) Define outputs
- D) Define commands

**7. Which file stores DVC parameters?**
- A) `params.yaml`
- B) `parameters.yaml`
- C) `config.yaml`
- D) `dvc.yaml`

**8. What is the purpose of `dvc dag`?**
- A) View pipeline graph
- B) Download artifacts
- C) Debug pipeline
- D) Deploy pipeline

**9. What is the command to see what changed in a pipeline?**
- A) `dvc diff`
- B) `dvc status`
- C) `dvc changes`
- D) `dvc log`

**10. How does DVC determine which stages to run?**
- A) By hash comparison
- B) By timestamp
- C) By file size
- D) By user input

**11. What is the purpose of `dvc.lock`?**
- A) Lock files for editing
- B) Lock pipeline versions
- C) Lock data files
- D) Lock remote storage

**12. What is the command to force-reproduce a pipeline?**
- A) `dvc repro --force`
- B) `dvc repro --all`
- C) `dvc run --force`
- D) `dvc run --all`

**13. What are DVC metrics used for?**
- A) Tracking model performance
- B) Tracking data size
- C) Tracking pipeline speed
- D) Tracking code quality

**14. What is the command to show metrics?**
- A) `dvc metrics show`
- B) `dvc metrics display`
- C) `dvc metrics list`
- D) `dvc metrics view`

**15. How can you compare metrics across pipeline versions?**
- A) `dvc metrics diff`
- B) `dvc metrics compare`
- C) `dvc diff metrics`
- D) `dvc compare metrics`

### Fill in the Blank

**16. A DVC pipeline stage is defined with: `cmd`, `deps`, `outs`, and __________.**

**17. The __________ command shows the pipeline dependency graph.**

**18. DVC parameters are stored in __________.yaml.**

**19. The __________ file locks pipeline versions for reproducibility.**

**20. DVC metrics should be set with `cache: __________` to avoid caching.**

---

## Quiz 1.3: Remote Storage

**Instructions:** Choose the best answer for each question.

### Multiple Choice

**1. What is the command to add a remote storage?**
- A) `dvc remote add`
- B) `dvc add remote`
- C) `dvc store add`
- D) `dvc storage add`

**2. Which of these is NOT a supported DVC remote type?**
- A) S3
- B) GCS
- C) MySQL
- D) SSH

**3. What is the purpose of `dvc remote default`?**
- A) Set default remote
- B) View default remote
- C) Remove default remote
- D) All of the above

**4. How do you list configured remotes?**
- A) `dvc remote list`
- B) `dvc list remote`
- C) `dvc remote show`
- D) `dvc show remote`

**5. What is the correct S3 remote URL format?**
- A) `s3://bucket/path`
- B) `s3://bucket:path`
- C) `s3://path/bucket`
- D) `s3://bucket`

**6. How do you configure AWS credentials for DVC?**
- A) In `dvc.yaml`
- B) In `.env` or environment variables
- C) In `params.yaml`
- D) In `requirements.txt`

**7. What is the purpose of `dvc remote modify`?**
- A) Change remote configuration
- B) Modify remote data
- C) Change remote name
- D) Delete remote

**8. Which command uploads data to remote storage?**
- A) `dvc push`
- B) `dvc upload`
- C) `dvc sync`
- D) `dvc send`

**9. Which command downloads data from remote storage?**
- A) `dvc pull`
- B) `dvc download`
- C) `dvc sync`
- D) `dvc receive`

**10. What is the purpose of `dvc remote remove`?**
- A) Remove remote configuration
- B) Remove data from remote
- C) Remove remote file
- D) Remove remote directory

### True/False

**11. DVC remote storage is required for team collaboration.**
- ☐ True
- ☐ False

**12. You can use multiple remote storage types simultaneously.**
- ☐ True
- ☐ False

**13. Credentials should be hardcoded in DVC config files.**
- ☐ True
- ☐ False

**14. DVC supports server-side encryption for S3.**
- ☐ True
- ☐ False

**15. You can import data directly from remote storage.**
- ☐ True
- ☐ False

---

## Test 1: DVC Comprehensive

**Instructions:** This is a comprehensive test covering all DVC topics.

### Multiple Choice (1-15)

**1. What is the primary purpose of DVC?**
- A) Version control for code
- B) Version control for data and models
- C) Experiment tracking
- D) Pipeline orchestration

**2. Which command initializes DVC in a project?**
- A) `dvc start`
- B) `dvc init`
- C) `dvc setup`
- D) `dvc create`

**3. Where does DVC store data files?**
- A) Git repository
- B) `.dvc/cache`
- C) Remote server
- D) Database

**4. What is the purpose of `dvc add`?**
- A) Add file to Git
- B) Add file to DVC tracking
- C) Add remote storage
- D) Add pipeline stage

**5. What file is created by `dvc add`?**
- A) `.dvc` file
- B) `dvc.yaml`
- C) `params.yaml`
- D) `dvc.lock`

**6. What is the command to see DVC status?**
- A) `dvc status`
- B) `dvc check`
- C) `dvc state`
- D) `dvc view`

**7. What is the purpose of `dvc repro`?**
- A) Reproduce pipeline
- B) Reprocess data
- C) Retrain model
- D) Redeploy model

**8. Which file defines DVC pipeline stages?**
- A) `.dvc/config`
- B) `dvc.yaml`
- C) `pipeline.yaml`
- D) `dvc.pipeline`

**9. What is the purpose of `dvc dag`?**
- A) Show pipeline graph
- B) Show data graph
- C) Show dependency graph
- D) All of the above

**10. What is the command to push data to remote?**
- A) `dvc push`
- B) `dvc upload`
- C) `dvc sync`
- D) `dvc send`

**11. What is the purpose of `dvc pull`?**
- A) Pull code from Git
- B) Pull data from remote
- C) Pull pipeline from server
- D) Pull metrics from database

**12. What is the purpose of `dvc checkout`?**
- A) Checkout Git branch
- B) Restore data from cache
- C) Checkout pipeline stage
- D) Checkout remote storage

**13. Where are DVC parameters stored?**
- A) `dvc.yaml`
- B) `params.yaml`
- C) `dvc.lock`
- D) `.dvc/config`

**14. What is the purpose of `dvc.lock`?**
- A) Lock files for editing
- B) Lock pipeline version
- C) Lock remote storage
- D) Lock data cache

**15. How does DVC track file changes?**
- A) By timestamp
- B) By MD5 hash
- C) By file size
- D) By user input

### True/False (16-20)

**16. DVC can only be used with Git.**
- ☐ True
- ☐ False

**17. DVC supports multiple remote storage backends.**
- ☐ True
- ☐ False

**18. DVC pipelines are defined in `dvc.yaml`.**
- ☐ True
- ☐ False

**19. DVC can version files larger than Git's limits.**
- ☐ True
- ☐ False

**20. DVC metrics can be used to track model performance.**
- ☐ True
- ☐ False

### Short Answer (21-25)

**21. Explain the difference between DVC and Git.**

**22. Describe the purpose of a DVC pipeline and how it works.**

**23. What are the steps to set up DVC remote storage with AWS S3?**

**24. Explain how DVC ensures reproducibility.**

**25. Describe the DVC cache and its role in the system.**

---

# PART 2: MLFLOW (EXPERIMENT TRACKING)

## Quiz 2.1: MLflow Basics

**Instructions:** Choose the best answer for each question.

### Multiple Choice

**1. What is MLflow primarily used for?**
- A) Data versioning
- B) Experiment tracking and model management
- C) Pipeline orchestration
- D) Containerization

**2. Which of the following is NOT a main component of MLflow?**
- A) Tracking
- B) Projects
- C) Registry
- D) Data Versioning

**3. What is the command to start the MLflow UI?**
- A) `mlflow start`
- B) `mlflow ui`
- C) `mlflow web`
- D) `mlflow dashboard`

**4. What is an MLflow experiment?**
- A) A single run
- B) A container for runs
- C) A model version
- D) A parameter set

**5. What is an MLflow run?**
- A) A single execution
- B) An experiment container
- C) A model version
- D) A parameter set

**6. What is the purpose of `mlflow.log_param()`?**
- A) Log parameters to a run
- B) Log metrics to a run
- C) Log artifacts to a run
- D) Log models to a run

**7. What is the purpose of `mlflow.log_metric()`?**
- A) Log parameters to a run
- B) Log metrics to a run
- C) Log artifacts to a run
- D) Log models to a run

**8. What is the purpose of `mlflow.log_artifact()`?**
- A) Log parameters to a run
- B) Log metrics to a run
- C) Log files to a run
- D) Log models to a run

**9. What is the purpose of `mlflow.set_tracking_uri()`?**
- A) Set experiment name
- B) Set tracking server location
- C) Set run name
- D) Set model registry

**10. What is the purpose of `mlflow.set_experiment()`?**
- A) Set tracking URI
- B) Set active experiment
- C) Set run name
- D) Set model registry

**11. How do you start a run with MLflow?**
- A) `mlflow.start_run()`
- B) `mlflow.begin_run()`
- C) `mlflow.init_run()`
- D) `mlflow.create_run()`

**12. What is the purpose of MLflow tags?**
- A) Track parameters
- B) Add metadata
- C) Track metrics
- D) Store artifacts

**13. What is the default tracking URI for MLflow?**
- A) `http://localhost:5000`
- B) `file:./mlruns`
- C) `./mlflow`
- D) `local:./runs`

**14. Which file format is used for MLflow projects?**
- A) `MLproject`
- B) `project.yaml`
- C) `mlflow.yaml`
- D) `run.yaml`

**15. What is the purpose of `mlflow.sklearn.log_model()`?**
- A) Log sklearn model
- B) Log sklearn metrics
- C) Log sklearn parameters
- D) Log sklearn artifacts

### True/False

**16. MLflow only works with Python.**
- ☐ True
- ☐ False

**17. MLflow can track experiments on remote servers.**
- ☐ True
- ☐ False

**18. MLflow artifacts can include any type of file.**
- ☐ True
- ☐ False

**19. MLflow tracking requires a database backend.**
- ☐ True
- ☐ False

**20. MLflow supports multiple model flavors (sklearn, pytorch, etc.).**
- ☐ True
- ☐ False

---

## Quiz 2.2: MLflow Tracking

**Instructions:** Choose the best answer for each question.

### Multiple Choice

**1. What is the correct order for setting up MLflow tracking?**
- A) Set experiment → Set tracking URI → Start run
- B) Set tracking URI → Set experiment → Start run
- C) Start run → Set experiment → Set tracking URI
- D) Set experiment → Start run → Set tracking URI

**2. Which method is used to log multiple parameters?**
- A) `mlflow.log_params()`
- B) `mlflow.log_parameters()`
- C) `mlflow.set_params()`
- D) `mlflow.add_params()`

**3. Which method is used to log multiple metrics?**
- A) `mlflow.log_metrics()`
- B) `mlflow.log_metrics()`
- C) `mlflow.set_metrics()`
- D) `mlflow.add_metrics()`

**4. What is the purpose of the `step` parameter in `mlflow.log_metric()`?**
- A) Indicate training step
- B) Indicate batch size
- C) Indicate learning rate
- D) Indicate epoch number

**5. How do you log an image as an artifact?**
- A) `mlflow.log_image()`
- B) `mlflow.log_artifact()`
- C) `mlflow.log_figure()`
- D) `mlflow.save_image()`

**6. Which method is used to log a matplotlib figure?**
- A) `mlflow.log_image()`
- B) `mlflow.log_artifact()`
- C) `mlflow.log_figure()`
- D) `mlflow.save_figure()`

**7. What is the purpose of `mlflow.active_run()`?**
- A) Get current active run
- B) End current run
- C) Start new run
- D) Create new experiment

**8. How do you end an active run?**
- A) `mlflow.end_run()`
- B) `mlflow.finish_run()`
- C) `mlflow.stop_run()`
- D) `mlflow.close_run()`

**9. What is the purpose of `mlflow.search_runs()`?**
- A) Search for experiments
- B) Search for runs
- C) Search for models
- D) Search for artifacts

**10. Which method is used to log a dictionary as JSON?**
- A) `mlflow.log_dict()`
- B) `mlflow.log_json()`
- C) `mlflow.save_dict()`
- D) `mlflow.save_json()`

**11. What is the purpose of `mlflow.get_experiment_by_name()`?**
- A) Get experiment by ID
- B) Get experiment by name
- C) Create experiment
- D) Delete experiment

**12. Which method is used to create a new experiment?**
- A) `mlflow.create_experiment()`
- B) `mlflow.new_experiment()`
- C) `mlflow.add_experiment()`
- D) `mlflow.set_experiment()`

**13. What is the purpose of `mlflow.list_experiments()`?**
- A) List all runs
- B) List all experiments
- C) List all models
- D) List all artifacts

**14. How do you set tags on a run?**
- A) `mlflow.set_tags()`
- B) `mlflow.set_tag()`
- C) `mlflow.log_tags()`
- D) `mlflow.log_tag()`

**15. What is the purpose of `mlflow.get_run()`?**
- A) Get run by ID
- B) Get run by name
- C) Get run by experiment
- D) Get run by status

### Fill in the Blank

**16. The ____________ method logs multiple parameters to a run.**

**17. The ____________ method logs multiple metrics to a run.**

**18. MLflow uses the ____________ context manager to manage runs.**

**19. The ____________ parameter in `log_metric()` indicates the step number.**

**20. MLflow artifacts are stored in the ____________ store.**

---

## Quiz 2.3: Model Registry

**Instructions:** Choose the best answer for each question.

### Multiple Choice

**1. What is the MLflow Model Registry?**
- A) A place to store code
- B) A centralized model management system
- C) A data versioning tool
- D) A pipeline orchestration tool

**2. What are the three main stages in the Model Registry?**
- A) Development, Testing, Production
- B) Staging, Production, Archived
- C) Training, Validation, Deployment
- D) Dev, QA, Prod

**3. How do you create a model version in the registry?**
- A) `client.create_model_version()`
- B) `client.add_model_version()`
- C) `client.new_model_version()`
- D) `client.register_model()`

**4. What is the purpose of `client.transition_model_version_stage()`?**
- A) Create new version
- B) Transition between stages
- C) Delete version
- D) Update version

**5. Which client is used for registry operations?**
- A) `MlflowClient`
- B) `RegistryClient`
- C) `ModelClient`
- D) `TrackingClient`

**6. How do you get the latest version of a model?**
- A) `client.get_latest_versions()`
- B) `client.get_version()`
- C) `client.search_versions()`
- D) `client.find_version()`

**7. What is the purpose of model version tags?**
- A) Add metadata
- B) Track parameters
- C) Store metrics
- D) Store artifacts

**8. Which method updates model version description?**
- A) `client.update_model_version()`
- B) `client.set_model_version()`
- C) `client.modify_model_version()`
- D) `client.change_model_version()`

**9. How do you list all registered models?**
- A) `client.search_registered_models()`
- B) `client.list_models()`
- C) `client.get_models()`
- D) `client.find_models()`

**10. What is the purpose of archiving model versions?**
- A) Delete permanently
- B) Keep historical record
- C) Move to production
- D) Remove from registry

### True/False

**11. The Model Registry is part of MLflow.**
- ☐ True
- ☐ False

**12. Models can only be in one stage at a time.**
- ☐ True
- ☐ False

**13. Tags can be added to model versions.**
- ☐ True
- ☐ False

**14. The registry can integrate with CI/CD pipelines.**
- ☐ True
- ☐ False

**15. Models can be archived automatically when new versions are promoted.**
- ☐ True
- ☐ False

---

## Test 2: MLflow Comprehensive

**Instructions:** This is a comprehensive test covering all MLflow topics.

### Multiple Choice (1-15)

**1. What is MLflow primarily used for?**
- A) Data versioning
- B) Experiment tracking and model management
- C) Pipeline orchestration
- D) Containerization

**2. Which component of MLflow is used for experiment tracking?**
- A) Projects
- B) Tracking
- C) Models
- D) Registry

**3. What is the command to start the MLflow UI?**
- A) `mlflow ui`
- B) `mlflow start`
- C) `mlflow web`
- D) `mlflow dashboard`

**4. What is the purpose of `mlflow.log_param()`?**
- A) Log metrics
- B) Log parameters
- C) Log artifacts
- D) Log models

**5. Which method logs a scikit-learn model?**
- A) `mlflow.sklearn.log_model()`
- B) `mlflow.log_model()`
- C) `mlflow.sklearn.save_model()`
- D) `mlflow.save_model()`

**6. What is the default tracking URI?**
- A) `http://localhost:5000`
- B) `file:./mlruns`
- C) `./mlflow`
- D) `local:./runs`

**7. How do you set the active experiment?**
- A) `mlflow.set_experiment()`
- B) `mlflow.set_active_experiment()`
- C) `mlflow.select_experiment()`
- D) `mlflow.choose_experiment()`

**8. What is the purpose of the Model Registry?**
- A) Store code
- B) Manage model lifecycle
- C) Track experiments
- D) Version data

**9. What are the three stages in the Model Registry?**
- A) Dev, Test, Prod
- B) Staging, Production, Archived
- C) Dev, QA, Prod
- D) Training, Validation, Deployment

**10. Which client is used for registry operations?**
- A) `MlflowClient`
- B) `TrackingClient`
- C) `RegistryClient`
- D) `ModelClient`

**11. How do you transition a model stage?**
- A) `client.transition_model_version_stage()`
- B) `client.set_model_stage()`
- C) `client.change_model_stage()`
- D) `client.update_model_stage()`

**12. What is the purpose of MLflow tags?**
- A) Track parameters
- B) Add metadata
- C) Track metrics
- D) Store artifacts

**13. Which method logs multiple metrics?**
- A) `mlflow.log_metrics()`
- B) `mlflow.log_multiple_metrics()`
- C) `mlflow.set_metrics()`
- D) `mlflow.add_metrics()`

**14. What is the purpose of `mlflow.log_artifact()`?**
- A) Log parameters
- B) Log metrics
- C) Log files
- D) Log models

**15. How do you search for runs?**
- A) `mlflow.search_runs()`
- B) `mlflow.find_runs()`
- C) `mlflow.list_runs()`
- D) `mlflow.get_runs()`

### True/False (16-20)

**16. MLflow can log artifacts to cloud storage.**
- ☐ True
- ☐ False

**17. MLflow only supports Python.**
- ☐ True
- ☐ False

**18. The Model Registry requires a separate server.**
- ☐ True
- ☐ False

**19. MLflow can serve models as REST APIs.**
- ☐ True
- ☐ False

**20. Tags are only for experiments, not runs.**
- ☐ True
- ☐ False

### Short Answer (21-25)

**21. Explain the difference between parameters and metrics in MLflow.**

**22. Describe the process of registering a model in the MLflow Model Registry.**

**23. What are the benefits of using MLflow for experiment tracking?**

**24. Explain how MLflow handles artifacts.**

**25. Describe the model lifecycle in the MLflow Model Registry.**

---

# PART 3: DAGSTER (PIPELINE ORCHESTRATION)

## Quiz 3.1: Dagster Basics

**Instructions:** Choose the best answer for each question.

### Multiple Choice

**1. What is Dagster primarily used for?**
- A) Data versioning
- B) Experiment tracking
- C) Pipeline orchestration
- D) Model serving

**2. What does "DAG" stand for in Dagster?**
- A) Data Aggregation Graph
- B) Directed Acyclic Graph
- C) Data Analysis Graph
- D) Dynamic Action Graph

**3. What is the command to start the Dagster UI?**
- A) `dagster ui`
- B) `dagster-webserver`
- C) `dagster start`
- D) `dagster web`

**4. What is a Dagster "op"?**
- A) An operation or transformation
- B) An optimization
- C) An option
- D) An operator

**5. What is a Dagster "asset"?**
- A) A data artifact
- B) A model
- C) A parameter
- D) A metric

**6. What is a Dagster "job"?**
- A) A single op
- B) A graph of ops
- C) A schedule
- D) A sensor

**7. Which decorator is used to define an op?**
- A) `@dagster.op`
- B) `@op`
- C) `@task`
- D) `@step`

**8. Which decorator is used to define an asset?**
- A) `@dagster.asset`
- B) `@asset`
- C) `@data`
- D) `@artifact`

**9. Which decorator is used to define a job?**
- A) `@dagster.job`
- B) `@job`
- C) `@pipeline`
- D) `@workflow`

**10. What is the purpose of `context.log` in an op?**
- A) Log messages
- B) Track metrics
- C) Log parameters
- D) Store artifacts

**11. How do you execute a job from the command line?**
- A) `dagster job execute`
- B) `dagster run`
- C) `dagster start`
- D) `dagster launch`

**12. What is the purpose of resources in Dagster?**
- A) Shared services
- B) Data storage
- C) Model storage
- D) Logging

**13. What is an I/O manager in Dagster?**
- A) Data persistence
- B) Model persistence
- C) Parameter storage
- D) Log storage

**14. What is the purpose of `dagster-daemon`?**
- A) Run schedules and sensors
- B) Start the UI
- C) Execute jobs
- D) Manage storage

**15. Where does Dagster store run data?**
- A) In memory
- B) In a storage system
- C) In files
- D) In code

### True/False

**16. Dagster is an alternative to Airflow.**
- ☐ True
- ☐ False

**17. Dagster only supports Python.**
- ☐ True
- ☐ False

**18. Dagster has built-in testing support.**
- ☐ True
- ☐ False

**19. Dagster requires a database backend.**
- ☐ True
- ☐ False

**20. Dagster can integrate with MLflow and DVC.**
- ☐ True
- ☐ False

---

## Quiz 3.2: Assets and Ops

**Instructions:** Choose the best answer for each question.

### Multiple Choice

**1. What is the difference between an asset and an op?**
- A) Assets are data, ops are transformations
- B) Assets are transformations, ops are data
- C) They are the same
- D) Assets are for ML, ops are for data

**2. How do you define dependencies between assets?**
- A) By specifying `deps` in `@asset`
- B) By specifying `ins` in `@asset`
- C) By specifying `outs` in `@asset`
- D) By specifying `requires` in `@asset`

**3. What is the purpose of `AssetExecutionContext`?**
- A) Provide context to asset
- B) Define asset metadata
- C) Log asset metrics
- D) Store asset data

**4. How do you handle errors in an asset?**
- A) Raise exceptions
- B) Use try/except
- C) Return error value
- D) Use error handler

**5. What is a "multi-asset"?**
- A) Multiple outputs from one function
- B) Multiple assets in one file
- C) Multiple transformations
- D) Multiple data sources

**6. Which decorator is used for multi-assets?**
- A) `@multi_asset`
- B) `@multiple_asset`
- C) `@asset_group`
- D) `@assets`

**7. What is the purpose of `AssetOut`?**
- A) Define output of multi-asset
- B) Define input of asset
- C) Define asset metadata
- D) Define asset schedule

**8. How do you materialize an asset?**
- A) `materialize()`
- B) `run_asset()`
- C) `execute_asset()`
- D) `compute_asset()`

**9. What is the purpose of `IOManager`?**
- A) Handle data persistence
- B) Handle model persistence
- C) Handle parameter storage
- D) Handle log storage

**10. What is a "partitioned asset"?**
- A) Asset with partitions
- B) Asset with multiple outputs
- C) Asset with dependencies
- D) Asset with schedules

**11. How do you define a partition on an asset?**
- A) `partitions_def` parameter
- B) `partition` decorator
- C) `partition_key` parameter
- D) `partition_definition` parameter

**12. What is the purpose of `context.partition_key`?**
- A) Get current partition key
- B) Set partition key
- C) Define partition key
- D) Delete partition key

**13. How do you add metadata to an asset?**
- A) Use `context.add_metadata()`
- B) Use `metadata` parameter
- C) Use `context.metadata`
- D) Use `set_metadata()`

**14. What is a "dynamic asset"?**
- A) Asset that creates other assets
- B) Asset with dynamic data
- C) Asset with dynamic config
- D) Asset with dynamic schedule

**15. Which decorator is used for dynamic assets?**
- A) `@dynamic_asset`
- B) `@asset_dynamic`
- C) `@dynamic_asset_definition`
- D) `@dyn_asset`

### Fill in the Blank

**16. Assets are defined using the ____________ decorator.**

**17. Ops are defined using the ____________ decorator.**

**18. The ____________ parameter in `@asset` defines dependencies.**

**19. ____________ are used for data persistence in Dagster.**

**20. The ____________ context provides information about the current asset.**

---

## Quiz 3.3: Schedules and Sensors

**Instructions:** Choose the best answer for each question.

### Multiple Choice

**1. What is a schedule in Dagster?**
- A) Time-based trigger
- B) Event-based trigger
- C) Data trigger
- D) Model trigger

**2. What is a sensor in Dagster?**
- A) Time-based trigger
- B) Event-based trigger
- C) Data trigger
- D) Model trigger

**3. Which decorator is used for schedules?**
- A) `@schedule`
- B) `@scheduler`
- C) `@time_trigger`
- D) `@cron`

**4. Which decorator is used for sensors?**
- A) `@sensor`
- B) `@sensor_trigger`
- C) `@event_trigger`
- D) `@data_trigger`

**5. What is the format of cron schedule in Dagster?**
- A) Standard cron format
- B) Custom Dagster format
- C) Time interval format
- D) Date format

**6. What is the purpose of `RunRequest`?**
- A) Request a run
- B) Create a run
- C) Stop a run
- D) Monitor a run

**7. What is the purpose of `SkipReason`?**
- A) Skip a run
- B) Skip a schedule
- C) Skip a sensor
- D) Skip an op

**8. How do you update cursor in a sensor?**
- A) `context.update_cursor()`
- B) `context.set_cursor()`
- C) `context.save_cursor()`
- D) `context.store_cursor()`

**9. What is the purpose of `context.cursor`?**
- A) Track sensor state
- B) Track schedule state
- C) Track run state
- D) Track asset state

**10. How do you start a schedule from the command line?**
- A) `dagster schedule start`
- B) `dagster start schedule`
- C) `dagster run schedule`
- D) `dagster schedule enable`

**11. What is the purpose of `dagster-daemon`?**
- A) Run schedules and sensors
- B) Start the UI
- C) Execute jobs
- D) Manage storage

**12. How do you list schedules from the command line?**
- A) `dagster schedule list`
- B) `dagster list schedules`
- C) `dagster show schedules`
- D) `dagster display schedules`

**13. What is a "run status sensor"?**
- A) Triggers on run status change
- B) Triggers on schedule run
- C) Triggers on data change
- D) Triggers on model change

**14. Which decorator is used for run status sensors?**
- A) `@run_status_sensor`
- B) `@run_sensor`
- C) `@status_sensor`
- D) `@run_trigger`

**15. What is the purpose of a pipeline failure sensor?**
- A) Trigger on pipeline failure
- B) Trigger on pipeline success
- C) Trigger on pipeline start
- D) Trigger on pipeline progress

### True/False

**16. Schedules are time-based triggers.**
- ☐ True
- ☐ False

**17. Sensors are event-based triggers.**
- ☐ True
- ☐ False

**18. Cursors are used to track sensor state.**
- ☐ True
- ☐ False

**19. Schedules require a cron expression.**
- ☐ True
- ☐ False

**20. Sensors can monitor file changes.**
- ☐ True
- ☐ False

---

## Test 3: Dagster Comprehensive

**Instructions:** This is a comprehensive test covering all Dagster topics.

### Multiple Choice (1-15)

**1. What is Dagster primarily used for?**
- A) Data versioning
- B) Experiment tracking
- C) Pipeline orchestration
- D) Model serving

**2. What does "DAG" stand for?**
- A) Data Aggregation Graph
- B) Directed Acyclic Graph
- C) Data Analysis Graph
- D) Dynamic Action Graph

**3. Which decorator is used to define an op?**
- A) `@op`
- B) `@task`
- C) `@step`
- D) `@function`

**4. Which decorator is used to define an asset?**
- A) `@asset`
- B) `@data`
- C) `@artifact`
- D) `@object`

**5. Which decorator is used to define a job?**
- A) `@job`
- B) `@pipeline`
- C) `@workflow`
- D) `@graph`

**6. What is the purpose of resources in Dagster?**
- A) Shared services
- B) Data storage
- C) Model storage
- D) Logging

**7. What is a schedule in Dagster?**
- A) Time-based trigger
- B) Event-based trigger
- C) Data trigger
- D) Model trigger

**8. What is a sensor in Dagster?**
- A) Time-based trigger
- B) Event-based trigger
- C) Data trigger
- D) Model trigger

**9. Which decorator is used for schedules?**
- A) `@schedule`
- B) `@scheduler`
- C) `@time_trigger`
- D) `@cron`

**10. Which decorator is used for sensors?**
- A) `@sensor`
- B) `@sensor_trigger`
- C) `@event_trigger`
- D) `@data_trigger`

**11. How do you start the Dagster UI?**
- A) `dagster-webserver`
- B) `dagster ui`
- C) `dagster web`
- D) `dagster start`

**12. What is the purpose of `dagster-daemon`?**
- A) Run schedules and sensors
- B) Start the UI
- C) Execute jobs
- D) Manage storage

**13. What is an I/O manager?**
- A) Data persistence
- B) Model persistence
- C) Parameter storage
- D) Log storage

**14. How do you materialize an asset?**
- A) `materialize()`
- B) `run_asset()`
- C) `execute_asset()`
- D) `compute_asset()`

**15. What is the purpose of `RunRequest`?**
- A) Request a run
- B) Create a run
- C) Stop a run
- D) Monitor a run

### True/False (16-20)

**16. Dagster is an alternative to Airflow.**
- ☐ True
- ☐ False

**17. Dagster supports testing of ops and assets.**
- ☐ True
- ☐ False

**18. Schedules require a cron expression.**
- ☐ True
- ☐ False

**19. Sensors can monitor file changes.**
- ☐ True
- ☐ False

**20. Dagster can integrate with DVC and MLflow.**
- ☐ True
- ☐ False

### Short Answer (21-25)

**21. Explain the difference between an asset and an op in Dagster.**

**22. Describe how schedules and sensors differ in Dagster.**

**23. What is the purpose of I/O managers in Dagster?**

**24. Explain the role of resources in a Dagster pipeline.**

**25. Describe how to handle errors in a Dagster pipeline.**

---

# PART 4: INTEGRATION AND DEPLOYMENT

## Quiz 4.1: Integration

**Instructions:** Choose the best answer for each question.

### Multiple Choice

**1. How do you integrate DVC with Dagster?**
- A) Use a resource
- B) Use an op
- C) Use a schedule
- D) Use a sensor

**2. How do you integrate MLflow with Dagster?**
- A) Use a resource
- B) Use an op
- C) Use a schedule
- D) Use a sensor

**3. What is the purpose of data versioning in the pipeline?**
- A) Reproducibility
- B) Speed
- C) Cost reduction
- D) Simplicity

**4. What is the purpose of experiment tracking in the pipeline?**
- A) Compare model versions
- B) Speed up training
- C) Reduce code
- D) Simplify deployment

**5. What is the purpose of pipeline orchestration?**
- A) Automate workflows
- B) Speed up training
- C) Reduce code
- D) Simplify deployment

**6. How does DVC integrate with MLflow?**
- A) Log data version
- B) Log model version
- C) Log pipeline version
- D) Log code version

**7. What is the purpose of the Model Registry in the pipeline?**
- A) Manage model lifecycle
- B) Store code
- C) Track experiments
- D) Version data

**8. How do you deploy a model from the registry?**
- A) Load from registry
- B) Copy from registry
- C) Export from registry
- D) Transfer from registry

**9. What is the purpose of the master pipeline?**
- A) Orchestrate all steps
- B) Train models
- C) Process data
- D) Deploy models

**10. What does the end-to-end pipeline automate?**
- A) Entire ML lifecycle
- B) Data processing
- C) Model training
- D) Model deployment

### True/False

**11. DVC and MLflow can be used together in a pipeline.**
- ☐ True
- ☐ False

**12. Dagster can orchestrate both DVC and MLflow operations.**
- ☐ True
- ☐ False

**13. The Model Registry is separate from the pipeline.**
- ☐ True
- ☐ False

**14. Integration reduces manual steps in the ML lifecycle.**
- ☐ True
- ☐ False

**15. The master pipeline combines all components.**
- ☐ True
- ☐ False

---

## Quiz 4.2: Deployment

**Instructions:** Choose the best answer for each question.

### Multiple Choice

**1. What is a REST API deployment?**
- A) HTTP endpoints
- B) Batch processing
- C) Edge deployment
- D) Mobile deployment

**2. What is a batch deployment?**
- A) Scheduled predictions
- B) Real-time predictions
- C) Edge predictions
- D) Mobile predictions

**3. What is a blue-green deployment?**
- A) Zero-downtime switching
- B) Gradual rollout
- C) Canary release
- D) A/B testing

**4. What is a canary deployment?**
- A) Gradual rollout
- B) Zero-downtime switching
- C) A/B testing
- D) Batch processing

**5. What is the purpose of health checks?**
- A) Verify deployment
- B) Speed up deployment
- C) Reduce cost
- D) Simplify deployment

**6. How do you rollback a deployment?**
- A) Switch environments
- B) Delete deployment
- C) Restart service
- D) Update code

**7. What is the purpose of CI/CD?**
- A) Automate deployment
- B) Speed up training
- C) Reduce code
- D) Simplify development

**8. What is a Docker container?**
- A) Application packaging
- B) Data storage
- C) Model storage
- D) Code storage

**9. What is Kubernetes used for?**
- A) Container orchestration
- B) Experiment tracking
- C) Data versioning
- D) Pipeline definition

**10. What is the purpose of performance testing?**
- A) Verify speed and throughput
- B) Verify accuracy
- C) Verify data quality
- D) Verify security

### True/False

**11. REST APIs are used for real-time predictions.**
- ☐ True
- ☐ False

**12. Blue-green deployment has zero downtime.**
- ☐ True
- ☐ False

**13. Canary deployments are always safe.**
- ☐ True
- ☐ False

**14. CI/CD is optional for ML deployment.**
- ☐ True
- ☐ False

**15. Docker containers ensure environment consistency.**
- ☐ True
- ☐ False

---

## Quiz 4.3: Monitoring

**Instructions:** Choose the best answer for each question.

### Multiple Choice

**1. What are system metrics?**
- A) CPU, memory, disk
- B) Model accuracy
- C) User traffic
- D) Business metrics

**2. What are model metrics?**
- A) Accuracy, latency
- B) CPU, memory
- C) User traffic
- D) Business metrics

**3. What is the purpose of alerts?**
- A) Notify of issues
- B) Speed up system
- C) Reduce cost
- D) Simplify monitoring

**4. What is model drift?**
- A) Performance degradation
- B) Data change
- C) Model update
- D) System change

**5. What is the purpose of a dashboard?**
- A) Visualize metrics
- B) Store metrics
- C) Alert on metrics
- D) Process metrics

**6. What is the purpose of logging?**
- A) Record events
- B) Store metrics
- C) Alert on events
- D) Process events

**7. What is Prometheus used for?**
- A) Metrics collection
- B) Logging
- C) Alerting
- D) Visualization

**8. What is Grafana used for?**
- A) Visualization
- B) Metrics collection
- C) Alerting
- D) Logging

**9. What is the purpose of structured logging?**
- A) Parseable logs
- B) Human-readable logs
- C) Compact logs
- D) Secure logs

**10. What is the purpose of an alerting system?**
- A) Notify on conditions
- B) Store metrics
- C) Visualize data
- D) Process logs

### True/False

**11. Monitoring is important after deployment.**
- ☐ True
- ☐ False

**12. Alerts should only be for critical issues.**
- ☐ True
- ☐ False

**13. Model drift can be detected with monitoring.**
- ☐ True
- ☐ False

**14. Logs are optional in production systems.**
- ☐ True
- ☐ False

**15. Dashboards provide real-time visibility.**
- ☐ True
- ☐ False

---

## Test 4: Integration Comprehensive

**Instructions:** This is a comprehensive test covering all integration topics.

### Multiple Choice (1-15)

**1. How do you integrate DVC with Dagster?**
- A) Use a resource
- B) Use an op
- C) Use a schedule
- D) Use a sensor

**2. How do you integrate MLflow with Dagster?**
- A) Use a resource
- B) Use an op
- C) Use a schedule
- D) Use a sensor

**3. What is a REST API deployment?**
- A) HTTP endpoints
- B) Batch processing
- C) Edge deployment
- D) Mobile deployment

**4. What is a blue-green deployment?**
- A) Zero-downtime switching
- B) Gradual rollout
- C) Canary release
- D) A/B testing

**5. What is a canary deployment?**
- A) Gradual rollout
- B) Zero-downtime switching
- C) A/B testing
- D) Batch processing

**6. What are system metrics?**
- A) CPU, memory, disk
- B) Model accuracy
- C) User traffic
- D) Business metrics

**7. What are model metrics?**
- A) Accuracy, latency
- B) CPU, memory
- C) User traffic
- D) Business metrics

**8. What is the purpose of alerts?**
- A) Notify of issues
- B) Speed up system
- C) Reduce cost
- D) Simplify monitoring

**9. What is model drift?**
- A) Performance degradation
- B) Data change
- C) Model update
- D) System change

**10. What is the purpose of CI/CD?**
- A) Automate deployment
- B) Speed up training
- C) Reduce code
- D) Simplify development

**11. What is Docker used for?**
- A) Containerization
- B) Experiment tracking
- C) Data versioning
- D) Pipeline orchestration

**12. What is Kubernetes used for?**
- A) Container orchestration
- B) Experiment tracking
- C) Data versioning
- D) Pipeline definition

**13. What is Prometheus used for?**
- A) Metrics collection
- B) Logging
- C) Alerting
- D) Visualization

**14. What is Grafana used for?**
- A) Visualization
- B) Metrics collection
- C) Alerting
- D) Logging

**15. What does the end-to-end pipeline automate?**
- A) Entire ML lifecycle
- B) Data processing
- C) Model training
- D) Model deployment

### True/False (16-20)

**16. DVC, MLflow, and Dagster can be integrated together.**
- ☐ True
- ☐ False

**17. Blue-green deployment has zero downtime.**
- ☐ True
- ☐ False

**18. Monitoring is optional after deployment.**
- ☐ True
- ☐ False

**19. CI/CD is essential for automated deployment.**
- ☐ True
- ☐ False

**20. Docker containers ensure environment consistency.**
- ☐ True
- ☐ False

### Short Answer (21-25)

**21. Describe how DVC, MLflow, and Dagster work together in a complete pipeline.**

**22. Explain the difference between blue-green and canary deployments.**

**23. What metrics should be monitored in a production ML system?**

**24. Describe the purpose of CI/CD in MLOps.**

**25. Explain how to handle model drift in production.**

---

# FINAL EXAM: MLOps Pipeline Engineering

## Comprehensive Final Examination

**Instructions:** This is a comprehensive final exam covering all topics from the course. Answer all questions to the best of your ability.

**Time Limit:** 3 hours
**Total Points:** 200

---

## Section 1: Multiple Choice (50 questions, 2 points each = 100 points)

**1. What does MLOps stand for?**
- A) Machine Learning Operations
- B) Model Lifecycle Operations
- C) Machine Language Operations
- D) Model Learning Operations

**2. Which of the following is NOT a key component of MLOps?**
- A) Data versioning
- B) Experiment tracking
- C) Front-end development
- D) Pipeline orchestration

**3. DVC is primarily used for:**
- A) Experiment tracking
- B) Data versioning
- C) Pipeline orchestration
- D) Model deployment

**4. MLflow is primarily used for:**
- A) Data versioning
- B) Experiment tracking
- C) Pipeline orchestration
- D) Containerization

**5. Dagster is primarily used for:**
- A) Data versioning
- B) Experiment tracking
- C) Pipeline orchestration
- D) Model serving

**6. What is the command to initialize DVC?**
- A) `dvc start`
- B) `dvc init`
- C) `dvc create`
- D) `dvc setup`

**7. Where does DVC store data files?**
- A) Git repository
- B) `.dvc/cache`
- C) Remote server
- D) Database

**8. What is the purpose of `dvc repro`?**
- A) Reproduce pipeline
- B) Reprocess data
- C) Retrain model
- D) Redeploy model

**9. Which file defines DVC pipeline stages?**
- A) `.dvc/config`
- B) `dvc.yaml`
- C) `pipeline.yaml`
- D) `dvc.pipeline`

**10. What is the command to start the MLflow UI?**
- A) `mlflow start`
- B) `mlflow ui`
- C) `mlflow web`
- D) `mlflow dashboard`

**11. What is an MLflow experiment?**
- A) A single run
- B) A container for runs
- C) A model version
- D) A parameter set

**12. What is the purpose of `mlflow.log_param()`?**
- A) Log parameters to a run
- B) Log metrics to a run
- C) Log artifacts to a run
- D) Log models to a run

**13. What is the purpose of `mlflow.log_metric()`?**
- A) Log parameters to a run
- B) Log metrics to a run
- C) Log artifacts to a run
- D) Log models to a run

**14. What is the purpose of the Model Registry?**
- A) Store code
- B) Manage model lifecycle
- C) Track experiments
- D) Version data

**15. What are the three stages in the Model Registry?**
- A) Dev, Test, Prod
- B) Staging, Production, Archived
- C) Dev, QA, Prod
- D) Training, Validation, Deployment

**16. What is Dagster primarily used for?**
- A) Data versioning
- B) Experiment tracking
- C) Pipeline orchestration
- D) Model serving

**17. What does "DAG" stand for in Dagster?**
- A) Data Aggregation Graph
- B) Directed Acyclic Graph
- C) Data Analysis Graph
- D) Dynamic Action Graph

**18. Which decorator is used to define an op?**
- A) `@op`
- B) `@task`
- C) `@step`
- D) `@function`

**19. Which decorator is used to define an asset?**
- A) `@asset`
- B) `@data`
- C) `@artifact`
- D) `@object`

**20. Which decorator is used to define a job?**
- A) `@job`
- B) `@pipeline`
- C) `@workflow`
- D) `@graph`

**21. What is a schedule in Dagster?**
- A) Time-based trigger
- B) Event-based trigger
- C) Data trigger
- D) Model trigger

**22. What is a sensor in Dagster?**
- A) Time-based trigger
- B) Event-based trigger
- C) Data trigger
- D) Model trigger

**23. How do you start the Dagster UI?**
- A) `dagster-webserver`
- B) `dagster ui`
- C) `dagster web`
- D) `dagster start`

**24. What is the purpose of `dagster-daemon`?**
- A) Run schedules and sensors
- B) Start the UI
- C) Execute jobs
- D) Manage storage

**25. How do you integrate DVC with Dagster?**
- A) Use a resource
- B) Use an op
- C) Use a schedule
- D) Use a sensor

**26. How do you integrate MLflow with Dagster?**
- A) Use a resource
- B) Use an op
- C) Use a schedule
- D) Use a sensor

**27. What is a REST API deployment?**
- A) HTTP endpoints
- B) Batch processing
- C) Edge deployment
- D) Mobile deployment

**28. What is a blue-green deployment?**
- A) Zero-downtime switching
- B) Gradual rollout
- C) Canary release
- D) A/B testing

**29. What is a canary deployment?**
- A) Gradual rollout
- B) Zero-downtime switching
- C) A/B testing
- D) Batch processing

**30. What are system metrics?**
- A) CPU, memory, disk
- B) Model accuracy
- C) User traffic
- D) Business metrics

**31. What are model metrics?**
- A) Accuracy, latency
- B) CPU, memory
- C) User traffic
- D) Business metrics

**32. What is the purpose of alerts?**
- A) Notify of issues
- B) Speed up system
- C) Reduce cost
- D) Simplify monitoring

**33. What is model drift?**
- A) Performance degradation
- B) Data change
- C) Model update
- D) System change

**34. What is the purpose of CI/CD?**
- A) Automate deployment
- B) Speed up training
- C) Reduce code
- D) Simplify development

**35. What is Docker used for?**
- A) Containerization
- B) Experiment tracking
- C) Data versioning
- D) Pipeline orchestration

**36. What is Kubernetes used for?**
- A) Container orchestration
- B) Experiment tracking
- C) Data versioning
- D) Pipeline definition

**37. What is Prometheus used for?**
- A) Metrics collection
- B) Logging
- C) Alerting
- D) Visualization

**38. What is Grafana used for?**
- A) Visualization
- B) Metrics collection
- C) Alerting
- D) Logging

**39. What is the purpose of the master pipeline?**
- A) Orchestrate all steps
- B) Train models
- C) Process data
- D) Deploy models

**40. What does the end-to-end pipeline automate?**
- A) Entire ML lifecycle
- B) Data processing
- C) Model training
- D) Model deployment

**41. What is an I/O manager in Dagster?**
- A) Data persistence
- B) Model persistence
- C) Parameter storage
- D) Log storage

**42. What is the purpose of resources in Dagster?**
- A) Shared services
- B) Data storage
- C) Model storage
- D) Logging

**43. How do you materialize an asset?**
- A) `materialize()`
- B) `run_asset()`
- C) `execute_asset()`
- D) `compute_asset()`

**44. What is the purpose of `RunRequest`?**
- A) Request a run
- B) Create a run
- C) Stop a run
- D) Monitor a run

**45. What is the purpose of `context.cursor`?**
- A) Track sensor state
- B) Track schedule state
- C) Track run state
- D) Track asset state

**46. What is the purpose of the Model Registry?**
- A) Manage model lifecycle
- B) Store code
- C) Track experiments
- D) Version data

**47. How do you transition a model stage?**
- A) `client.transition_model_version_stage()`
- B) `client.set_model_stage()`
- C) `client.change_model_stage()`
- D) `client.update_model_stage()`

**48. What is the purpose of structured logging?**
- A) Parseable logs
- B) Human-readable logs
- C) Compact logs
- D) Secure logs

**49. What is the purpose of the DVC pipeline?**
- A) Automate data processing
- B) Track code
- C) Deploy models
- D) Monitor metrics

**50. What is the purpose of MLflow tracking?**
- A) Log experiments
- B) Version data
- C) Orchestrate pipelines
- D) Deploy models

---

## Section 2: True/False (25 questions, 2 points each = 50 points)

**51.** MLOps combines ML, DevOps, and Data Engineering.
- ☐ True
- ☐ False

**52.** Data versioning is optional in production ML systems.
- ☐ True
- ☐ False

**53.** Experiment tracking helps with reproducibility.
- ☐ True
- ☐ False

**54.** DVC can track files larger than Git's limits.
- ☐ True
- ☐ False

**55.** DVC stores data directly in the Git repository.
- ☐ True
- ☐ False

**56.** DVC pipelines are defined in `dvc.yaml`.
- ☐ True
- ☐ False

**57.** MLflow only works with Python.
- ☐ True
- ☐ False

**58.** MLflow can log artifacts to cloud storage.
- ☐ True
- ☐ False

**59.** The Model Registry is part of MLflow.
- ☐ True
- ☐ False

**60.** Dagster is an alternative to Airflow.
- ☐ True
- ☐ False

**61.** Dagster supports testing of ops and assets.
- ☐ True
- ☐ False

**62.** Schedules require a cron expression.
- ☐ True
- ☐ False

**63.** Sensors can monitor file changes.
- ☐ True
- ☐ False

**64.** Dagster can integrate with DVC and MLflow.
- ☐ True
- ☐ False

**65.** DVC and MLflow can be used together in a pipeline.
- ☐ True
- ☐ False

**66.** REST APIs are used for real-time predictions.
- ☐ True
- ☐ False

**67.** Blue-green deployment has zero downtime.
- ☐ True
- ☐ False

**68.** CI/CD is optional for ML deployment.
- ☐ True
- ☐ False

**69.** Docker containers ensure environment consistency.
- ☐ True
- ☐ False

**70.** Monitoring is important after deployment.
- ☐ True
- ☐ False

**71.** Alerts should only be for critical issues.
- ☐ True
- ☐ False

**72.** Model drift can be detected with monitoring.
- ☐ True
- ☐ False

**73.** The master pipeline combines all components.
- ☐ True
- ☐ False

**74.** Integration reduces manual steps in the ML lifecycle.
- ☐ True
- ☐ False

**75.** DVC, MLflow, and Dagster can be integrated together.
- ☐ True
- ☐ False

---

## Section 3: Short Answer (10 questions, 5 points each = 50 points)

**76.** Explain the difference between DVC and Git.

**77.** Describe the purpose of a DVC pipeline and how it works.

**78.** Explain the difference between parameters and metrics in MLflow.

**79.** Describe the process of registering a model in the MLflow Model Registry.

**80.** Explain the difference between an asset and an op in Dagster.

**81.** Describe how schedules and sensors differ in Dagster.

**82.** Describe how DVC, MLflow, and Dagster work together in a complete pipeline.

**83.** Explain the difference between blue-green and canary deployments.

**84.** What metrics should be monitored in a production ML system?

**85.** Explain how to handle model drift in production.

---

# ANSWER KEYS

## Quiz 0.1: MLOps Fundamentals

**Multiple Choice:**
1. A
2. C
3. C
4. B
5. A
6. C
7. B
8. B
9. C
10. B

**True/False:**
11. True
12. False
13. True
14. False
15. True

---

## Quiz 0.2: Tools and Architecture

**Multiple Choice:**
1. B
2. B
3. C
4. C
5. C
6. B
7. C
8. A
9. A
10. B

**Fill in the Blank:**
11. Data Versioning, Experiment Tracking, Pipeline Orchestration
12. Data Version Control
13. Tracking, Projects, Models, Registry
14. orchestration
15. failures

---

## Quiz 1.1: DVC Basics

**Multiple Choice:**
1. A
2. B
3. B
4. A
5. B
6. B
7. B
8. B
9. B
10. B
11. A
12. B
13. A
14. B
15. A

**True/False:**
16. True
17. False
18. False
19. False
20. True

---

## Quiz 1.2: DVC Pipelines

**Multiple Choice:**
1. B
2. C
3. B
4. B
5. A
6. A
7. A
8. A
9. B
10. A
11. B
12. A
13. A
14. A
15. A

**Fill in the Blank:**
16. params
17. dvc dag
18. params
19. dvc.lock
20. false

---

## Quiz 1.3: Remote Storage

**Multiple Choice:**
1. A
2. C
3. D
4. A
5. A
6. B
7. A
8. A
9. A
10. A

**True/False:**
11. True
12. True
13. False
14. True
15. True

---

## Test 1: DVC Comprehensive

**Multiple Choice:**
1. B
2. B
3. B
4. B
5. A
6. A
7. A
8. B
9. D
10. A
11. B
12. B
13. B
14. B
15. B

**True/False:**
16. False
17. True
18. True
19. True
20. True

**Short Answer:**
21. Git is for code versioning; DVC is for data versioning. Git stores code changes, while DVC stores pointers to large files in a separate cache.

22. A DVC pipeline defines a series of data processing steps. Each step has dependencies (inputs) and outputs. DVC tracks changes and only runs steps that need updating.

23. 1. Create S3 bucket, 2. Add remote with `dvc remote add`, 3. Configure credentials via environment variables, 4. Set as default with `dvc remote default`

24. DVC ensures reproducibility by tracking file hashes, pipeline dependencies, and parameters. Every stage has defined inputs and outputs, making it reproducible.

25. The DVC cache stores all versioned data in `.dvc/cache/`. It uses MD5 hashes to identify files and creates symlinks to the cache for versioned files.

---

## Quiz 2.1: MLflow Basics

**Multiple Choice:**
1. B
2. D
3. B
4. B
5. A
6. A
7. B
8. C
9. B
10. B
11. A
12. B
13. B
14. A
15. A

**True/False:**
16. False
17. True
18. True
19. False
20. True

---

## Quiz 2.2: MLflow Tracking

**Multiple Choice:**
1. B
2. A
3. A
4. A
5. B
6. C
7. A
8. A
9. B
10. A
11. B
12. A
13. B
14. B
15. A

**Fill in the Blank:**
16. log_params
17. log_metrics
18. with
19. step
20. artifact

---

## Quiz 2.3: Model Registry

**Multiple Choice:**
1. B
2. B
3. A
4. B
5. A
6. A
7. A
8. A
9. A
10. B

**True/False:**
11. True
12. False
13. True
14. True
15. True

---

## Test 2: MLflow Comprehensive

**Multiple Choice:**
1. B
2. B
3. A
4. B
5. A
6. B
7. A
8. B
9. B
10. A
11. A
12. B
13. A
14. C
15. A

**True/False:**
16. True
17. False
18. True
19. True
20. False

**Short Answer:**
21. Parameters are input values (hyperparameters) that are set before training. Metrics are output values (accuracy, loss) that are computed during/after training.

22. 1. Create a model version from a run, 2. Register it in the registry, 3. Transition to Staging, 4. Test the model, 5. Transition to Production, 6. Archive old versions.

23. Reproducibility, comparison of experiments, tracking of model lineage, collaboration, and governance of model lifecycle.

24. Artifacts are files logged with a run. They are stored in the artifact store (local or cloud) and can include models, plots, data, and other files.

25. Development → Staging (testing) → Production (serving) → Archived (historical). Each stage represents a phase in the model's lifecycle.

---

## Quiz 3.1: Dagster Basics

**Multiple Choice:**
1. C
2. B
3. B
4. A
5. A
6. B
7. B
8. B
9. B
10. A
11. A
12. A
13. A
14. A
15. B

**True/False:**
16. True
17. False
18. True
19. False
20. True

---

## Quiz 3.2: Assets and Ops

**Multiple Choice:**
1. A
2. A
3. A
4. B
5. A
6. A
7. A
8. A
9. A
10. A
11. A
12. A
13. A
14. A
15. A

**Fill in the Blank:**
16. @asset
17. @op
18. deps
19. I/O managers
20. AssetExecutionContext

---

## Quiz 3.3: Schedules and Sensors

**Multiple Choice:**
1. A
2. B
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A
11. A
12. A
13. A
14. A
15. A

**True/False:**
16. True
17. True
18. True
19. True
20. True

---

## Test 3: Dagster Comprehensive

**Multiple Choice:**
1. C
2. B
3. A
4. A
5. A
6. A
7. A
8. B
9. A
10. A
11. A
12. A
13. A
14. A
15. A

**True/False:**
16. True
17. True
18. True
19. True
20. True

**Short Answer:**
21. An asset represents data (a file, table, etc.) that is created by an op. An op is a transformation that takes inputs and produces outputs.

22. Schedules are time-based triggers (cron). Sensors are event-based triggers that respond to external conditions (file changes, API calls, etc.).

23. I/O managers handle data persistence, defining how inputs are loaded and outputs are saved. They abstract storage details from ops.

24. Resources are shared services (database connections, API clients) that can be used by multiple ops. They handle setup/cleanup and dependency injection.

25. Use try/except blocks, retry policies for transient errors, failure hooks for notifications, and fallback ops for recovery.

---

## Quiz 4.1: Integration

**Multiple Choice:**
1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A

**True/False:**
11. True
12. True
13. False
14. True
15. True

---

## Quiz 4.2: Deployment

**Multiple Choice:**
1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A

**True/False:**
11. True
12. True
13. False
14. False
15. True

---

## Quiz 4.3: Monitoring

**Multiple Choice:**
1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A

**True/False:**
11. True
12. False
13. True
14. False
15. True

---

## Test 4: Integration Comprehensive

**Multiple Choice:**
1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A
11. A
12. A
13. A
14. A
15. A

**True/False:**
16. True
17. True
18. False
19. True
20. True

**Short Answer:**
21. DVC version data, MLflow tracks experiments, Dagster orchestrates the pipeline. They work together to automate the ML lifecycle from data to deployment.

22. Blue-green switches between two complete environments. Canary gradually rolls out to a subset of users before full deployment.

23. System metrics (CPU, memory, disk), model metrics (accuracy, latency, throughput), data quality metrics, and business metrics.

24. CI/CD automates testing, building, and deployment of ML models. It ensures consistent, reliable deployments with rollback capabilities.

25. Monitor model performance over time, detect drift with statistical tests, retrain when drift is detected, and have rollback mechanisms ready.

---

## Final Exam Answer Key

### Section 1: Multiple Choice (1-50)

1. A
2. C
3. B
4. B
5. C
6. B
7. B
8. A
9. B
10. B
11. B
12. A
13. B
14. B
15. B
16. C
17. B
18. A
19. A
20. A
21. A
22. B
23. A
24. A
25. A
26. A
27. A
28. A
29. A
30. A
31. A
32. A
33. A
34. A
35. A
36. A
37. A
38. A
39. A
40. A
41. A
42. A
43. A
44. A
45. A
46. A
47. A
48. A
49. A
50. A

### Section 2: True/False (51-75)

51. True
52. False
53. True
54. True
55. False
56. True
57. False
58. True
59. True
60. True
61. True
62. True
63. True
64. True
65. True
66. True
67. True
68. False
69. True
70. True
71. False
72. True
73. True
74. True
75. True

### Section 3: Short Answer (76-85)

**76.** Git is for code versioning; DVC is for data versioning. Git stores code changes efficiently but cannot handle large files. DVC stores pointers to large files in Git while keeping the actual data in a separate cache or remote storage.

**77.** A DVC pipeline defines a series of data processing steps with dependencies. Each stage has a command, dependencies (inputs), and outputs. DVC tracks changes via file hashes and only runs stages whose dependencies have changed, ensuring efficient and reproducible execution.

**78.** Parameters are input values (hyperparameters) that are set before training and remain fixed during training. Metrics are output values (accuracy, loss) that are computed during or after training and can vary between runs.

**79.** 1. Train a model and get a run ID from MLflow tracking, 2. Use `client.create_model_version()` to register the model, 3. The model is assigned a version number, 4. Transition to Staging with `client.transition_model_version_stage()`, 5. After validation, transition to Production, 6. Old production versions are archived automatically.

**80.** An asset represents data (a file, table, or other artifact) that is created by the pipeline. An op is a transformation function that takes inputs and produces outputs. Assets focus on what data exists, while ops focus on how data is transformed.

**81.** Schedules are time-based triggers that run at specified times (cron). Sensors are event-based triggers that react to external conditions like file changes, API calls, or database updates. Schedules are for regular intervals, sensors are for reactive workflows.

**82.** DVC versions the data, MLflow tracks the experiments and models, and Dagster orchestrates the entire workflow. Dagster calls DVC to pull data and run data pipelines, then calls MLflow to track training runs and register models. This creates an end-to-end automated pipeline.

**83.** Blue-green deployment maintains two identical environments (blue and green). Traffic is switched instantly from one to the other, allowing zero-downtime and easy rollback. Canary deployment gradually shifts traffic to the new version, starting with a small percentage and increasing if no issues are detected.

**84.** System metrics (CPU, memory, disk, network), model performance metrics (accuracy, latency, throughput), data quality metrics (missing values, schema validation), business metrics (predictions per day, conversion rates), and drift metrics (feature drift, concept drift).

**85.** Monitor model performance over time using metrics like accuracy and F1. Use statistical tests (KS test) to detect feature drift. Set up automated retraining when drift is detected. Use A/B testing to validate new models before full deployment. Have a rollback mechanism ready if performance degrades.

---

**END OF ANSWER KEYS**

---

## Scoring Guide

| Section | Questions | Points | Maximum |
|---------|-----------|--------|---------|
| Part 0 | 25 | 2 each | 50 |
| Part 1 | 85 | 2-5 each | 200 |
| Part 2 | 85 | 2-5 each | 200 |
| Part 3 | 85 | 2-5 each | 200 |
| Part 4 | 70 | 2-5 each | 175 |
| **Final Exam** | **100** | **2 each** | **200** |

### Grade Conversion

| Percentage | Grade | Performance |
|------------|-------|-------------|
| 90-100% | A | Excellent |
| 80-89% | B | Good |
| 70-79% | C | Satisfactory |
| 60-69% | D | Needs Improvement |
| Below 60% | F | Unsatisfactory |

---

**End of Quiz and Test Bank**

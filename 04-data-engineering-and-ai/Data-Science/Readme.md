# 🚀 Data Science & Analytics Engineering Curriculum

A comprehensive, production-ready curriculum designed to take you from raw data processing to robust MLOps and responsible AI engineering.

## Core Curriculum Map

```text
  [1. Data Wrangling & SQL Engine]
                 │
                 ▼
  [2. Exploratory Analysis & Viz]
                 │
                 ▼
  [3. Applied Stats & Inference]
                 │
                 ▼
  [4. Machine Learning & Feature Prep]
                 │
                 ▼
  [5. Engineering, MLOps & Pipelines]
                 │
                 ▼
  [6. Analytics Storytelling & Ethics]

```

---

## Phase 1: Data Processing, Storage & Validation

*Focus: Master memory management, vectorized operations, analytical SQL, and automated data quality constraints.*

### Module 1.1: Modern DataFrame Engines & Vectorization

* **Core Concepts:** In-memory execution models, contiguous memory layouts (Apache Arrow), vectorized operations vs. Python loops, and lazy evaluation vs. eager execution.
* **Key Topics:**
* **NumPy:** N-dimensional arrays, broadcasting rules, vectorization, and memory views.
* **Pandas:** `DataFrame` and `Series` internal architecture, indexing mechanics, method chaining, and performance anti-patterns (e.g., `iterrows`).
* **Polars:** Multi-threaded query engine, lazy contexts (`lazy()`), expression syntax, streaming large-than-RAM datasets, and benchmarking against Pandas.



### Module 1.2: Analytical SQL & DB Engines

* **Core Concepts:** OLAP vs. OLTP database engines, set-based thinking, window framing, and embedded analytical databases.
* **Key Topics:**
* **PostgreSQL:** Relational modeling, normalization (3NF), indexing strategies (B-Tree, GIN), joins, and query plan analysis (`EXPLAIN ANALYZE`).
* **DuckDB:** Embedded analytical engine, querying Parquet/CSV directly, zero-copy data sharing with Arrow/Polars, and fast aggregations.
* **Advanced SQL:** Common Table Expressions (CTEs), recursive queries, and window functions (`ROW_NUMBER`, `RANK`, `LAG`/`LEAD`, window frames `ROWS BETWEEN`).



### Module 1.3: Data Quality, Schema Management & Validation

* **Core Concepts:** Schema enforcement, data drift, structural validation, and automated assertion checks.
* **Key Topics:**
* Detecting missing value patterns (MCAR, MAR, MNAR), duplicates, and distribution shifts.
* Schema validation using **Pandera** and **Pydantic**.
* Defining structural constraints, null checks, data type casting, and anomaly bounds within automated pipelines.



> **Phase 1 Capstone:** Build a high-throughput ETL data ingestion module that queries a multi-gigabyte raw dataset using DuckDB and Polars, runs schema and data-quality checks using Pandera, and outputs partitioned Parquet files.

---

## Phase 2: Exploratory Data Analysis & Visualization

*Focus: Develop intuition for multi-dimensional data structures, distribution profiling, and declarative plotting frameworks.*

### Module 2.1: Systematic EDA & Data Profiling

* **Core Concepts:** Univariate, bivariate, and multivariate analysis; robust statistical profiling; identifying signal vs. noise.
* **Key Topics:**
* Profiling numerical and categorical feature distributions (skewness, kurtosis, cardinality).
* Correlation analysis (Pearson, Spearman, Cramér's V) and collinearity detection.
* Automated EDA vs. custom visual inspection techniques.



### Module 2.2: Static & Declarative Visualizations

* **Core Concepts:** Visual encodings, grammar of graphics, Gestalt principles of perception, and publication-ready charting.
* **Key Topics:**
* **Matplotlib:** Object-oriented API, custom layouts (`GridSpec`), axes formatting, and annotations.
* **Seaborn:** Statistical charting (distribution plots, categorical plots, multi-plot grids like `FacetGrid`).
* **Altair:** Declarative visualization based on Vega-Lite, mapping data to visual channels (`x`, `y`, `color`, `size`), and transform expressions.



### Module 2.3: Interactive Data Exploration

* **Core Concepts:** Dynamic filtering, spatial data visualization, hover details, and interactive chart composition.
* **Key Topics:**
* **Plotly Express / Graph Objects:** Interactive scatter, line, bar, heatmaps, and 3D surface charts.
* Implementing dynamic sliders, cross-filtering, and drill-down capabilities.



> **Phase 2 Capstone:** Create an exploratory analysis report combining static publication-ready figures (Altair/Seaborn) and an interactive multi-chart dashboard (Plotly) isolating key behavioral drivers in a complex customer dataset.

---

## Phase 3: Applied Statistics & Hypothesis Testing

*Focus: Build mathematical rigor for evaluating experiments, modeling relationships, and validating business decisions.*

### Module 3.1: Descriptive & Inferential Foundations

* **Core Concepts:** Probability theory, Central Limit Theorem, confidence intervals, and sampling methods.
* **Key Topics:**
* Parametric vs. non-parametric distributions (Normal, Binomial, Poisson, Exponential).
* Calculating point estimates, standard errors, and confidence bounds using **SciPy**.
* Quantifying uncertainty in sample metrics.



### Module 3.2: Hypothesis Testing & Experimental Design

* **Core Concepts:** Null vs. alternative hypotheses, Type I & Type II errors, statistical power, and effect size.
* **Key Topics:**
* Designing and evaluating A/B tests (sample size determination, power analysis).
* Parametric tests: Student's t-test, Paired t-test, ANOVA.
* Non-parametric and categorical tests: Chi-Square test of independence, Mann-Whitney U test.
* Multiple testing correction (Bonferroni, False Discovery Rate).



### Module 3.3: Statistical Modeling & Diagnostic Analysis

* **Core Concepts:** Ordinary Least Squares (OLS), Maximum Likelihood Estimation (MLE), and model goodness-of-fit.
* **Key Topics:**
* **Linear & Logistic Regression:** Fitting models via **Statsmodels**, interpreting coefficients, odds ratios, and p-values.
* Diagnostic evaluations: Residual normality, homoscedasticity, Multicollinearity (Variance Inflation Factor), and leverage points.



> **Phase 3 Capstone:** Design, execute, and analyze an A/B test on a simulated conversion dataset, including sample size sizing, statistical significance testing, power calculation, and a regression-based diagnostic model using Statsmodels.

---

## Phase 4: Machine Learning & Predictive Modeling

*Focus: Master end-to-end predictive pipelines, from preprocessing raw features to training, evaluating, and fine-tuning models.*

### Module 4.1: Feature Prep & Engineering

* **Core Concepts:** Data leakage prevention, encoding spaces, dimensionality reduction, and handling imbalance.
* **Key Topics:**
* Imputation strategies and scaling techniques (Standardization, Robust Scaling, MinMax).
* Categorical encodings: Target encoding, One-Hot encoding, and Ordinal encoding.
* Dimensionality reduction: Principal Component Analysis (PCA) and t-SNE.
* Imbalanced learning: Class weighting, SMOTE, and undersampling strategies.



### Module 4.2: Supervised & Unsupervised Learning

* **Core Concepts:** Bias-variance tradeoff, non-parametric learning, ensemble methods, and neural fundamentals.
* **Key Topics:**
* **Classification & Regression:** Decision Trees, Random Forests, Gradient Boosted Trees (XGBoost / LightGBM / CatBoost).
* **Unsupervised:** Clustering (K-Means, DBSCAN, Hierarchical) and metric evaluation (Silhouette score).
* **Deep Learning Baseline:** Feedforward neural networks built with **PyTorch** or **TensorFlow** (tensors, activation functions, loss functions, backpropagation).



### Module 4.3: Model Validation & Hyperparameter Tuning

* **Core Concepts:** Overfitting mitigation, out-of-sample evaluation, and metric alignment with domain objectives.
* **Key Topics:**
* Cross-validation schemes: Stratified, GroupKFold, and TimeSeriesSplit.
* Evaluation metrics: Precision, Recall, F1, ROC-AUC, PR-AUC, MAE, RMSE, and MAPE.
* Hyperparameter optimization: Grid Search, Random Search, and Bayesian Optimization (Optuna).



> **Phase 4 Capstone:** Construct a predictive modeling pipeline in Scikit-learn and XGBoost that preprocesses raw features without data leakage, handles class imbalance, optimizes hyperparameters, and evaluates out-of-sample performance against domain metrics.

---

## Phase 5: Pipeline Orchestration & MLOps

*Focus: Transition from localized scripts to reproducible, automated, and trackable data pipelines.*

### Module 5.1: Data & Artifact Versioning

* **Core Concepts:** Reproducibility in data science, tracking non-text assets, and cache management.
* **Key Topics:**
* Setting up **DVC (Data Version Control)** paired with Git.
* Versioning large datasets, intermediate features, and binary model artifacts.
* Configuring remote storage backends (S3, GCS, or local storage).



### Module 5.2: Experiment Tracking & Model Registry

* **Core Concepts:** Auditing experiments, tracking parameters/metrics, and lifecycle management.
* **Key Topics:**
* Logging runs, parameters, metrics, and visual artifacts with **MLflow**.
* Managing the MLflow Model Registry (Staging, Production, Archival states).
* Packaging models for inference (PyFunc, Scikit-learn flavor).



### Module 5.3: Pipeline Orchestration & Workflow Engines

* **Core Concepts:** Directed Acyclic Graphs (DAGs), state management, task dependency, and backfilling.
* **Key Topics:**
* Building production DAGs using **Apache Airflow** or **Dagster**.
* Task dependencies, operators, sensors, and error handling/retries.
* Automating data transformation pipelines end-to-end.



> **Phase 5 Capstone:** Build an automated pipeline orchestrator in Dagster/Airflow that fetches data, validates quality, runs a DVC-tracked dataset transform, trains an ML model while logging metrics to MLflow, and updates the production model registry.

---

## Phase 6: Analytics Storytelling, BI & Ethics

*Focus: Communicate insights clearly to business leadership, configure enterprise BI platforms, and adhere to responsible AI principles.*

### Module 6.1: Dashboard Engineering & BI Semantic Layers

* **Core Concepts:** Self-service BI, semantic models, metric definitions, and dashboard UX design.
* **Key Topics:**
* Connecting analytical databases (DuckDB / PostgreSQL) to **Apache Superset** or **Metabase**.
* Designing data models, metrics, and slice-and-dice interactive dashboards for non-technical stakeholders.



### Module 6.2: Analytics Storytelling & Executive Communication

* **Core Concepts:** Data-to-ink ratio, framing business problems, structuring executive summaries, and action-oriented takeaways.
* **Key Topics:**
* Translating complex metrics (e.g., Log-loss, p-values) into business outcomes (revenue impact, churn reduction).
* Structuring presentations using the Situation-Complication-Resolution (SCR) framework.



### Module 6.3: Data Ethics, Explainability & Governance

* **Core Concepts:** Algorithmic bias, regulatory compliance (GDPR, CCPA), privacy-preserving techniques, and model interpretability.
* **Key Topics:**
* Model Explainability: Feature importance, **SHAP** (Shapley Additive exPlanations), and **LIME**.
* Auditing models for demographic parity and equal opportunity metrics.
* Data privacy: Anonymization, differential privacy, and license compliance for external datasets.



> **Phase 6 Capstone:** Deliver an end-to-end executive decision pack containing a live Metabase/Superset dashboard, a SHAP-backed explainability report breaking down model predictions, and an executive summary presenting key strategic recommendations.

```

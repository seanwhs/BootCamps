# Mastering Machine Learning & Predictive Modeling
## Quiz and Test Bank
### Complete Assessment with Answer Keys

---

## PART 0: INTRODUCTION

### Quiz 0.1: Fundamentals (10 Questions)

**Multiple Choice:**

1. What is the definition of machine learning?
   a) Programming computers to follow rules
   b) Systems that learn from experience without explicit programming
   c) Creating artificial intelligence that thinks like humans
   d) Storing and retrieving large amounts of data

2. Which of the following is NOT a type of machine learning?
   a) Supervised learning
   b) Unsupervised learning
   c) Reinforcement learning
   d) Automated learning

3. What is an instance in machine learning?
   a) A single data point
   b) The entire dataset
   c) A model parameter
   d) A feature value

4. What is the difference between features and labels?
   a) Features are outputs, labels are inputs
   b) Features are inputs, labels are outputs
   c) They are the same thing
   d) Features are numeric, labels are categorical

5. What is overfitting?
   a) When a model performs well on test data
   b) When a model fits training data too well but fails to generalize
   c) When a model is too simple to capture patterns
   d) When a model uses too few features

6. What is the purpose of a test set?
   a) To train the model
   b) To tune hyperparameters
   c) To evaluate final model performance
   d) To validate during training

7. Which is the correct order of the ML workflow?
   a) Deploy, Train, Evaluate, Data Preparation
   b) Data Preparation, Train, Evaluate, Deploy
   c) Evaluate, Train, Data Preparation, Deploy
   d) Train, Data Preparation, Deploy, Evaluate

8. What is a validation set used for?
   a) Training the model
   b) Evaluating final model performance
   c) Tuning hyperparameters
   d) All of the above

9. What is the bias-variance tradeoff?
   a) The tradeoff between model complexity and interpretability
   b) The tradeoff between training speed and accuracy
   c) The tradeoff between underfitting and overfitting
   d) The tradeoff between data size and model size

10. Why is data quality more important than model quality?
    a) Because models are always right
    b) Because great data with an average model beats average data with a great model
    c) Because data is easier to fix than models
    d) Because models don't affect outcomes

**Answer Key:**

1. b
2. d
3. a
4. b
5. b
6. c
7. b
8. c
9. c
10. b

---

## PART 1: PROJECT SETUP

### Quiz 1.1: Project Structure (10 Questions)

**Multiple Choice:**

1. What is the purpose of a `requirements.txt` file?
   a) To document the project
   b) To list Python dependencies with exact versions
   c) To store environment variables
   d) To define project structure

2. Which command creates a Python virtual environment?
   a) `python venv`
   b) `python -m venv venv`
   c) `virtualenv`
   d) `python create venv`

3. What should NOT be committed to version control?
   a) `requirements.txt`
   b) `README.md`
   c) `.env`
   d) `pyproject.toml`

4. What is the purpose of a Makefile?
   a) To define project metadata
   b) To automate common commands
   c) To store environment variables
   d) To list dependencies

5. What is the correct way to activate a virtual environment on Linux?
   a) `venv\Scripts\activate`
   b) `source venv/bin/activate`
   c) `activate venv`
   d) `venv activate`

6. What is `pyproject.toml` used for?
   a) Storing environment variables
   b) Project configuration and metadata
   c) Listing dependencies only
   d) Running tests

7. What is the purpose of `.env.example`?
   a) To store actual environment variables
   b) To provide a template for environment variables
   c) To ignore files in git
   d) To configure logging

8. Which directory should source code be placed in?
   a) `src/`
   b) `code/`
   c) `lib/`
   d) `bin/`

9. What is the purpose of logging?
   a) To slow down the application
   b) To track what the application is doing
   c) To store data
   d) To format code

10. What is the command to install dependencies in development mode?
    a) `pip install requirements.txt`
    b) `pip install -r requirements.txt`
    c) `pip install -e .`
    d) `pip install --dev`

**Answer Key:**

1. b
2. b
3. c
4. b
5. b
6. b
7. b
8. a
9. b
10. c

---

## PART 2: DATA VALIDATION

### Quiz 2.1: Data Quality (10 Questions)

**Multiple Choice:**

1. What does MCAR stand for?
   a) Missing Completely At Random
   b) Missing Conditionally At Random
   c) Mostly Complete And Reliable
   d) Missing Correlated And Random

2. What is the difference between MAR and MNAR?
   a) MAR depends on missing value, MNAR depends on observed variables
   b) MAR depends on observed variables, MNAR depends on missing value
   c) They are the same
   d) MAR is less common than MNAR

3. Which of the following is NOT a data quality dimension?
   a) Completeness
   b) Accuracy
   c) Timeliness
   d) Colorfulness

4. What is the IQR method for outlier detection?
   a) Values beyond 1.5 * IQR are outliers
   b) Values beyond 3 * IQR are outliers
   c) Values beyond 2 standard deviations are outliers
   d) Values beyond 1 standard deviation are outliers

5. What is the Z-score threshold for outlier detection?
   a) |z| > 1
   b) |z| > 2
   c) |z| > 3
   d) |z| > 4

6. What is data leakage?
   a) Data being lost during transmission
   b) Using information from outside the training set
   c) Hardware failure
   d) Missing values in the dataset

7. What is the purpose of schema validation?
   a) To check column types and constraints
   b) To remove duplicates
   c) To handle missing values
   d) To scale features

8. What is a good quality grade threshold for production-ready data?
   a) A (90-100%)
   b) B (80-89%)
   c) C (70-79%)
   d) D (60-69%)

9. What does the completeness score measure?
   a) Data accuracy
   b) Missing values
   c) Duplicate values
   d) Data consistency

10. Which is NOT a type of missing data?
    a) MCAR
    b) MAR
    c) MNAR
    d) MCR

**Answer Key:**

1. a
2. b
3. d
4. a
5. c
6. b
7. a
8. a
9. b
10. d

---

## PART 3: EDA

### Quiz 3.1: Exploratory Data Analysis (10 Questions)

**Multiple Choice:**

1. What does EDA stand for?
   a) Electronic Data Analysis
   b) Exploratory Data Analysis
   c) Extended Data Analysis
   d) Efficient Data Assessment

2. What is univariate analysis?
   a) Analyzing multiple variables at once
   b) Analyzing one variable at a time
   c) Analyzing two variables together
   d) Analyzing the relationship between features and target

3. What is skewness?
   a) A measure of data spread
   b) A measure of distribution asymmetry
   c) A measure of central tendency
   d) A measure of correlation

4. What does a skewness value > 1 indicate?
   a) Symmetric distribution
   b) Highly right-skewed distribution
   c) Highly left-skewed distribution
   d) Normal distribution

5. What is Pearson correlation used for?
   a) Measuring correlation between two categorical variables
   b) Measuring linear correlation between two numeric variables
   c) Measuring non-linear correlation between two numeric variables
   d) Measuring correlation between multiple variables

6. What is Cramér's V used for?
   a) Measuring correlation between two numeric variables
   b) Measuring correlation between two categorical variables
   c) Measuring correlation between numeric and categorical variables
   d) Measuring correlation between multiple variables

7. What is the purpose of target analysis?
   a) To analyze the target variable and its relationship with features
   b) To predict the target variable
   c) To remove the target variable
   d) To scale the target variable

8. What is a good class balance ratio?
   a) > 3.0
   b) < 3.0
   c) > 5.0
   d) < 1.0

9. What is bivariate analysis?
   a) Analyzing one variable at a time
   b) Analyzing two variables together
   c) Analyzing multiple variables at once
   d) Analyzing only the target variable

10. What is kurtosis?
    a) A measure of data spread
    b) A measure of tail heaviness
    c) A measure of central tendency
    d) A measure of correlation

**Answer Key:**

1. b
2. b
3. b
4. b
5. b
6. b
7. a
8. b
9. b
10. b

---

## PART 4: IMPUTATION & SCALING

### Quiz 4.1: Preprocessing (10 Questions)

**Multiple Choice:**

1. Which imputation strategy is best for skewed data with outliers?
   a) Mean
   b) Median
   c) Mode
   d) Constant

2. What is the formula for StandardScaler?
   a) (x - min) / (max - min)
   b) (x - mean) / std
   c) (x - median) / IQR
   d) x / max(abs)

3. Which scaling method is robust to outliers?
   a) StandardScaler
   b) RobustScaler
   c) MinMaxScaler
   d) MaxAbsScaler

4. What is KNN imputation?
   a) Imputing with the mean of all values
   b) Imputing with the median of all values
   c) Imputing with the mean of k nearest neighbors
   d) Imputing with a constant value

5. What is MICE imputation?
   a) Mean Imputation by Chained Equations
   b) Multiple Imputation by Chained Equations
   c) Median Imputation by Chained Equations
   d) Mode Imputation by Chained Equations

6. Which scaling method produces values in [0, 1] range?
   a) StandardScaler
   b) RobustScaler
   c) MinMaxScaler
   d) MaxAbsScaler

7. What is the purpose of PowerTransformer?
   a) To scale data to [0,1]
   b) To handle skewness
   c) To remove outliers
   d) To encode categorical data

8. What is the IQR?
   a) Q1 - Q3
   b) Q3 - Q1
   c) Q2 - Q1
   d) Q3 - Q2

9. When should you NOT use mean imputation?
   a) When data is symmetric
   b) When data has no outliers
   c) When data is skewed
   d) When data is normally distributed

10. What is the purpose of robust scaling?
    a) To handle outliers
    b) To make data normally distributed
    c) To encode categorical data
    d) To remove duplicates

**Answer Key:**

1. b
2. b
3. b
4. c
5. b
6. c
7. b
8. b
9. c
10. a

---

## PART 5: CATEGORICAL ENCODING

### Quiz 5.1: Encoding (10 Questions)

**Multiple Choice:**

1. What is one-hot encoding?
   a) Converting categories to numeric values
   b) Creating binary columns for each category
   c) Replacing categories with frequencies
   d) Replacing categories with target mean

2. When should you use one-hot encoding?
   a) High cardinality features
   b) Low cardinality features
   c) Continuous features
   d) Time series data

3. What is target encoding?
   a) Converting categories to binary columns
   b) Replacing categories with frequencies
   c) Replacing categories with target mean
   d) Replacing categories with hashed values

4. What is the purpose of smoothing in target encoding?
   a) To prevent overfitting
   b) To make the encoding faster
   c) To create more categories
   d) To remove outliers

5. What is frequency encoding?
   a) Replacing categories with their frequency
   b) Replacing categories with target mean
   c) Creating binary columns for each category
   d) Hashing categories to fixed-length vectors

6. When should you use hashing encoding?
   a) Low cardinality features
   b) Medium cardinality features
   c) Very high cardinality features
   d) Continuous features

7. What is the risk of target encoding?
   a) Data leakage
   b) High memory usage
   c) Slow training
   d) Loss of information

8. How do you prevent data leakage in target encoding?
   a) Use cross-validation
   b) Use all data for encoding
   c) Use test data for encoding
   d) Use random values

9. What is ordinal encoding?
   a) Creating binary columns for each category
   b) Replacing categories with integer values
   c) Replacing categories with frequencies
   d) Replacing categories with target mean

10. What is the auto-strategy for categorical encoding?
    a) Always use one-hot encoding
    b) Always use target encoding
    c) Select strategy based on data characteristics
    d) Use a fixed strategy

**Answer Key:**

1. b
2. b
3. c
4. a
5. a
6. c
7. a
8. a
9. b
10. c

---

## PART 6: FEATURE CREATION & SELECTION

### Quiz 6.1: Feature Engineering (10 Questions)

**Multiple Choice:**

1. What is a polynomial feature?
   a) Feature raised to a power
   b) Feature divided by another feature
   c) Feature multiplied by another feature
   d) Feature subtracted from another feature

2. What is an interaction feature?
   a) Feature raised to a power
   b) Feature multiplied by another feature
   c) Feature divided by another feature
   d) Feature added to another feature

3. What is the purpose of feature selection?
   a) To create new features
   b) To remove irrelevant features
   c) To scale features
   d) To encode features

4. What is a filter method in feature selection?
   a) Using a model to select features
   b) Using statistical measures to select features
   c) Using regularization to select features
   d) Using random selection

5. What is a wrapper method in feature selection?
   a) Using a model to select features
   b) Using statistical measures to select features
   c) Using regularization to select features
   d) Using random selection

6. What is an embedded method in feature selection?
   a) Using a model to select features
   b) Using statistical measures to select features
   c) Using regularization and model importance
   d) Using random selection

7. What is permutation importance?
   a) Importance based on model coefficients
   b) Importance based on shuffling feature values
   c) Importance based on tree splits
   d) Importance based on correlation

8. What is the purpose of feature creation?
   a) To remove irrelevant features
   b) To create new informative features
   c) To scale features
   d) To encode features

9. What is a ratio feature?
   a) Feature raised to a power
   b) Feature multiplied by another feature
   c) Feature divided by another feature
   d) Feature subtracted from another feature

10. What is the purpose of domain-specific features?
    a) To use general features
    b) To incorporate business knowledge
    c) To use only numeric features
    d) To use only categorical features

**Answer Key:**

1. a
2. b
3. b
4. b
5. a
6. c
7. b
8. b
9. c
10. b

---

## PART 7: DIMENSIONALITY REDUCTION & IMBALANCE

### Quiz 7.1: Advanced Techniques (10 Questions)

**Multiple Choice:**

1. What is the curse of dimensionality?
   a) Too many features cause overfitting
   b) Too many features cause data sparsity
   c) Too many features cause multicollinearity
   d) Too many features cause data leakage

2. What is PCA?
   a) Principal Component Analysis
   b) Principal Correlation Analysis
   c) Principal Classification Analysis
   d) Principal Clustering Analysis

3. What does PCA find?
   a) Directions of maximum variance
   b) Directions of maximum correlation
   c) Directions of minimum variance
   d) Random directions

4. What is t-SNE used for?
   a) Feature selection
   b) Visualization
   c) Classification
   d) Regression

5. What is SMOTE?
   a) Synthetic Minority Over-sampling Technique
   b) Synthetic Majority Over-sampling Technique
   c) Statistical Minority Over-sampling Technique
   d) Simple Minority Over-sampling Technique

6. What is the purpose of SMOTE?
   a) To create synthetic majority samples
   b) To create synthetic minority samples
   c) To remove majority samples
   d) To remove minority samples

7. What is class weighting?
   a) Assigning weights to classes to handle imbalance
   b) Removing classes with low weight
   c) Adding synthetic classes
   d) Removing all classes

8. What is ADASYN?
   a) A method to create synthetic samples focusing on hard examples
   b) A method to remove outliers
   c) A method to scale features
   d) A method to select features

9. What is the difference between t-SNE and PCA?
   a) t-SNE is linear, PCA is non-linear
   b) PCA is linear, t-SNE is non-linear
   c) Both are linear
   d) Both are non-linear

10. What is LDA used for?
    a) Dimensionality reduction with class separation
    b) Dimensionality reduction without class labels
    c) Feature selection
    d) Classification only

**Answer Key:**

1. b
2. a
3. a
4. b
5. a
6. b
7. a
8. a
9. b
10. a

---

## PART 8: TREE-BASED MODELS

### Quiz 8.1: Tree Models (10 Questions)

**Multiple Choice:**

1. What is a decision tree?
   a) A model that splits data based on feature values
   b) A model that uses linear combinations
   c) A model that uses neural networks
   d) A model that uses support vectors

2. What is Gini impurity?
   a) A measure of feature importance
   b) A measure of split quality
   c) A measure of model accuracy
   d) A measure of data spread

3. What is random forest?
   a) A single decision tree
   b) An ensemble of decision trees with bootstrap and feature randomization
   c) A neural network
   d) A linear model

4. What is XGBoost?
   a) A random forest implementation
   b) A gradient boosting implementation
   c) A neural network implementation
   d) A linear model implementation

5. What is the purpose of early stopping in XGBoost?
   a) To train faster
   b) To prevent overfitting
   c) To use less memory
   d) To improve accuracy

6. What is LightGBM?
   a) A decision tree implementation
   b) A fast gradient boosting implementation
   c) A neural network implementation
   d) A linear model implementation

7. What is CatBoost?
   a) A gradient boosting implementation with native categorical support
   b) A decision tree implementation
   c) A neural network implementation
   d) A linear model implementation

8. What is the purpose of regularization in XGBoost?
   a) To speed up training
   b) To prevent overfitting
   c) To use less memory
   d) To improve speed

9. What is the advantage of LightGBM over XGBoost?
   a) Better accuracy
   b) Faster training
   c) Native categorical support
   d) Better interpretability

10. What is feature importance in tree-based models?
    a) The number of times a feature is used
    b) The improvement in split quality
    c) Both a and b
    d) Neither a nor b

**Answer Key:**

1. a
2. b
3. b
4. b
5. b
6. b
7. a
8. b
9. b
10. c

---

## PART 9: UNSUPERVISED LEARNING

### Quiz 9.1: Clustering (10 Questions)

**Multiple Choice:**

1. What is unsupervised learning?
   a) Learning with labeled data
   b) Learning with unlabeled data
   c) Learning with rewards
   d) Learning without any data

2. What is K-Means clustering?
   a) A hierarchical clustering method
   b) A partition-based clustering method
   c) A density-based clustering method
   d) A probabilistic clustering method

3. What is the elbow method used for?
   a) Finding optimal K in K-Means
   b) Finding optimal epsilon in DBSCAN
   c) Evaluating clustering quality
   d) Visualizing clusters

4. What is silhouette score?
   a) A measure of cluster separation
   b) A measure of cluster density
   c) A measure of cluster size
   d) A measure of cluster shape

5. What is DBSCAN?
   a) A partition-based clustering method
   b) A density-based clustering method
   c) A hierarchical clustering method
   d) A probabilistic clustering method

6. What are the key parameters of DBSCAN?
   a) K and max_iter
   b) eps and min_samples
   c) n_clusters and random_state
   d) linkage and distance

7. What is hierarchical clustering?
   a) A clustering method that builds a hierarchy of clusters
   b) A partition-based clustering method
   c) A density-based clustering method
   d) A probabilistic clustering method

8. What is a dendrogram?
   a) A visualization of hierarchical clustering
   b) A visualization of K-Means
   c) A visualization of DBSCAN
   d) A visualization of silhouette scores

9. What is the advantage of DBSCAN over K-Means?
   a) It finds spherical clusters
   b) It finds arbitrary shapes
   c) It requires K
   d) It is faster

10. What is the range of silhouette score?
    a) [0, 1]
    b) [-1, 1]
    c) [-∞, ∞]
    d) [0, ∞]

**Answer Key:**

1. b
2. b
3. a
4. a
5. b
6. b
7. a
8. a
9. b
10. b

---

## PART 10: DEEP LEARNING

### Quiz 10.1: Neural Networks (10 Questions)

**Multiple Choice:**

1. What is a neural network?
   a) A linear model
   b) A network of interconnected neurons
   c) A tree-based model
   d) A clustering method

2. What is an activation function?
   a) A function that introduces non-linearity
   b) A function that scales data
   c) A function that selects features
   d) A function that encodes categories

3. What is ReLU?
   a) max(0, x)
   b) 1/(1+e⁻ˣ)
   c) (eˣ-e⁻ˣ)/(eˣ+e⁻ˣ)
   d) eˣⁱ/Σeˣʲ

4. What is backpropagation?
   a) Forward propagation of data
   b) Computation of gradients for training
   c) Model evaluation
   d) Data preprocessing

5. What is the purpose of dropout?
   a) To speed up training
   b) To prevent overfitting
   c) To improve accuracy
   d) To use less memory

6. What is the purpose of batch normalization?
   a) To normalize data
   b) To improve training stability
   c) To select features
   d) To encode categories

7. What is an optimizer in deep learning?
   a) A function to initialize weights
   b) An algorithm to update weights
   c) A function to evaluate models
   d) A method to preprocess data

8. What is the difference between parameters and hyperparameters?
   a) Parameters are learned, hyperparameters are set
   b) Hyperparameters are learned, parameters are set
   c) They are the same
   d) Parameters are for data, hyperparameters are for models

9. What is the purpose of a loss function?
   a) To measure model error
   b) To update weights
   c) To initialize weights
   d) To preprocess data

10. What is transfer learning?
    a) Learning from scratch
    b) Using pre-trained models
    c) Learning without data
    d) Learning with labels

**Answer Key:**

1. b
2. a
3. a
4. b
5. b
6. b
7. b
8. a
9. a
10. b

---

## PART 11: CROSS-VALIDATION & EVALUATION

### Quiz 11.1: Validation (10 Questions)

**Multiple Choice:**

1. What is cross-validation?
   a) Training on all data
   b) Splitting data into train and test
   c) Multiple train-test splits
   d) Training without test data

2. What is stratified K-Fold?
   a) K-Fold with random splitting
   b) K-Fold with class proportion preservation
   c) K-Fold with time series split
   d) K-Fold with group split

3. What is the purpose of cross-validation?
   a) To train the model
   b) To estimate model performance
   c) To preprocess data
   d) To select features

4. What is precision?
   a) TP / (TP + FN)
   b) TP / (TP + FP)
   c) (TP + TN) / (TP + TN + FP + FN)
   d) 2*P*R/(P+R)

5. What is recall?
   a) TP / (TP + FN)
   b) TP / (TP + FP)
   c) (TP + TN) / (TP + TN + FP + FN)
   d) 2*P*R/(P+R)

6. What is F1 score?
   a) TP / (TP + FN)
   b) TP / (TP + FP)
   c) (TP + TN) / (TP + TN + FP + FN)
   d) 2*P*R/(P+R)

7. What is ROC-AUC?
   a) Accuracy metric
   b) Area under ROC curve
   c) Precision-recall tradeoff
   d) Loss function

8. What is RMSE?
   a) Root Mean Squared Error
   b) Regularized Mean Squared Error
   c) Relative Mean Squared Error
   d) Random Mean Squared Error

9. What is the difference between MAE and RMSE?
   a) MAE penalizes large errors more
   b) RMSE penalizes large errors more
   c) They are the same
   d) MAE is for classification

10. What is R²?
    a) Variance explained by the model
    b) Mean squared error
    c) Mean absolute error
    d) Root mean squared error

**Answer Key:**

1. c
2. b
3. b
4. b
5. a
6. d
7. b
8. a
9. b
10. a

---

## PART 12: HYPERPARAMETER OPTIMIZATION

### Quiz 12.1: Tuning (10 Questions)

**Multiple Choice:**

1. What is hyperparameter optimization?
   a) Finding best model parameters
   b) Finding best model hyperparameters
   c) Finding best data preprocessing
   d) Finding best features

2. What is grid search?
   a) Random sampling of hyperparameters
   b) Exhaustive search over a predefined grid
   c) Bayesian optimization
   d) Evolutionary search

3. What is random search?
   a) Random sampling of hyperparameters
   b) Exhaustive search over a predefined grid
   c) Bayesian optimization
   d) Evolutionary search

4. What is Bayesian optimization?
   a) Random sampling of hyperparameters
   b) Exhaustive search over a predefined grid
   c) Probabilistic model-based optimization
   d) Evolutionary search

5. What is Optuna?
   a) A grid search library
   b) A Bayesian optimization library
   c) A random search library
   d) A neural network library

6. What is the purpose of pruning in Optuna?
   a) To stop unpromising trials early
   b) To increase accuracy
   c) To use less memory
   d) To improve code quality

7. What is the advantage of Bayesian optimization over grid search?
   a) More efficient exploration
   b) Exhaustive search
   c) Simpler implementation
   d) Less code required

8. What is the difference between parameters and hyperparameters?
   a) Parameters are learned from data, hyperparameters are set before training
   b) Hyperparameters are learned from data, parameters are set before training
   c) They are the same
   d) Parameters are numeric, hyperparameters are categorical

9. What is a parameter space?
   a) The range of possible parameter values
   b) The number of parameters
   c) The model architecture
   d) The training data

10. What is the purpose of cross-validation in hyperparameter tuning?
    a) To evaluate hyperparameter combinations
    b) To train the final model
    c) To preprocess data
    d) To select features

**Answer Key:**

1. b
2. b
3. a
4. c
5. b
6. a
7. a
8. a
9. a
10. a

---

## PART 13: PIPELINE CONSTRUCTION

### Quiz 13.1: Pipeline (10 Questions)

**Multiple Choice:**

1. What is a machine learning pipeline?
   a) A sequence of data processing steps
   b) A single model
   c) A data storage system
   d) A visualization tool

2. What is the purpose of a pipeline?
   a) To ensure consistent preprocessing
   b) To increase accuracy
   c) To store data
   d) To visualize results

3. What is data leakage in a pipeline?
   a) Using test data in training
   b) Losing data
   c) Data corruption
   d) Data duplication

4. How do you prevent data leakage?
   a) Fit transformers on training data only
   b) Fit transformers on all data
   c) Use all data for training
   d) Use test data for training

5. What is the purpose of saving a pipeline?
   a) To deploy the model
   b) To increase accuracy
   c) To preprocess data
   d) To select features

6. What is model versioning?
   a) Tracking different versions of models
   b) Creating multiple models
   c) Training models in parallel
   d) Testing models

7. What is the benefit of configuration-driven pipelines?
   a) Easy to experiment with different settings
   b) Faster training
   c) Better accuracy
   d) Simpler code

8. What is the purpose of logging in a pipeline?
   a) To track what happened during training
   b) To increase speed
   c) To improve accuracy
   d) To reduce memory usage

9. What is the difference between training and inference pipelines?
   a) Training creates the model, inference uses it
   b) They are the same
   c) Inference creates the model, training uses it
   d) Training is faster than inference

10. What is the purpose of the prediction pipeline?
    a) To make predictions on new data
    b) To train the model
    c) To preprocess data
    d) To evaluate the model

**Answer Key:**

1. a
2. a
3. a
4. a
5. a
6. a
7. a
8. a
9. a
10. a

---

## PART 14: CAPSTONE PROJECT

### Quiz 14.1: Real-World Application (10 Questions)

**Multiple Choice:**

1. What is customer churn?
   a) Customers leaving a service
   b) Customers buying more
   c) New customers joining
   d) Customer satisfaction

2. Why is churn prediction important?
   a) It saves money by preventing customer loss
   b) It increases sales
   c) It improves product quality
   d) It reduces costs

3. What is a key feature for churn prediction?
   a) Customer tenure
   b) Customer age
   c) Customer name
   d) Customer address

4. What is the most important factor in churn?
   a) Contract type
   b) Customer age
   c) Customer location
   d) Customer name

5. What is the business impact of churn prediction?
   a) Identifying at-risk customers
   b) Increasing revenue
   c) Reducing marketing costs
   d) All of the above

6. What is the potential savings from churn prediction?
   a) $200,000 annually for a telecom company
   b) $1,000 annually
   c) $10,000 annually
   d) $1,000,000 annually

7. What is a retention offer?
   a) An offer to keep a customer
   b) An offer to get new customers
   c) An offer to reduce prices
   d) An offer to increase features

8. What is the purpose of the capstone project?
   a) To apply all skills to a real problem
   b) To learn new skills
   c) To practice programming
   d) To write a paper

9. What is the key business metric for churn?
   a) Churn rate
   b) Revenue
   c) Profit
   d) Customer satisfaction

10. What is the role of feature engineering in churn prediction?
    a) Creating features to improve prediction
    b) Removing features
    c) Scaling features
    d) Encoding features

**Answer Key:**

1. a
2. a
3. a
4. a
5. d
6. a
7. a
8. a
9. a
10. a

---

## PART 15: DEPLOYMENT & MONITORING

### Quiz 15.1: Production (10 Questions)

**Multiple Choice:**

1. What is model deployment?
   a) Making a model available for use
   b) Training a model
   c) Evaluating a model
   d) Designing a model

2. What is FastAPI?
   a) A web framework for APIs
   b) A machine learning library
   c) A database system
   d) A visualization tool

3. What is the purpose of Docker?
   a) Containerization for consistent deployment
   b) Data storage
   c) Code editing
   d) Version control

4. What is model monitoring?
   a) Tracking model performance in production
   b) Training the model
   c) Evaluating the model
   d) Designing the model

5. What is data drift?
   a) Changes in data distribution over time
   b) Data being lost
   c) Data being corrupted
   d) Data being duplicated

6. What is concept drift?
   a) Changes in the relationship between features and target
   b) Changes in data distribution
   c) Data being lost
   d) Data being corrupted

7. What is the purpose of health checks?
   a) To ensure the API is working
   b) To train the model
   c) To evaluate the model
   d) To design the model

8. What is response time?
   a) Time taken to respond to a request
   b) Time taken to train a model
   c) Time taken to evaluate a model
   d) Time taken to deploy a model

9. What is the purpose of logging in production?
   a) To track what the system is doing
   b) To increase speed
   c) To improve accuracy
   d) To reduce memory usage

10. What is the purpose of alerting in production?
    a) To notify when something goes wrong
    b) To increase speed
    c) To improve accuracy
    d) To reduce memory usage

**Answer Key:**

1. a
2. a
3. a
4. a
5. a
6. a
7. a
8. a
9. a
10. a

---

# COMPREHENSIVE FINAL EXAM

## Section 1: Multiple Choice (50 Questions)

**Instructions:** Choose the best answer for each question.

1. What is the correct order of the ML workflow?
   a) Deploy, Train, Evaluate, Data Prep
   b) Data Prep, Train, Evaluate, Deploy
   c) Evaluate, Train, Data Prep, Deploy
   d) Train, Data Prep, Deploy, Evaluate

2. What is data leakage?
   a) Data being lost during transmission
   b) Using information from outside the training set
   c) Hardware failure
   d) Missing values in the dataset

3. What is the IQR method for outlier detection?
   a) Values beyond 1.5 * IQR
   b) Values beyond 3 * IQR
   c) Values beyond 2 standard deviations
   d) Values beyond 1 standard deviation

4. What is the Z-score threshold for outlier detection?
   a) |z| > 1
   b) |z| > 2
   c) |z| > 3
   d) |z| > 4

5. Which imputation strategy is best for skewed data with outliers?
   a) Mean
   b) Median
   c) Mode
   d) Constant

6. What is the formula for StandardScaler?
   a) (x - min) / (max - min)
   b) (x - mean) / std
   c) (x - median) / IQR
   d) x / max(abs)

7. What is one-hot encoding?
   a) Converting categories to numeric values
   b) Creating binary columns for each category
   c) Replacing categories with frequencies
   d) Replacing categories with target mean

8. What is target encoding?
   a) Converting categories to binary columns
   b) Replacing categories with frequencies
   c) Replacing categories with target mean
   d) Replacing categories with hashed values

9. What is PCA?
   a) Principal Component Analysis
   b) Principal Correlation Analysis
   c) Principal Classification Analysis
   d) Principal Clustering Analysis

10. What is SMOTE?
    a) Synthetic Minority Over-sampling Technique
    b) Synthetic Majority Over-sampling Technique
    c) Statistical Minority Over-sampling Technique
    d) Simple Minority Over-sampling Technique

11. What is a decision tree?
    a) A model that splits data based on feature values
    b) A model that uses linear combinations
    c) A model that uses neural networks
    d) A model that uses support vectors

12. What is random forest?
    a) A single decision tree
    b) An ensemble of decision trees with bootstrap and feature randomization
    c) A neural network
    d) A linear model

13. What is XGBoost?
    a) A random forest implementation
    b) A gradient boosting implementation
    c) A neural network implementation
    d) A linear model implementation

14. What is K-Means clustering?
    a) A hierarchical clustering method
    b) A partition-based clustering method
    c) A density-based clustering method
    d) A probabilistic clustering method

15. What is silhouette score?
    a) A measure of cluster separation
    b) A measure of cluster density
    c) A measure of cluster size
    d) A measure of cluster shape

16. What is an activation function?
    a) A function that introduces non-linearity
    b) A function that scales data
    c) A function that selects features
    d) A function that encodes categories

17. What is backpropagation?
    a) Forward propagation of data
    b) Computation of gradients for training
    c) Model evaluation
    d) Data preprocessing

18. What is the purpose of cross-validation?
    a) To train the model
    b) To estimate model performance
    c) To preprocess data
    d) To select features

19. What is precision?
    a) TP / (TP + FN)
    b) TP / (TP + FP)
    c) (TP + TN) / (TP + TN + FP + FN)
    d) 2*P*R/(P+R)

20. What is recall?
    a) TP / (TP + FN)
    b) TP / (TP + FP)
    c) (TP + TN) / (TP + TN + FP + FN)
    d) 2*P*R/(P+R)

21. What is F1 score?
    a) TP / (TP + FN)
    b) TP / (TP + FP)
    c) (TP + TN) / (TP + TN + FP + FN)
    d) 2*P*R/(P+R)

22. What is grid search?
    a) Random sampling of hyperparameters
    b) Exhaustive search over a predefined grid
    c) Bayesian optimization
    d) Evolutionary search

23. What is Bayesian optimization?
    a) Random sampling of hyperparameters
    b) Exhaustive search over a predefined grid
    c) Probabilistic model-based optimization
    d) Evolutionary search

24. What is the purpose of a machine learning pipeline?
    a) A sequence of data processing steps
    b) A single model
    c) A data storage system
    d) A visualization tool

25. How do you prevent data leakage in a pipeline?
    a) Fit transformers on training data only
    b) Fit transformers on all data
    c) Use all data for training
    d) Use test data for training

26. What is model deployment?
    a) Making a model available for use
    b) Training a model
    c) Evaluating a model
    d) Designing a model

27. What is data drift?
    a) Changes in data distribution over time
    b) Data being lost
    c) Data being corrupted
    d) Data being duplicated

28. What is the difference between parameters and hyperparameters?
    a) Parameters are learned, hyperparameters are set
    b) Hyperparameters are learned, parameters are set
    c) They are the same
    d) Parameters are numeric, hyperparameters are categorical

29. What is the purpose of regularization?
    a) To speed up training
    b) To prevent overfitting
    c) To use less memory
    d) To improve speed

30. What is the advantage of LightGBM over XGBoost?
    a) Better accuracy
    b) Faster training
    c) Native categorical support
    d) Better interpretability

31. What is the advantage of DBSCAN over K-Means?
    a) It finds spherical clusters
    b) It finds arbitrary shapes
    c) It requires K
    d) It is faster

32. What is the purpose of dropout in neural networks?
    a) To speed up training
    b) To prevent overfitting
    c) To improve accuracy
    d) To use less memory

33. What is the purpose of batch normalization?
    a) To normalize data
    b) To improve training stability
    c) To select features
    d) To encode categories

34. What is transfer learning?
    a) Learning from scratch
    b) Using pre-trained models
    c) Learning without data
    d) Learning with labels

35. What is the elbow method used for?
    a) Finding optimal K in K-Means
    b) Finding optimal epsilon in DBSCAN
    c) Evaluating clustering quality
    d) Visualizing clusters

36. What is the range of silhouette score?
    a) [0, 1]
    b) [-1, 1]
    c) [-∞, ∞]
    d) [0, ∞]

37. What is the purpose of early stopping in XGBoost?
    a) To train faster
    b) To prevent overfitting
    c) To use less memory
    d) To improve accuracy

38. What is the purpose of smoothing in target encoding?
    a) To prevent overfitting
    b) To make the encoding faster
    c) To create more categories
    d) To remove outliers

39. What is the purpose of feature selection?
    a) To create new features
    b) To remove irrelevant features
    c) To scale features
    d) To encode features

40. What is the advantage of CatBoost over XGBoost?
    a) Faster training
    b) Native categorical support
    c) Better accuracy
    d) More interpretable

41. What is the purpose of the validation set?
    a) To train the model
    b) To tune hyperparameters
    c) To evaluate final performance
    d) To preprocess data

42. What is RMSE?
    a) Root Mean Squared Error
    b) Regularized Mean Squared Error
    c) Relative Mean Squared Error
    d) Random Mean Squared Error

43. What is the difference between MAE and RMSE?
    a) MAE penalizes large errors more
    b) RMSE penalizes large errors more
    c) They are the same
    d) MAE is for classification

44. What is R²?
    a) Variance explained by the model
    b) Mean squared error
    c) Mean absolute error
    d) Root mean squared error

45. What is the purpose of logging in production?
    a) To track what the system is doing
    b) To increase speed
    c) To improve accuracy
    d) To reduce memory usage

46. What is the purpose of alerting in production?
    a) To notify when something goes wrong
    b) To increase speed
    c) To improve accuracy
    d) To reduce memory usage

47. What is the difference between training and inference pipelines?
    a) Training creates the model, inference uses it
    b) They are the same
    c) Inference creates the model, training uses it
    d) Training is faster than inference

48. What is the purpose of the prediction pipeline?
    a) To make predictions on new data
    b) To train the model
    c) To preprocess data
    d) To evaluate the model

49. What is concept drift?
    a) Changes in the relationship between features and target
    b) Changes in data distribution
    c) Data being lost
    d) Data being corrupted

50. What is the purpose of health checks in production?
    a) To ensure the API is working
    b) To train the model
    c) To evaluate the model
    d) To design the model

**Final Exam Answer Key:**

1. b
2. b
3. a
4. c
5. b
6. b
7. b
8. c
9. a
10. a
11. a
12. b
13. b
14. b
15. a
16. a
17. b
18. b
19. b
20. a
21. d
22. b
23. c
24. a
25. a
26. a
27. a
28. a
29. b
30. b
31. b
32. b
33. b
34. b
35. a
36. b
37. b
38. a
39. b
40. b
41. b
42. a
43. b
44. a
45. a
46. a
47. a
48. a
49. a
50. a

---

## Section 2: Short Answer (10 Questions)

**Instructions:** Answer each question in 2-3 sentences.

1. What is the difference between supervised and unsupervised learning?
   _________________________________________________________________
   _________________________________________________________________

2. Explain the bias-variance tradeoff.
   _________________________________________________________________
   _________________________________________________________________

3. What is data leakage and how can it be prevented?
   _________________________________________________________________
   _________________________________________________________________

4. Explain the difference between grid search and Bayesian optimization.
   _________________________________________________________________
   _________________________________________________________________

5. What is the purpose of cross-validation?
   _________________________________________________________________
   _________________________________________________________________

6. How does SMOTE work?
   _________________________________________________________________
   _________________________________________________________________

7. What is the difference between bagging and boosting?
   _________________________________________________________________
   _________________________________________________________________

8. Explain the purpose of a machine learning pipeline.
   _________________________________________________________________
   _________________________________________________________________

9. What is model drift and how is it detected?
   _________________________________________________________________
   _________________________________________________________________

10. What is the difference between parameters and hyperparameters?
    _________________________________________________________________
    _________________________________________________________________

**Short Answer Answer Key:**

1. Supervised learning uses labeled data to predict outputs. Unsupervised learning finds patterns in unlabeled data without predefined outputs.

2. The bias-variance tradeoff is the tension between model simplicity (high bias, underfitting) and model complexity (high variance, overfitting). The goal is to find a balance that minimizes total error.

3. Data leakage occurs when information from outside the training set is used to train the model. It can be prevented by splitting data before preprocessing, fitting transformers on training data only, and using appropriate cross-validation strategies.

4. Grid search exhaustively tries all combinations in a predefined parameter grid. Bayesian optimization builds a probabilistic model of the objective function to intelligently sample promising regions, making it more efficient for large search spaces.

5. Cross-validation estimates how well a model will generalize to unseen data by splitting data into multiple train/test folds. It provides a more robust performance estimate than a single train-test split.

6. SMOTE creates synthetic minority class samples by interpolating between existing minority samples. It selects a minority sample, finds its k-nearest neighbors, and creates new samples along the line segments between them.

7. Bagging (Random Forest) trains models independently on bootstrap samples and averages predictions. Boosting (XGBoost) trains models sequentially, with each model correcting the errors of the previous ones.

8. A machine learning pipeline ensures consistent preprocessing and modeling steps. It prevents data leakage by fitting transformers on training data only and applying the same transformations to new data.

9. Model drift is the degradation of model performance over time due to changes in data patterns. It is detected by monitoring performance metrics, data distributions, and feature relationships over time.

10. Parameters are learned from data during training (e.g., weights in linear regression). Hyperparameters are set before training and control the learning process (e.g., learning rate, tree depth).

---

## Section 3: Case Study (1 Question)

**Instructions:** Read the case study and answer the following questions.

### Case Study: Telecom Churn Prediction

A telecommunications company is experiencing high customer churn rates. They have provided you with a dataset containing customer information including demographics, account details, service usage, and whether they churned.

**Dataset Information:**
- 5,000 customers
- 20 features: tenure, contract type, monthly charges, total charges, service usage, etc.
- Target: churn (Yes/No)
- Churn rate: 20%

**Questions:**

1. What preprocessing steps would you perform on this data?
   _________________________________________________________________
   _________________________________________________________________

2. Which models would you try and why?
   _________________________________________________________________
   _________________________________________________________________

3. How would you handle the class imbalance?
   _________________________________________________________________
   _________________________________________________________________

4. What features are likely to be most important?
   _________________________________________________________________
   _________________________________________________________________

5. How would you evaluate model performance?
   _________________________________________________________________
   _________________________________________________________________

6. How would you deploy the model?
   _________________________________________________________________
   _________________________________________________________________

7. What would you monitor in production?
   _________________________________________________________________
   _________________________________________________________________

**Case Study Answer Key:**

1. Preprocessing steps would include: handling missing values (median for numeric, mode for categorical), scaling numeric features, encoding categorical features (one-hot or target encoding), creating additional features (tenure groups, average monthly charge, number of services). Split data into train/test sets.

2. Models to try: Logistic Regression (baseline), Random Forest (handles non-linearity), XGBoost/LightGBM (best performance for tabular data). Use cross-validation for model selection.

3. Class imbalance (20% churn) would be addressed using SMOTE for oversampling or class weights in the model. Use PR-AUC and F1 score for evaluation rather than accuracy.

4. Key features likely include: tenure (shorter tenure = higher churn), contract type (month-to-month = higher churn), monthly charges, number of services, payment method.

5. Use stratified cross-validation. Metrics: ROC-AUC, PR-AUC, F1 Score, Precision, Recall. For business impact, calculate cost savings from retention offers.

6. Deploy using FastAPI for predictions, containerize with Docker, save pipeline using joblib. Create endpoints for single and batch predictions, implement health checks.

7. Monitor: prediction distribution, feature distributions (data drift), performance (when ground truth available), response time, error rate, churn rate predictions vs actual.

---

# GRADING SCHEMA

## Quiz Scoring

| Score | Grade |
|-------|-------|
| 90-100% | Excellent |
| 80-89% | Good |
| 70-79% | Satisfactory |
| 60-69% | Needs Improvement |
| <60% | Review Required |

## Test Scoring

| Score | Grade |
|-------|-------|
| 90-100% | A |
| 80-89% | B |
| 70-79% | C |
| 60-69% | D |
| <60% | F |

## Final Exam Scoring

| Score | Grade |
|-------|-------|
| 90-100% | A |
| 80-89% | B |
| 70-79% | C |
| 60-69% | D |
| <60% | F |

---

*End of Quiz and Test Bank*

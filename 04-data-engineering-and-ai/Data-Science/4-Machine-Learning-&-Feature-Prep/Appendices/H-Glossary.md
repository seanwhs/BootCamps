# Appendix H: Glossary of Terms

## A

**Accuracy**: The proportion of correct predictions among all predictions. Formula: (TP + TN) / (TP + TN + FP + FN).

**Activation Function**: A mathematical function applied to a neuron's output that introduces non-linearity. Common examples: ReLU, Sigmoid, Tanh, Softmax.

**AdaBoost (Adaptive Boosting)**: An ensemble method that combines weak learners by adjusting weights based on previous errors.

**ADASYN (Adaptive Synthetic Sampling)**: An oversampling technique that generates synthetic samples for minority classes, focusing on harder-to-learn examples.

**Agglomerative Clustering**: A hierarchical clustering method that starts with each point as its own cluster and merges closest clusters iteratively.

**ANOVA (Analysis of Variance)**: A statistical test used to compare means across multiple groups.

**API (Application Programming Interface)**: A set of protocols and tools for building software applications, enabling communication between different systems.

**AUC (Area Under Curve)**: A performance metric for classification models, measuring the area under the ROC curve.

**Autoencoder**: A neural network trained to reconstruct its input, learning a compressed representation in the process.

**Autograd (Automatic Differentiation)**: A technique used in deep learning frameworks to automatically compute gradients for backpropagation.

## B

**Backpropagation**: An algorithm for training neural networks that computes gradients by propagating errors backward through the network.

**Bagging (Bootstrap Aggregating)**: An ensemble method that trains multiple models on bootstrap samples and averages their predictions.

**Batch**: A subset of training data processed together in a single forward/backward pass.

**Batch Normalization**: A technique that normalizes layer inputs to improve training speed and stability.

**Bayesian Optimization**: A strategy for optimizing expensive black-box functions using probabilistic models.

**Bias (Model)**: The error introduced by approximating a real-world problem with a simplified model.

**Binary Classification**: A classification task with two possible outcomes (e.g., spam vs. not spam).

**Boosting**: An ensemble method that sequentially trains models, each correcting errors of its predecessors.

**Bootstrap**: Sampling with replacement from a dataset to create multiple training sets.

## C

**Categorical Variable**: A variable with a finite set of discrete values (e.g., gender, color, country).

**CatBoost**: A gradient boosting framework that handles categorical features natively.

**Chain Rule**: A calculus rule used in backpropagation for computing gradients through composite functions.

**Chi-Square Test**: A statistical test for categorical variables, assessing independence between two variables.

**Classification**: A supervised learning task where the goal is to predict a categorical label.

**Cluster**: A group of data points that are similar to each other and different from points in other clusters.

**Clustering**: An unsupervised learning task that groups similar data points together.

**Cold Start**: The challenge of making predictions for new users or items with no historical data.

**Column Transformer**: A scikit-learn class that applies different transformations to different columns.

**Confusion Matrix**: A table showing the performance of a classification model, with true vs. predicted labels.

**Convergence**: The point at which an optimization algorithm has found a stable solution.

**Convex Function**: A function where the line segment between any two points lies above the function graph.

**Correlation**: A measure of the linear relationship between two variables (range: -1 to 1).

**Cost Function**: See Loss Function.

**Cross-Validation**: A technique for evaluating model performance by splitting data into multiple train/test sets.

## D

**Data Drift**: The change in data distribution over time, which can degrade model performance.

**Data Leakage**: The unintentional use of information from outside the training set, leading to overly optimistic performance.

**Dataset**: A collection of data points, typically with features and (for supervised learning) targets.

**DBSCAN (Density-Based Spatial Clustering)**: A clustering algorithm that finds clusters based on density, handling arbitrary shapes.

**Decision Tree**: A tree-based model that splits data based on feature values to make predictions.

**Deep Learning**: A subset of machine learning using neural networks with many layers.

**Dendrogram**: A tree diagram used to visualize hierarchical clustering results.

**Density**: A measure of how closely data points are packed in a region.

**Dimensionality**: The number of features in a dataset.

**Dimensionality Reduction**: Techniques to reduce the number of features while preserving important information.

**Discriminant**: A function that separates different classes.

**Divergence**: A measure of how two probability distributions differ.

**Dropout**: A regularization technique that randomly drops neurons during training to prevent overfitting.

## E

**Early Stopping**: A regularization technique that stops training when validation performance stops improving.

**EDA (Exploratory Data Analysis)**: The process of analyzing data to discover patterns, anomalies, and insights.

**Eigenvalue**: A scalar representing the magnitude of a transformation in a particular direction.

**Eigenvector**: A vector that only changes by a scalar factor when a linear transformation is applied.

**Elastic Net**: A regression method that combines L1 and L2 regularization.

**Embedding**: A mapping of discrete values (e.g., words, categories) to continuous vectors.

**Ensemble**: A model combining multiple individual models to improve performance.

**Entropy**: A measure of uncertainty or information content in a probability distribution.

**Epoch**: One complete pass through the entire training dataset.

**Euclidean Distance**: The straight-line distance between two points in Euclidean space.

**Evaluation Metric**: A measure used to assess model performance (e.g., accuracy, F1, MSE).

## F

**F1 Score**: The harmonic mean of precision and recall: 2 * (P * R) / (P + R).

**False Negative (FN)**: A case where the model incorrectly predicts the negative class.

**False Positive (FP)**: A case where the model incorrectly predicts the positive class.

**Feature**: An individual measurable property of a data point (also called variable, attribute).

**Feature Engineering**: The process of creating new features from raw data.

**Feature Hashing**: A technique for encoding high-cardinality categorical features using hash functions.

**Feature Importance**: A measure of how much each feature contributes to the model's predictions.

**Feature Selection**: The process of selecting a subset of relevant features for use in model training.

**Feedforward Neural Network**: A neural network where connections do not form cycles.

**Focal Loss**: A loss function designed to address class imbalance by focusing on hard examples.

**Forward Propagation**: The process of passing input through a neural network to generate output.

**Frequency Encoding**: Replacing categorical values with their frequency in the training data.

## G

**Gaussian Distribution**: A normal distribution, characterized by mean and standard deviation.

**Gaussian Mixture Model (GMM)**: A probabilistic model that assumes data is generated from multiple Gaussian distributions.

**Gini Impurity**: A measure of how often a randomly chosen element would be incorrectly labeled.

**GPU (Graphics Processing Unit)**: A specialized processor used for parallel computing, ideal for deep learning.

**Gradient**: A vector of partial derivatives indicating the direction of steepest ascent.

**Gradient Boosting**: An ensemble method that builds models sequentially, each correcting previous errors.

**Gradient Descent**: An optimization algorithm that iteratively updates parameters to minimize a loss function.

**Gradient Vanishing**: A problem in deep networks where gradients become very small, preventing learning.

**Grid Search**: A hyperparameter optimization method that exhaustively tries all combinations.

## H

**HDBSCAN**: A clustering algorithm that extends DBSCAN to handle varying densities.

**He Initialization**: A weight initialization method for neural networks, designed for ReLU activations.

**Heteroscedasticity**: When the variance of errors is not constant across observations.

**Hidden Layer**: A layer in a neural network between the input and output layers.

**Hierarchical Clustering**: A clustering method that builds a hierarchy of clusters.

**Homoscedasticity**: When the variance of errors is constant across observations.

**Huber Loss**: A loss function combining MSE and MAE, robust to outliers.

**Hyperparameter**: A parameter set before training (e.g., learning rate, tree depth).

**Hypothesis Testing**: A statistical method for testing assumptions about data.

## I

**Imbalanced Data**: A dataset where the class distribution is significantly skewed.

**Imputation**: The process of filling in missing values.

**Inference**: Using a trained model to make predictions on new data.

**Information Gain**: A measure of how much a feature reduces uncertainty about the target.

**Instance**: A single data point (row) in a dataset.

**Interaction Feature**: A feature created by combining two or more features (e.g., product, ratio).

**IQR (Interquartile Range)**: The range between the first and third quartiles, used for outlier detection.

**Iteration**: One update of model parameters during training.

## J

**Jaccard Index**: A similarity metric for sets: |A ∩ B| / |A ∪ B|.

**Joint Distribution**: The probability distribution of two or more variables.

**Jupyter Notebook**: An interactive computing environment for data analysis and exploration.

## K

**K-Fold Cross-Validation**: A CV method that splits data into K folds and trains K times.

**K-Means**: A clustering algorithm that partitions data into K clusters based on centroids.

**K-Nearest Neighbors (KNN)**: A classification/regression method that uses the K closest training points.

**Kernel**: A function used in SVMs and other algorithms to implicitly map to higher dimensions.

**Kernel Density Estimation**: A non-parametric way to estimate the probability density function.

**KL Divergence (Kullback-Leibler Divergence)**: A measure of difference between two probability distributions.

**Kurtosis**: A measure of the "tailedness" of a probability distribution.

## L

**L1 Regularization (Lasso)**: Regularization that adds absolute value of coefficients to the loss.

**L2 Regularization (Ridge)**: Regularization that adds squared value of coefficients to the loss.

**Label**: The target value in supervised learning.

**Lag Feature**: A feature created from previous time steps in time series data.

**Latent Variable**: A variable that is not directly observed but inferred from other variables.

**Learning Curve**: A plot showing model performance as a function of training set size.

**Learning Rate**: A hyperparameter controlling how much to update parameters during training.

**LightGBM**: A fast gradient boosting framework with histogram-based training.

**Linear Regression**: A model that assumes a linear relationship between features and target.

**Loss Function**: A function that measures how wrong a model's predictions are.

## M

**MAE (Mean Absolute Error)**: The average absolute difference between predictions and actual values.

**MAPE (Mean Absolute Percentage Error)**: The average percentage error: (1/n) * Σ |(actual-pred)/actual|.

**Margin**: The distance between a decision boundary and the nearest data points.

**Min-Max Scaling**: Scaling features to a fixed range, typically [0, 1].

**MLE (Maximum Likelihood Estimation)**: A method for estimating model parameters that maximize the likelihood.

**MLP (Multi-Layer Perceptron)**: A type of neural network with multiple hidden layers.

**Momentum**: A technique that accelerates gradient descent by accumulating past gradients.

**MSE (Mean Squared Error)**: The average squared difference between predictions and actual values.

**Multicollinearity**: When features are highly correlated with each other.

## N

**Naive Bayes**: A probabilistic classifier based on Bayes' theorem with strong independence assumptions.

**Neural Network**: A computing system inspired by biological neural networks, consisting of layers of neurons.

**Noise**: Random variation in data that doesn't represent the underlying signal.

**Non-Linear**: Relationships that cannot be represented by a straight line.

**Normal Distribution**: A symmetric, bell-shaped probability distribution.

**Normalization**: Scaling data to a standard range (often [0, 1] or [-1, 1]).

**Null Hypothesis (H₀)**: The default assumption in hypothesis testing that there is no effect.

## O

**OHE (One-Hot Encoding)**: Encoding categorical variables as binary vectors.

**One-Class SVM**: An anomaly detection method that finds a boundary around normal data.

**Online Learning**: Training models incrementally as new data arrives.

**OpenAPI**: A specification for describing RESTful APIs.

**Optimizer**: An algorithm that updates model parameters to minimize the loss.

**Ordinal Encoding**: Encoding categories as ordered integers.

**Outlier**: An observation that deviates significantly from other observations.

**Oversampling**: Increasing the number of samples in the minority class.

**Overfitting**: When a model fits the training data too well but fails to generalize.

## P

**P-Value**: The probability of observing results as extreme as those observed, assuming the null hypothesis.

**PCA (Principal Component Analysis)**: A dimensionality reduction technique that finds directions of maximum variance.

**Perceptron**: The simplest neural network model, with only an input and output layer.

**Pipeline**: A sequence of data processing steps, ending with a model.

**Polynomial Features**: Features created by raising existing features to powers.

**Precision**: The proportion of true positive predictions among all positive predictions: TP / (TP + FP).

**Predictive Power**: A model's ability to make accurate predictions on new data.

**PR-AUC (Precision-Recall AUC)**: The area under the precision-recall curve.

**Probability**: A measure of the likelihood of an event occurring.

**Proximity**: A measure of similarity or distance between data points.

**Pruning**: Reducing model complexity by removing parts of the model.

## Q

**Quantile**: A value that divides a probability distribution into equal intervals.

**Quantile Regression**: Regression that estimates quantiles of the target distribution.

**Quantile Transformation**: A transformation that maps data to a uniform or normal distribution.

**Quasi-Newton Methods**: Optimization algorithms that approximate the Hessian matrix.

## R

**R² Score (Coefficient of Determination)**: A measure of how well the model explains the variance in the target.

**Random Forest**: An ensemble of decision trees using bagging and feature randomization.

**Random Search**: A hyperparameter optimization method that randomly samples parameter combinations.

**Recall (Sensitivity)**: The proportion of true positives correctly identified: TP / (TP + FN).

**ReLU (Rectified Linear Unit)**: An activation function: f(x) = max(0, x).

**Regularization**: Techniques to prevent overfitting by penalizing complexity.

**Residual**: The difference between a predicted value and the actual value.

**Residual Connection**: A connection that bypasses one or more layers, helping with gradient flow.

**ROC-AUC**: The area under the Receiver Operating Characteristic curve.

**Robust Scaling**: Scaling using median and IQR, robust to outliers.

## S

**Scaler**: A transformer that scales features to a specific range.

**Schema**: A definition of the structure of data (columns, types, constraints).

**Sigmoid**: An activation function: f(x) = 1 / (1 + e^(-x)).

**Silhouette Score**: A metric for evaluating clustering quality.

**Skewness**: A measure of the asymmetry of a distribution.

**SMOTE (Synthetic Minority Oversampling Technique)**: An oversampling method that creates synthetic minority samples.

**Softmax**: An activation function that converts logits to probabilities.

**Sparse Matrix**: A matrix with most elements being zero.

**Spectral Clustering**: A clustering method using eigenvectors of the similarity matrix.

**Standardization**: Scaling features to have zero mean and unit variance.

**Stochastic Gradient Descent (SGD)**: Gradient descent using random mini-batches.

**Stratification**: Ensuring class proportions are maintained in splits.

**Support Vector Machine (SVM)**: A classifier that finds the hyperplane maximizing margin.

## T

**T-Distributed Stochastic Neighbor Embedding (t-SNE)**: A dimensionality reduction technique for visualization.

**Tanh**: An activation function: f(x) = (e^x - e^-x) / (e^x + e^-x).

**Target**: The variable we want to predict (also called label, dependent variable).

**Target Encoding**: Replacing categorical values with the mean of the target variable.

**Temporal Split**: Splitting data based on time (e.g., training on past data, testing on future).

**Tensor**: A multi-dimensional array used in deep learning.

**Test Set**: A dataset used to evaluate the final model.

**Training Set**: A dataset used to train the model.

**Transformer**: An object that transforms data (e.g., Scaler, Encoder).

**Tree**: A hierarchical decision structure used in decision trees and ensemble methods.

**True Negative (TN)**: A case where the model correctly predicts the negative class.

**True Positive (TP)**: A case where the model correctly predicts the positive class.

**Tuning**: The process of selecting optimal hyperparameters.

## U

**UMAP (Uniform Manifold Approximation and Projection)**: A dimensionality reduction technique similar to t-SNE.

**Underfitting**: When a model fails to capture the patterns in the training data.

**Undersampling**: Reducing the number of samples in the majority class.

**Unsupervised Learning**: Learning patterns from unlabeled data.

**Upsampling**: See Oversampling.

## V

**Validation Set**: A dataset used to tune hyperparameters and monitor overfitting.

**Variance**: (1) A measure of data spread: E[(X - μ)²]. (2) The variability of model predictions across different training sets.

**Variance Threshold**: A feature selection method that removes features with low variance.

**Vector**: A one-dimensional array of numbers.

**Versioning**: Tracking changes to code, data, and models over time.

## W

**Weight**: A parameter in a model that determines the influence of a feature.

**Weight Initialization**: The method of setting initial weights before training.

**Winsorizing**: Replacing extreme values with less extreme values.

**Word Embedding**: A representation of words as dense vectors.

**Wrapper Method**: A feature selection method that uses a model to evaluate feature subsets.

## X

**XGBoost**: An optimized gradient boosting library that stands for eXtreme Gradient Boosting.

## Y

**YAML**: A human-readable data serialization format used for configuration files.

**Yeo-Johnson Transformation**: A power transformation that handles both positive and negative values.

## Z

**Z-Score**: A measure of how many standard deviations a value is from the mean.

**Zero-Shot Learning**: Learning to recognize classes without any training examples.

---

This glossary provides definitions for key terms used throughout the series. Bookmark this page for quick reference when encountering unfamiliar terminology.

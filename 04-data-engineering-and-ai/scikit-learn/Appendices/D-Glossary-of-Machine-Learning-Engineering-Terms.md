## Appendix D: Glossary of Machine Learning Engineering Terms

To ensure you have a complete technical reference manual for your engineering journey, this glossary defines the essential industry terminology used throughout this tutorial series.

---

### 1. Core Mathematical & Modeling Terms

* **Algorithm:** A set of step-by-step mathematical rules and instructions that a computer follows to learn patterns from data (e.g., Random Forest, Linear Regression).
* **Attribute:** A parameter learned by a model *during* training (e.g., weights, coefficients, or cluster centers). In Scikit-Learn, attributes are always suffixed with a trailing underscore (`_`).
* **Classification:** A supervised learning task focused on predicting discrete categorical class labels (e.g., spam vs. not spam, churn vs. retained).
* **Clustering:** An unsupervised learning technique used to group unlabelled data points into natural clusters based on feature similarities.
* **Coefficient:** A numerical weight assigned to a feature in linear models, indicating the strength and direction of that feature's relationship with the target variable.
* **Cross-Validation:** A robust model evaluation technique where data is partitioned into $k$ folds, and the model is trained and tested $k$ separate times to ensure evaluation metrics are not dependent on a lucky single train/test split.
* **Data Drift:** The silent phenomenon where production data distributions shift away from the baseline data distributions used during training, leading to degraded model accuracy.
* **Decision Tree:** A non-linear machine learning model that makes predictions by executing a hierarchical flowchart of binary true/false questions based on feature values.
* **Ensemble Method:** A machine learning strategy that combines multiple distinct models (e.g., bagging, boosting, or voting classifiers) to produce more accurate and robust predictions than any single model could achieve alone.
* **Estimator:** The foundational base class interface in Scikit-Learn representing any object that learns from data via a `.fit()` method.
* **Feature:** An individual measurable property, characteristic, or input variable used by a model to make predictions (represented as columns in a dataset).
* **Gradient Boosting:** An iterative ensemble technique where each new decision tree is trained specifically to predict and correct the residual errors made by the previous ensemble of trees.
* **Hyperparameter:** A structural setting chosen *before* model training begins (e.g., maximum depth of a tree, learning rate, or number of estimators) that dictates how the learning algorithm behaves.
* **Imputation:** The statistical process of filling in missing or null data values using estimated metrics (such as the median, mean, or a constant string).
* **Inertia:** In K-Means clustering, the sum of squared distances from each data point to its assigned cluster center. Lower inertia indicates tighter, more cohesive clusters.
* **Isolation Forest:** An unsupervised anomaly detection algorithm that isolates outliers by measuring how quickly random feature splits can isolate a data point.
* **Label (Target):** The known output value, correct answer, or supervisory signal in a dataset that supervised models attempt to predict.
* **Loss Function:** A mathematical function that calculates the penalty or error between a model's predicted output and the true target value during training.
* **Mean Squared Error (MSE):** A regression metric that measures the average squared difference between estimated values and actual values, heavily penalizing large errors.
* **MLOps (Machine Learning Operations):** A set of engineering practices combining machine learning, DevOps, and data engineering to deploy, monitor, and manage machine learning systems in production reliably.
* **One-Hot Encoding:** A preprocessing technique that converts categorical text variables into binary true/false (0 or 1) indicator columns.
* **Overfitting:** A modeling failure where a model memorizes the specific noise and quirks of its training dataset rather than learning generalizable patterns, leading to poor performance on unseen data.
* **Pipeline:** An encapsulated Scikit-Learn object that chains sequential preprocessing steps and a final estimator together into a single unified object, preventing data leakage.
* **Principal Component Analysis (PCA):** An unsupervised dimensionality reduction technique that compresses high-dimensional data into orthogonal principal components while retaining maximum variance.
* **Random Forest:** An ensemble learning method that constructs a multitude of randomized decision trees during training and outputs the majority vote of the individual trees.
* **Recall:** A classification metric measuring the proportion of actual positive cases that were correctly identified by the model (minimizing false negatives).
* **Regression:** A supervised learning task focused on predicting continuous numerical values (e.g., housing prices, sales revenue, or temperature).
* **Regularization:** A technique that adds a penalty term to a model's loss function (such as L1 or L2 penalties) to prevent coefficient explosion and overfitting.
* **Serialization:** The process of converting a trained model object and its internal state into a binary format (using tools like `joblib` or `pickle`) to be saved to disk and loaded into production servers.
* **Silhouette Score:** A metric evaluating how similar a data point is to its own cluster compared to neighboring clusters, ranging from -1 to +1.
* **Standardization (Scaling):** A preprocessing transformation that centers numerical features by subtracting the mean and scaling to unit variance (standard deviation of 1).
* **Transformer:** A Scikit-Learn object that implements a `.transform()` method to modify dataset features (e.g., scalers, imputers, and encoders).

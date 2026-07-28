## Part 3: Unsupervised Learning & Dimensionality Reduction

Welcome to Part 3. In supervised learning, our data came with an answer key. Now, we step into **Unsupervised Learning**, where we throw away the answer key entirely.

Unsupervised learning is like dropping an investigator into a massive room of strangers with no biographical records. Their job is to find natural friendship circles (**clustering**), summarize complex individual personalities into core behavioral traits (**dimensionality reduction**), or spot the one suspicious individual wearing a disguise (**anomaly detection**).

---

### Step 3.1: Clustering Algorithms – K-Means, DBSCAN, & Hierarchical

#### The Target

Write a script (`unsupervised_clustering.py`) that applies K-Means, DBSCAN, and Agglomerative Hierarchical clustering to group unlabelled data points.

#### The Concept

* **K-Means** assumes your data forms neat, spherical island clusters. You tell the model how many islands to look for ($K$), and it iteratively shifts center pins until everyone belongs to the nearest island.
* **DBSCAN** (Density-Based Spatial Clustering of Applications with Noise) does not require you to guess the number of clusters. Instead, it groups points that are packed closely together, ignoring isolated stragglers and labeling them as outliers or noise.
* **Hierarchical Clustering** builds a family tree of data points, merging closest relatives step-by-step until all data branches meet at a single trunk.

#### The Implementation

Create a file named `unsupervised_clustering.py` with the following code:

```python
# unsupervised_clustering.py
import numpy as np
from sklearn.datasets import make_blobs
from sklearn.cluster import KMeans, DBSCAN, AgglomerativeClustering
from sklearn.metrics import silhouette_score

def run_clustering():
    # Generate synthetic unlabelled data with distinct blobs
    X, _ = make_blobs(n_samples=300, centers=4, cluster_std=0.60, random_state=42)

    print("--- 1. K-Means Clustering ---")
    kmeans = KMeans(n_clusters=4, n_init=10, random_state=42)
    kmeans_labels = kmeans.fit_predict(X)
    kmeans_silhouette = silhouette_score(X, kmeans_labels)
    print(f"K-Means Silhouette Score: {kmeans_silhouette:.4f}")

    print("\n--- 2. DBSCAN Clustering ---")
    dbscan = DBSCAN(eps=0.3, min_samples=5)
    dbscan_labels = dbscan.fit_predict(X)
    # Filter out noise points (-1) for silhouette calculation if any exist
    n_clusters_db = len(set(dbscan_labels)) - (1 if -1 in dbscan_labels else 0)
    print(f"DBSCAN estimated clusters found: {n_clusters_db}")
    print(f"DBSCAN identified noise points: {list(dbscan_labels).count(-1)}")

    print("\n--- 3. Hierarchical Agglomerative Clustering ---")
    hierarchical = AgglomerativeClustering(n_clusters=4)
    hier.labels_ = hierarchical.fit_predict(X)
    hier_silhouette = silhouette_score(X, hier.labels_)
    print(f"Hierarchical Silhouette Score: {hier_silhouette:.4f}")

if __name__ == '__main__':
    run_clustering()

```

#### The Verification

Execute the clustering script in your terminal:

```bash
python unsupervised_clustering.py

```

You should see silhouette evaluation scores for K-Means and Hierarchical clustering, alongside cluster counts and noise tallies for DBSCAN.

---

### Step 3.2: Dimensionality Reduction with Principal Component Analysis (PCA)

#### The Target

Compress a multi-feature dataset down to two dimensions using Principal Component Analysis in a script named `dimensionality_reduction.py`.

#### The Concept

Imagine photographing a complex 3D statue. Depending on the angle of your camera, you capture a 2D shadow that preserves most of the statue's defining silhouette while discarding redundant depth. **Principal Component Analysis (PCA)** is the mathematical equivalent of finding the optimal camera angles (principal components) that capture the maximum amount of variance (information) with the fewest possible features.

#### The Implementation

Create a file named `dimensionality_reduction.py` with the following code:

```python
# dimensionality_reduction.py
from sklearn.datasets import load_iris
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

def run_pca():
    # Load the classic Iris dataset (4 features)
    iris = load_iris()
    X, y = iris.data, iris.target

    # Scale features so high-magnitude measurements do not dominate variance
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    # Apply PCA to reduce 4 dimensions down to 2 principal components
    pca = PCA(n_components=2)
    X_reduced = pca.fit_transform(X_scaled)

    print("--- PCA Transformation Results ---")
    print(f"Original shape: {X.shape}")
    print(f"Reduced shape: {X_reduced.shape}")
    
    explained_variance = pca.explained_variance_ratio_
    print(f"Variance explained by Principal Component 1: {explained_variance[0]*100:.2f}%")
    print(f"Variance explained by Principal Component 2: {explained_variance[1]*100:.2f}%")
    print(f"Total cumulative variance retained: {sum(explained_variance)*100:.2f}%")

if __name__ == '__main__':
    run_pca()

```

#### The Verification

Run the PCA script via your terminal:

```bash
python dimensionality_reduction.py

```

You should see confirmation that the 4-dimensional iris dataset was compressed to 2 dimensions while retaining over 95% of the total dataset variance.

---

### Step 3.3: Anomaly Detection – Isolation Forests & Local Outlier Factor

#### The Target

Build an unsupervised anomaly detection script (`anomaly_detection.py`) to isolate fraudulent or abnormal records using Isolation Forests.

#### The Concept

Normal data points require many sequential filtering questions to isolate because they sit tightly packed in dense neighborhoods. Outliers, however, are loners sitting out in the open—they are easily isolated with very few random splits. An **Isolation Forest** exploits this trait, measuring how quickly a data point can be isolated to flag it as an anomaly.

#### The Implementation

Create a file named `anomaly_detection.py` with the following code:

```python
# anomaly_detection.py
import numpy as np
from sklearn.ensemble import IsolationForest

def run_anomaly_detection():
    # Generate clean training data and inject a few extreme outliers
    np.random.seed(42)
    X_normal = np.random.normal(loc=0.0, scale=1.0, size=(100, 2))
    X_outliers = np.random.uniform(low=-6.0, high=6.0, size=(5, 2))
    X = np.vstack([X_normal, X_outliers])

    # Instantiate and fit Isolation Forest
    # contamination represents our expected proportion of outliers
    iso_forest = IsolationForest(contamination=0.05, random_state=42)
    preds = iso_forest.fit_predict(X)

    # IsolationForest outputs 1 for inliers and -1 for outliers
    n_outliers_detected = list(preds).count(-1)

    print("--- Anomaly Detection Results ---")
    print(f"Total samples evaluated: {len(X)}")
    print(f"Outliers flagged by Isolation Forest: {n_outliers_detected}")

if __name__ == '__main__':
    run_anomaly_detection()

```

#### The Verification

Execute the anomaly detection script:

```bash
python anomaly_detection.py

```

You should see output confirming that the Isolation Forest successfully scanned the batch and flagged the injected outliers.

---

### Reference Section: Unsupervised Evaluation Metrics

* **Silhouette Score:** Measures how similar a data point is to its own cluster compared to other clusters. Ranges from -1 to +1, where higher scores indicate dense, well-separated clusters.
* **Inertia (K-Means):** Sum of squared distances of samples to their closest cluster center. Lower inertia indicates tighter clusters, though dropping infinitely as $K$ increases requires the "Elbow Method" to find the optimal cluster count.

## Part 3: Unsupervised Learning & Dimensionality Reduction

Welcome to Part 3. In supervised learning our data came with an answer key. Now we step into **Unsupervised Learning**, where that answer key is discarded.

Unsupervised learning is like dropping an investigator into a large room of strangers who have no name tags or biographical records. The investigator’s job is to discover natural friendship circles (**clustering**), summarize complex personalities into a few core behavioral traits (**dimensionality reduction**), or spot the one individual behaving suspiciously (**anomaly detection**).

---

### Step 3.1: Clustering Algorithms – K-Means, DBSCAN & Hierarchical

#### The Target

Write a script (`unsupervised_clustering.py`) that applies K-Means, DBSCAN, and Agglomerative Hierarchical clustering to group unlabeled data points and evaluates the results with silhouette scores where appropriate.

#### The Concept

* **K-Means** assumes the data forms roughly spherical clusters. You specify the number of clusters \(K\); the algorithm iteratively updates cluster centers until each point belongs to the nearest center.
* **DBSCAN** (Density-Based Spatial Clustering of Applications with Noise) does not require you to choose \(K\). It groups points that are densely packed together and labels isolated points as noise/outliers.
* **Hierarchical (Agglomerative) Clustering** builds a tree of clusters by successively merging the closest pairs of points or clusters until a stopping criterion (often a desired number of clusters) is reached.

#### The Implementation

Create a file named `unsupervised_clustering.py` with the following code:

```python
# unsupervised_clustering.py
import numpy as np
from sklearn.datasets import make_blobs
from sklearn.cluster import KMeans, DBSCAN, AgglomerativeClustering
from sklearn.metrics import silhouette_score

def run_clustering():
    # Generate synthetic unlabeled data with four distinct blobs
    X, _ = make_blobs(
        n_samples=300, centers=4, cluster_std=0.60, random_state=42
    )

    print("--- 1. K-Means Clustering ---")
    kmeans = KMeans(n_clusters=4, n_init=10, random_state=42)
    kmeans_labels = kmeans.fit_predict(X)
    kmeans_silhouette = silhouette_score(X, kmeans_labels)
    print(f"K-Means Silhouette Score: {kmeans_silhouette:.4f}")

    print("\n--- 2. DBSCAN Clustering ---")
    dbscan = DBSCAN(eps=0.3, min_samples=5)
    dbscan_labels = dbscan.fit_predict(X)
    n_clusters_db = len(set(dbscan_labels)) - (1 if -1 in dbscan_labels else 0)
    n_noise = list(dbscan_labels).count(-1)
    print(f"DBSCAN estimated clusters: {n_clusters_db}")
    print(f"DBSCAN noise points: {n_noise}")

    # Silhouette is only meaningful when more than one cluster and some non-noise points exist
    if n_clusters_db > 1 and n_noise < len(X):
        mask = dbscan_labels != -1
        if mask.sum() > 1:
            db_sil = silhouette_score(X[mask], dbscan_labels[mask])
            print(f"DBSCAN Silhouette (non-noise): {db_sil:.4f}")

    print("\n--- 3. Hierarchical Agglomerative Clustering ---")
    hierarchical = AgglomerativeClustering(n_clusters=4)
    hier_labels = hierarchical.fit_predict(X)
    hier_silhouette = silhouette_score(X, hier_labels)
    print(f"Hierarchical Silhouette Score: {hier_silhouette:.4f}")

if __name__ == '__main__':
    run_clustering()
```

#### The Verification

Execute the clustering script:

```bash
python unsupervised_clustering.py
```

You should see silhouette scores for K-Means and Hierarchical clustering, together with the number of clusters and noise points identified by DBSCAN.

---

### Step 3.2: Dimensionality Reduction with Principal Component Analysis (PCA)

#### The Target

Compress a multi-feature dataset down to two dimensions using Principal Component Analysis in a script named `dimensionality_reduction.py`.

#### The Concept

Imagine photographing a complex three-dimensional statue. Depending on the camera angle, the two-dimensional photograph retains most of the statue’s distinctive silhouette while discarding redundant depth information. **Principal Component Analysis (PCA)** finds the optimal “camera angles” (principal components) that capture the maximum amount of variance (information) with the fewest possible dimensions.

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

    # Always scale before PCA — otherwise high-magnitude features dominate
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    # Reduce from 4 dimensions to 2 principal components
    pca = PCA(n_components=2)
    X_reduced = pca.fit_transform(X_scaled)

    print("--- PCA Transformation Results ---")
    print(f"Original shape: {X.shape}")
    print(f"Reduced shape:  {X_reduced.shape}")

    explained = pca.explained_variance_ratio_
    print(f"Variance explained by PC1: {explained[0]*100:.2f}%")
    print(f"Variance explained by PC2: {explained[1]*100:.2f}%")
    print(f"Total variance retained:   {sum(explained)*100:.2f}%")

if __name__ == '__main__':
    run_pca()
```

#### The Verification

Run the PCA script:

```bash
python dimensionality_reduction.py
```

You should see that the 4-dimensional Iris data was successfully compressed to 2 dimensions while retaining the large majority of the original variance (typically > 95 %).

---

### Step 3.3: Anomaly Detection – Isolation Forest

#### The Target

Build an unsupervised anomaly-detection script (`anomaly_detection.py`) that isolates abnormal records using an Isolation Forest.

#### The Concept

Normal observations lie in dense regions and require many random partitions to isolate. Outliers sit far from the bulk of the data and can be isolated with very few splits. An **Isolation Forest** exploits this property: the average path length required to isolate a point becomes a measure of its anomaly score. Points with unusually short average path lengths are flagged as anomalies.

#### The Implementation

Create a file named `anomaly_detection.py` with the following code:

```python
# anomaly_detection.py
import numpy as np
from sklearn.ensemble import IsolationForest

def run_anomaly_detection():
    np.random.seed(42)

    # Clean normal data + a few extreme outliers
    X_normal = np.random.normal(loc=0.0, scale=1.0, size=(100, 2))
    X_outliers = np.random.uniform(low=-6.0, high=6.0, size=(5, 2))
    X = np.vstack([X_normal, X_outliers])

    # contamination = expected proportion of outliers
    iso_forest = IsolationForest(contamination=0.05, random_state=42)
    preds = iso_forest.fit_predict(X)

    # IsolationForest returns 1 for inliers and -1 for outliers
    n_outliers = list(preds).count(-1)

    print("--- Anomaly Detection Results ---")
    print(f"Total samples evaluated: {len(X)}")
    print(f"Outliers flagged by Isolation Forest: {n_outliers}")

if __name__ == '__main__':
    run_anomaly_detection()
```

#### The Verification

Execute the anomaly-detection script:

```bash
python anomaly_detection.py
```

You should see that the Isolation Forest correctly flags a number of outliers close to the five extreme points we injected.

---

### Reference Section: Unsupervised Evaluation Metrics & Guidance

* **Silhouette Score** — Measures how similar a point is to its own cluster compared with other clusters. Ranges from –1 to +1; higher values indicate better-defined clusters.
* **Inertia (K-Means)** — Sum of squared distances from each point to its assigned cluster center. Lower inertia means tighter clusters, but inertia always decreases as \(K\) grows, so the “elbow method” or silhouette analysis is needed to choose a sensible \(K\).
* **DBSCAN Parameters** — `eps` (neighborhood radius) and `min_samples` control density. These are data-dependent; a quick k-distance plot can help select a reasonable `eps`.
* **When to Prefer Each Algorithm**
  * K-Means — roughly spherical, similarly sized clusters and a known or easily estimated \(K\).
  * DBSCAN — arbitrary shapes, presence of noise, and no need to specify the number of clusters.
  * Hierarchical — small-to-medium datasets where a dendrogram (cluster hierarchy) is useful for interpretation.
  * Isolation Forest — high-dimensional data or when a fast, tree-based anomaly score is desired.

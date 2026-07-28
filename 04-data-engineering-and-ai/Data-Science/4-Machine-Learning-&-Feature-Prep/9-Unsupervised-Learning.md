# Module 4.2: Supervised & Unsupervised Learning

## Part 9: Unsupervised Learning

Welcome back! In Part 8, we mastered supervised tree-based models. Now we shift to unsupervised learning—discovering hidden patterns and structures in data without labeled targets. This is like exploring a new city without a map, finding natural neighborhoods and landmarks purely by observation.

### The Target: A Complete Unsupervised Learning System

By the end of this part, you'll have:
1. K-Means clustering with automated K selection
2. DBSCAN with adaptive parameter tuning
3. Hierarchical clustering with dendrogram visualization
4. Clustering validation metrics (Silhouette Score, Davies-Bouldin Index)
5. Dimensionality reduction for visualization (PCA, t-SNE)
6. Unified API for all clustering algorithms
7. Cluster profiling and interpretation tools

### The Concept: Understanding Unsupervised Learning

Think of unsupervised learning like organizing a library without knowing the categories:

**K-Means**: Like deciding there should be exactly 5 sections, then putting each book into the section whose "average" book it's most similar to. You keep adjusting the section definitions until they stabilize.

**DBSCAN**: Like finding clusters of books that are close together on the shelves. Books that are isolated (no close neighbors) are considered outliers.

**Hierarchical Clustering**: Like building a family tree of books. You start with each book alone and repeatedly merge the two most similar books or groups until everything is connected.

#### Why Unsupervised Learning Matters

1. **Discover unknown patterns**: Find groups you didn't know existed
2. **Data exploration**: Understand the structure of your data
3. **Preprocessing for supervised learning**: Create cluster features
4. **Anomaly detection**: Find outliers and unusual patterns
5. **Dimensionality reduction**: Summarize data with cluster labels

#### The Clustering Spectrum

```
Simple, Assumptive ←─────────────────────────────→ Complex, Flexible

K-Means ←─ Hierarchical ←─ DBSCAN ←─ GMM ←─ Spectral
(Spherical)    (Tree)     (Density) (Probabilistic) (Graph)
```

### The Implementation: Building Our Unsupervised Learning System

#### Step 1: Unified Clustering Interface

**File:** `src/models/clustering.py`
**Path:** `ml-pipeline-project/src/models/clustering.py`

```python
"""
Unsupervised learning: Clustering algorithms.

This module provides a unified interface for:
- K-Means clustering
- DBSCAN
- Hierarchical clustering
- Gaussian Mixture Models
- Spectral clustering
"""

from typing import Dict, List, Optional, Union, Any, Tuple
import warnings
import numpy as np
import pandas as pd
from loguru import logger
from sklearn.base import BaseEstimator, ClusterMixin
from sklearn.cluster import (
    KMeans, DBSCAN, AgglomerativeClustering,
    SpectralClustering, Birch
)
from sklearn.mixture import GaussianMixture
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import silhouette_score, davies_bouldin_score, calinski_harabasz_score
from sklearn.decomposition import PCA

warnings.filterwarnings("ignore", category=UserWarning)

class ClusteringMethod:
    """Enumeration of available clustering methods."""
    KMEANS = "kmeans"
    DBSCAN = "dbscan"
    HIERARCHICAL = "hierarchical"
    GMM = "gmm"  # Gaussian Mixture Model
    SPECTRAL = "spectral"
    BIRCH = "birch"

class ClusterValidator:
    """Validation metrics for clustering results."""
    
    @staticmethod
    def silhouette(X: np.ndarray, labels: np.ndarray) -> float:
        """Calculate silhouette score (higher is better, range [-1, 1])."""
        if len(np.unique(labels)) < 2:
            return 0.0
        return silhouette_score(X, labels)
    
    @staticmethod
    def davies_bouldin(X: np.ndarray, labels: np.ndarray) -> float:
        """Calculate Davies-Bouldin index (lower is better)."""
        if len(np.unique(labels)) < 2:
            return float('inf')
        return davies_bouldin_score(X, labels)
    
    @staticmethod
    def calinski_harabasz(X: np.ndarray, labels: np.ndarray) -> float:
        """Calculate Calinski-Harabasz index (higher is better)."""
        if len(np.unique(labels)) < 2:
            return 0.0
        return calinski_harabasz_score(X, labels)

class ClusteringModel(BaseEstimator, ClusterMixin):
    """
    Unified interface for clustering algorithms.
    
    This class provides a consistent API for various clustering
    methods with automatic preprocessing and validation.
    
    Example:
        >>> clusterer = ClusteringModel(
        ...     method='kmeans',
        ...     n_clusters=5,
        ...     scale_data=True
        ... )
        >>> labels = clusterer.fit_predict(X)
        >>> clusterer.evaluate(X)
    """
    
    def __init__(
        self,
        method: str = 'kmeans',
        n_clusters: Optional[int] = None,
        scale_data: bool = True,
        random_state: int = 42,
        **kwargs
    ):
        """
        Initialize the clustering model.
        
        Args:
            method: Clustering method ('kmeans', 'dbscan', 'hierarchical', 'gmm', 'spectral', 'birch')
            n_clusters: Number of clusters (required for some methods)
            scale_data: Whether to scale the data before clustering
            random_state: Random seed
            **kwargs: Method-specific parameters
        """
        self.method = method
        self.n_clusters = n_clusters
        self.scale_data = scale_data
        self.random_state = random_state
        self.kwargs = kwargs
        
        self._model = None
        self._scaler = None
        self._feature_names = None
        self._is_fitted = False
        self._labels = None
        self._cluster_centers = None
        
        logger.info(f"ClusteringModel initialized with method={method}")
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> 'ClusteringModel':
        """
        Fit the clustering model.
        
        Args:
            X: Feature matrix
            y: Ignored
            
        Returns:
            ClusteringModel: Fitted model
        """
        X = self._prepare_data(X)
        
        # Store feature names
        if hasattr(X, 'columns'):
            self._feature_names = X.columns.tolist()
        else:
            self._feature_names = [f'feature_{i}' for i in range(X.shape[1])]
        
        # Scale data if requested
        if self.scale_data:
            self._scaler = StandardScaler()
            X_scaled = self._scaler.fit_transform(X)
        else:
            X_scaled = X
        
        # Create and fit the model
        self._model = self._create_model(X_scaled)
        self._model.fit(X_scaled)
        self._is_fitted = True
        
        # Store labels and cluster centers
        self._labels = self._model.labels_
        if hasattr(self._model, 'cluster_centers_'):
            self._cluster_centers = self._model.cluster_centers_
            
            # Inverse transform centers if scaled
            if self.scale_data and self._scaler is not None:
                self._cluster_centers = self._scaler.inverse_transform(self._cluster_centers)
        
        logger.info(f"Clustering complete. Found {self.n_clusters_} clusters")
        return self
    
    def predict(self, X: Union[pd.DataFrame, np.ndarray]) -> np.ndarray:
        """
        Predict cluster labels for new data.
        
        Args:
            X: Feature matrix
            
        Returns:
            np.ndarray: Cluster labels
        """
        if not self._is_fitted:
            raise ValueError("Model has not been fitted yet. Call fit() first.")
        
        X = self._prepare_data(X)
        
        # Scale data
        if self.scale_data and self._scaler is not None:
            X_scaled = self._scaler.transform(X)
        else:
            X_scaled = X
        
        # Predict
        if hasattr(self._model, 'predict'):
            return self._model.predict(X_scaled)
        else:
            # For models without predict (like DBSCAN), use fit_predict on combined data
            # This is a simplification - in practice, you'd need to handle this differently
            combined = np.vstack([self._model.components_.reshape(-1, X_scaled.shape[1]), X_scaled])
            # This is not ideal; better to use a different approach for out-of-sample prediction
            logger.warning(f"{self.method} does not support predict(). Using nearest centroid.")
            # Fallback: use nearest centroid
            if hasattr(self._model, 'cluster_centers_'):
                centers = self._model.cluster_centers_
                distances = np.linalg.norm(X_scaled[:, np.newaxis, :] - centers[np.newaxis, :, :], axis=2)
                return np.argmin(distances, axis=1)
            else:
                raise ValueError(f"{self.method} does not support prediction")
    
    def fit_predict(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> np.ndarray:
        """
        Fit and predict cluster labels in one step.
        """
        self.fit(X)
        return self._labels
    
    def _create_model(self, X: np.ndarray):
        """Create the appropriate clustering model."""
        
        # Determine n_clusters if not provided
        if self.n_clusters is None:
            if self.method in [ClusteringMethod.KMEANS, ClusteringMethod.GMM, 
                             ClusteringMethod.SPECTRAL, ClusteringMethod.BIRCH]:
                # Use heuristic: sqrt(n_samples/2) for small datasets
                n_samples = X.shape[0]
                self.n_clusters = int(np.sqrt(n_samples / 2))
                if self.n_clusters < 2:
                    self.n_clusters = 2
                logger.info(f"Auto-selected n_clusters={self.n_clusters}")
        
        if self.method == ClusteringMethod.KMEANS:
            return KMeans(
                n_clusters=self.n_clusters or 8,
                random_state=self.random_state,
                n_init='auto',
                **self.kwargs
            )
        
        elif self.method == ClusteringMethod.DBSCAN:
            # Auto-determine eps if not provided
            eps = self.kwargs.get('eps', None)
            if eps is None:
                # Use heuristic: based on nearest neighbor distances
                from sklearn.neighbors import NearestNeighbors
                nn = NearestNeighbors(n_neighbors=min(5, X.shape[0]))
                nn.fit(X)
                distances, _ = nn.kneighbors(X)
                # Use average of 4th nearest neighbor distances
                eps = np.percentile(distances[:, -1], 90)
                self.kwargs['eps'] = eps
                logger.info(f"Auto-selected eps={eps:.3f}")
            
            return DBSCAN(**self.kwargs)
        
        elif self.method == ClusteringMethod.HIERARCHICAL:
            return AgglomerativeClustering(
                n_clusters=self.n_clusters or None,
                **self.kwargs
            )
        
        elif self.method == ClusteringMethod.GMM:
            return GaussianMixture(
                n_components=self.n_clusters or 8,
                random_state=self.random_state,
                **self.kwargs
            )
        
        elif self.method == ClusteringMethod.SPECTRAL:
            return SpectralClustering(
                n_clusters=self.n_clusters or 8,
                random_state=self.random_state,
                **self.kwargs
            )
        
        elif self.method == ClusteringMethod.BIRCH:
            return Birch(
                n_clusters=self.n_clusters or None,
                **self.kwargs
            )
        
        else:
            raise ValueError(f"Unknown method: {self.method}")
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> np.ndarray:
        """Convert input to numpy array."""
        if isinstance(X, pd.DataFrame):
            return X.values
        return X
    
    @property
    def n_clusters_(self) -> int:
        """Get the number of clusters found."""
        if not self._is_fitted:
            return 0
        return len(np.unique(self._labels[self._labels >= 0]))
    
    def evaluate(self, X: Optional[Union[pd.DataFrame, np.ndarray]] = None) -> Dict[str, float]:
        """
        Evaluate clustering quality using multiple metrics.
        
        Args:
            X: Feature matrix (if None, uses training data)
            
        Returns:
            Dict: Validation metrics
        """
        if not self._is_fitted:
            raise ValueError("Model has not been fitted yet. Call fit() first.")
        
        if X is None:
            X = self._prepare_data(self._scaler.transform(self._data) if self.scale_data else self._data)
        else:
            X = self._prepare_data(X)
        
        labels = self._labels
        
        # Check if we have valid clusters
        if len(np.unique(labels)) < 2:
            return {
                'silhouette': 0.0,
                'davies_bouldin': float('inf'),
                'calinski_harabasz': 0.0,
                'n_clusters': 1,
                'n_noise': np.sum(labels == -1) if -1 in labels else 0
            }
        
        # Calculate metrics
        metrics = {
            'silhouette': ClusterValidator.silhouette(X, labels),
            'davies_bouldin': ClusterValidator.davies_bouldin(X, labels),
            'calinski_harabasz': ClusterValidator.calinski_harabasz(X, labels),
            'n_clusters': self.n_clusters_,
            'n_noise': np.sum(labels == -1) if -1 in labels else 0
        }
        
        logger.info(f"Evaluation: silhouette={metrics['silhouette']:.3f}")
        return metrics
    
    def get_cluster_profiles(self, X: pd.DataFrame) -> pd.DataFrame:
        """
        Create profiles for each cluster.
        
        Args:
            X: Original feature matrix
            
        Returns:
            pd.DataFrame: Cluster profiles
        """
        if not self._is_fitted:
            raise ValueError("Model has not been fitted yet. Call fit() first.")
        
        X = self._prepare_data(X)
        if isinstance(X, pd.DataFrame):
            X = X.values
        
        # Get cluster labels
        labels = self._labels
        if labels is None:
            raise ValueError("No labels found. Fit the model first.")
        
        # Create profile for each cluster
        profiles = []
        unique_labels = np.unique(labels[labels >= 0])
        
        for cluster_id in unique_labels:
            mask = labels == cluster_id
            cluster_data = X[mask]
            
            if len(cluster_data) == 0:
                continue
            
            profile = {
                'cluster': cluster_id,
                'size': len(cluster_data),
                'percentage': (len(cluster_data) / len(X)) * 100
            }
            
            # Add statistics for each feature
            for i in range(X.shape[1]):
                feature_name = self._feature_names[i] if self._feature_names else f'feature_{i}'
                profile[f'{feature_name}_mean'] = np.mean(cluster_data[:, i])
                profile[f'{feature_name}_std'] = np.std(cluster_data[:, i])
            
            profiles.append(profile)
        
        return pd.DataFrame(profiles)
    
    def plot_clusters(
        self,
        X: Optional[Union[pd.DataFrame, np.ndarray]] = None,
        method: str = 'pca',
        figsize: Tuple[int, int] = (10, 8),
        save_path: Optional[str] = None
    ):
        """
        Plot clusters in 2D using dimensionality reduction.
        
        Args:
            X: Feature matrix (if None, uses training data)
            method: Dimensionality reduction method ('pca' or 'tsne')
            figsize: Figure size
            save_path: Path to save the figure
            
        Returns:
            matplotlib.figure.Figure: The created figure
        """
        import matplotlib.pyplot as plt
        
        if not self._is_fitted:
            raise ValueError("Model has not been fitted yet. Call fit() first.")
        
        # Prepare data
        if X is None:
            X = self._prepare_data(self._data)
        else:
            X = self._prepare_data(X)
        
        # Reduce dimensionality for visualization
        if method == 'pca':
            reducer = PCA(n_components=2, random_state=self.random_state)
            X_reduced = reducer.fit_transform(X)
            explained_var = reducer.explained_variance_ratio_
            xlabel = f'PC1 ({explained_var[0]:.1%} variance)'
            ylabel = f'PC2 ({explained_var[1]:.1%} variance)'
        elif method == 'tsne':
            from sklearn.manifold import TSNE
            # Use subset if data is large
            n_samples = X.shape[0]
            if n_samples > 1000:
                idx = np.random.choice(n_samples, 1000, replace=False)
                X_subset = X[idx]
                labels_subset = self._labels[idx]
            else:
                X_subset = X
                labels_subset = self._labels
            
            tsne = TSNE(n_components=2, random_state=self.random_state, perplexity=min(30, n_samples-1))
            X_reduced = tsne.fit_transform(X_subset)
            xlabel = 't-SNE 1'
            ylabel = 't-SNE 2'
        else:
            raise ValueError(f"Unknown method: {method}")
        
        # Create plot
        fig, ax = plt.subplots(figsize=figsize)
        
        # Get unique labels
        labels = self._labels if X is None else labels_subset
        unique_labels = np.unique(labels[labels >= 0])
        n_clusters = len(unique_labels)
        
        # Use colormap
        colors = plt.cm.viridis(np.linspace(0, 1, max(n_clusters, 1)))
        
        # Plot each cluster
        for i, cluster_id in enumerate(unique_labels):
            mask = labels == cluster_id
            color = colors[i % len(colors)]
            ax.scatter(
                X_reduced[mask, 0],
                X_reduced[mask, 1],
                c=[color],
                label=f'Cluster {cluster_id}',
                alpha=0.6,
                s=20
            )
        
        # Plot noise points (if any)
        if -1 in labels:
            mask = labels == -1
            ax.scatter(
                X_reduced[mask, 0],
                X_reduced[mask, 1],
                c='gray',
                label='Noise',
                alpha=0.4,
                s=10
            )
        
        ax.set_xlabel(xlabel)
        ax.set_ylabel(ylabel)
        ax.set_title(f'Clustering Results ({self.method.upper()})')
        ax.legend()
        ax.grid(True, alpha=0.3)
        
        plt.tight_layout()
        
        if save_path:
            fig.savefig(save_path, dpi=100, bbox_inches='tight')
            logger.info(f"Cluster plot saved to: {save_path}")
        
        return fig

class OptimalKSelector:
    """
    Automatically select optimal number of clusters for K-Means.
    
    Uses multiple methods:
    - Elbow method (inertia)
    - Silhouette score
    - Gap statistic
    """
    
    def __init__(
        self,
        max_k: int = 10,
        min_k: int = 2,
        random_state: int = 42
    ):
        """
        Initialize the K selector.
        
        Args:
            max_k: Maximum number of clusters to try
            min_k: Minimum number of clusters to try
            random_state: Random seed
        """
        self.max_k = max_k
        self.min_k = min_k
        self.random_state = random_state
        
        self._results = None
        self._optimal_k = None
    
    def select(self, X: Union[pd.DataFrame, np.ndarray]) -> int:
        """
        Select optimal number of clusters.
        
        Args:
            X: Feature matrix
            
        Returns:
            int: Optimal number of clusters
        """
        X = self._prepare_data(X)
        
        # Scale data
        scaler = StandardScaler()
        X_scaled = scaler.fit_transform(X)
        
        results = {
            'k': [],
            'inertia': [],
            'silhouette': [],
            'gap': []
        }
        
        # Calculate for each K
        for k in range(self.min_k, min(self.max_k + 1, X_scaled.shape[0])):
            kmeans = KMeans(n_clusters=k, random_state=self.random_state, n_init=10)
            kmeans.fit(X_scaled)
            labels = kmeans.labels_
            
            results['k'].append(k)
            results['inertia'].append(kmeans.inertia_)
            
            # Silhouette score
            if len(np.unique(labels)) >= 2:
                silhouette = silhouette_score(X_scaled, labels)
            else:
                silhouette = 0
            results['silhouette'].append(silhouette)
            
            # Gap statistic (simplified)
            # Calculate within-cluster dispersion
            if len(np.unique(labels)) >= 2:
                # Compute gap using reference distribution
                gap = self._compute_gap_statistic(X_scaled, k)
            else:
                gap = 0
            results['gap'].append(gap)
        
        self._results = pd.DataFrame(results)
        
        # Find optimal K using multiple methods
        # Method 1: Elbow (find where inertia decrease starts to flatten)
        if len(results['k']) >= 3:
            # Calculate elbow using second derivative
            diff1 = np.diff(results['inertia'])
            diff2 = np.diff(diff1)
            elbow_idx = np.argmax(diff2) + 1
            k_elbow = results['k'][elbow_idx] if elbow_idx < len(results['k']) else results['k'][-1]
        else:
            k_elbow = results['k'][-1]
        
        # Method 2: Max silhouette
        k_silhouette = results['k'][np.argmax(results['silhouette'])]
        
        # Method 3: Max gap
        k_gap = results['k'][np.argmax(results['gap'])]
        
        # Combine methods (majority vote)
        k_candidates = [k_elbow, k_silhouette, k_gap]
        if len(set(k_candidates)) >= 2:
            # Find most common
            from collections import Counter
            self._optimal_k = Counter(k_candidates).most_common(1)[0][0]
        else:
            self._optimal_k = k_candidates[0]
        
        logger.info(f"Optimal K selected: {self._optimal_k} "
                   f"(elbow={k_elbow}, silhouette={k_silhouette}, gap={k_gap})")
        
        return self._optimal_k
    
    def _compute_gap_statistic(self, X: np.ndarray, k: int, n_refs: int = 5) -> float:
        """Compute gap statistic (simplified)."""
        # Reference distribution: uniform over range of each feature
        mins = X.min(axis=0)
        maxs = X.max(axis=0)
        
        # Compute dispersion for original data
        kmeans = KMeans(n_clusters=k, random_state=self.random_state, n_init=10)
        kmeans.fit(X)
        labels = kmeans.labels_
        
        # Within-cluster dispersion (log)
        dispersion_original = np.sum([
            np.sum((X[labels == cluster] - kmeans.cluster_centers_[cluster]) ** 2)
            for cluster in range(k)
        ])
        log_dispersion_original = np.log(dispersion_original + 1e-10)
        
        # Compute dispersion for reference distributions
        log_dispersion_ref = []
        for _ in range(n_refs):
            X_ref = np.random.uniform(mins, maxs, X.shape)
            kmeans_ref = KMeans(n_clusters=k, random_state=self.random_state, n_init=10)
            kmeans_ref.fit(X_ref)
            labels_ref = kmeans_ref.labels_
            
            dispersion_ref = np.sum([
                np.sum((X_ref[labels_ref == cluster] - kmeans_ref.cluster_centers_[cluster]) ** 2)
                for cluster in range(k)
            ])
            log_dispersion_ref.append(np.log(dispersion_ref + 1e-10))
        
        gap = np.mean(log_dispersion_ref) - log_dispersion_original
        
        return gap
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> np.ndarray:
        """Convert input to numpy array."""
        if isinstance(X, pd.DataFrame):
            return X.values
        return X
    
    def get_results(self) -> pd.DataFrame:
        """Get detailed results for each K."""
        if self._results is None:
            raise ValueError("No results available. Call select() first.")
        return self._results
    
    def plot_results(self, figsize: Tuple[int, int] = (12, 4)):
        """
        Plot selection metrics.
        
        Args:
            figsize: Figure size
            
        Returns:
            matplotlib.figure.Figure: The created figure
        """
        import matplotlib.pyplot as plt
        
        if self._results is None:
            raise ValueError("No results available. Call select() first.")
        
        fig, axes = plt.subplots(1, 3, figsize=figsize)
        
        # Inertia
        axes[0].plot(self._results['k'], self._results['inertia'], 'bo-')
        axes[0].axvline(self._optimal_k, color='red', linestyle='--', label=f'Optimal K={self._optimal_k}')
        axes[0].set_xlabel('Number of Clusters (K)')
        axes[0].set_ylabel('Inertia')
        axes[0].set_title('Elbow Method')
        axes[0].grid(True, alpha=0.3)
        axes[0].legend()
        
        # Silhouette
        axes[1].plot(self._results['k'], self._results['silhouette'], 'go-')
        axes[1].axvline(self._optimal_k, color='red', linestyle='--', label=f'Optimal K={self._optimal_k}')
        axes[1].set_xlabel('Number of Clusters (K)')
        axes[1].set_ylabel('Silhouette Score')
        axes[1].set_title('Silhouette Score')
        axes[1].grid(True, alpha=0.3)
        axes[1].legend()
        
        # Gap statistic
        axes[2].plot(self._results['k'], self._results['gap'], 'ro-')
        axes[2].axvline(self._optimal_k, color='red', linestyle='--', label=f'Optimal K={self._optimal_k}')
        axes[2].set_xlabel('Number of Clusters (K)')
        axes[2].set_ylabel('Gap Statistic')
        axes[2].set_title('Gap Statistic')
        axes[2].grid(True, alpha=0.3)
        axes[2].legend()
        
        plt.tight_layout()
        return fig
```

#### Step 2: Hierarchical Clustering with Dendrogram

**File:** `src/models/hierarchical.py`
**Path:** `ml-pipeline-project/src/models/hierarchical.py`

```python
"""
Hierarchical clustering with dendrogram visualization.
"""

from typing import Dict, List, Optional, Union, Any, Tuple
import numpy as np
import pandas as pd
from loguru import logger
from scipy.cluster.hierarchy import dendrogram, linkage, fcluster
from scipy.spatial.distance import pdist
from sklearn.cluster import AgglomerativeClustering
import matplotlib.pyplot as plt

class HierarchicalClustering:
    """
    Hierarchical clustering with comprehensive visualization.
    
    This class provides hierarchical clustering with:
    - Multiple linkage methods
    - Dendrogram visualization
    - Cluster extraction at different distances
    - Cluster profiling
    
    Example:
        >>> hc = HierarchicalClustering(method='ward')
        >>> labels = hc.fit_predict(X, n_clusters=5)
        >>> hc.plot_dendrogram()
    """
    
    def __init__(
        self,
        method: str = 'ward',
        metric: str = 'euclidean',
        **kwargs
    ):
        """
        Initialize hierarchical clustering.
        
        Args:
            method: Linkage method ('ward', 'complete', 'average', 'single')
            metric: Distance metric ('euclidean', 'manhattan', 'cosine', etc.)
            **kwargs: Additional arguments
        """
        self.method = method
        self.metric = metric
        self.kwargs = kwargs
        
        self._linkage_matrix = None
        self._labels = None
        self._data = None
        
        logger.info(f"HierarchicalClustering initialized with method={method}")
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray]) -> 'HierarchicalClustering':
        """
        Fit the hierarchical clustering.
        
        Args:
            X: Feature matrix
            
        Returns:
            HierarchicalClustering: Fitted model
        """
        X = self._prepare_data(X)
        self._data = X
        
        # Compute linkage matrix
        self._linkage_matrix = linkage(
            X,
            method=self.method,
            metric=self.metric,
            **self.kwargs
        )
        
        logger.info(f"Hierarchical clustering fitted with {X.shape[0]} samples")
        return self
    
    def fit_predict(
        self,
        X: Union[pd.DataFrame, np.ndarray],
        n_clusters: Optional[int] = None,
        distance_threshold: Optional[float] = None
    ) -> np.ndarray:
        """
        Fit and predict cluster labels.
        
        Args:
            X: Feature matrix
            n_clusters: Number of clusters
            distance_threshold: Distance threshold for cutting the dendrogram
            
        Returns:
            np.ndarray: Cluster labels
        """
        self.fit(X)
        
        if n_clusters is not None:
            self._labels = fcluster(self._linkage_matrix, n_clusters, criterion='maxclust')
        elif distance_threshold is not None:
            self._labels = fcluster(self._linkage_matrix, distance_threshold, criterion='distance')
        else:
            # Default: use 10% of max distance
            max_dist = self._linkage_matrix[-1, 2]
            threshold = max_dist * 0.7
            self._labels = fcluster(self._linkage_matrix, threshold, criterion='distance')
            logger.info(f"Auto-selected distance threshold: {threshold:.3f}")
        
        return self._labels
    
    def get_labels_at_distance(self, distance_threshold: float) -> np.ndarray:
        """
        Get cluster labels at a specific distance threshold.
        
        Args:
            distance_threshold: Distance threshold
            
        Returns:
            np.ndarray: Cluster labels
        """
        if self._linkage_matrix is None:
            raise ValueError("Model has not been fitted yet. Call fit() first.")
        
        return fcluster(self._linkage_matrix, distance_threshold, criterion='distance')
    
    def get_labels_at_k(self, n_clusters: int) -> np.ndarray:
        """
        Get cluster labels at a specific K.
        
        Args:
            n_clusters: Number of clusters
            
        Returns:
            np.ndarray: Cluster labels
        """
        if self._linkage_matrix is None:
            raise ValueError("Model has not been fitted yet. Call fit() first.")
        
        return fcluster(self._linkage_matrix, n_clusters, criterion='maxclust')
    
    def plot_dendrogram(
        self,
        max_d: Optional[float] = None,
        figsize: Tuple[int, int] = (12, 8),
        save_path: Optional[str] = None
    ):
        """
        Plot the dendrogram.
        
        Args:
            max_d: Maximum distance to show
            figsize: Figure size
            save_path: Path to save the figure
            
        Returns:
            matplotlib.figure.Figure: The created figure
        """
        if self._linkage_matrix is None:
            raise ValueError("Model has not been fitted yet. Call fit() first.")
        
        fig, ax = plt.subplots(figsize=figsize)
        
        # Plot dendrogram
        dendrogram(
            self._linkage_matrix,
            ax=ax,
            color_threshold=max_d if max_d else None,
            above_threshold_color='gray'
        )
        
        ax.set_xlabel('Sample Index')
        ax.set_ylabel('Distance')
        ax.set_title(f'Dendrogram ({self.method} linkage)')
        ax.grid(True, alpha=0.3)
        
        # Add horizontal line for threshold
        if max_d:
            ax.axhline(y=max_d, color='red', linestyle='--', label=f'Threshold: {max_d:.2f}')
            ax.legend()
        
        plt.tight_layout()
        
        if save_path:
            fig.savefig(save_path, dpi=100, bbox_inches='tight')
            logger.info(f"Dendrogram saved to: {save_path}")
        
        return fig
    
    def get_cluster_hierarchy(self) -> pd.DataFrame:
        """
        Get the cluster hierarchy as a DataFrame.
        
        Returns:
            pd.DataFrame: Hierarchy information
        """
        if self._linkage_matrix is None:
            raise ValueError("Model has not been fitted yet. Call fit() first.")
        
        # Create DataFrame from linkage matrix
        df = pd.DataFrame(
            self._linkage_matrix,
            columns=['cluster1', 'cluster2', 'distance', 'size']
        )
        df['cluster1'] = df['cluster1'].astype(int)
        df['cluster2'] = df['cluster2'].astype(int)
        
        return df
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> np.ndarray:
        """Convert input to numpy array."""
        if isinstance(X, pd.DataFrame):
            return X.values
        return X
```

### The Verification: Testing Our Unsupervised Learning System

#### Test 1: Basic Clustering

```bash
cat > test_clustering.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_blobs
from src.models.clustering import ClusteringModel, OptimalKSelector

# Create dataset with natural clusters
X, y_true = make_blobs(
    n_samples=500,
    n_features=2,
    centers=4,
    cluster_std=0.8,
    random_state=42
)

X = pd.DataFrame(X, columns=['feature_1', 'feature_2'])

print("Dataset shape:", X.shape)
print("True clusters:", len(np.unique(y_true)))

# Test K-Means
print("\n" + "="*60)
print("Test 1: K-Means Clustering")
print("="*60)

kmeans = ClusteringModel(method='kmeans', n_clusters=4)
labels = kmeans.fit_predict(X)
print(f"Found clusters: {kmeans.n_clusters_}")
print(f"Cluster sizes: {pd.Series(labels).value_counts().to_dict()}")

# Evaluate
metrics = kmeans.evaluate(X)
print(f"\nMetrics:")
for key, value in metrics.items():
    print(f"  {key}: {value:.4f}" if isinstance(value, float) else f"  {key}: {value}")

# Test DBSCAN
print("\n" + "="*60)
print("Test 2: DBSCAN")
print("="*60)

dbscan = ClusteringModel(method='dbscan')
labels = dbscan.fit_predict(X)
print(f"Found clusters: {dbscan.n_clusters_}")
print(f"Cluster sizes: {pd.Series(labels).value_counts().to_dict()}")

# Test Hierarchical
print("\n" + "="*60)
print("Test 3: Hierarchical Clustering")
print("="*60)

hier = ClusteringModel(method='hierarchical', n_clusters=4)
labels = hier.fit_predict(X)
print(f"Found clusters: {hier.n_clusters_}")
print(f"Cluster sizes: {pd.Series(labels).value_counts().to_dict()}")

# Optimal K selection
print("\n" + "="*60)
print("Test 4: Optimal K Selection")
print("="*60)

k_selector = OptimalKSelector(max_k=10)
optimal_k = k_selector.select(X)
print(f"Optimal K: {optimal_k}")

# Show results
results_df = k_selector.get_results()
print("\nResults:")
print(results_df.to_string())

# Plot results
fig = k_selector.plot_results()
fig.savefig('reports/figures/optimal_k_selection.png', dpi=100, bbox_inches='tight')
print("\nOptimal K plot saved to: reports/figures/optimal_k_selection.png")

# Plot clusters
fig = kmeans.plot_clusters(method='pca')
fig.savefig('reports/figures/clusters_pca.png', dpi=100, bbox_inches='tight')
print("Cluster plot saved to: reports/figures/clusters_pca.png")

print("\n✅ Clustering test complete!")
EOF

python test_clustering.py
```

#### Test 2: Hierarchical Clustering

```bash
cat > test_hierarchical.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_blobs
from src.models.hierarchical import HierarchicalClustering

# Create dataset
X, y_true = make_blobs(
    n_samples=200,
    n_features=2,
    centers=4,
    cluster_std=0.8,
    random_state=42
)

X = pd.DataFrame(X, columns=['feature_1', 'feature_2'])

print("Dataset shape:", X.shape)

# Test hierarchical clustering
print("\n" + "="*60)
print("Hierarchical Clustering")
print("="*60)

hc = HierarchicalClustering(method='ward')

# Fit with different K
for k in [3, 4, 5]:
    labels = hc.fit_predict(X, n_clusters=k)
    print(f"K={k}: {len(np.unique(labels))} clusters, sizes: {pd.Series(labels).value_counts().to_dict()}")

# Plot dendrogram
fig = hc.plot_dendrogram(max_d=15)
fig.savefig('reports/figures/dendrogram.png', dpi=100, bbox_inches='tight')
print("\nDendrogram saved to: reports/figures/dendrogram.png")

# Get cluster hierarchy
hierarchy = hc.get_cluster_hierarchy()
print("\nCluster hierarchy:")
print(hierarchy.head())

# Get labels at different thresholds
print("\nLabels at different thresholds:")
for threshold in [5, 8, 12]:
    labels = hc.get_labels_at_distance(threshold)
    n_clusters = len(np.unique(labels))
    print(f"  Threshold={threshold}: {n_clusters} clusters")

print("\n✅ Hierarchical clustering test complete!")
EOF

python test_hierarchical.py
```

#### Test 3: Real-World Dataset with Evaluation

```bash
cat > test_clustering_evaluation.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import load_wine
from sklearn.preprocessing import StandardScaler
from src.models.clustering import ClusteringModel, OptimalKSelector

# Load wine dataset
wine = load_wine()
X = pd.DataFrame(wine.data, columns=wine.feature_names)
y_true = wine.target

print("Wine dataset:")
print(f"Shape: {X.shape}")
print(f"True classes: {len(np.unique(y_true))}")
print(f"Features: {X.columns.tolist()}")

# Scale data
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)
X_scaled = pd.DataFrame(X_scaled, columns=X.columns)

# Find optimal K
print("\n" + "="*60)
print("Finding Optimal K")
print("="*60)

k_selector = OptimalKSelector(max_k=8)
optimal_k = k_selector.select(X_scaled)
print(f"Optimal K: {optimal_k}")

# Plot K selection
fig = k_selector.plot_results()
fig.savefig('reports/figures/wine_optimal_k.png', dpi=100, bbox_inches='tight')

# K-Means with optimal K
print("\n" + "="*60)
print("K-Means Clustering")
print("="*60)

kmeans = ClusteringModel(method='kmeans', n_clusters=optimal_k)
labels = kmeans.fit_predict(X_scaled)

print(f"Clusters found: {kmeans.n_clusters_}")
print(f"Cluster sizes: {pd.Series(labels).value_counts().to_dict()}")

# Evaluate
metrics = kmeans.evaluate(X_scaled)
print(f"\nMetrics:")
for key, value in metrics.items():
    print(f"  {key}: {value:.4f}" if isinstance(value, float) else f"  {key}: {value}")

# Compare with true labels
from sklearn.metrics import adjusted_rand_score, normalized_mutual_info_score
ari = adjusted_rand_score(y_true, labels)
nmi = normalized_mutual_info_score(y_true, labels)

print(f"\nComparison with true classes:")
print(f"  Adjusted Rand Index: {ari:.4f}")
print(f"  Normalized Mutual Info: {nmi:.4f}")

# Cluster profiles
profiles = kmeans.get_cluster_profiles(X_scaled)
print(f"\nCluster profiles (first 5 features):")
profile_cols = ['cluster', 'size', 'percentage'] + [col for col in profiles.columns if col.endswith('_mean')][:5]
print(profiles[profile_cols].to_string())

# Try different methods
print("\n" + "="*60)
print("Method Comparison")
print("="*60)

methods = ['kmeans', 'dbscan', 'hierarchical', 'gmm']
results = []

for method in methods:
    try:
        if method == 'dbscan':
            clusterer = ClusteringModel(method=method)
        else:
            clusterer = ClusteringModel(method=method, n_clusters=optimal_k)
        
        labels = clusterer.fit_predict(X_scaled)
        n_clusters = len(np.unique(labels[labels >= 0]))
        
        # Metrics
        if n_clusters >= 2:
            silhouette = clusterer.evaluate(X_scaled)['silhouette']
        else:
            silhouette = 0.0
        
        results.append({
            'method': method,
            'n_clusters': n_clusters,
            'silhouette': silhouette,
            'ari': adjusted_rand_score(y_true, labels) if n_clusters >= 2 else 0,
            'nmi': normalized_mutual_info_score(y_true, labels) if n_clusters >= 2 else 0
        })
        
        print(f"{method}: {n_clusters} clusters, silhouette={silhouette:.3f}")
    except Exception as e:
        print(f"{method}: Error - {str(e)}")

# Create comparison DataFrame
results_df = pd.DataFrame(results)
print("\nComparison Results:")
print(results_df.to_string())

# Plot clusters
fig = kmeans.plot_clusters(method='pca')
fig.savefig('reports/figures/wine_clusters.png', dpi=100, bbox_inches='tight')
print("\nCluster plot saved to: reports/figures/wine_clusters.png")

print("\n✅ Clustering evaluation test complete!")
EOF

python test_clustering_evaluation.py
```

### What Just Happened: Understanding Clustering

#### K-Means Clustering

**The Algorithm**:
1. Initialize K cluster centers randomly
2. Assign each point to the nearest center
3. Recompute centers as the mean of assigned points
4. Repeat steps 2-3 until convergence

**Pros**: Fast, simple, scalable
**Cons**: Assumes spherical clusters, sensitive to initialization, requires K

**When to use**: Large datasets, spherical clusters, clear separation

#### DBSCAN (Density-Based Spatial Clustering)

**The Algorithm**:
1. For each point, find points within distance ε
2. If a point has min_samples neighbors, it's a core point
3. Core points form clusters with their neighbors
4. Non-core points are outliers (noise)

**Pros**: Finds arbitrary shapes, handles outliers, no K required
**Cons**: Sensitive to parameters, varying densities challenging

**When to use**: Non-spherical clusters, outlier detection, unknown number of clusters

#### Hierarchical Clustering

**The Algorithm**:
1. Start with each point as its own cluster
2. Find the two closest clusters and merge them
3. Repeat until all points are in one cluster
4. Cut the dendrogram at a chosen distance

**Pros**: Creates hierarchy, visual dendrogram, no K required
**Cons**: O(n²) complexity, sensitive to noise

**When to use**: Small to medium datasets, wanting to see hierarchical structure

#### Gaussian Mixture Models (GMM)

**The Algorithm**:
1. Assume data comes from K Gaussian distributions
2. Expectation-Maximization (EM) algorithm:
   - E-step: Assign points to clusters probabilistically
   - M-step: Update Gaussian parameters

**Pros**: Probabilistic, soft assignments, handles ellipsoidal clusters
**Cons**: Assumes Gaussian distributions, can converge to local optima

**When to use**: When cluster boundaries are fuzzy, wanting probability of membership

### Summary

In this part, we've built a comprehensive unsupervised learning system that:

1. **Provides a unified interface** for K-Means, DBSCAN, Hierarchical, GMM, and Spectral clustering
2. **Automatically selects** optimal K using elbow, silhouette, and gap statistic
3. **Evaluates clustering** with silhouette, Davies-Bouldin, and Calinski-Harabasz
4. **Creates cluster profiles** for interpretation
5. **Visualizes** clusters and dendrograms
6. **Handles hierarchical clustering** with comprehensive dendrogram tools

### What's Next

In Part 10, we'll explore deep learning fundamentals with PyTorch, building our first neural networks from scratch.

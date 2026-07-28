# Primer 24: Recommendation Systems

## Overview

This primer provides a comprehensive introduction to recommendation systems—the engines that power personalized experiences in e-commerce, streaming, social media, and more. Understanding recommendation systems is essential for building products that engage users and drive business value.

---

## 1. Introduction to Recommendation Systems

### Why Recommendation Systems Matter

```
┌─────────────────────────────────────────────────────────────────┐
│              WHY RECOMMENDATION SYSTEMS MATTER                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Business Impact                                                │
│  └── ~35% of Amazon purchases come from recommendations        │
│  └── ~75% of Netflix content watched from recommendations     │
│  └── ~60% of YouTube views come from recommendations           │
│                                                                 │
│  User Experience                                                │
│  └── Personalization improves engagement                       │
│  └── Discovery of new content                                  │
│  └── Reduced choice overload                                   │
│                                                                 │
│  Types of Recommendation Systems                               │
│  └── Collaborative Filtering: User-item interactions           │
│  └── Content-Based: Item features                              │
│  └── Hybrid: Combination of methods                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Recommendation System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│              RECOMMENDATION SYSTEM ARCHITECTURE                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Data Sources                                                   │
│  └── User interactions (clicks, purchases, ratings)            │
│  └── User profiles (demographics, preferences)                 │
│  └── Item metadata (descriptions, categories, features)        │
│                                                                 │
│  Candidate Generation                                           │
│  └── Collaborative filtering                                    │
│  └── Content-based filtering                                    │
│  └── Popularity/trending                                        │
│                                                                 │
│  Ranking                                                        │
│  └── Machine learning models                                   │
│  └── Personalization                                            │
│  └── Context awareness                                          │
│                                                                 │
│  Filtering                                                      │
│  └── Deduplication                                              │
│  └── Diversity                                                  │
│  └── Freshness                                                  │
│                                                                 │
│  Output                                                         │
│  └── Personalized recommendations                               │
│  └── Explanations                                               │
│  └── Business metrics tracking                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Collaborative Filtering

### User-Based Collaborative Filtering

```python
import numpy as np
import pandas as pd
from scipy.spatial.distance import cosine
from sklearn.metrics.pairwise import cosine_similarity

class UserBasedCF:
    """
    User-based collaborative filtering.
    """
    
    def __init__(self, similarity='cosine', k=10):
        self.similarity = similarity
        self.k = k
        self.user_similarity = None
        self.item_similarity = None
        self.user_item_matrix = None
    
    def fit(self, user_item_matrix):
        """
        Fit the model.
        
        Args:
            user_item_matrix: User-item interactions (users x items)
        """
        self.user_item_matrix = user_item_matrix.values if hasattr(user_item_matrix, 'values') else user_item_matrix
        
        # Compute user similarity
        if self.similarity == 'cosine':
            self.user_similarity = cosine_similarity(self.user_item_matrix)
        elif self.similarity == 'pearson':
            # Pearson correlation
            self.user_similarity = np.corrcoef(self.user_item_matrix)
        
        return self
    
    def predict(self, user_id, item_id):
        """
        Predict rating for a user-item pair.
        
        Args:
            user_id: User index
            item_id: Item index
        
        Returns:
            float: Predicted rating
        """
        # Get similar users
        similar_users = self.user_similarity[user_id].copy()
        
        # Get users who rated this item
        rated_mask = self.user_item_matrix[:, item_id] != 0
        
        # Set similarity for users who haven't rated to 0
        similar_users[~rated_mask] = 0
        
        # Get top k similar users
        top_k_indices = np.argsort(similar_users)[-self.k:][::-1]
        
        # Remove self
        top_k_indices = top_k_indices[top_k_indices != user_id]
        
        if len(top_k_indices) == 0:
            # No similar users, return global mean
            return np.mean(self.user_item_matrix[:, item_id][self.user_item_matrix[:, item_id] != 0])
        
        # Weighted average
        numerator = np.sum(
            self.user_similarity[user_id][top_k_indices] * 
            self.user_item_matrix[top_k_indices, item_id]
        )
        denominator = np.sum(np.abs(self.user_similarity[user_id][top_k_indices]))
        
        if denominator == 0:
            return np.mean(self.user_item_matrix[:, item_id][self.user_item_matrix[:, item_id] != 0])
        
        return numerator / denominator
    
    def recommend(self, user_id, n=10, exclude_rated=True):
        """
        Recommend items for a user.
        
        Args:
            user_id: User index
            n: Number of recommendations
            exclude_rated: Whether to exclude already rated items
        
        Returns:
            list: Top n recommended items
        """
        # Get all items
        items = np.arange(self.user_item_matrix.shape[1])
        
        # Get already rated items
        rated_items = np.where(self.user_item_matrix[user_id] != 0)[0] if exclude_rated else []
        
        # Predict ratings for all items
        predictions = []
        for item in items:
            if item in rated_items:
                continue
            predictions.append((item, self.predict(user_id, item)))
        
        # Sort by predicted rating
        predictions.sort(key=lambda x: x[1], reverse=True)
        
        return predictions[:n]

# Example usage
# ratings = pd.DataFrame(...)  # user-item matrix
# cf = UserBasedCF()
# cf.fit(ratings)
# recommendations = cf.recommend(user_id=0, n=10)
```

### Item-Based Collaborative Filtering

```python
class ItemBasedCF:
    """
    Item-based collaborative filtering.
    """
    
    def __init__(self, similarity='cosine', k=10):
        self.similarity = similarity
        self.k = k
        self.item_similarity = None
        self.user_item_matrix = None
    
    def fit(self, user_item_matrix):
        """
        Fit the model.
        
        Args:
            user_item_matrix: User-item interactions (users x items)
        """
        self.user_item_matrix = user_item_matrix.values if hasattr(user_item_matrix, 'values') else user_item_matrix
        
        # Compute item similarity (transpose matrix)
        if self.similarity == 'cosine':
            self.item_similarity = cosine_similarity(self.user_item_matrix.T)
        elif self.similarity == 'pearson':
            self.item_similarity = np.corrcoef(self.user_item_matrix.T)
        
        return self
    
    def predict(self, user_id, item_id):
        """
        Predict rating for a user-item pair.
        
        Args:
            user_id: User index
            item_id: Item index
        
        Returns:
            float: Predicted rating
        """
        # Get items rated by user
        rated_items = np.where(self.user_item_matrix[user_id] != 0)[0]
        
        if len(rated_items) == 0:
            # No items rated, return global mean
            return np.mean(self.user_item_matrix[:, item_id][self.user_item_matrix[:, item_id] != 0])
        
        # Similarities with rated items
        similarities = self.item_similarity[item_id][rated_items]
        
        # Ratings for rated items
        ratings = self.user_item_matrix[user_id][rated_items]
        
        # Weighted average
        numerator = np.sum(similarities * ratings)
        denominator = np.sum(np.abs(similarities))
        
        if denominator == 0:
            return np.mean(ratings)
        
        return numerator / denominator
    
    def recommend(self, user_id, n=10, exclude_rated=True):
        """
        Recommend items for a user.
        
        Args:
            user_id: User index
            n: Number of recommendations
            exclude_rated: Whether to exclude already rated items
        
        Returns:
            list: Top n recommended items
        """
        items = np.arange(self.user_item_matrix.shape[1])
        rated_items = np.where(self.user_item_matrix[user_id] != 0)[0] if exclude_rated else []
        
        predictions = []
        for item in items:
            if item in rated_items:
                continue
            predictions.append((item, self.predict(user_id, item)))
        
        predictions.sort(key=lambda x: x[1], reverse=True)
        
        return predictions[:n]
```

### Matrix Factorization (SVD)

```python
from sklearn.decomposition import TruncatedSVD
from scipy.sparse.linalg import svds

class MatrixFactorization:
    """
    Matrix factorization using SVD.
    """
    
    def __init__(self, n_factors=50):
        self.n_factors = n_factors
        self.U = None
        self.Sigma = None
        self.Vt = None
        self.user_item_matrix = None
    
    def fit(self, user_item_matrix):
        """
        Fit the model using SVD.
        
        Args:
            user_item_matrix: User-item interactions (users x items)
        """
        self.user_item_matrix = user_item_matrix.values if hasattr(user_item_matrix, 'values') else user_item_matrix
        
        # Center data (mean imputation)
        self.global_mean = np.mean(self.user_item_matrix[self.user_item_matrix != 0])
        
        # Impute zeros with global mean for SVD
        matrix_imputed = self.user_item_matrix.copy()
        matrix_imputed[matrix_imputed == 0] = self.global_mean
        
        # Perform SVD
        U, sigma, Vt = svds(matrix_imputed, k=self.n_factors)
        self.U = U
        self.Sigma = np.diag(sigma)
        self.Vt = Vt
        
        return self
    
    def predict(self, user_id, item_id):
        """
        Predict rating for a user-item pair.
        
        Args:
            user_id: User index
            item_id: Item index
        
        Returns:
            float: Predicted rating
        """
        # Reconstruct matrix
        reconstructed = np.dot(self.U, np.dot(self.Sigma, self.Vt))
        
        # Clamp to valid range (assuming 1-5 ratings)
        prediction = reconstructed[user_id, item_id]
        prediction = max(1, min(5, prediction))
        
        return prediction
    
    def recommend(self, user_id, n=10, exclude_rated=True):
        """
        Recommend items for a user.
        
        Args:
            user_id: User index
            n: Number of recommendations
            exclude_rated: Whether to exclude already rated items
        
        Returns:
            list: Top n recommended items
        """
        # Reconstruct matrix
        reconstructed = np.dot(self.U, np.dot(self.Sigma, self.Vt))
        
        # Get predictions for user
        predictions = reconstructed[user_id]
        
        # Get already rated items
        rated_items = np.where(self.user_item_matrix[user_id] != 0)[0] if exclude_rated else []
        
        # Create list of (item, predicted_rating)
        recommendations = []
        for item, rating in enumerate(predictions):
            if item in rated_items:
                continue
            recommendations.append((item, rating))
        
        # Sort by rating descending
        recommendations.sort(key=lambda x: x[1], reverse=True)
        
        return recommendations[:n]
```

---

## 3. Content-Based Filtering

### Content-Based Recommender

```python
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

class ContentBasedRecommender:
    """
    Content-based recommendation system.
    """
    
    def __init__(self, text_columns=None, numeric_columns=None):
        self.text_columns = text_columns or []
        self.numeric_columns = numeric_columns or []
        self.item_features = None
        self.item_similarity = None
        self.item_ids = None
    
    def fit(self, items_df):
        """
        Fit the model.
        
        Args:
            items_df: DataFrame with item features
        """
        self.item_ids = items_df.index.tolist()
        
        # Process text features
        if self.text_columns:
            # Combine text columns
            texts = items_df[self.text_columns].fillna('').agg(' '.join, axis=1)
            
            # TF-IDF vectorization
            vectorizer = TfidfVectorizer(stop_words='english')
            text_features = vectorizer.fit_transform(texts)
            text_features = text_features.toarray()
        else:
            text_features = np.array([])
        
        # Process numeric features
        if self.numeric_columns:
            numeric_features = items_df[self.numeric_columns].fillna(0).values
        else:
            numeric_features = np.array([])
        
        # Combine features
        if len(text_features) > 0 and len(numeric_features) > 0:
            self.item_features = np.hstack([text_features, numeric_features])
        elif len(text_features) > 0:
            self.item_features = text_features
        elif len(numeric_features) > 0:
            self.item_features = numeric_features
        else:
            raise ValueError("No features provided")
        
        # Compute item similarity
        self.item_similarity = cosine_similarity(self.item_features)
        
        return self
    
    def recommend_similar_items(self, item_id, n=10):
        """
        Recommend similar items.
        
        Args:
            item_id: Item index
            n: Number of recommendations
        
        Returns:
            list: Top n similar items
        """
        if item_id not in self.item_ids:
            return []
        
        idx = self.item_ids.index(item_id)
        similarities = self.item_similarity[idx]
        
        # Get top n (excluding self)
        top_indices = np.argsort(similarities)[-n-1:-1][::-1]
        
        recommendations = []
        for i in top_indices:
            recommendations.append((self.item_ids[i], similarities[i]))
        
        return recommendations
    
    def recommend_for_user(self, user_items, n=10):
        """
        Recommend items for a user based on their interactions.
        
        Args:
            user_items: List of item IDs the user interacted with
            n: Number of recommendations
        
        Returns:
            list: Recommended items
        """
        if not user_items:
            return []
        
        # Get indices of user items
        user_indices = [self.item_ids.index(item) for item in user_items if item in self.item_ids]
        
        if not user_indices:
            return []
        
        # Aggregate similarities
        similarities = np.mean(self.item_similarity[user_indices], axis=0)
        
        # Sort by similarity
        top_indices = np.argsort(similarities)[-n-1:][::-1]
        
        recommendations = []
        for i in top_indices:
            item_id = self.item_ids[i]
            if item_id not in user_items:
                recommendations.append((item_id, similarities[i]))
        
        return recommendations
```

---

## 4. Hybrid Recommender Systems

### Hybrid Recommender

```python
class HybridRecommender:
    """
    Hybrid recommendation system combining collaborative and content-based.
    """
    
    def __init__(self, cf_model, cb_model, weight=0.5):
        self.cf_model = cf_model
        self.cb_model = cb_model
        self.weight = weight
    
    def recommend(self, user_id, n=10, exclude_rated=True):
        """
        Get hybrid recommendations.
        
        Args:
            user_id: User ID
            n: Number of recommendations
            exclude_rated: Whether to exclude already rated items
        
        Returns:
            list: Recommended items
        """
        # Get CF recommendations
        cf_recs = self.cf_model.recommend(user_id, n=n*2, exclude_rated=exclude_rated)
        
        # Get CB recommendations
        cb_recs = self.cb_model.recommend_for_user(
            [item for item, _ in cf_recs[:n]],
            n=n*2
        )
        
        # Combine and weight
        combined = {}
        
        # Add CF recommendations
        for item_id, score in cf_recs:
            combined[item_id] = combined.get(item_id, 0) + self.weight * score
        
        # Add CB recommendations
        for item_id, score in cb_recs:
            combined[item_id] = combined.get(item_id, 0) + (1 - self.weight) * score
        
        # Sort and return
        sorted_items = sorted(combined.items(), key=lambda x: x[1], reverse=True)
        
        return sorted_items[:n]
```

---

## 5. Evaluation of Recommender Systems

### Evaluation Metrics

```python
from sklearn.metrics import mean_squared_error, mean_absolute_error

class RecommenderEvaluator:
    """
    Evaluation metrics for recommendation systems.
    """
    
    @staticmethod
    def rmse(y_true, y_pred):
        """Root Mean Squared Error."""
        return np.sqrt(mean_squared_error(y_true, y_pred))
    
    @staticmethod
    def mae(y_true, y_pred):
        """Mean Absolute Error."""
        return mean_absolute_error(y_true, y_pred)
    
    @staticmethod
    def precision_at_k(recommendations, actual, k=10):
        """
        Precision@k.
        
        Args:
            recommendations: List of recommended items
            actual: List of actual items
            k: Number of recommendations to consider
        
        Returns:
            float: Precision@k
        """
        rec_at_k = recommendations[:k]
        hits = len(set(rec_at_k) & set(actual))
        return hits / min(k, len(rec_at_k)) if rec_at_k else 0
    
    @staticmethod
    def recall_at_k(recommendations, actual, k=10):
        """
        Recall@k.
        
        Args:
            recommendations: List of recommended items
            actual: List of actual items
            k: Number of recommendations to consider
        
        Returns:
            float: Recall@k
        """
        rec_at_k = recommendations[:k]
        hits = len(set(rec_at_k) & set(actual))
        return hits / len(actual) if actual else 0
    
    @staticmethod
    def f1_at_k(recommendations, actual, k=10):
        """
        F1@k.
        
        Args:
            recommendations: List of recommended items
            actual: List of actual items
            k: Number of recommendations to consider
        
        Returns:
            float: F1@k
        """
        precision = RecommenderEvaluator.precision_at_k(recommendations, actual, k)
        recall = RecommenderEvaluator.recall_at_k(recommendations, actual, k)
        
        if precision + recall == 0:
            return 0
        
        return 2 * precision * recall / (precision + recall)
    
    @staticmethod
    def ndcg_at_k(recommendations, actual, k=10):
        """
        NDCG@k (Normalized Discounted Cumulative Gain).
        
        Args:
            recommendations: List of recommended items
            actual: List of actual items
            k: Number of recommendations to consider
        
        Returns:
            float: NDCG@k
        """
        # Create relevance scores
        actual_set = set(actual)
        relevance = [1 if item in actual_set else 0 for item in recommendations[:k]]
        
        # DCG
        dcg = sum(rel / np.log2(pos + 2) for pos, rel in enumerate(relevance))
        
        # IDCG (ideal)
        ideal_relevance = sorted(relevance, reverse=True)
        idcg = sum(rel / np.log2(pos + 2) for pos, rel in enumerate(ideal_relevance))
        
        if idcg == 0:
            return 0
        
        return dcg / idcg
```

---

## Quick Reference: Recommendation Systems

### Algorithms Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│  ALGORITHM           │ PROS                     │ CONS        │
├──────────────────────┼──────────────────────────┼─────────────┤
│  User CF             │ Simple, interpretable    │ Scalability │
│  Item CF             │ More stable than user CF │ Cold start  │
│  Matrix Factorization│ Good performance         │ Cold start  │
│  Content-Based       │ No cold start problem    │ Limited     │
│  Hybrid              │ Best of both worlds      │ Complexity  │
└─────────────────────────────────────────────────────────────────┘
```

### Common Use Cases

```
┌─────────────────────────────────────────────────────────────────┐
│  USE CASE            │ RECOMMENDED APPROACH                    │
├──────────────────────┼──────────────────────────────────────────┤
│  E-commerce          │ Hybrid (CF + Content)                  │
│  Movies/Entertainment│ Matrix Factorization                    │
│  News/Articles       │ Content-Based                          │
│  Social Media        │ Collaborative Filtering                │
│  Music               │ Matrix Factorization                   │
│  Jobs/Careers        │ Content-Based + User CF                │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers the essential concepts of recommendation systems. You now understand:

1. **Why recommenders matter**: Business impact and user experience
2. **Collaborative filtering**: User-based, item-based, matrix factorization
3. **Content-based filtering**: Feature extraction and similarity
4. **Hybrid recommenders**: Combining approaches
5. **Evaluation**: Precision, recall, NDCG, RMSE

**Next Steps:**
1. Build a simple CF recommender
2. Implement content-based recommendations
3. Create a hybrid recommender
4. Evaluate your recommender system
5. Proceed to Part 1 of the series

---

*End of Primer 24*

# Primer 27: Graph Machine Learning

## Overview

This primer provides a comprehensive introduction to Graph Machine Learning—the field of applying ML techniques to graph-structured data. Understanding graph ML is essential for applications like social network analysis, recommendation systems, drug discovery, and knowledge graphs.

---

## 1. Introduction to Graph ML

### What are Graphs?

```
┌─────────────────────────────────────────────────────────────────┐
│                    WHAT ARE GRAPHS?                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  A graph G = (V, E) consists of:                               │
│                                                                 │
│  Vertices (Nodes) V                                            │
│  └── Entities in the system (people, items, concepts)          │
│                                                                 │
│  Edges E                                                       │
│  └── Relationships between entities                            │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                                                         │   │
│  │        (A) ──────── (B)                                 │   │
│  │         │          /  │                                 │   │
│  │         │         /   │                                 │   │
│  │         │        /    │                                 │   │
│  │         │       /     │                                 │   │
│  │        (C)────(D)    (E)                               │   │
│  │                                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Types of Graphs:                                               │
│  • Directed: edges have direction (follow)                     │
│  • Undirected: edges have no direction (friendship)            │
│  • Weighted: edges have weights (distance)                     │
│  • Attributed: nodes/edges have features (user profiles)       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Why Graph ML?

```
┌─────────────────────────────────────────────────────────────────┐
│                    WHY GRAPH ML?                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Real-world Data is Graph-Structured                           │
│                                                                 │
│  Social Networks      │  Knowledge Graphs                      │
│  └── Facebook, Twitter │  └── Wikidata, Freebase              │
│                                                                 │
│  Molecular Graphs     │  Transportation Networks               │
│  └── Chemical compounds│  └── Road networks, airlines          │
│                                                                 │
│  Recommender Systems  │  Biological Networks                   │
│  └── User-item graph   │  └── Protein-protein interactions     │
│                                                                 │
│  Why Traditional ML Fails:                                     │
│  • Can't capture relational structure                         │
│  • Ignores connections between data points                    │
│  • Requires fixed feature vectors                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Graph ML Tasks

```
┌─────────────────────────────────────────────────────────────────┐
│                    GRAPH ML TASKS                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Node Classification                                            │
│  └── Predict label of a node                                   │
│  └── Example: User interest prediction                        │
│                                                                 │
│  Link Prediction                                                │
│  └── Predict if two nodes should be connected                  │
│  └── Example: Friendship recommendation                       │
│                                                                 │
│  Graph Classification                                          │
│  └── Classify entire graphs                                    │
│  └── Example: Molecular property prediction                   │
│                                                                 │
│  Node Clustering                                                │
│  └── Group similar nodes                                       │
│  └── Example: Community detection                             │
│                                                                 │
│  Graph Generation                                               │
│  └── Generate new graphs                                       │
│  └── Example: Drug discovery                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Graph Representation

### NetworkX for Graph Creation

```python
import networkx as nx
import matplotlib.pyplot as plt
import numpy as np

class GraphRepresentation:
    """
    Graph creation and representation utilities.
    """
    
    @staticmethod
    def create_social_network():
        """Create a sample social network graph."""
        G = nx.Graph()
        
        # Add nodes with attributes
        G.add_node(1, name="Alice", age=25, interest="music")
        G.add_node(2, name="Bob", age=30, interest="sports")
        G.add_node(3, name="Charlie", age=35, interest="reading")
        G.add_node(4, name="Diana", age=28, interest="music")
        G.add_node(5, name="Eve", age=22, interest="sports")
        
        # Add edges with weights
        G.add_edge(1, 2, weight=0.8)
        G.add_edge(1, 4, weight=0.9)
        G.add_edge(2, 3, weight=0.6)
        G.add_edge(2, 5, weight=0.7)
        G.add_edge(3, 4, weight=0.5)
        G.add_edge(4, 5, weight=0.3)
        
        return G
    
    @staticmethod
    def create_knowledge_graph():
        """Create a sample knowledge graph."""
        G = nx.DiGraph()
        
        # Add nodes with types
        G.add_node("Machine Learning", type="concept")
        G.add_node("Deep Learning", type="concept")
        G.add_node("Neural Networks", type="concept")
        G.add_node("Python", type="language")
        G.add_node("TensorFlow", type="framework")
        G.add_node("PyTorch", type="framework")
        
        # Add directed edges
        G.add_edge("Deep Learning", "Machine Learning", rel="subset_of")
        G.add_edge("Neural Networks", "Deep Learning", rel="part_of")
        G.add_edge("TensorFlow", "Python", rel="written_in")
        G.add_edge("PyTorch", "Python", rel="written_in")
        G.add_edge("TensorFlow", "Neural Networks", rel="implements")
        G.add_edge("PyTorch", "Neural Networks", rel="implements")
        
        return G
    
    @staticmethod
    def create_weighted_graph():
        """Create a weighted graph with random weights."""
        G = nx.Graph()
        nodes = ['A', 'B', 'C', 'D', 'E']
        
        for node in nodes:
            G.add_node(node)
        
        # Add weighted edges
        for i in range(len(nodes)):
            for j in range(i+1, len(nodes)):
                weight = np.random.rand()
                G.add_edge(nodes[i], nodes[j], weight=weight)
        
        return G
    
    @staticmethod
    def graph_to_features(G, node_attributes=None):
        """
        Convert graph to feature matrices.
        
        Args:
            G: NetworkX graph
            node_attributes: List of attribute names
        
        Returns:
            tuple: (adjacency_matrix, node_features)
        """
        # Adjacency matrix
        adj_matrix = nx.adjacency_matrix(G)
        
        # Node features (if available)
        if node_attributes:
            node_features = []
            for node in G.nodes():
                features = [G.nodes[node].get(attr, 0) for attr in node_attributes]
                node_features.append(features)
            node_features = np.array(node_features)
        else:
            node_features = None
        
        return adj_matrix.toarray(), node_features
    
    @staticmethod
    def visualize_graph(G, title="Graph Visualization", node_color='skyblue'):
        """Visualize the graph."""
        plt.figure(figsize=(10, 8))
        
        # Get node positions
        pos = nx.spring_layout(G, k=1, iterations=50)
        
        # Draw nodes
        nx.draw_networkx_nodes(G, pos, node_size=500, node_color=node_color)
        nx.draw_networkx_labels(G, pos)
        
        # Draw edges
        nx.draw_networkx_edges(G, pos, alpha=0.5)
        
        # Draw edge labels (if weighted)
        if nx.get_edge_attributes(G, 'weight'):
            edge_labels = nx.get_edge_attributes(G, 'weight')
            nx.draw_networkx_edge_labels(G, pos, edge_labels)
        
        plt.title(title)
        plt.axis('off')
        plt.tight_layout()
        return plt.gcf()
```

### Graph Feature Engineering

```python
class GraphFeatures:
    """
    Graph feature engineering utilities.
    """
    
    @staticmethod
    def node_degree_centrality(G):
        """Compute node degree centrality."""
        return dict(nx.degree_centrality(G))
    
    @staticmethod
    def node_closeness_centrality(G):
        """Compute node closeness centrality."""
        return dict(nx.closeness_centrality(G))
    
    @staticmethod
    def node_betweenness_centrality(G):
        """Compute node betweenness centrality."""
        return dict(nx.betweenness_centrality(G))
    
    @staticmethod
    def node_eigenvector_centrality(G):
        """Compute node eigenvector centrality."""
        return dict(nx.eigenvector_centrality(G))
    
    @staticmethod
    def node_clustering_coefficient(G):
        """Compute clustering coefficient for each node."""
        return dict(nx.clustering(G))
    
    @staticmethod
    def graph_statistics(G):
        """
        Compute comprehensive graph statistics.
        
        Args:
            G: NetworkX graph
        
        Returns:
            dict: Graph statistics
        """
        stats = {
            'nodes': G.number_of_nodes(),
            'edges': G.number_of_edges(),
            'density': nx.density(G),
            'is_connected': nx.is_connected(G),
            'diameter': nx.diameter(G) if nx.is_connected(G) else None,
            'avg_degree': np.mean([d for n, d in G.degree()]),
            'avg_clustering': nx.average_clustering(G),
            'number_connected_components': nx.number_connected_components(G)
        }
        
        return stats
    
    @staticmethod
    def create_neighborhood_features(G, node, radius=1):
        """
        Create features based on node's neighborhood.
        
        Args:
            G: NetworkX graph
            node: Target node
            radius: Neighborhood radius
        
        Returns:
            dict: Neighborhood features
        """
        # Get neighbors within radius
        neighbors = nx.single_source_shortest_path_length(G, node, cutoff=radius)
        
        # Exclude self
        neighbors = {k: v for k, v in neighbors.items() if k != node}
        
        features = {
            'degree': G.degree(node),
            'clustering': nx.clustering(G, node),
            'neighbor_count': len(neighbors),
            'neighbor_degrees': [G.degree(n) for n in neighbors.keys()],
            'avg_neighbor_degree': np.mean([G.degree(n) for n in neighbors.keys()]) if neighbors else 0,
            'weighted_degree': sum([G[node][n].get('weight', 1) for n in G.neighbors(node)])
        }
        
        return features
    
    @staticmethod
    def create_edge_features(G, node1, node2):
        """
        Create features for an edge.
        
        Args:
            G: NetworkX graph
            node1: First node
            node2: Second node
        
        Returns:
            dict: Edge features
        """
        # Common neighbors
        common_neighbors = len(list(nx.common_neighbors(G, node1, node2)))
        
        # Jaccard similarity
        neighbors1 = set(G.neighbors(node1))
        neighbors2 = set(G.neighbors(node2))
        jaccard = len(neighbors1 & neighbors2) / len(neighbors1 | neighbors2) if neighbors1 | neighbors2 else 0
        
        # Adamic-Adar score
        adamic_adar = nx.adamic_adar_index(G, [(node1, node2)])
        adamic_adar = next(adamic_adar, (0, 0, 0))[2]
        
        # Preferential attachment
        pref_attach = G.degree(node1) * G.degree(node2)
        
        features = {
            'common_neighbors': common_neighbors,
            'jaccard_similarity': jaccard,
            'adamic_adar': adamic_adar,
            'preferential_attachment': pref_attach
        }
        
        return features
```

---

## 3. Graph Neural Networks (GNNs)

### Graph Convolutional Networks (GCN)

```python
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch_geometric.nn import GCNConv, global_mean_pool
from torch_geometric.datasets import Planetoid
from torch_geometric.transforms import NormalizeFeatures

class GCN(nn.Module):
    """
    Graph Convolutional Network for node classification.
    """
    
    def __init__(self, in_channels, hidden_channels, out_channels, num_layers=2):
        super(GCN, self).__init__()
        
        self.num_layers = num_layers
        self.convs = nn.ModuleList()
        
        # Input layer
        self.convs.append(GCNConv(in_channels, hidden_channels))
        
        # Hidden layers
        for _ in range(num_layers - 2):
            self.convs.append(GCNConv(hidden_channels, hidden_channels))
        
        # Output layer
        self.convs.append(GCNConv(hidden_channels, out_channels))
    
    def forward(self, x, edge_index):
        # First layers with ReLU
        for i in range(self.num_layers):
            x = self.convs[i](x, edge_index)
            if i < self.num_layers - 1:
                x = F.relu(x)
                x = F.dropout(x, training=self.training)
        
        return F.log_softmax(x, dim=1)

class GCNForGraphClassification(nn.Module):
    """
    GCN for graph classification.
    """
    
    def __init__(self, in_channels, hidden_channels, out_channels, num_layers=2):
        super(GCNForGraphClassification, self).__init__()
        
        self.num_layers = num_layers
        self.convs = nn.ModuleList()
        
        # Input layer
        self.convs.append(GCNConv(in_channels, hidden_channels))
        
        # Hidden layers
        for _ in range(num_layers - 2):
            self.convs.append(GCNConv(hidden_channels, hidden_channels))
        
        # Output layer
        self.convs.append(GCNConv(hidden_channels, hidden_channels))
        
        # Classifier
        self.classifier = nn.Linear(hidden_channels, out_channels)
    
    def forward(self, x, edge_index, batch):
        # GCN layers
        for i in range(self.num_layers):
            x = self.convs[i](x, edge_index)
            if i < self.num_layers - 1:
                x = F.relu(x)
                x = F.dropout(x, training=self.training)
        
        # Global pooling
        x = global_mean_pool(x, batch)
        
        # Classifier
        x = F.relu(x)
        x = self.classifier(x)
        
        return F.log_softmax(x, dim=1)

# Training function for GCN
def train_gcn(model, data, optimizer, epochs=200):
    """
    Train GCN model.
    
    Args:
        model: GCN model
        data: PyTorch Geometric data
        optimizer: Optimizer
        epochs: Number of epochs
    """
    model.train()
    
    for epoch in range(epochs):
        optimizer.zero_grad()
        
        # Forward pass
        out = model(data.x, data.edge_index)
        
        # Compute loss (only on training nodes)
        loss = F.nll_loss(out[data.train_mask], data.y[data.train_mask])
        
        # Backward pass
        loss.backward()
        optimizer.step()
        
        if (epoch + 1) % 20 == 0:
            # Evaluate on validation set
            model.eval()
            with torch.no_grad():
                pred = model(data.x, data.edge_index).argmax(dim=1)
                val_acc = (pred[data.val_mask] == data.y[data.val_mask]).float().mean()
                train_acc = (pred[data.train_mask] == data.y[data.train_mask]).float().mean()
            
            print(f"Epoch {epoch+1}, Loss: {loss.item():.4f}, "
                  f"Train Acc: {train_acc:.4f}, Val Acc: {val_acc:.4f}")
            
            model.train()
```

### Graph Attention Networks (GAT)

```python
from torch_geometric.nn import GATConv

class GAT(nn.Module):
    """
    Graph Attention Network.
    """
    
    def __init__(self, in_channels, hidden_channels, out_channels, heads=8, num_layers=2):
        super(GAT, self).__init__()
        
        self.num_layers = num_layers
        self.convs = nn.ModuleList()
        
        # Input layer with multi-head attention
        self.convs.append(GATConv(in_channels, hidden_channels, heads=heads, dropout=0.6))
        
        # Hidden layers
        for _ in range(num_layers - 2):
            self.convs.append(GATConv(hidden_channels * heads, hidden_channels, heads=heads, dropout=0.6))
        
        # Output layer
        self.convs.append(GATConv(hidden_channels * heads, out_channels, heads=1, concat=False, dropout=0.6))
    
    def forward(self, x, edge_index):
        for i in range(self.num_layers):
            x = self.convs[i](x, edge_index)
            if i < self.num_layers - 1:
                x = F.elu(x)
                x = F.dropout(x, training=self.training)
        
        return F.log_softmax(x, dim=1)
```

### GraphSAGE

```python
from torch_geometric.nn import SAGEConv

class GraphSAGE(nn.Module):
    """
    GraphSAGE network.
    """
    
    def __init__(self, in_channels, hidden_channels, out_channels, num_layers=2):
        super(GraphSAGE, self).__init__()
        
        self.num_layers = num_layers
        self.convs = nn.ModuleList()
        
        # Input layer
        self.convs.append(SAGEConv(in_channels, hidden_channels))
        
        # Hidden layers
        for _ in range(num_layers - 2):
            self.convs.append(SAGEConv(hidden_channels, hidden_channels))
        
        # Output layer
        self.convs.append(SAGEConv(hidden_channels, out_channels))
    
    def forward(self, x, edge_index):
        for i in range(self.num_layers):
            x = self.convs[i](x, edge_index)
            if i < self.num_layers - 1:
                x = F.relu(x)
                x = F.dropout(x, training=self.training)
        
        return F.log_softmax(x, dim=1)
```

---

## 4. Node Embedding Methods

### Node2Vec

```python
from node2vec import Node2Vec

class NodeEmbeddings:
    """
    Node embedding methods.
    """
    
    @staticmethod
    def node2vec_embeddings(G, dimensions=64, walk_length=30, num_walks=200, workers=4):
        """
        Generate Node2Vec embeddings.
        
        Args:
            G: NetworkX graph
            dimensions: Embedding dimensions
            walk_length: Length of random walks
            num_walks: Number of walks per node
            workers: Number of workers
        
        Returns:
            dict: Node embeddings
        """
        # Learn embeddings
        node2vec = Node2Vec(
            G,
            dimensions=dimensions,
            walk_length=walk_length,
            num_walks=num_walks,
            workers=workers
        )
        
        # Fit model
        model = node2vec.fit(window=10, min_count=1, batch_words=4)
        
        # Get embeddings
        embeddings = {node: model.wv[str(node)] for node in G.nodes()}
        
        return embeddings
    
    @staticmethod
    def deepwalk_embeddings(G, dimensions=64, walk_length=30, num_walks=200):
        """
        Generate DeepWalk embeddings (using Node2Vec implementation).
        """
        # DeepWalk is similar to Node2Vec with p=1, q=1
        from node2vec import Node2Vec
        
        node2vec = Node2Vec(
            G,
            dimensions=dimensions,
            walk_length=walk_length,
            num_walks=num_walks,
            p=1,
            q=1
        )
        
        model = node2vec.fit(window=10, min_count=1, batch_words=4)
        embeddings = {node: model.wv[str(node)] for node in G.nodes()}
        
        return embeddings
```

---

## 5. Link Prediction

### Link Prediction with GNNs

```python
class LinkPredictor(nn.Module):
    """
    Link prediction using GNN.
    """
    
    def __init__(self, in_channels, hidden_channels, num_layers=2):
        super(LinkPredictor, self).__init__()
        
        self.gnn = GCN(in_channels, hidden_channels, hidden_channels, num_layers)
        self.classifier = nn.Sequential(
            nn.Linear(hidden_channels * 2, 64),
            nn.ReLU(),
            nn.Dropout(0.5),
            nn.Linear(64, 1)
        )
    
    def forward(self, x, edge_index, edge_pairs):
        # Get node embeddings
        node_emb = self.gnn(x, edge_index)
        
        # Concatenate embeddings for each edge pair
        edge_emb = torch.cat([
            node_emb[edge_pairs[:, 0]],
            node_emb[edge_pairs[:, 1]]
        ], dim=1)
        
        # Predict link probability
        return torch.sigmoid(self.classifier(edge_emb)).squeeze(-1)

def train_link_predictor(model, data, train_edges, train_labels, optimizer, epochs=100):
    """
    Train link prediction model.
    """
    model.train()
    
    for epoch in range(epochs):
        optimizer.zero_grad()
        
        # Predict
        pred = model(data.x, data.edge_index, train_edges)
        
        # Loss
        loss = F.binary_cross_entropy(pred, train_labels.float())
        
        # Backward
        loss.backward()
        optimizer.step()
        
        if (epoch + 1) % 20 == 0:
            print(f"Epoch {epoch+1}, Loss: {loss.item():.4f}")
```

### Traditional Link Prediction

```python
class LinkPrediction:
    """
    Traditional link prediction methods.
    """
    
    @staticmethod
    def common_neighbors(G, node1, node2):
        """Common neighbors score."""
        return len(list(nx.common_neighbors(G, node1, node2)))
    
    @staticmethod
    def jaccard_coefficient(G, node1, node2):
        """Jaccard similarity."""
        neighbors1 = set(G.neighbors(node1))
        neighbors2 = set(G.neighbors(node2))
        intersection = neighbors1 & neighbors2
        union = neighbors1 | neighbors2
        return len(intersection) / len(union) if union else 0
    
    @staticmethod
    def adamic_adar(G, node1, node2):
        """Adamic-Adar score."""
        return sum(1 / np.log(G.degree(n)) for n in nx.common_neighbors(G, node1, node2))
    
    @staticmethod
    def preferential_attachment(G, node1, node2):
        """Preferential attachment score."""
        return G.degree(node1) * G.degree(node2)
    
    @staticmethod
    def resource_allocation(G, node1, node2):
        """Resource allocation score."""
        return sum(1 / G.degree(n) for n in nx.common_neighbors(G, node1, node2))
    
    @staticmethod
    def katz_index(G, node1, node2, beta=0.1):
        """Katz index (approximate)."""
        # Count walks of length 1, 2, 3
        score = 0
        
        # Length 1: direct edge
        if G.has_edge(node1, node2):
            score += beta
        
        # Length 2: common neighbors
        common = nx.common_neighbors(G, node1, node2)
        score += beta**2 * len(list(common))
        
        # Length 3: walks of length 3
        walks_3 = 0
        for n in G.neighbors(node1):
            if n != node2:
                for m in G.neighbors(n):
                    if m != node1:
                        if G.has_edge(m, node2):
                            walks_3 += 1
        score += beta**3 * walks_3
        
        return score
    
    @staticmethod
    def predict_all_links(G, method='common_neighbors', top_k=10):
        """
        Predict missing links.
        
        Args:
            G: NetworkX graph
            method: Link prediction method
            top_k: Number of top predictions
        
        Returns:
            list: Top predicted links
        """
        # Get all possible non-existent edges
        nodes = list(G.nodes())
        non_edges = [(u, v) for u in nodes for v in nodes 
                    if u < v and not G.has_edge(u, v)]
        
        # Score each non-edge
        scores = []
        for u, v in non_edges:
            if method == 'common_neighbors':
                score = LinkPrediction.common_neighbors(G, u, v)
            elif method == 'jaccard':
                score = LinkPrediction.jaccard_coefficient(G, u, v)
            elif method == 'adamic_adar':
                score = LinkPrediction.adamic_adar(G, u, v)
            elif method == 'preferential_attachment':
                score = LinkPrediction.preferential_attachment(G, u, v)
            elif method == 'resource_allocation':
                score = LinkPrediction.resource_allocation(G, u, v)
            else:
                raise ValueError(f"Unknown method: {method}")
            
            scores.append((u, v, score))
        
        # Sort by score descending
        scores.sort(key=lambda x: x[2], reverse=True)
        
        return scores[:top_k]
```

---

## Quick Reference: Graph ML

### GNN Layer Types

```
┌─────────────────────────────────────────────────────────────────┐
│  LAYER      │ BEST FOR                │ COMPLEXITY            │
├─────────────┼─────────────────────────┼───────────────────────┤
│  GCN        │ General purpose         │ Medium                │
│  GAT        │ Attention needed        │ High                  │
│  GraphSAGE  │ Large graphs            │ Medium                │
│  GIN        │ Graph classification    │ Medium                │
│  Gated      │ Sequential data         │ High                  │
└─────────────────────────────────────────────────────────────────┘
```

### Libraries

```
┌─────────────────────────────────────────────────────────────────┐
│  LIBRARY     │ BEST FOR               │ EASE OF USE          │
├──────────────┼────────────────────────┼───────────────────────┤
│  PyTorch G.  │ Research, GNNs        │ Medium               │
│  DGL         │ Production, Scaling   │ Medium               │
│  NetworkX    │ Small graphs, Analysis │ High                 │
│  Stellargraph│ Traditional methods   │ High                 │
│  Graph-tool  │ Performance           │ Low                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers the essential concepts of Graph Machine Learning. You now understand:

1. **Graph basics**: Structure, types, tasks
2. **Graph representation**: NetworkX, features
3. **GNNs**: GCN, GAT, GraphSAGE
4. **Node embeddings**: Node2Vec, DeepWalk
5. **Link prediction**: GNN and traditional methods

**Next Steps:**
1. Practice with NetworkX
2. Implement a GCN
3. Try link prediction
4. Explore PyTorch Geometric
5. Proceed to Part 1 of the series

---

*End of Primer 27*

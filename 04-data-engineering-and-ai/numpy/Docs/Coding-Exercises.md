# Coding Exercises & Solutions: High-Performance NumPy Data Manipulation

Welcome to the **NumPy Coding Exercises & Solutions** workbook. This manual provides hands-on exercises focused on array vectorization, broadcasting rules, memory strides, advanced indexing, and linear algebra operations designed to build raw C-level computational fluency.

---

## Exercise 1: Vectorized Euclidean Distance Matrix

### Problem Statement

Given two 2D arrays representing sets of coordinates—`points_a` of shape $(N, D)$ and `points_b` of shape $(M, D)$—write a function `compute_distance_matrix(points_a, points_b)` that computes the pairwise Euclidean distance matrix of shape $(N, M)$ **without using explicit loops (`for` or `while`)**.

### Solution Code

```python
import numpy as np

def compute_distance_matrix(points_a: np.ndarray, points_b: np.ndarray) -> np.ndarray:
    # Expand dimensions to enable broadcasting:
    # points_a[:, np.newaxis, :] has shape (N, 1, D)
    # points_b[np.newaxis, :, :] has shape (1, M, D)
    diff = points_a[:, np.newaxis, :] - points_b[np.newaxis, :, :]
    
    # Compute Euclidean distance via squared differences, summing across coordinate axis (D), and taking square root
    dist_matrix = np.sqrt(np.sum(diff ** 2, axis=-1))
    
    return dist_matrix

```

---

## Exercise 2: Image Normalization & Min-Max Scaling via Broadcasting

### Problem Statement

You are given a batch of RGB images of shape `(Batch, Height, Width, Channels)` represented as float arrays. Write a function `normalize_images(batch_images)` that scales each image channel independently across the batch such that pixel values for each channel map to the range $[0.0, 1.0]$. Avoid loops by utilizing proper axis reduction and broadcasting.

### Solution Code

```python
import numpy as np

def normalize_images(batch_images: np.ndarray) -> np.ndarray:
    # Find minimum and maximum values per channel across Batch, Height, and Width axes (axes 0, 1, 2)
    # Keep dimensions to allow proper broadcasting against shape (B, H, W, C)
    min_val = batch_images.min(axis=(0, 1, 2), keepdims=True)
    max_val = batch_images.max(axis=(0, 1, 2), keepdims=True)
    
    # Prevent division by zero if a channel is entirely uniform
    range_val = max_val - min_val
    range_val[range_val == 0.0] = 1.0
    
    # Vectorized min-max scaling
    normalized = (batch_images - min_val) / range_val
    
    return normalized

```

---

## Exercise 3: Sliding Window Views (Strides Manipulation)

### Problem Statement

Write a function `sliding_window_1d(arr, window_size)` that takes a 1D NumPy array `arr` of length $L$ and returns a 2D array containing overlapping sliding windows of size $W$ (`window_size`) using `np.lib.stride_tricks.as_strided` without allocating redundant memory copies.

### Solution Code

```python
import numpy as np

def sliding_window_1d(arr: np.ndarray, window_size: int) -> np.ndarray:
    if window_size > len(arr):
        raise ValueError("Window size cannot exceed array length.")
        
    n_windows = len(arr) - window_size + 1
    
    # Extract existing element itemsize and stride step in bytes
    item_size = arr.itemsize
    stride_step = arr.strides[0]
    
    # Construct new shape and strides layout
    shape = (n_windows, window_size)
    strides = (stride_step, stride_step)
    
    # Generate zero-copy view via stride manipulation
    windows = np.lib.stride_tricks.as_strided(arr, shape=shape, strides=strides)
    
    return windows

```

---

## Exercise 4: Conditional Masking & In-Place Array Clipping

### Problem Statement

Given a 2D temperature readings matrix `data`, write a function `clip_outliers(data, lower_bound, upper_bound)` that modifies the array **in-place** (without allocating new memory arrays) such that any value below `lower_bound` is set exactly to `lower_bound`, and any value above `upper_bound` is set to `upper_bound`.

### Solution Code

```python
import numpy as np

def clip_outliers(data: np.ndarray, lower_bound: float, upper_bound: float) -> np.ndarray:
    # Use boolean masks combined with in-place assignment to avoid allocating new memory
    data[data < lower_bound] = lower_bound
    data[data > upper_bound] = upper_bound
    
    return data

```

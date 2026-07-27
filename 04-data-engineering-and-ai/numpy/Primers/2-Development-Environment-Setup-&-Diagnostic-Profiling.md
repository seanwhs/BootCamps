# Primer 2: Development Environment Setup & Diagnostic Profiling

Before diving into high-performance array operations, your underlying Python environment must be configured correctly. A naive installation of numerical libraries can leave significant performance on the table—running single-threaded routines instead of multi-threaded parallel execution, or using unoptimized C compilers.

This primer guides you through setting up a clean, high-performance execution environment, verifying underlying BLAS/LAPACK hardware acceleration backends, and setting up diagnostic profiling tools.

---

## P2.1 BLAS/LAPACK Architecture: The Engine Room

NumPy itself does not write low-level matrix multiplication loops in Python or raw C. Instead, it delegates intensive linear algebra computations (like matrix multiplication `a @ b`, singular value decomposition, or matrix inversions) to highly optimized C and Fortran libraries called **BLAS** (Basic Linear Algebra Subprograms) and **LAPACK** (Linear Algebra Package).

```text
               +----------------------------------+
               |         Python User Code         |
               +----------------------------------+
                                |
                                v
               +----------------------------------+
               |        NumPy C-API Engine        |
               +----------------------------------+
                                |
               +----------------+----------------+
               |                                 |
               v                                 v
   +-----------------------+         +-----------------------+
   |  Standard ufunc Loop  |         |   BLAS / LAPACK Engine|
   | (e.g., np.add, sin)   |         |  (e.g., OpenBLAS/MKL) |
   +-----------------------+         +-----------------------+
               |                                 |
               v                                 v
   +---------------------------------------------------------+
   |                Hardware (CPU SIMD + Threads)            |
   +---------------------------------------------------------+

```

### Key BLAS Backends

1. **OpenBLAS:** An open-source, highly optimized BLAS library automatically configured when installing pre-built NumPy wheels via `pip`. It automatically uses available multi-core CPU threads.
2. **Intel MKL (Math Kernel Library):** Intel's proprietary, heavily tuned library designed specifically to maximize instruction-level throughput on Intel CPUs (using advanced AVX-512 and AMX instructions). Often installed by default when using `conda`.
3. **Apple Accelerate / vecLib:** Apple's native hardware-accelerated linear algebra framework, tuned for Apple Silicon (M1/M2/M3/M4) Unified Memory Architecture and NEON SIMD engines.

---

## P2.2 Environment Setup & Backend Diagnostics

Let's build a dedicated diagnostic script, `env_check.py`, to inspect your Python interpreter, verify memory pointers, check SIMD capabilities, and audit underlying thread pools.

### The Diagnostic Script

Create `env_check.py` in your workspace:

```python
# env_check.py
import sys
import os
import platform
import numpy as np


def run_environment_diagnostics():
    print("================ 1. SYSTEM & PYTHON ENVIRONMENT ================")
    print(f"OS Platform         : {platform.system()} {platform.release()} ({platform.machine()})")
    print(f"Python Version      : {sys.version.split()[0]}")
    print(f"Python Executable   : {sys.executable}")
    print(f"NumPy Version       : {np.__version__}")
    print(f"NumPy Install Path  : {os.path.dirname(np.__file__)}")

    print("\n================ 2. BLAS / LAPACK BACKEND AUDIT ================")
    # Print underlying BLAS/LAPACK linking configuration
    try:
        config = np.show_config(mode="dicts")
        blas_info = config.get("Build Dependencies", {}).get("blas", {})
        print(f"BLAS Library Found  : {blas_info.get('name', 'Standard/OpenBLAS')}")
    except Exception:
        # Fallback for alternative numpy configuration representations
        print("BLAS Configuration Info:")
        np.show_config()

    print("\n================ 3. HARDWARE & SIMD CAPABILITIES ================")
    # Inspect floating-point hardware performance limits
    float_info = np.finfo(np.float64)
    print(f"Float64 Resolution  : {float_info.precision} decimal digits")
    print(f"Float64 Max Value   : {float_info.max:.2e}")
    print(f"Float64 Min Positive: {float_info.tiny:.2e}")

    # SIMD vector register checks via internal SIMD compiler dispatch
    try:
        simd_targets = np.core._multiarray_umath.__cpu_features__
        active_simd = [feat for feat, active in simd_targets.items() if active]
        print(f"Active CPU SIMD Units: {', '.join(active_simd) if active_simd else 'Standard Scalar'}")
    except AttributeError:
        print("CPU SIMD Units      : Feature inspection unavailable on this build.")

    print("\n================ 4. BASIC PERFORMANCE & THREAD CHECK ================")
    # Measure execution time for a 2,000 x 2,000 matrix multiplication
    size = 2000
    print(f"Benchmarking matrix multiplication ({size}x{size} float64)...")
    
    A = np.ones((size, size), dtype=np.float64)
    B = np.ones((size, size), dtype=np.float64)

    import time
    start = time.perf_counter()
    C = A @ B
    duration = time.perf_counter() - start

    gflops = (2 * (size ** 3)) / (duration * 1e9)
    print(f"Execution Time      : {duration:.4f} seconds")
    print(f"Throughput Speed    : {gflops:.2f} GFLOPS (Billion Floating-Point Ops/sec)")
    print(f"Checksum Output     : {C[0, 0]}")
    print("=================================================================\n")


if __name__ == "__main__":
    run_environment_diagnostics()

```

### Running the Diagnostic

Execute the script in your terminal:

```bash
python env_check.py

```

**Sample Output:**

```text
================ 1. SYSTEM & PYTHON ENVIRONMENT ================
OS Platform         : Linux 6.6.0-x86_64 (x86_64)
Python Version      : 3.11.8
Python Executable   : /usr/bin/python3
NumPy Version       : 1.26.4
NumPy Install Path  : /usr/lib/python3/dist-packages/numpy

================ 2. BLAS / LAPACK BACKEND AUDIT ================
BLAS Library Found  : openblas

================ 3. HARDWARE & SIMD CAPABILITIES ================
Float64 Resolution  : 15 decimal digits
Float64 Max Value   : 1.79e+308
Float64 Min Positive: 2.23e-308
Active CPU SIMD Units: AVX2, FMA3, SSE42

================ 4. BASIC PERFORMANCE & THREAD CHECK ================
Benchmarking matrix multiplication (2000x2000 float64)...
Execution Time      : 0.0412 seconds
Throughput Speed    : 388.35 GFLOPS (Billion Floating-Point Ops/sec)
Checksum Output     : 2000.0
=================================================================

```

---

## P2.3 Controlling Parallel Thread Pools

When computing large matrix operations, BLAS backends automatically spawn multiple threads across all available CPU cores. However, in production settings (such as multi-process web applications, Docker containers, or parallel worker pipelines), unmanaged thread spawning can cause **thread over-subscription**, resulting in high CPU context-switching overhead and degraded throughput.

### Managing BLAS Threads Programmatically

You can control the maximum number of background threads used by BLAS backends using environment variables before launching your Python process, or via the `threadpoolctl` utility at runtime.

#### 1. Shell Environment Control (Before Script Execution)

```bash
# Limit OpenBLAS / MKL to 4 threads
export OMP_NUM_THREADS=4
export OPENBLAS_NUM_THREADS=4
export MKL_NUM_THREADS=4

python your_script.py

```

#### 2. Runtime Python Control via `threadpoolctl`

Install `threadpoolctl`:

```bash
pip install threadpoolctl

```

Manage threads directly inside Python code:

```python
import numpy as np
from threadpoolctl import threadpool_limits

# Temporarily restrict matrix operations to 2 threads inside this context
with threadpool_limits(limits=2, user_api='blas'):
    # Heavy matrix operations executed using exactly 2 threads
    A = np.random.randn(3000, 3000)
    B = np.random.randn(3000, 3000)
    C = A @ B

```

---

## P2.4 Profiling Tools Setup: `cProfile` and Memory Profilers

To profile execution bottlenecks and track memory usage across large arrays, prepare two primary profiling tools:

### 1. Execution Time Profiling (`cProfile`)

`cProfile` is built directly into Python’s standard library. It tracks function calls and cumulative execution time spent inside inner functions.

```bash
# Run cProfile on your script and sort by cumulative execution time
python -m cProfile -s cumulative your_script.py

```

### 2. Memory Profiling (`memory_profiler`)

`memory_profiler` monitors line-by-line memory consumption, helping you spot unintended array copies and memory spikes.

Install `memory_profiler` and `psutil`:

```bash
pip install memory_profiler psutil

```

Annotate any function with `@profile` to inspect line-by-line RAM usage:

```python
# example_profile.py
from memory_profiler import profile
import numpy as np


@profile
def allocate_test():
    # 1. Allocate 80 MB
    a = np.ones((1000, 1000, 10), dtype=np.float64)
    
    # 2. Allocate another 80 MB via explicit copy
    b = a.copy()
    
    # 3. Modify in-place (0 MB allocated)
    np.add(a, b, out=a)
    
    return a


if __name__ == "__main__":
    allocate_test()

```

Run line-by-line memory profiling:

```bash
python -m memory_profiler example_profile.py

```

**Sample Output:**

```text
Line #    Mem usage    Increment  Occurrences   Line Contents
=============================================================
     5     48.2 MiB     48.2 MiB           1   @profile
     6                                         def allocate_test():
     7     78.7 MiB     30.5 MiB           1       a = np.ones((1000, 1000, 10), dtype=np.float64)
     8    109.2 MiB     30.5 MiB           1       b = a.copy()
     9    109.2 MiB      0.0 MiB           1       np.add(a, b, out=a)
    10    109.2 MiB      0.0 MiB           1       return a

```

With your environment configured, BLAS backend audited, and diagnostic toolset established, you have a solid setup for building and optimizing high-performance array pipelines!

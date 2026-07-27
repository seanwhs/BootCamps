# Curated References & Further Reading

Here is a targeted selection of official documentation, foundational textbooks, and diagnostic tools to deepen your expertise in high-performance array computing and numerical system design.

---

## 📚 Essential Reading & Core Specifications

* **NumPy C-API & Internals Documentation**
*Official NumPy Documentation*
[numpy.org/doc/stable/reference/c-api](https://numpy.org/doc/stable/reference/c-api)
*Deep dive into `PyArrayObject`, stride structures, ufunc execution loops, and memory flags.*
* **Guide to NumPy (2nd Edition)** — *Travis E. Oliphant*
*CreateSpace Independent Publishing Platform (2015)*
*Written by the creator of NumPy; provides the authoritative architectural overview of array layout, memory buffers, and C-extensions.*
* **Python High Performance (3rd Edition)** — *Gabriele Lanaro, Fernando Doglio*
*Packt Publishing (2020)*
*Practical strategies for profiling Python applications, vectorizing computations, and leveraging Numba/Cython for low-level execution.*
* **What Every Computer Scientist Should Know About Floating-Point Arithmetic** — *David Goldberg*
*ACM Computing Surveys (1991)*
[docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html](https://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html)
*The foundational paper on IEEE 754 floating-point behavior, rounding errors, precision loss, and numerical stability.*

---

## 🛠️ Optimization & Profiling Tooling

* **`threadpoolctl` Library**
[github.com/joblib/threadpoolctl](https://github.com/joblib/threadpoolctl)
*Python tool to inspect and programmatically limit thread pools in OpenBLAS, MKL, BLIS, and OpenMP runtimes.*
* **`memory_profiler` Module**
[pypi.org/project/memory-profiler](https://pypi.org/project/memory-profiler/)
*Line-by-line monitoring of memory consumption in Python programs.*
* **Numba JIT Documentation & Performance Tips**
[numba.readthedocs.io](https://numba.readthedocs.io/)
*Official guides on compiling Python code down to LLVM machine code, avoiding object-mode fallbacks, and utilizing `@njit(parallel=True)`.*
* **NumExpr Documentation**
[github.com/pydata/numexpr](https://github.com/pydata/numexpr)
*Fast numerical expression evaluator that avoids intermediate allocations by computing array operations in chunks via multi-threaded VM execution.*

---

## 🌐 Open-Source Numerical Architecture Resources

* **BLAS (Basic Linear Algebra Subprograms) Standards**
[netlib.org/blas](https://www.netlib.org/blas/)
*Level 1 (vector-vector), Level 2 (matrix-vector), and Level 3 (matrix-matrix) operational specifications.*
* **OpenBLAS Source Repository & Wiki**
[github.com/OpenMathLib/OpenBLAS](https://github.com/OpenMathLib/OpenBLAS)
*High-performance open-source implementation of BLAS/LAPACK tuned for specific CPU microarchitectures.*
* **Intel OneAPI Math Kernel Library (MKL)**
[intel.com/content/www/us/en/developer/tools/oneapi/onemkl.html](https://www.intel.com/content/www/us/en/developer/tools/oneapi/onemkl.html)
*Intel’s proprietary BLAS backend optimized for AVX-512 and AMX instructions.*

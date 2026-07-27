# Trainer Guide: Mastering High-Performance NumPy

This guide provides instructional strategies, pacing benchmarks, whiteboard diagrams, common student misconceptions, and live delivery notes for teaching the 52-slide presentation deck.

---

## 🧭 Course Overview & Pacing Schedule

* **Target Audience:** Software engineers, data engineers, and quantitative developers looking to transition from basic NumPy usage to low-level optimization, memory efficiency, and high-performance execution.
* **Format:** 2-Day Intensive Workshop (12 Hours Total) or 4 Half-Day Sessions.
* **Prerequisites:** Intermediate Python (functions, decorators, basic OOP), familiarity with numerical vectors/matrices.

### Recommended Time Allocation

```
+-------------------------------------------------------------------------+
| DAY 1                                                                   |
| 09:00 - 10:30 | Primers 1 & 2: System Architecture & Diagnostics (Slides 1-7) |
| 10:30 - 10:45 | Morning Break                                           |
| 10:45 - 12:30 | Module 1: Memory Architecture & Strides (Slides 8-18)    |
| 12:30 - 13:30 | Lunch Break                                             |
| 13:30 - 15:00 | Lab 1: Stride Mechanics & Zero-Copy Audit               |
| 15:00 - 15:15 | Afternoon Break                                         |
| 15:15 - 17:00 | Module 2: Broadcasting & Vectorization (Slides 19-29)   |
+-------------------------------------------------------------------------+
| DAY 2                                                                   |
| 09:00 - 10:30 | Module 3: Advanced Optimization & Einsum (Slides 30-39) |
| 10:30 - 10:45 | Morning Break                                           |
| 10:45 - 12:30 | Module 4: Memory Mapping & Out-of-Core (Slides 40-45)   |
| 12:30 - 13:30 | Lunch Break                                             |
| 13:30 - 16:00 | Capstone Lab: Out-of-Core Engine (Slides 46-47)         |
| 16:00 - 17:00 | Review, Cheat Sheets & Appendices (Slides 48-52)        |
+-------------------------------------------------------------------------+

```

---

## 📐 Whiteboard Diagrams for Live Delivery

### Diagram 1: The Dual-Layer Array Structure (Module 1)

Draw this on the board when introducing **Slides 8–10** to separate array metadata from raw memory payloads.

```
       +-------------------------------------------------------------+
       |                  PyArrayObject (Header)                     |
       |  - dtype    : int32 (4 bytes)                               |
       |  - shape    : (3, 4)                                        |
       |  - strides  : (16, 4)  --> [Row step: 16B, Col step: 4B]     |
       |  - data_ptr : 0x7FFF00                                      |
       +-------------------------------------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       |                       RAW DATA BUFFER                       |
       | [0x7FFF00]  0   1   2   3  |  Row 0                         |
       | [0x7FFF10]  4   5   6   7  |  Row 1                         |
       | [0x7FFF20]  8   9  10  11  |  Row 2                         |
       +-------------------------------------------------------------+

```

> **Key Instructional Point:** Emphasize that when we slice or transpose an array, we only modify the numbers in the top box (`strides` and `shape`). The bottom box (the raw bytes) remains untouched in RAM.

---

### Diagram 2: Broadcasting via Zero-Stride Virtual Expansion (Module 2)

Draw this when explaining **Slides 20–21** to reveal how broadcasting avoids allocating extra memory.

```
Array A: shape=(3, 1), strides=(8, 8)          Broadcast Target: shape=(3, 4)
+----+                                         +----+----+----+----+
| 10 |                                         | 10 | 10 | 10 | 10 |
| 20 |  ========== BROADCAST ===============>  | 20 | 20 | 20 | 20 |
| 30 |                                         | 30 | 30 | 30 | 30 |
+----+                                         +----+----+----+----+
                                               strides=(8, 0)
                                                           ^
                                                           |
                                      Byte step along Axis 1 is ZERO.
                                      The CPU reads the same RAM address!

```

---

## ⚠️ Common Student Misconceptions & Pitfalls

### 1. "Reshaping or transposing an array always copies the data."

* **Reality:** Reshaping and transposing are zero-copy view operations as long as the memory layout permits continuous stride strides.
* **How to prove it in class:** Run `A.T.base is A` on screen. Show that the memory address pointer does not change.

### 2. "Using Python `for` loops with NumPy is fine if the array is small."

* **Reality:** Calling NumPy elements individually inside a Python loop (e.g., `arr[i]`) incurs **PyObject wrapping/unwrapping overhead** on every single iteration. It is often *slower* than a standard Python list loop.
* **How to prove it in class:** Benchmark `sum([x for x in list])` vs `sum([arr[i] for i in range(N)])`.

### 3. "Fancy indexing creates a view just like basic slicing."

* **Reality:** Basic slicing (`arr[0:5]`) creates a **view**. Fancy indexing (`arr[[0, 1, 2]]` or `arr[arr > 0]`) creates a **copy** because the resulting elements may not fit a uniform stride interval.
* **How to prove it in class:** Modify a basic slice and show the parent array changing. Then modify a fancy indexed slice and show the parent array remaining unchanged.

---

## 🛠️ Module-by-Module Delivery Notes

### Primers 1 & 2: Setup & Environment Diagnostics

* **Goal:** Ensure every student's machine is configured properly before running benchmarks.
* **Instructor Action:** Have all students run `env_check.py` (from Primer 2). Inspect their BLAS backend outputs (`openblas`, `mkl`, or `accelerate`).
* **Discussion Prompt:** *"Why would running 16 OpenBLAS threads on an 8-core CPU slow down a web worker pipeline?"* (Answer: CPU context-switching and thread over-subscription).

### Module 1: Memory Architecture & Stride Mechanics

* **Goal:** Demystify memory pointers, strides, and contiguity.
* **Teaching Strategy:** Walk through Stride Calculations by hand using **Exercise 1.1** in the Student Workbook.
* **Key Demonstration:** Show how `np.ascontiguousarray()` fixes broken memory strides after a transpose operation to restore SIMD performance.

### Module 2: Broadcasting & Vectorization

* **Goal:** Master shape compatibility rules and eliminate loops.
* **Teaching Strategy:** Use the **Right-to-Left Alignment Rule** table on the whiteboard.
* **Interactive Exercise:** Present 3 incompatible array shapes and ask the class to identify which axis breaks compatibility and how to fix it with `np.newaxis`.

### Module 3: Advanced Optimization & Einstein Summation

* **Goal:** Teach students how to write high-performance, low-allocation array expressions.
* **Teaching Strategy:** Introduce `np.einsum` by translating familiar operations (`@`, `np.trace`, `np.sum`) step-by-step.
* **Live Demo:** Benchmark standard array expressions (`a * 2 + b`) against in-place ufuncs (`np.multiply(..., out=a)`) using `time.perf_counter()` to show the speed and memory improvement.

### Module 4: Memory-Mapped Files & Out-of-Core Processing

* **Goal:** Show how to process giant datasets without running out of RAM.
* **Teaching Strategy:** Emphasize that `np.memmap` delegates page management directly to the Operating System kernel.
* **Live Demo:** Create a dummy binary file on disk and process it using a fixed chunk size loop. Show RAM usage remaining flat in the system monitor.

---

## 🔬 Lab Facilitation Guide

During hands-on lab sessions, walk around the room and check for these specific implementation details:

1. **Workbook Lab 1.2 (View vs. Copy Audit):** Ensure students are using `.base` or `ctypes.data` to verify memory locations rather than guessing.
2. **Workbook Lab 3.2 (In-place Refactoring):** Check that students are pre-allocating memory buffers (`np.empty_like`) instead of re-assigning variables.
3. **Capstone Mini-Project:** Verify that students remember to call `.flush()` on their memory maps before re-opening them in read mode, and ensure they clean up temporary files after execution.

---

> **Trainer Note:** Keep the **Student Notes** and **Student Workbook** open alongside the slide deck during delivery for seamless reference to code snippets and exercises.

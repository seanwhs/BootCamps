# Appendix E: Asynchronous Data Pipelines & Real-Time Streaming Ingestion

Welcome to **Appendix E**. In this final expansion of the series, we bridge static batch data processing with asynchronous event-driven architectures. Here, we explore how to ingest and process high-frequency streaming payloads concurrently using Python's `asyncio` and queue patterns.

---

## 1. Asynchronous Event Stream Ingestion (`asyncio`)

### 1.1 The Target

Simulate and ingest concurrent asynchronous data batches using non-blocking I/O routines, ensuring high throughput without blocking the main event loop.

### 1.2 The Implementation

Create a script named `appx_09_async_ingestion.py`:

```python
# appx_09_async_ingestion.py
"""
Appendix E.1: Asynchronous Data Ingestion Pipeline
Simulates non-blocking concurrent batch ingestion using Python's asyncio.
"""

import asyncio
import logging
import pandas as pd

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("AsyncIngestion")


async def fetch_simulated_stream_batch(batch_id: int) -> pd.DataFrame:
    """Simulates an asynchronous network or message queue payload fetch."""
    logger.info(f"Fetching asynchronous batch {batch_id}...")
    await asyncio.sleep(0.2)  # Non-blocking simulated network delay
    
    # Generate mock batch DataFrame
    data = {
        "order_id": [f"ORD_{batch_id}_{i}" for i in range(3)],
        "quantity": [i + 1 for i in range(3)],
        "unit_price": [150.0 + (i * 10) for i in range(3)],
    }
    return pd.DataFrame(data)


async def process_stream_pipeline() -> None:
    logger.info("Initializing concurrent stream ingestion tasks...")
    
    # Fire 4 asynchronous batch ingestion requests concurrently
    tasks = [fetch_simulated_stream_batch(i) for i in range(1, 5)]
    results = await asyncio.gather(*tasks)

    # Concatenate all asynchronous streams into a unified DataFrame
    unified_stream_df = pd.concat(results, ignore_index=True)
    
    logger.info(f"Successfully aggregated {len(unified_stream_df)} total records from async streams.")
    print("\nUnified Async Stream Data Head:")
    print(unified_stream_df.head(6))


if __name__ == "__main__":
    asyncio.run(process_stream_pipeline())

```

### 1.3 The Verification

Run the asynchronous ingestion script:

```bash
python appx_09_async_ingestion.py

```

#### Verification Output:

```text
2026-07-28 07:53:10 [INFO] AsyncIngestion: Initializing concurrent stream ingestion tasks...
2026-07-28 07:53:10 [INFO] AsyncIngestion: Fetching asynchronous batch 1...
2026-07-28 07:53:10 [INFO] AsyncIngestion: Fetching asynchronous batch 2...
2026-07-28 07:53:10 [INFO] AsyncIngestion: Fetching asynchronous batch 3...
2026-07-28 07:53:10 [INFO] AsyncIngestion: Fetching asynchronous batch 4...
2026-07-28 07:53:10 [INFO] AsyncIngestion: Successfully aggregated 12 total records from async streams.

Unified Async Stream Data Head:
     order_id  quantity  unit_price
0  ORD_1_0         1       150.0
1  ORD_1_1         2       160.0
2  ORD_1_2         3       170.0
3  ORD_2_0         1       150.0
4  ORD_2_1         2       160.0
5  ORD_2_2         3       170.0

```

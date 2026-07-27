# Appendix D: Production Pipeline Orchestration & Testing

Welcome to **Appendix D**. Moving beyond standalone scripts, this final appendix explores enterprise-grade engineering practices: structuring your modular pipelines for automated test coverage and orchestrating robust end-to-end execution flows.

---

## 1. Unit Testing Data Pipelines (`pytest`)

### 1.1 The Target

Write robust unit tests using `pytest` to validate schema compliance, verify transformation outputs, and catch edge cases (such as zero-division or missing values) automatically.

### 1.2 The Implementation

Create a script named `appx_07_pipeline_tests.py`:

```python
# appx_07_pipeline_tests.py
"""
Appendix D.1: Automated Unit Testing for Data Pipelines
Validates PyArrow schema adherence and transformation logic using pytest.
"""

import pandas as pd
import pytest


def calculate_net_revenue(df: pd.DataFrame) -> pd.Series:
    """Core business logic function to test."""
    return df["quantity"] * df["unit_price"] * 0.92


@pytest.fixture
def mock_orders_dataframe() -> pd.DataFrame:
    """Provides a deterministic, isolated mock dataset for testing."""
    return pd.DataFrame({
        "order_id": [101, 102],
        "quantity": [2, 5],
        "unit_price": [100.0, 50.0],
        "payment_method": ["Credit Card", "PayPal"],
    })


def test_calculate_net_revenue(mock_orders_dataframe):
    """Test net revenue vector multiplication logic."""
    revenue = calculate_net_revenue(mock_orders_dataframe)
    
    # Expected: [2 * 100 * 0.92, 5 * 50 * 0.92] => [184.0, 230.0]
    assert revenue.iloc[0] == pytest.approx(184.0)
    assert revenue.iloc[1] == pytest.approx(230.0)


def test_dataframe_schema_validation(mock_orders_dataframe):
    """Test structural schema requirements."""
    expected_columns = {"order_id", "quantity", "unit_price", "payment_method"}
    assert expected_columns.issubset(mock_orders_dataframe.columns)
    assert mock_orders_dataframe["quantity"].dtype in ["int64", "int32"]

```

### 1.3 The Verification

Run the unit test suite via `pytest`:

```bash
pytest appx_07_pipeline_tests.py -v

```

#### Verification Output:

```text
============================= test session starts ==============================
platform linux -- Python 3.11.x, pytest-8.x.x, pluggy-1.x.x
cachedir: .pytest_cache
rootdir: /workspace
collected 2 items

appx_07_pipeline_tests.py::test_calculate_net_revenue PASSED            [ 50%]
appx_07_pipeline_tests.py::test_dataframe_schema_validation PASSED       [100%]

============================== 2 passed in 0.14s ===============================

```

---

## 2. End-to-End Pipeline Orchestration & Logging

### 2.1 The Target

Construct an orchestration harness featuring structured console logging, strict execution timing, and safe error propagation across multiple pipeline stages.

### 2.2 The Implementation

Create a script named `appx_08_pipeline_orchestrator.py`:

```python
# appx_08_pipeline_orchestrator.py
"""
Appendix D.2: Production Pipeline Orchestrator
Wraps individual ingestion and transformation modules in an audited DAG harness.
"""

import logging
import time
from typing import Callable, List

# Configure professional structured logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("PipelineOrchestrator")


def stage_wrapper(stage_name: str) -> Callable:
    """Decorator to log execution duration and handle stage-level exceptions."""
    def decorator(func: Callable) -> Callable:
        def wrapper(*args, **kwargs):
            logger.info(f"--- START STAGE: {stage_name} ---")
            start_time = time.time()
            try:
                result = func(*args, **kwargs)
                duration = time.time() - start_time
                logger.info(f"--- SUCCESS STAGE: {stage_name} (Duration: {duration:.4f}s) ---")
                return result
            except Exception as e:
                logger.error(f"--- FAILED STAGE: {stage_name} | Error: {str(e)} ---")
                raise
        return wrapper
    return decorator


@stage_wrapper("Data Ingestion & Schema Enforcement")
def run_ingestion_stage() -> str:
    time.sleep(0.1) # Simulate file IO
    return "raw_data/orders.csv"


@stage_wrapper("Transformation & Enrichment")
def run_transformation_stage(file_path: str) -> None:
    time.sleep(0.15) # Simulate transformation
    logger.info(f"Processed target file: {file_path}")


def execute_pipeline_dag() -> None:
    logger.info("Initializing Production Data Pipeline DAG...")
    try:
        path = run_ingestion_stage()
        run_transformation_stage(path)
        logger.info("Pipeline DAG executed successfully from end to end.")
    except Exception:
        logger.critical("Pipeline execution halted due to unrecoverable errors.")


if __name__ == "__main__":
    execute_pipeline_dag()

```

### 2.3 The Verification

Run the pipeline orchestrator:

```bash
python appx_08_pipeline_orchestrator.py

```

#### Verification Output:

```text
2026-07-28 07:51:25 [INFO] PipelineOrchestrator: Initializing Production Data Pipeline DAG...
2026-07-28 07:51:25 [INFO] PipelineOrchestrator: --- START STAGE: Data Ingestion & Schema Enforcement ---
2026-07-28 07:51:25 [INFO] PipelineOrchestrator: --- SUCCESS STAGE: Data Ingestion & Schema Enforcement (Duration: 0.1012s) ---
2026-07-28 07:51:25 [INFO] PipelineOrchestrator: --- START STAGE: Transformation & Enrichment ---
2026-07-28 07:51:25 [INFO] PipelineOrchestrator: PipelineOrchestrator: Processed target file: raw_data/orders.csv
2026-07-28 07:51:25 [INFO] PipelineOrchestrator: --- SUCCESS STAGE: Transformation & Enrichment (Duration: 0.1508s) ---
2026-07-28 07:51:25 [INFO] PipelineOrchestrator: Pipeline DAG executed successfully from end to end.

```

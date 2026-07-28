# Primer 4: Evaluation Metrics & The Cost of Error

> *"Not everything that counts can be counted, and not everything that can be counted counts."* — William Bruce Cameron

Once a model is trained and validated, you must evaluate its performance. However, picking the wrong evaluation metric can create a false sense of security. In machine learning engineering, **not all errors are created equal**. A model that achieves 99% accuracy on a fraud detection task may be completely useless if it misses the 1% of transactions that are actually fraudulent. This primer teaches you to choose metrics that align with business reality.

---

## 1. Regression Metrics: Penalizing Magnitude

When evaluating continuous predictions (like house prices, delivery times, or energy consumption), regression metrics measure the distance between the prediction ($\hat{y}$) and reality ($y$).

### 1.1 Mean Absolute Error (MAE)

$$\text{MAE} = \frac{1}{n} \sum_{i=1}^{n} |y_i - \hat{y}_i|$$

MAE calculates the average absolute distance between predictions and actuals. It treats a $10 error the exact same way whether it happens 10 times or once, making it robust against outliers.

- **Unit:** Same as the target variable (e.g., dollars, hours).
- **Sensitivity to outliers:** Low—one extreme error doesn't dominate.
- **Best for:** Situations where all errors are equally costly and outliers are genuine anomalies you don't want to over-penalize.

```python
from sklearn.metrics import mean_absolute_error

y_true = [100, 200, 300, 400]
y_pred = [110, 190, 310, 450]

mae = mean_absolute_error(y_true, y_pred)
print(f"MAE: {mae}")  # MAE: 17.5
```

### 1.2 Mean Squared Error (MSE) & Root Mean Squared Error (RMSE)

$$\text{MSE} = \frac{1}{n} \sum_{i=1}^{n} (y_i - \hat{y}_i)^2$$

$$\text{RMSE} = \sqrt{\text{MSE}}$$

MSE squares the errors before averaging. Because errors are squared, missing a prediction by $100 incurs a penalty of 10,000, while a $10 error incurs only 100.

- **Unit:** MSE is in squared units; RMSE returns to original units.
- **Sensitivity to outliers:** High—large errors are heavily penalized.
- **Best for:** Situations where large errors are completely unacceptable (e.g., predicting medication dosages, structural engineering loads).

```python
from sklearn.metrics import mean_squared_error
import numpy as np

mse = mean_squared_error(y_true, y_pred)
rmse = np.sqrt(mse)
print(f"MSE: {mse:.1f}, RMSE: {rmse:.1f}")
```

### 1.3 Mean Absolute Percentage Error (MAPE)

$$\text{MAPE} = \frac{100\%}{n} \sum_{i=1}^{n} \left| \frac{y_i - \hat{y}_i}{y_i} \right|$$

MAPE expresses error as a percentage of the true value, making it intuitive for non-technical stakeholders.

- **Caveat:** Undefined when $y_i = 0$. Use sMAPE (symmetric MAPE) as an alternative.
- **Best for:** Business forecasting where stakeholders think in percentages.

### 1.4 R-squared Score (Coefficient of Determination)

$$R^2 = 1 - \frac{\sum (y_i - \hat{y}_i)^2}{\sum (y_i - \bar{y})^2}$$

R-squared measures the proportion of variance in the target that is predictable from the features. An R-squared of 0.85 means your model explains 85% of the variability.

- **Interpretation:** 1.0 = perfect prediction; 0.0 = no better than predicting the mean; negative = worse than predicting the mean.
- **Caveat:** Can be misleading with non-linear relationships or when comparing models on different datasets.

### 1.5 Choosing a Regression Metric

| Scenario | Recommended Metric | Why |
|----------|-------------------|-----|
| All errors equally bad | MAE | Robust, interpretable |
| Large errors are catastrophic | RMSE | Quadratic penalty |
| Reporting to executives | MAPE | Percentage is intuitive |
| Explaining variance | R-squared | Standard in scientific literature |
| Heavy-tailed error distribution | MAE or Huber | Robust to outliers |

---

## 2. Classification Metrics: The Confusion Matrix

For categorical targets, relying solely on **Accuracy** (total correct predictions divided by total predictions) is dangerous when classes are imbalanced.

Consider a medical dataset where 99% of patients are healthy and 1% have cancer. A model that always predicts "healthy" achieves 99% accuracy while failing to detect a single cancer case. **Accuracy is meaningless without context.**

### 2.1 The Confusion Matrix

To understand true performance, we look at the **Confusion Matrix**, which breaks down predictions into four categories:

|  | Predicted Positive | Predicted Negative |
|--|-------------------|-------------------|
| **Actual Positive** | True Positive (TP) | False Negative (FN) |
| **Actual Negative** | False Positive (FP) | True Negative (TN) |

- **True Positives (TP):** Correctly predicted positive cases.
  - *Example:* Correctly flagged fraudulent transactions.
- **True Negatives (TN):** Correctly predicted negative cases.
  - *Example:* Correctly passed legitimate transactions.
- **False Positives (FP) [Type I Error]:** Incorrectly flagging a negative case as positive.
  - *Example:* Blocking a legitimate credit card purchase (customer inconvenience).
- **False Negatives (FN) [Type II Error]:** Incorrectly missing a positive case.
  - *Example:* Letting a fraudulent transaction slip through (financial loss).

```python
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay
import matplotlib.pyplot as plt

y_true = [0, 1, 0, 0, 1, 1, 0, 1, 0, 1]
y_pred = [0, 1, 0, 1, 1, 0, 0, 1, 0, 1]

cm = confusion_matrix(y_true, y_pred)
print(cm)
# [[4 1]    # 4 TN, 1 FP
#  [1 4]]   # 1 FN, 4 TP
```

### 2.2 Derived Metrics from the Confusion Matrix

**Accuracy:**
$$\text{Accuracy} = \frac{TP + TN}{TP + TN + FP + FN}$$

- Misleading when classes are imbalanced. Only trust accuracy when classes are roughly balanced (40-60% split).

**Precision:**
$$\text{Precision} = \frac{TP}{TP + FP}$$

- Of all positive predictions, how many were actually correct?
- High precision means few false alarms.

**Recall (Sensitivity / True Positive Rate):**
$$\text{Recall} = \frac{TP}{TP + FN}$$

- Of all actual positives, how many did we catch?
- High recall means few missed cases.

**Specificity (True Negative Rate):**
$$\text{Specificity} = \frac{TN}{TN + FP}$$

- Of all actual negatives, how many did we correctly identify?

**F1-Score:**
$$\text{F1} = 2 \cdot \frac{\text{Precision} \cdot \text{Recall}}{\text{Precision} + \text{Recall}}$$

- The harmonic mean of precision and recall. Penalizes extreme imbalances between the two.

```python
from sklearn.metrics import classification_report

print(classification_report(y_true, y_pred, target_names=["Negative", "Positive"]))
```

---

## 3. Precision vs. Recall Trade-Off

Depending on your application, you must choose whether minimizing False Positives or False Negatives is more critical. You cannot maximize both simultaneously—there is an inherent trade-off.

### 3.1 When Precision Matters More

**Question:** Out of all the things the model *claimed* were positive, how many were actually correct?

**Crucial for:** Email spam filters.

> You would rather a spam email slip into your inbox (FN) than have an important work email mistakenly tossed into the spam folder (FP). A false positive here means lost business, missed deadlines, or damaged relationships. The cost of a false alarm exceeds the cost of a missed spam.

**Other precision-critical domains:**
- **Search engines:** Returning irrelevant results (FP) frustrates users.
- **Product recommendations:** Suggesting irrelevant products (FP) degrades trust.
- **Legal document review:** Flagging non-relevant documents (FP) wastes attorney time.

### 3.2 When Recall Matters More

**Question:** Out of all the *actual* positive cases in the dataset, how many did the model successfully find?

**Crucial for:** Medical cancer screening.

> You cannot afford to miss an actual positive case. A false negative means a patient with cancer walks away undiagnosed, potentially delaying life-saving treatment. The cost of missing a true case far exceeds the cost of additional testing for a false alarm.

**Other recall-critical domains:**
- **Fraud detection:** Missing fraud (FN) means direct financial loss.
- **Security screening:** Missing a threat (FN) endangers lives.
- **Disease outbreak detection:** Missing an early cluster (FN) allows exponential spread.

### 3.3 The Precision-Recall Curve

By adjusting the classification threshold (default is 0.5 in binary classification), you can traverse the precision-recall trade-off:

- **Lower threshold (e.g., 0.3):** More predictions are classified as positive -> higher recall, lower precision.
- **Higher threshold (e.g., 0.7):** Fewer predictions are classified as positive -> higher precision, lower recall.

```python
from sklearn.metrics import precision_recall_curve
import matplotlib.pyplot as plt

precision, recall, thresholds = precision_recall_curve(y_true, y_pred_proba)

# Find threshold that gives at least 90% recall
idx = np.where(recall >= 0.90)[0][-1]
optimal_threshold = thresholds[idx]
print(f"Threshold for 90% recall: {optimal_threshold:.3f}")
```

### 3.4 ROC Curve and AUC

The **Receiver Operating Characteristic (ROC)** curve plots the True Positive Rate (recall) against the False Positive Rate ($\frac{FP}{FP + TN}$) at various thresholds.

- **AUC (Area Under the Curve):** A single scalar summarizing ROC performance. AUC = 0.5 means random guessing; AUC = 1.0 means perfect separation.
- **When to use:** Good for balanced datasets or when you care about both classes equally.
- **When NOT to use:** Severely imbalanced datasets—use Precision-Recall AUC instead.

```python
from sklearn.metrics import roc_auc_score, roc_curve

auc = roc_auc_score(y_true, y_pred_proba)
print(f"AUC-ROC: {auc:.3f}")
```

---

## 4. The Business Cost of Error

Metrics are not just numbers—they translate directly into business outcomes. A complete evaluation considers the **asymmetric cost** of different error types.

### 4.1 Cost-Sensitive Learning

Not all misclassifications cost the same. Define a cost matrix:

|  | Predicted Negative | Predicted Positive |
|--|-------------------|-------------------|
| **Actual Negative** | $0 (correct) | $10 (FP: customer support call) |
| **Actual Positive** | $1,000 (FN: fraud loss) | $0 (correct) |

In this scenario, one false negative costs as much as 100 false positives. Your model should be tuned to minimize **expected cost**, not just error rate.

### 4.2 Expected Value Framework

$$\text{Expected Value} = \sum_{i} P(\text{outcome}_i) \times \text{Value}(\text{outcome}_i)$$

By framing model decisions in terms of expected monetary value, you can:
1. Determine the optimal operating threshold.
2. Compare model performance to a baseline (e.g., "do nothing").
3. Justify model deployment costs to stakeholders.

### 4.3 Calibration: When Probabilities Matter

If your model outputs probabilities (e.g., "80% chance of fraud"), those probabilities should be **calibrated**—an 80% prediction should actually be correct 80% of the time.

- **Well-calibrated models** enable threshold optimization and risk-based decision-making.
- **Calibration techniques:** Platt scaling, isotonic regression.

```python
from sklearn.calibration import CalibratedClassifierCV

calibrated = CalibratedClassifierCV(base_estimator=model, method="sigmoid", cv=5)
calibrated.fit(X_train, y_train)
# Now predicted probabilities are trustworthy
```

---

## 5. Summary

| Metric | Type | Best For | Key Insight |
|--------|------|----------|-------------|
| MAE | Regression | Robust to outliers | Average absolute error |
| RMSE | Regression | Penalize large errors | Square root of average squared error |
| R-squared | Regression | Explain variance | Proportion of variance explained |
| Accuracy | Classification | Balanced classes | Overall correctness |
| Precision | Classification | Minimize false alarms | Quality of positive predictions |
| Recall | Classification | Minimize missed cases | Coverage of actual positives |
| F1 | Classification | Balance precision/recall | Harmonic mean |
| AUC-ROC | Classification | Overall separability | Threshold-independent |
| AUC-PR | Classification | Imbalanced data | Focus on positive class |

---

## Further Reading

- Scikit-Learn: [Model Evaluation](https://scikit-learn.org/stable/modules/model_evaluation.html)
- *"Evaluating Machine Learning Models"* — Alice Zheng (O'Reilly)
- *"The Precision-Recall Plot Is More Informative than the ROC Plot When Evaluating Binary Classifiers on Imbalanced Datasets"* — Saito & Rehmsmeier
- Google ML Rules: [Best Practices for ML Engineering](https://developers.google.com/machine-learning/guides/rules-of-ml)

---

*Previous: [Primer 3 — Data Lifecycle & Validation](primer-3-data-lifecycle-validation.md)*  
*Next: [Primer 5 — Production ML Architecture](primer-5-production-architecture.md)*

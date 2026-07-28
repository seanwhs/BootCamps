## Primer 4: Evaluation Metrics & The Cost of Error

Once a model is trained and validated, you must evaluate its performance. However, picking the wrong evaluation metric can create a false sense of security. In machine learning engineering, **not all errors are created equal**.

---

### 1. Regression Metrics: Penalizing Magnitude

When evaluating continuous predictions (like house prices or delivery times), regression metrics measure the distance between the prediction ($\hat{y}$) and reality ($y$).

* **Mean Absolute Error (MAE):** Calculates the average absolute distance between predictions and actuals. It treats a $10 error the exact same way whether it happens 10 times or once, making it robust against outliers.
* **Mean Squared Error (MSE) / Root Mean Squared Error (RMSE):** Squares the errors before averaging. Because errors are squared, missing a prediction by $100 incurs a penalty of $10,000, while a $10 error incurs only $100. RMSE scales this back down to the original unit of measurement, making it ideal when large errors are completely unacceptable.

---

### 2. Classification Metrics: The Confusion Matrix

For categorical targets, relying solely on **Accuracy** (total correct predictions divided by total predictions) is dangerous when classes are imbalanced.

To understand true performance, we look at the **Confusion Matrix**, which breaks down predictions into four categories:

* **True Positives (TP):** Correctly predicted positive cases (e.g., correctly flagged fraud).
* **True Negatives (TN):** Correctly predicted negative cases (e.g., correctly passed legitimate transactions).
* **False Positives (FP) [Type I Error]:** Incorrectly flagging a negative case as positive (e.g., blocking a legitimate credit card purchase).
* **False Negatives (FN) [Type II Error]:** Incorrectly missing a positive case (e.g., letting a fraudulent transaction slip through).

---

### 3. Precision vs. Recall Trade-Off

Depending on your application, you must choose whether minimizing False Positives or False Negatives is more critical:

* **Precision (Minimizing False Positives):** Out of all the things the model *claimed* were positive, how many were actually correct? *(Crucial for email spam filters: you would rather a spam email slip into your inbox than have an important work email mistakenly tossed into the spam folder).*
* **Recall / Sensitivity (Minimizing False Negatives):** Out of all the *actual* positive cases in the dataset, how many did the model successfully find? *(Crucial for medical cancer screening: you cannot afford to miss an actual positive case).*

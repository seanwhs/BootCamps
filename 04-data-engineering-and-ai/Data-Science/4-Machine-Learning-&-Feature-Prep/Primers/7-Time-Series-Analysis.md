# Primer 7: Time Series Analysis

## Overview

This primer provides a comprehensive introduction to time series analysis—a critical skill for many real-world ML applications. Time series data appears everywhere: sales forecasting, financial markets, weather prediction, IoT sensors, and more. Understanding how to handle temporal data is essential for building robust prediction systems.

---

## 1. What is Time Series Data?

### Definition

A time series is a sequence of observations recorded at regular time intervals.

```
┌─────────────────────────────────────────────────────────────────┐
│                    TIME SERIES DATA                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Value                                                         │
│    ▲                                                           │
│    │    ╭──╮           ╭──╮                                   │
│    │   ╱    ╲         ╱    ╲                                  │
│    │  ╱      ╲       ╱      ╲                                 │
│    │ ╱        ╲     ╱        ╲   ╭──╮                       │
│    │╱          ╲   ╱          ╲ ╱    ╲                      │
│    │            ╲ ╱            ╲      ╲                      │
│    │             ╯              ╲      ╲                     │
│    │                             ╲      ╲                    │
│    │                              ╲      ╲                   │
│    │                               ╯       ╯                  │
│    └──────────────────────────────────────────────────────────→ │
│         t₁    t₂    t₃    t₄    t₅    t₆    t₇    Time        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Components of Time Series

| Component | Description | Example |
|-----------|-------------|---------|
| **Trend** | Long-term direction | Increasing sales over years |
| **Seasonality** | Regular patterns | Holiday sales spikes |
| **Cyclical** | Irregular patterns | Economic cycles |
| **Noise** | Random variation | Daily fluctuations |

### Types of Time Series

```
┌─────────────────────────────────────────────────────────────────┐
│                    TYPES OF TIME SERIES                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Univariate          │  Multivariate                           │
│  (Single variable)   │  (Multiple variables)                   │
│                                                                 │
│  Example:            │  Example:                               │
│  Daily temperature   │  Temperature + Humidity + Pressure     │
│                                                                 │
│  Single-Step         │  Multi-Step                             │
│  (Next value)        │  (Next N values)                       │
│                                                                 │
│  Example:            │  Example:                               │
│  Predict tomorrow    │  Predict next 7 days                   │
│                                                                 │
│  Regular             │  Irregular                              │
│  (Equal intervals)   │  (Unequal intervals)                   │
│                                                                 │
│  Example:            │  Example:                               │
│  Hourly readings     │  Event-based logs                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Time Series Decomposition

### Additive vs Multiplicative

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from statsmodels.tsa.seasonal import seasonal_decompose

# Create sample time series
np.random.seed(42)
dates = pd.date_range('2020-01-01', periods=365, freq='D')

# Components
trend = np.linspace(100, 150, 365)  # Upward trend
seasonal = 10 * np.sin(2 * np.pi * np.arange(365) / 30)  # Monthly seasonality
noise = np.random.normal(0, 5, 365)  # Random noise

# Additive series
additive_series = trend + seasonal + noise

# Multiplicative series
multiplicative_series = trend * (1 + seasonal/100) + noise

# Create DataFrame
df = pd.DataFrame({
    'date': dates,
    'additive': additive_series,
    'multiplicative': multiplicative_series
})
df.set_index('date', inplace=True)

# Decompose additive series
result_additive = seasonal_decompose(df['additive'], model='additive', period=30)

# Decompose multiplicative series
result_multiplicative = seasonal_decompose(df['multiplicative'], model='multiplicative', period=30)

# Plot decomposition
fig, axes = plt.subplots(4, 2, figsize=(14, 10))

# Additive decomposition
result_additive.observed.plot(ax=axes[0, 0])
axes[0, 0].set_title('Additive - Observed')
result_additive.trend.plot(ax=axes[1, 0])
axes[1, 0].set_title('Additive - Trend')
result_additive.seasonal.plot(ax=axes[2, 0])
axes[2, 0].set_title('Additive - Seasonal')
result_additive.resid.plot(ax=axes[3, 0])
axes[3, 0].set_title('Additive - Residual')

# Multiplicative decomposition
result_multiplicative.observed.plot(ax=axes[0, 1])
axes[0, 1].set_title('Multiplicative - Observed')
result_multiplicative.trend.plot(ax=axes[1, 1])
axes[1, 1].set_title('Multiplicative - Trend')
result_multiplicative.seasonal.plot(ax=axes[2, 1])
axes[2, 1].set_title('Multiplicative - Seasonal')
result_multiplicative.resid.plot(ax=axes[3, 1])
axes[3, 1].set_title('Multiplicative - Residual')

plt.tight_layout()
plt.show()
```

### Detecting Components

```python
from statsmodels.tsa.stattools import adfuller, acf, pacf

def analyze_components(series):
    """Analyze time series components."""
    
    print("=" * 50)
    print("Time Series Analysis")
    print("=" * 50)
    
    # 1. Stationarity test
    result = adfuller(series)
    print(f"\n1. Stationarity Test (ADF)")
    print(f"   Test Statistic: {result[0]:.4f}")
    print(f"   p-value: {result[1]:.4f}")
    print(f"   Stationary: {'Yes' if result[1] < 0.05 else 'No'}")
    
    # 2. Trend detection
    from scipy import stats
    x = np.arange(len(series))
    slope, intercept, r_value, p_value, std_err = stats.linregress(x, series)
    print(f"\n2. Trend Analysis")
    print(f"   Slope: {slope:.4f}")
    print(f"   Trend: {'Increasing' if slope > 0 else 'Decreasing' if slope < 0 else 'None'}")
    print(f"   R²: {r_value**2:.4f}")
    
    # 3. Seasonality detection
    acf_values = acf(series, nlags=60, fft=False)
    seasonality_period = None
    for lag in range(1, 60):
        if lag > 1 and abs(acf_values[lag]) > 0.3:
            seasonality_period = lag
            break
    
    print(f"\n3. Seasonality Analysis")
    if seasonality_period:
        print(f"   Detected seasonality: {seasonality_period}")
    else:
        print(f"   No strong seasonality detected")
    
    # 4. Noise level
    noise_ratio = np.std(result.resid) / np.std(series) if hasattr(result, 'resid') else 0
    print(f"\n4. Noise Level")
    print(f"   Noise ratio: {noise_ratio:.4f}")
```

---

## 3. Time Series Forecasting

### Classical Methods

#### ARIMA (AutoRegressive Integrated Moving Average)

```python
from statsmodels.tsa.arima.model import ARIMA
from statsmodels.tsa.stattools import adfuller

# Check stationarity
def check_stationarity(series):
    result = adfuller(series)
    return result[1] < 0.05

# Fit ARIMA model
def fit_arima(series, order=(1, 1, 1)):
    """Fit ARIMA model."""
    model = ARIMA(series, order=order)
    fitted_model = model.fit()
    return fitted_model

# Fit model
model = fit_arima(df['additive'], order=(2, 1, 2))

# Make predictions
forecast = model.forecast(steps=30)

# Plot
plt.figure(figsize=(12, 6))
plt.plot(df.index, df['additive'], label='Actual')
plt.plot(pd.date_range(df.index[-1], periods=31, freq='D')[1:], forecast, label='Forecast')
plt.legend()
plt.title('ARIMA Forecast')
plt.show()
```

#### SARIMA (Seasonal ARIMA)

```python
from statsmodels.tsa.statespace.sarimax import SARIMAX

# Fit SARIMA model
sarima_model = SARIMAX(
    df['additive'],
    order=(1, 1, 1),
    seasonal_order=(1, 1, 1, 30),  # Seasonal period = 30
    enforce_stationarity=False,
    enforce_invertibility=False
)
fitted_sarima = sarima_model.fit()

# Forecast
forecast_sarima = fitted_sarima.forecast(steps=30)

# Plot
plt.figure(figsize=(12, 6))
plt.plot(df.index[-100:], df['additive'].iloc[-100:], label='Actual')
plt.plot(pd.date_range(df.index[-1], periods=31, freq='D')[1:], forecast_sarima, label='SARIMA Forecast')
plt.legend()
plt.title('SARIMA Forecast')
plt.show()
```

### Exponential Smoothing

```python
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# Holt-Winters (Triple Exponential Smoothing)
hw_model = ExponentialSmoothing(
    df['additive'],
    trend='add',
    seasonal='add',
    seasonal_periods=30
)
fitted_hw = hw_model.fit()

# Forecast
forecast_hw = fitted_hw.forecast(steps=30)

# Plot
plt.figure(figsize=(12, 6))
plt.plot(df.index[-100:], df['additive'].iloc[-100:], label='Actual')
plt.plot(pd.date_range(df.index[-1], periods=31, freq='D')[1:], forecast_hw, label='Holt-Winters Forecast')
plt.legend()
plt.title('Holt-Winters Forecast')
plt.show()
```

### Machine Learning for Time Series

#### Feature Engineering for Time Series

```python
def create_time_features(df):
    """Create time-based features."""
    df = df.copy()
    df['year'] = df.index.year
    df['month'] = df.index.month
    df['day'] = df.index.day
    df['dayofweek'] = df.index.dayofweek
    df['quarter'] = df.index.quarter
    df['dayofyear'] = df.index.dayofyear
    df['weekofyear'] = df.index.isocalendar().week.astype(int)
    return df

def create_lag_features(df, target, lags=[1, 7, 14, 30]):
    """Create lag features."""
    df = df.copy()
    for lag in lags:
        df[f'{target}_lag_{lag}'] = df[target].shift(lag)
    return df

def create_rolling_features(df, target, windows=[7, 14, 30]):
    """Create rolling statistics."""
    df = df.copy()
    for window in windows:
        df[f'{target}_rolling_mean_{window}'] = df[target].rolling(window).mean()
        df[f'{target}_rolling_std_{window}'] = df[target].rolling(window).std()
        df[f'{target}_rolling_max_{window}'] = df[target].rolling(window).max()
        df[f'{target}_rolling_min_{window}'] = df[target].rolling(window).min()
    return df

# Prepare data for ML
df_ml = create_time_features(df)
df_ml = create_lag_features(df_ml, 'additive')
df_ml = create_rolling_features(df_ml, 'additive')
df_ml = df_ml.dropna()

print(f"Features shape: {df_ml.shape}")
print(f"Features: {df_ml.columns.tolist()}")
```

#### XGBoost for Time Series

```python
import xgboost as xgb
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, mean_squared_error

# Prepare data
X = df_ml.drop(['additive'], axis=1)
y = df_ml['additive']

# Split (ensure chronological order)
train_size = int(0.8 * len(X))
X_train, X_test = X.iloc[:train_size], X.iloc[train_size:]
y_train, y_test = y.iloc[:train_size], y.iloc[train_size:]

# Train XGBoost
xgb_model = xgb.XGBRegressor(
    n_estimators=100,
    learning_rate=0.1,
    max_depth=6,
    random_state=42
)
xgb_model.fit(X_train, y_train)

# Predict
y_pred = xgb_model.predict(X_test)

# Evaluate
mae = mean_absolute_error(y_test, y_pred)
rmse = np.sqrt(mean_squared_error(y_test, y_pred))

print(f"MAE: {mae:.4f}")
print(f"RMSE: {rmse:.4f}")

# Feature importance
importance = pd.DataFrame({
    'feature': X_train.columns,
    'importance': xgb_model.feature_importances_
}).sort_values('importance', ascending=False)

print("\nFeature Importance:")
print(importance.head(10))

# Plot predictions
plt.figure(figsize=(12, 6))
plt.plot(y_test.index, y_test, label='Actual')
plt.plot(y_test.index, y_pred, label='Predicted')
plt.legend()
plt.title('XGBoost Time Series Forecast')
plt.show()
```

---

## 4. Time Series Validation

### Time-Based Split vs Random Split

```python
from sklearn.model_selection import TimeSeriesSplit

# Time series cross-validation
tscv = TimeSeriesSplit(n_splits=5)

# Compare with random split
def compare_splits(X, y):
    """Compare time-based and random splits."""
    print("=" * 50)
    print("Time-Based Split (no leakage)")
    print("=" * 50)
    
    for fold, (train_idx, test_idx) in enumerate(tscv.split(X)):
        train_dates = y.index[train_idx]
        test_dates = y.index[test_idx]
        print(f"Fold {fold+1}: Train {train_dates.min().date()} - {train_dates.max().date()}, "
              f"Test {test_dates.min().date()} - {test_dates.max().date()}")
    
    print("\n" + "=" * 50)
    print("Random Split (potential leakage!)")
    print("=" * 50)
    
    # Random split (wrong for time series)
    from sklearn.model_selection import train_test_split
    for i in range(3):
        train_idx, test_idx = train_test_split(
            range(len(X)), test_size=0.2, random_state=i
        )
        train_dates = y.index[train_idx]
        test_dates = y.index[test_idx]
        print(f"Split {i+1}: Train {train_dates.min().date()} - {train_dates.max().date()}, "
              f"Test {test_dates.min().date()} - {test_dates.max().date()}")
        # Check for temporal overlap
        if train_dates.max() > test_dates.min():
            print("  ⚠️  WARNING: Future data in training set!")

compare_splits(X, y)
```

### Walk-Forward Validation

```python
def walk_forward_validation(data, model, n_steps=5):
    """Perform walk-forward validation."""
    predictions = []
    actuals = []
    
    for i in range(n_steps, len(data)):
        # Split
        train = data.iloc[:i]
        test = data.iloc[i:i+1]
        
        # Train
        X_train = train.drop('additive', axis=1)
        y_train = train['additive']
        
        # Train model
        model.fit(X_train, y_train)
        
        # Predict
        X_test = test.drop('additive', axis=1)
        y_test = test['additive']
        
        pred = model.predict(X_test)[0]
        actual = y_test.iloc[0]
        
        predictions.append(pred)
        actuals.append(actual)
    
    # Calculate metrics
    mae = mean_absolute_error(actuals, predictions)
    rmse = np.sqrt(mean_squared_error(actuals, predictions))
    
    print(f"Walk-Forward Results:")
    print(f"  MAE: {mae:.4f}")
    print(f"  RMSE: {rmse:.4f}")
    
    return predictions, actuals

# Use XGBoost for walk-forward
xgb_wf = xgb.XGBRegressor(n_estimators=50, max_depth=4)
preds, actuals = walk_forward_validation(df_ml, xgb_wf, n_steps=50)
```

---

## 5. Anomaly Detection

```python
from sklearn.ensemble import IsolationForest

def detect_anomalies(series, contamination=0.05):
    """Detect anomalies in time series."""
    # Prepare data
    X = series.values.reshape(-1, 1)
    
    # Fit Isolation Forest
    iso_forest = IsolationForest(contamination=contamination, random_state=42)
    predictions = iso_forest.fit_predict(X)
    
    # -1 = anomaly, 1 = normal
    anomalies = series[predictions == -1]
    
    print(f"Detected {len(anomalies)} anomalies ({len(anomalies)/len(series)*100:.2f}%)")
    
    # Plot
    plt.figure(figsize=(12, 6))
    plt.plot(series.index, series, label='Time Series')
    plt.scatter(anomalies.index, anomalies, color='red', s=50, label='Anomalies')
    plt.legend()
    plt.title('Anomaly Detection')
    plt.show()
    
    return anomalies

# Detect anomalies
anomalies = detect_anomalies(df['additive'])
print("\nAnomaly Timestamps:")
print(anomalies.head())
```

---

## 6. Quick Reference: Time Series

### Key Functions

```python
# Decomposition
from statsmodels.tsa.seasonal import seasonal_decompose
result = seasonal_decompose(series, model='additive', period=30)

# Stationarity test
from statsmodels.tsa.stattools import adfuller
result = adfuller(series)

# ACF/PACF
from statsmodels.tsa.stattools import acf, pacf
acf_values = acf(series, nlags=30)
pacf_values = pacf(series, nlags=30)

# ARIMA
from statsmodels.tsa.arima.model import ARIMA
model = ARIMA(series, order=(p, d, q))

# SARIMA
from statsmodels.tsa.statespace.sarimax import SARIMAX
model = SARIMAX(series, order=(p,d,q), seasonal_order=(P,D,Q,s))

# Exponential Smoothing
from statsmodels.tsa.holtwinters import ExponentialSmoothing
model = ExponentialSmoothing(series, trend='add', seasonal='add', seasonal_periods=s)
```

### Time Series Checklist

```
□ 1. Check frequency and regularity
□ 2. Visualize the series
□ 3. Test for stationarity
□ 4. Decompose into components
□ 5. Detect seasonality
□ 6. Handle missing values
□ 7. Create lag features
□ 8. Create rolling statistics
□ 9. Split chronologically
□ 10. Use appropriate validation
```

---

## Conclusion

This primer covers the essential concepts of time series analysis. You now understand:

1. **Time series components**: Trend, seasonality, cyclical, noise
2. **Decomposition**: Additive and multiplicative models
3. **Forecasting**: ARIMA, SARIMA, exponential smoothing, ML
4. **Feature engineering**: Lags, rolling statistics, time features
5. **Validation**: Time-based splits, walk-forward validation
6. **Anomaly detection**: Isolation Forest, statistical methods

**Next Steps:**
1. Practice with real time series data
2. Experiment with different forecasting methods
3. Implement walk-forward validation
4. Build a time series forecasting pipeline
5. Proceed to Part 1 of the series

---

*End of Primer 7*

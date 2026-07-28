# Primer 26: Time Series Advanced Forecasting

## Overview

This primer provides an in-depth exploration of advanced time series forecasting techniques. Building on the basics covered in Primer 7, this primer covers state-of-the-art methods including Prophet, Neural Prophet, DeepAR, and transformer-based approaches for complex forecasting problems.

---

## 1. Advanced Time Series Concepts

### Time Series Complexity

```
┌─────────────────────────────────────────────────────────────────┐
│              TIME SERIES COMPLEXITY                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Multiple Seasonalities                                         │
│  └── Daily + Weekly + Yearly patterns                         │
│  └── Holiday effects                                           │
│  └── Calendar anomalies                                        │
│                                                                 │
│  Trend Changes                                                  │
│  └── Structural breaks                                         │
│  └── Regime changes                                            │
│  └── External shocks                                           │
│                                                                 │
│  Exogenous Variables                                            │
│  └── Weather                                                   │
│  └── Economic indicators                                       │
│  └── Promotional events                                        │
│                                                                 │
│  Hierarchical Forecasting                                       │
│  └── Product categories                                        │
│  └── Geographic regions                                        │
│  └── Organizational levels                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Advanced Decomposition

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from statsmodels.tsa.seasonal import STL
from statsmodels.tsa.stattools import adfuller
from sklearn.preprocessing import StandardScaler

class AdvancedDecomposer:
    """
    Advanced time series decomposition techniques.
    """
    
    def __init__(self, period=12):
        self.period = period
        self.stl = None
    
    def stl_decompose(self, series, seasonal=7, trend=13, low_pass=21):
        """
        STL decomposition for handling multiple seasonalities.
        
        Args:
            series: Time series
            seasonal: Seasonal smoother length
            trend: Trend smoother length
            low_pass: Low-pass filter length
        
        Returns:
            dict: Decomposition components
        """
        stl = STL(
            series,
            period=self.period,
            seasonal=seasonal,
            trend=trend,
            low_pass=low_pass
        )
        result = stl.fit()
        
        return {
            'observed': result.observed,
            'trend': result.trend,
            'seasonal': result.seasonal,
            'resid': result.resid,
            'weights': result.weights
        }
    
    def mstl_decompose(self, series, periods=[7, 30, 365]):
        """
        Multiple Seasonal-Trend Decomposition.
        
        Args:
            series: Time series
            periods: List of seasonal periods
        
        Returns:
            dict: Decomposition components
        """
        # This is a simplified version of MSTL
        result = {
            'trend': None,
            'seasonal': {},
            'resid': None
        }
        
        # Iteratively remove seasonalities
        residual = series.copy()
        
        for period in periods:
            # STL for each period
            stl = STL(residual, period=period)
            fit = stl.fit()
            result['seasonal'][period] = fit.seasonal
            residual = fit.resid
        
        # Remaining is trend + noise
        result['trend'] = residual
        
        return result
    
    def plot_decomposition(self, result, title="Time Series Decomposition"):
        """Plot decomposition components."""
        fig, axes = plt.subplots(4, 1, figsize=(12, 10))
        
        axes[0].plot(result['observed'], label='Original')
        axes[0].set_title('Observed')
        
        axes[1].plot(result['trend'], label='Trend')
        axes[1].set_title('Trend')
        
        axes[2].plot(result['seasonal'], label='Seasonal')
        axes[2].set_title('Seasonal')
        
        axes[3].plot(result['resid'], label='Residual')
        axes[3].set_title('Residual')
        
        plt.suptitle(title)
        plt.tight_layout()
        return fig
```

---

## 2. Prophet for Time Series

### Facebook Prophet

```python
from prophet import Prophet
from prophet.diagnostics import cross_validation, performance_metrics
import pandas as pd

class ProphetForecaster:
    """
    Advanced time series forecasting with Prophet.
    """
    
    def __init__(self, config=None):
        self.config = config or {}
        self.model = None
    
    def prepare_data(self, df, ds_col='ds', y_col='y'):
        """
        Prepare data for Prophet.
        
        Args:
            df: DataFrame with date and value columns
            ds_col: Date column name
            y_col: Value column name
        
        Returns:
            pd.DataFrame: Prepared data
        """
        data = df.copy()
        data = data.rename(columns={ds_col: 'ds', y_col: 'y'})
        return data
    
    def train(self, df, ds_col='ds', y_col='y', **kwargs):
        """
        Train Prophet model.
        
        Args:
            df: Training data
            ds_col: Date column
            y_col: Value column
            **kwargs: Prophet parameters
        """
        # Prepare data
        data = self.prepare_data(df, ds_col, y_col)
        
        # Create model with custom parameters
        params = {
            'yearly_seasonality': kwargs.get('yearly_seasonality', True),
            'weekly_seasonality': kwargs.get('weekly_seasonality', True),
            'daily_seasonality': kwargs.get('daily_seasonality', False),
            'seasonality_mode': kwargs.get('seasonality_mode', 'additive'),
            'changepoint_prior_scale': kwargs.get('changepoint_prior_scale', 0.05),
            'seasonality_prior_scale': kwargs.get('seasonality_prior_scale', 10.0),
            'holidays_prior_scale': kwargs.get('holidays_prior_scale', 10.0),
            'interval_width': kwargs.get('interval_width', 0.8)
        }
        
        self.model = Prophet(**params)
        
        # Add custom seasonalities
        for period, name in kwargs.get('custom_seasonalities', []):
            self.model.add_seasonality(name=name, period=period, fourier_order=5)
        
        # Add holidays
        if 'holidays' in kwargs:
            self.model.holidays = kwargs['holidays']
        
        # Fit model
        self.model.fit(data)
        
        print(f"Model trained on {len(data)} rows")
        return self.model
    
    def predict(self, periods=30, freq='D'):
        """
        Make predictions.
        
        Args:
            periods: Number of periods to forecast
            freq: Frequency of periods
        
        Returns:
            pd.DataFrame: Predictions
        """
        if self.model is None:
            raise ValueError("Model not trained. Call train() first.")
        
        # Create future dataframe
        future = self.model.make_future_dataframe(periods=periods, freq=freq)
        forecast = self.model.predict(future)
        
        return forecast
    
    def cross_validate(self, horizon='30 days', initial='180 days', period='30 days'):
        """
        Perform cross-validation.
        
        Args:
            horizon: Forecast horizon
            initial: Initial training period
            period: Period between cuts
        
        Returns:
            pd.DataFrame: CV results
        """
        if self.model is None:
            raise ValueError("Model not trained. Call train() first.")
        
        cv_results = cross_validation(
            self.model,
            horizon=horizon,
            initial=initial,
            period=period
        )
        
        metrics = performance_metrics(cv_results)
        
        return cv_results, metrics
    
    def plot_components(self, forecast):
        """Plot Prophet components."""
        if self.model is None:
            raise ValueError("Model not trained.")
        
        return self.model.plot_components(forecast)
    
    def plot_forecast(self, forecast):
        """Plot forecast."""
        if self.model is None:
            raise ValueError("Model not trained.")
        
        return self.model.plot(forecast)

# Example usage
prophet = ProphetForecaster()

# Train with custom parameters
prophet.train(
    df,
    'date',
    'value',
    yearly_seasonality=True,
    weekly_seasonality=True,
    changepoint_prior_scale=0.1,
    custom_seasonalities=[(30, 'monthly'), (7, 'weekly')]
)

# Predict
forecast = prophet.predict(periods=30)

# Cross-validate
cv_results, metrics = prophet.cross_validate(
    horizon='30 days',
    initial='180 days',
    period='15 days'
)
```

---

## 3. Neural Prophet

### Neural Prophet

```python
from neuralprophet import NeuralProphet

class NeuralProphetForecaster:
    """
    Deep learning-based time series forecasting with Neural Prophet.
    """
    
    def __init__(self, config=None):
        self.config = config or {}
        self.model = None
    
    def train(
        self,
        df,
        ds_col='ds',
        y_col='y',
        epochs=100,
        learning_rate=0.01,
        **kwargs
    ):
        """
        Train Neural Prophet model.
        
        Args:
            df: Training data
            ds_col: Date column
            y_col: Value column
            epochs: Number of training epochs
            learning_rate: Learning rate
            **kwargs: Additional parameters
        """
        # Prepare data
        data = df.copy()
        data = data.rename(columns={ds_col: 'ds', y_col: 'y'})
        
        # Create model
        self.model = NeuralProphet(
            n_forecasts=kwargs.get('n_forecasts', 1),
            n_lags=kwargs.get('n_lags', 0),
            n_changepoints=kwargs.get('n_changepoints', 10),
            yearly_seasonality=kwargs.get('yearly_seasonality', True),
            weekly_seasonality=kwargs.get('weekly_seasonality', True),
            daily_seasonality=kwargs.get('daily_seasonality', False),
            learning_rate=learning_rate,
            epochs=epochs,
            trend_reg=kwargs.get('trend_reg', 0.0),
            seasonality_reg=kwargs.get('seasonality_reg', 0.0)
        )
        
        # Add custom seasonalities
        for period, name in kwargs.get('custom_seasonalities', []):
            self.model.add_seasonality(name=name, period=period, fourier_order=5)
        
        # Add lag features
        if kwargs.get('lags', 0) > 0:
            self.model.add_lagged_regressor('y', kwargs['lags'])
        
        # Train
        metrics = self.model.fit(data, freq=kwargs.get('freq', 'D'))
        
        print(f"Model trained for {epochs} epochs")
        return metrics
    
    def predict(self, periods=30):
        """
        Make predictions.
        
        Args:
            periods: Number of periods to forecast
        
        Returns:
            pd.DataFrame: Predictions
        """
        if self.model is None:
            raise ValueError("Model not trained. Call train() first.")
        
        future = self.model.make_future_dataframe(
            df=self.model.history,
            periods=periods,
            n_historic_predictions=True
        )
        
        forecast = self.model.predict(future)
        
        return forecast
    
    def cross_validate(self, horizon, test_size=0.2):
        """
        Perform cross-validation.
        
        Args:
            horizon: Forecast horizon
            test_size: Proportion of test data
        
        Returns:
            dict: CV metrics
        """
        if self.model is None:
            raise ValueError("Model not trained.")
        
        # Split data
        train_end = int(len(self.model.history) * (1 - test_size))
        train = self.model.history.iloc[:train_end]
        test = self.model.history.iloc[train_end:]
        
        # Retrain on train
        self.model.fit(train)
        
        # Predict
        future = self.model.make_future_dataframe(
            df=train,
            periods=horizon,
            n_historic_predictions=False
        )
        
        forecast = self.model.predict(future)
        
        # Calculate metrics
        test_pred = forecast.iloc[-horizon:]
        test_actual = test.iloc[-horizon:]
        
        from sklearn.metrics import mean_absolute_error, mean_squared_error
        
        metrics = {
            'mae': mean_absolute_error(test_actual['y'], test_pred['yhat1']),
            'rmse': np.sqrt(mean_squared_error(test_actual['y'], test_pred['yhat1']))
        }
        
        return metrics
```

---

## 4. DeepAR and Probabilistic Forecasting

### DeepAR with GluonTS

```python
from gluonts.dataset.pandas import PandasDataset
from gluonts.model.deepar import DeepAREstimator
from gluonts.mx.trainer import Trainer
from gluonts.evaluation import Evaluator
import mxnet as mx

class DeepARForecaster:
    """
    DeepAR for probabilistic time series forecasting.
    """
    
    def __init__(self, freq='D', prediction_length=30):
        self.freq = freq
        self.prediction_length = prediction_length
        self.model = None
        self.predictor = None
    
    def train(self, df, target_col='value', **kwargs):
        """
        Train DeepAR model.
        
        Args:
            df: Training data with timestamp index
            target_col: Target column name
            **kwargs: Additional parameters
        """
        # Create dataset
        dataset = PandasDataset.from_long_dataframe(
            df,
            target=target_col,
            item_id='item_id'
        )
        
        # Create estimator
        estimator = DeepAREstimator(
            freq=self.freq,
            prediction_length=self.prediction_length,
            context_length=kwargs.get('context_length', 100),
            num_cells=kwargs.get('num_cells', 40),
            num_layers=kwargs.get('num_layers', 2),
            dropout_rate=kwargs.get('dropout_rate', 0.1),
            trainer=Trainer(
                epochs=kwargs.get('epochs', 100),
                learning_rate=kwargs.get('learning_rate', 1e-3),
                hybridize=False
            )
        )
        
        # Train
        self.model = estimator.train(dataset)
        self.predictor = self.model
    
    def predict(self, df):
        """
        Make probabilistic predictions.
        
        Args:
            df: Data to predict on (same format as training)
        
        Returns:
            dict: Predictions with quantiles
        """
        if self.predictor is None:
            raise ValueError("Model not trained.")
        
        dataset = PandasDataset.from_long_dataframe(
            df,
            target='value',
            item_id='item_id'
        )
        
        # Get predictions
        forecast = next(self.predictor.predict(dataset))
        
        return {
            'mean': forecast.mean,
            'median': forecast.median,
            'quantiles': {
                f'q{q}': forecast.quantile(q/100)
                for q in [10, 20, 50, 80, 90]
            },
            'predictions': forecast.samples
        }
    
    def evaluate(self, df_test):
        """Evaluate model performance."""
        if self.predictor is None:
            raise ValueError("Model not trained.")
        
        dataset = PandasDataset.from_long_dataframe(
            df_test,
            target='value',
            item_id='item_id'
        )
        
        evaluator = Evaluator()
        agg_metrics, _ = evaluator(self.model, dataset)
        
        return agg_metrics
```

---

## 5. Transformer-Based Forecasting

### Informer

```python
import torch
import torch.nn as nn
import numpy as np
from sklearn.preprocessing import MinMaxScaler

class InformerModel(nn.Module):
    """
    Simplified Informer for time series forecasting.
    """
    
    def __init__(
        self,
        input_dim,
        output_dim,
        d_model=512,
        n_heads=8,
        n_layers=3,
        dropout=0.1
    ):
        super().__init__()
        self.input_dim = input_dim
        self.output_dim = output_dim
        self.d_model = d_model
        
        # Embedding
        self.embedding = nn.Linear(input_dim, d_model)
        
        # Positional encoding
        self.pos_encoding = self._create_position_encoding()
        
        # Transformer encoder
        self.transformer = nn.TransformerEncoder(
            nn.TransformerEncoderLayer(
                d_model=d_model,
                nhead=n_heads,
                dropout=dropout,
                batch_first=True
            ),
            num_layers=n_layers
        )
        
        # Output
        self.output = nn.Linear(d_model, output_dim)
    
    def _create_position_encoding(self, max_len=512):
        """Create position encoding."""
        pe = torch.zeros(max_len, self.d_model)
        position = torch.arange(0, max_len, dtype=torch.float).unsqueeze(1)
        div_term = torch.exp(
            torch.arange(0, self.d_model, 2).float() *
            (-np.log(10000.0) / self.d_model)
        )
        pe[:, 0::2] = torch.sin(position * div_term)
        pe[:, 1::2] = torch.cos(position * div_term)
        return pe
    
    def forward(self, x):
        # Embed
        x = self.embedding(x)
        
        # Add position encoding
        seq_len = x.size(1)
        x = x + self.pos_encoding[:seq_len, :]
        
        # Transformer
        x = self.transformer(x)
        
        # Output
        x = self.output(x)
        
        return x

class TransformerForecaster:
    """
    Transformer-based time series forecasting.
    """
    
    def __init__(self, seq_len=30, pred_len=1, d_model=64):
        self.seq_len = seq_len
        self.pred_len = pred_len
        self.d_model = d_model
        self.model = None
        self.scaler = MinMaxScaler()
    
    def prepare_data(self, series):
        """
        Prepare data for transformer.
        
        Args:
            series: Time series data
        
        Returns:
            tuple: (X, y) input-output pairs
        """
        # Scale data
        scaled = self.scaler.fit_transform(series.reshape(-1, 1))
        
        X, y = [], []
        for i in range(len(scaled) - self.seq_len - self.pred_len + 1):
            X.append(scaled[i:i+self.seq_len])
            y.append(scaled[i+self.seq_len:i+self.seq_len+self.pred_len])
        
        return np.array(X), np.array(y)
    
    def train(self, X, y, epochs=100, lr=0.001, batch_size=32):
        """
        Train transformer model.
        
        Args:
            X: Input sequences
            y: Target sequences
            epochs: Training epochs
            lr: Learning rate
            batch_size: Batch size
        """
        # Convert to tensor
        X = torch.FloatTensor(X)
        y = torch.FloatTensor(y)
        
        # Create dataset
        dataset = torch.utils.data.TensorDataset(X, y)
        dataloader = torch.utils.data.DataLoader(
            dataset, batch_size=batch_size, shuffle=True
        )
        
        # Create model
        self.model = InformerModel(
            input_dim=1,
            output_dim=self.pred_len,
            d_model=self.d_model
        )
        
        # Training
        optimizer = torch.optim.Adam(self.model.parameters(), lr=lr)
        criterion = nn.MSELoss()
        
        for epoch in range(epochs):
            total_loss = 0
            for batch_x, batch_y in dataloader:
                optimizer.zero_grad()
                
                # Forward pass
                pred = self.model(batch_x)
                loss = criterion(pred, batch_y)
                
                loss.backward()
                optimizer.step()
                
                total_loss += loss.item()
            
            if (epoch + 1) % 10 == 0:
                print(f"Epoch {epoch+1}, Loss: {total_loss/len(dataloader):.4f}")
    
    def predict(self, series, steps=1):
        """
        Make predictions.
        
        Args:
            series: Input series
            steps: Number of steps to forecast
        
        Returns:
            np.ndarray: Predictions
        """
        if self.model is None:
            raise ValueError("Model not trained.")
        
        self.model.eval()
        
        predictions = []
        current = series.copy()
        
        for _ in range(steps):
            # Prepare input
            scaled = self.scaler.transform(current[-self.seq_len:].reshape(-1, 1))
            input_tensor = torch.FloatTensor(scaled).unsqueeze(0)
            
            # Predict
            with torch.no_grad():
                pred = self.model(input_tensor)
            
            # Inverse transform
            pred_scaled = pred.numpy().flatten()
            pred_original = self.scaler.inverse_transform(pred_scaled.reshape(-1, 1))
            
            predictions.append(pred_original[0][0])
            
            # Update current
            current = np.append(current, pred_original[0][0])
        
        return np.array(predictions)
```

---

## Quick Reference: Advanced Forecasting

### Model Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│  MODEL        │ SEASONALITY │ EXOGENOUS │ INTERPRETABLE      │
├───────────────┼─────────────┼───────────┼────────────────────┤
│  Prophet      │ Multiple    │ Yes       │ High               │
│  NeuralProphet│ Multiple    │ Yes       │ Medium             │
│  DeepAR       │ Learned     │ Yes       │ Low                │
│  Transformer  │ Learned     │ Yes       │ Low                │
│  LSTM         │ Learned     │ Yes       │ Low                │
│  ARIMA        │ Single      │ No        │ High               │
└─────────────────────────────────────────────────────────────────┘
```

### Forecasting Best Practices

```
┌─────────────────────────────────────────────────────────────────┐
│  PRACTICE                │ IMPORTANCE                          │
├──────────────────────────┼─────────────────────────────────────┤
│  Multiple seasonalities  │ High for daily/hourly data         │
│  Holiday effects         │ Medium for retail/sales           │
│  Exogenous variables     │ High for business forecasting     │
│  Cross-validation        │ Essential for model selection     │
│  Ensemble methods        │ Medium for robustness            │
│  Uncertainty estimation  │ High for decision making         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers advanced time series forecasting techniques. You now understand:

1. **Advanced decomposition**: STL, MSTL
2. **Prophet**: Facebook's forecasting tool
3. **Neural Prophet**: Deep learning with Prophet
4. **DeepAR**: Probabilistic forecasting
5. **Transformer-based**: Modern approaches

**Next Steps:**
1. Practice with Prophet on real data
2. Experiment with Neural Prophet
3. Try DeepAR for uncertainty
4. Explore transformer-based forecasting
5. Proceed to Part 1 of the series

---

*End of Primer 26*

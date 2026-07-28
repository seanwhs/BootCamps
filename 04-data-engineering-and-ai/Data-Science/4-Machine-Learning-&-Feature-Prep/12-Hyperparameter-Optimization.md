# Module 4.3: Model Validation & Hyperparameter Tuning

## Part 12: Hyperparameter Optimization

Welcome to the final part of Module 4.3! We've built models, validated them, and evaluated their performance. Now we tackle the art and science of hyperparameter optimization—finding the perfect settings for our models to maximize performance. This is where we squeeze every ounce of predictive power from our algorithms.

### The Target: A Complete Hyperparameter Optimization System

By the end of this part, you'll have:
1. Grid Search for exhaustive parameter exploration
2. Random Search for efficient exploration
3. Bayesian Optimization with Optuna for intelligent search
4. Automated hyperparameter tuning with pruning
5. Integration with our validation pipeline
6. Visualization of optimization results
7. Hyperparameter importance analysis
8. Model selection and comparison

### The Concept: Understanding Hyperparameter Optimization

Think of hyperparameter optimization like tuning a race car:

**Grid Search**: Like trying every possible combination of tire pressure, fuel mixture, and suspension settings from a preset list. Comprehensive but time-consuming.

**Random Search**: Like randomly trying combinations. Surprisingly efficient because you cover more of the space.

**Bayesian Optimization**: Like having a race engineer who learns from each test and suggests what to try next. Efficient and intelligent.

**The Problem**: Models have dozens of hyperparameters, each with a range of possible values. The search space is enormous. We need smart strategies to find the best combination.

### The Implementation: Building Our Optimization System

#### Step 1: Grid and Random Search

**File:** `src/validation/tuning.py`
**Path:** `ml-pipeline-project/src/validation/tuning.py`

```python
"""
Hyperparameter optimization with Grid Search, Random Search, and Bayesian Optimization.
"""

from typing import Dict, List, Optional, Union, Any, Callable, Tuple
from pathlib import Path
import time
import numpy as np
import pandas as pd
from loguru import logger
from sklearn.model_selection import GridSearchCV, RandomizedSearchCV
from sklearn.base import BaseEstimator
from sklearn.metrics import make_scorer
import joblib
import warnings

warnings.filterwarnings("ignore", category=UserWarning)

class GridSearchOptimizer:
    """
    Exhaustive Grid Search for hyperparameter optimization.
    
    This class performs systematic search over specified parameter
    values with cross-validation.
    
    Example:
        >>> optimizer = GridSearchOptimizer(
        ...     param_grid={
        ...         'n_estimators': [50, 100, 200],
        ...         'max_depth': [3, 5, 7],
        ...         'learning_rate': [0.01, 0.1, 0.3]
        ...     },
        ...     cv=5,
        ...     scoring='accuracy'
        ... )
        >>> best_params = optimizer.optimize(model, X, y)
    """
    
    def __init__(
        self,
        param_grid: Dict[str, List[Any]],
        cv: int = 5,
        scoring: Optional[Union[str, Callable]] = None,
        n_jobs: int = -1,
        verbose: int = 1,
        random_state: int = 42
    ):
        """
        Initialize the grid search optimizer.
        
        Args:
            param_grid: Dictionary of parameter names to lists of values
            cv: Number of cross-validation folds
            scoring: Scoring metric
            n_jobs: Number of parallel jobs
            verbose: Verbosity level
            random_state: Random seed
        """
        self.param_grid = param_grid
        self.cv = cv
        self.scoring = scoring
        self.n_jobs = n_jobs
        self.verbose = verbose
        self.random_state = random_state
        
        self._grid_search = None
        self._results = None
        
        logger.info(f"GridSearchOptimizer initialized with {len(param_grid)} parameters")
        logger.info(f"Total combinations: {self._count_combinations()}")
    
    def optimize(
        self,
        model: BaseEstimator,
        X: Union[pd.DataFrame, np.ndarray],
        y: Union[pd.Series, np.ndarray],
        fit_params: Optional[Dict] = None
    ) -> Dict[str, Any]:
        """
        Perform grid search optimization.
        
        Args:
            model: Scikit-learn compatible model
            X: Feature matrix
            y: Target vector
            fit_params: Additional fitting parameters
            
        Returns:
            Dict: Best parameters and results
        """
        logger.info("Starting grid search optimization")
        start_time = time.time()
        
        # Create grid search
        self._grid_search = GridSearchCV(
            estimator=model,
            param_grid=self.param_grid,
            cv=self.cv,
            scoring=self.scoring,
            n_jobs=self.n_jobs,
            verbose=self.verbose,
            return_train_score=True
        )
        
        # Perform search
        self._grid_search.fit(X, y, **(fit_params or {}))
        
        # Store results
        self._results = {
            'best_params': self._grid_search.best_params_,
            'best_score': self._grid_search.best_score_,
            'best_estimator': self._grid_search.best_estimator_,
            'cv_results': self._grid_search.cv_results_,
            'n_combinations': len(self._grid_search.cv_results_['params']),
            'time_seconds': time.time() - start_time
        }
        
        logger.info(f"Grid search completed in {self._results['time_seconds']:.2f}s")
        logger.info(f"Best score: {self._results['best_score']:.4f}")
        logger.info(f"Best params: {self._results['best_params']}")
        
        return self._results
    
    def get_results_dataframe(self) -> pd.DataFrame:
        """
        Get CV results as a DataFrame.
        
        Returns:
            pd.DataFrame: Results sorted by performance
        """
        if self._grid_search is None:
            raise ValueError("No results available. Run optimize() first.")
        
        results = pd.DataFrame(self._grid_search.cv_results_)
        
        # Sort by mean test score
        results = results.sort_values('mean_test_score', ascending=False)
        
        return results
    
    def plot_results(
        self,
        param_name: Optional[str] = None,
        figsize: Tuple[int, int] = (12, 6)
    ):
        """
        Plot optimization results.
        
        Args:
            param_name: Parameter to plot (None for all)
            figsize: Figure size
            
        Returns:
            matplotlib.figure.Figure: The created figure
        """
        import matplotlib.pyplot as plt
        
        if self._grid_search is None:
            raise ValueError("No results available. Run optimize() first.")
        
        results = self.get_results_dataframe()
        
        if param_name is not None and param_name in results.columns:
            # Plot single parameter
            fig, ax = plt.subplots(figsize=figsize)
            
            param_values = results[param_name].astype(str)
            test_scores = results['mean_test_score']
            train_scores = results['mean_train_score']
            
            x = np.arange(len(param_values))
            width = 0.35
            
            ax.bar(x - width/2, test_scores, width, label='Test Score', color='steelblue')
            ax.bar(x + width/2, train_scores, width, label='Train Score', color='coral')
            
            ax.set_xlabel(param_name)
            ax.set_ylabel('Score')
            ax.set_title(f'Grid Search Results for {param_name}')
            ax.set_xticks(x)
            ax.set_xticklabels(param_values, rotation=45)
            ax.legend()
            ax.grid(True, alpha=0.3)
            
            plt.tight_layout()
            
        else:
            # Plot parameter importance heatmap
            param_names = [col for col in results.columns if col.startswith('param_')]
            if len(param_names) >= 2:
                fig, axes = plt.subplots(1, len(param_names)-1, figsize=figsize)
                if len(param_names)-1 == 1:
                    axes = [axes]
                
                for idx, name1 in enumerate(param_names[:-1]):
                    for name2 in param_names[idx+1:]:
                        # Pivot table
                        pivot = results.pivot_table(
                            values='mean_test_score',
                            index=name1,
                            columns=name2,
                            aggfunc='mean'
                        )
                        
                        ax = axes[idx]
                        im = ax.imshow(pivot.values, cmap='viridis')
                        ax.set_xticks(range(len(pivot.columns)))
                        ax.set_xticklabels(pivot.columns, rotation=45)
                        ax.set_yticks(range(len(pivot.index)))
                        ax.set_yticklabels(pivot.index)
                        ax.set_xlabel(name2.replace('param_', ''))
                        ax.set_ylabel(name1.replace('param_', ''))
                        ax.set_title(f'{name1} vs {name2}')
                        
                        plt.colorbar(im, ax=ax)
            
            plt.tight_layout()
        
        return fig
    
    def _count_combinations(self) -> int:
        """Count total parameter combinations."""
        count = 1
        for values in self.param_grid.values():
            count *= len(values)
        return count

class RandomSearchOptimizer:
    """
    Random Search for hyperparameter optimization.
    
    More efficient than Grid Search for high-dimensional spaces.
    """
    
    def __init__(
        self,
        param_distributions: Dict[str, Any],
        n_iter: int = 100,
        cv: int = 5,
        scoring: Optional[Union[str, Callable]] = None,
        n_jobs: int = -1,
        verbose: int = 1,
        random_state: int = 42
    ):
        """
        Initialize the random search optimizer.
        
        Args:
            param_distributions: Parameter distributions
            n_iter: Number of iterations
            cv: Number of cross-validation folds
            scoring: Scoring metric
            n_jobs: Number of parallel jobs
            verbose: Verbosity level
            random_state: Random seed
        """
        self.param_distributions = param_distributions
        self.n_iter = n_iter
        self.cv = cv
        self.scoring = scoring
        self.n_jobs = n_jobs
        self.verbose = verbose
        self.random_state = random_state
        
        self._random_search = None
        self._results = None
        
        logger.info(f"RandomSearchOptimizer initialized with {n_iter} iterations")
    
    def optimize(
        self,
        model: BaseEstimator,
        X: Union[pd.DataFrame, np.ndarray],
        y: Union[pd.Series, np.ndarray],
        fit_params: Optional[Dict] = None
    ) -> Dict[str, Any]:
        """
        Perform random search optimization.
        
        Args:
            model: Scikit-learn compatible model
            X: Feature matrix
            y: Target vector
            fit_params: Additional fitting parameters
            
        Returns:
            Dict: Best parameters and results
        """
        logger.info("Starting random search optimization")
        start_time = time.time()
        
        # Create random search
        self._random_search = RandomizedSearchCV(
            estimator=model,
            param_distributions=self.param_distributions,
            n_iter=self.n_iter,
            cv=self.cv,
            scoring=self.scoring,
            n_jobs=self.n_jobs,
            verbose=self.verbose,
            random_state=self.random_state,
            return_train_score=True
        )
        
        # Perform search
        self._random_search.fit(X, y, **(fit_params or {}))
        
        # Store results
        self._results = {
            'best_params': self._random_search.best_params_,
            'best_score': self._random_search.best_score_,
            'best_estimator': self._random_search.best_estimator_,
            'cv_results': self._random_search.cv_results_,
            'n_iterations': self.n_iter,
            'time_seconds': time.time() - start_time
        }
        
        logger.info(f"Random search completed in {self._results['time_seconds']:.2f}s")
        logger.info(f"Best score: {self._results['best_score']:.4f}")
        logger.info(f"Best params: {self._results['best_params']}")
        
        return self._results
    
    def get_results_dataframe(self) -> pd.DataFrame:
        """
        Get CV results as a DataFrame.
        
        Returns:
            pd.DataFrame: Results sorted by performance
        """
        if self._random_search is None:
            raise ValueError("No results available. Run optimize() first.")
        
        results = pd.DataFrame(self._random_search.cv_results_)
        results = results.sort_values('mean_test_score', ascending=False)
        
        return results
```

#### Step 2: Bayesian Optimization with Optuna

**File:** `src/validation/optuna_tuner.py`
**Path:** `ml-pipeline-project/src/validation/optuna_tuner.py`

```python
"""
Bayesian hyperparameter optimization with Optuna.

This module provides advanced hyperparameter optimization using:
- Bayesian optimization for intelligent search
- Automated pruning of poor trials
- Parallel execution
- Visualization of optimization process
"""

from typing import Dict, List, Optional, Union, Any, Callable, Tuple
from pathlib import Path
import time
import numpy as np
import pandas as pd
from loguru import logger
from sklearn.base import BaseEstimator
from sklearn.model_selection import cross_val_score, StratifiedKFold
from sklearn.metrics import make_scorer
import joblib
import warnings

warnings.filterwarnings("ignore", category=UserWarning)

try:
    import optuna
    from optuna.pruners import MedianPruner
    from optuna.samplers import TPESampler
    from optuna.visualization import plot_optimization_history, plot_param_importances
    from optuna.visualization import plot_parallel_coordinate, plot_contour
except ImportError:
    raise ImportError("Optuna not installed. Install with: pip install optuna")

class OptunaTuner:
    """
    Bayesian hyperparameter optimization with Optuna.
    
    This class provides advanced hyperparameter optimization with:
    - Intelligent parameter search using TPE sampler
    - Automatic pruning of unpromising trials
    - Parallel execution support
    - Comprehensive visualization
    
    Example:
        >>> tuner = OptunaTuner(
        ...     objective_function=my_objective,
        ...     n_trials=100,
        ...     direction='maximize'
        ... )
        >>> best_params = tuner.optimize()
        >>> tuner.plot_optimization()
    """
    
    def __init__(
        self,
        objective_function: Optional[Callable] = None,
        param_space: Optional[Dict[str, Any]] = None,
        n_trials: int = 100,
        direction: str = 'maximize',
        cv: int = 5,
        scoring: Optional[Union[str, Callable]] = None,
        sampler: str = 'tpe',
        pruner: str = 'median',
        timeout: Optional[int] = None,
        random_state: int = 42,
        study_name: Optional[str] = None,
        storage: Optional[str] = None,
        n_jobs: int = -1
    ):
        """
        Initialize the Optuna tuner.
        
        Args:
            objective_function: Objective function to optimize
            param_space: Parameter space definition
            n_trials: Number of trials
            direction: Optimization direction ('maximize' or 'minimize')
            cv: Number of cross-validation folds
            scoring: Scoring metric
            sampler: Sampler type ('tpe', 'random', 'grid')
            pruner: Pruner type ('median', 'none')
            timeout: Time limit in seconds
            random_state: Random seed
            study_name: Name of the study
            storage: Storage URL for study persistence
            n_jobs: Number of parallel jobs
        """
        self.objective_function = objective_function
        self.param_space = param_space or {}
        self.n_trials = n_trials
        self.direction = direction
        self.cv = cv
        self.scoring = scoring
        self.sampler = sampler
        self.pruner = pruner
        self.timeout = timeout
        self.random_state = random_state
        self.study_name = study_name
        self.storage = storage
        self.n_jobs = n_jobs
        
        self._study = None
        self._best_params = None
        self._best_value = None
        
        logger.info(f"OptunaTuner initialized with {n_trials} trials")
    
    def optimize(
        self,
        X: Optional[Union[pd.DataFrame, np.ndarray]] = None,
        y: Optional[Union[pd.Series, np.ndarray]] = None,
        model: Optional[BaseEstimator] = None,
        fit_params: Optional[Dict] = None
    ) -> Dict[str, Any]:
        """
        Run the optimization.
        
        Args:
            X: Feature matrix (if not using pre-defined objective)
            y: Target vector (if not using pre-defined objective)
            model: Model to tune (if not using pre-defined objective)
            fit_params: Additional fitting parameters
            
        Returns:
            Dict: Best parameters and results
        """
        # Create objective function if not provided
        if self.objective_function is None:
            if X is None or y is None or model is None:
                raise ValueError("X, y, and model are required when objective_function is not provided")
            
            self.objective_function = self._create_objective(X, y, model, fit_params)
        
        # Create sampler
        if self.sampler == 'tpe':
            sampler = TPESampler(seed=self.random_state)
        elif self.sampler == 'random':
            sampler = optuna.samplers.RandomSampler(seed=self.random_state)
        elif self.sampler == 'grid':
            sampler = optuna.samplers.GridSampler(self.param_space)
        else:
            sampler = TPESampler(seed=self.random_state)
        
        # Create pruner
        if self.pruner == 'median':
            pruner = MedianPruner(
                n_startup_trials=5,
                n_warmup_steps=10,
                interval_steps=1
            )
        else:
            pruner = optuna.pruners.NopPruner()
        
        # Create study
        self._study = optuna.create_study(
            direction=self.direction,
            sampler=sampler,
            pruner=pruner,
            study_name=self.study_name,
            storage=self.storage,
            load_if_exists=True
        )
        
        # Run optimization
        logger.info("Starting Bayesian optimization")
        start_time = time.time()
        
        self._study.optimize(
            self.objective_function,
            n_trials=self.n_trials,
            timeout=self.timeout,
            show_progress_bar=True
        )
        
        # Get results
        self._best_params = self._study.best_params
        self._best_value = self._study.best_value
        
        results = {
            'best_params': self._best_params,
            'best_value': self._best_value,
            'n_trials': len(self._study.trials),
            'time_seconds': time.time() - start_time,
            'study': self._study
        }
        
        logger.info(f"Optimization completed in {results['time_seconds']:.2f}s")
        logger.info(f"Best value: {self._best_value:.4f}")
        logger.info(f"Best params: {self._best_params}")
        
        return results
    
    def _create_objective(self, X, y, model, fit_params):
        """
        Create an objective function for Optuna.
        
        Args:
            X: Feature matrix
            y: Target vector
            model: Scikit-learn compatible model
            fit_params: Additional fitting parameters
            
        Returns:
            Callable: Objective function
        """
        def objective(trial):
            # Get parameter suggestions
            params = {}
            for param_name, param_range in self.param_space.items():
                if isinstance(param_range, list):
                    params[param_name] = trial.suggest_categorical(param_name, param_range)
                elif isinstance(param_range, tuple):
                    if len(param_range) == 2:
                        low, high = param_range
                        if isinstance(low, int) and isinstance(high, int):
                            params[param_name] = trial.suggest_int(param_name, low, high)
                        else:
                            params[param_name] = trial.suggest_float(param_name, low, high)
                    else:
                        params[param_name] = param_range[0]
            
            # Update model parameters
            model.set_params(**params)
            
            # Perform cross-validation
            try:
                cv = StratifiedKFold(n_splits=self.cv, shuffle=True, random_state=self.random_state)
                scores = cross_val_score(model, X, y, cv=cv, scoring=self.scoring)
                mean_score = np.mean(scores)
                
                # Return score (Optuna handles direction)
                return mean_score
                
            except Exception as e:
                logger.debug(f"Trial failed: {str(e)}")
                return float('-inf') if self.direction == 'maximize' else float('inf')
        
        return objective
    
    def get_trials_dataframe(self) -> pd.DataFrame:
        """
        Get trials as a DataFrame.
        
        Returns:
            pd.DataFrame: Trial results
        """
        if self._study is None:
            raise ValueError("No results available. Run optimize() first.")
        
        trials_df = self._study.trials_dataframe()
        return trials_df
    
    def plot_optimization_history(self, figsize: Tuple[int, int] = (10, 6)):
        """
        Plot optimization history.
        
        Args:
            figsize: Figure size
            
        Returns:
            plotly.graph_objects.Figure: The created figure
        """
        if self._study is None:
            raise ValueError("No results available. Run optimize() first.")
        
        fig = plot_optimization_history(self._study)
        fig.update_layout(
            title='Optimization History',
            xaxis_title='Trial',
            yaxis_title='Objective Value',
            width=figsize[0]*100,
            height=figsize[1]*100
        )
        return fig
    
    def plot_param_importances(self, figsize: Tuple[int, int] = (10, 6)):
        """
        Plot parameter importances.
        
        Args:
            figsize: Figure size
            
        Returns:
            plotly.graph_objects.Figure: The created figure
        """
        if self._study is None:
            raise ValueError("No results available. Run optimize() first.")
        
        fig = plot_param_importances(self._study)
        fig.update_layout(
            title='Hyperparameter Importance',
            width=figsize[0]*100,
            height=figsize[1]*100
        )
        return fig
    
    def plot_parallel_coordinate(self, figsize: Tuple[int, int] = (12, 8)):
        """
        Plot parallel coordinate visualization.
        
        Args:
            figsize: Figure size
            
        Returns:
            plotly.graph_objects.Figure: The created figure
        """
        if self._study is None:
            raise ValueError("No results available. Run optimize() first.")
        
        fig = plot_parallel_coordinate(self._study)
        fig.update_layout(
            title='Parallel Coordinate Plot',
            width=figsize[0]*100,
            height=figsize[1]*100
        )
        return fig
    
    def plot_contour(self, figsize: Tuple[int, int] = (10, 8)):
        """
        Plot contour plot of parameter interactions.
        
        Args:
            figsize: Figure size
            
        Returns:
            plotly.graph_objects.Figure: The created figure
        """
        if self._study is None:
            raise ValueError("No results available. Run optimize() first.")
        
        fig = plot_contour(self._study)
        fig.update_layout(
            title='Parameter Interaction Contour',
            width=figsize[0]*100,
            height=figsize[1]*100
        )
        return fig
    
    def save_study(self, filepath: Path):
        """
        Save the study to disk.
        
        Args:
            filepath: Path to save the study
        """
        filepath = Path(filepath)
        filepath.parent.mkdir(parents=True, exist_ok=True)
        
        if self._study is None:
            raise ValueError("No study available. Run optimize() first.")
        
        joblib.dump({
            'study': self._study,
            'best_params': self._best_params,
            'best_value': self._best_value
        }, filepath)
        
        logger.info(f"Study saved to: {filepath}")
    
    def load_study(self, filepath: Path):
        """
        Load a saved study.
        
        Args:
            filepath: Path to the saved study
        """
        filepath = Path(filepath)
        if not filepath.exists():
            raise FileNotFoundError(f"Study not found: {filepath}")
        
        data = joblib.load(filepath)
        self._study = data['study']
        self._best_params = data['best_params']
        self._best_value = data['best_value']
        
        logger.info(f"Study loaded from: {filepath}")

class AutomatedTuner:
    """
    Automated hyperparameter tuning with multiple methods.
    
    This class automatically selects and applies the best tuning method.
    """
    
    def __init__(
        self,
        method: str = 'bayesian',
        n_trials: int = 100,
        cv: int = 5,
        scoring: Optional[Union[str, Callable]] = None,
        random_state: int = 42
    ):
        """
        Initialize the automated tuner.
        
        Args:
            method: Tuning method ('grid', 'random', 'bayesian')
            n_trials: Number of trials/iterations
            cv: Number of cross-validation folds
            scoring: Scoring metric
            random_state: Random seed
        """
        self.method = method
        self.n_trials = n_trials
        self.cv = cv
        self.scoring = scoring
        self.random_state = random_state
        
        self._tuner = None
        self._results = None
        
        logger.info(f"AutomatedTuner initialized with method={method}")
    
    def tune(
        self,
        model: BaseEstimator,
        X: Union[pd.DataFrame, np.ndarray],
        y: Union[pd.Series, np.ndarray],
        param_space: Dict[str, Any],
        fit_params: Optional[Dict] = None
    ) -> Dict[str, Any]:
        """
        Run hyperparameter tuning with automatic method selection.
        
        Args:
            model: Scikit-learn compatible model
            X: Feature matrix
            y: Target vector
            param_space: Parameter space to search
            fit_params: Additional fitting parameters
            
        Returns:
            Dict: Best parameters and results
        """
        # Determine the best method based on parameter space size
        total_combinations = self._count_combinations(param_space)
        
        if self.method == 'auto':
            if total_combinations <= 20:
                method = 'grid'
                logger.info(f"Auto-selected Grid Search ({total_combinations} combinations)")
            elif total_combinations <= 100:
                method = 'random'
                logger.info(f"Auto-selected Random Search ({total_combinations} combinations)")
            else:
                method = 'bayesian'
                logger.info(f"Auto-selected Bayesian Optimization ({total_combinations} combinations)")
        else:
            method = self.method
        
        # Create and run the appropriate tuner
        if method == 'grid':
            tuner = GridSearchOptimizer(
                param_grid=param_space,
                cv=self.cv,
                scoring=self.scoring,
                random_state=self.random_state
            )
            results = tuner.optimize(model, X, y, fit_params)
            
        elif method == 'random':
            tuner = RandomSearchOptimizer(
                param_distributions=param_space,
                n_iter=min(self.n_trials, 100),
                cv=self.cv,
                scoring=self.scoring,
                random_state=self.random_state
            )
            results = tuner.optimize(model, X, y, fit_params)
            
        elif method == 'bayesian':
            tuner = OptunaTuner(
                param_space=param_space,
                n_trials=self.n_trials,
                cv=self.cv,
                scoring=self.scoring,
                random_state=self.random_state
            )
            results = tuner.optimize(X=X, y=y, model=model, fit_params=fit_params)
            
        else:
            raise ValueError(f"Unknown method: {method}")
        
        self._tuner = tuner
        self._results = results
        self._results['method'] = method
        
        return results
    
    def _count_combinations(self, param_space: Dict[str, Any]) -> int:
        """Count total parameter combinations."""
        count = 1
        for values in param_space.values():
            if isinstance(values, list):
                count *= len(values)
            elif isinstance(values, tuple):
                # For continuous parameters, estimate
                count *= 10
        return count
    
    def get_results(self) -> Dict[str, Any]:
        """Get tuning results."""
        return self._results
    
    def get_best_params(self) -> Dict[str, Any]:
        """Get best parameters."""
        if self._results is None:
            return {}
        return self._results.get('best_params', {})
    
    def get_best_score(self) -> float:
        """Get best score."""
        if self._results is None:
            return 0.0
        return self._results.get('best_score', 0.0)
```

### The Verification: Testing Our Hyperparameter Optimization

#### Test 1: Grid and Random Search

```bash
cat > test_grid_random_search.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from src.validation.tuning import GridSearchOptimizer, RandomSearchOptimizer

# Create dataset
X, y = make_classification(
    n_samples=500,
    n_features=10,
    n_informative=5,
    n_classes=2,
    random_state=42
)

X = pd.DataFrame(X, columns=[f'feature_{i}' for i in range(X.shape[1])])

print(f"Data shape: {X.shape}")

# Grid Search
print("\n" + "="*60)
print("Grid Search")
print("="*60)

param_grid = {
    'n_estimators': [50, 100, 150],
    'max_depth': [3, 5, 7],
    'min_samples_split': [2, 5, 10]
}

grid_optimizer = GridSearchOptimizer(
    param_grid=param_grid,
    cv=3,
    scoring='accuracy',
    verbose=0
)

results = grid_optimizer.optimize(RandomForestClassifier(random_state=42), X, y)

print(f"Best score: {results['best_score']:.4f}")
print(f"Best params: {results['best_params']}")
print(f"Time: {results['time_seconds']:.2f}s")

# Get results DataFrame
results_df = grid_optimizer.get_results_dataframe()
print(f"\nTop 5 combinations:")
print(results_df[['param_n_estimators', 'param_max_depth', 'param_min_samples_split', 'mean_test_score']].head())

# Random Search
print("\n" + "="*60)
print("Random Search")
print("="*60)

param_dist = {
    'n_estimators': list(range(50, 201, 10)),
    'max_depth': list(range(3, 11)),
    'min_samples_split': list(range(2, 11)),
    'min_samples_leaf': list(range(1, 5))
}

random_optimizer = RandomSearchOptimizer(
    param_distributions=param_dist,
    n_iter=30,
    cv=3,
    scoring='accuracy',
    random_state=42,
    verbose=0
)

results = random_optimizer.optimize(RandomForestClassifier(random_state=42), X, y)

print(f"Best score: {results['best_score']:.4f}")
print(f"Best params: {results['best_params']}")
print(f"Time: {results['time_seconds']:.2f}s")

print("\n✅ Grid and Random Search test complete!")
EOF

python test_grid_random_search.py
```

#### Test 2: Bayesian Optimization with Optuna

```bash
cat > test_optuna.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_classification
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score
from src.validation.optuna_tuner import OptunaTuner

# Create dataset
X, y = make_classification(
    n_samples=500,
    n_features=10,
    n_informative=5,
    n_classes=2,
    random_state=42
)

X = pd.DataFrame(X, columns=[f'feature_{i}' for i in range(X.shape[1])])

print(f"Data shape: {X.shape}")

# Define parameter space
param_space = {
    'n_estimators': (50, 200),
    'max_depth': (3, 10),
    'min_samples_split': (2, 10),
    'min_samples_leaf': (1, 4),
    'max_features': ['sqrt', 'log2', None]
}

# Create tuner
tuner = OptunaTuner(
    param_space=param_space,
    n_trials=20,
    direction='maximize',
    cv=3,
    scoring='accuracy',
    random_state=42
)

# Run optimization
print("\n" + "="*60)
print("Bayesian Optimization with Optuna")
print("="*60)

results = tuner.optimize(
    X=X,
    y=y,
    model=RandomForestClassifier(random_state=42)
)

print(f"Best value: {results['best_value']:.4f}")
print(f"Best params: {results['best_params']}")
print(f"Trials: {results['n_trials']}")
print(f"Time: {results['time_seconds']:.2f}s")

# Get trials data
trials_df = tuner.get_trials_dataframe()
print(f"\nTrials summary:")
print(f"  Number of trials: {len(trials_df)}")
print(f"  Best trial: {trials_df['value'].min() if tuner.direction == 'minimize' else trials_df['value'].max():.4f}")

# Save study
tuner.save_study('models/optuna_study.joblib')
print("\nStudy saved to: models/optuna_study.joblib")

print("\n✅ Optuna test complete!")
EOF

python test_optuna.py
```

#### Test 3: Automated Tuning Pipeline

```bash
cat > test_automated_tuning.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_classification
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from src.validation.optuna_tuner import AutomatedTuner
from src.validation.metrics import MetricsCalculator

# Create dataset
X, y = make_classification(
    n_samples=800,
    n_features=15,
    n_informative=8,
    n_redundant=3,
    n_classes=2,
    random_state=42
)

X = pd.DataFrame(X, columns=[f'feature_{i}' for i in range(X.shape[1])])

# Split data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

print(f"Data: {X.shape}")
print(f"Train: {X_train.shape}, Test: {X_test.shape}")

# Define parameter space
param_space = {
    'n_estimators': [50, 100, 150, 200],
    'max_depth': [3, 5, 7, 10],
    'min_samples_split': [2, 5, 10],
    'min_samples_leaf': [1, 2, 4],
    'max_features': ['sqrt', 'log2']
}

# Test different tuning methods
print("\n" + "="*60)
print("Automated Tuning Methods")
print("="*60)

methods = ['grid', 'random', 'bayesian']
results = {}

for method in methods:
    print(f"\n{method.upper()}:")
    
    tuner = AutomatedTuner(
        method=method,
        n_trials=30,
        cv=3,
        scoring='accuracy'
    )
    
    result = tuner.tune(
        model=RandomForestClassifier(random_state=42),
        X=X_train,
        y=y_train,
        param_space=param_space
    )
    
    results[method] = result
    
    print(f"  Best score: {result.get('best_score', 0):.4f}")
    print(f"  Best params: {result.get('best_params', {})}")
    print(f"  Time: {result.get('time_seconds', 0):.2f}s")

# Evaluate best model on test set
print("\n" + "="*60)
print("Best Model Evaluation on Test Set")
print("="*60)

best_method = max(results.items(), key=lambda x: x[1].get('best_score', 0))[0]
best_params = results[best_method].get('best_params', {})

print(f"Best method: {best_method}")

# Train with best parameters
best_model = RandomForestClassifier(**best_params, random_state=42)
best_model.fit(X_train, y_train)

y_pred = best_model.predict(X_test)
y_proba = best_model.predict_proba(X_test)[:, 1]

calc = MetricsCalculator(task='classification')
metrics = calc.compute_metrics(y_test, y_pred, y_proba)
calc.print_report(metrics, f"Test Set Performance ({best_method.upper()})")

print("\n✅ Automated tuning test complete!")
EOF

python test_automated_tuning.py
```

### What Just Happened: Understanding Hyperparameter Optimization

#### Search Methods Comparison

| Method | Best For | Pros | Cons |
|--------|----------|------|------|
| Grid Search | Small spaces, known good ranges | Exhaustive, reproducible | Slow, doesn't scale |
| Random Search | Medium spaces, unknown good ranges | Faster than grid, good coverage | Less systematic |
| Bayesian Search | Large spaces, expensive evaluation | Most efficient, learns from past | Complex, requires tuning |

#### Parameter Types

**Integer Parameters**
- Example: `n_estimators`, `max_depth`
- Search: Use discrete ranges or continuous with int()

**Float Parameters**
- Example: `learning_rate`, `subsample`
- Search: Use continuous ranges, often log-scale

**Categorical Parameters**
- Example: `max_features`, `loss`
- Search: Use categorical choices

**Conditional Parameters**
- Example: `gamma` only matters for tree-based models
- Search: Use conditional logic in objective function

#### Optimization Strategies

**Early Stopping**: Stop unpromising trials early to save time.

**Pruning**: Remove trials that show poor performance early.

**Warm Start**: Use results from previous runs to inform new runs.

**Parallel Execution**: Run multiple trials simultaneously.

#### Interpreting Results

**Parameter Importance**: Which hyperparameters matter most?

**Search Convergence**: Have we found the optimal region?

**Performance vs. Complexity**: Is the added complexity worth the performance gain?

### Summary

In this part, we've built a comprehensive hyperparameter optimization system that:

1. **Implements Grid Search** for exhaustive exploration
2. **Implements Random Search** for efficient exploration
3. **Implements Bayesian Optimization** with Optuna for intelligent search
4. **Provides automated tuning** with method selection
5. **Visualizes** optimization results and parameter importance
6. **Supports pruning** and early stopping
7. **Saves and loads** studies for reproducibility

### What's Next

We've completed Module 4.3! Next is the Phase 4 Capstone, where we'll integrate everything we've built into a complete end-to-end predictive pipeline.

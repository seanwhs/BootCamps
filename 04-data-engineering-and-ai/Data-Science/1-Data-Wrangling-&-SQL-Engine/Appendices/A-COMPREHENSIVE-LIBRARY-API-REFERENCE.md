# APPENDIX A: COMPREHENSIVE LIBRARY API REFERENCE

This appendix serves as your go-to quick reference for the core libraries used throughout this series. While the tutorials focused on *when* and *why* to use each tool, this appendix provides the *what*—a complete, structured catalog of the most important functions, methods, and patterns.

---

## A.1 NumPy – The Foundation

### Array Creation

| Function | Description | Example |
|----------|-------------|---------|
| `np.array(list)` | Create array from list/tuple | `np.array([1,2,3])` |
| `np.zeros(shape)` | Array of zeros | `np.zeros((3,4))` |
| `np.ones(shape)` | Array of ones | `np.ones((2,3))` |
| `np.full(shape, value)` | Array filled with constant | `np.full((3,3), 7)` |
| `np.eye(n)` | Identity matrix | `np.eye(4)` |
| `np.diag(vals)` | Diagonal matrix | `np.diag([1,2,3])` |
| `np.arange(start,stop,step)` | Range of values | `np.arange(0,10,2)` |
| `np.linspace(start,stop,num)` | Evenly spaced values | `np.linspace(0,1,5)` |
| `np.random.randn(shape)` | Standard normal | `np.random.randn(2,3)` |
| `np.random.uniform(low,high,size)` | Uniform distribution | `np.random.uniform(0,1,(2,3))` |
| `np.random.randint(low,high,size)` | Random integers | `np.random.randint(0,10,(3,4))` |
| `np.random.seed(n)` | Set random seed | `np.random.seed(42)` |

### Array Properties

| Attribute | Description | Example |
|-----------|-------------|---------|
| `.shape` | Dimensions | `arr.shape` → `(3,4)` |
| `.size` | Total elements | `arr.size` → `12` |
| `.ndim` | Number of dimensions | `arr.ndim` → `2` |
| `.dtype` | Data type | `arr.dtype` → `dtype('float64')` |
| `.itemsize` | Bytes per element | `arr.itemsize` → `8` |
| `.nbytes` | Total bytes | `arr.nbytes` → `96` |
| `.T` | Transpose | `arr.T` |

### Indexing & Slicing

| Operation | Description | Example |
|-----------|-------------|---------|
| `arr[i,j]` | Element access | `arr[2,3]` |
| `arr[i]` | Row access | `arr[2]` |
| `arr[:, j]` | Column access | `arr[:, 3]` |
| `arr[i:j, k:l]` | Slice | `arr[1:3, 2:4]` |
| `arr[bool_mask]` | Boolean indexing | `arr[arr > 5]` |
| `arr[[rows],[cols]]` | Fancy indexing | `arr[[0,2,3],[1,4,2]]` |
| `arr.reshape(new_shape)` | Reshape | `arr.reshape(2,6)` |
| `arr.flatten()` | Flatten to 1D | `arr.flatten()` |
| `arr.ravel()` | Flatten (view) | `arr.ravel()` |

### Universal Functions (Ufuncs)

| Function | Description | Example |
|----------|-------------|---------|
| `np.add(a,b)` | Element-wise addition | `np.add(arr1, arr2)` |
| `np.subtract(a,b)` | Subtraction | `np.subtract(arr1, arr2)` |
| `np.multiply(a,b)` | Multiplication | `np.multiply(arr1, arr2)` |
| `np.divide(a,b)` | Division | `np.divide(arr1, arr2)` |
| `np.power(a,b)` | Power | `np.power(arr, 2)` |
| `np.sqrt(arr)` | Square root | `np.sqrt(arr)` |
| `np.exp(arr)` | Exponential | `np.exp(arr)` |
| `np.log(arr)` | Natural log | `np.log(arr)` |
| `np.log10(arr)` | Log base 10 | `np.log10(arr)` |
| `np.sin(arr)` | Sine | `np.sin(arr)` |
| `np.cos(arr)` | Cosine | `np.cos(arr)` |
| `np.abs(arr)` | Absolute value | `np.abs(arr)` |
| `np.greater(a,b)` | Element-wise > | `np.greater(arr1, arr2)` |
| `np.where(cond, x, y)` | Conditional | `np.where(arr > 0, 1, -1)` |

### Aggregations

| Function | Description | Example |
|----------|-------------|---------|
| `np.sum(arr)` | Sum | `np.sum(arr)` |
| `np.mean(arr)` | Mean | `np.mean(arr)` |
| `np.std(arr)` | Standard deviation | `np.std(arr)` |
| `np.var(arr)` | Variance | `np.var(arr)` |
| `np.min(arr)` | Minimum | `np.min(arr)` |
| `np.max(arr)` | Maximum | `np.max(arr)` |
| `np.median(arr)` | Median | `np.median(arr)` |
| `np.percentile(arr, q)` | Percentile | `np.percentile(arr, 75)` |
| `np.cumsum(arr)` | Cumulative sum | `np.cumsum(arr)` |
| `np.cumprod(arr)` | Cumulative product | `np.cumprod(arr)` |

### Linear Algebra

| Function | Description | Example |
|----------|-------------|---------|
| `np.dot(A,B)` | Matrix multiplication | `np.dot(A,B)` |
| `A @ B` | Matrix multiplication (modern) | `A @ B` |
| `np.linalg.inv(A)` | Inverse | `np.linalg.inv(A)` |
| `np.linalg.det(A)` | Determinant | `np.linalg.det(A)` |
| `np.linalg.solve(A,b)` | Solve Ax=b | `np.linalg.solve(A,b)` |
| `np.linalg.eig(A)` | Eigenvalues/vectors | `np.linalg.eig(A)` |
| `np.linalg.svd(A)` | Singular value decomposition | `np.linalg.svd(A)` |

### Broadcasting Rules

1. If arrays have different dimensions, pad with 1s on the left
2. Arrays can be broadcast if dimensions are equal or one is 1
3. The result has the maximum dimension along each axis

**Example:** `(3,4)` + `(4,)` → `(4,)` broadcasts to `(1,4)` → broadcasts to `(3,4)`

---

## A.2 Pandas – Data Manipulation

### Series

| Operation | Description | Example |
|-----------|-------------|---------|
| `pd.Series(data)` | Create Series | `pd.Series([1,2,3])` |
| `pd.Series(data, index=idx)` | With custom index | `pd.Series([1,2,3], index=['a','b','c'])` |
| `.values` | Get values (NumPy array) | `s.values` |
| `.index` | Get index | `s.index` |
| `.dtype` | Data type | `s.dtype` |
| `.shape` | Shape | `s.shape` |
| `.size` | Size | `s.size` |
| `.isna()` | Check for NA | `s.isna()` |
| `.dropna()` | Drop NA | `s.dropna()` |
| `.fillna(value)` | Fill NA | `s.fillna(0)` |
| `.astype(dtype)` | Change type | `s.astype('int')` |

### DataFrame

| Operation | Description | Example |
|-----------|-------------|---------|
| `pd.DataFrame(data)` | Create DataFrame | `pd.DataFrame({'col1':[1,2], 'col2':[3,4]})` |
| `.head(n)` | First n rows | `df.head(5)` |
| `.tail(n)` | Last n rows | `df.tail(5)` |
| `.info()` | Summary info | `df.info()` |
| `.describe()` | Summary statistics | `df.describe()` |
| `.shape` | Dimensions | `df.shape` |
| `.columns` | Column names | `df.columns` |
| `.dtypes` | Column types | `df.dtypes` |
| `.index` | Row index | `df.index` |
| `.values` | Values (NumPy array) | `df.values` |

### Selection

| Operation | Description | Example |
|-----------|-------------|---------|
| `df[col]` | Select column | `df['age']` |
| `df[[col1,col2]]` | Select multiple columns | `df[['age','income']]` |
| `df.loc[idx]` | Label-based selection | `df.loc[5]` |
| `df.iloc[idx]` | Integer-based selection | `df.iloc[5]` |
| `df.loc[rows, cols]` | Label-based 2D | `df.loc[1:5, 'age':'income']` |
| `df.iloc[rows, cols]` | Integer-based 2D | `df.iloc[1:5, 2:4]` |
| `df[bool_condition]` | Boolean indexing | `df[df['age'] > 30]` |
| `df.query(expression)` | Query string | `df.query('age > 30 & income > 50000')` |
| `.at[row, col]` | Fast scalar access | `df.at[5, 'age']` |
| `.iat[row, col]` | Fast scalar integer access | `df.iat[5, 2]` |

### Manipulation

| Operation | Description | Example |
|-----------|-------------|---------|
| `.drop(columns=cols)` | Drop columns | `df.drop(columns=['age'])` |
| `.drop(index=idx)` | Drop rows | `df.drop(index=[0,1,2])` |
| `.rename(columns=dict)` | Rename columns | `df.rename(columns={'age':'age_years'})` |
| `.assign(**kwargs)` | Add columns | `df.assign(new_col=df['col']*2)` |
| `.sort_values(col)` | Sort by column | `df.sort_values('age')` |
| `.sort_index()` | Sort by index | `df.sort_index()` |
| `.reset_index()` | Reset index | `df.reset_index()` |
| `.set_index(col)` | Set index | `df.set_index('id')` |
| `.copy()` | Create a copy | `df.copy()` |

### Aggregation & Grouping

| Operation | Description | Example |
|-----------|-------------|---------|
| `.groupby(col)` | Group by column | `df.groupby('category')` |
| `.agg(functions)` | Aggregate | `df.groupby('cat').agg(['mean','std'])` |
| `.agg({col:func})` | Column-specific | `df.groupby('cat').agg({'age':'mean', 'income':'sum'})` |
| `.transform(func)` | Transform | `df.groupby('cat')['age'].transform('mean')` |
| `.apply(func)` | Apply function | `df.groupby('cat').apply(lambda x: x.max() - x.min())` |
| `.pivot_table(values, index, columns, aggfunc)` | Pivot table | `df.pivot_table(values='sales', index='region', columns='category', aggfunc='mean')` |

### Merging & Joining

| Operation | Description | Example |
|-----------|-------------|---------|
| `pd.merge(df1, df2, on=key)` | Merge on key | `pd.merge(df1, df2, on='id')` |
| `pd.merge(df1, df2, how='left')` | Left join | `pd.merge(df1, df2, on='id', how='left')` |
| `pd.concat([df1, df2])` | Concatenate | `pd.concat([df1, df2])` |
| `.join(df2)` | Join on index | `df1.join(df2)` |

### Performance Anti-Patterns

| Anti-Pattern | Solution |
|--------------|----------|
| `for i, row in df.iterrows():` | Use vectorized operations |
| `df[df['a'] > 5]['b'] = 10` | Use `df.loc[df['a'] > 5, 'b'] = 10` |
| `df.apply(lambda x: x['a'] + x['b'], axis=1)` | Use `df['a'] + df['b']` |
| `df[col].astype('object')` for categories | Use `df[col].astype('category')` |

---

## A.3 Polars – Modern DataFrame

### DataFrame Creation

| Operation | Description | Example |
|-----------|-------------|---------|
| `pl.DataFrame(dict)` | From dictionary | `pl.DataFrame({'a':[1,2], 'b':[3,4]})` |
| `pl.DataFrame(data, schema=...)` | With schema | `pl.DataFrame(data, schema=['a','b','c'])` |
| `pl.from_pandas(df)` | From Pandas | `pl.from_pandas(df)` |
| `pl.read_csv(path)` | Read CSV | `pl.read_csv('file.csv')` |
| `pl.read_parquet(path)` | Read Parquet | `pl.read_parquet('file.parquet')` |
| `pl.scan_csv(path)` | Lazy CSV | `pl.scan_csv('file.csv')` |
| `pl.scan_parquet(path)` | Lazy Parquet | `pl.scan_parquet('file.parquet')` |

### Selection

| Operation | Description | Example |
|-----------|-------------|---------|
| `.select(col)` | Select column | `df.select(pl.col('a'))` |
| `.select([col1, col2])` | Select multiple | `df.select(['a', 'b'])` |
| `.filter(condition)` | Filter rows | `df.filter(pl.col('a') > 5)` |
| `.with_columns([expr])` | Add/update columns | `df.with_columns((pl.col('a')*2).alias('a2'))` |
| `.head(n)` | First n rows | `df.head(5)` |
| `.tail(n)` | Last n rows | `df.tail(5)` |
| `.sample(n)` | Random sample | `df.sample(100)` |

### Expressions

| Function | Description | Example |
|----------|-------------|---------|
| `pl.col(name)` | Column reference | `pl.col('a')` |
| `pl.lit(value)` | Literal value | `pl.lit(5)` |
| `.alias(name)` | Rename | `pl.col('a').alias('new_name')` |
| `.cast(dtype)` | Cast type | `pl.col('a').cast(pl.Float64)` |
| `.str.` | String operations | `pl.col('text').str.to_uppercase()` |
| `.dt.` | DateTime operations | `pl.col('date').dt.year()` |
| `.list.` | List operations | `pl.col('list').list.length()` |
| `.mean()` | Mean | `pl.col('a').mean()` |
| `.sum()` | Sum | `pl.col('a').sum()` |
| `.std()` | Standard deviation | `pl.col('a').std()` |
| `.min()` | Minimum | `pl.col('a').min()` |
| `.max()` | Maximum | `pl.col('a').max()` |
| `.unique()` | Unique values | `pl.col('a').unique()` |
| `.is_null()` | Check null | `pl.col('a').is_null()` |
| `.is_not_null()` | Check not null | `pl.col('a').is_not_null()` |
| `.is_in(list)` | Check membership | `pl.col('a').is_in([1,2,3])` |
| `.fill_null(value)` | Fill null | `pl.col('a').fill_null(0)` |

### Grouping & Aggregation

| Operation | Description | Example |
|-----------|-------------|---------|
| `.group_by(col)` | Group by | `df.group_by('category')` |
| `.agg([exprs])` | Aggregate | `df.group_by('cat').agg([pl.col('value').mean(), pl.col('value').sum()])` |
| `.sort(col, descending=...)` | Sort | `df.sort('value', descending=True)` |
| `.unique()` | Unique rows | `df.unique()` |

### Lazy Evaluation

| Operation | Description | Example |
|-----------|-------------|---------|
| `.lazy()` | Convert to lazy | `df.lazy()` |
| `.collect()` | Execute lazy plan | `df.lazy().filter(...).collect()` |
| `.fetch(n)` | Fetch n rows | `df.lazy().filter(...).fetch(100)` |

---

## A.4 DuckDB – Analytical SQL

### Connection

| Operation | Description | Example |
|-----------|-------------|---------|
| `duckdb.connect(':memory:')` | In-memory DB | `duckdb.connect(':memory:')` |
| `duckdb.connect('file.db')` | File-based DB | `duckdb.connect('database.db')` |
| `.execute(sql)` | Execute SQL | `conn.execute("SELECT * FROM table")` |
| `.fetchdf()` | Return as Pandas DataFrame | `conn.execute(sql).fetchdf()` |
| `.fetch_arrow()` | Return as Arrow table | `conn.execute(sql).fetch_arrow()` |
| `.register(name, df)` | Register DataFrame as view | `conn.register('my_data', df)` |

### File Querying

| Operation | Description | Example |
|-----------|-------------|---------|
| `SELECT * FROM 'file.csv'` | Query CSV directly | `conn.execute("SELECT * FROM 'data.csv'")` |
| `SELECT * FROM 'file.parquet'` | Query Parquet directly | `conn.execute("SELECT * FROM 'data.parquet'")` |

---

## A.5 Pandera – Data Validation

### Schema Definition

| Operation | Description | Example |
|-----------|-------------|---------|
| `pa.SchemaModel` | Define schema class | `class MySchema(pa.SchemaModel): ...` |
| `pa.Field()` | Field definition | `col: Series[int] = pa.Field(gt=0)` |
| `pa.Field(ge=0)` | Greater/equal | `pa.Field(ge=0)` |
| `pa.Field(le=100)` | Less/equal | `pa.Field(le=100)` |
| `pa.Field(isin=[values])` | In list | `pa.Field(isin=['A','B'])` |
| `pa.Field(nullable=False)` | Not null | `pa.Field(nullable=False)` |
| `@pa.dataframe_check` | DataFrame-level check | `def check_condition(cls, df):` |

### Validation

| Operation | Description | Example |
|-----------|-------------|---------|
| `.validate(df)` | Validate DataFrame | `MySchema.validate(df)` |
| `.validate(df, lazy=True)` | Collect all errors | `MySchema.validate(df, lazy=True)` |

---

## A.6 Pydantic – Type Validation

### Schema Definition

| Operation | Description | Example |
|-----------|-------------|---------|
| `BaseModel` | Base class | `class MyModel(BaseModel):` |
| `Field(...)` | Field definition | `id: int = Field(gt=0)` |
| `Field(ge=0)` | Greater/equal | `Field(ge=0)` |
| `Field(le=100)` | Less/equal | `Field(le=100)` |
| `Field(regex=r'^...$')` | Regex validation | `Field(regex=r'^[a-z]+$')` |
| `Field(min_length=1)` | Min string length | `Field(min_length=1)` |
| `Field(max_length=50)` | Max string length | `Field(max_length=50)` |
| `Optional[type]` | Optional field | `Optional[int]` |
| `@validator(field)` | Custom validator | `def validate_field(cls, v): ...` |

---

## A.7 Scipy – Statistics

### Statistical Tests

| Function | Description | Example |
|----------|-------------|---------|
| `stats.ttest_1samp(data, mu)` | One-sample t-test | `stats.ttest_1samp(sample, 100)` |
| `stats.ttest_ind(a,b)` | Independent t-test | `stats.ttest_ind(group1, group2)` |
| `stats.ttest_rel(a,b)` | Paired t-test | `stats.ttest_rel(before, after)` |
| `stats.f_oneway(*groups)` | One-way ANOVA | `stats.f_oneway(g1, g2, g3)` |
| `stats.mannwhitneyu(a,b)` | Mann-Whitney U | `stats.mannwhitneyu(g1, g2)` |
| `stats.wilcoxon(a,b)` | Wilcoxon signed-rank | `stats.wilcoxon(before, after)` |
| `stats.kruskal(*groups)` | Kruskal-Wallis | `stats.kruskal(g1, g2, g3)` |
| `stats.chi2_contingency(table)` | Chi-square test | `stats.chi2_contingency(contingency)` |
| `stats.shapiro(data)` | Shapiro-Wilk normality | `stats.shapiro(residuals)` |
| `stats.ks_2samp(a,b)` | Kolmogorov-Smirnov | `stats.ks_2samp(sample1, sample2)` |
| `stats.pearsonr(a,b)` | Pearson correlation | `stats.pearsonr(x, y)` |
| `stats.spearmanr(a,b)` | Spearman correlation | `stats.spearmanr(x, y)` |

### Probability Distributions

| Distribution | Functions | Example |
|--------------|-----------|---------|
| Normal (norm) | `.pdf`, `.cdf`, `.ppf`, `.rvs` | `norm.pdf(x, mu, sigma)` |
| t (t) | `.pdf`, `.cdf`, `.ppf`, `.rvs` | `t.ppf(0.95, df=10)` |
| Chi-Square (chi2) | `.pdf`, `.cdf`, `.ppf`, `.rvs` | `chi2.pdf(x, df=5)` |
| F (f) | `.pdf`, `.cdf`, `.ppf`, `.rvs` | `f.pdf(x, dfn=3, dfd=10)` |

### Power Analysis

| Function | Description | Example |
|----------|-------------|---------|
| `TTestIndPower().solve_power()` | Sample size for t-test | `power.solve_power(effect_size=0.5, alpha=0.05, power=0.8)` |
| `TTestIndPower().power()` | Power for t-test | `power.power(effect_size=0.5, nobs1=100, alpha=0.05)` |

---

## A.8 Statsmodels – Statistical Modeling

### Linear Regression

| Operation | Description | Example |
|-----------|-------------|---------|
| `sm.OLS(y, X)` | OLS model | `sm.OLS(y, sm.add_constant(X))` |
| `.fit()` | Fit model | `model.fit()` |
| `.params` | Coefficients | `model.params` |
| `.pvalues` | P-values | `model.pvalues` |
| `.conf_int()` | Confidence intervals | `model.conf_int()` |
| `.rsquared` | R-squared | `model.rsquared` |
| `.rsquared_adj` | Adjusted R-squared | `model.rsquared_adj` |
| `.fvalue` | F-statistic | `model.fvalue` |
| `.f_pvalue` | F-statistic p-value | `model.f_pvalue` |
| `.resid` | Residuals | `model.resid` |
| `.fittedvalues` | Fitted values | `model.fittedvalues` |
| `.get_influence()` | Influence measures | `model.get_influence()` |
| `het_breuschpagan(resid, exog)` | Heteroscedasticity test | `het_breuschpagan(model.resid, model.model.exog)` |
| `variance_inflation_factor(X, idx)` | VIF | `variance_inflation_factor(X, i)` |

### Logistic Regression

| Operation | Description | Example |
|-----------|-------------|---------|
| `sm.Logit(y, X)` | Logit model | `sm.Logit(y, sm.add_constant(X))` |
| `.fit(disp=0)` | Fit (silent) | `model.fit(disp=0)` |
| `.predict(X)` | Predict probabilities | `model.predict(X)` |
| `.llf` | Log-likelihood | `model.llf` |
| `.prsquared` | Pseudo R-squared | `model.prsquared` |

---

## A.9 Visualization Libraries

### Matplotlib

| Function | Description | Example |
|----------|-------------|---------|
| `plt.subplots(nrows, ncols)` | Create figure | `fig, axes = plt.subplots(2, 2)` |
| `plt.plot(x, y)` | Line plot | `ax.plot(x, y)` |
| `plt.scatter(x, y)` | Scatter plot | `ax.scatter(x, y)` |
| `plt.bar(x, y)` | Bar plot | `ax.bar(categories, values)` |
| `plt.hist(data, bins=30)` | Histogram | `ax.hist(data, bins=30)` |
| `plt.boxplot(data)` | Box plot | `ax.boxplot(data)` |
| `plt.imshow(data, cmap=...)` | Heatmap | `ax.imshow(matrix, cmap='RdBu')` |
| `.set_title(text)` | Title | `ax.set_title('Title')` |
| `.set_xlabel(text)` | X-axis label | `ax.set_xlabel('Label')` |
| `.set_ylabel(text)` | Y-axis label | `ax.set_ylabel('Label')` |
| `.legend()` | Legend | `ax.legend()` |
| `.grid(True, alpha=0.3)` | Grid | `ax.grid(True, alpha=0.3)` |
| `plt.tight_layout()` | Tight layout | `plt.tight_layout()` |
| `plt.savefig(path, dpi=300)` | Save figure | `plt.savefig('figure.png', dpi=300)` |

### Seaborn

| Function | Description | Example |
|----------|-------------|---------|
| `sns.histplot(data, kde=True)` | Histogram with KDE | `sns.histplot(df['age'], kde=True)` |
| `sns.kdeplot(data, fill=True)` | KDE plot | `sns.kdeplot(df['income'], fill=True)` |
| `sns.boxplot(x=..., y=...)` | Box plot | `sns.boxplot(x='cat', y='value', data=df)` |
| `sns.violinplot(x=..., y=...)` | Violin plot | `sns.violinplot(x='cat', y='value', data=df)` |
| `sns.scatterplot(x=..., y=...)` | Scatter plot | `sns.scatterplot(x='x', y='y', data=df)` |
| `sns.regplot(x=..., y=...)` | Regression plot | `sns.regplot(x='x', y='y', data=df)` |
| `sns.pairplot(data)` | Pair plot | `sns.pairplot(df)` |
| `sns.heatmap(data, annot=True)` | Heatmap | `sns.heatmap(corr, annot=True)` |
| `sns.FacetGrid(data, col=..., row=...)` | Facet grid | `sns.FacetGrid(df, col='region')` |

### Plotly (Interactive)

| Function | Description | Example |
|----------|-------------|---------|
| `px.scatter(df, x, y, color=...)` | Interactive scatter | `px.scatter(df, x='x', y='y', color='cat')` |
| `px.histogram(df, x, color=...)` | Interactive histogram | `px.histogram(df, x='age', color='cat')` |
| `px.box(df, x, y, color=...)` | Interactive box plot | `px.box(df, x='cat', y='value')` |
| `px.bar(df, x, y, color=...)` | Interactive bar chart | `px.bar(df, x='cat', y='value')` |
| `px.line(df, x, y, color=...)` | Interactive line chart | `px.line(df, x='date', y='value')` |
| `px.scatter_3d(df, x, y, z)` | 3D scatter | `px.scatter_3d(df, x='x', y='y', z='z')` |
| `px.density_heatmap(df, x, y)` | 2D histogram | `px.density_heatmap(df, x='x', y='y')` |
| `.write_html(path)` | Save as HTML | `fig.write_html('chart.html')` |

---

## A.10 Quick Reference: Statistical Tests Selection

### Which Test Should I Use?

| Research Question | Data Type | Test | Library |
|-------------------|-----------|------|---------|
| Does sample mean differ from hypothesized value? | 1 numeric group | One-sample t-test | `scipy.stats.ttest_1samp` |
| Do two independent groups differ? | 2 numeric groups | Independent t-test | `scipy.stats.ttest_ind` |
| Do two paired groups differ? | 2 numeric groups (paired) | Paired t-test | `scipy.stats.ttest_rel` |
| Do 3+ groups differ? | 3+ numeric groups | ANOVA | `scipy.stats.f_oneway` |
| Are two categorical variables independent? | 2 categorical | Chi-square | `scipy.stats.chi2_contingency` |
| Do two independent groups differ? (non-normal) | 2 numeric groups | Mann-Whitney | `scipy.stats.mannwhitneyu` |
| Do two paired groups differ? (non-normal) | 2 numeric groups (paired) | Wilcoxon | `scipy.stats.wilcoxon` |
| Are two variables correlated? | 2 numeric | Pearson/Spearman | `scipy.stats.pearsonr` / `spearmanr` |

---

This appendix is designed to be your quick reference throughout the series and beyond. Keep it handy as you continue your data science journey!

---

**[APPENDIX A COMPLETE]**  

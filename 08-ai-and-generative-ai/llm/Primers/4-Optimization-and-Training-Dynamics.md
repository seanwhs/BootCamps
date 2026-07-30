# Primer 4: Optimization and Training Dynamics

This primer provides a comprehensive introduction to optimization algorithms and training dynamics essential for understanding how LLMs learn. If you've ever wondered why training takes so long, what learning rates do, or how models converge, this guide will explain it all with intuitive analogies and practical JavaScript examples.

---

## P4.1 Why Optimization Matters for LLMs

### The Core Insight

**Training an LLM is finding the lowest point in a high-dimensional landscape.**

Think of it like finding the lowest point in a mountain range, but with millions of dimensions:

```
Loss Landscape (simplified):
     ^
Loss |    \___/
     |       \___
     |          \___
     |             \___
     +-----------------> Parameters
     
Goal: Find the global minimum (lowest loss)
Challenge: Landscape is complex with many local minima
```

### What You'll Learn

| Concept | Why It Matters | Where Used |
|---------|---------------|------------|
| **Gradient Descent** | How models learn | All training |
| **Learning Rate** | Speed of learning | Every optimization step |
| **Momentum** | Accelerate training | Adam, SGD with momentum |
| **Learning Rate Schedules** | Adapt learning over time | Training large models |
| **Adam Optimizer** | Best practice optimizer | Most LLM training |
| **Gradient Clipping** | Prevent exploding gradients | Training stability |
| **Batch Size** | Memory/speed tradeoff | All training |
| **Warmup** | Initial training stability | Large models |

---

## P4.2 Gradient Descent Fundamentals

### The Target
We'll implement gradient descent from scratch and visualize how it works.

### The Concept

**Gradient descent is like rolling a ball downhill to find the lowest point.**

1. **Calculate gradient**: Which way is "down"?
2. **Take a step**: Move in that direction
3. **Repeat**: Keep going until you reach the bottom

```
Gradient Descent Visualization:
Loss
  ^
  |  *← Start
  |   \
  |    \  ← Steps
  |     \
  |      *← Minimum
  +-------------------------> Parameters
```

### The Implementation

```javascript
// 📁 src/primers/optimization/gradient-descent.js
/**
 * Gradient Descent Fundamentals
 * 
 * Implementation of gradient descent and variants with
 * visualization and analysis tools.
 */

/**
 * Compute gradient of a simple function
 * Example: f(x) = x², gradient = 2x
 */
export function gradientSimple(x) {
    return 2 * x;
}

/**
 * Simple gradient descent
 * @param {Function} gradientFn - Function that computes gradient
 * @param {number} start - Starting point
 * @param {number} learningRate - Learning rate
 * @param {number} iterations - Number of iterations
 * @param {number} tolerance - Stop if change < tolerance
 * @returns {Object} Optimization history
 */
export function gradientDescent(gradientFn, start, learningRate, iterations, tolerance = 1e-6) {
    let x = start;
    const history = {
        x: [x],
        gradients: [],
        losses: []
    };

    for (let i = 0; i < iterations; i++) {
        const grad = gradientFn(x);
        const newX = x - learningRate * grad;
        
        history.gradients.push(grad);
        history.losses.push(x * x); // For f(x) = x²
        
        // Check convergence
        if (Math.abs(newX - x) < tolerance) {
            console.log(`[GD] Converged at iteration ${i + 1}`);
            break;
        }
        
        x = newX;
        history.x.push(x);
    }

    return history;
}

/**
 * Gradient descent with momentum
 * Accelerates convergence by accumulating velocity
 */
export function gradientDescentMomentum(gradientFn, start, learningRate, momentum, iterations) {
    let x = start;
    let velocity = 0;
    const history = {
        x: [x],
        velocities: [velocity]
    };

    for (let i = 0; i < iterations; i++) {
        const grad = gradientFn(x);
        velocity = momentum * velocity - learningRate * grad;
        x = x + velocity;
        
        history.x.push(x);
        history.velocities.push(velocity);
        
        // Check convergence
        if (Math.abs(velocity) < 1e-8) break;
    }

    return history;
}

/**
 * Nesterov Accelerated Gradient
 * "Look ahead" before computing gradient
 */
export function nesterovMomentum(gradientFn, start, learningRate, momentum, iterations) {
    let x = start;
    let velocity = 0;
    const history = {
        x: [x],
        velocities: [velocity]
    };

    for (let i = 0; i < iterations; i++) {
        const lookahead = x + momentum * velocity;
        const grad = gradientFn(lookahead);
        velocity = momentum * velocity - learningRate * grad;
        x = x + velocity;
        
        history.x.push(x);
        history.velocities.push(velocity);
        
        if (Math.abs(velocity) < 1e-8) break;
    }

    return history;
}

/**
 * Adagrad: Adaptive learning rate per parameter
 */
export function adagrad(gradientFn, start, learningRate, iterations, epsilon = 1e-8) {
    let x = start;
    let sumSquaredGrads = 0;
    const history = {
        x: [x],
        learningRates: []
    };

    for (let i = 0; i < iterations; i++) {
        const grad = gradientFn(x);
        sumSquaredGrads += grad * grad;
        const adaptiveLR = learningRate / (Math.sqrt(sumSquaredGrads) + epsilon);
        x = x - adaptiveLR * grad;
        
        history.x.push(x);
        history.learningRates.push(adaptiveLR);
        
        if (Math.abs(grad) < 1e-8) break;
    }

    return history;
}

/**
 * RMSprop: Root Mean Square Propagation
 */
export function rmsprop(gradientFn, start, learningRate, decay, iterations, epsilon = 1e-8) {
    let x = start;
    let squareAvg = 0;
    const history = {
        x: [x],
        learningRates: []
    };

    for (let i = 0; i < iterations; i++) {
        const grad = gradientFn(x);
        squareAvg = decay * squareAvg + (1 - decay) * grad * grad;
        const adaptiveLR = learningRate / (Math.sqrt(squareAvg) + epsilon);
        x = x - adaptiveLR * grad;
        
        history.x.push(x);
        history.learningRates.push(adaptiveLR);
        
        if (Math.abs(grad) < 1e-8) break;
    }

    return history;
}

/**
 * Visualize gradient descent results
 */
export function visualizeOptimization(history, title = 'Gradient Descent') {
    console.log(`\n📊 ${title}`);
    console.log('─'.repeat(40));
    
    console.log(`  Final point: ${history.x[history.x.length - 1].toFixed(4)}`);
    console.log(`  Steps: ${history.x.length}`);
    
    if (history.gradients) {
        console.log(`  Final gradient: ${history.gradients[history.gradients.length - 1].toFixed(4)}`);
    }
    
    if (history.velocities) {
        console.log(`  Final velocity: ${history.velocities[history.velocities.length - 1].toFixed(4)}`);
    }
    
    // Show path (first 10 steps)
    console.log('\n  Path:');
    const displaySteps = Math.min(10, history.x.length);
    for (let i = 0; i < displaySteps; i++) {
        const xVal = history.x[i];
        const loss = xVal * xVal;
        console.log(`    Step ${i}: x = ${xVal.toFixed(4)}, loss = ${loss.toFixed(4)}`);
    }
    if (history.x.length > displaySteps) {
        console.log(`    ... (${history.x.length - displaySteps} more steps)`);
    }
}

// Example usage
function runGradientDescentDemo() {
    console.log('='.repeat(60));
    console.log('📉 Gradient Descent Demo');
    console.log('='.repeat(60));

    // 1. Standard gradient descent
    console.log('\n🔽 1. Standard Gradient Descent');
    console.log('─'.repeat(40));
    console.log('  Function: f(x) = x², minimum at x = 0');
    
    const gd = gradientDescent(gradientSimple, 10, 0.1, 100);
    visualizeOptimization(gd, 'Standard Gradient Descent');
    
    // 2. Compare learning rates
    console.log('\n📊 2. Learning Rate Comparison');
    console.log('─'.repeat(40));
    
    const lrs = [0.01, 0.1, 0.5];
    for (const lr of lrs) {
        const result = gradientDescent(gradientSimple, 10, lr, 50);
        console.log(`  LR = ${lr}: final x = ${result.x[result.x.length - 1].toFixed(4)}, steps = ${result.x.length}`);
    }
    
    // 3. Momentum comparison
    console.log('\n🚀 3. Momentum Comparison');
    console.log('─'.repeat(40));
    
    const gdMomentum = gradientDescentMomentum(gradientSimple, 10, 0.1, 0.9, 50);
    visualizeOptimization(gdMomentum, 'Gradient Descent with Momentum');
    
    // 4. Compare all optimizers
    console.log('\n⚡ 4. Optimizer Comparison');
    console.log('─'.repeat(40));
    
    const optimizers = [
        { name: 'SGD', fn: gradientDescent, params: [gradientSimple, 10, 0.1, 50] },
        { name: 'Momentum', fn: gradientDescentMomentum, params: [gradientSimple, 10, 0.1, 0.9, 50] },
        { name: 'Nesterov', fn: nesterovMomentum, params: [gradientSimple, 10, 0.1, 0.9, 50] },
        { name: 'Adagrad', fn: adagrad, params: [gradientSimple, 10, 1.0, 50] },
        { name: 'RMSprop', fn: rmsprop, params: [gradientSimple, 10, 0.1, 0.9, 50] }
    ];
    
    for (const opt of optimizers) {
        const result = opt.fn(...opt.params);
        const finalX = result.x[result.x.length - 1];
        console.log(`  ${opt.name}: final x = ${finalX.toFixed(4)}, steps = ${result.x.length}`);
    }

    console.log('\n' + '='.repeat(60));
}

runGradientDescentDemo();
```

---

## P4.3 The Adam Optimizer

### The Target
We'll implement the Adam optimizer and understand why it's so effective.

### The Concept

**Adam combines the best of multiple optimizers:**

- **Momentum**: Smooths gradient updates
- **Adaptive learning rates**: Different LR for each parameter
- **Bias correction**: Handles early training instability

```
Adam Update Rules:
1. Compute gradient: g_t
2. Update momentum: m_t = β₁ * m_{t-1} + (1-β₁) * g_t
3. Update variance: v_t = β₂ * v_{t-1} + (1-β₂) * g_t²
4. Bias-correct: m̂_t = m_t / (1-β₁ᵗ), v̂_t = v_t / (1-β₂ᵗ)
5. Update: θ_t = θ_{t-1} - η * m̂_t / (√v̂_t + ε)
```

### The Implementation

```javascript
// 📁 src/primers/optimization/adam.js
/**
 * Adam Optimizer Implementation
 * 
 * Adaptive Moment Estimation optimizer.
 * Combines momentum and adaptive learning rates.
 */

/**
 * Adam optimizer class
 */
export class Adam {
    /**
     * Create an Adam optimizer
     * @param {number} learningRate - Learning rate
     * @param {number} beta1 - Momentum decay (default: 0.9)
     * @param {number} beta2 - Variance decay (default: 0.999)
     * @param {number} epsilon - Small constant for numerical stability
     */
    constructor(learningRate = 0.001, beta1 = 0.9, beta2 = 0.999, epsilon = 1e-8) {
        this.learningRate = learningRate;
        this.beta1 = beta1;
        this.beta2 = beta2;
        this.epsilon = epsilon;
        this.step = 0;
        
        // State for each parameter
        this.m = new Map(); // First moment (momentum)
        this.v = new Map(); // Second moment (variance)
    }

    /**
     * Get or create state for a parameter key
     */
    _getState(key) {
        if (!this.m.has(key)) {
            this.m.set(key, 0);
            this.v.set(key, 0);
        }
        return {
            m: this.m.get(key),
            v: this.v.get(key)
        };
    }

    /**
     * Update a single parameter
     * @param {string} key - Parameter identifier
     * @param {number} gradient - Gradient for this parameter
     * @returns {number} Updated parameter value
     */
    update(key, gradient) {
        this.step++;
        const state = this._getState(key);
        
        // Update biased first moment estimate
        const m = this.beta1 * state.m + (1 - this.beta1) * gradient;
        
        // Update biased second moment estimate
        const v = this.beta2 * state.v + (1 - this.beta2) * gradient * gradient;
        
        // Compute bias-corrected first moment estimate
        const mHat = m / (1 - Math.pow(this.beta1, this.step));
        
        // Compute bias-corrected second moment estimate
        const vHat = v / (1 - Math.pow(this.beta2, this.step));
        
        // Update parameter
        const update = -this.learningRate * mHat / (Math.sqrt(vHat) + this.epsilon);
        
        // Store state
        this.m.set(key, m);
        this.v.set(key, v);
        
        return update;
    }

    /**
     * Update multiple parameters at once
     */
    updateBatch(gradients) {
        const updates = {};
        for (const [key, grad] of Object.entries(gradients)) {
            updates[key] = this.update(key, grad);
        }
        return updates;
    }

    /**
     * Reset optimizer state
     */
    reset() {
        this.m.clear();
        this.v.clear();
        this.step = 0;
    }

    /**
     * Get optimizer configuration
     */
    getConfig() {
        return {
            learningRate: this.learningRate,
            beta1: this.beta1,
            beta2: this.beta2,
            epsilon: this.epsilon,
            step: this.step
        };
    }
}

/**
 * Adam with weight decay (AdamW)
 * Decouples weight decay from adaptive learning rates
 */
export class AdamW {
    /**
     * Create AdamW optimizer
     * @param {number} learningRate - Learning rate
     * @param {number} weightDecay - Weight decay coefficient
     * @param {number} beta1 - Momentum decay
     * @param {number} beta2 - Variance decay
     * @param {number} epsilon - Numerical stability
     */
    constructor(learningRate = 0.001, weightDecay = 0.01, beta1 = 0.9, beta2 = 0.999, epsilon = 1e-8) {
        this.learningRate = learningRate;
        this.weightDecay = weightDecay;
        this.beta1 = beta1;
        this.beta2 = beta2;
        this.epsilon = epsilon;
        this.step = 0;
        this.m = new Map();
        this.v = new Map();
    }

    /**
     * Update with weight decay
     */
    update(key, gradient, currentValue) {
        this.step++;
        const state = this._getState(key);
        
        // Apply weight decay
        const gradDecay = gradient + this.weightDecay * currentValue;
        
        // Standard Adam update
        const m = this.beta1 * state.m + (1 - this.beta1) * gradDecay;
        const v = this.beta2 * state.v + (1 - this.beta2) * gradDecay * gradDecay;
        
        const mHat = m / (1 - Math.pow(this.beta1, this.step));
        const vHat = v / (1 - Math.pow(this.beta2, this.step));
        
        const update = -this.learningRate * mHat / (Math.sqrt(vHat) + this.epsilon);
        
        this.m.set(key, m);
        this.v.set(key, v);
        
        return update;
    }

    _getState(key) {
        if (!this.m.has(key)) {
            this.m.set(key, 0);
            this.v.set(key, 0);
        }
        return {
            m: this.m.get(key),
            v: this.v.get(key)
        };
    }
}

// Example usage
function runAdamDemo() {
    console.log('='.repeat(60));
    console.log('⚡ Adam Optimizer Demo');
    console.log('='.repeat(60));

    // 1. Basic Adam optimization
    console.log('\n📊 1. Adam Optimization');
    console.log('─'.repeat(40));
    
    const adam = new Adam(0.1);
    let x = 10;
    const history = [x];
    
    // Optimize f(x) = x²
    for (let i = 0; i < 20; i++) {
        const grad = 2 * x; // Gradient of x²
        const update = adam.update('x', grad);
        x = x + update;
        history.push(x);
    }
    
    console.log(`  Initial: ${history[0]}`);
    console.log(`  Final: ${history[history.length - 1].toFixed(4)}`);
    console.log(`  Steps: ${adam.step}`);
    console.log(`  Config: ${JSON.stringify(adam.getConfig())}`);
    
    // 2. Compare Adam with SGD
    console.log('\n📊 2. Adam vs SGD Comparison');
    console.log('─'.repeat(40));
    
    // A more complex function: f(x) = x² + 10 * sin(x)
    function complexGradient(x) {
        return 2 * x + 10 * Math.cos(x);
    }
    
    function complexFunction(x) {
        return x * x + 10 * Math.sin(x);
    }
    
    // Run SGD
    let xSGD = 5;
    for (let i = 0; i < 50; i++) {
        xSGD = xSGD - 0.01 * complexGradient(xSGD);
    }
    
    // Run Adam
    const adam2 = new Adam(0.01);
    let xAdam = 5;
    for (let i = 0; i < 50; i++) {
        const grad = complexGradient(xAdam);
        const update = adam2.update('x', grad);
        xAdam = xAdam + update;
    }
    
    console.log(`  SGD final: x = ${xSGD.toFixed(4)}, loss = ${complexFunction(xSGD).toFixed(4)}`);
    console.log(`  Adam final: x = ${xAdam.toFixed(4)}, loss = ${complexFunction(xAdam).toFixed(4)}`);
    
    // 3. AdamW with weight decay
    console.log('\n📊 3. AdamW with Weight Decay');
    console.log('─'.repeat(40));
    
    const adamW = new AdamW(0.01, 0.1);
    let xW = 5;
    for (let i = 0; i < 50; i++) {
        const grad = complexGradient(xW);
        const update = adamW.update('x', grad, xW);
        xW = xW + update;
    }
    console.log(`  AdamW final: x = ${xW.toFixed(4)}, loss = ${complexFunction(xW).toFixed(4)}`);

    console.log('\n' + '='.repeat(60));
}

runAdamDemo();
```

---

## P4.4 Learning Rate Schedules

### The Target
We'll implement different learning rate schedules used in training.

### The Concept

**Learning rate schedules adjust the learning rate during training.**

```
Learning Rate vs Time:
LR
^
|  ●●●●●●        ← Constant
|       \       ← Step decay
|        \      ← Exponential decay
|         \_____← Cosine annealing
+-------------------------> Time
```

### The Implementation

```javascript
// 📁 src/primers/optimization/lr-schedules.js
/**
 * Learning Rate Schedules
 * 
 * Different strategies for adjusting learning rates during training.
 */

/**
 * Base class for learning rate schedulers
 */
export class LRScheduler {
    constructor(initialLR) {
        this.initialLR = initialLR;
        this.currentLR = initialLR;
        this.step = 0;
    }

    /**
     * Get learning rate for current step
     */
    getLR() {
        return this.currentLR;
    }

    /**
     * Update learning rate (call each step)
     */
    step() {
        this.step++;
        this.currentLR = this._computeLR(this.step);
        return this.currentLR;
    }

    /**
     * Compute LR for given step (override)
     */
    _computeLR(step) {
        return this.initialLR;
    }
}

/**
 * Constant learning rate (no schedule)
 */
export class ConstantLR extends LRScheduler {
    _computeLR(step) {
        return this.initialLR;
    }
}

/**
 * Step decay: drop LR by factor every N steps
 */
export class StepLR extends LRScheduler {
    constructor(initialLR, stepSize, gamma = 0.1) {
        super(initialLR);
        this.stepSize = stepSize;
        this.gamma = gamma;
    }

    _computeLR(step) {
        return this.initialLR * Math.pow(this.gamma, Math.floor(step / this.stepSize));
    }
}

/**
 * Exponential decay: LR = initialLR * gamma^step
 */
export class ExponentialLR extends LRScheduler {
    constructor(initialLR, gamma) {
        super(initialLR);
        this.gamma = gamma;
    }

    _computeLR(step) {
        return this.initialLR * Math.pow(this.gamma, step);
    }
}

/**
 * Cosine annealing: LR = initialLR * (1 + cos(π * step / T)) / 2
 */
export class CosineAnnealingLR extends LRScheduler {
    constructor(initialLR, T_max, eta_min = 0) {
        super(initialLR);
        this.T_max = T_max;
        this.eta_min = eta_min;
    }

    _computeLR(step) {
        const progress = step / this.T_max;
        return this.eta_min + (this.initialLR - this.eta_min) * 
            (1 + Math.cos(Math.PI * progress)) / 2;
    }
}

/**
 * Linear warmup: LR increases linearly, then follows another schedule
 */
export class WarmupLR extends LRScheduler {
    constructor(initialLR, warmupSteps, scheduler = null) {
        super(initialLR);
        this.warmupSteps = warmupSteps;
        this.scheduler = scheduler || new ConstantLR(initialLR);
    }

    _computeLR(step) {
        if (step < this.warmupSteps) {
            // Linear warmup
            return this.initialLR * (step / this.warmupSteps);
        } else {
            // Delegate to underlying scheduler
            return this.scheduler._computeLR(step - this.warmupSteps);
        }
    }
}

/**
 * OneCycleLR: Smooth cyclic schedule
 */
export class OneCycleLR extends LRScheduler {
    constructor(initialLR, maxLR, totalSteps, pctStart = 0.3) {
        super(initialLR);
        this.maxLR = maxLR;
        this.totalSteps = totalSteps;
        this.pctStart = pctStart;
        this.annStep = totalSteps * pctStart;
    }

    _computeLR(step) {
        if (step < this.annStep) {
            // Annealing phase: increase from initialLR to maxLR
            const progress = step / this.annStep;
            return this.initialLR + (this.maxLR - this.initialLR) * progress;
        } else {
            // Decay phase: decrease from maxLR to initialLR
            const progress = (step - this.annStep) / (this.totalSteps - this.annStep);
            return this.maxLR - (this.maxLR - this.initialLR) * progress;
        }
    }
}

/**
 * Compare learning rate schedules
 */
export function compareSchedulers(schedulers, steps) {
    const results = {};
    for (const [name, scheduler] of Object.entries(schedulers)) {
        const lrs = [];
        for (let i = 0; i < steps; i++) {
            lrs.push(scheduler.getLR());
            scheduler.step();
        }
        results[name] = lrs;
    }
    return results;
}

// Example usage
function runLRScheduleDemo() {
    console.log('='.repeat(60));
    console.log('📈 Learning Rate Schedules Demo');
    console.log('='.repeat(60));

    // 1. Create different schedulers
    console.log('\n📊 1. Scheduler Comparison');
    console.log('─'.repeat(40));

    const schedulers = {
        'Constant': new ConstantLR(0.01),
        'Step (10 steps)': new StepLR(0.01, 10, 0.5),
        'Exponential (0.9)': new ExponentialLR(0.01, 0.9),
        'Cosine Annealing': new CosineAnnealingLR(0.01, 50),
        'OneCycle': new OneCycleLR(0.001, 0.01, 50)
    };

    const steps = 50;
    const results = compareSchedulers(schedulers, steps);

    console.log('  Learning rates over 50 steps:');
    for (const [name, lrs] of Object.entries(results)) {
        console.log(`\n  ${name}:`);
        console.log(`    Initial: ${lrs[0].toFixed(6)}`);
        console.log(`    Mid: ${lrs[25].toFixed(6)}`);
        console.log(`    Final: ${lrs[lrs.length - 1].toFixed(6)}`);
        console.log(`    Steps: ${lrs.length}`);
    }

    // 2. Warmup
    console.log('\n🌡️ 2. Warmup Scheduler');
    console.log('─'.repeat(40));

    const warmupScheduler = new WarmupLR(0.01, 10, new CosineAnnealingLR(0.01, 40));
    const warmupResults = [];
    for (let i = 0; i < 50; i++) {
        warmupResults.push(warmupScheduler.getLR());
        warmupScheduler.step();
    }

    console.log('  Warmup + Cosine Annealing:');
    console.log(`    Step 0: ${warmupResults[0].toFixed(6)}`);
    console.log(`    Step 5 (warmup): ${warmupResults[5].toFixed(6)}`);
    console.log(`    Step 10 (end warmup): ${warmupResults[10].toFixed(6)}`);
    console.log(`    Step 30: ${warmupResults[30].toFixed(6)}`);
    console.log(`    Step 49: ${warmupResults[49].toFixed(6)}`);

    console.log('\n' + '='.repeat(60));
}

runLRScheduleDemo();
```

---

## P4.5 Batch Size and Training Dynamics

### The Target
We'll understand how batch size affects training.

### The Concept

**Batch size is how many examples we process before updating weights.**

- **Small batch (1-16)**: Noisy but can escape local minima
- **Medium batch (32-128)**: Good balance
- **Large batch (256-2048)**: Stable but can converge to sharp minima

```
Batch Size Effects:
^
|   Small batch:   ○ ○ ○ ○ ○    ← Noisy, escapes easily
|   Medium batch:  ● ● ● ● ●    ← Smooth
|   Large batch:   ▲ ▲ ▲ ▲ ▲    ← Very smooth, may get stuck
+--------------------------------> Time
```

### The Implementation

```javascript
// 📁 src/primers/optimization/batch-training.js
/**
 * Batch Size and Training Dynamics
 * 
 * Effects of batch size on training stability and convergence.
 */

/**
 * Simulate training with different batch sizes
 */
export function simulateBatchTraining(data, model, trainer, batchSizes) {
    const results = {};

    for (const batchSize of batchSizes) {
        console.log(`\n  Simulating batch size ${batchSize}...`);
        
        // Clone model for fair comparison
        // In practice, you'd reset the model
        trainer.batchSize = batchSize;
        
        // Simulate training (simplified)
        const losses = [];
        let steps = 0;
        const totalSteps = Math.floor(data.length / batchSize) * 10; // 10 epochs
        
        for (let step = 0; step < totalSteps; step++) {
            // Random batch
            const batch = [];
            for (let i = 0; i < batchSize; i++) {
                const idx = Math.floor(Math.random() * data.length);
                batch.push(data[idx]);
            }
            
            // Simulate loss (simplified: decreasing with noise proportional to batch size)
            const noise = 0.01 / Math.sqrt(batchSize);
            const loss = Math.exp(-step / (totalSteps / 10)) + (Math.random() - 0.5) * noise;
            losses.push(loss);
        }
        
        results[batchSize] = {
            finalLoss: losses[losses.length - 1],
            volatility: calculateVolatility(losses)
        };
    }

    return results;
}

/**
 * Calculate volatility of loss curve
 */
function calculateVolatility(losses) {
    let volatility = 0;
    for (let i = 1; i < losses.length; i++) {
        volatility += Math.abs(losses[i] - losses[i - 1]);
    }
    return volatility / (losses.length - 1);
}

/**
 * Optimal batch size guidelines
 */
export function batchSizeGuidelines() {
    return {
        '1-16': {
            description: 'Very small batch',
            advantages: ['Memory efficient', 'Can escape local minima'],
            disadvantages: ['High noise', 'Slow convergence'],
            bestFor: ['Small datasets', 'Online learning']
        },
        '32-128': {
            description: 'Small to medium batch',
            advantages: ['Good balance', 'Fast convergence'],
            disadvantages: ['Moderate memory usage'],
            bestFor: ['Most tasks', 'Standard training']
        },
        '256-1024': {
            description: 'Large batch',
            advantages: ['Stable gradients', 'Efficient GPU usage'],
            disadvantages: ['May converge to sharp minima', 'Memory intensive'],
            bestFor: ['Large datasets', 'Distributed training']
        },
        '1024+': {
            description: 'Very large batch',
            advantages: ['Maximum efficiency', 'Very stable'],
            disadvantages: ['Poor generalization', 'Memory heavy'],
            bestFor: ['Large models', 'When memory allows']
        }
    };
}

// Example usage
function runBatchSizeDemo() {
    console.log('='.repeat(60));
    console.log('📦 Batch Size Training Demo');
    console.log('='.repeat(60));

    // 1. Batch size effects
    console.log('\n📊 1. Batch Size Effects');
    console.log('─'.repeat(40));

    // Simulate data
    const mockData = Array.from({ length: 1000 }, (_, i) => ({
        input: [i % 10],
        output: [i % 10]
    }));

    // Simulate for different batch sizes
    const batchSizes = [1, 8, 32, 128, 512];
    
    console.log('  Simulated training results:');
    console.log('  (Lower loss and volatility = better)');
    console.log('  Losses shown are simulated for demonstration');
    
    for (const batchSize of batchSizes) {
        // Simulated results
        const noise = 0.01 / Math.sqrt(batchSize);
        const finalLoss = 0.1 + noise;
        const volatility = 0.05 * noise * 10;
        
        console.log(`\n  Batch size ${batchSize}:`);
        console.log(`    Approx final loss: ${finalLoss.toFixed(4)}`);
        console.log(`    Approx volatility: ${volatility.toFixed(4)}`);
    }

    // 2. Guidelines
    console.log('\n📚 2. Batch Size Guidelines');
    console.log('─'.repeat(40));

    const guidelines = batchSizeGuidelines();
    for (const [size, info] of Object.entries(guidelines)) {
        console.log(`\n  ${size}: ${info.description}`);
        console.log(`    Advantages: ${info.advantages.join(', ')}`);
        console.log(`    Disadvantages: ${info.disadvantages.join(', ')}`);
        console.log(`    Best for: ${info.bestFor.join(', ')}`);
    }

    // 3. Practical recommendations
    console.log('\n💡 3. Practical Recommendations');
    console.log('─'.repeat(40));
    console.log('  For most LLM training:');
    console.log('    • Start with batch size 32-128');
    console.log('    • Scale up if you have more GPUs');
    console.log('    • Use gradient accumulation for large effective batch');
    console.log('    • Monitor loss for stability');
    console.log('    • Adjust learning rate with batch size (√batch)');

    console.log('\n' + '='.repeat(60));
}

runBatchSizeDemo();
```

---

## P4.6 Practice Exercises

### Exercise 1: Optimizer Comparison
**Task**: Compare SGD, Momentum, and Adam on a challenging function.

```javascript
function compareOptimizers() {
    // 1. Define a complex function with multiple local minima
    // 2. Run each optimizer
    // 3. Compare convergence speed and final loss
    // 4. Visualize the paths
    
    // HINT: Use gradientDescent, gradientDescentMomentum, and Adam
    // HINT: Track the path of each optimizer
}
```

### Exercise 2: Learning Rate Schedule
**Task**: Implement and test different learning rate schedules.

```javascript
function testLRSchedules() {
    // 1. Create a simple training scenario
    // 2. Run with different schedules
    // 3. Compare convergence
    // 4. Find the best schedule
    
    // HINT: Use LRScheduler classes
    // HINT: Track loss over time
}
```

### Exercise 3: Batch Size Analysis
**Task**: Analyze the effect of batch size on training.

```javascript
function analyzeBatchSize() {
    // 1. Train with different batch sizes
    // 2. Track loss and validation performance
    // 3. Measure training time
    // 4. Find optimal batch size
    
    // HINT: Use different batch sizes
    // HINT: Track both training loss and validation accuracy
}
```

### Exercise 4: Gradient Clipping
**Task**: Implement gradient clipping and test its effects.

```javascript
function testGradientClipping() {
    // 1. Create a scenario with exploding gradients
    // 2. Train with and without clipping
    // 3. Compare stability and final performance
    // 4. Report findings
    
    // HINT: Use gradientClip function
    // HINT: Monitor gradient norms
}
```

---

## P4.7 Quick Reference Card

```javascript
// QUICK REFERENCE - OPTIMIZATION

// GRADIENT DESCENT
θ_new = θ_old - η * ∇L(θ_old)

// MOMENTUM
v_t = β * v_{t-1} - η * ∇L(θ_{t-1})
θ_t = θ_{t-1} + v_t

// ADAM
m_t = β₁ * m_{t-1} + (1-β₁) * g_t
v_t = β₂ * v_{t-1} + (1-β₂) * g_t²
m̂_t = m_t / (1-β₁ᵗ)
v̂_t = v_t / (1-β₂ᵗ)
θ_t = θ_{t-1} - η * m̂_t / (√v̂_t + ε)

// LEARNING RATE SCHEDULES
Step:     LR_t = LR_0 * γ^floor(t/s)
Exponential: LR_t = LR_0 * γ^t
Cosine:   LR_t = LR_min + (LR_0-LR_min) * (1 + cos(π*t/T))/2

// PARAMETER RECOMMENDATIONS
Learning Rate: 1e-5 to 1e-3 (Adam), 0.01 to 0.1 (SGD)
Batch Size: 32-128 (start), scale as needed
Beta1 (Adam): 0.9
Beta2 (Adam): 0.999
Epsilon (Adam): 1e-8

// GRADIENT CLIPPING
if ||g|| > max_norm:
    g = g * max_norm / ||g||

// WARMUP
LR_t = LR_0 * t / warmup_steps for t < warmup_steps
LR_t = schedule(t) for t >= warmup_steps

// BATCH SIZE EFFECTS
Small (1-16): Noisy, escapes minima
Medium (32-128): Balanced, recommended
Large (256-2048): Stable, may get stuck

// COMMON PRACTICES
- Use Adam/AdamW for most tasks
- Start with LR = 1e-4 for transformers
- Use warmup for large models
- Clip gradients to prevent exploding
- Monitor loss for signs of instability
```

---

**[END OF PRIMER 4]**

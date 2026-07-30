# Primer 3: Neural Networks and Deep Learning Fundamentals

This primer provides a comprehensive introduction to neural networks and deep learning concepts essential for understanding LLMs. If you've ever wondered how models actually "learn" or what happens during training, this guide will explain it all with intuitive analogies and practical JavaScript examples.

---

## P3.1 Why Neural Networks Matter for LLMs

### The Core Insight

**LLMs are very large, very deep neural networks.**

Everything you've built—tokenization, embeddings, attention—is ultimately a neural network. Understanding the fundamentals helps you understand:
- How models learn from data
- Why training takes so long
- What gradients and backpropagation do
- How to debug training issues

### What You'll Learn

| Concept | Why It Matters | Where Used |
|---------|---------------|------------|
| **Neurons** | Basic building blocks | Every layer |
| **Activation Functions** | Add non-linearity | Feed-forward, attention |
| **Forward Pass** | Computing outputs | Inference, training |
| **Backpropagation** | Learning from errors | Training |
| **Loss Functions** | Measuring performance | Training objective |
| **Optimization** | Updating weights | SGD, Adam |
| **Regularization** | Preventing overfitting | Dropout, weight decay |

---

## P3.2 The Neuron: Building Block of Neural Networks

### The Target
We'll implement a neuron from scratch and understand how it works.

### The Concept

**Think of a neuron like a decision-maker.**

A neuron receives inputs, weighs their importance, and makes a decision:

```
Inputs → Multiply by weights → Sum → Activation → Output

Example:
Input: [0.8, 0.2, 0.5]
Weights: [0.3, -0.1, 0.4]
Bias: 0.1

Sum = 0.8*0.3 + 0.2*(-0.1) + 0.5*0.4 + 0.1 = 0.24 - 0.02 + 0.20 + 0.1 = 0.52
Output = activation(0.52) ≈ 0.63
```

### The Implementation

```javascript
// 📁 src/primers/neural/neuron.js
/**
 * The Neuron: Basic Building Block
 * 
 * Implements a single neuron with weights, bias, and activation.
 */

import { normalRandom } from '../math/vectors.js';

/**
 * A single neuron
 */
export class Neuron {
    /**
     * Create a neuron
     * @param {number} numInputs - Number of input connections
     * @param {string} activation - Activation function type
     */
    constructor(numInputs, activation = 'sigmoid') {
        // Initialize weights randomly (Xavier initialization)
        const scale = Math.sqrt(2.0 / numInputs);
        this.weights = Array.from({ length: numInputs }, () => normalRandom(0, scale));
        this.bias = normalRandom(0, 0.1);
        this.activation = activation;
        
        // Cache for training
        this.lastInput = null;
        this.lastOutput = null;
        this.lastSum = null;
    }

    /**
     * Forward pass: compute output from input
     */
    forward(inputs) {
        if (inputs.length !== this.weights.length) {
            throw new Error(`Expected ${this.weights.length} inputs, got ${inputs.length}`);
        }

        // Compute weighted sum: ∑(w_i * x_i) + bias
        let sum = this.bias;
        for (let i = 0; i < inputs.length; i++) {
            sum += this.weights[i] * inputs[i];
        }

        this.lastInput = inputs;
        this.lastSum = sum;

        // Apply activation function
        const output = this.activate(sum);
        this.lastOutput = output;

        return output;
    }

    /**
     * Activation functions
     */
    activate(x) {
        switch (this.activation) {
            case 'sigmoid':
                return 1 / (1 + Math.exp(-x));
            case 'tanh':
                return Math.tanh(x);
            case 'relu':
                return Math.max(0, x);
            case 'leaky_relu':
                return x > 0 ? x : 0.01 * x;
            default:
                return x; // Linear
        }
    }

    /**
     * Derivative of activation function (for backpropagation)
     */
    activateDerivative(x) {
        switch (this.activation) {
            case 'sigmoid': {
                const sig = 1 / (1 + Math.exp(-x));
                return sig * (1 - sig);
            }
            case 'tanh':
                return 1 - Math.tanh(x) ** 2;
            case 'relu':
                return x > 0 ? 1 : 0;
            case 'leaky_relu':
                return x > 0 ? 1 : 0.01;
            default:
                return 1;
        }
    }

    /**
     * Get number of parameters
     */
    getNumParams() {
        return this.weights.length + 1; // weights + bias
    }
}

/**
 * Layer: Collection of neurons
 */
export class Layer {
    /**
     * Create a layer
     * @param {number} numNeurons - Number of neurons in layer
     * @param {number} numInputs - Number of inputs to each neuron
     * @param {string} activation - Activation function
     */
    constructor(numNeurons, numInputs, activation = 'sigmoid') {
        this.neurons = Array.from(
            { length: numNeurons },
            () => new Neuron(numInputs, activation)
        );
        this.numNeurons = numNeurons;
        this.numInputs = numInputs;
        this.lastOutputs = null;
    }

    /**
     * Forward pass through layer
     */
    forward(inputs) {
        const outputs = this.neurons.map(neuron => neuron.forward(inputs));
        this.lastOutputs = outputs;
        return outputs;
    }

    /**
     * Get weights matrix for this layer
     */
    getWeights() {
        return this.neurons.map(neuron => neuron.weights);
    }

    /**
     * Get biases for this layer
     */
    getBiases() {
        return this.neurons.map(neuron => neuron.bias);
    }

    /**
     * Get number of parameters
     */
    getNumParams() {
        return this.neurons.reduce((sum, n) => sum + n.getNumParams(), 0);
    }
}

/**
 * Neural Network: Multi-layer perceptron
 */
export class NeuralNetwork {
    /**
     * Create a neural network
     * @param {number[]} layerSizes - [input, hidden1, hidden2, ..., output]
     * @param {string} activation - Activation function for hidden layers
     * @param {string} outputActivation - Activation for output layer
     */
    constructor(layerSizes, activation = 'relu', outputActivation = 'sigmoid') {
        if (layerSizes.length < 2) {
            throw new Error('Network must have at least 2 layers');
        }

        this.layers = [];
        for (let i = 0; i < layerSizes.length - 1; i++) {
            const isOutput = i === layerSizes.length - 2;
            const act = isOutput ? outputActivation : activation;
            this.layers.push(new Layer(layerSizes[i + 1], layerSizes[i], act));
        }

        this.layerSizes = layerSizes;
        this.lastInputs = null;
        this.lastOutputs = null;
    }

    /**
     * Forward pass through network
     */
    forward(inputs) {
        let current = inputs;
        this.lastInputs = [];

        for (const layer of this.layers) {
            this.lastInputs.push(current);
            current = layer.forward(current);
        }

        this.lastOutputs = current;
        return current;
    }

    /**
     * Predict (forward pass)
     */
    predict(inputs) {
        return this.forward(inputs);
    }

    /**
     * Get all parameters (weights and biases)
     */
    getParameters() {
        const params = [];
        for (const layer of this.layers) {
            for (const neuron of layer.neurons) {
                params.push(...neuron.weights);
                params.push(neuron.bias);
            }
        }
        return params;
    }

    /**
     * Set parameters
     */
    setParameters(params) {
        let idx = 0;
        for (const layer of this.layers) {
            for (const neuron of layer.neurons) {
                for (let i = 0; i < neuron.weights.length; i++) {
                    neuron.weights[i] = params[idx++];
                }
                neuron.bias = params[idx++];
            }
        }
    }

    /**
     * Get number of parameters
     */
    getNumParams() {
        return this.layers.reduce((sum, layer) => sum + layer.getNumParams(), 0);
    }

    /**
     * Save model
     */
    save() {
        return {
            layerSizes: this.layerSizes,
            weights: this.layers.map(layer => layer.getWeights()),
            biases: this.layers.map(layer => layer.getBiases())
        };
    }

    /**
     * Load model
     */
    load(data) {
        this.layerSizes = data.layerSizes;
        // Recreate layers
        this.layers = [];
        for (let i = 0; i < data.weights.length; i++) {
            const numNeurons = data.weights[i].length;
            const numInputs = data.weights[i][0].length;
            const isOutput = i === data.weights.length - 1;
            const act = isOutput ? 'sigmoid' : 'relu';
            const layer = new Layer(numNeurons, numInputs, act);
            
            // Set weights and biases
            for (let n = 0; n < numNeurons; n++) {
                layer.neurons[n].weights = data.weights[i][n];
                layer.neurons[n].bias = data.biases[i][n];
            }
            
            this.layers.push(layer);
        }
    }
}

// Example usage
function runNeuronDemo() {
    console.log('='.repeat(60));
    console.log('🧠 Neuron and Neural Network Demo');
    console.log('='.repeat(60));

    // 1. Single neuron
    console.log('\n📊 1. Single Neuron');
    console.log('─'.repeat(40));

    const neuron = new Neuron(3, 'sigmoid');
    console.log(`  Weights: [${neuron.weights.map(w => w.toFixed(3)).join(', ')}]`);
    console.log(`  Bias: ${neuron.bias.toFixed(3)}`);

    const input = [0.8, 0.2, 0.5];
    const output = neuron.forward(input);
    console.log(`  Input: [${input.join(', ')}]`);
    console.log(`  Output: ${output.toFixed(4)}`);

    // 2. Neural Network (XOR problem)
    console.log('\n🔄 2. XOR Problem');
    console.log('─'.repeat(40));

    // XOR training data
    const xorData = [
        { input: [0, 0], output: [0] },
        { input: [0, 1], output: [1] },
        { input: [1, 0], output: [1] },
        { input: [1, 1], output: [0] }
    ];

    const net = new NeuralNetwork([2, 4, 1], 'relu', 'sigmoid');
    console.log(`  Network: 2 → 4 → 1`);
    console.log(`  Parameters: ${net.getNumParams()}`);

    console.log('\n  Initial predictions:');
    for (const data of xorData) {
        const pred = net.predict(data.input);
        console.log(`    ${data.input} → ${pred[0].toFixed(4)} (expected: ${data.output[0]})`);
    }

    // 3. Activation functions comparison
    console.log('\n📈 3. Activation Functions');
    console.log('─'.repeat(40));

    const activations = ['sigmoid', 'tanh', 'relu', 'leaky_relu'];
    const x = [-3, -2, -1, 0, 1, 2, 3];

    for (const act of activations) {
        const testNeuron = new Neuron(1, act);
        console.log(`\n  ${act}:`);
        const values = x.map(v => testNeuron.activate(v));
        console.log(`    f(-2) = ${testNeuron.activate(-2).toFixed(3)}`);
        console.log(`    f(0)  = ${testNeuron.activate(0).toFixed(3)}`);
        console.log(`    f(2)  = ${testNeuron.activate(2).toFixed(3)}`);
    }

    console.log('\n' + '='.repeat(60));
}

runNeuronDemo();
```

---

## P3.3 Forward Pass and Backpropagation

### The Target
We'll implement forward pass and backpropagation for a neural network.

### The Concept

**Forward pass: "What do I predict?"**
- Input flows through the network
- Each layer computes outputs
- Final layer produces predictions

**Backpropagation: "How do I get better?"**
- Compare predictions to truth (loss)
- Compute gradients backwards
- Update weights to reduce loss

```
Forward Pass:  Input → Layer1 → Layer2 → Output → Loss
Backprop:      Loss ← Layer2 ← Layer1 ← Input ← Gradients
```

### The Implementation

```javascript
// 📁 src/primers/neural/training.js
/**
 * Forward Pass and Backpropagation
 * 
 * Implements training for neural networks using gradient descent.
 */

import { Neuron, Layer, NeuralNetwork } from './neuron.js';

/**
 * Loss functions
 */
export class Loss {
    /**
     * Mean Squared Error (MSE) for regression
     */
    static mse(predicted, target) {
        let sum = 0;
        for (let i = 0; i < predicted.length; i++) {
            sum += (predicted[i] - target[i]) ** 2;
        }
        return sum / predicted.length;
    }

    /**
     * MSE derivative
     */
    static mseDerivative(predicted, target) {
        return predicted.map((p, i) => 2 * (p - target[i]) / predicted.length);
    }

    /**
     * Binary Cross-Entropy (BCE) for classification
     */
    static binaryCrossEntropy(predicted, target) {
        let sum = 0;
        for (let i = 0; i < predicted.length; i++) {
            const p = Math.max(predicted[i], 1e-8);
            const t = target[i];
            sum -= t * Math.log(p) + (1 - t) * Math.log(1 - p);
        }
        return sum / predicted.length;
    }

    /**
     * BCE derivative
     */
    static binaryCrossEntropyDerivative(predicted, target) {
        return predicted.map((p, i) => {
            const pClamped = Math.max(Math.min(p, 0.9999), 0.0001);
            return (pClamped - target[i]) / (pClamped * (1 - pClamped));
        });
    }
}

/**
 * Training the network
 */
export class Trainer {
    /**
     * Create a trainer
     * @param {NeuralNetwork} network - Network to train
     * @param {Object} config - Training configuration
     */
    constructor(network, config = {}) {
        this.network = network;
        this.learningRate = config.learningRate || 0.01;
        this.lossFunction = config.lossFunction || 'mse';
        this.batchSize = config.batchSize || 1;
        this.epochs = config.epochs || 100;
        
        // Training history
        this.history = {
            losses: [],
            valLosses: []
        };
    }

    /**
     * Compute gradients via backpropagation
     */
    backward(input, target) {
        // 1. Forward pass
        const output = this.network.forward(input);
        
        // 2. Compute output error (loss derivative)
        let error;
        if (this.lossFunction === 'mse') {
            error = Loss.mseDerivative(output, target);
        } else if (this.lossFunction === 'bce') {
            error = Loss.binaryCrossEntropyDerivative(output, target);
        } else {
            throw new Error(`Unknown loss function: ${this.lossFunction}`);
        }
        
        // 3. Backpropagate through layers (in reverse)
        const gradients = [];
        
        for (let layerIdx = this.network.layers.length - 1; layerIdx >= 0; layerIdx--) {
            const layer = this.network.layers[layerIdx];
            const layerGradients = [];
            
            // Compute gradients for each neuron in this layer
            for (let n = 0; n < layer.neurons.length; n++) {
                const neuron = layer.neurons[n];
                const neuronError = error[n];
                
                // Derivative of activation
                const activationDeriv = neuron.activateDerivative(neuron.lastSum);
                const delta = neuronError * activationDeriv;
                
                // Compute weight gradients (∂L/∂w)
                const weightGrads = neuron.lastInput.map(x => delta * x);
                const biasGrad = delta;
                
                layerGradients.push({
                    weightGrads: weightGrads,
                    biasGrad: biasGrad
                });
                
                // Propagate error to previous layer
                if (layerIdx > 0) {
                    const prevLayer = this.network.layers[layerIdx - 1];
                    for (let p = 0; p < prevLayer.neurons.length; p++) {
                        error[p] = (error[p] || 0) + delta * neuron.weights[p];
                    }
                }
            }
            
            gradients.push({
                layerIndex: layerIdx,
                gradients: layerGradients
            });
        }
        
        return {
            output: output,
            gradients: gradients.reverse() // Reverse to match layer order
        };
    }

    /**
     * Update weights using gradients
     */
    updateWeights(gradients) {
        for (const gradInfo of gradients) {
            const layer = this.network.layers[gradInfo.layerIndex];
            const layerGrads = gradInfo.gradients;
            
            for (let n = 0; n < layer.neurons.length; n++) {
                const neuron = layer.neurons[n];
                const grad = layerGrads[n];
                
                // Update weights
                for (let i = 0; i < neuron.weights.length; i++) {
                    neuron.weights[i] -= this.learningRate * grad.weightGrads[i];
                }
                neuron.bias -= this.learningRate * grad.biasGrad;
            }
        }
    }

    /**
     * Train on a single example
     */
    trainStep(input, target) {
        const { output, gradients } = this.backward(input, target);
        this.updateWeights(gradients);
        
        // Compute loss
        let loss;
        if (this.lossFunction === 'mse') {
            loss = Loss.mse(output, target);
        } else if (this.lossFunction === 'bce') {
            loss = Loss.binaryCrossEntropy(output, target);
        }
        
        return {
            loss: loss,
            output: output
        };
    }

    /**
     * Train on entire dataset
     */
    train(data, valData = null) {
        console.log(`[Trainer] Starting training on ${data.length} samples`);
        console.log(`[Trainer] Learning rate: ${this.learningRate}`);
        console.log(`[Trainer] Loss function: ${this.lossFunction}`);
        
        for (let epoch = 0; epoch < this.epochs; epoch++) {
            // Shuffle data
            const shuffled = [...data];
            for (let i = shuffled.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
            }
            
            let totalLoss = 0;
            let batchLoss = 0;
            
            for (let i = 0; i < shuffled.length; i++) {
                const { input, output } = shuffled[i];
                const result = this.trainStep(input, output);
                
                totalLoss += result.loss;
                batchLoss += result.loss;
                
                // Log batch progress
                if ((i + 1) % this.batchSize === 0) {
                    const avgBatchLoss = batchLoss / this.batchSize;
                    // console.log(`  Batch ${i / this.batchSize + 1}: Loss = ${avgBatchLoss.toFixed(4)}`);
                    batchLoss = 0;
                }
            }
            
            const avgLoss = totalLoss / shuffled.length;
            this.history.losses.push(avgLoss);
            
            // Validation
            let valLoss = null;
            if (valData) {
                valLoss = this.evaluate(valData);
                this.history.valLosses.push(valLoss);
            }
            
            // Log progress
            if (epoch % 10 === 0 || epoch === this.epochs - 1) {
                console.log(`  Epoch ${epoch + 1}/${this.epochs}: Train Loss = ${avgLoss.toFixed(4)}` + 
                    (valLoss !== null ? `, Val Loss = ${valLoss.toFixed(4)}` : ''));
            }
        }
        
        console.log('[Trainer] Training complete!');
        return this.history;
    }

    /**
     * Evaluate network on data
     */
    evaluate(data) {
        let totalLoss = 0;
        for (const item of data) {
            const { input, output } = item;
            const prediction = this.network.predict(input);
            
            let loss;
            if (this.lossFunction === 'mse') {
                loss = Loss.mse(prediction, output);
            } else if (this.lossFunction === 'bce') {
                loss = Loss.binaryCrossEntropy(prediction, output);
            }
            
            totalLoss += loss;
        }
        return totalLoss / data.length;
    }

    /**
     * Predict (forward pass only)
     */
    predict(input) {
        return this.network.predict(input);
    }
}

// Example: Training XOR
function runTrainingDemo() {
    console.log('='.repeat(60));
    console.log('🔄 Training Demo: XOR Problem');
    console.log('='.repeat(60));

    // XOR dataset
    const xorData = [
        { input: [0, 0], output: [0] },
        { input: [0, 1], output: [1] },
        { input: [1, 0], output: [1] },
        { input: [1, 1], output: [0] }
    ];

    // Split into train and validation
    const trainData = xorData.slice(0, 3);
    const valData = xorData.slice(3);

    // Create network
    const net = new NeuralNetwork([2, 4, 1], 'relu', 'sigmoid');
    console.log(`\n  Network: 2 → 4 → 1`);
    console.log(`  Parameters: ${net.getNumParams()}`);

    // Train
    const trainer = new Trainer(net, {
        learningRate: 0.5,
        lossFunction: 'mse',
        epochs: 200
    });

    console.log('\n  Training...');
    trainer.train(trainData, valData);

    // Test
    console.log('\n  Final predictions:');
    for (const data of xorData) {
        const pred = trainer.predict(data.input);
        console.log(`    ${data.input} → ${pred[0].toFixed(4)} (expected: ${data.output[0]})`);
    }

    // Accuracy
    let correct = 0;
    for (const data of xorData) {
        const pred = trainer.predict(data.input);
        const predictedClass = pred[0] > 0.5 ? 1 : 0;
        if (predictedClass === data.output[0]) correct++;
    }
    console.log(`\n  Accuracy: ${correct}/${xorData.length} (${(correct/xorData.length*100).toFixed(0)}%)`);

    console.log('\n' + '='.repeat(60));
}

runTrainingDemo();
```

---

## P3.4 Activation Functions Deep Dive

### The Target
We'll implement and compare different activation functions.

### The Concept

**Activation functions add non-linearity to the network.**

Without activation functions, neural networks would just be linear transformations. Activation functions allow them to learn complex patterns:

```
Linear:   y = wx + b        (cannot learn XOR)
Nonlinear: y = σ(wx + b)    (can learn XOR)
```

### The Implementation

```javascript
// 📁 src/primers/neural/activations.js
/**
 * Activation Functions
 * 
 * Comprehensive activation functions with properties and derivatives.
 */

/**
 * Activation function registry
 */
export const Activations = {
    /**
     * Sigmoid: S-shaped curve, outputs (0,1)
     * Used for: Binary classification, output layer
     * Pros: Smooth gradient, interpretable
     * Cons: Vanishing gradient for extreme values
     */
    sigmoid: {
        forward: (x) => 1 / (1 + Math.exp(-x)),
        derivative: (x) => {
            const sig = 1 / (1 + Math.exp(-x));
            return sig * (1 - sig);
        },
        range: [0, 1],
        name: 'Sigmoid'
    },

    /**
     * Tanh: S-shaped curve, outputs (-1,1)
     * Used for: Hidden layers, embedding layers
     * Pros: Zero-centered, better gradients than sigmoid
     * Cons: Still has vanishing gradient
     */
    tanh: {
        forward: (x) => Math.tanh(x),
        derivative: (x) => 1 - Math.tanh(x) ** 2,
        range: [-1, 1],
        name: 'Tanh'
    },

    /**
     * ReLU: Rectified Linear Unit
     * Used for: Hidden layers (most common)
     * Pros: Fast, no vanishing gradient, sparse activations
     * Cons: Dead neurons (dying ReLU)
     */
    relu: {
        forward: (x) => Math.max(0, x),
        derivative: (x) => x > 0 ? 1 : 0,
        range: [0, Infinity],
        name: 'ReLU'
    },

    /**
     * Leaky ReLU: ReLU with small slope for negatives
     * Used for: Hidden layers (when ReLU causes dead neurons)
     * Pros: Prevents dying ReLU
     * Cons: Slightly more computation
     */
    leaky_relu: {
        forward: (x) => x > 0 ? x : 0.01 * x,
        derivative: (x) => x > 0 ? 1 : 0.01,
        range: [-Infinity, Infinity],
        name: 'Leaky ReLU'
    },

    /**
     * ELU: Exponential Linear Unit
     * Used for: Hidden layers (when negative values are useful)
     * Pros: Zero-centered, smooth negative values
     * Cons: Computationally expensive
     */
    elu: {
        forward: (x) => x > 0 ? x : Math.exp(x) - 1,
        derivative: (x) => x > 0 ? 1 : Math.exp(x),
        range: [-1, Infinity],
        name: 'ELU'
    },

    /**
     * GELU: Gaussian Error Linear Unit
     * Used for: Modern transformers (GPT, BERT)
     * Pros: Smooth approximation, better performance
     * Cons: Computationally expensive
     */
    gelu: {
        forward: (x) => {
            // Approximation: x * sigmoid(1.702 * x)
            return x * 1 / (1 + Math.exp(-1.702 * x));
        },
        derivative: (x) => {
            const sig = 1 / (1 + Math.exp(-1.702 * x));
            return sig + 1.702 * x * sig * (1 - sig);
        },
        range: [-0.17, Infinity],
        name: 'GELU'
    },

    /**
     * Swish: Self-gated activation
     * Used for: Research, some modern architectures
     * Pros: Smooth, non-monotonic, better than ReLU
     * Cons: More parameters
     */
    swish: {
        forward: (x, beta = 1) => x * 1 / (1 + Math.exp(-beta * x)),
        derivative: (x, beta = 1) => {
            const sig = 1 / (1 + Math.exp(-beta * x));
            return sig + beta * x * sig * (1 - sig);
        },
        range: [-0.27, Infinity],
        name: 'Swish'
    },

    /**
     * Softmax: Exponential normalization
     * Used for: Output layer (multi-class classification)
     * Pros: Outputs sum to 1, interpretable as probabilities
     * Cons: Not used in hidden layers
     */
    softmax: {
        forward: (x) => {
            const maxVal = Math.max(...x);
            const exp = x.map(v => Math.exp(v - maxVal));
            const sum = exp.reduce((a, b) => a + b, 0);
            return exp.map(v => v / sum);
        },
        derivative: (x) => {
            // Softmax derivative is a Jacobian matrix
            // Simplified: just the diagonal for single outputs
            return x.map(p => p * (1 - p));
        },
        range: [0, 1],
        name: 'Softmax'
    }
};

/**
 * Compare activation functions
 */
export function compareActivations(xValues) {
    const results = {};
    for (const [name, activation] of Object.entries(Activations)) {
        results[name] = xValues.map(x => ({
            x: x,
            y: activation.forward(x),
            dy: activation.derivative(x)
        }));
    }
    return results;
}

/**
 * Activation analysis
 */
export function analyzeActivation(name, x) {
    const activation = Activations[name];
    if (!activation) {
        throw new Error(`Unknown activation: ${name}`);
    }
    return {
        name: activation.name,
        input: x,
        output: activation.forward(x),
        derivative: activation.derivative(x),
        range: activation.range
    };
}

// Example usage
function runActivationDemo() {
    console.log('='.repeat(60));
    console.log('📈 Activation Functions Comparison');
    console.log('='.repeat(60));

    const xValues = [-3, -2, -1, 0, 1, 2, 3];

    console.log('\n  Comparison of activation functions:');
    console.log('─'.repeat(40));

    for (const [name, activation] of Object.entries(Activations)) {
        console.log(`\n  ${name}:`);
        console.log(`    Range: [${activation.range[0]}, ${activation.range[1]}]`);
        console.log(`    f(-1) = ${activation.forward(-1).toFixed(3)}, f(0) = ${activation.forward(0).toFixed(3)}, f(1) = ${activation.forward(1).toFixed(3)}`);
        console.log(`    f'(-1) = ${activation.derivative(-1).toFixed(3)}, f'(0) = ${activation.derivative(0).toFixed(3)}, f'(1) = ${activation.derivative(1).toFixed(3)}`);
    }

    // Softmax example
    console.log('\n  Softmax Example:');
    console.log('─'.repeat(40));
    const logits = [2.0, 1.0, 0.5];
    const probs = Activations.softmax.forward(logits);
    console.log(`  Logits: [${logits.join(', ')}]`);
    console.log(`  Probabilities: [${probs.map(p => p.toFixed(3)).join(', ')}]`);
    console.log(`  Sum: ${probs.reduce((a, b) => a + b, 0).toFixed(3)}`);

    console.log('\n' + '='.repeat(60));
}

runActivationDemo();
```

---

## P3.5 Regularization Techniques

### The Target
We'll implement dropout and weight decay for better generalization.

### The Concept

**Regularization prevents overfitting.**

- **Overfitting**: Model memorizes training data, fails on new data
- **Dropout**: Randomly turn off neurons during training
- **Weight Decay**: Penalize large weights

```
Without Regularization:     With Dropout:
All neurons active          Random neurons disabled
Model memorizes patterns    Model learns robust features
Poor generalization         Better generalization
```

### The Implementation

```javascript
// 📁 src/primers/neural/regularization.js
/**
 * Regularization Techniques
 * 
 * Dropout, weight decay, and other regularization methods.
 */

/**
 * Dropout layer
 * Randomly sets inputs to zero during training
 */
export class Dropout {
    /**
     * Create a dropout layer
     * @param {number} rate - Dropout rate (0-1)
     */
    constructor(rate = 0.5) {
        this.rate = rate;
        this.mask = null;
        this.training = true;
    }

    /**
     * Forward pass with dropout
     */
    forward(inputs) {
        if (this.training) {
            // Create mask: 1 with probability (1-rate), 0 with probability rate
            this.mask = inputs.map(() => Math.random() > this.rate ? 1 : 0);
            return inputs.map((v, i) => v * this.mask[i]);
        } else {
            // At test time, scale by (1-rate)
            const scale = 1 - this.rate;
            return inputs.map(v => v * scale);
        }
    }

    /**
     * Set training mode
     */
    setTraining(mode) {
        this.training = mode;
    }
}

/**
 * Apply L2 regularization (weight decay)
 */
export function l2Regularization(weights, lambda = 0.01) {
    let loss = 0;
    for (const w of weights) {
        loss += w * w;
    }
    return lambda * loss / 2;
}

/**
 * Apply L1 regularization (sparsity)
 */
export function l1Regularization(weights, lambda = 0.01) {
    let loss = 0;
    for (const w of weights) {
        loss += Math.abs(w);
    }
    return lambda * loss;
}

/**
 * Apply gradient clipping
 */
export function gradientClip(gradients, maxNorm = 1.0) {
    let norm = 0;
    for (const g of gradients) {
        norm += g * g;
    }
    norm = Math.sqrt(norm);
    
    if (norm > maxNorm) {
        const scale = maxNorm / norm;
        return gradients.map(g => g * scale);
    }
    return gradients;
}

/**
 * Early stopping
 */
export class EarlyStopping {
    /**
     * Create early stopping
     * @param {number} patience - Number of epochs to wait
     * @param {number} minDelta - Minimum change to consider improvement
     */
    constructor(patience = 10, minDelta = 1e-4) {
        this.patience = patience;
        this.minDelta = minDelta;
        this.bestLoss = Infinity;
        this.counter = 0;
        this.shouldStop = false;
    }

    /**
     * Update early stopping state
     */
    update(valLoss) {
        if (valLoss < this.bestLoss - this.minDelta) {
            this.bestLoss = valLoss;
            this.counter = 0;
            return false;
        } else {
            this.counter++;
            if (this.counter >= this.patience) {
                this.shouldStop = true;
                return true;
            }
            return false;
        }
    }

    /**
     * Reset early stopping
     */
    reset() {
        this.bestLoss = Infinity;
        this.counter = 0;
        this.shouldStop = false;
    }
}

// Example usage
function runRegularizationDemo() {
    console.log('='.repeat(60));
    console.log('🛡️ Regularization Demo');
    console.log('='.repeat(60));

    // 1. Dropout
    console.log('\n📊 1. Dropout');
    console.log('─'.repeat(40));

    const dropout = new Dropout(0.5);
    const input = [1, 2, 3, 4, 5, 6, 7, 8];

    dropout.setTraining(true);
    const trainOutput = dropout.forward(input);
    console.log(`  Input:  [${input.join(', ')}]`);
    console.log(`  Mask:   [${dropout.mask.join(', ')}]`);
    console.log(`  Output: [${trainOutput.join(', ')}]`);

    dropout.setTraining(false);
    const testOutput = dropout.forward(input);
    console.log(`  Test output: [${testOutput.map(v => v.toFixed(1)).join(', ')}]`);

    // 2. L2 Regularization
    console.log('\n📊 2. L2 Regularization (Weight Decay)');
    console.log('─'.repeat(40));

    const weights = [1.0, 2.0, 3.0, 4.0];
    const l2 = l2Regularization(weights, 0.01);
    console.log(`  Weights: [${weights.join(', ')}]`);
    console.log(`  L2 penalty: ${l2.toFixed(4)}`);

    // 3. Gradient Clipping
    console.log('\n📊 3. Gradient Clipping');
    console.log('─'.repeat(40));

    const gradients = [2.0, 3.0, 4.0, 5.0];
    const clipped = gradientClip(gradients, 5.0);
    console.log(`  Original gradients: [${gradients.join(', ')}]`);
    console.log(`  Clipped gradients: [${clipped.map(g => g.toFixed(2)).join(', ')}]`);

    // 4. Early Stopping
    console.log('\n📊 4. Early Stopping');
    console.log('─'.repeat(40));

    const earlyStop = new EarlyStopping(3, 0.01);
    const valLosses = [0.5, 0.49, 0.48, 0.48, 0.47, 0.47];

    console.log('  Validation losses:');
    for (let i = 0; i < valLosses.length; i++) {
        const shouldStop = earlyStop.update(valLosses[i]);
        console.log(`    Epoch ${i + 1}: Loss = ${valLosses[i].toFixed(3)}, Stop = ${shouldStop}`);
        if (shouldStop) {
            console.log(`  ⛔ Early stopping triggered at epoch ${i + 1}`);
            break;
        }
    }

    console.log('\n' + '='.repeat(60));
}

runRegularizationDemo();
```

---

## P3.6 Practice Exercises

### Exercise 1: Neural Network from Scratch
**Task**: Implement a neural network that learns the XOR function.

```javascript
function trainXOR() {
    // 1. Create network with 2 inputs, 1 hidden layer, 1 output
    // 2. Train on XOR dataset
    // 3. Show predictions
    // 4. Report accuracy
    
    // HINT: Use NeuralNetwork class
    // HINT: XOR data: [[0,0]→[0], [0,1]→[1], [1,0]→[1], [1,1]→[0]]
}
```

### Exercise 2: Activation Function Comparison
**Task**: Compare ReLU, Sigmoid, and Tanh on a simple problem.

```javascript
function compareActivations() {
    // 1. Create networks with different activations
    // 2. Train on same dataset
    // 3. Compare training curves
    // 4. Compare final performance
    
    // HINT: Use different activation functions
    // HINT: Plot loss curves (or just log them)
}
```

### Exercise 3: Dropout Implementation
**Task**: Implement dropout and test its effect on overfitting.

```javascript
function testDropout() {
    // 1. Create network with dropout
    // 2. Train on data with and without dropout
    // 3. Compare train vs validation performance
    // 4. Report findings
    
    // HINT: Use Dropout class
    // HINT: Track train and validation loss separately
}
```

### Exercise 4: Gradient Descent Visualization
**Task**: Implement a simple gradient descent and visualize it.

```javascript
function visualizeGradientDescent() {
    // 1. Define a simple function (e.g., f(x) = x²)
    // 2. Compute gradient
    // 3. Show steps of gradient descent
    // 4. Track convergence
    
    // HINT: derivative of x² is 2x
    // HINT: Start at some value, repeatedly subtract gradient * learning_rate
}
```

---

## P3.7 Quick Reference Card

```javascript
// QUICK REFERENCE - NEURAL NETWORKS

// NEURON
output = activation(sum(weights * inputs) + bias)

// ACTIVATION FUNCTIONS
Sigmoid:  f(x) = 1/(1+e^(-x)),  range: (0,1)
Tanh:     f(x) = tanh(x),       range: (-1,1)
ReLU:     f(x) = max(0,x),      range: [0,∞)
Leaky:    f(x) = x if x>0 else 0.01x, range: (-∞,∞)

// FORWARD PASS
Layer1: h = activation(X * W1 + b1)
Layer2: y = activation(h * W2 + b2)

// BACKPROPAGATION
Error:       δ = ∂L/∂output
Layer:       δ = δ * activation'(z)
Weight grad: ∂L/∂W = δ * input^T
Bias grad:   ∂L/∂b = δ

// LOSS FUNCTIONS
MSE:  L = (y_pred - y_true)²
BCE:  L = -[y*log(y_pred) + (1-y)*log(1-y_pred)]

// REGULARIZATION
Dropout:     Randomly set inputs to 0
L2:          Add λ/2 * ∑w² to loss
L1:          Add λ * ∑|w| to loss

// OPTIMIZATION
SGD: w = w - η * ∂L/∂w
Adam: adaptive learning rate with momentum

// TRAINING LOOP
for epoch in epochs:
    for batch in data:
        output = forward(batch)
        loss = compute_loss(output, target)
        gradients = backward(loss)
        update_weights(gradients)
```

---

**[END OF PRIMER 3]**

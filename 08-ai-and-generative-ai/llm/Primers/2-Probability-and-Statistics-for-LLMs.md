# Primer 2: Probability and Statistics for LLMs

This primer provides a comprehensive introduction to the probability and statistics concepts essential for understanding LLMs. If you've ever wondered how models handle uncertainty or why sampling works the way it does, this guide will demystify the concepts with intuitive explanations and practical JavaScript examples.

---

## P2.1 Why Probability Matters for LLMs

### The Core Insight

**LLMs are fundamentally probability machines.**

When an LLM generates text, it doesn't "think" - it calculates probabilities:

```
"Today is" → P("Monday") = 0.15, P("Tuesday") = 0.12, P("sunny") = 0.08, ...
```

Every output is a probability distribution over the next token. Understanding probability helps you understand:
- Why models sometimes hallucinate
- How temperature affects creativity
- Why some outputs are more "confident" than others
- How sampling strategies work

### What You'll Learn

| Concept | Why It Matters | Where Used |
|---------|---------------|------------|
| **Probability Distributions** | Model outputs are distributions | Output layer, attention |
| **Conditional Probability** | Text generation is conditional | Autoregressive generation |
| **Entropy** | Measures uncertainty | Model evaluation, sampling |
| **KL Divergence** | Compares distributions | Knowledge distillation |
| **Sampling** | Converting distributions to outputs | Text generation |
| **Bayes' Theorem** | Updating beliefs | Inference, fine-tuning |
| **Cross-Entropy** | Training objective | Loss functions, distillation |

---

## P2.2 Probability Basics

### What Is Probability?

**Probability measures how likely something is to happen.**

```
P(event) = number of favorable outcomes / total number of outcomes
```

**Examples:**
- Coin flip: P(heads) = 1/2 = 0.5
- Dice roll: P(6) = 1/6 ≈ 0.167
- Next word: P("the" | context) = 0.87

### Probability Rules

```javascript
// 📁 src/primers/probability/basics.js
/**
 * Probability Basics
 * 
 * Fundamental probability operations used in LLMs.
 */

/**
 * Probability of an event
 * @param {number} favorable - Number of favorable outcomes
 * @param {number} total - Total number of outcomes
 * @returns {number} Probability (0 to 1)
 */
export function probability(favorable, total) {
    if (total === 0) {
        throw new Error('Total outcomes must be greater than 0');
    }
    if (favorable < 0 || favorable > total) {
        throw new Error('Favorable outcomes must be between 0 and total');
    }
    return favorable / total;
}

/**
 * Joint probability: P(A and B)
 * For independent events: P(A∩B) = P(A) × P(B)
 * For dependent events: P(A∩B) = P(A) × P(B|A)
 */
export function jointProbability(pA, pB, conditional = null) {
    if (conditional !== null) {
        // Dependent: P(A∩B) = P(A) × P(B|A)
        return pA * conditional;
    }
    // Independent: P(A∩B) = P(A) × P(B)
    return pA * pB;
}

/**
 * Conditional probability: P(A|B) = P(A∩B) / P(B)
 * Probability of A given B has occurred
 */
export function conditionalProbability(pIntersection, pB) {
    if (pB === 0) {
        throw new Error('P(B) cannot be zero');
    }
    return pIntersection / pB;
}

/**
 * Addition rule: P(A or B) = P(A) + P(B) - P(A∩B)
 * Used for: Mutually exclusive vs non-mutually exclusive events
 */
export function additionRule(pA, pB, pIntersection) {
    return pA + pB - pIntersection;
}

/**
 * Complement rule: P(not A) = 1 - P(A)
 */
export function complement(pA) {
    return 1 - pA;
}

/**
 * Bayes' Theorem: P(A|B) = P(B|A) × P(A) / P(B)
 * Used for: Updating beliefs with new evidence
 */
export function bayesTheorem(pB_given_A, pA, pB) {
    if (pB === 0) {
        throw new Error('P(B) cannot be zero');
    }
    return (pB_given_A * pA) / pB;
}

/**
 * Law of Total Probability
 * P(B) = ∑ P(B|A_i) × P(A_i)
 * Used for: Computing marginal probabilities
 */
export function totalProbability(conditionalProbs, priors) {
    if (conditionalProbs.length !== priors.length) {
        throw new Error('Arrays must have same length');
    }
    let total = 0;
    for (let i = 0; i < conditionalProbs.length; i++) {
        total += conditionalProbs[i] * priors[i];
    }
    return total;
}

// Example usage
function runProbabilityDemo() {
    console.log('='.repeat(60));
    console.log('🎲 Probability Basics Demo');
    console.log('='.repeat(60));

    // 1. Simple probabilities
    console.log('\n📊 1. Simple Probabilities');
    console.log('─'.repeat(40));

    const coinFlip = probability(1, 2);
    console.log(`  Coin flip P(heads): ${coinFlip.toFixed(3)}`);

    const diceRoll = probability(1, 6);
    console.log(`  Dice roll P(6): ${diceRoll.toFixed(3)}`);

    // 2. Conditional probability
    console.log('\n🔀 2. Conditional Probability');
    console.log('─'.repeat(40));
    console.log('  Example: Weather and mood');

    // P(Sunny) = 0.6, P(Happy | Sunny) = 0.8, P(Happy | Rainy) = 0.3
    const pSunny = 0.6;
    const pRainy = 0.4;
    const pHappy_given_Sunny = 0.8;
    const pHappy_given_Rainy = 0.3;

    // P(Happy)
    const pHappy = totalProbability(
        [pHappy_given_Sunny, pHappy_given_Rainy],
        [pSunny, pRainy]
    );
    console.log(`  P(Happy): ${pHappy.toFixed(3)}`);

    // P(Sunny | Happy) using Bayes' Theorem
    const pSunny_given_Happy = bayesTheorem(pHappy_given_Sunny, pSunny, pHappy);
    console.log(`  P(Sunny | Happy): ${pSunny_given_Happy.toFixed(3)}`);

    // 3. Independence
    console.log('\n📈 3. Independence');
    console.log('─'.repeat(40));

    // Coin flips are independent
    const pTwoHeads = jointProbability(0.5, 0.5);
    console.log(`  P(heads and heads): ${pTwoHeads.toFixed(3)}`);

    // Weather and mood are dependent
    const pSunnyAndHappy = jointProbability(pSunny, pHappy_given_Sunny);
    console.log(`  P(Sunny and Happy): ${pSunnyAndHappy.toFixed(3)}`);

    console.log('\n' + '='.repeat(60));
}

runProbabilityDemo();
```

---

## P2.3 Probability Distributions

### What Is a Probability Distribution?

**A probability distribution tells us how probability is spread across all possible outcomes.**

```
Discrete distribution: Values you can count
Example: P(weather) = {sunny: 0.6, rainy: 0.3, cloudy: 0.1}

Continuous distribution: Values on a range
Example: Temperature follows a normal distribution
```

### Common Distributions in LLMs

```javascript
// 📁 src/primers/probability/distributions.js
/**
 * Probability Distributions
 * 
 * Common probability distributions used in LLMs.
 */

/**
 * Uniform distribution
 * All outcomes equally likely
 * Used for: Random sampling, initialization
 */
export function uniform(n) {
    return new Array(n).fill(1 / n);
}

/**
 * Uniform random sampling
 */
export function uniformRandom(min = 0, max = 1) {
    return min + Math.random() * (max - min);
}

/**
 * Categorical distribution
 * Like rolling a weighted die
 * Used for: Next token selection, sampling
 */
export function categorical(probabilities) {
    const r = Math.random();
    let cumulative = 0;
    for (let i = 0; i < probabilities.length; i++) {
        cumulative += probabilities[i];
        if (r < cumulative) {
            return i;
        }
    }
    return probabilities.length - 1;
}

/**
 * Normal (Gaussian) distribution
 * Bell curve: most values near mean
 * Used for: Weight initialization, embeddings
 * Formula: f(x) = (1/√(2πσ²)) * exp(-(x-μ)²/(2σ²))
 */
export function normalPDF(x, mean = 0, std = 1) {
    const coeff = 1 / (Math.sqrt(2 * Math.PI) * std);
    const exponent = -((x - mean) ** 2) / (2 * std ** 2);
    return coeff * Math.exp(exponent);
}

/**
 * Sample from normal distribution (Box-Muller transform)
 */
export function normalRandom(mean = 0, std = 1) {
    let u1 = Math.random();
    let u2 = Math.random();
    while (u1 === 0) u1 = Math.random();
    while (u2 === 0) u2 = Math.random();
    const z = Math.sqrt(-2 * Math.log(u1)) * Math.cos(2 * Math.PI * u2);
    return mean + std * z;
}

/**
 * Generate array of normal random values
 */
export function normalRandomArray(length, mean = 0, std = 1) {
    return Array.from({ length }, () => normalRandom(mean, std));
}

/**
 * Softmax distribution
 * Converts logits to probabilities
 * Used for: Output layer, attention weights
 * Formula: p_i = exp(z_i) / ∑ exp(z_j)
 */
export function softmaxDistribution(logits) {
    const maxVal = Math.max(...logits);
    const expLogits = logits.map(z => Math.exp(z - maxVal));
    const sumExp = expLogits.reduce((a, b) => a + b, 0);
    return expLogits.map(e => e / sumExp);
}

/**
 * Temperature-scaling of distribution
 * Higher temperature = more uniform
 * Lower temperature = more peaked
 */
export function temperatureDistribution(logits, temperature = 1.0) {
    if (temperature === 0) {
        // Greedy: choose max
        const maxIdx = logits.indexOf(Math.max(...logits));
        const result = new Array(logits.length).fill(0);
        result[maxIdx] = 1;
        return result;
    }
    const scaledLogits = logits.map(z => z / temperature);
    return softmaxDistribution(scaledLogits);
}

/**
 * Top-K sampling distribution
 * Only keep top K probabilities
 * Used for: Controlled generation
 */
export function topKDistribution(probs, k) {
    const sorted = probs.map((p, i) => ({ p, i }));
    sorted.sort((a, b) => b.p - a.p);

    const topIndices = sorted.slice(0, k).map(({ i }) => i);
    const result = new Array(probs.length).fill(0);

    const sumTop = topIndices.reduce((sum, i) => sum + probs[i], 0);
    for (const i of topIndices) {
        result[i] = probs[i] / sumTop;
    }

    return result;
}

/**
 * Top-P (nucleus) sampling distribution
 * Keep smallest set where cumulative probability ≥ P
 * Used for: Controlled generation
 */
export function topPDistribution(probs, p) {
    const sorted = probs.map((p, i) => ({ p, i }));
    sorted.sort((a, b) => b.p - a.p);

    let cumulative = 0;
    const selectedIndices = [];

    for (const { p: prob, i } of sorted) {
        if (cumulative + prob > p && selectedIndices.length > 0) break;
        cumulative += prob;
        selectedIndices.push(i);
    }

    const result = new Array(probs.length).fill(0);
    const sumSelected = selectedIndices.reduce((sum, i) => sum + probs[i], 0);

    for (const i of selectedIndices) {
        result[i] = probs[i] / sumSelected;
    }

    return result;
}

/**
 * Compute entropy of a distribution
 * Measures uncertainty: higher = more uncertain
 * Formula: H(X) = -∑ p_i * log(p_i)
 */
export function entropy(probs) {
    let h = 0;
    for (const p of probs) {
        if (p > 0) {
            h -= p * Math.log(p);
        }
    }
    return h;
}

/**
 * Compute KL divergence between two distributions
 * Measures how different they are
 * Formula: D_KL(P || Q) = ∑ P_i * log(P_i / Q_i)
 */
export function klDivergence(p, q) {
    let kl = 0;
    for (let i = 0; i < p.length; i++) {
        if (p[i] > 0 && q[i] > 0) {
            kl += p[i] * Math.log(p[i] / q[i]);
        }
    }
    return kl;
}

/**
 * Cross-entropy between two distributions
 * Formula: H(P,Q) = -∑ P_i * log(Q_i)
 */
export function crossEntropy(p, q) {
    let ce = 0;
    for (let i = 0; i < p.length; i++) {
        if (q[i] > 0) {
            ce -= p[i] * Math.log(q[i]);
        }
    }
    return ce;
}
```

---

## P2.4 Sampling from Distributions

### The Target
We'll build a comprehensive sampling system used in LLM text generation.

### The Concept

**Sampling is how we turn probability distributions into actual tokens.**

Think of it like drawing from a bag of numbered balls:
- Each token has a number of balls proportional to its probability
- You draw one ball → that's your next token
- Different strategies change how many balls each token gets

### The Implementation

```javascript
// 📁 src/primers/probability/sampling.js
/**
 * Sampling Strategies
 * 
 * Different ways to sample from a probability distribution.
 * Used for: Text generation, decision making, exploration.
 */

import {
    softmaxDistribution,
    temperatureDistribution,
    topKDistribution,
    topPDistribution,
    categorical,
    entropy
} from './distributions.js';

/**
 * Sampling Strategy Configuration
 */
export class SamplingConfig {
    constructor(config = {}) {
        this.mode = config.mode || 'temperature'; // 'greedy', 'temperature', 'topk', 'topp'
        this.temperature = config.temperature || 1.0;
        this.topK = config.topK || 0;
        this.topP = config.topP || 0.0;
        this.seed = config.seed || null;
    }

    describe() {
        const description = [];
        if (this.mode === 'greedy') {
            description.push('Greedy (always pick max)');
        } else if (this.mode === 'temperature') {
            description.push(`Temperature sampling (T=${this.temperature})`);
        } else if (this.mode === 'topk') {
            description.push(`Top-K sampling (K=${this.topK})`);
        } else if (this.mode === 'topp') {
            description.push(`Top-P sampling (P=${this.topP})`);
        } else {
            description.push('Unknown mode');
        }

        if (this.seed !== null) {
            description.push(`Seed: ${this.seed}`);
        }

        return description.join(', ');
    }
}

/**
 * Sample from logits using various strategies
 */
export function sampleFromLogits(logits, config) {
    // Apply temperature
    let probs;
    if (config.temperature <= 0) {
        // Greedy: temperature = 0
        const maxIdx = logits.indexOf(Math.max(...logits));
        probs = new Array(logits.length).fill(0);
        probs[maxIdx] = 1;
    } else {
        probs = temperatureDistribution(logits, config.temperature);
    }

    // Apply top-K
    if (config.topK > 0) {
        probs = topKDistribution(probs, config.topK);
    }

    // Apply top-P
    if (config.topP > 0) {
        probs = topPDistribution(probs, config.topP);
    }

    // Sample from distribution
    const index = categorical(probs);

    return {
        index: index,
        probability: probs[index],
        distribution: probs,
        entropy: entropy(probs)
    };
}

/**
 * Sample with rejection sampling
 * Useful for constrained generation
 */
export function rejectionSampling(probs, constraint) {
    let attempts = 0;
    const maxAttempts = 100;

    while (attempts < maxAttempts) {
        const idx = categorical(probs);
        if (constraint(idx)) {
            return idx;
        }
        attempts++;
    }

    // Fallback: pick max that satisfies constraint
    let bestIdx = -1;
    let bestProb = -Infinity;
    for (let i = 0; i < probs.length; i++) {
        if (constraint(i) && probs[i] > bestProb) {
            bestProb = probs[i];
            bestIdx = i;
        }
    }

    return bestIdx;
}

/**
 * Batch sampling: sample multiple tokens with different configs
 */
export function batchSample(logitsArray, configs) {
    const results = [];
    for (let i = 0; i < logitsArray.length; i++) {
        const config = configs[i] || new SamplingConfig();
        const result = sampleFromLogits(logitsArray[i], config);
        results.push(result);
    }
    return results;
}

/**
 * Compare sampling strategies
 */
export function compareSamplingStrategies(logits, strategies) {
    const results = {};

    for (const [name, config] of Object.entries(strategies)) {
        const result = sampleFromLogits(logits, config);
        results[name] = {
            token: result.index,
            probability: result.probability,
            entropy: result.entropy,
            distribution: result.distribution.slice(0, 5).map((p, i) => ({
                index: i,
                probability: p
            }))
        };
    }

    return results;
}

// Example usage
function runSamplingDemo() {
    console.log('='.repeat(60));
    console.log('🎯 Sampling Strategies Demo');
    console.log('='.repeat(60));

    // Sample logits (raw scores before softmax)
    const logits = [2.5, 1.8, 0.5, -0.2, 2.1, 0.3, -1.5, 0.8];

    console.log('\n📊 Logits:');
    console.log(`  ${logits.map(l => l.toFixed(2)).join(', ')}`);

    // Define strategies
    const strategies = {
        'Greedy': new SamplingConfig({ mode: 'greedy', temperature: 0 }),
        'Temperature 0.5': new SamplingConfig({ mode: 'temperature', temperature: 0.5 }),
        'Temperature 1.0': new SamplingConfig({ mode: 'temperature', temperature: 1.0 }),
        'Temperature 2.0': new SamplingConfig({ mode: 'temperature', temperature: 2.0 }),
        'Top-K 3': new SamplingConfig({ mode: 'topk', topK: 3, temperature: 1.0 }),
        'Top-P 0.8': new SamplingConfig({ mode: 'topp', topP: 0.8, temperature: 1.0 })
    };

    // Compare strategies
    console.log('\n🔍 Strategy Comparison:');
    console.log('─'.repeat(40));

    const results = compareSamplingStrategies(logits, strategies);

    for (const [name, result] of Object.entries(results)) {
        console.log(`\n  ${name}:`);
        console.log(`    Selected token: ${result.token}`);
        console.log(`    Probability: ${result.probability.toFixed(3)}`);
        console.log(`    Entropy: ${result.entropy.toFixed(3)}`);
        console.log(`    Top 5 distribution:`);
        for (const item of result.distribution) {
            console.log(`      ${item.index}: ${item.probability.toFixed(3)}`);
        }
    }

    // Demonstrate entropy concept
    console.log('\n📈 Entropy Analysis:');
    console.log('─'.repeat(40));

    const dist1 = [0.9, 0.05, 0.05]; // Low entropy (certain)
    const dist2 = [0.4, 0.3, 0.3];    // Medium entropy
    const dist3 = [0.33, 0.33, 0.34]; // High entropy (uncertain)

    console.log(`  Low entropy (certain): ${entropy(dist1).toFixed(3)}`);
    console.log(`  Medium entropy: ${entropy(dist2).toFixed(3)}`);
    console.log(`  High entropy (uncertain): ${entropy(dist3).toFixed(3)}`);

    console.log('\n' + '='.repeat(60));
}

runSamplingDemo();
```

---

## P2.5 Conditional Probability and Language Models

### The Target
We'll demonstrate how conditional probability powers language models.

### The Concept

**Language models are conditional probability machines.**

```
P(word_n | word_1, word_2, ..., word_{n-1})
```

This is the probability of the next word given all previous words. The model learns to approximate this from training data.

### The Implementation

```javascript
// 📁 src/primers/probability/conditional.js
/**
 * Conditional Probability in Language Models
 * 
 * Demonstrates how language models use conditional probability.
 */

import { softmaxDistribution, crossEntropy } from './distributions.js';

/**
 * Language Model Simulator
 * Demonstrates conditional probability in text generation
 */
export class SimpleLanguageModel {
    constructor(vocabulary) {
        this.vocabulary = vocabulary;
        this.conditionalProbs = new Map();
    }

    /**
     * Learn conditional probabilities from text
     * This simulates what a real language model learns
     */
    train(texts) {
        console.log('[LM] Training conditional probabilities...');

        for (const text of texts) {
            const words = text.split(' ');

            for (let i = 0; i < words.length - 1; i++) {
                const context = words.slice(0, i + 1).join(' ');
                const nextWord = words[i + 1];

                if (!this.conditionalProbs.has(context)) {
                    this.conditionalProbs.set(context, new Map());
                }

                const nextProbs = this.conditionalProbs.get(context);
                nextProbs.set(nextWord, (nextProbs.get(nextWord) || 0) + 1);
            }
        }

        // Normalize to probabilities
        for (const [context, counts] of this.conditionalProbs) {
            let total = 0;
            for (const count of counts.values()) {
                total += count;
            }
            for (const [word, count] of counts) {
                counts.set(word, count / total);
            }
        }

        console.log(`[LM] Trained on ${texts.length} texts`);
        console.log(`[LM] Learned ${this.conditionalProbs.size} contexts`);
    }

    /**
     * Get conditional probability: P(next | context)
     */
    getProbability(context, nextWord) {
        const nextProbs = this.conditionalProbs.get(context);
        if (!nextProbs) return 0;
        return nextProbs.get(nextWord) || 0;
    }

    /**
     * Get distribution over next words: P(* | context)
     */
    getDistribution(context) {
        const nextProbs = this.conditionalProbs.get(context);
        if (!nextProbs) return new Map();

        // Return as Map for easier use
        return new Map(nextProbs);
    }

    /**
     * Generate text using conditional probabilities
     */
    generate(seed, maxTokens = 10) {
        let text = seed;
        const words = text.split(' ');

        console.log(`\n[LM] Generating from: "${seed}"`);

        for (let step = 0; step < maxTokens; step++) {
            const context = words.slice(-5).join(' '); // Use last 5 words

            // Get distribution
            let probs = this.getDistribution(context);
            if (probs.size === 0) {
                // No data for this context, use fallback
                console.log(`  No context data, falling back to random`);
                break;
            }

            // Convert to arrays for sampling
            const tokens = Array.from(probs.keys());
            const probabilities = tokens.map(t => probs.get(t));

            // Sample next word
            const r = Math.random();
            let cumulative = 0;
            let nextWord = tokens[0];

            for (let i = 0; i < probabilities.length; i++) {
                cumulative += probabilities[i];
                if (r < cumulative) {
                    nextWord = tokens[i];
                    break;
                }
            }

            // Show top 3 probabilities
            const sorted = tokens
                .map(t => ({ token: t, prob: probs.get(t) }))
                .sort((a, b) => b.prob - a.prob)
                .slice(0, 3);

            console.log(`  Step ${step + 1}: "${nextWord}"`);
            console.log(`    Top options: ${sorted.map(t => `${t.token} (${t.prob.toFixed(3)})`).join(', ')}`);

            words.push(nextWord);
            text += ' ' + nextWord;
        }

        return text;
    }

    /**
     * Compute perplexity: 2^(-average log probability)
     * Lower = better model
     */
    computePerplexity(text) {
        const words = text.split(' ');
        let totalLogProb = 0;
        let count = 0;

        for (let i = 0; i < words.length - 1; i++) {
            const context = words.slice(0, i + 1).join(' ');
            const nextWord = words[i + 1];
            const prob = this.getProbability(context, nextWord);

            if (prob > 0) {
                totalLogProb += Math.log2(prob);
                count++;
            }
        }

        if (count === 0) return Infinity;
        const avgLogProb = totalLogProb / count;
        return Math.pow(2, -avgLogProb);
    }
}

/**
 * Compute the probability of a sequence
 * P(w1, w2, ..., wn) = P(w1) * P(w2|w1) * P(w3|w1,w2) * ...
 */
export function sequenceProbability(model, text) {
    const words = text.split(' ');
    let prob = 1;

    for (let i = 0; i < words.length - 1; i++) {
        const context = words.slice(0, i + 1).join(' ');
        const nextWord = words[i + 1];
        const condProb = model.getProbability(context, nextWord);
        prob *= condProb;

        if (prob === 0) break;
    }

    return prob;
}

// Example usage
function runConditionalDemo() {
    console.log('='.repeat(60));
    console.log('📖 Conditional Probability in Language Models');
    console.log('='.repeat(60));

    // Training corpus
    const trainingData = [
        'the cat sat on the mat',
        'the dog played in the garden',
        'the cat chased the mouse',
        'the mouse ran under the chair',
        'the dog barked at the cat',
        'the cat slept on the bed',
        'the sun set behind the mountains',
        'the birds flew over the trees'
    ];

    // Create and train model
    const lm = new SimpleLanguageModel(new Set());
    lm.train(trainingData);

    // Test predictions
    console.log('\n🔮 Conditional Probability Predictions:');
    console.log('─'.repeat(40));

    const contexts = [
        'the cat',
        'the dog',
        'the mouse'
    ];

    for (const context of contexts) {
        const probs = lm.getDistribution(context);
        const sorted = Array.from(probs.entries())
            .sort((a, b) => b[1] - a[1])
            .slice(0, 5);

        console.log(`\n  Context: "${context}"`);
        console.log(`  Next word probabilities:`);
        for (const [word, prob] of sorted) {
            console.log(`    ${word}: ${prob.toFixed(3)}`);
        }
    }

    // Generate text
    console.log('\n🎯 Text Generation:');
    console.log('─'.repeat(40));

    const seed = 'the cat';
    const generated = lm.generate(seed, 6);

    console.log(`\n  Generated: "${generated}"`);

    // Compute perplexity
    const testText = 'the cat sat on the bed';
    const perplexity = lm.computePerplexity(testText);
    console.log(`\n📊 Perplexity of "${testText}": ${perplexity.toFixed(3)}`);

    console.log('\n' + '='.repeat(60));
}

runConditionalDemo();
```

---

## P2.6 KL Divergence and Distillation

### The Target
We'll demonstrate how KL divergence is used in knowledge distillation.

### The Concept

**KL divergence measures how different two distributions are.**

In distillation, we want the student's distribution to be close to the teacher's:
```
L_distillation = D_KL(P_teacher || P_student)
```

### The Implementation

```javascript
// 📁 src/primers/probability/kl-divergence.js
/**
 * KL Divergence Demo
 * 
 * Demonstrates how KL divergence is used in knowledge distillation.
 */

import { klDivergence, crossEntropy, entropy } from './distributions.js';
import { temperatureDistribution } from './distributions.js';

/**
 * Simulate teacher and student distributions
 */
function runKLDemo() {
    console.log('='.repeat(60));
    console.log('📊 KL Divergence and Knowledge Distillation');
    console.log('='.repeat(60));

    // 1. Define teacher logits (raw scores)
    console.log('\n🎯 1. Teacher Model');
    console.log('─'.repeat(40));

    const teacherLogits = [3.5, 2.8, 1.5, 0.2, 2.3, 0.8];
    console.log(`  Teacher logits: ${teacherLogits.map(l => l.toFixed(1)).join(', ')}`);

    // Teacher distribution (T=1)
    const teacherProbs = temperatureDistribution(teacherLogits, 1.0);
    console.log(`  Teacher probabilities: ${teacherProbs.map(p => p.toFixed(3)).join(', ')}`);
    console.log(`  Teacher entropy: ${entropy(teacherProbs).toFixed(3)}`);

    // 2. Define student distributions (different logits)
    console.log('\n🧑‍🎓 2. Student Models');
    console.log('─'.repeat(40));

    const studentConfigs = [
        { name: 'Good Student', logits: [3.0, 2.5, 1.8, 0.5, 2.0, 1.0] },
        { name: 'OK Student', logits: [2.5, 2.0, 1.5, 1.0, 1.8, 0.8] },
        { name: 'Poor Student', logits: [1.0, 0.8, 0.5, 0.2, 0.3, 0.1] }
    ];

    for (const config of studentConfigs) {
        const studentProbs = temperatureDistribution(config.logits, 1.0);
        const kl = klDivergence(teacherProbs, studentProbs);
        const ce = crossEntropy(teacherProbs, studentProbs);

        console.log(`\n  ${config.name}:`);
        console.log(`    Logits: ${config.logits.map(l => l.toFixed(1)).join(', ')}`);
        console.log(`    Probabilities: ${studentProbs.map(p => p.toFixed(3)).join(', ')}`);
        console.log(`    KL Divergence (Teacher || Student): ${kl.toFixed(4)}`);
        console.log(`    Cross-Entropy: ${ce.toFixed(4)}`);
    }

    // 3. Temperature effect
    console.log('\n🌡️ 3. Temperature Effect on Distillation');
    console.log('─'.repeat(40));

    const temperatures = [0.5, 1.0, 2.0, 5.0];

    for (const temp of temperatures) {
        const teacherSoft = temperatureDistribution(teacherLogits, temp);
        const studentSoft = temperatureDistribution(
            studentConfigs[1].logits, // OK Student
            temp
        );
        const kl = klDivergence(teacherSoft, studentSoft);

        console.log(`\n  Temperature T=${temp}:`);
        console.log(`    Teacher distribution (soft): ${teacherSoft.map(p => p.toFixed(3)).join(', ')}`);
        console.log(`    Student distribution (soft): ${studentSoft.map(p => p.toFixed(3)).join(', ')}`);
        console.log(`    KL Divergence: ${kl.toFixed(4)}`);
    }

    // 4. Visualization of KL divergence
    console.log('\n📈 4. KL Divergence Visualization');
    console.log('─'.repeat(40));
    console.log('  High KL = distributions are very different');
    console.log('  Low KL = distributions are similar');
    console.log('  KL = 0 = distributions are identical');

    const identical = teacherProbs.map(p => p);
    const klIdentical = klDivergence(teacherProbs, identical);
    console.log(`\n  Identical distributions: KL = ${klIdentical.toFixed(4)}`);

    const shifted = teacherProbs.map((p, i) => {
        if (i === 0) return p - 0.1;
        if (i === 1) return p + 0.1;
        return p;
    });
    const klShifted = klDivergence(teacherProbs, shifted);
    console.log(`  Slightly shifted: KL = ${klShifted.toFixed(4)}`);

    const random = teacherProbs.map(() => Math.random());
    const sumRandom = random.reduce((a, b) => a + b, 0);
    const randomNormalized = random.map(r => r / sumRandom);
    const klRandom = klDivergence(teacherProbs, randomNormalized);
    console.log(`  Random distribution: KL = ${klRandom.toFixed(4)}`);

    console.log('\n' + '='.repeat(60));
}

runKLDemo();
```

---

## P2.7 Practice Exercises

### Exercise 1: Temperature Analysis
**Task**: Implement a function that analyzes how temperature affects a distribution.

```javascript
function analyzeTemperature(logits, temperatures) {
    // For each temperature:
    // 1. Apply temperature scaling
    // 2. Compute entropy
    // 3. Find max probability
    // 4. Return analysis
    
    // HINT: Use temperatureDistribution and entropy
}
```

### Exercise 2: Sampling Strategies
**Task**: Compare different sampling strategies on a probability distribution.

```javascript
function compareSampling(probs, strategies) {
    // For each strategy:
    // 1. Sample 1000 times
    // 2. Count frequency of each token
    // 3. Compare to expected distribution
    
    // HINT: Use categorical sampling
    // HINT: Track frequencies in an array
}
```

### Exercise 3: Distillation Loss
**Task**: Implement the combined distillation loss.

```javascript
function distillationLoss(studentLogits, teacherProbs, targetIds, config) {
    // 1. Apply temperature to student logits
    // 2. Compute KL divergence (distillation loss)
    // 3. Compute cross-entropy (supervised loss)
    // 4. Combine with alpha
    
    // HINT: Use temperatureDistribution
    // HINT: Use klDivergence and crossEntropy
}
```

### Exercise 4: Perplexity Calculation
**Task**: Implement perplexity for a language model.

```javascript
function computePerplexity(model, text) {
    // 1. Split text into tokens
    // 2. For each position, get probability
    // 3. Compute average negative log probability
    // 4. Return 2^(avg_log_prob)
    
    // HINT: Use Math.log2
}
```

---

## P2.8 Quick Reference Card

```javascript
// QUICK REFERENCE - PROBABILITY AND STATISTICS

// BASIC PROBABILITY
P(A) = favorable / total
P(A and B) = P(A) * P(B|A)
P(A or B) = P(A) + P(B) - P(A and B)
P(not A) = 1 - P(A)

// BAYES' THEOREM
P(A|B) = P(B|A) * P(A) / P(B)

// DISTRIBUTIONS
// Uniform: All outcomes equally likely
// Normal: Bell curve (μ, σ)
// Categorical: Weighted die

// SAMPLING
greedy: pick max probability
temperature: T < 1 = more peaked, T > 1 = more uniform
top-K: only keep top K probabilities
top-P: keep smallest set with cumulative probability ≥ P

// INFORMATION THEORY
Entropy: H(X) = -∑ P(x) * log(P(x))
Cross-Entropy: H(P,Q) = -∑ P(x) * log(Q(x))
KL Divergence: D_KL(P||Q) = ∑ P(x) * log(P(x)/Q(x))

// RELATIONSHIPS
D_KL(P||Q) = H(P,Q) - H(P)
CrossEntropy = Entropy + KL Divergence

// IN LLMS
Softmax: converts logits to probabilities
Temperature: controls randomness
Sampling: converts probabilities to tokens
Perplexity: 2^(-average log probability)
```

---

**[END OF PRIMER 2]**

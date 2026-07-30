# Appendix C: Complete API Reference — Knowledge Distillation

This appendix provides comprehensive API documentation for the knowledge distillation system built throughout the series. Use this as a quick reference when compressing models, training student networks, and implementing teacher-student frameworks.

---

## C.1 Teacher Model API

### Overview
The teacher model provides "soft targets" for the student to learn from. It's typically a large, well-trained model that captures rich relationships between tokens.

```javascript
import { TeacherModel } from './src/distillation/teacher.js';
```

### Constructor

```javascript
new TeacherModel(config)
```

**Constructor Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.transformer` | `Transformer` | null | Pre-trained transformer |
| `config.pipeline` | `TextProcessingPipeline` | null | Tokenization pipeline |
| `config.modelPath` | `string` | null | Path to saved model weights |
| `config.temperature` | `number` | 1.0 | Default softmax temperature |
| `config.maxSequenceLength` | `number` | 512 | Maximum sequence length |

**Methods:**

#### `initialize()`

Loads or initializes the teacher model.

```javascript
await teacher.initialize();
```

**Returns:** `Promise<TeacherModel>` (for chaining)

**Example:**
```javascript
const teacher = new TeacherModel({
    pipeline: pipeline,
    transformer: new Transformer({
        vocabSize: 1000,
        d_model: 128,
        numHeads: 8,
        numLayers: 6
    })
});

await teacher.initialize();
console.log('Teacher ready!');
```

#### `getSoftTargets(tokenIds, temperature)`

Gets soft targets (logits/probabilities) for input tokens.

```javascript
const targets = teacher.getSoftTargets(tokenIds, 2.0);
```

**Parameters:**
- `tokenIds` (number[]): Input token IDs
- `temperature` (number): Softmax temperature (default: 1.0)

**Returns:** `Object`
```javascript
{
    logits: number[][],              // Raw logits [seq_len, vocabSize]
    scaledLogits: number[][],        // Temperature-scaled logits
    probabilities: number[][],       // Softmax probabilities
    temperature: number              // Applied temperature
}
```

**Example:**
```javascript
const processed = pipeline.processText("The quick brown fox");
const targets = teacher.getSoftTargets(processed.tokenIds, 2.0);
console.log(targets.probabilities.length);    // seq_len
console.log(targets.probabilities[0].length); // vocabSize
```

#### `predict(text, temperature)`

Gets predictions for a text prompt.

```javascript
const prediction = teacher.predict("The quick brown fox", 1.0);
```

**Parameters:**
- `text` (string): Input text
- `temperature` (number): Softmax temperature (default: 1.0)

**Returns:** `Object`
```javascript
{
    tokenIds: number[],          // Tokenized input
    probabilities: number[][],   // Softmax probabilities
    logits: number[][],         // Raw logits
    predictedId: number,         // Most likely next token ID
    predictedToken: string,      // Most likely next token
    confidence: number           // Confidence of prediction
}
```

**Example:**
```javascript
const result = teacher.predict("The meaning of life is");
console.log(`Teacher predicts: ${result.predictedToken}`);
console.log(`Confidence: ${result.confidence.toFixed(3)}`);
```

#### `getDistillationTargets(tokenIds, temperature)`

Gets complete distillation targets for student training.

```javascript
const targets = teacher.getDistillationTargets(tokenIds, 2.0);
```

**Parameters:**
- `tokenIds` (number[]): Input token IDs
- `temperature` (number): Softmax temperature (default: 2.0)

**Returns:** `Object`
```javascript
{
    probabilities: number[][],   // Soft targets
    logits: number[][],         // Raw logits
    temperature: number,         // Applied temperature
    shape: {
        sequenceLength: number, // Length of sequence
        vocabSize: number       // Vocabulary size
    }
}
```

#### `getStats()`

Gets teacher model statistics.

```javascript
const stats = teacher.getStats();
// Returns: { isLoaded: true, parameters: 15000, layers: 6, heads: 8, ... }
```

**Returns:** `Object` - Model statistics

#### `saveToFile(filepath)`

Saves teacher model to disk.

```javascript
teacher.saveToFile('./models/teacher.json');
```

**Parameters:**
- `filepath` (string): Path to save file

---

## C.2 Student Model API

### Overview
The student model is a smaller, more efficient network that learns from the teacher's soft targets.

```javascript
import { StudentModel } from './src/distillation/student.js';
```

### Constructor

```javascript
new StudentModel(config)
```

**Constructor Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.vocabSize` | `number` | 100 | Vocabulary size |
| `config.d_model` | `number` | 32 | Model dimension (smaller than teacher) |
| `config.numHeads` | `number` | 4 | Number of attention heads |
| `config.numLayers` | `number` | 2 | Number of transformer layers |
| `config.d_ff` | `number` | `4 * d_model` | Feed-forward dimension |
| `config.maxLen` | `number` | 256 | Maximum sequence length |
| `config.dropout` | `number` | 0.1 | Dropout rate |

**Methods:**

#### `forward(tokenIds, mask)`

Forward pass through student model.

```javascript
const { logits, attentionWeights } = student.forward(tokenIds);
```

**Parameters:**
- `tokenIds` (number[]): Input token IDs
- `mask` (boolean[][]): Optional attention mask

**Returns:** `Object`
```javascript
{
    logits: number[][],              // [seq_len, vocabSize]
    attentionWeights: number[][][]   // Per layer, per head
}
```

**Example:**
```javascript
const student = new StudentModel({
    vocabSize: 1000,
    d_model: 32,
    numHeads: 4,
    numLayers: 2
});

const tokenIds = [1, 2, 3, 4];
const { logits } = student.forward(tokenIds);
console.log(logits.length);    // 4 (seq_len)
console.log(logits[0].length); // 1000 (vocabSize)
```

#### `predict(tokenIds)`

Gets predictions from student.

```javascript
const predictions = student.predict(tokenIds);
```

**Parameters:**
- `tokenIds` (number[]): Input token IDs

**Returns:** `Object`
```javascript
{
    logits: number[][],          // Raw logits
    probabilities: number[][],   // Softmax probabilities
    predictions: Array<{
        id: number,              // Predicted token ID
        confidence: number,      // Confidence score
        distribution: number[]   // Full probability distribution
    }>
}
```

#### `computeDistillationLoss(studentLogits, teacherProbabilities, temperature, alpha)`

Computes distillation loss (KL divergence).

```javascript
const distLoss = student.computeDistillationLoss(
    studentLogits,
    teacherProbabilities,
    2.0,
    0.7
);
```

**Parameters:**
- `studentLogits` (number[][]): Student model logits
- `teacherProbabilities` (number[][]): Teacher soft targets
- `temperature` (number): Softmax temperature (default: 2.0)
- `alpha` (number): Distillation loss weight (default: 0.7)

**Returns:** `number` - Distillation loss

#### `computeSupervisedLoss(studentLogits, targetIds)`

Computes supervised loss (cross-entropy).

```javascript
const supLoss = student.computeSupervisedLoss(studentLogits, tokenIds);
```

**Parameters:**
- `studentLogits` (number[][]): Student model logits
- `targetIds` (number[]): Target token IDs (hard labels)

**Returns:** `number` - Supervised loss

#### `trainStep(tokenIds, teacherProbabilities, config)`

Performs a single training step.

```javascript
const result = student.trainStep(tokenIds, teacherProbabilities, {
    temperature: 2.0,
    alpha: 0.7,
    learningRate: 0.001
});
```

**Parameters:**
- `tokenIds` (number[]): Input token IDs
- `teacherProbabilities` (number[][]): Teacher soft targets
- `config.temperature` (number): Softmax temperature (default: 2.0)
- `config.alpha` (number): Distillation weight (default: 0.7)
- `config.learningRate` (number): Learning rate (default: 0.001)

**Returns:** `Object`
```javascript
{
    totalLoss: number,
    distillationLoss: number,
    supervisedLoss: number,
    learningRate: number
}
```

#### `generate(inputIds, config)`

Generates text using student model.

```javascript
const outputIds = student.generate(inputIds, {
    maxTokens: 100,
    temperature: 0.8
});
```

**Parameters:**
- `inputIds` (number[]): Starting token IDs
- `config` (Object): Generation configuration

**Returns:** `number[]` - Generated token IDs

#### `getStats()`

Gets student model statistics.

```javascript
const stats = student.getStats();
// Returns: { parameters: 5000, layers: 2, heads: 4, d_model: 32, ... }
```

**Returns:** `Object` - Model statistics

#### `saveToFile(filepath)`

Saves student model to disk.

```javascript
student.saveToFile('./models/student.json');
```

**Parameters:**
- `filepath` (string): Path to save file

#### `loadFromFile(filepath)`

Loads student model from disk.

```javascript
student.loadFromFile('./models/student.json');
```

**Parameters:**
- `filepath` (string): Path to load file

**Returns:** `StudentModel` (for chaining)

---

## C.3 Distillation Trainer API

### Overview
Orchestrates the training process where the student learns from the teacher's soft targets.

```javascript
import { DistillationTrainer } from './src/distillation/trainer.js';
```

### Constructor

```javascript
new DistillationTrainer(config)
```

**Constructor Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.teacher` | `TeacherModel` | Required | Teacher model |
| `config.student` | `StudentModel` | Required | Student model |
| `config.pipeline` | `TextProcessingPipeline` | Required | Tokenization pipeline |
| `config.epochs` | `number` | 10 | Number of training epochs |
| `config.batchSize` | `number` | 8 | Batch size |
| `config.learningRate` | `number` | 0.001 | Learning rate |
| `config.temperature` | `number` | 2.0 | Softmax temperature |
| `config.alpha` | `number` | 0.7 | Distillation loss weight |
| `config.validationSplit` | `number` | 0.2 | Validation split ratio |
| `config.patience` | `number` | 3 | Early stopping patience |

**Methods:**

#### `prepareData(texts)`

Prepares training and validation data.

```javascript
const { trainData, valData } = trainer.prepareData(texts);
```

**Parameters:**
- `texts` (string[]): Array of training texts

**Returns:** `Object`
```javascript
{
    trainData: number[][],  // Tokenized training sequences
    valData: number[][]     // Tokenized validation sequences
}
```

**Example:**
```javascript
const texts = [
    "The quick brown fox",
    "A fast cat runs",
    "The sun sets"
];
const { trainData, valData } = trainer.prepareData(texts);
console.log(`Train samples: ${trainData.length}`);
console.log(`Val samples: ${valData.length}`);
```

#### `getTeacherTargets(batch, temperature)`

Gets teacher soft targets for a batch.

```javascript
const targets = trainer.getTeacherTargets(batch, 2.0);
```

**Parameters:**
- `batch` (number[][]): Batch of token sequences
- `temperature` (number): Softmax temperature (default: 2.0)

**Returns:** `number[][][]` - Teacher probabilities for each sequence

#### `trainEpoch(trainData, valData, epoch)`

Trains for one epoch.

```javascript
const result = trainer.trainEpoch(trainData, valData, 0);
```

**Parameters:**
- `trainData` (number[][]): Training data
- `valData` (number[][]): Validation data
- `epoch` (number): Epoch number

**Returns:** `Object`
```javascript
{
    epochLoss: number,
    valLoss: number,
    epochDistLoss: number,
    epochSupLoss: number
}
```

#### `validate(valData)`

Validates the student model.

```javascript
const valLoss = trainer.validate(valData);
```

**Parameters:**
- `valData` (number[][]): Validation data

**Returns:** `number` - Average validation loss

#### `train(texts, callback)`

Complete training loop.

```javascript
const results = await trainer.train(texts, (result, state) => {
    console.log(`Epoch ${state.epoch + 1}: Loss = ${result.epochLoss}`);
});
```

**Parameters:**
- `texts` (string[]): Training texts
- `callback` (Function): Optional callback per epoch

**Returns:** `Promise<Object>`
```javascript
{
    bestValidationLoss: number,
    trainHistory: Array<{epoch, loss, distillationLoss, supervisedLoss}>,
    validationHistory: Array<{epoch, loss}>,
    totalSteps: number,
    finalEpoch: number
}
```

**Example:**
```javascript
const texts = [
    "The quick brown fox jumps over the lazy dog.",
    "A fast cat runs through the garden.",
    // ... more texts
];

const results = await trainer.train(texts, (result, state) => {
    console.log(`Epoch ${state.epoch + 1}/${trainer.trainingConfig.epochs}`);
    console.log(`  Train Loss: ${result.epochLoss.toFixed(4)}`);
    console.log(`  Val Loss: ${result.valLoss.toFixed(4)}`);
});

console.log(`Best validation loss: ${results.bestValidationLoss.toFixed(4)}`);
```

#### `getStats()`

Gets trainer statistics.

```javascript
const stats = trainer.getStats();
// Returns: { currentEpoch: 3, bestValidationLoss: 0.234, patienceCounter: 0, ... }
```

**Returns:** `Object` - Trainer statistics

---

## C.4 Loss Functions API

### Overview
Loss functions for knowledge distillation including KL divergence, cross-entropy, and combined losses.

```javascript
import {
    distillationLoss,
    supervisedLoss,
    combinedLoss,
    softmaxWithTemperature,
    analyzeTemperatureEffect
} from './src/distillation/loss.js';
```

### Function: `distillationLoss`

```javascript
distillationLoss(studentLogits, teacherProbs, temperature, average)
```

Computes distillation loss (KL divergence).

**Parameters:**
- `studentLogits` (number[][]): Student model logits
- `teacherProbs` (number[][]): Teacher soft targets
- `temperature` (number): Softmax temperature (default: 2.0)
- `average` (boolean): Average over sequence (default: true)

**Returns:** `number` - Distillation loss

**Example:**
```javascript
const loss = distillationLoss(
    studentLogits,
    teacherProbabilities,
    2.0,
    true
);
console.log(`Distillation loss: ${loss.toFixed(4)}`);
```

### Function: `supervisedLoss`

```javascript
supervisedLoss(studentLogits, targetIds, average)
```

Computes supervised loss (cross-entropy).

**Parameters:**
- `studentLogits` (number[][]): Student model logits
- `targetIds` (number[]): Target token IDs (hard labels)
- `average` (boolean): Average over sequence (default: true)

**Returns:** `number` - Supervised loss

**Example:**
```javascript
const loss = supervisedLoss(studentLogits, tokenIds, true);
console.log(`Supervised loss: ${loss.toFixed(4)}`);
```

### Function: `combinedLoss`

```javascript
combinedLoss(studentLogits, teacherProbs, targetIds, config)
```

Computes combined distillation + supervised loss.

**Parameters:**
- `studentLogits` (number[][]): Student model logits
- `teacherProbs` (number[][]): Teacher soft targets
- `targetIds` (number[]): Target token IDs
- `config.temperature` (number): Softmax temperature (default: 2.0)
- `config.alpha` (number): Distillation weight (default: 0.7)
- `config.average` (boolean): Average over sequence (default: true)

**Returns:** `Object`
```javascript
{
    distillationLoss: number,
    supervisedLoss: number,
    totalLoss: number,
    alpha: number,
    temperature: number
}
```

**Example:**
```javascript
const result = combinedLoss(
    studentLogits,
    teacherProbabilities,
    tokenIds,
    { temperature: 2.0, alpha: 0.7 }
);

console.log(`Total loss: ${result.totalLoss.toFixed(4)}`);
console.log(`Distillation: ${result.distillationLoss.toFixed(4)}`);
console.log(`Supervised: ${result.supervisedLoss.toFixed(4)}`);
```

### Function: `softmaxWithTemperature`

```javascript
softmaxWithTemperature(logits, temperature)
```

Applies temperature-scaled softmax.

**Parameters:**
- `logits` (number[]): Raw logits
- `temperature` (number): Temperature (default: 1.0)

**Returns:** `number[]` - Probability distribution

**Example:**
```javascript
const logits = [2.0, 1.0, 0.5, 0.1];
const probs = softmaxWithTemperature(logits, 2.0);
console.log(probs);
```

### Function: `analyzeTemperatureEffect`

```javascript
analyzeTemperatureEffect(logits, temperatures)
```

Analyzes the effect of temperature on soft targets.

**Parameters:**
- `logits` (number[]): Raw logits
- `temperatures` (number[]): Array of temperatures to test

**Returns:** `Object`
```javascript
{
    [temperature: number]: {
        probabilities: number[],    // Softmax probabilities
        entropy: number,           // Entropy of distribution
        maxProb: number,           // Maximum probability
        distribution: Array<{      // Top 5 probabilities
            index: number,
            prob: number
        }>
    }
}
```

**Example:**
```javascript
const logits = [3.0, 2.0, 1.0, 0.0];
const analysis = analyzeTemperatureEffect(logits, [0.5, 1.0, 2.0, 5.0]);

for (const [temp, data] of Object.entries(analysis)) {
    console.log(`Temperature ${temp}:`);
    console.log(`  Entropy: ${data.entropy.toFixed(3)}`);
    console.log(`  Max prob: ${data.maxProb.toFixed(3)}`);
}
```

---

## C.5 Common Usage Patterns

### Complete Distillation Training

```javascript
import { TextProcessingPipeline } from './src/tokenizer/pipeline.js';
import { TeacherModel } from './src/distillation/teacher.js';
import { StudentModel } from './src/distillation/student.js';
import { DistillationTrainer } from './src/distillation/trainer.js';
import { Transformer } from './src/transformer/transformer.js';

// 1. Create pipeline
const pipeline = new TextProcessingPipeline({
    vocabSize: 2000,
    embeddingDim: 64
});
pipeline.train("Your training corpus...");

// 2. Create teacher (large model)
const teacher = new TeacherModel({
    pipeline: pipeline,
    transformer: new Transformer({
        vocabSize: pipeline.getStats().vocabSize,
        d_model: 128,
        numHeads: 8,
        numLayers: 6
    })
});
await teacher.initialize();

// 3. Create student (small model)
const student = new StudentModel({
    vocabSize: pipeline.getStats().vocabSize,
    d_model: 32,
    numHeads: 4,
    numLayers: 2
});

// 4. Create trainer
const trainer = new DistillationTrainer({
    teacher: teacher,
    student: student,
    pipeline: pipeline,
    epochs: 10,
    batchSize: 8,
    temperature: 2.0,
    alpha: 0.7
});

// 5. Train
const texts = [
    "The quick brown fox jumps over the lazy dog.",
    "A fast cat runs through the garden.",
    // ... more training texts
];

const results = await trainer.train(texts, (result, state) => {
    console.log(`Epoch ${state.epoch + 1}: Loss = ${result.epochLoss.toFixed(4)}`);
});

// 6. Save models
teacher.saveToFile('./models/teacher.json');
student.saveToFile('./models/student.json');

console.log(`Best validation loss: ${results.bestValidationLoss.toFixed(4)}`);
```

### Comparing Teacher and Student

```javascript
function compareModels(teacher, student, pipeline) {
    const testText = "The quick brown fox";
    const processed = pipeline.processText(testText);
    const tokenIds = processed.tokenIds;
    
    // Get teacher predictions
    const teacherResult = teacher.predict(testText);
    const teacherLogits = teacherResult.logits;
    const teacherProbs = teacherResult.probabilities;
    
    // Get student predictions
    const studentResult = student.predict(tokenIds);
    const studentLogits = studentResult.logits;
    const studentProbs = studentResult.probabilities;
    
    // Compare distributions
    const lastTeacherProbs = teacherProbs[teacherProbs.length - 1];
    const lastStudentProbs = studentProbs[studentProbs.length - 1];
    
    const topTeacher = lastTeacherProbs
        .map((p, i) => ({ id: i, prob: p }))
        .sort((a, b) => b.prob - a.prob)
        .slice(0, 3);
    
    const topStudent = lastStudentProbs
        .map((p, i) => ({ id: i, prob: p }))
        .sort((a, b) => b.prob - a.prob)
        .slice(0, 3);
    
    // Compute KL divergence
    const klDiv = teacherProbs.reduce((sum, tp, i) => {
        const sp = studentProbs[i] || new Array(tp.length).fill(0);
        return sum + tp.reduce((s, p, j) => 
            s + p * Math.log((p + 1e-8) / (sp[j] + 1e-8)), 0
        );
    }, 0) / teacherProbs.length;
    
    return {
        teacherTopTokens: topTeacher.map(t => ({
            token: pipeline.vocabulary.getToken(t.id),
            prob: t.prob
        })),
        studentTopTokens: topStudent.map(t => ({
            token: pipeline.vocabulary.getToken(t.id),
            prob: t.prob
        })),
        klDivergence: klDiv,
        teacherParams: teacher.getStats().parameters,
        studentParams: student.getStats().parameters,
        compressionRatio: teacher.getStats().parameters / student.getStats().parameters
    };
}

// Usage
const comparison = compareModels(teacher, student, pipeline);
console.log(`Compression ratio: ${comparison.compressionRatio.toFixed(2)}x`);
console.log(`KL divergence: ${comparison.klDivergence.toFixed(4)}`);
```

### Temperature Sweep Analysis

```javascript
function temperatureSweep(teacher, pipeline, text, temperatures) {
    const processed = pipeline.processText(text);
    const tokenIds = processed.tokenIds;
    
    const results = {};
    for (const temp of temperatures) {
        const targets = teacher.getSoftTargets(tokenIds, temp);
        const lastProbs = targets.probabilities[targets.probabilities.length - 1];
        
        // Get top 3 tokens
        const topTokens = lastProbs
            .map((p, i) => ({ token: pipeline.vocabulary.getToken(i), prob: p }))
            .sort((a, b) => b.prob - a.prob)
            .slice(0, 3);
        
        results[temp] = {
            entropy: -lastProbs.reduce((s, p) => s + (p > 0 ? p * Math.log(p) : 0), 0),
            topTokens: topTokens,
            distributionSpread: 1 - Math.max(...lastProbs)
        };
    }
    return results;
}

// Usage
const temperatures = [0.5, 1.0, 2.0, 5.0];
const sweep = temperatureSweep(teacher, pipeline, "The meaning of life", temperatures);

for (const [temp, data] of Object.entries(sweep)) {
    console.log(`\nTemperature ${temp}:`);
    console.log(`  Entropy: ${data.entropy.toFixed(3)}`);
    console.log(`  Top tokens: ${data.topTokens.map(t => t.token).join(', ')}`);
    console.log(`  Spread: ${data.distributionSpread.toFixed(3)}`);
}
```

---

## C.6 Performance Optimization

### Batch Processing for Distillation

```javascript
// Process in batches for efficiency
const batchSize = 16;
const allTexts = getTrainingTexts();

for (let i = 0; i < allTexts.length; i += batchSize) {
    const batch = allTexts.slice(i, i + batchSize);
    const batchResults = [];
    
    // Tokenize batch
    for (const text of batch) {
        const processed = pipeline.processText(text);
        batchResults.push(processed.tokenIds);
    }
    
    // Get teacher targets for batch
    const batchTargets = trainer.getTeacherTargets(batchResults);
    
    // Train student on batch
    for (let j = 0; j < batchResults.length; j++) {
        student.trainStep(batchResults[j], batchTargets[j]);
    }
}
```

### Memory-Efficient Training

```javascript
// Use streaming data for large datasets
async function streamTrainingData(filepath, batchSize) {
    const fs = require('fs');
    const readline = require('readline');
    
    const fileStream = fs.createReadStream(filepath);
    const rl = readline.createInterface({
        input: fileStream,
        crlfDelay: Infinity
    });
    
    let batch = [];
    for await (const line of rl) {
        if (line.trim()) {
            batch.push(line);
            if (batch.length >= batchSize) {
                yield batch;
                batch = [];
            }
        }
    }
    if (batch.length > 0) {
        yield batch;
    }
}

// Usage
for await (const batch of streamTrainingData('data.txt', 8)) {
    const tokenized = batch.map(text => pipeline.processText(text).tokenIds);
    const targets = trainer.getTeacherTargets(tokenized);
    for (let i = 0; i < tokenized.length; i++) {
        student.trainStep(tokenized[i], targets[i]);
    }
}
```

---

## C.7 Error Handling Reference

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `Teacher model not loaded` | `initialize()` not called | Call `await teacher.initialize()` first |
| `Invalid temperature` | Temperature ≤ 0 | Use positive temperature (≥ 0.1) |
| `Alpha out of range` | Alpha not in [0,1] | Set alpha between 0 and 1 |
| `Batch size too large` | Out of memory | Reduce batch size |
| `Student too small` | Poor performance | Increase student size or adjust distillation parameters |

### Defensive Training

```javascript
async function safeTrain(trainer, texts, maxRetries = 3) {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            console.log(`Training attempt ${attempt}/${maxRetries}`);
            
            // Reduce batch size on retry
            if (attempt > 1) {
                trainer.trainingConfig.batchSize = Math.max(2, Math.floor(
                    trainer.trainingConfig.batchSize / 2
                ));
                console.log(`Reduced batch size to ${trainer.trainingConfig.batchSize}`);
            }
            
            const results = await trainer.train(texts);
            return results;
            
        } catch (error) {
            console.error(`Attempt ${attempt} failed:`, error.message);
            if (attempt === maxRetries) {
                throw new Error(`Training failed after ${maxRetries} attempts: ${error.message}`);
            }
            // Wait before retry
            await new Promise(resolve => setTimeout(resolve, 2000));
        }
    }
}
```

---

## C.8 Advanced Configuration

### Custom Alpha Schedules

```javascript
// Dynamic alpha (distillation weight) schedule
function getAlpha(epoch, totalEpochs) {
    // Start with high distillation weight, gradually reduce
    const startAlpha = 0.9;
    const endAlpha = 0.5;
    const progress = epoch / totalEpochs;
    return startAlpha - (startAlpha - endAlpha) * progress;
}

// Usage in training loop
for (let epoch = 0; epoch < totalEpochs; epoch++) {
    const alpha = getAlpha(epoch, totalEpochs);
    trainer.trainingConfig.alpha = alpha;
    console.log(`Epoch ${epoch + 1}: Alpha = ${alpha.toFixed(3)}`);
    // ... train epoch
}
```

### Custom Temperature Schedules

```javascript
// Gradual temperature increase
function getTemperature(epoch, totalEpochs) {
    // Start with low temperature, gradually increase
    const startTemp = 1.0;
    const endTemp = 3.0;
    const progress = epoch / totalEpochs;
    return startTemp + (endTemp - startTemp) * progress;
}

// Usage
for (let epoch = 0; epoch < totalEpochs; epoch++) {
    const temp = getTemperature(epoch, totalEpochs);
    trainer.trainingConfig.temperature = temp;
    console.log(`Epoch ${epoch + 1}: Temperature = ${temp.toFixed(3)}`);
    // ... train epoch
}
```

### Ensemble Distillation

```javascript
// Distill from multiple teachers
class EnsembleTeacher {
    constructor(teachers) {
        this.teachers = teachers;
    }
    
    getSoftTargets(tokenIds, temperature = 2.0) {
        // Get predictions from all teachers
        const allTargets = this.teachers.map(teacher =>
            teacher.getSoftTargets(tokenIds, temperature)
        );
        
        // Average the probabilities
        const numTeachers = allTargets.length;
        const avgProbs = allTargets[0].probabilities.map((_, i) => {
            return allTargets[0].probabilities[i].map((_, j) => {
                let sum = 0;
                for (const targets of allTargets) {
                    sum += targets.probabilities[i][j];
                }
                return sum / numTeachers;
            });
        });
        
        return {
            probabilities: avgProbs,
            logits: null, // Can't average logits easily
            temperature: temperature
        };
    }
}

// Usage
const teacher1 = new TeacherModel({ /* config */ });
const teacher2 = new TeacherModel({ /* config */ });
const ensemble = new EnsembleTeacher([teacher1, teacher2]);

// Use ensemble teacher for distillation
const targets = ensemble.getSoftTargets(tokenIds, 2.0);
```

---

## C.9 API Quick Reference Card

```javascript
// QUICK REFERENCE - DISTILLATION API

// Teacher Model
const teacher = new TeacherModel({ pipeline, transformer });
await teacher.initialize();
const targets = teacher.getSoftTargets(tokenIds, 2.0);
const prediction = teacher.predict("Text", 1.0);

// Student Model
const student = new StudentModel({
    vocabSize: 1000,
    d_model: 32,
    numHeads: 4,
    numLayers: 2
});
const { logits } = student.forward(tokenIds);
const loss = student.computeDistillationLoss(logits, teacherProbs, 2.0, 0.7);

// Trainer
const trainer = new DistillationTrainer({
    teacher, student, pipeline,
    epochs: 10,
    batchSize: 8,
    temperature: 2.0,
    alpha: 0.7
});
const results = await trainer.train(texts);

// Loss Functions
const distLoss = distillationLoss(studentLogits, teacherProbs, 2.0);
const supLoss = supervisedLoss(studentLogits, tokenIds);
const combined = combinedLoss(studentLogits, teacherProbs, tokenIds, {
    temperature: 2.0,
    alpha: 0.7
});

// Utilities
const probs = softmaxWithTemperature(logits, 2.0);
const analysis = analyzeTemperatureEffect(logits, [0.5, 1.0, 2.0]);

// Save/Load
teacher.saveToFile('./teacher.json');
student.saveToFile('./student.json');
student.loadFromFile('./student.json');
```

---

**[END OF APPENDIX C]**

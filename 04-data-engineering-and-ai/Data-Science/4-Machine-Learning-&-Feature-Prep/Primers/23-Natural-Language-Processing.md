# Primer 23: Natural Language Processing (NLP)

## Overview

This primer provides a comprehensive introduction to Natural Language Processing (NLP)—the field of making computers understand, interpret, and generate human language. Understanding NLP is essential for applications like chatbots, sentiment analysis, text classification, and information extraction.

---

## 1. Introduction to NLP

### What is Natural Language Processing?

```
┌─────────────────────────────────────────────────────────────────┐
│                    WHAT IS NLP?                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  NLP sits at the intersection of:                              │
│                                                                 │
│  ╔═══════════════════╗  ╔═══════════════════╗                  │
│  ║   Computational   ║  ║   Linguistics     ║                  │
│  ║   Linguistics     ║  ║                   ║                  │
│  ╚═══════════════════╝  ╚═══════════════════╝                  │
│           ╲                      ╱                             │
│            ╲                    ╱                              │
│             ╲                  ╱                               │
│              ╲                ╱                                │
│               ╲              ╱                                 │
│                ╲            ╱                                  │
│                 ╲          ╱                                   │
│                  ╲        ╱                                    │
│                   ╲      ╱                                     │
│                    ╲    ╱                                      │
│                     ╲  ╱                                       │
│                      ╲╱                                        │
│               ╔═══════════════════╗                            │
│               ║   Machine         ║                            │
│               ║   Learning        ║                            │
│               ╚═══════════════════╝                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### NLP Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    NLP PIPELINE                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Raw Text                                                       │
│      │                                                          │
│      ▼                                                          │
│  1. Text Preprocessing                                         │
│     ├── Lowercasing                                            │
│     ├── Tokenization                                           │
│     ├── Stopword Removal                                       │
│     └── Stemming/Lemmatization                                 │
│                                                                 │
│  2. Feature Extraction                                         │
│     ├── Bag of Words                                           │
│     ├── TF-IDF                                                 │
│     ├── Word Embeddings                                        │
│     └── Contextual Embeddings                                  │
│                                                                 │
│  3. Modeling                                                   │
│     ├── Text Classification                                    │
│     ├── Named Entity Recognition                               │
│     ├── Sentiment Analysis                                     │
│     └── Machine Translation                                    │
│                                                                 │
│  4. Output                                                     │
│     └── Structured Information                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Text Preprocessing

### Basic Text Preprocessing

```python
import re
import nltk
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer, WordNetLemmatizer
from nltk.tokenize import word_tokenize, sent_tokenize

# Download NLTK data (first time)
nltk.download('punkt')
nltk.download('stopwords')
nltk.download('wordnet')
nltk.download('omw-1.4')

class TextPreprocessor:
    """
    Text preprocessing utilities.
    """
    
    def __init__(self, remove_stopwords=True, lowercase=True, remove_punctuation=True):
        self.remove_stopwords = remove_stopwords
        self.lowercase = lowercase
        self.remove_punctuation = remove_punctuation
        self.stopwords = set(stopwords.words('english')) if remove_stopwords else set()
        self.stemmer = PorterStemmer()
        self.lemmatizer = WordNetLemmatizer()
    
    def preprocess(self, text, stem=False, lemmatize=False):
        """
        Preprocess text.
        
        Args:
            text: Input text
            stem: Whether to apply stemming
            lemmatize: Whether to apply lemmatization
        
        Returns:
            list: Processed tokens
        """
        # Lowercase
        if self.lowercase:
            text = text.lower()
        
        # Remove punctuation
        if self.remove_punctuation:
            text = re.sub(r'[^\w\s]', '', text)
        
        # Tokenize
        tokens = word_tokenize(text)
        
        # Remove stopwords
        if self.remove_stopwords:
            tokens = [t for t in tokens if t not in self.stopwords]
        
        # Apply stemming or lemmatization
        if stem:
            tokens = [self.stemmer.stem(t) for t in tokens]
        elif lemmatize:
            tokens = [self.lemmatizer.lemmatize(t) for t in tokens]
        
        return tokens
    
    def preprocess_document(self, docs, stem=False, lemmatize=False):
        """Preprocess multiple documents."""
        return [self.preprocess(doc, stem, lemmatize) for doc in docs]

# Example usage
preprocessor = TextPreprocessor()

text = "The quick brown foxes are jumping over the lazy dogs. They are very quick!"
processed = preprocessor.preprocess(text, lemmatize=True)
print("Original:", text)
print("Processed:", " ".join(processed))
```

### Advanced Preprocessing

```python
class AdvancedTextPreprocessor:
    """
    Advanced text preprocessing with additional features.
    """
    
    def __init__(self, config=None):
        self.config = config or {}
        self._init_components()
    
    def _init_components(self):
        """Initialize preprocessing components."""
        # Initialize spaCy if available
        try:
            import spacy
            self.nlp = spacy.load('en_core_web_sm')
            self.has_spacy = True
        except:
            self.has_spacy = False
        
        # Initialize TextBlob if available
        try:
            from textblob import TextBlob
            self.has_textblob = True
        except:
            self.has_textblob = False
    
    def preprocess(self, text):
        """
        Advanced text preprocessing.
        
        Args:
            text: Input text
        
        Returns:
            dict: Preprocessing results
        """
        results = {
            'original': text,
            'cleaned': None,
            'tokens': None,
            'lemmas': None,
            'pos_tags': None,
            'entities': None,
            'sentiment': None
        }
        
        # spaCy processing
        if self.has_spacy:
            doc = self.nlp(text)
            results['tokens'] = [token.text for token in doc]
            results['lemmas'] = [token.lemma_ for token in doc]
            results['pos_tags'] = [(token.text, token.pos_) for token in doc]
            results['entities'] = [(ent.text, ent.label_) for ent in doc.ents]
        
        # TextBlob sentiment
        if self.has_textblob:
            blob = TextBlob(text)
            results['sentiment'] = {
                'polarity': blob.sentiment.polarity,
                'subjectivity': blob.sentiment.subjectivity
            }
        
        return results
```

---

## 3. Feature Extraction

### Bag of Words (BoW)

```python
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer

def bag_of_words(docs, max_features=1000, ngram_range=(1, 2)):
    """
    Create Bag of Words features.
    
    Args:
        docs: List of documents
        max_features: Maximum number of features
        ngram_range: Range of n-grams
    
    Returns:
        tuple: (vectorizer, features)
    """
    vectorizer = CountVectorizer(
        max_features=max_features,
        ngram_range=ngram_range,
        stop_words='english'
    )
    
    features = vectorizer.fit_transform(docs)
    feature_names = vectorizer.get_feature_names_out()
    
    return vectorizer, features

def tfidf(docs, max_features=1000, ngram_range=(1, 2)):
    """
    Create TF-IDF features.
    
    Args:
        docs: List of documents
        max_features: Maximum number of features
        ngram_range: Range of n-grams
    
    Returns:
        tuple: (vectorizer, features)
    """
    vectorizer = TfidfVectorizer(
        max_features=max_features,
        ngram_range=ngram_range,
        stop_words='english',
        use_idf=True,
        smooth_idf=True
    )
    
    features = vectorizer.fit_transform(docs)
    feature_names = vectorizer.get_feature_names_out()
    
    return vectorizer, features
```

### Word Embeddings

```python
import numpy as np
from gensim.models import Word2Vec, KeyedVectors

class WordEmbeddings:
    """
    Word embedding utilities.
    """
    
    def __init__(self, embedding_dim=100):
        self.embedding_dim = embedding_dim
        self.model = None
        self.word_vectors = None
    
    def train_word2vec(self, sentences, min_count=1, window=5):
        """
        Train Word2Vec model.
        
        Args:
            sentences: List of tokenized sentences
            min_count: Minimum word count
            window: Context window size
        """
        self.model = Word2Vec(
            sentences,
            vector_size=self.embedding_dim,
            window=window,
            min_count=min_count,
            sg=1  # Skip-gram
        )
        self.word_vectors = self.model.wv
        print(f"Word2Vec trained with {len(self.word_vectors)} words")
        return self.model
    
    def get_embedding(self, word):
        """Get embedding for a word."""
        if self.word_vectors and word in self.word_vectors:
            return self.word_vectors[word]
        return None
    
    def load_pretrained(self, filepath):
        """Load pre-trained embeddings."""
        self.word_vectors = KeyedVectors.load_word2vec_format(filepath, binary=False)
        print(f"Loaded {len(self.word_vectors)} words")
        return self.word_vectors
    
    def average_document_embedding(self, tokens):
        """
        Average word embeddings for a document.
        
        Args:
            tokens: List of tokens
        
        Returns:
            np.ndarray: Document embedding
        """
        embeddings = []
        for token in tokens:
            emb = self.get_embedding(token)
            if emb is not None:
                embeddings.append(emb)
        
        if embeddings:
            return np.mean(embeddings, axis=0)
        return np.zeros(self.embedding_dim)
    
    def tfidf_weighted_embedding(self, tokens, tfidf_model):
        """
        TF-IDF weighted document embedding.
        
        Args:
            tokens: List of tokens
            tfidf_model: Trained TF-IDF vectorizer
        
        Returns:
            np.ndarray: Weighted document embedding
        """
        # This would require mapping tokens to TF-IDF weights
        pass
```

### Contextual Embeddings (Transformers)

```python
from transformers import AutoTokenizer, AutoModel
import torch

class TransformerEmbeddings:
    """
    Contextual embeddings using Transformers.
    """
    
    def __init__(self, model_name='bert-base-uncased'):
        self.model_name = model_name
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModel.from_pretrained(model_name)
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        self.model.to(self.device)
    
    def get_embeddings(self, texts, pooling='mean'):
        """
        Get contextual embeddings for texts.
        
        Args:
            texts: List of texts
            pooling: Pooling strategy ('mean', 'cls', 'max')
        
        Returns:
            np.ndarray: Embeddings
        """
        # Tokenize
        inputs = self.tokenizer(
            texts,
            return_tensors='pt',
            padding=True,
            truncation=True,
            max_length=512
        ).to(self.device)
        
        # Get model output
        with torch.no_grad():
            outputs = self.model(**inputs)
            hidden_states = outputs.last_hidden_state
        
        # Pool embeddings
        if pooling == 'mean':
            # Mean pooling (attention mask for padding)
            attention_mask = inputs['attention_mask']
            embeddings = self._mean_pooling(hidden_states, attention_mask)
        elif pooling == 'cls':
            embeddings = hidden_states[:, 0, :]  # CLS token
        elif pooling == 'max':
            embeddings = torch.max(hidden_states, dim=1)[0]
        
        return embeddings.cpu().numpy()
    
    def _mean_pooling(self, hidden_states, attention_mask):
        """Mean pooling with attention mask."""
        # Expand mask to hidden states
        mask = attention_mask.unsqueeze(-1).expand(hidden_states.size()).float()
        
        # Sum hidden states
        sum_embeddings = torch.sum(hidden_states * mask, dim=1)
        
        # Count non-padding tokens
        sum_mask = torch.sum(mask, dim=1)
        
        # Mean
        embeddings = sum_embeddings / sum_mask
        
        return embeddings
    
    def get_sentence_embedding(self, text):
        """Get embedding for a single sentence."""
        return self.get_embeddings([text])[0]
    
    def get_similarity(self, text1, text2):
        """
        Calculate cosine similarity between two texts.
        
        Args:
            text1: First text
            text2: Second text
        
        Returns:
            float: Cosine similarity
        """
        emb1 = self.get_sentence_embedding(text1)
        emb2 = self.get_sentence_embedding(text2)
        
        return np.dot(emb1, emb2) / (np.linalg.norm(emb1) * np.linalg.norm(emb2))
```

---

## 4. Text Classification

### Simple Text Classifier

```python
from sklearn.naive_bayes import MultinomialNB
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score

class TextClassifier:
    """
    Text classification with multiple models.
    """
    
    def __init__(self, model_type='logistic', max_features=10000, ngram_range=(1, 2)):
        self.model_type = model_type
        self.max_features = max_features
        self.ngram_range = ngram_range
        self.vectorizer = None
        self.model = None
    
    def train(self, X_train, y_train, X_val=None, y_val=None):
        """
        Train text classifier.
        
        Args:
            X_train: Training texts
            y_train: Training labels
            X_val: Validation texts
            y_val: Validation labels
        """
        # Create TF-IDF features
        self.vectorizer = TfidfVectorizer(
            max_features=self.max_features,
            ngram_range=self.ngram_range,
            stop_words='english'
        )
        
        X_train_tfidf = self.vectorizer.fit_transform(X_train)
        
        if X_val is not None:
            X_val_tfidf = self.vectorizer.transform(X_val)
        
        # Create model
        if self.model_type == 'naive_bayes':
            self.model = MultinomialNB()
        elif self.model_type == 'logistic':
            self.model = LogisticRegression(max_iter=1000, random_state=42)
        elif self.model_type == 'random_forest':
            self.model = RandomForestClassifier(n_estimators=100, random_state=42)
        else:
            raise ValueError(f"Unknown model type: {self.model_type}")
        
        # Train
        self.model.fit(X_train_tfidf, y_train)
        
        # Validation
        if X_val is not None:
            y_pred = self.model.predict(X_val_tfidf)
            accuracy = accuracy_score(y_val, y_pred)
            print(f"Validation Accuracy: {accuracy:.4f}")
            
            # If multi-class, show full report
            if len(np.unique(y_train)) > 2:
                print("\nClassification Report:")
                print(classification_report(y_val, y_pred))
        
        return self.model
    
    def predict(self, texts):
        """Predict labels for new texts."""
        X_tfidf = self.vectorizer.transform(texts)
        return self.model.predict(X_tfidf)
    
    def predict_proba(self, texts):
        """Predict probabilities."""
        X_tfidf = self.vectorizer.transform(texts)
        return self.model.predict_proba(X_tfidf)
```

### Transformers for Classification

```python
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from transformers import TrainingArguments, Trainer
import torch.nn.functional as F

class TransformerClassifier:
    """
    Text classification using Transformers.
    """
    
    def __init__(self, model_name='bert-base-uncased', num_labels=2):
        self.model_name = model_name
        self.num_labels = num_labels
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = None
    
    def train(self, train_texts, train_labels, val_texts=None, val_labels=None, epochs=3):
        """
        Train transformer classifier.
        
        Args:
            train_texts: Training texts
            train_labels: Training labels
            val_texts: Validation texts
            val_labels: Validation labels
            epochs: Number of epochs
        """
        from transformers import AutoModelForSequenceClassification
        
        # Create datasets
        train_dataset = self._create_dataset(train_texts, train_labels)
        
        if val_texts is not None:
            val_dataset = self._create_dataset(val_texts, val_labels)
        
        # Load model
        self.model = AutoModelForSequenceClassification.from_pretrained(
            self.model_name,
            num_labels=self.num_labels
        )
        
        # Training arguments
        training_args = TrainingArguments(
            output_dir='./results',
            num_train_epochs=epochs,
            per_device_train_batch_size=16,
            per_device_eval_batch_size=16,
            warmup_steps=500,
            weight_decay=0.01,
            logging_dir='./logs',
            logging_steps=10,
            evaluation_strategy='epoch' if val_texts is not None else 'no'
        )
        
        # Trainer
        trainer = Trainer(
            model=self.model,
            args=training_args,
            train_dataset=train_dataset,
            eval_dataset=val_dataset if val_texts is not None else None
        )
        
        # Train
        trainer.train()
        
        return self.model
    
    def _create_dataset(self, texts, labels):
        """Create Hugging Face Dataset."""
        from datasets import Dataset
        
        # Tokenize
        encodings = self.tokenizer(
            texts,
            truncation=True,
            padding=True,
            max_length=512
        )
        
        # Create dataset
        dataset = Dataset.from_dict({
            'input_ids': encodings['input_ids'],
            'attention_mask': encodings['attention_mask'],
            'labels': labels
        })
        
        dataset.set_format('pt', columns=['input_ids', 'attention_mask', 'labels'])
        
        return dataset
    
    def predict(self, texts):
        """Predict labels."""
        if self.model is None:
            raise ValueError("Model not trained. Call train() first.")
        
        # Tokenize
        inputs = self.tokenizer(
            texts,
            return_tensors='pt',
            padding=True,
            truncation=True,
            max_length=512
        )
        
        # Predict
        with torch.no_grad():
            outputs = self.model(**inputs)
            logits = outputs.logits
            predictions = torch.argmax(logits, dim=1)
        
        return predictions.numpy()
    
    def predict_proba(self, texts):
        """Predict probabilities."""
        if self.model is None:
            raise ValueError("Model not trained. Call train() first.")
        
        inputs = self.tokenizer(
            texts,
            return_tensors='pt',
            padding=True,
            truncation=True,
            max_length=512
        )
        
        with torch.no_grad():
            outputs = self.model(**inputs)
            logits = outputs.logits
            probabilities = F.softmax(logits, dim=1)
        
        return probabilities.numpy()
```

---

## 5. Sentiment Analysis

### Simple Sentiment Analysis

```python
from textblob import TextBlob
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

class SentimentAnalyzer:
    """
    Sentiment analysis utilities.
    """
    
    def __init__(self, method='vader'):
        self.method = method
        if method == 'vader':
            self.analyzer = SentimentIntensityAnalyzer()
        elif method == 'textblob':
            self.analyzer = None  # TextBlob is used directly
    
    def analyze(self, text):
        """
        Analyze sentiment of text.
        
        Args:
            text: Input text
        
        Returns:
            dict: Sentiment scores
        """
        if self.method == 'vader':
            return self._vader_analysis(text)
        elif self.method == 'textblob':
            return self._textblob_analysis(text)
        else:
            raise ValueError(f"Unknown method: {self.method}")
    
    def _vader_analysis(self, text):
        """VADER sentiment analysis."""
        scores = self.analyzer.polarity_scores(text)
        
        # Determine sentiment label
        if scores['compound'] >= 0.05:
            label = 'positive'
        elif scores['compound'] <= -0.05:
            label = 'negative'
        else:
            label = 'neutral'
        
        return {
            'label': label,
            'positive': scores['pos'],
            'negative': scores['neg'],
            'neutral': scores['neu'],
            'compound': scores['compound']
        }
    
    def _textblob_analysis(self, text):
        """TextBlob sentiment analysis."""
        blob = TextBlob(text)
        polarity = blob.sentiment.polarity
        subjectivity = blob.sentiment.subjectivity
        
        # Determine sentiment label
        if polarity > 0.1:
            label = 'positive'
        elif polarity < -0.1:
            label = 'negative'
        else:
            label = 'neutral'
        
        return {
            'label': label,
            'polarity': polarity,
            'subjectivity': subjectivity
        }
    
    def analyze_batch(self, texts):
        """Analyze sentiment for multiple texts."""
        return [self.analyze(text) for text in texts]
```

---

## 6. Named Entity Recognition (NER)

```python
import spacy

class NamedEntityRecognizer:
    """
    Named Entity Recognition with spaCy.
    """
    
    def __init__(self, model='en_core_web_sm'):
        self.nlp = spacy.load(model)
    
    def extract_entities(self, text):
        """
        Extract named entities from text.
        
        Args:
            text: Input text
        
        Returns:
            list: Extracted entities
        """
        doc = self.nlp(text)
        entities = []
        
        for ent in doc.ents:
            entities.append({
                'text': ent.text,
                'label': ent.label_,
                'start': ent.start_char,
                'end': ent.end_char
            })
        
        return entities
    
    def extract_entities_batch(self, texts):
        """Extract entities from multiple texts."""
        return [self.extract_entities(text) for text in texts]
    
    def get_entity_summary(self, texts):
        """
        Get entity frequency summary.
        
        Args:
            texts: List of texts
        
        Returns:
            dict: Entity frequency by type
        """
        summary = {}
        
        for text in texts:
            entities = self.extract_entities(text)
            for entity in entities:
                label = entity['label']
                if label not in summary:
                    summary[label] = {'count': 0, 'examples': []}
                summary[label]['count'] += 1
                if len(summary[label]['examples']) < 5:
                    summary[label]['examples'].append(entity['text'])
        
        return summary
```

---

## Quick Reference: NLP Tasks

### Common NLP Tasks

```
┌─────────────────────────────────────────────────────────────────┐
│  TASK                │ DESCRIPTION                            │
├──────────────────────┼─────────────────────────────────────────┤
│  Text Classification │ Assign categories to text             │
│  Sentiment Analysis  │ Determine sentiment (positive/negative)│
│  NER                 │ Extract named entities                 │
│  Machine Translation │ Translate between languages            │
│  Question Answering  │ Answer questions based on context     │
│  Text Summarization  │ Generate concise summaries            │
│  Topic Modeling      │ Discover topics in documents          │
│  Text Generation     │ Generate new text                    │
│  Language Modeling   │ Predict next word/sentence           │
│  Text Similarity     │ Compute similarity between texts     │
└─────────────────────────────────────────────────────────────────┘
```

### NLP Libraries

```
┌─────────────────────────────────────────────────────────────────┐
│  LIBRARY         │ PURPOSE                    │ EASE OF USE  │
├──────────────────┼────────────────────────────┼──────────────┤
│  NLTK            │ Education, Basic NLP       │ High         │
│  spaCy           │ Production NLP             │ High         │
│  TextBlob        │ Simple NLP tasks           │ Very High    │
│  Transformers    │ State-of-the-art models    │ Medium       │
│  Gensim          │ Topic modeling, embeddings │ Medium       │
│  Flair           │ Advanced NLP               │ Medium       │
│  AllenNLP        │ Research NLP               │ Low          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers the essential concepts of Natural Language Processing. You now understand:

1. **NLP pipeline**: Preprocessing, feature extraction, modeling
2. **Text preprocessing**: Tokenization, stopwords, stemming, lemmatization
3. **Feature extraction**: BoW, TF-IDF, word embeddings, contextual embeddings
4. **Text classification**: Traditional ML and Transformers
5. **Sentiment analysis**: VADER, TextBlob
6. **Named Entity Recognition**: spaCy

**Next Steps:**
1. Practice with text preprocessing
2. Build a text classifier
3. Implement sentiment analysis
4. Extract named entities
5. Proceed to Part 1 of the series

---

*End of Primer 23*

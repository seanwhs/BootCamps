# Part 2: State Management & Local Persistence
## Phase 1: Local State & Component Lifecycle

Welcome to Part 2! Now that your app has a solid foundation with navigation and beautiful UI components, it's time to make it come alive with data. In this phase, we'll master React's state management capabilities within React Native, understanding how to handle local component state, side effects, and performance optimizations.

---

## Target 1: Understanding State in React Native

**The Target:** Master the fundamentals of state management in React Native.

**The Concept:** Think of state as your app's memory. When a user interacts with your app—typing in a field, toggling a switch, or loading data—that information needs to be stored somewhere. React provides hooks like `useState` and `useReducer` to manage this memory at the component level.

### State Fundamentals

```typescript
// src/examples/StateFundamentals.tsx
import React, { useState, useReducer, useCallback, useMemo } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Switch,
  Platform,
} from 'react-native';

/**
 * StateFundamentals - Demonstrates React state concepts
 * 
 * This component shows different ways to manage local state
 * in React Native components.
 */
export const StateFundamentals: React.FC = () => {
  // 1. useState - Simple state management
  const [count, setCount] = useState(0);
  const [text, setText] = useState('');
  const [isEnabled, setIsEnabled] = useState(false);
  const [user, setUser] = useState({ name: '', age: 0 });

  // 2. useReducer - Complex state management
  type TodoState = {
    todos: string[];
    filter: 'all' | 'completed' | 'pending';
  };

  type TodoAction = 
    | { type: 'ADD_TODO'; payload: string }
    | { type: 'REMOVE_TODO'; payload: number }
    | { type: 'SET_FILTER'; payload: 'all' | 'completed' | 'pending' };

  const todoReducer = (state: TodoState, action: TodoAction): TodoState => {
    switch (action.type) {
      case 'ADD_TODO':
        return { ...state, todos: [...state.todos, action.payload] };
      case 'REMOVE_TODO':
        return { 
          ...state, 
          todos: state.todos.filter((_, i) => i !== action.payload) 
        };
      case 'SET_FILTER':
        return { ...state, filter: action.payload };
      default:
        return state;
    }
  };

  const [todoState, dispatchTodo] = useReducer(todoReducer, {
    todos: ['Learn React Native', 'Build a project'],
    filter: 'all',
  });

  // 3. useMemo - Memoize expensive computations
  const expensiveComputation = useMemo(() => {
    console.log('Running expensive computation...');
    return Array.from({ length: 10000 }, (_, i) => i)
      .reduce((sum, num) => sum + num, 0);
  }, []); // Empty dependency array = compute once

  // 4. useCallback - Memoize functions
  const handleIncrement = useCallback(() => {
    setCount(prev => prev + 1);
  }, []);

  const handleDecrement = useCallback(() => {
    setCount(prev => prev - 1);
  }, []);

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.title}>State Fundamentals</Text>

      {/* useState Examples */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>1. useState - Simple Counter</Text>
        <View style={styles.counterContainer}>
          <TouchableOpacity style={styles.counterButton} onPress={handleDecrement}>
            <Text style={styles.counterButtonText}>-</Text>
          </TouchableOpacity>
          <Text style={styles.counterText}>{count}</Text>
          <TouchableOpacity style={styles.counterButton} onPress={handleIncrement}>
            <Text style={styles.counterButtonText}>+</Text>
          </TouchableOpacity>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>2. useState - Text Input</Text>
        <TextInput
          style={styles.input}
          placeholder="Type something..."
          value={text}
          onChangeText={setText}
          placeholderTextColor="#95a5a6"
        />
        <Text style={styles.inputDisplay}>You typed: {text || 'Nothing yet'}</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>3. useState - Toggle Switch</Text>
        <View style={styles.switchContainer}>
          <Text style={styles.switchLabel}>Enabled: {isEnabled ? 'Yes' : 'No'}</Text>
          <Switch
            trackColor={{ false: '#e1e8ed', true: '#3498db' }}
            thumbColor={Platform.OS === 'ios' ? '#ffffff' : '#3498db'}
            onValueChange={setIsEnabled}
            value={isEnabled}
          />
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>4. useState - Object State</Text>
        <TextInput
          style={styles.input}
          placeholder="Enter name"
          value={user.name}
          onChangeText={(name) => setUser({ ...user, name })}
          placeholderTextColor="#95a5a6"
        />
        <TextInput
          style={styles.input}
          placeholder="Enter age"
          value={user.age ? String(user.age) : ''}
          onChangeText={(age) => setUser({ ...user, age: Number(age) || 0 })}
          keyboardType="numeric"
          placeholderTextColor="#95a5a6"
        />
        <Text style={styles.userDisplay}>
          User: {user.name || 'Anonymous'} ({user.age || 0} years old)
        </Text>
      </View>

      {/* useReducer Examples */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>5. useReducer - Todo List</Text>
        <View style={styles.todoInputContainer}>
          <TextInput
            style={[styles.input, styles.todoInput]}
            placeholder="Add a todo..."
            onSubmitEditing={(e) => {
              const text = e.nativeEvent.text;
              if (text.trim()) {
                dispatchTodo({ type: 'ADD_TODO', payload: text });
                e.target.value = ''; // Clear input
              }
            }}
            placeholderTextColor="#95a5a6"
          />
          <TouchableOpacity 
            style={styles.todoFilterButton}
            onPress={() => dispatchTodo({ type: 'SET_FILTER', payload: 'all' })}
          >
            <Text style={styles.todoFilterText}>All</Text>
          </TouchableOpacity>
        </View>
        <View style={styles.todoList}>
          {todoState.todos.map((todo, index) => (
            <View key={index} style={styles.todoItem}>
              <Text style={styles.todoText}>{todo}</Text>
              <TouchableOpacity 
                onPress={() => dispatchTodo({ type: 'REMOVE_TODO', payload: index })}
              >
                <Text style={styles.todoDelete}>✕</Text>
              </TouchableOpacity>
            </View>
          ))}
          {todoState.todos.length === 0 && (
            <Text style={styles.todoEmpty}>No todos yet. Add one above!</Text>
          )}
        </View>
      </View>

      {/* useMemo Example */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>6. useMemo - Expensive Computation</Text>
        <Text style={styles.computationResult}>
          Sum of 1 to 10,000: {expensiveComputation}
        </Text>
        <Text style={styles.computationNote}>
          (This value is memoized and only computed once)
        </Text>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  content: {
    padding: 16,
    paddingBottom: 40,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 24,
    textAlign: 'center',
  },
  section: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
      },
      android: {
        elevation: 2,
      },
    }),
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 12,
  },
  counterContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  counterButton: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#3498db',
    alignItems: 'center',
    justifyContent: 'center',
  },
  counterButtonText: {
    color: '#ffffff',
    fontSize: 24,
    fontWeight: '600',
  },
  counterText: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginHorizontal: 20,
    minWidth: 40,
    textAlign: 'center',
  },
  input: {
    backgroundColor: '#f8f9fa',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 16,
    color: '#2c3e50',
    borderWidth: 1,
    borderColor: '#e1e8ed',
    marginBottom: 8,
  },
  inputDisplay: {
    fontSize: 14,
    color: '#7f8c8d',
    marginTop: 4,
  },
  switchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  switchLabel: {
    fontSize: 16,
    color: '#2c3e50',
  },
  userDisplay: {
    fontSize: 14,
    color: '#2c3e50',
    marginTop: 8,
    fontStyle: 'italic',
  },
  todoInputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  todoInput: {
    flex: 1,
    marginRight: 8,
    marginBottom: 0,
  },
  todoFilterButton: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    backgroundColor: '#3498db',
    borderRadius: 6,
  },
  todoFilterText: {
    color: '#ffffff',
    fontSize: 12,
    fontWeight: '600',
  },
  todoList: {
    marginTop: 8,
  },
  todoItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  todoText: {
    fontSize: 14,
    color: '#2c3e50',
    flex: 1,
  },
  todoDelete: {
    fontSize: 18,
    color: '#e74c3c',
    paddingHorizontal: 8,
  },
  todoEmpty: {
    fontSize: 14,
    color: '#95a5a6',
    textAlign: 'center',
    paddingVertical: 16,
  },
  computationResult: {
    fontSize: 16,
    color: '#2c3e50',
    fontWeight: '500',
  },
  computationNote: {
    fontSize: 12,
    color: '#95a5a6',
    marginTop: 4,
    fontStyle: 'italic',
  },
});
```

---

## Target 2: useEffect - Managing Side Effects

**The Target:** Master side effects in React Native components.

**The Concept:** `useEffect` handles operations that happen "outside" your component's render logic—API calls, subscriptions, timers, and DOM manipulations. In React Native, this includes device API calls, animations, and navigation events.

### Complete useEffect Guide

```typescript
// src/examples/EffectExamples.tsx
import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  ActivityIndicator,
  Platform,
} from 'react-native';

/**
 * EffectExamples - Demonstrates different useEffect patterns
 * 
 * This component shows common useEffect use cases in React Native,
 * including data fetching, subscriptions, and cleanup.
 */
export const EffectExamples: React.FC = () => {
  // 1. Basic effect - runs after every render
  const [renderCount, setRenderCount] = useState(0);
  
  useEffect(() => {
    console.log('Component rendered!');
    // This runs after every render
  });

  // 2. Effect with empty dependencies - runs once
  const [data, setData] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    console.log('Fetching data (once)...');
    // Simulate API call
    const timer = setTimeout(() => {
      setData('Data loaded!');
      setLoading(false);
    }, 2000);

    // Cleanup function
    return () => {
      console.log('Cleaning up data fetch...');
      clearTimeout(timer);
    };
  }, []); // Empty array = run once

  // 3. Effect with dependencies - runs when dependencies change
  const [count, setCount] = useState(0);
  const [message, setMessage] = useState('');

  useEffect(() => {
    setMessage(`Count changed to: ${count}`);
    console.log(`Count updated to: ${count}`);
  }, [count]); // Runs when `count` changes

  // 4. Effect with cleanup - subscriptions and event listeners
  const [isOnline, setIsOnline] = useState(true);
  
  useEffect(() => {
    console.log('Setting up online status listener...');
    
    // Simulate a subscription
    const interval = setInterval(() => {
      setIsOnline(Math.random() > 0.3);
    }, 3000);

    // Cleanup subscription
    return () => {
      console.log('Cleaning up online status listener...');
      clearInterval(interval);
    };
  }, []);

  // 5. Effect with refs - avoiding stale closures
  const intervalRef = useRef<NodeJS.Timeout | null>(null);
  const [timer, setTimer] = useState(0);

  useEffect(() => {
    // Start timer
    intervalRef.current = setInterval(() => {
      setTimer(prev => prev + 1);
    }, 1000);

    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, []);

  // 6. Effect for navigation events
  useEffect(() => {
    console.log('Screen focused!');
    
    // In a real app, you'd use navigation listeners here
    const unsubscribe = () => {
      console.log('Screen unfocused!');
    };

    return unsubscribe;
  }, []);

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.title}>useEffect Patterns</Text>

      {/* Loading State */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>1. Data Fetching</Text>
        {loading ? (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color="#3498db" />
            <Text style={styles.loadingText}>Loading data...</Text>
          </View>
        ) : (
          <Text style={styles.dataText}>{data}</Text>
        )}
      </View>

      {/* Dependency Tracking */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>2. Dependency Tracking</Text>
        <Text style={styles.messageText}>{message || 'No count yet'}</Text>
        <View style={styles.buttonRow}>
          <TouchableOpacity 
            style={styles.smallButton} 
            onPress={() => setCount(prev => prev + 1)}
          >
            <Text style={styles.smallButtonText}>Increment</Text>
          </TouchableOpacity>
          <TouchableOpacity 
            style={[styles.smallButton, { backgroundColor: '#e74c3c' }]} 
            onPress={() => setCount(0)}
          >
            <Text style={styles.smallButtonText}>Reset</Text>
          </TouchableOpacity>
        </View>
        <Text style={styles.countText}>Count: {count}</Text>
      </View>

      {/* Online Status */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>3. Subscription Example</Text>
        <View style={styles.statusContainer}>
          <View style={[
            styles.statusDot,
            { backgroundColor: isOnline ? '#2ecc71' : '#e74c3c' }
          ]} />
          <Text style={styles.statusText}>
            {isOnline ? 'Online' : 'Offline'}
          </Text>
        </View>
        <Text style={styles.statusNote}>
          Status updates every 3 seconds
        </Text>
      </View>

      {/* Timer */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>4. Timer with Cleanup</Text>
        <Text style={styles.timerText}>{timer}s</Text>
        <TouchableOpacity 
          style={[styles.smallButton, { backgroundColor: '#e74c3c' }]}
          onPress={() => {
            if (intervalRef.current) {
              clearInterval(intervalRef.current);
              setTimer(0);
            }
          }}
        >
          <Text style={styles.smallButtonText}>Reset Timer</Text>
        </TouchableOpacity>
      </View>

      {/* Lifecycle Notes */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>5. Lifecycle Notes</Text>
        <Text style={styles.noteText}>
          📱 Open the console to see lifecycle logs
        </Text>
        <Text style={styles.noteText}>
          🔄 Component mounts → useEffect runs → cleanup on unmount
        </Text>
        <TouchableOpacity 
          style={styles.forceUpdateButton}
          onPress={() => setRenderCount(prev => prev + 1)}
        >
          <Text style={styles.forceUpdateText}>
            Force Re-render ({renderCount})
          </Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  content: {
    padding: 16,
    paddingBottom: 40,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 24,
    textAlign: 'center',
  },
  section: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
      },
      android: {
        elevation: 2,
      },
    }),
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 12,
  },
  loadingContainer: {
    alignItems: 'center',
    paddingVertical: 20,
  },
  loadingText: {
    fontSize: 14,
    color: '#7f8c8d',
    marginTop: 8,
  },
  dataText: {
    fontSize: 16,
    color: '#2c3e50',
    textAlign: 'center',
    paddingVertical: 16,
  },
  messageText: {
    fontSize: 14,
    color: '#34495e',
    marginBottom: 12,
    fontStyle: 'italic',
  },
  buttonRow: {
    flexDirection: 'row',
    gap: 8,
  },
  smallButton: {
    backgroundColor: '#3498db',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 6,
    flex: 1,
  },
  smallButtonText: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '500',
    textAlign: 'center',
  },
  countText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginTop: 8,
  },
  statusContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statusDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: 8,
  },
  statusText: {
    fontSize: 16,
    fontWeight: '500',
    color: '#2c3e50',
  },
  statusNote: {
    fontSize: 12,
    color: '#95a5a6',
    marginTop: 4,
  },
  timerText: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#2c3e50',
    textAlign: 'center',
    marginBottom: 12,
  },
  noteText: {
    fontSize: 14,
    color: '#7f8c8d',
    marginBottom: 4,
  },
  forceUpdateButton: {
    backgroundColor: '#f1f2f6',
    paddingVertical: 10,
    borderRadius: 6,
    marginTop: 8,
  },
  forceUpdateText: {
    fontSize: 14,
    color: '#34495e',
    textAlign: 'center',
  },
});
```

---

## Target 3: useMemo and useCallback - Performance Optimization

**The Target:** Optimize component performance with memoization.

**The Concept:** memoization is like caching—you store the result of expensive operations so you don't have to recompute them every time your component renders. This is crucial for mobile apps where performance is paramount.

### Performance Optimization Guide

```typescript
// src/examples/MemoizationExamples.tsx
import React, { useState, useMemo, useCallback, memo } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Platform,
} from 'react-native';

/**
 * Child Component - Demonstrates memo usage
 */
interface ChildProps {
  name: string;
  onPress: () => void;
}

const ChildComponent = memo(({ name, onPress }: ChildProps) => {
  console.log(`Child ${name} rendered!`);
  
  return (
    <TouchableOpacity style={styles.childContainer} onPress={onPress}>
      <Text style={styles.childText}>{name}</Text>
    </TouchableOpacity>
  );
});

/**
 * MemoizationExamples - Demonstrates memoization patterns
 * 
 * This component shows how useMemo, useCallback, and memo
 * can optimize React Native performance.
 */
export const MemoizationExamples: React.FC = () => {
  const [count, setCount] = useState(0);
  const [items, setItems] = useState(['Apple', 'Banana', 'Orange']);
  const [selectedItem, setSelectedItem] = useState<string | null>(null);

  // 1. useMemo - Memoize expensive calculations
  const expensiveCalculation = useMemo(() => {
    console.log('⚡ Running expensive calculation...');
    // Simulate a heavy operation
    let sum = 0;
    for (let i = 0; i < 1000000; i++) {
      sum += i;
    }
    return sum;
  }, []); // Empty dependency = calculate once

  // 2. useMemo - Memoize filtered data
  const filteredItems = useMemo(() => {
    console.log('🔄 Filtering items...');
    return items.filter(item => 
      item.toLowerCase().includes('a') || 
      item.toLowerCase().includes('e')
    );
  }, [items]); // Recalculate when items change

  // 3. useCallback - Memoize functions
  const handleItemPress = useCallback((item: string) => {
    console.log(`📱 Item pressed: ${item}`);
    setSelectedItem(item);
  }, []);

  const handleAddItem = useCallback(() => {
    console.log('➕ Adding new item...');
    const newItem = `Item ${items.length + 1}`;
    setItems(prev => [...prev, newItem]);
  }, [items.length]);

  // 4. useCallback with dependencies
  const handleIncrement = useCallback(() => {
    setCount(prev => prev + 1);
  }, []);

  // Component rendered count (for demonstration)
  const renderCount = useMemo(() => {
    return 'Rendered';
  }, []);

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.title}>Memoization & Performance</Text>

      {/* Render Counter */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Component Renders</Text>
        <Text style={styles.renderText}>
          This component has rendered {count > 0 ? count + 1 : 1} times
        </Text>
        <TouchableOpacity style={styles.button} onPress={handleIncrement}>
          <Text style={styles.buttonText}>Force Re-render</Text>
        </TouchableOpacity>
      </View>

      {/* useMemo Example */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>1. useMemo - Expensive Calc</Text>
        <Text style={styles.calculationText}>
          Sum: {expensiveCalculation}
        </Text>
        <Text style={styles.noteText}>
          ⚡ This calculation runs once and is cached
        </Text>
      </View>

      {/* useMemo - Filtered Data */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>2. useMemo - Filtered Data</Text>
        <View style={styles.itemContainer}>
          {filteredItems.map((item, index) => (
            <ChildComponent
              key={index}
              name={item}
              onPress={() => handleItemPress(item)}
            />
          ))}
        </View>
        <Text style={styles.noteText}>
          Showing items containing 'a' or 'e' ({filteredItems.length} items)
        </Text>
        <TouchableOpacity style={styles.button} onPress={handleAddItem}>
          <Text style={styles.buttonText}>Add New Item</Text>
        </TouchableOpacity>
      </View>

      {/* Selected Item */}
      {selectedItem && (
        <View style={[styles.section, styles.selectedSection]}>
          <Text style={styles.sectionTitle}>Selected Item</Text>
          <Text style={styles.selectedText}>{selectedItem}</Text>
        </View>
      )}

      {/* Performance Tips */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Performance Tips</Text>
        <View style={styles.tipContainer}>
          <Text style={styles.tipText}>✅ Use useMemo for expensive calculations</Text>
          <Text style={styles.tipText}>✅ Use useCallback for functions passed to children</Text>
          <Text style={styles.tipText}>✅ Wrap child components with memo</Text>
          <Text style={styles.tipText}>✅ Avoid unnecessary re-renders</Text>
          <Text style={styles.tipText}>✅ Check console for render logs</Text>
        </View>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  content: {
    padding: 16,
    paddingBottom: 40,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 24,
    textAlign: 'center',
  },
  section: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
      },
      android: {
        elevation: 2,
      },
    }),
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 12,
  },
  renderText: {
    fontSize: 16,
    color: '#2c3e50',
    textAlign: 'center',
    marginBottom: 12,
  },
  button: {
    backgroundColor: '#3498db',
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  calculationText: {
    fontSize: 16,
    color: '#2c3e50',
    textAlign: 'center',
    marginVertical: 8,
  },
  noteText: {
    fontSize: 12,
    color: '#95a5a6',
    fontStyle: 'italic',
    textAlign: 'center',
    marginTop: 4,
  },
  itemContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 12,
  },
  childContainer: {
    backgroundColor: '#f1f2f6',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#e1e8ed',
  },
  childText: {
    fontSize: 14,
    color: '#2c3e50',
  },
  selectedSection: {
    borderWidth: 2,
    borderColor: '#3498db',
  },
  selectedText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#3498db',
    textAlign: 'center',
  },
  tipContainer: {
    gap: 4,
  },
  tipText: {
    fontSize: 14,
    color: '#34495e',
    paddingVertical: 2,
  },
});
```

---

## Target 4: Custom Hooks - Reusable Logic

**The Target:** Create reusable custom hooks for common patterns.

**The Concept:** Custom hooks allow you to extract and share component logic across your app. Think of them as helper functions that can contain state and effects.

### Essential Custom Hooks

```typescript
// src/hooks/useDebounce.ts
import { useState, useEffect } from 'react';

/**
 * useDebounce - Debounce a value
 * 
 * Delays updating a value until after a specified delay,
 * useful for search inputs and expensive operations.
 * 
 * @param value - The value to debounce
 * @param delay - Delay in milliseconds
 * @returns The debounced value
 */
export function useDebounce<T>(value: T, delay: number = 500): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(timer);
    };
  }, [value, delay]);

  return debouncedValue;
}
```

```typescript
// src/hooks/useApi.ts
import { useState, useCallback } from 'react';

interface ApiState<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
}

type ApiFunction<T, P> = (params: P) => Promise<T>;

/**
 * useApi - Manage API calls with loading and error states
 * 
 * Wraps an API function with loading and error handling,
 * providing a consistent interface for data fetching.
 * 
 * @param apiFunction - The API function to call
 * @returns Object containing data, loading, error, and execute function
 */
export function useApi<T, P = void>(apiFunction: ApiFunction<T, P>) {
  const [state, setState] = useState<ApiState<T>>({
    data: null,
    loading: false,
    error: null,
  });

  const execute = useCallback(
    async (params: P): Promise<T> => {
      setState(prev => ({ ...prev, loading: true, error: null }));
      
      try {
        const result = await apiFunction(params);
        setState({ data: result, loading: false, error: null });
        return result;
      } catch (error) {
        const err = error instanceof Error ? error : new Error('An error occurred');
        setState({ data: null, loading: false, error: err });
        throw err;
      }
    },
    [apiFunction]
  );

  return { ...state, execute };
}
```

```typescript
// src/hooks/useAsyncStorage.ts
import { useState, useEffect, useCallback } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * useAsyncStorage - Manage AsyncStorage with React state
 * 
 * Provides a React-friendly interface for AsyncStorage,
 * handling loading states and error handling.
 * 
 * @param key - Storage key
 * @param initialValue - Initial value if not found
 * @returns Object containing value, loading, error, and setValue
 */
export function useAsyncStorage<T>(
  key: string,
  initialValue: T
): {
  value: T;
  loading: boolean;
  error: Error | null;
  setValue: (value: T) => Promise<void>;
  refresh: () => Promise<void>;
} {
  const [value, setValue] = useState<T>(initialValue);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  // Load value from storage
  const loadValue = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const storedValue = await AsyncStorage.getItem(key);
      if (storedValue !== null) {
        setValue(JSON.parse(storedValue));
      } else {
        setValue(initialValue);
      }
    } catch (error) {
      setError(error as Error);
      console.error(`Error loading ${key}:`, error);
    } finally {
      setLoading(false);
    }
  }, [key, initialValue]);

  // Save value to storage
  const saveValue = useCallback(
    async (newValue: T) => {
      try {
        setError(null);
        await AsyncStorage.setItem(key, JSON.stringify(newValue));
        setValue(newValue);
      } catch (error) {
        setError(error as Error);
        console.error(`Error saving ${key}:`, error);
        throw error;
      }
    },
    [key]
  );

  // Load on mount
  useEffect(() => {
    loadValue();
  }, [loadValue]);

  return { value, loading, error, setValue: saveValue, refresh: loadValue };
}
```

```typescript
// src/hooks/useKeyboard.ts
import { useState, useEffect } from 'react';
import { Keyboard, KeyboardEvent, Platform } from 'react-native';

/**
 * useKeyboard - Track keyboard visibility and height
 * 
 * Handles keyboard events for responsive layouts,
 * especially useful for forms and chat interfaces.
 * 
 * @returns Object containing keyboard visible state and height
 */
export function useKeyboard() {
  const [keyboardVisible, setKeyboardVisible] = useState(false);
  const [keyboardHeight, setKeyboardHeight] = useState(0);

  useEffect(() => {
    const showListener = Keyboard.addListener(
      Platform.OS === 'ios' ? 'keyboardWillShow' : 'keyboardDidShow',
      (e: KeyboardEvent) => {
        setKeyboardVisible(true);
        setKeyboardHeight(e.endCoordinates.height);
      }
    );

    const hideListener = Keyboard.addListener(
      Platform.OS === 'ios' ? 'keyboardWillHide' : 'keyboardDidHide',
      () => {
        setKeyboardVisible(false);
        setKeyboardHeight(0);
      }
    );

    return () => {
      showListener.remove();
      hideListener.remove();
    };
  }, []);

  return { keyboardVisible, keyboardHeight };
}
```

### Using Custom Hooks in a Component

```typescript
// src/examples/CustomHooksDemo.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  ActivityIndicator,
  Platform,
} from 'react-native';
import { useDebounce } from '../hooks/useDebounce';
import { useApi } from '../hooks/useApi';
import { useAsyncStorage } from '../hooks/useAsyncStorage';
import { useKeyboard } from '../hooks/useKeyboard';

// Mock API function
const mockApiSearch = async (query: string): Promise<string[]> => {
  // Simulate API delay
  await new Promise(resolve => setTimeout(resolve, 500));
  
  const mockData = [
    'React Native',
    'JavaScript',
    'TypeScript',
    'Expo',
    'React Navigation',
    'Redux',
    'MobX',
    'Zustand',
    'Tailwind CSS',
    'Firebase',
  ];
  
  if (!query.trim()) return [];
  return mockData.filter(item => 
    item.toLowerCase().includes(query.toLowerCase())
  );
};

export const CustomHooksDemo: React.FC = () => {
  const [searchText, setSearchText] = useState('');
  const [results, setResults] = useState<string[]>([]);
  const keyboard = useKeyboard();

  // Use custom hooks
  const debouncedSearch = useDebounce(searchText, 500);
  const { data, loading, error, execute } = useApi(mockApiSearch);

  // Use AsyncStorage for settings
  const { 
    value: darkMode, 
    setValue: setDarkMode,
    loading: settingsLoading 
  } = useAsyncStorage('darkMode', false);

  // Search effect
  React.useEffect(() => {
    const performSearch = async () => {
      if (debouncedSearch.trim()) {
        try {
          const results = await execute(debouncedSearch);
          setResults(results || []);
        } catch (error) {
          console.error('Search error:', error);
        }
      } else {
        setResults([]);
      }
    };

    performSearch();
  }, [debouncedSearch, execute]);

  return (
    <View style={[
      styles.container,
      { paddingBottom: keyboard.keyboardVisible ? keyboard.keyboardHeight : 0 }
    ]}>
      <ScrollView 
        style={styles.scrollView}
        contentContainerStyle={styles.content}
      >
        <Text style={styles.title}>Custom Hooks Demo</Text>

        {/* AsyncStorage Hook */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>1. useAsyncStorage</Text>
          {settingsLoading ? (
            <ActivityIndicator size="small" color="#3498db" />
          ) : (
            <TouchableOpacity 
              style={styles.darkModeButton}
              onPress={() => setDarkMode(!darkMode)}
            >
              <Text style={styles.darkModeText}>
                {darkMode ? '🌙 Dark Mode' : '☀️ Light Mode'}
              </Text>
            </TouchableOpacity>
          )}
        </View>

        {/* useDebounce + useApi */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>2. useDebounce + useApi</Text>
          <TextInput
            style={styles.searchInput}
            placeholder="Search..."
            value={searchText}
            onChangeText={setSearchText}
            placeholderTextColor="#95a5a6"
          />
          
          {loading && (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="small" color="#3498db" />
              <Text style={styles.loadingText}>Searching...</Text>
            </View>
          )}

          {error && (
            <Text style={styles.errorText}>Error: {error.message}</Text>
          )}

          {!loading && results.length > 0 && (
            <View style={styles.resultsContainer}>
              {results.map((item, index) => (
                <View key={index} style={styles.resultItem}>
                  <Text style={styles.resultText}>{item}</Text>
                </View>
              ))}
            </View>
          )}

          {!loading && debouncedSearch && results.length === 0 && (
            <Text style={styles.noResults}>No results found</Text>
          )}
        </View>

        {/* useKeyboard */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>3. useKeyboard</Text>
          <View style={styles.keyboardInfo}>
            <Text style={styles.keyboardText}>
              Keyboard Visible: {keyboard.keyboardVisible ? '✅' : '❌'}
            </Text>
            <Text style={styles.keyboardText}>
              Keyboard Height: {keyboard.keyboardHeight}px
            </Text>
          </View>
          <Text style={styles.keyboardNote}>
            Open the keyboard to see the effect
          </Text>
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  scrollView: {
    flex: 1,
  },
  content: {
    padding: 16,
    paddingBottom: 40,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 24,
    textAlign: 'center',
  },
  section: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
      },
      android: {
        elevation: 2,
      },
    }),
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 12,
  },
  darkModeButton: {
    backgroundColor: '#f1f2f6',
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  darkModeText: {
    fontSize: 16,
    color: '#2c3e50',
    fontWeight: '500',
  },
  searchInput: {
    backgroundColor: '#f8f9fa',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 16,
    color: '#2c3e50',
    borderWidth: 1,
    borderColor: '#e1e8ed',
  },
  loadingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
  },
  loadingText: {
    fontSize: 14,
    color: '#7f8c8d',
    marginLeft: 8,
  },
  errorText: {
    fontSize: 14,
    color: '#e74c3c',
    textAlign: 'center',
    paddingVertical: 8,
  },
  resultsContainer: {
    marginTop: 8,
  },
  resultItem: {
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  resultText: {
    fontSize: 14,
    color: '#2c3e50',
  },
  noResults: {
    fontSize: 14,
    color: '#95a5a6',
    textAlign: 'center',
    paddingVertical: 12,
  },
  keyboardInfo: {
    gap: 4,
  },
  keyboardText: {
    fontSize: 14,
    color: '#2c3e50',
  },
  keyboardNote: {
    fontSize: 12,
    color: '#95a5a6',
    marginTop: 8,
    fontStyle: 'italic',
  },
});
```

---

## Target 5: Building TaskForm with Local State

**The Target:** Build a real-world form component with complete state management.

**The Concept:** Forms are one of the most common uses of local state. Here we'll build a complete task creation form with validation and error handling.

### Task Form Component

```typescript
// src/components/TaskForm.tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Switch,
  Platform,
  Alert,
} from 'react-native';
import { DateTimePicker } from '@react-native-community/datetimepicker';

interface TaskFormData {
  title: string;
  description: string;
  priority: 'low' | 'medium' | 'high';
  dueDate: Date;
  hasReminder: boolean;
  category: string;
  assignee: string;
}

interface TaskFormProps {
  initialData?: Partial<TaskFormData>;
  onSubmit: (data: TaskFormData) => void;
  isLoading?: boolean;
}

/**
 * TaskForm - Complete task creation/editing form
 * 
 * This component demonstrates real-world form state management
 * with validation, error handling, and user feedback.
 */
export const TaskForm: React.FC<TaskFormProps> = ({
  initialData,
  onSubmit,
  isLoading = false,
}) => {
  // Initialize form state
  const [formData, setFormData] = useState<TaskFormData>({
    title: initialData?.title || '',
    description: initialData?.description || '',
    priority: initialData?.priority || 'medium',
    dueDate: initialData?.dueDate || new Date(),
    hasReminder: initialData?.hasReminder || false,
    category: initialData?.category || '',
    assignee: initialData?.assignee || '',
  });

  const [errors, setErrors] = useState<Partial<Record<keyof TaskFormData, string>>>({});
  const [touched, setTouched] = useState<Partial<Record<keyof TaskFormData, boolean>>>({});
  const [showDatePicker, setShowDatePicker] = useState(false);

  // Validation function
  const validate = (data: TaskFormData): Partial<Record<keyof TaskFormData, string>> => {
    const newErrors: Partial<Record<keyof TaskFormData, string>> = {};

    if (!data.title.trim()) {
      newErrors.title = 'Title is required';
    } else if (data.title.length < 3) {
      newErrors.title = 'Title must be at least 3 characters';
    }

    if (data.dueDate < new Date()) {
      newErrors.dueDate = 'Due date cannot be in the past';
    }

    if (!data.category.trim()) {
      newErrors.category = 'Category is required';
    }

    return newErrors;
  };

  // Update form field
  const updateField = <K extends keyof TaskFormData>(field: K, value: TaskFormData[K]) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    setTouched(prev => ({ ...prev, [field]: true }));
    
    // Clear error when field is updated
    if (errors[field]) {
      setErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[field];
        return newErrors;
      });
    }
  };

  // Handle field blur
  const handleBlur = (field: keyof TaskFormData) => {
    setTouched(prev => ({ ...prev, [field]: true }));
    const validationErrors = validate(formData);
    setErrors(prev => ({ ...prev, ...validationErrors }));
  };

  // Handle form submission
  const handleSubmit = () => {
    const validationErrors = validate(formData);
    setErrors(validationErrors);
    
    // Mark all fields as touched
    const allTouched: Partial<Record<keyof TaskFormData, boolean>> = {};
    Object.keys(formData).forEach(key => {
      allTouched[key as keyof TaskFormData] = true;
    });
    setTouched(allTouched);

    if (Object.keys(validationErrors).length === 0) {
      onSubmit(formData);
    } else {
      Alert.alert(
        'Validation Error',
        'Please fix the highlighted fields before submitting.',
        [{ text: 'OK', style: 'default' }]
      );
    }
  };

  // Priority selection
  const PriorityButton = ({ 
    level, 
    label, 
    color 
  }: { 
    level: 'low' | 'medium' | 'high'; 
    label: string; 
    color: string;
  }) => (
    <TouchableOpacity
      style={[
        styles.priorityButton,
        formData.priority === level && styles.priorityButtonActive,
        { borderColor: color, backgroundColor: formData.priority === level ? color : 'transparent' },
      ]}
      onPress={() => updateField('priority', level)}
    >
      <Text
        style={[
          styles.priorityButtonText,
          formData.priority === level && styles.priorityButtonTextActive,
          { color: formData.priority === level ? '#ffffff' : color },
        ]}
      >
        {label}
      </Text>
    </TouchableOpacity>
  );

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      {/* Title */}
      <View style={styles.fieldContainer}>
        <Text style={styles.label}>
          Title <Text style={styles.required}>*</Text>
        </Text>
        <TextInput
          style={[
            styles.input,
            errors.title && touched.title && styles.inputError,
          ]}
          placeholder="Enter task title"
          value={formData.title}
          onChangeText={(value) => updateField('title', value)}
          onBlur={() => handleBlur('title')}
          placeholderTextColor="#95a5a6"
        />
        {errors.title && touched.title && (
          <Text style={styles.errorText}>{errors.title}</Text>
        )}
      </View>

      {/* Description */}
      <View style={styles.fieldContainer}>
        <Text style={styles.label}>Description</Text>
        <TextInput
          style={[styles.input, styles.textArea]}
          placeholder="Enter task description"
          value={formData.description}
          onChangeText={(value) => updateField('description', value)}
          onBlur={() => handleBlur('description')}
          multiline
          numberOfLines={4}
          textAlignVertical="top"
          placeholderTextColor="#95a5a6"
        />
      </View>

      {/* Priority */}
      <View style={styles.fieldContainer}>
        <Text style={styles.label}>Priority</Text>
        <View style={styles.priorityContainer}>
          <PriorityButton level="low" label="Low" color="#2ecc71" />
          <PriorityButton level="medium" label="Medium" color="#f39c12" />
          <PriorityButton level="high" label="High" color="#e74c3c" />
        </View>
      </View>

      {/* Due Date */}
      <View style={styles.fieldContainer}>
        <Text style={styles.label}>
          Due Date <Text style={styles.required}>*</Text>
        </Text>
        <TouchableOpacity
          style={[
            styles.dateButton,
            errors.dueDate && touched.dueDate && styles.inputError,
          ]}
          onPress={() => setShowDatePicker(true)}
        >
          <Text style={styles.dateButtonText}>
            {formData.dueDate.toLocaleDateString('en-US', {
              weekday: 'short',
              year: 'numeric',
              month: 'short',
              day: 'numeric',
            })}
          </Text>
        </TouchableOpacity>
        {errors.dueDate && touched.dueDate && (
          <Text style={styles.errorText}>{errors.dueDate}</Text>
        )}
        {showDatePicker && (
          <DateTimePicker
            value={formData.dueDate}
            mode="date"
            display={Platform.OS === 'ios' ? 'spinner' : 'default'}
            onChange={(event, selectedDate) => {
              setShowDatePicker(false);
              if (selectedDate) {
                updateField('dueDate', selectedDate);
              }
            }}
            minimumDate={new Date()}
          />
        )}
      </View>

      {/* Reminder */}
      <View style={styles.fieldContainer}>
        <View style={styles.switchContainer}>
          <Text style={styles.label}>Set Reminder</Text>
          <Switch
            trackColor={{ false: '#e1e8ed', true: '#3498db' }}
            thumbColor={Platform.OS === 'ios' ? '#ffffff' : '#3498db'}
            onValueChange={(value) => updateField('hasReminder', value)}
            value={formData.hasReminder}
          />
        </View>
      </View>

      {/* Category */}
      <View style={styles.fieldContainer}>
        <Text style={styles.label}>
          Category <Text style={styles.required}>*</Text>
        </Text>
        <TextInput
          style={[
            styles.input,
            errors.category && touched.category && styles.inputError,
          ]}
          placeholder="Enter category"
          value={formData.category}
          onChangeText={(value) => updateField('category', value)}
          onBlur={() => handleBlur('category')}
          placeholderTextColor="#95a5a6"
        />
        {errors.category && touched.category && (
          <Text style={styles.errorText}>{errors.category}</Text>
        )}
      </View>

      {/* Assignee */}
      <View style={styles.fieldContainer}>
        <Text style={styles.label}>Assignee</Text>
        <TextInput
          style={styles.input}
          placeholder="Enter assignee name"
          value={formData.assignee}
          onChangeText={(value) => updateField('assignee', value)}
          onBlur={() => handleBlur('assignee')}
          placeholderTextColor="#95a5a6"
        />
      </View>

      {/* Submit Button */}
      <TouchableOpacity
        style={[styles.submitButton, isLoading && styles.submitButtonDisabled]}
        onPress={handleSubmit}
        disabled={isLoading}
      >
        <Text style={styles.submitButtonText}>
          {isLoading ? 'Saving...' : 'Save Task'}
        </Text>
      </TouchableOpacity>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  content: {
    padding: 16,
    paddingBottom: 40,
  },
  fieldContainer: {
    marginBottom: 20,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: '#2c3e50',
    marginBottom: 6,
  },
  required: {
    color: '#e74c3c',
  },
  input: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 16,
    color: '#2c3e50',
    borderWidth: 1,
    borderColor: '#e1e8ed',
  },
  inputError: {
    borderColor: '#e74c3c',
    borderWidth: 2,
  },
  textArea: {
    minHeight: 100,
    paddingTop: 10,
  },
  errorText: {
    fontSize: 12,
    color: '#e74c3c',
    marginTop: 4,
  },
  priorityContainer: {
    flexDirection: 'row',
    gap: 8,
  },
  priorityButton: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 8,
    borderWidth: 2,
    alignItems: 'center',
  },
  priorityButtonActive: {
    borderWidth: 2,
  },
  priorityButtonText: {
    fontSize: 14,
    fontWeight: '500',
  },
  priorityButtonTextActive: {
    color: '#ffffff',
  },
  dateButton: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderWidth: 1,
    borderColor: '#e1e8ed',
  },
  dateButtonText: {
    fontSize: 16,
    color: '#2c3e50',
  },
  switchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  submitButton: {
    backgroundColor: '#3498db',
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: 8,
  },
  submitButtonDisabled: {
    opacity: 0.7,
  },
  submitButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
});
```

---

## Verification: Test Local State Management

```bash
# Run the app to test all state management examples
cd ~/projects/TaskFlow
expo start

# Navigate to the examples screens
```

### Verification Checklist

1. **State Fundamentals:**
   - [ ] Counter increments/decrements correctly
   - [ ] Text input updates display
   - [ ] Switch toggles state
   - [ ] Object state updates properly
   - [ ] Todo list add/remove works
   - [ ] Expensive computation only runs once

2. **useEffect Patterns:**
   - [ ] Data loads on mount
   - [ ] Component logs render count
   - [ ] Status updates every 3 seconds
   - [ ] Timer counts up
   - [ ] Cleanup works on unmount

3. **Memoization:**
   - [ ] Expensive calculation caches
   - [ ] Filtered items update on list change
   - [ ] Child components don't rerender unnecessarily
   - [ ] Console logs show render behavior

4. **Custom Hooks:**
   - [ ] Search debounces input
   - [ ] API call shows loading state
   - [ ] AsyncStorage persists dark mode setting
   - [ ] Keyboard height updates

5. **TaskForm:**
   - [ ] All fields update correctly
   - [ ] Validation works (title, due date, category)
   - [ ] Errors show when fields are invalid
   - [ ] Form submits with valid data
   - [ ] Date picker works on both platforms

### Debugging Tips

```typescript
// Add this to debug state changes
useEffect(() => {
  console.log('State changed:', { 
    count, 
    text, 
    isEnabled, 
    user,
    todos: todoState.todos.length 
  });
}, [count, text, isEnabled, user, todoState.todos]);

// Add this to debug hook performance
console.count('🔴 Component rendered');
```

---

## What We've Accomplished

Congratulations! You've mastered local state management in React Native. Here's what you've learned:

1. **State Fundamentals:** useState, useReducer, and state patterns
2. **Side Effects:** useEffect for API calls, subscriptions, and cleanup
3. **Performance:** useMemo, useCallback, and memo for optimization
4. **Custom Hooks:** Reusable state logic for debouncing, API calls, and storage
5. **Form Management:** Complete form with validation and error handling

### What's Next: Part 2, Phase 2 - Global State Management

In the next phase, we'll scale our state management with:
- **Zustand:** Simple and scalable state management
- **Store Patterns:** Organizing stores for large applications
- **Middleware:** Persistence, logging, and devtools
- **Complex State:** Handling async actions and side effects

*Your local state foundation is solid! Now it's time to scale up to global state management. We'll use Zustand to manage application-wide state like user authentication, theme settings, and task data across screens. Get ready to build a truly stateful app!*

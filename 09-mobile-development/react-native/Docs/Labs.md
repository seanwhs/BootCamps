# React Native: From Blueprint to Production
## Complete Lab Book

---

# STUDENT LAB BOOK

## Mobile Development with React Native: From Blueprint to Production

---

**Student Name:** _______________________

**Course Dates:** _______________________

**Instructor:** _______________________

---

## How to Use This Lab Book

This lab book contains all the hands-on exercises for the "Mobile Development with React Native: From Blueprint to Production" course. Each lab includes:

- **Lab Objectives:** What you will learn
- **Prerequisites:** What you need before starting
- **Step-by-Step Instructions:** Detailed guidance
- **Code Snippets:** Complete, copy-pasteable code
- **Checkpoints:** Verify your progress
- **Challenge Tasks:** Extend your learning
- **Reflection Questions:** Think about what you learned

**Lab Completion Checklist:**

```
☐ Part 1: Foundations & Environment (4 labs)
☐ Part 2: State Management & Persistence (3 labs)
☐ Part 3: Device Capabilities & Native Features (3 labs)
☐ Part 4: Testing, Performance & Deployment (3 labs)
☐ Final Project: Complete TaskFlow Application
```

---

# PART 1: FOUNDATIONS & ENVIRONMENT ARCHITECTURE

---

## Lab 1.1: Environment Setup & "Hello, TaskFlow!"

### Lab Objectives
- Set up development environment (Node.js, Expo CLI, Xcode/Android Studio)
- Create your first Expo project
- Understand the project structure
- Modify App.tsx
- Run on simulators and physical devices

### Prerequisites
- Computer with macOS (for iOS) or Windows/Linux (for Android)
- Node.js 18+ installed
- Git installed
- Code editor (VSCode recommended)

---

### Step 1: Verify Prerequisites

**Check Node.js:**
```bash
node --version
# Should show v18.x.x or higher
```

**Check npm:**
```bash
npm --version
# Should show 9.x.x or higher
```

**Check Git:**
```bash
git --version
# Should show 2.x.x or higher
```

**Record your versions:**
- Node.js: _______________
- npm: _______________
- Git: _______________

---

### Step 2: Install Expo CLI

```bash
npm install -g expo-cli
```

**Verify:**
```bash
expo --version
# Should show 6.x.x or higher
```

**Your version:** _______________

---

### Step 3: Create the TaskFlow Project

```bash
# Create new Expo project with TypeScript
npx create-expo-app TaskFlow --template

# Navigate to project
cd TaskFlow

# Start development server
npm start
```

**Project Creation Notes:**
- Template selected: _______________
- Project location: _______________
- Time to create: _______________

---

### Step 4: Explore the Project Structure

```
TaskFlow/
├── .expo/                 # Expo configuration
├── .gitignore             # Git ignore file
├── App.tsx                # Main app component
├── app.json               # App configuration
├── assets/                # Images, fonts
├── babel.config.js        # Babel config
├── package.json           # Dependencies
├── tsconfig.json          # TypeScript config
└── node_modules/          # Installed packages
```

**List 3 things you notice about the project structure:**
1. _________________________________________________________
2. _________________________________________________________
3. _________________________________________________________

---

### Step 5: Modify App.tsx

**Replace the content of `App.tsx` with:**

```tsx
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View, SafeAreaView, Platform } from 'react-native';

export default function App() {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <Text style={styles.title}>Welcome to TaskFlow</Text>
        <Text style={styles.subtitle}>Your Productivity Companion</Text>
        <View style={styles.card}>
          <Text style={styles.cardText}>
            🚀 Environment successfully configured!
          </Text>
          <Text style={styles.cardSubtext}>
            Development ready for iOS and Android
          </Text>
        </View>
        <StatusBar style={Platform.OS === 'ios' ? 'dark' : 'auto'} />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 18,
    color: '#7f8c8d',
    marginBottom: 40,
  },
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 24,
    width: '100%',
    maxWidth: 400,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    alignItems: 'center',
  },
  cardText: {
    fontSize: 16,
    color: '#2c3e50',
    marginBottom: 8,
    fontWeight: '600',
  },
  cardSubtext: {
    fontSize: 14,
    color: '#95a5a6',
  },
});
```

**Observe the changes in your simulator/device:**
_________________________________________________________

---

### Step 6: Running on Different Platforms

**iOS Simulator:**
```bash
# Press 'i' in terminal or run:
npm run ios
```

**Android Emulator:**
```bash
# Press 'a' in terminal or run:
npm run android
```

**Physical Device:**
1. Install Expo Go app on your device
2. Scan QR code from terminal
3. App loads on device

**Platforms you ran on:**
- [ ] iOS Simulator
- [ ] Android Emulator
- [ ] Physical Device (iOS)
- [ ] Physical Device (Android)

---

### Step 7: Experiment with Fast Refresh

**Make a change to App.tsx:**
```tsx
// Change the subtitle text
<Text style={styles.subtitle}>Your Productivity Companion - v1.0</Text>
```

**What happened when you saved the file?**
_________________________________________________________

**Fast Refresh Indicator Color:**
- 🟢 Green: _______________
- 🔴 Red: _______________

---

### Step 8: Explore DevTools

**Open React DevTools:**
```bash
# In Expo, press 'd' in terminal
# Or use Chrome DevTools
```

**What tabs do you see in DevTools?**
1. _________________________________________________________
2. _________________________________________________________
3. _________________________________________________________

---

### Checkpoint: Verify Your Setup

- [ ] Node.js 18+ installed
- [ ] Expo CLI installed
- [ ] Project created successfully
- [ ] App runs on iOS Simulator (if macOS)
- [ ] App runs on Android Emulator
- [ ] App runs on physical device
- [ ] Fast Refresh works
- [ ] DevTools accessible

---

### Challenge Tasks

1. **Customize the Card:**
   - Add a new text element showing the current date
   - Change the card background color
   - Add a border to the card

2. **Add a Button:**
   - Add a TouchableOpacity below the card
   - Show an alert when pressed: `Alert.alert('Button Pressed!')`

3. **Platform-Specific Message:**
   - Show "Running on iOS" for iOS devices
   - Show "Running on Android" for Android devices

---

### Reflection Questions

1. What was the most challenging part of setting up the environment?
   ___________________________________________________________________
   ___________________________________________________________________

2. How does Fast Refresh improve the development experience?
   ___________________________________________________________________
   ___________________________________________________________________

3. What are the differences between running on a simulator vs a physical device?
   ___________________________________________________________________
   ___________________________________________________________________

---

## Lab 1.2: Core Components & TaskForm

### Lab Objectives
- Build a reusable TaskForm component
- Implement various input types (text, priority selector)
- Handle form state locally with useState
- Style for both iOS and Android

### Prerequisites
- Lab 1.1 completed
- Understanding of React components
- Basic TypeScript knowledge

---

### Step 1: Create the Components Directory

```bash
# Create components directory
mkdir src/components
```

---

### Step 2: Build the TaskForm Component

**Create `src/components/TaskForm.tsx`:**

```tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  Switch,
  StyleSheet,
  Platform,
} from 'react-native';

export interface TaskFormData {
  title: string;
  description: string;
  priority: 'low' | 'medium' | 'high';
  hasReminder: boolean;
}

interface TaskFormProps {
  onSubmit: (data: TaskFormData) => void;
  initialData?: Partial<TaskFormData>;
}

export const TaskForm: React.FC<TaskFormProps> = ({
  onSubmit,
  initialData = {},
}) => {
  const [title, setTitle] = useState(initialData.title || '');
  const [description, setDescription] = useState(initialData.description || '');
  const [priority, setPriority] = useState<'low' | 'medium' | 'high'>(
    initialData.priority || 'medium'
  );
  const [hasReminder, setHasReminder] = useState(initialData.hasReminder || false);

  const handleSubmit = () => {
    if (!title.trim()) {
      // Show error (we'll add validation later)
      return;
    }
    onSubmit({ title, description, priority, hasReminder });
    // Reset form
    setTitle('');
    setDescription('');
    setPriority('medium');
    setHasReminder(false);
  };

  const getPriorityColor = (p: string) => {
    switch (p) {
      case 'high': return '#e74c3c';
      case 'medium': return '#f39c12';
      case 'low': return '#2ecc71';
      default: return '#95a5a6';
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Create New Task</Text>

      {/* Title Input */}
      <View style={styles.fieldContainer}>
        <Text style={styles.label}>Title *</Text>
        <TextInput
          style={[styles.input, !title.trim() && styles.inputError]}
          placeholder="Enter task title..."
          value={title}
          onChangeText={setTitle}
          placeholderTextColor="#95a5a6"
        />
      </View>

      {/* Description Input */}
      <View style={styles.fieldContainer}>
        <Text style={styles.label}>Description</Text>
        <TextInput
          style={[styles.input, styles.textArea]}
          placeholder="Enter task description..."
          value={description}
          onChangeText={setDescription}
          multiline
          numberOfLines={4}
          textAlignVertical="top"
          placeholderTextColor="#95a5a6"
        />
      </View>

      {/* Priority Selector */}
      <View style={styles.fieldContainer}>
        <Text style={styles.label}>Priority</Text>
        <View style={styles.priorityContainer}>
          {(['low', 'medium', 'high'] as const).map((p) => (
            <TouchableOpacity
              key={p}
              style={[
                styles.priorityButton,
                priority === p && styles.priorityButtonActive,
                { borderColor: getPriorityColor(p) },
              ]}
              onPress={() => setPriority(p)}
            >
              <Text
                style={[
                  styles.priorityText,
                  priority === p && styles.priorityTextActive,
                  { color: priority === p ? '#fff' : getPriorityColor(p) },
                ]}
              >
                {p.charAt(0).toUpperCase() + p.slice(1)}
              </Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      {/* Reminder Switch */}
      <View style={styles.switchContainer}>
        <Text style={styles.label}>Set Reminder</Text>
        <Switch
          trackColor={{ false: '#e1e8ed', true: '#3498db' }}
          thumbColor={Platform.OS === 'ios' ? '#fff' : '#3498db'}
          onValueChange={setHasReminder}
          value={hasReminder}
        />
      </View>

      {/* Submit Button */}
      <TouchableOpacity
        style={[styles.submitButton, !title.trim() && styles.submitButtonDisabled]}
        onPress={handleSubmit}
        disabled={!title.trim()}
      >
        <Text style={styles.submitButtonText}>Create Task</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginVertical: 8,
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
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 16,
  },
  fieldContainer: {
    marginBottom: 16,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: '#2c3e50',
    marginBottom: 6,
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
  },
  inputError: {
    borderColor: '#e74c3c',
    borderWidth: 2,
  },
  textArea: {
    minHeight: 100,
    paddingTop: 10,
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
    backgroundColor: '#3498db',
    borderColor: '#3498db',
  },
  priorityText: {
    fontSize: 14,
    fontWeight: '500',
  },
  priorityTextActive: {
    color: '#ffffff',
  },
  switchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 16,
    paddingVertical: 8,
  },
  submitButton: {
    backgroundColor: '#3498db',
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
  },
  submitButtonDisabled: {
    opacity: 0.5,
  },
  submitButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
});
```

---

### Step 3: Test the TaskForm in App.tsx

**Update `App.tsx` to include the TaskForm:**

```tsx
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View, SafeAreaView, ScrollView, Platform, Alert } from 'react-native';
import { TaskForm, TaskFormData } from './src/components/TaskForm';

export default function App() {
  const handleTaskSubmit = (data: TaskFormData) => {
    Alert.alert(
      'Task Created',
      `Title: ${data.title}\nPriority: ${data.priority}\nReminder: ${data.hasReminder ? 'On' : 'Off'}`
    );
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView contentContainerStyle={styles.container}>
        <Text style={styles.header}>TaskFlow</Text>
        <TaskForm onSubmit={handleTaskSubmit} />
        <Text style={styles.footer}>v1.0.0</Text>
      </ScrollView>
      <StatusBar style={Platform.OS === 'ios' ? 'dark' : 'auto'} />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  container: {
    padding: 16,
    paddingBottom: 40,
  },
  header: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2c3e50',
    textAlign: 'center',
    marginVertical: 16,
  },
  footer: {
    fontSize: 12,
    color: '#95a5a6',
    textAlign: 'center',
    marginTop: 16,
  },
});
```

---

### Step 4: Verify Form Functionality

**Test each input:**
- [ ] Title input updates correctly
- [ ] Description input updates correctly
- [ ] Priority buttons toggle correctly
- [ ] Reminder switch toggles correctly
- [ ] Submit button works with valid input
- [ ] Submit button disabled when title is empty

**Screenshot of working form:**

[Insert screenshot here]

---

### Challenge Tasks

1. **Add Validation:**
   - Show an error when title is empty
   - Show an error when title is less than 3 characters
   - Highlight the input with error state

2. **Add Reset Button:**
   - Add a "Cancel" button that resets the form
   - Clear all fields when pressed

3. **Date Picker:**
   - Add a due date field using `@react-native-community/datetimepicker`
   - Format the date display

---

### Reflection Questions

1. How did you manage the form state in this component?
   ___________________________________________________________________
   ___________________________________________________________________

2. What are the benefits of using a controlled component pattern?
   ___________________________________________________________________
   ___________________________________________________________________

3. How would you make this component more reusable?
   ___________________________________________________________________
   ___________________________________________________________________

---

## Lab 1.3: Flexbox Layout & Responsive Task List

### Lab Objectives
- Master Flexbox layout properties
- Build a responsive task list
- Create reusable TaskCard component
- Adapt to different screen sizes

### Prerequisites
- Labs 1.1 and 1.2 completed
- Understanding of Flexbox concepts

---

### Step 1: Create the TaskCard Component

**Create `src/components/TaskCard.tsx`:**

```tsx
import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Platform,
} from 'react-native';

export interface Task {
  id: string;
  title: string;
  description?: string;
  priority: 'low' | 'medium' | 'high';
  status: 'todo' | 'in-progress' | 'done';
  dueDate?: string;
}

interface TaskCardProps {
  task: Task;
  onPress?: (task: Task) => void;
  onStatusToggle?: (task: Task) => void;
}

export const TaskCard: React.FC<TaskCardProps> = ({
  task,
  onPress,
  onStatusToggle,
}) => {
  const getPriorityColor = (priority: Task['priority']) => {
    switch (priority) {
      case 'high': return '#e74c3c';
      case 'medium': return '#f39c12';
      case 'low': return '#2ecc71';
      default: return '#95a5a6';
    }
  };

  const getStatusIcon = (status: Task['status']) => {
    switch (status) {
      case 'done': return '✓';
      case 'in-progress': return '⟳';
      default: return '○';
    }
  };

  return (
    <TouchableOpacity
      style={styles.container}
      onPress={() => onPress?.(task)}
      activeOpacity={0.7}
      testID="task-card"
    >
      <View style={[styles.priorityIndicator, { backgroundColor: getPriorityColor(task.priority) }]} />
      
      <View style={styles.content}>
        <Text style={styles.title} numberOfLines={1}>
          {task.title}
        </Text>
        {task.description && (
          <Text style={styles.description} numberOfLines={2}>
            {task.description}
          </Text>
        )}
        <View style={styles.metaContainer}>
          {task.dueDate && (
            <Text style={styles.metaText}>Due: {task.dueDate}</Text>
          )}
          <Text style={styles.statusText}>
            {task.status.replace('-', ' ')}
          </Text>
        </View>
      </View>

      <TouchableOpacity
        style={styles.statusButton}
        onPress={() => onStatusToggle?.(task)}
        testID="status-toggle"
      >
        <Text style={styles.statusIcon}>{getStatusIcon(task.status)}</Text>
      </TouchableOpacity>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 12,
    marginVertical: 6,
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
  priorityIndicator: {
    width: 4,
    height: 40,
    borderRadius: 2,
    marginRight: 12,
  },
  content: {
    flex: 1,
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 2,
  },
  description: {
    fontSize: 14,
    color: '#7f8c8d',
    marginBottom: 4,
  },
  metaContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  metaText: {
    fontSize: 12,
    color: '#95a5a6',
  },
  statusText: {
    fontSize: 12,
    color: '#95a5a6',
    textTransform: 'capitalize',
  },
  statusButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: '#f1f2f6',
    alignItems: 'center',
    justifyContent: 'center',
    marginLeft: 8,
  },
  statusIcon: {
    fontSize: 16,
    color: '#2c3e50',
  },
});
```

---

### Step 2: Create the Responsive Task List

**Create `src/components/ResponsiveTaskList.tsx`:**

```tsx
import React from 'react';
import {
  View,
  FlatList,
  StyleSheet,
  useWindowDimensions,
  Text,
  Platform,
} from 'react-native';
import { Task, TaskCard } from './TaskCard';

interface ResponsiveTaskListProps {
  tasks: Task[];
  onTaskPress?: (task: Task) => void;
  onStatusToggle?: (task: Task) => void;
  emptyMessage?: string;
}

export const ResponsiveTaskList: React.FC<ResponsiveTaskListProps> = ({
  tasks,
  onTaskPress,
  onStatusToggle,
  emptyMessage = 'No tasks yet',
}) => {
  const { width } = useWindowDimensions();
  const isTablet = width >= 768;
  const numColumns = isTablet ? 2 : 1;

  const renderItem = ({ item }: { item: Task }) => (
    <View style={[styles.cardWrapper, isTablet && styles.cardWrapperTablet]}>
      <TaskCard
        task={item}
        onPress={onTaskPress}
        onStatusToggle={onStatusToggle}
      />
    </View>
  );

  if (tasks.length === 0) {
    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyEmoji}>📋</Text>
        <Text style={styles.emptyTitle}>{emptyMessage}</Text>
        <Text style={styles.emptySubtitle}>Create your first task to get started</Text>
      </View>
    );
  }

  return (
    <FlatList
      data={tasks}
      renderItem={renderItem}
      keyExtractor={(item) => item.id}
      numColumns={numColumns}
      contentContainerStyle={styles.listContent}
      showsVerticalScrollIndicator={false}
      key={numColumns} // Re-render when numColumns changes
    />
  );
};

const styles = StyleSheet.create({
  listContent: {
    padding: 8,
    paddingBottom: 20,
  },
  cardWrapper: {
    flex: 1,
    paddingHorizontal: 4,
  },
  cardWrapperTablet: {
    flex: 1,
    maxWidth: '50%',
    paddingHorizontal: 6,
  },
  emptyContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 40,
  },
  emptyEmoji: {
    fontSize: 48,
    marginBottom: 16,
  },
  emptyTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 8,
  },
  emptySubtitle: {
    fontSize: 14,
    color: '#7f8c8d',
    textAlign: 'center',
  },
});
```

---

### Step 3: Update App.tsx with Sample Data

**Update `App.tsx`:**

```tsx
import React, { useState } from 'react';
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, View, SafeAreaView, Platform, TouchableOpacity, Text } from 'react-native';
import { TaskForm, TaskFormData } from './src/components/TaskForm';
import { ResponsiveTaskList } from './src/components/ResponsiveTaskList';
import { Task } from './src/components/TaskCard';

const SAMPLE_TASKS: Task[] = [
  {
    id: '1',
    title: 'Learn React Native',
    description: 'Complete the React Native tutorial series',
    priority: 'high',
    status: 'in-progress',
    dueDate: '2024-12-20',
  },
  {
    id: '2',
    title: 'Build TaskFlow app',
    description: 'Complete the full TaskFlow application',
    priority: 'high',
    status: 'todo',
    dueDate: '2024-12-30',
  },
  {
    id: '3',
    title: 'Write documentation',
    description: 'Document the TaskFlow codebase',
    priority: 'medium',
    status: 'todo',
    dueDate: '2025-01-15',
  },
  {
    id: '4',
    title: 'Review design mockups',
    description: 'Review and provide feedback on UI designs',
    priority: 'low',
    status: 'done',
    dueDate: '2024-12-10',
  },
];

export default function App() {
  const [tasks, setTasks] = useState<Task[]>(SAMPLE_TASKS);
  const [showForm, setShowForm] = useState(false);

  const handleTaskSubmit = (data: TaskFormData) => {
    const newTask: Task = {
      id: `task-${Date.now()}`,
      title: data.title,
      description: data.description,
      priority: data.priority,
      status: 'todo',
    };
    setTasks([newTask, ...tasks]);
    setShowForm(false);
  };

  const handleStatusToggle = (task: Task) => {
    setTasks(tasks.map(t => {
      if (t.id === task.id) {
        const statusMap: Record<Task['status'], Task['status']> = {
          'todo': 'in-progress',
          'in-progress': 'done',
          'done': 'todo',
        };
        return { ...t, status: statusMap[t.status] };
      }
      return t;
    }));
  };

  const handleTaskPress = (task: Task) => {
    console.log('Task pressed:', task.title);
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.headerContainer}>
        <Text style={styles.header}>TaskFlow</Text>
        <TouchableOpacity
          style={styles.addButton}
          onPress={() => setShowForm(!showForm)}
        >
          <Text style={styles.addButtonText}>{showForm ? '✕' : '+'}</Text>
        </TouchableOpacity>
      </View>

      {showForm && (
        <View style={styles.formContainer}>
          <TaskForm onSubmit={handleTaskSubmit} />
        </View>
      )}

      <ResponsiveTaskList
        tasks={tasks}
        onTaskPress={handleTaskPress}
        onStatusToggle={handleStatusToggle}
        emptyMessage="No tasks yet"
      />
      <StatusBar style={Platform.OS === 'ios' ? 'dark' : 'auto'} />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  headerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  header: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2c3e50',
  },
  addButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#3498db',
    alignItems: 'center',
    justifyContent: 'center',
  },
  addButtonText: {
    fontSize: 24,
    color: '#ffffff',
    fontWeight: '300',
  },
  formContainer: {
    paddingHorizontal: 16,
    paddingVertical: 8,
  },
});
```

---

### Step 4: Test Responsive Behavior

**Test on different screen sizes:**

| Device | Width | Columns | Notes |
|--------|-------|---------|-------|
| iPhone SE | 375 | 1 | |
| iPhone 14 Pro | 390 | 1 | |
| iPad Mini | 768 | 2 | |
| iPad Pro | 1024 | 2 | |

**Screenshot of responsive layout:**

[Insert screenshots for phone and tablet]

---

### Challenge Tasks

1. **Add Grid/List Toggle:**
   - Add a button to switch between grid and list views
   - Store user preference in state

2. **Add Filtering:**
   - Filter tasks by priority (low, medium, high)
   - Filter tasks by status (todo, in-progress, done)

3. **Sorting:**
   - Sort tasks by due date
   - Sort tasks by priority

---

### Reflection Questions

1. How does Flexbox help with responsive design in React Native?
   ___________________________________________________________________
   ___________________________________________________________________

2. What strategies did you use to make the task list responsive?
   ___________________________________________________________________
   ___________________________________________________________________

3. How would you handle different screen sizes and orientations?
   ___________________________________________________________________
   ___________________________________________________________________

---

## Lab 1.4: Navigation Setup

### Lab Objectives
- Set up React Navigation
- Implement Stack navigator
- Implement Tab navigator
- Implement Drawer navigator
- Create navigation types

### Prerequisites
- Labs 1.1-1.3 completed
- Understanding of navigation concepts

---

### Step 1: Install Navigation Dependencies

```bash
# Core navigation
npx expo install @react-navigation/native
npx expo install react-native-screens react-native-safe-area-context

# Stack navigation
npx expo install @react-navigation/stack
npx expo install react-native-gesture-handler

# Tab navigation
npx expo install @react-navigation/bottom-tabs

# Drawer navigation
npx expo install @react-navigation/drawer
```

---

### Step 2: Create Navigation Types

**Create `src/navigation/types.ts`:**

```tsx
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { BottomTabNavigationProp } from '@react-navigation/bottom-tabs';
import { DrawerNavigationProp } from '@react-navigation/drawer';
import { RouteProp } from '@react-navigation/native';

// Root Stack Param List
export type RootStackParamList = {
  Auth: undefined;
  Main: undefined;
  TaskDetail: { taskId: string };
  TaskCreate: undefined;
  TaskEdit: { taskId: string };
};

// Auth Stack Param List
export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
};

// Main Tab Param List
export type MainTabParamList = {
  Home: undefined;
  Tasks: undefined;
  Profile: undefined;
};

// Drawer Param List
export type DrawerParamList = {
  MainTabs: undefined;
  Settings: undefined;
  Help: undefined;
  About: undefined;
};

// Type-safe navigation hooks
export type RootStackNavigationProp<T extends keyof RootStackParamList> =
  NativeStackNavigationProp<RootStackParamList, T>;

export type MainTabNavigationProp<T extends keyof MainTabParamList> =
  BottomTabNavigationProp<MainTabParamList, T>;

export type DrawerNavigationProp<T extends keyof DrawerParamList> =
  DrawerNavigationProp<DrawerParamList, T>;

// Type-safe route props
export type RootStackRouteProp<T extends keyof RootStackParamList> =
  RouteProp<RootStackParamList, T>;
```

---

### Step 3: Create Auth Navigator

**Create `src/navigation/AuthNavigator.tsx`:**

```tsx
import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { AuthStackParamList } from './types';

// Placeholder screens (we'll implement these later)
const LoginScreen = () => <Text>Login Screen</Text>;
const RegisterScreen = () => <Text>Register Screen</Text>;
const ForgotPasswordScreen = () => <Text>Forgot Password Screen</Text>;

const AuthStack = createNativeStackNavigator<AuthStackParamList>();

export const AuthNavigator: React.FC = () => {
  return (
    <AuthStack.Navigator
      screenOptions={{
        headerShown: false,
        contentStyle: {
          backgroundColor: '#f8f9fa',
        },
      }}
    >
      <AuthStack.Screen name="Login" component={LoginScreen} />
      <AuthStack.Screen name="Register" component={RegisterScreen} />
      <AuthStack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
    </AuthStack.Navigator>
  );
};
```

---

### Step 4: Create Tab Navigator

**Create `src/navigation/MainTabs.tsx`:**

```tsx
import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Text, View, StyleSheet } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { MainTabParamList } from './types';

// Placeholder screens
const HomeScreen = () => (
  <View style={styles.placeholder}>
    <Text>Home Screen</Text>
  </View>
);
const TasksScreen = () => (
  <View style={styles.placeholder}>
    <Text>Tasks Screen</Text>
  </View>
);
const ProfileScreen = () => (
  <View style={styles.placeholder}>
    <Text>Profile Screen</Text>
  </View>
);

const Tab = createBottomTabNavigator<MainTabParamList>();

export const MainTabs: React.FC = () => {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName: keyof typeof MaterialIcons.glyphMap;

          switch (route.name) {
            case 'Home':
              iconName = focused ? 'home' : 'home-outlined';
              break;
            case 'Tasks':
              iconName = focused ? 'assignment' : 'assignment-outlined';
              break;
            case 'Profile':
              iconName = focused ? 'person' : 'person-outline';
              break;
            default:
              iconName = 'help';
          }

          return <MaterialIcons name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: '#3498db',
        tabBarInactiveTintColor: '#95a5a6',
        tabBarStyle: {
          paddingBottom: 8,
          paddingTop: 8,
          height: 64,
        },
        headerShown: false,
      })}
    >
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen
        name="Tasks"
        component={TasksScreen}
        options={{
          tabBarBadge: 3,
        }}
      />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
};

const styles = StyleSheet.create({
  placeholder: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f8f9fa',
  },
});
```

---

### Step 5: Create Drawer Navigator

**Create `src/navigation/DrawerNavigator.tsx`:**

```tsx
import React from 'react';
import { createDrawerNavigator } from '@react-navigation/drawer';
import { View, Text, StyleSheet, Image, TouchableOpacity } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { DrawerParamList } from './types';
import { MainTabs } from './MainTabs';

// Placeholder screens
const SettingsScreen = () => (
  <View style={styles.placeholder}>
    <Text>Settings Screen</Text>
  </View>
);
const HelpScreen = () => (
  <View style={styles.placeholder}>
    <Text>Help Screen</Text>
  </View>
);
const AboutScreen = () => (
  <View style={styles.placeholder}>
    <Text>About Screen</Text>
  </View>
);

const Drawer = createDrawerNavigator<DrawerParamList>();

interface DrawerItemProps {
  icon: keyof typeof MaterialIcons.glyphMap;
  label: string;
  onPress: () => void;
}

const DrawerItem: React.FC<DrawerItemProps> = ({ icon, label, onPress }) => (
  <TouchableOpacity style={styles.drawerItem} onPress={onPress}>
    <MaterialIcons name={icon} size={24} color="#2c3e50" />
    <Text style={styles.drawerItemLabel}>{label}</Text>
  </TouchableOpacity>
);

const CustomDrawerContent = ({ navigation }: any) => {
  return (
    <View style={styles.drawerContainer}>
      <View style={styles.drawerHeader}>
        <View style={styles.avatarPlaceholder}>
          <Text style={styles.avatarText}>👤</Text>
        </View>
        <Text style={styles.userName}>Guest User</Text>
        <Text style={styles.userEmail}>guest@example.com</Text>
      </View>

      <View style={styles.drawerItems}>
        <DrawerItem
          icon="home"
          label="Home"
          onPress={() => navigation.navigate('MainTabs')}
        />
        <DrawerItem
          icon="settings"
          label="Settings"
          onPress={() => navigation.navigate('Settings')}
        />
        <DrawerItem
          icon="help"
          label="Help"
          onPress={() => navigation.navigate('Help')}
        />
        <DrawerItem
          icon="info"
          label="About"
          onPress={() => navigation.navigate('About')}
        />
      </View>

      <View style={styles.drawerFooter}>
        <Text style={styles.versionText}>TaskFlow v1.0.0</Text>
      </View>
    </View>
  );
};

export const DrawerNavigator: React.FC = () => {
  return (
    <Drawer.Navigator
      screenOptions={{
        drawerStyle: {
          width: 280,
        },
        headerShown: false,
      }}
      drawerContent={(props) => <CustomDrawerContent {...props} />}
    >
      <Drawer.Screen name="MainTabs" component={MainTabs} />
      <Drawer.Screen name="Settings" component={SettingsScreen} />
      <Drawer.Screen name="Help" component={HelpScreen} />
      <Drawer.Screen name="About" component={AboutScreen} />
    </Drawer.Navigator>
  );
};

const styles = StyleSheet.create({
  drawerContainer: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  drawerHeader: {
    padding: 20,
    paddingTop: 40,
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  avatarPlaceholder: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: '#f1f2f6',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 8,
  },
  avatarText: {
    fontSize: 32,
  },
  userName: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2c3e50',
  },
  userEmail: {
    fontSize: 14,
    color: '#7f8c8d',
  },
  drawerItems: {
    flex: 1,
    paddingTop: 16,
  },
  drawerItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 20,
  },
  drawerItemLabel: {
    fontSize: 16,
    color: '#2c3e50',
    marginLeft: 16,
  },
  drawerFooter: {
    padding: 16,
    borderTopWidth: 1,
    borderTopColor: '#f0f0f0',
    alignItems: 'center',
  },
  versionText: {
    fontSize: 12,
    color: '#95a5a6',
  },
  placeholder: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f8f9fa',
  },
});
```

---

### Step 6: Create Root Navigator

**Create `src/navigation/RootNavigator.tsx`:**

```tsx
import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useAuthStore } from '../stores/authStore'; // We'll create this later
import { RootStackParamList } from './types';
import { AuthNavigator } from './AuthNavigator';
import { DrawerNavigator } from './DrawerNavigator';

// Placeholder screens
const TaskDetailScreen = () => <Text>Task Detail Screen</Text>;
const TaskCreateScreen = () => <Text>Task Create Screen</Text>;
const TaskEditScreen = () => <Text>Task Edit Screen</Text>;

const RootStack = createNativeStackNavigator<RootStackParamList>();

export const RootNavigator: React.FC = () => {
  // const { isAuthenticated } = useAuthStore();
  const isAuthenticated = true; // Placeholder

  return (
    <RootStack.Navigator
      screenOptions={{
        headerShown: false,
        contentStyle: {
          backgroundColor: '#f8f9fa',
        },
      }}
    >
      {!isAuthenticated ? (
        <RootStack.Screen name="Auth" component={AuthNavigator} />
      ) : (
        <>
          <RootStack.Screen name="Main" component={DrawerNavigator} />
          <RootStack.Screen
            name="TaskDetail"
            component={TaskDetailScreen}
            options={{ headerShown: true, title: 'Task Details' }}
          />
          <RootStack.Screen
            name="TaskCreate"
            component={TaskCreateScreen}
            options={{
              headerShown: true,
              title: 'Create Task',
              presentation: 'modal',
            }}
          />
          <RootStack.Screen
            name="TaskEdit"
            component={TaskEditScreen}
            options={{ headerShown: true, title: 'Edit Task' }}
          />
        </>
      )}
    </RootStack.Navigator>
  );
};
```

---

### Step 7: Update App.tsx

**Update `App.tsx`:**

```tsx
import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { NavigationContainer } from '@react-navigation/native';
import { Platform } from 'react-native';
import { RootNavigator } from './src/navigation/RootNavigator';

export default function App() {
  return (
    <SafeAreaProvider>
      <NavigationContainer>
        <RootNavigator />
        <StatusBar style={Platform.OS === 'ios' ? 'dark' : 'auto'} />
      </NavigationContainer>
    </SafeAreaProvider>
  );
}
```

---

### Step 8: Verify Navigation

**Test navigation flows:**

- [ ] App launches with Main/Home screen
- [ ] Tab navigation works (Home, Tasks, Profile)
- [ ] Drawer navigation opens
- [ ] Navigation between tabs preserves state
- [ ] All placeholder screens display correctly

**Screenshot of working navigation:**

[Insert screenshot here]

---

### Challenge Tasks

1. **Add Deep Linking:**
   - Configure deep linking for task details
   - Test with a URL scheme

2. **Navigation State Persistence:**
   - Save navigation state to AsyncStorage
   - Restore state on app restart

3. **Custom Headers:**
   - Add custom header with title and actions
   - Add back button behavior

---

### Reflection Questions

1. What are the advantages of using React Navigation over custom navigation?
   ___________________________________________________________________
   ___________________________________________________________________

2. How do the different navigator types (Stack, Tab, Drawer) work together?
   ___________________________________________________________________
   ___________________________________________________________________

3. What challenges did you face with navigation setup?
   ___________________________________________________________________
   ___________________________________________________________________

---

# PART 2: STATE MANAGEMENT & PERSISTENCE

---

## Lab 2.1: Zustand Stores

### Lab Objectives
- Create auth store with Zustand
- Create task store with Zustand
- Create UI store with Zustand
- Add persistence with AsyncStorage
- Use stores in components

### Prerequisites
- Lab 1.4 completed
- Understanding of Zustand concepts

---

### Step 1: Install Zustand

```bash
npm install zustand
```

---

### Step 2: Create Auth Store

**Create `src/stores/authStore.ts`:**

```tsx
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

export interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
}

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  login: (email: string, password: string) => Promise<void>;
  register: (name: string, email: string, password: string) => Promise<void>;
  logout: () => void;
  checkAuth: () => Promise<void>;
  clearError: () => void;
}

// Mock API functions
const mockApi = {
  login: async (email: string, password: string) => {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 1000));

    if (email === 'demo@example.com' && password === 'password') {
      return {
        user: {
          id: '1',
          name: 'Demo User',
          email: 'demo@example.com',
          avatar: 'https://ui-avatars.com/api/?name=Demo+User&background=3498db&color=fff&size=128',
        },
        token: 'mock-jwt-token-12345',
      };
    }

    throw new Error('Invalid email or password');
  },

  register: async (name: string, email: string, password: string) => {
    await new Promise(resolve => setTimeout(resolve, 1000));

    return {
      user: {
        id: '1',
        name,
        email,
        avatar: `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=3498db&color=fff&size=128`,
      },
      token: 'mock-jwt-token-67890',
    };
  },

  validateToken: async (token: string) => {
    await new Promise(resolve => setTimeout(resolve, 500));

    if (token === 'mock-jwt-token-12345') {
      return {
        id: '1',
        name: 'Demo User',
        email: 'demo@example.com',
        avatar: 'https://ui-avatars.com/api/?name=Demo+User&background=3498db&color=fff&size=128',
      };
    }

    throw new Error('Invalid token');
  },
};

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      login: async (email: string, password: string) => {
        set({ isLoading: true, error: null });

        try {
          const { user, token } = await mockApi.login(email, password);
          set({
            user,
            token,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Login failed',
            isAuthenticated: false,
          });
          throw error;
        }
      },

      register: async (name: string, email: string, password: string) => {
        set({ isLoading: true, error: null });

        try {
          const { user, token } = await mockApi.register(name, email, password);
          set({
            user,
            token,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Registration failed',
            isAuthenticated: false,
          });
          throw error;
        }
      },

      logout: () => {
        set({
          user: null,
          token: null,
          isAuthenticated: false,
          isLoading: false,
          error: null,
        });
      },

      checkAuth: async () => {
        const { token } = get();

        if (!token) {
          set({ isAuthenticated: false });
          return;
        }

        try {
          set({ isLoading: true });
          const user = await mockApi.validateToken(token);
          set({
            user,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
        } catch (error) {
          set({
            user: null,
            token: null,
            isAuthenticated: false,
            isLoading: false,
            error: 'Session expired. Please login again.',
          });
        }
      },

      clearError: () => {
        set({ error: null });
      },
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
```

---

### Step 3: Create Task Store

**Create `src/stores/taskStore.ts`:**

```tsx
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

export interface Task {
  id: string;
  title: string;
  description?: string;
  priority: 'low' | 'medium' | 'high';
  status: 'todo' | 'in-progress' | 'done';
  dueDate?: string;
  category?: string;
  createdAt: string;
  updatedAt: string;
}

export interface TaskFilters {
  search: string;
  priority?: 'low' | 'medium' | 'high';
  status?: 'todo' | 'in-progress' | 'done';
  category?: string;
}

interface TaskState {
  tasks: Task[];
  selectedTask: Task | null;
  filters: TaskFilters;
  isLoading: boolean;
  error: string | null;
  fetchTasks: () => Promise<void>;
  getTask: (id: string) => Task | undefined;
  createTask: (taskData: Omit<Task, 'id' | 'createdAt' | 'updatedAt'>) => Promise<Task>;
  updateTask: (id: string, taskData: Partial<Task>) => Promise<Task>;
  deleteTask: (id: string) => Promise<void>;
  selectTask: (task: Task | null) => void;
  setFilters: (filters: Partial<TaskFilters>) => void;
  clearFilters: () => void;
  clearError: () => void;
  getFilteredTasks: () => Task[];
  getTaskCount: () => { total: number; todo: number; inProgress: number; done: number };
}

// Mock initial tasks
const initialTasks: Task[] = [
  {
    id: '1',
    title: 'Learn React Native',
    description: 'Complete the React Native tutorial series',
    priority: 'high',
    status: 'in-progress',
    dueDate: '2024-12-20',
    category: 'Learning',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '2',
    title: 'Build TaskFlow app',
    description: 'Complete the full TaskFlow application',
    priority: 'high',
    status: 'todo',
    dueDate: '2024-12-30',
    category: 'Work',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '3',
    title: 'Review design mockups',
    description: 'Review and provide feedback on UI designs',
    priority: 'low',
    status: 'done',
    dueDate: '2024-12-10',
    category: 'Design',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
];

// Mock API
const mockTaskApi = {
  fetchTasks: async (): Promise<Task[]> => {
    await new Promise(resolve => setTimeout(resolve, 800));
    return [...initialTasks];
  },

  createTask: async (taskData: any): Promise<Task> => {
    await new Promise(resolve => setTimeout(resolve, 600));
    const newTask: Task = {
      id: `task-${Date.now()}`,
      ...taskData,
      status: 'todo',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    return newTask;
  },

  updateTask: async (id: string, taskData: any): Promise<Task> => {
    await new Promise(resolve => setTimeout(resolve, 600));
    const existingTask = initialTasks.find(t => t.id === id);
    if (!existingTask) {
      throw new Error('Task not found');
    }
    return {
      ...existingTask,
      ...taskData,
      updatedAt: new Date().toISOString(),
    };
  },

  deleteTask: async (id: string): Promise<void> => {
    await new Promise(resolve => setTimeout(resolve, 500));
    const existingTask = initialTasks.find(t => t.id === id);
    if (!existingTask) {
      throw new Error('Task not found');
    }
  },
};

export const useTaskStore = create<TaskState>()(
  persist(
    (set, get) => ({
      tasks: [],
      selectedTask: null,
      filters: {
        search: '',
      },
      isLoading: false,
      error: null,

      fetchTasks: async () => {
        set({ isLoading: true, error: null });

        try {
          const tasks = await mockTaskApi.fetchTasks();
          set({
            tasks,
            isLoading: false,
          });
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Failed to fetch tasks',
          });
        }
      },

      getTask: (id: string) => {
        const { tasks } = get();
        return tasks.find(task => task.id === id);
      },

      createTask: async (taskData) => {
        set({ isLoading: true, error: null });

        try {
          const newTask = await mockTaskApi.createTask(taskData);
          set((state) => ({
            tasks: [newTask, ...state.tasks],
            isLoading: false,
          }));
          return newTask;
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Failed to create task',
          });
          throw error;
        }
      },

      updateTask: async (id: string, taskData) => {
        set({ isLoading: true, error: null });

        try {
          const updatedTask = await mockTaskApi.updateTask(id, taskData);
          set((state) => ({
            tasks: state.tasks.map(task =>
              task.id === id ? updatedTask : task
            ),
            selectedTask: state.selectedTask?.id === id ? updatedTask : state.selectedTask,
            isLoading: false,
          }));
          return updatedTask;
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Failed to update task',
          });
          throw error;
        }
      },

      deleteTask: async (id: string) => {
        set({ isLoading: true, error: null });

        try {
          await mockTaskApi.deleteTask(id);
          set((state) => ({
            tasks: state.tasks.filter(task => task.id !== id),
            selectedTask: state.selectedTask?.id === id ? null : state.selectedTask,
            isLoading: false,
          }));
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Failed to delete task',
          });
          throw error;
        }
      },

      selectTask: (task) => {
        set({ selectedTask: task });
      },

      setFilters: (filters) => {
        set((state) => ({
          filters: { ...state.filters, ...filters },
        }));
      },

      clearFilters: () => {
        set({
          filters: { search: '' },
        });
      },

      clearError: () => {
        set({ error: null });
      },

      getFilteredTasks: () => {
        const { tasks, filters } = get();

        let filtered = [...tasks];

        if (filters.search) {
          const searchLower = filters.search.toLowerCase();
          filtered = filtered.filter(task =>
            task.title.toLowerCase().includes(searchLower) ||
            (task.description && task.description.toLowerCase().includes(searchLower))
          );
        }

        if (filters.priority) {
          filtered = filtered.filter(task => task.priority === filters.priority);
        }

        if (filters.status) {
          filtered = filtered.filter(task => task.status === filters.status);
        }

        if (filters.category) {
          filtered = filtered.filter(task =>
            task.category && task.category.toLowerCase().includes(filters.category!.toLowerCase())
          );
        }

        return filtered;
      },

      getTaskCount: () => {
        const { tasks } = get();
        const todo = tasks.filter(t => t.status === 'todo').length;
        const inProgress = tasks.filter(t => t.status === 'in-progress').length;
        const done = tasks.filter(t => t.status === 'done').length;

        return {
          total: tasks.length,
          todo,
          inProgress,
          done,
        };
      },
    }),
    {
      name: 'task-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        tasks: state.tasks,
        filters: state.filters,
      }),
    }
  )
);
```

---

### Step 4: Create UI Store

**Create `src/stores/uiStore.ts`:**

```tsx
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

export interface Toast {
  id: string;
  message: string;
  type: 'success' | 'error' | 'warning' | 'info';
}

interface UIState {
  theme: 'light' | 'dark' | 'system';
  modal: {
    visible: boolean;
    type: 'none' | 'taskForm' | 'taskFilter' | 'confirm';
    data?: any;
  };
  toasts: Toast[];
  isLoading: boolean;
  isOnline: boolean;
  setTheme: (theme: 'light' | 'dark' | 'system') => void;
  toggleTheme: () => void;
  showModal: (type: UIState['modal']['type'], data?: any) => void;
  hideModal: () => void;
  showToast: (message: string, type: Toast['type'], duration?: number) => void;
  hideToast: (id: string) => void;
  clearToasts: () => void;
  setLoading: (loading: boolean) => void;
  setOnlineStatus: (online: boolean) => void;
}

export const useUIStore = create<UIState>()(
  persist(
    (set, get) => ({
      theme: 'system',
      modal: {
        visible: false,
        type: 'none',
      },
      toasts: [],
      isLoading: false,
      isOnline: true,

      setTheme: (theme) => {
        set({ theme });
      },

      toggleTheme: () => {
        const { theme } = get();
        const newTheme = theme === 'light' ? 'dark' :
          theme === 'dark' ? 'system' : 'light';
        set({ theme: newTheme });
      },

      showModal: (type, data) => {
        set({
          modal: {
            visible: true,
            type,
            data,
          },
        });
      },

      hideModal: () => {
        set({
          modal: {
            visible: false,
            type: 'none',
          },
        });
      },

      showToast: (message, type, duration = 3000) => {
        const id = `toast-${Date.now()}`;
        const newToast: Toast = {
          id,
          message,
          type,
        };

        set((state) => ({
          toasts: [...state.toasts, newToast],
        }));

        // Auto-remove toast after duration
        setTimeout(() => {
          get().hideToast(id);
        }, duration);
      },

      hideToast: (id) => {
        set((state) => ({
          toasts: state.toasts.filter(toast => toast.id !== id),
        }));
      },

      clearToasts: () => {
        set({ toasts: [] });
      },

      setLoading: (loading) => {
        set({ isLoading: loading });
      },

      setOnlineStatus: (online) => {
        set({ isOnline: online });
      },
    }),
    {
      name: 'ui-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        theme: state.theme,
      }),
    }
  )
);
```

---

### Step 5: Use Stores in Components

**Update `src/components/TaskForm.tsx` to use the task store:**

```tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  Switch,
  StyleSheet,
  Platform,
  ActivityIndicator,
} from 'react-native';
import { useTaskStore } from '../stores/taskStore';
import { useUIStore } from '../stores/uiStore';

interface TaskFormProps {
  onSuccess?: () => void;
  initialData?: {
    id?: string;
    title?: string;
    description?: string;
    priority?: 'low' | 'medium' | 'high';
    dueDate?: string;
    category?: string;
  };
}

export const TaskForm: React.FC<TaskFormProps> = ({
  onSuccess,
  initialData,
}) => {
  const { createTask, updateTask, isLoading } = useTaskStore();
  const { showToast, hideModal } = useUIStore();

  const [title, setTitle] = useState(initialData?.title || '');
  const [description, setDescription] = useState(initialData?.description || '');
  const [priority, setPriority] = useState<'low' | 'medium' | 'high'>(
    initialData?.priority || 'medium'
  );
  const [dueDate, setDueDate] = useState(initialData?.dueDate || '');
  const [category, setCategory] = useState(initialData?.category || '');
  const [errors, setErrors] = useState<Record<string, string>>({});

  const validate = () => {
    const newErrors: Record<string, string> = {};

    if (!title.trim()) {
      newErrors.title = 'Title is required';
    } else if (title.length < 3) {
      newErrors.title = 'Title must be at least 3 characters';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async () => {
    if (!validate()) return;

    try {
      const taskData = {
        title: title.trim(),
        description: description.trim(),
        priority,
        dueDate: dueDate || undefined,
        category: category.trim() || undefined,
      };

      if (initialData?.id) {
        await updateTask(initialData.id, taskData);
        showToast('Task updated successfully!', 'success');
      } else {
        await createTask(taskData);
        showToast('Task created successfully!', 'success');
      }

      // Reset form
      setTitle('');
      setDescription('');
      setPriority('medium');
      setDueDate('');
      setCategory('');
      setErrors({});

      onSuccess?.();
      hideModal();
    } catch (error) {
      showToast(
        error instanceof Error ? error.message : 'Failed to save task',
        'error'
      );
    }
  };

  const getPriorityColor = (p: string) => {
    switch (p) {
      case 'high': return '#e74c3c';
      case 'medium': return '#f39c12';
      case 'low': return '#2ecc71';
      default: return '#95a5a6';
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>
        {initialData?.id ? 'Edit Task' : 'Create New Task'}
      </Text>

      {/* Title Input */}
      <View style={styles.fieldContainer}>
        <Text style={styles.label}>Title *</Text>
        <TextInput
          style={[
            styles.input,
            errors.title && styles.inputError,
          ]}
          placeholder="Enter task title..."
          value={title}
          onChangeText={setTitle}
          placeholderTextColor="#95a5a6"
        />
        {errors.title && (
          <Text style={styles.errorText}>{errors.title}</Text>
        )}
      </View>

      {/* Description Input */}
      <View style={styles.fieldContainer}>
        <Text style={styles.label}>Description</Text>
        <TextInput
          style={[styles.input, styles.textArea]}
          placeholder="Enter task description..."
          value={description}
          onChangeText={setDescription}
          multiline
          numberOfLines={4}
          textAlignVertical="top"
          placeholderTextColor="#95a5a6"
        />
      </View>

      {/* Priority Selector */}
      <View style={styles.fieldContainer}>
        <Text style={styles.label}>Priority</Text>
        <View style={styles.priorityContainer}>
          {(['low', 'medium', 'high'] as const).map((p) => (
            <TouchableOpacity
              key={p}
              style={[
                styles.priorityButton,
                priority === p && styles.priorityButtonActive,
                { borderColor: getPriorityColor(p) },
              ]}
              onPress={() => setPriority(p)}
            >
              <Text
                style={[
                  styles.priorityText,
                  priority === p && styles.priorityTextActive,
                  { color: priority === p ? '#fff' : getPriorityColor(p) },
                ]}
              >
                {p.charAt(0).toUpperCase() + p.slice(1)}
              </Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      {/* Due Date Input */}
      <View style={styles.fieldContainer}>
        <Text style={styles.label}>Due Date</Text>
        <TextInput
          style={styles.input}
          placeholder="YYYY-MM-DD"
          value={dueDate}
          onChangeText={setDueDate}
          placeholderTextColor="#95a5a6"
        />
      </View>

      {/* Category Input */}
      <View style={styles.fieldContainer}>
        <Text style={styles.label}>Category</Text>
        <TextInput
          style={styles.input}
          placeholder="Enter category..."
          value={category}
          onChangeText={setCategory}
          placeholderTextColor="#95a5a6"
        />
      </View>

      {/* Submit Button */}
      <TouchableOpacity
        style={[styles.submitButton, isLoading && styles.submitButtonDisabled]}
        onPress={handleSubmit}
        disabled={isLoading}
      >
        {isLoading ? (
          <ActivityIndicator color="#ffffff" />
        ) : (
          <Text style={styles.submitButtonText}>
            {initialData?.id ? 'Update Task' : 'Create Task'}
          </Text>
        )}
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginVertical: 8,
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
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 16,
  },
  fieldContainer: {
    marginBottom: 16,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: '#2c3e50',
    marginBottom: 6,
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
    backgroundColor: '#3498db',
    borderColor: '#3498db',
  },
  priorityText: {
    fontSize: 14,
    fontWeight: '500',
  },
  priorityTextActive: {
    color: '#ffffff',
  },
  submitButton: {
    backgroundColor: '#3498db',
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 8,
  },
  submitButtonDisabled: {
    opacity: 0.6,
  },
  submitButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
});
```

---

### Step 6: Verify Store Functionality

**Test each store:**

- [ ] Auth store persists login state
- [ ] Task store fetches tasks
- [ ] Task store creates tasks
- [ ] Task store updates tasks
- [ ] Task store deletes tasks
- [ ] UI store handles toasts
- [ ] UI store handles modal

---

### Challenge Tasks

1. **Add Error Handling:**
   - Display error messages from stores
   - Handle network errors gracefully
   - Add retry logic

2. **Add Selectors:**
   - Create selectors for derived state
   - Optimize re-renders with selectors

3. **Add Middleware:**
   - Add logging middleware
   - Add devtools middleware

---

### Reflection Questions

1. What are the benefits of using Zustand for state management?
   ___________________________________________________________________
   ___________________________________________________________________

2. How did you handle async operations in the stores?
   ___________________________________________________________________
   ___________________________________________________________________

3. What strategies did you use for error handling?
   ___________________________________________________________________
   ___________________________________________________________________

---

# PART 3: DEVICE CAPABILITIES & NATIVE FEATURES

---

## Lab 3.1: Camera & Photo Library

### Lab Objectives
- Implement camera capture
- Implement photo library selection
- Optimize images
- Store and display images

### Prerequisites
- Labs 1.1-2.1 completed
- Understanding of device permissions

---

### Step 1: Install Dependencies

```bash
npx expo install expo-camera expo-image-picker expo-image-manipulator expo-file-system
```

---

### Step 2: Create Camera Service

**Create `src/services/cameraService.ts`:**

```tsx
import * as Camera from 'expo-camera';
import * as ImagePicker from 'expo-image-picker';
import * as ImageManipulator from 'expo-image-manipulator';
import * as FileSystem from 'expo-file-system';
import { Alert, Platform } from 'react-native';

export interface ImageResult {
  uri: string;
  width: number;
  height: number;
  base64?: string;
  fileName?: string;
  fileSize?: number;
}

export class CameraService {
  /**
   * Request camera permissions
   */
  static async requestCameraPermissions(): Promise<boolean> {
    try {
      const { status } = await Camera.requestCameraPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert(
          'Permission Required',
          'Camera access is needed to take photos for your tasks.',
          [{ text: 'OK' }]
        );
        return false;
      }
      return true;
    } catch (error) {
      console.error('Error requesting camera permissions:', error);
      return false;
    }
  }

  /**
   * Request photo library permissions
   */
  static async requestMediaLibraryPermissions(): Promise<boolean> {
    try {
      const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert(
          'Permission Required',
          'Photo library access is needed to select images for your tasks.',
          [{ text: 'OK' }]
        );
        return false;
      }
      return true;
    } catch (error) {
      console.error('Error requesting media library permissions:', error);
      return false;
    }
  }

  /**
   * Take a photo with the camera
   */
  static async takePhoto(): Promise<ImageResult | null> {
    const hasPermission = await this.requestCameraPermissions();
    if (!hasPermission) return null;

    try {
      const result = await ImagePicker.launchCameraAsync({
        allowsEditing: true,
        aspect: [4, 3],
        quality: 0.8,
        base64: false,
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
      });

      if (!result.canceled && result.assets.length > 0) {
        const asset = result.assets[0];
        return await this.optimizeImage(asset);
      }

      return null;
    } catch (error) {
      console.error('Error taking photo:', error);
      Alert.alert('Error', 'Failed to take photo. Please try again.');
      return null;
    }
  }

  /**
   * Pick an image from the photo library
   */
  static async pickImage(): Promise<ImageResult | null> {
    const hasPermission = await this.requestMediaLibraryPermissions();
    if (!hasPermission) return null;

    try {
      const result = await ImagePicker.launchImageLibraryAsync({
        allowsEditing: true,
        aspect: [4, 3],
        quality: 0.8,
        base64: false,
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
      });

      if (!result.canceled && result.assets.length > 0) {
        const asset = result.assets[0];
        return await this.optimizeImage(asset);
      }

      return null;
    } catch (error) {
      console.error('Error picking image:', error);
      Alert.alert('Error', 'Failed to select image. Please try again.');
      return null;
    }
  }

  /**
   * Optimize image (resize, compress)
   */
  static async optimizeImage(
    asset: ImagePicker.ImagePickerAsset
  ): Promise<ImageResult> {
    try {
      // Resize to max 1024px
      const manipResult = await ImageManipulator.manipulateAsync(
        asset.uri,
        [
          {
            resize: {
              width: Math.min(asset.width, 1024),
              height: Math.min(asset.height, 1024),
            },
          },
        ],
        {
          compress: 0.8,
          format: ImageManipulator.SaveFormat.JPEG,
          base64: false,
        }
      );

      // Get file info
      const fileInfo = await FileSystem.getInfoAsync(manipResult.uri);

      return {
        uri: manipResult.uri,
        width: manipResult.width,
        height: manipResult.height,
        fileName: asset.fileName || `image_${Date.now()}.jpg`,
        fileSize: fileInfo.size,
      };
    } catch (error) {
      console.error('Error optimizing image:', error);
      return {
        uri: asset.uri,
        width: asset.width,
        height: asset.height,
        fileName: asset.fileName || `image_${Date.now()}.jpg`,
      };
    }
  }

  /**
   * Save image to app's local storage
   */
  static async saveImageToLocalStorage(
    imageUri: string,
    fileName?: string
  ): Promise<string> {
    try {
      const directory = `${FileSystem.documentDirectory}images/`;
      const dirInfo = await FileSystem.getInfoAsync(directory);

      if (!dirInfo.exists) {
        await FileSystem.makeDirectoryAsync(directory, { intermediates: true });
      }

      const extension = imageUri.split('.').pop() || 'jpg';
      const name = fileName || `task_image_${Date.now()}.${extension}`;
      const path = `${directory}${name}`;

      await FileSystem.copyAsync({
        from: imageUri,
        to: path,
      });

      return path;
    } catch (error) {
      console.error('Error saving image:', error);
      throw new Error('Failed to save image');
    }
  }

  /**
   * Delete image from local storage
   */
  static async deleteImageFromLocalStorage(imagePath: string): Promise<void> {
    try {
      const fileInfo = await FileSystem.getInfoAsync(imagePath);
      if (fileInfo.exists) {
        await FileSystem.deleteAsync(imagePath);
      }
    } catch (error) {
      console.error('Error deleting image:', error);
    }
  }

  /**
   * Get image as base64
   */
  static async getImageAsBase64(uri: string): Promise<string | null> {
    try {
      const base64 = await FileSystem.readAsStringAsync(uri, {
        encoding: FileSystem.EncodingType.Base64,
      });
      return base64;
    } catch (error) {
      console.error('Error reading image as base64:', error);
      return null;
    }
  }
}
```

---

### Step 3: Create Image Attachment Component

**Create `src/components/ImageAttachment.tsx`:**

```tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Image,
  StyleSheet,
  ScrollView,
  ActivityIndicator,
  Platform,
  Alert,
} from 'react-native';
import { CameraService, ImageResult } from '../services/cameraService';

interface ImageAttachmentProps {
  onImageSelected?: (image: ImageResult) => void;
  onImageRemoved?: (uri: string) => void;
  maxImages?: number;
  initialImages?: ImageResult[];
  readonly?: boolean;
}

export const ImageAttachment: React.FC<ImageAttachmentProps> = ({
  onImageSelected,
  onImageRemoved,
  maxImages = 5,
  initialImages = [],
  readonly = false,
}) => {
  const [images, setImages] = useState<ImageResult[]>(initialImages);
  const [uploading, setUploading] = useState(false);

  const handleAddImage = async () => {
    if (images.length >= maxImages) {
      Alert.alert('Limit Reached', `You can add up to ${maxImages} images`);
      return;
    }

    Alert.alert(
      'Add Image',
      'Choose an option',
      [
        {
          text: 'Take Photo',
          onPress: handleTakePhoto,
        },
        {
          text: 'Choose from Library',
          onPress: handlePickImage,
        },
        {
          text: 'Cancel',
          style: 'cancel',
        },
      ],
      { cancelable: true }
    );
  };

  const handleTakePhoto = async () => {
    setUploading(true);
    try {
      const image = await CameraService.takePhoto();
      if (image) {
        const savedPath = await CameraService.saveImageToLocalStorage(image.uri);
        const newImage = { ...image, uri: savedPath };
        setImages(prev => [...prev, newImage]);
        onImageSelected?.(newImage);
      }
    } catch (error) {
      console.error('Error taking photo:', error);
      Alert.alert('Error', 'Failed to take photo');
    } finally {
      setUploading(false);
    }
  };

  const handlePickImage = async () => {
    setUploading(true);
    try {
      const image = await CameraService.pickImage();
      if (image) {
        const savedPath = await CameraService.saveImageToLocalStorage(image.uri);
        const newImage = { ...image, uri: savedPath };
        setImages(prev => [...prev, newImage]);
        onImageSelected?.(newImage);
      }
    } catch (error) {
      console.error('Error picking image:', error);
      Alert.alert('Error', 'Failed to pick image');
    } finally {
      setUploading(false);
    }
  };

  const handleRemoveImage = async (index: number) => {
    const imageToRemove = images[index];
    if (imageToRemove) {
      await CameraService.deleteImageFromLocalStorage(imageToRemove.uri);
    }

    setImages(prev => prev.filter((_, i) => i !== index));
    if (images.length === 1) {
      onImageRemoved?.(images[0].uri);
    }
  };

  const renderImageItem = (image: ImageResult, index: number) => (
    <View key={index} style={styles.imageContainer}>
      <Image source={{ uri: image.uri }} style={styles.imageThumb} />

      {!readonly && (
        <TouchableOpacity
          style={styles.removeButton}
          onPress={() => handleRemoveImage(index)}
        >
          <Text style={styles.removeText}>✕</Text>
        </TouchableOpacity>
      )}

      {image.fileName && (
        <Text style={styles.imageName} numberOfLines={1}>
          {image.fileName}
        </Text>
      )}
    </View>
  );

  return (
    <View style={styles.container}>
      <Text style={styles.label}>
        Attachments ({images.length}/{maxImages})
      </Text>

      {uploading && (
        <View style={styles.uploadingContainer}>
          <ActivityIndicator size="large" color="#3498db" />
          <Text style={styles.uploadingText}>Processing image...</Text>
        </View>
      )}

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.imagesScrollContent}
      >
        {images.map(renderImageItem)}

        {!readonly && images.length < maxImages && (
          <TouchableOpacity style={styles.addButton} onPress={handleAddImage}>
            <Text style={styles.addButtonText}>+</Text>
            <Text style={styles.addButtonLabel}>Add Image</Text>
          </TouchableOpacity>
        )}
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginVertical: 8,
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
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: '#2c3e50',
    marginBottom: 12,
  },
  imagesScrollContent: {
    paddingVertical: 4,
  },
  imageContainer: {
    marginRight: 12,
    alignItems: 'center',
    position: 'relative',
  },
  imageThumb: {
    width: 80,
    height: 80,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#e1e8ed',
  },
  removeButton: {
    position: 'absolute',
    top: -8,
    right: -8,
    backgroundColor: '#e74c3c',
    width: 24,
    height: 24,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    borderColor: '#ffffff',
  },
  removeText: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '600',
  },
  imageName: {
    fontSize: 10,
    color: '#7f8c8d',
    marginTop: 4,
    maxWidth: 80,
  },
  addButton: {
    width: 80,
    height: 80,
    borderRadius: 8,
    borderWidth: 2,
    borderColor: '#e1e8ed',
    borderStyle: 'dashed',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#f8f9fa',
  },
  addButtonText: {
    fontSize: 28,
    color: '#3498db',
    fontWeight: '300',
  },
  addButtonLabel: {
    fontSize: 12,
    color: '#7f8c8d',
    marginTop: 4,
  },
  uploadingContainer: {
    alignItems: 'center',
    paddingVertical: 20,
  },
  uploadingText: {
    fontSize: 14,
    color: '#7f8c8d',
    marginTop: 8,
  },
});
```

---

### Step 4: Test Camera Integration

**Test camera functionality:**

- [ ] Camera permission request works
- [ ] Camera opens and captures photo
- [ ] Photo library opens and selects image
- [ ] Images are optimized
- [ ] Images are displayed
- [ ] Images can be removed

---

### Challenge Tasks

1. **Multiple Images:**
   - Allow multiple image selection
   - Show image gallery
   - Handle deletion of individual images

2. **Image Preview:**
   - Tap image to view full size
   - Add zoom and pan functionality

3. **Image Metadata:**
   - Display image dimensions
   - Display image file size

---

### Reflection Questions

1. What challenges did you face with camera permissions?
   ___________________________________________________________________
   ___________________________________________________________________

2. How did you handle image optimization?
   ___________________________________________________________________
   ___________________________________________________________________

3. What strategies would you use for large image files?
   ___________________________________________________________________
   ___________________________________________________________________

---

## Lab 3.2: Gestures & Animations

### Lab Objectives
- Implement swipe-to-delete
- Implement drag-to-reorder
- Implement custom pull-to-refresh
- Add haptic feedback

### Prerequisites
- Labs 1.1-3.1 completed
- Understanding of gesture concepts

---

### Step 1: Install Gesture Dependencies

```bash
npx expo install react-native-gesture-handler react-native-reanimated
npx expo install expo-haptics
```

**Add Reanimated plugin to babel.config.js:**

```js
module.exports = {
  presets: ['babel-preset-expo'],
  plugins: ['react-native-reanimated/plugin'],
};
```

---

### Step 2: Create Swipe-to-Delete Component

**Create `src/components/SwipeableTaskItem.tsx`:**

```tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Alert,
  Platform,
} from 'react-native';
import {
  GestureDetector,
  Gesture,
} from 'react-native-gesture-handler';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
  withTiming,
  runOnJS,
  interpolate,
  Extrapolate,
} from 'react-native-reanimated';
import * as Haptics from 'expo-haptics';

interface SwipeableTaskItemProps {
  children: React.ReactNode;
  onDelete: () => void;
  onEdit?: () => void;
  onSwipeLeft?: () => void;
  onSwipeRight?: () => void;
}

export const SwipeableTaskItem: React.FC<SwipeableTaskItemProps> = ({
  children,
  onDelete,
  onEdit,
  onSwipeLeft,
  onSwipeRight,
}) => {
  const translateX = useSharedValue(0);
  const [isSwiped, setIsSwiped] = useState(false);
  const swipeThreshold = 80;

  const handleSwipeComplete = (direction: 'left' | 'right') => {
    if (direction === 'left') {
      Alert.alert(
        'Delete Task',
        'Are you sure you want to delete this task?',
        [
          { text: 'Cancel', style: 'cancel', onPress: resetSwipe },
          {
            text: 'Delete',
            style: 'destructive',
            onPress: () => {
              Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
              onDelete();
            },
          },
        ]
      );
    } else if (direction === 'right') {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      onSwipeRight?.();
    }
  };

  const resetSwipe = () => {
    translateX.value = withSpring(0, { damping: 15, stiffness: 150 });
    setIsSwiped(false);
  };

  const panGesture = Gesture.Pan()
    .onUpdate((event) => {
      const newX = Math.min(Math.max(event.translationX, -200), 200);
      translateX.value = newX;

      if (Math.abs(newX) > swipeThreshold) {
        runOnJS(setIsSwiped)(true);
      } else {
        runOnJS(setIsSwiped)(false);
      }
    })
    .onEnd((event) => {
      const velocity = event.velocityX;
      const translation = event.translationX;

      const shouldComplete =
        Math.abs(translation) > swipeThreshold ||
        Math.abs(velocity) > 500;

      if (shouldComplete) {
        const direction = translation > 0 ? 'right' : 'left';
        runOnJS(handleSwipeComplete)(direction);
      } else {
        translateX.value = withSpring(0, {
          damping: 15,
          stiffness: 150,
          restDisplacementThreshold: 1,
          restSpeedThreshold: 1,
        });
        runOnJS(setIsSwiped)(false);
      }
    });

  const animatedStyle = useAnimatedStyle(() => {
    const bgColor = interpolate(
      translateX.value,
      [-200, -swipeThreshold, 0, swipeThreshold, 200],
      ['#e74c3c', '#e74c3c', '#ffffff', '#2ecc71', '#2ecc71'],
      Extrapolate.CLAMP
    );

    const scale = interpolate(
      Math.abs(translateX.value),
      [0, 200],
      [1, 0.95],
      Extrapolate.CLAMP
    );

    const rotation = interpolate(
      translateX.value,
      [-200, 0, 200],
      [-0.05, 0, 0.05],
      Extrapolate.CLAMP
    );

    return {
      transform: [
        { translateX: translateX.value },
        { scale },
        { rotate: `${rotation}rad` },
      ],
      backgroundColor: bgColor,
    };
  });

  const renderActions = () => (
    <View style={styles.actionsContainer}>
      <View style={[styles.action, styles.actionLeft]}>
        <Text style={styles.actionIcon}>✓</Text>
        <Text style={styles.actionLabel}>Complete</Text>
      </View>
      <View style={[styles.action, styles.actionRight]}>
        <Text style={styles.actionIcon}>🗑️</Text>
        <Text style={styles.actionLabel}>Delete</Text>
      </View>
    </View>
  );

  return (
    <View style={styles.wrapper}>
      {renderActions()}
      <GestureDetector gesture={panGesture}>
        <Animated.View style={[styles.container, animatedStyle]}>
          <TouchableOpacity
            style={styles.content}
            onPress={() => {
              if (!isSwiped) {
                onEdit?.();
              } else {
                resetSwipe();
              }
            }}
            activeOpacity={0.7}
          >
            {children}
          </TouchableOpacity>
        </Animated.View>
      </GestureDetector>
    </View>
  );
};

const styles = StyleSheet.create({
  wrapper: {
    marginVertical: 4,
    marginHorizontal: 16,
    borderRadius: 12,
    overflow: 'hidden',
  },
  container: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
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
  content: {
    padding: 16,
    backgroundColor: '#ffffff',
  },
  actionsContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    flexDirection: 'row',
    borderRadius: 12,
    overflow: 'hidden',
  },
  action: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  actionLeft: {
    backgroundColor: '#2ecc71',
    marginRight: 'auto',
  },
  actionRight: {
    backgroundColor: '#e74c3c',
    marginLeft: 'auto',
  },
  actionIcon: {
    color: '#ffffff',
    fontSize: 24,
  },
  actionLabel: {
    color: '#ffffff',
    fontSize: 12,
    marginTop: 2,
  },
});
```

---

### Step 3: Create Drag-to-Reorder Component

**Create `src/components/DragReorderList.tsx`:**

```tsx
import React, { useState } from 'react';
import {
  View,
  FlatList,
  StyleSheet,
  Platform,
} from 'react-native';
import {
  GestureDetector,
  Gesture,
} from 'react-native-gesture-handler';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
  withTiming,
  runOnJS,
} from 'react-native-reanimated';
import * as Haptics from 'expo-haptics';

interface DragItem {
  id: string;
  [key: string]: any;
}

interface DragReorderListProps<T extends DragItem> {
  data: T[];
  onReorder: (newData: T[]) => void;
  renderItem: (item: T, index: number) => React.ReactNode;
  keyExtractor?: (item: T) => string;
}

export function DragReorderList<T extends DragItem>({
  data,
  onReorder,
  renderItem,
  keyExtractor,
}: DragReorderListProps<T>) {
  const [items, setItems] = useState(data);
  const [draggingIndex, setDraggingIndex] = useState<number | null>(null);

  const handleReorder = (fromIndex: number, toIndex: number) => {
    if (fromIndex === toIndex) return;

    const newData = [...items];
    const [movedItem] = newData.splice(fromIndex, 1);
    newData.splice(toIndex, 0, movedItem);

    setItems(newData);
    onReorder(newData);
  };

  const renderDragItem = ({ item, index }: { item: T; index: number }) => {
    const translateY = useSharedValue(0);
    const scale = useSharedValue(1);
    const isDragging = useSharedValue(false);

    const gesture = Gesture.Pan()
      .onStart(() => {
        isDragging.value = true;
        scale.value = withSpring(1.05, { damping: 20, stiffness: 200 });
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
        runOnJS(setDraggingIndex)(index);
      })
      .onUpdate((event) => {
        translateY.value = event.translationY;

        const rowHeight = 80;
        const targetIndex = Math.round(
          index + event.translationY / rowHeight
        );
        const clampedIndex = Math.max(0, Math.min(items.length - 1, targetIndex));

        if (clampedIndex !== index) {
          runOnJS(handleReorder)(index, clampedIndex);
        }
      })
      .onEnd(() => {
        isDragging.value = false;
        translateY.value = withSpring(0, { damping: 20, stiffness: 200 });
        scale.value = withSpring(1, { damping: 20, stiffness: 200 });
        runOnJS(setDraggingIndex)(null);
      });

    const animatedStyle = useAnimatedStyle(() => ({
      transform: [
        { translateY: translateY.value },
        { scale: scale.value },
      ],
      zIndex: isDragging.value ? 100 : 1,
      opacity: isDragging.value ? 0.9 : 1,
    }));

    const shadowStyle = useAnimatedStyle(() => ({
      ...Platform.select({
        ios: {
          shadowOpacity: isDragging.value ? 0.3 : 0.05,
          shadowRadius: isDragging.value ? 12 : 4,
        },
        android: {
          elevation: isDragging.value ? 8 : 2,
        },
      }),
    }));

    return (
      <GestureDetector gesture={gesture}>
        <Animated.View style={[styles.itemWrapper, animatedStyle, shadowStyle]}>
          <View style={styles.dragHandle}>
            <Text style={styles.dragIcon}>⠿</Text>
          </View>
          <View style={styles.itemContent}>
            {renderItem(item, index)}
          </View>
        </Animated.View>
      </GestureDetector>
    );
  };

  return (
    <FlatList
      data={items}
      renderItem={renderDragItem}
      keyExtractor={keyExtractor || ((item: T) => item.id)}
      contentContainerStyle={styles.listContent}
      showsVerticalScrollIndicator={false}
    />
  );
}

const styles = StyleSheet.create({
  listContent: {
    padding: 8,
    paddingBottom: 20,
  },
  itemWrapper: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    marginBottom: 8,
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
  dragHandle: {
    position: 'absolute',
    left: 8,
    top: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 4,
    zIndex: 10,
  },
  dragIcon: {
    fontSize: 20,
    color: '#95a5a6',
  },
  itemContent: {
    paddingVertical: 12,
    paddingRight: 16,
    paddingLeft: 36,
  },
});
```

---

### Step 4: Create Custom Pull-to-Refresh

**Create `src/components/CustomPullToRefresh.tsx`:**

```tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Platform,
} from 'react-native';
import {
  GestureDetector,
  Gesture,
} from 'react-native-gesture-handler';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
  interpolate,
  Extrapolate,
  runOnJS,
} from 'react-native-reanimated';
import * as Haptics from 'expo-haptics';

interface CustomPullToRefreshProps {
  children: React.ReactNode;
  onRefresh: () => Promise<void>;
  refreshing?: boolean;
  threshold?: number;
  maxPullDistance?: number;
}

export const CustomPullToRefresh: React.FC<CustomPullToRefreshProps> = ({
  children,
  onRefresh,
  refreshing = false,
  threshold = 80,
  maxPullDistance = 150,
}) => {
  const translateY = useSharedValue(0);
  const isRefreshing = useSharedValue(false);
  const [isRefreshingState, setIsRefreshingState] = useState(false);

  const progress = useSharedValue(0);

  const panGesture = Gesture.Pan()
    .onUpdate((event) => {
      if (refreshing || isRefreshingState) return;

      if (translateY.value > -10) {
        const newY = Math.max(0, Math.min(event.translationY, maxPullDistance));
        translateY.value = newY;
        progress.value = Math.min(translateY.value / threshold, 1);
      }
    })
    .onEnd(() => {
      if (refreshing || isRefreshingState) return;

      const shouldRefresh = translateY.value > threshold;

      if (shouldRefresh) {
        isRefreshing.value = true;
        runOnJS(setIsRefreshingState)(true);
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);

        translateY.value = withSpring(threshold, {
          damping: 20,
          stiffness: 150,
        });

        runOnJS(handleRefresh)();
      } else {
        translateY.value = withSpring(0, {
          damping: 20,
          stiffness: 150,
        });
        progress.value = 0;
      }
    });

  const handleRefresh = async () => {
    await onRefresh();
    isRefreshing.value = false;
    runOnJS(setIsRefreshingState)(false);
    translateY.value = withSpring(0, {
      damping: 20,
      stiffness: 150,
    });
    progress.value = 0;
  };

  const containerStyle = useAnimatedStyle(() => ({
    transform: [{ translateY: translateY.value }],
  }));

  const indicatorStyle = useAnimatedStyle(() => {
    const rotate = interpolate(
      progress.value,
      [0, 1],
      [0, 360],
      Extrapolate.CLAMP
    );

    const scale = interpolate(
      progress.value,
      [0, 0.5, 1],
      [0.5, 1, 1.2],
      Extrapolate.CLAMP
    );

    return {
      transform: [{ rotate: `${rotate}deg` }, { scale }],
      opacity: progress.value,
    };
  });

  return (
    <GestureDetector gesture={panGesture}>
      <Animated.View style={[styles.scrollContainer, containerStyle]}>
        <View style={styles.indicatorContainer}>
          <Animated.View style={[styles.indicator, indicatorStyle]}>
            {refreshing || isRefreshingState ? (
              <View style={styles.spinner}>
                <View style={styles.spinnerDot} />
              </View>
            ) : (
              <Text style={styles.arrow}>⟳</Text>
            )}
          </Animated.View>
          <Text style={styles.indicatorText}>
            {refreshing || isRefreshingState
              ? 'Refreshing...'
              : progress.value === 1
              ? 'Release to refresh'
              : 'Pull to refresh'}
          </Text>
        </View>

        {children}
      </Animated.View>
    </GestureDetector>
  );
};

const styles = StyleSheet.create({
  scrollContainer: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  indicatorContainer: {
    position: 'absolute',
    top: -60,
    left: 0,
    right: 0,
    alignItems: 'center',
    justifyContent: 'center',
    height: 60,
  },
  indicator: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#ffffff',
    alignItems: 'center',
    justifyContent: 'center',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 8,
      },
      android: {
        elevation: 4,
      },
    }),
  },
  arrow: {
    fontSize: 28,
    color: '#3498db',
  },
  spinner: {
    width: 24,
    height: 24,
    borderRadius: 12,
    borderWidth: 3,
    borderColor: '#3498db',
    borderTopColor: 'transparent',
    alignItems: 'center',
    justifyContent: 'center',
  },
  spinnerDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: '#3498db',
  },
  indicatorText: {
    fontSize: 12,
    color: '#95a5a6',
    marginTop: 8,
  },
});
```

---

### Step 5: Update Task List with Gestures

**Update the tasks screen to use gesture components:**

```tsx
// src/screens/TasksScreen.tsx (partial)
import { SwipeableTaskItem } from '../components/SwipeableTaskItem';
import { DragReorderList } from '../components/DragReorderList';
import { CustomPullToRefresh } from '../components/CustomPullToRefresh';

// ... inside the component
const renderTask = ({ item, index }) => (
  <SwipeableTaskItem
    onDelete={() => handleDelete(item.id)}
    onEdit={() => handleEdit(item)}
    onSwipeRight={() => handleComplete(item)}
  >
    <TaskItem task={item} onPress={() => handlePress(item)} />
  </SwipeableTaskItem>
);

return (
  <CustomPullToRefresh onRefresh={handleRefresh}>
    <DragReorderList
      data={tasks}
      onReorder={handleReorder}
      renderItem={renderTask}
    />
  </CustomPullToRefresh>
);
```

---

### Challenge Tasks

1. **Custom Animation:**
   - Add spring animation on item delete
   - Add fade animation on item reorder

2. **Gesture Conflicts:**
   - Handle gesture conflicts between swipe and scroll
   - Implement gesture priority

3. **Accessibility:**
   - Add accessibility labels for gestures
   - Announce gesture actions for screen readers

---

### Reflection Questions

1. How do gestures improve the user experience?
   ___________________________________________________________________
   ___________________________________________________________________

2. What challenges did you face with gesture handling?
   ___________________________________________________________________
   ___________________________________________________________________

3. How did you handle gesture conflicts?
   ___________________________________________________________________
   ___________________________________________________________________

---

# PART 4: TESTING, PERFORMANCE & DEPLOYMENT

---

## Lab 4.1: Unit & Component Testing

### Lab Objectives
- Write unit tests for utilities
- Write component tests
- Write store tests
- Run tests in CI/CD

### Prerequisites
- Labs 1.1-3.2 completed
- Understanding of testing concepts

---

### Step 1: Install Testing Dependencies

```bash
npm install --save-dev @testing-library/react-native @testing-library/jest-native
npm install --save-dev @testing-library/react-hooks
npm install --save-dev @types/jest
```

---

### Step 2: Configure Jest

**Create `jest.config.js`:**

```javascript
module.exports = {
  preset: 'jest-expo',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  transformIgnorePatterns: [
    'node_modules/(?!(jest-)?react-native|@react-native|@react-navigation|expo|@expo|expo-notifications|expo-asset|expo-constants|@expo/vector-icons)',
  ],
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/index.ts',
    '!src/**/*.stories.tsx',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
};
```

---

### Step 3: Create Setup File

**Create `jest.setup.js`:**

```javascript
import '@testing-library/jest-native/extend-expect';

// Mock React Native modules
jest.mock('react-native/Libraries/Animated/NativeAnimatedHelper');

// Mock Expo modules
jest.mock('expo-notifications', () => ({
  addNotificationReceivedListener: jest.fn(),
  addNotificationResponseReceivedListener: jest.fn(),
  requestPermissionsAsync: jest.fn().mockResolvedValue({ status: 'granted' }),
  getPermissionsAsync: jest.fn().mockResolvedValue({ status: 'granted' }),
  scheduleNotificationAsync: jest.fn().mockResolvedValue('test-notification-id'),
  cancelScheduledNotificationAsync: jest.fn(),
  cancelAllScheduledNotificationsAsync: jest.fn(),
}));

jest.mock('expo-location', () => ({
  requestForegroundPermissionsAsync: jest.fn().mockResolvedValue({ status: 'granted' }),
  getCurrentPositionAsync: jest.fn().mockResolvedValue({
    coords: { latitude: 37.78825, longitude: -122.4324 },
    timestamp: Date.now(),
  }),
  reverseGeocodeAsync: jest.fn().mockResolvedValue([
    { street: 'Test St', city: 'Test City', region: 'Test Region', country: 'Test Country' },
  ]),
}));

jest.mock('expo-camera', () => ({
  requestCameraPermissionsAsync: jest.fn().mockResolvedValue({ status: 'granted' }),
  Camera: {
    Constants: {
      Type: { back: 'back', front: 'front' },
      FlashMode: { on: 'on', off: 'off' },
    },
  },
}));

jest.mock('expo-image-picker', () => ({
  launchCameraAsync: jest.fn().mockResolvedValue({
    canceled: false,
    assets: [{ uri: 'test-uri', width: 100, height: 100 }],
  }),
  launchImageLibraryAsync: jest.fn().mockResolvedValue({
    canceled: false,
    assets: [{ uri: 'test-uri', width: 100, height: 100 }],
  }),
  requestMediaLibraryPermissionsAsync: jest.fn().mockResolvedValue({ status: 'granted' }),
}));

jest.mock('expo-secure-store', () => ({
  setItemAsync: jest.fn().mockResolvedValue(undefined),
  getItemAsync: jest.fn().mockResolvedValue('test-token'),
  deleteItemAsync: jest.fn().mockResolvedValue(undefined),
}));

jest.mock('@react-native-async-storage/async-storage', () => ({
  setItem: jest.fn(),
  getItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
  getAllKeys: jest.fn(),
}));

jest.mock('react-native-mmkv', () => ({
  MMKV: jest.fn().mockImplementation(() => ({
    set: jest.fn(),
    getString: jest.fn(),
    getNumber: jest.fn(),
    getBoolean: jest.fn(),
    delete: jest.fn(),
    getAllKeys: jest.fn(),
    clearAll: jest.fn(),
  })),
}));

// Mock React Navigation
jest.mock('@react-navigation/native', () => ({
  ...jest.requireActual('@react-navigation/native'),
  useNavigation: () => ({
    navigate: jest.fn(),
    goBack: jest.fn(),
    replace: jest.fn(),
    reset: jest.fn(),
    canGoBack: jest.fn(() => true),
  }),
  useRoute: () => ({
    params: {},
  }),
}));
```

---

### Step 4: Write Unit Tests

**Create `src/__tests__/utils/validation.test.ts`:**

```typescript
import { validateEmail, validatePassword, validateTaskTitle } from '../../utils/validation';

describe('Validation Utilities', () => {
  describe('validateEmail', () => {
    it('validates correct email addresses', () => {
      expect(validateEmail('test@example.com')).toBe(true);
      expect(validateEmail('user.name@domain.co')).toBe(true);
      expect(validateEmail('test@sub.domain.com')).toBe(true);
    });

    it('rejects invalid email addresses', () => {
      expect(validateEmail('')).toBe(false);
      expect(validateEmail('test')).toBe(false);
      expect(validateEmail('test@')).toBe(false);
      expect(validateEmail('test@domain')).toBe(false);
    });
  });

  describe('validatePassword', () => {
    it('validates strong passwords', () => {
      expect(validatePassword('Password123!')).toBe(true);
      expect(validatePassword('SecurePass#2024')).toBe(true);
    });

    it('rejects weak passwords', () => {
      expect(validatePassword('')).toBe(false);
      expect(validatePassword('12345')).toBe(false);
      expect(validatePassword('password')).toBe(false);
      expect(validatePassword('pass123')).toBe(false);
    });
  });

  describe('validateTaskTitle', () => {
    it('validates valid titles', () => {
      expect(validateTaskTitle('Complete project')).toBe(true);
      expect(validateTaskTitle('Team meeting')).toBe(true);
      expect(validateTaskTitle('Review design mockups')).toBe(true);
    });

    it('rejects invalid titles', () => {
      expect(validateTaskTitle('')).toBe(false);
      expect(validateTaskTitle('  ')).toBe(false);
      expect(validateTaskTitle('ab')).toBe(false);
      expect(validateTaskTitle('a'.repeat(101))).toBe(false);
    });
  });
});
```

---

### Step 5: Write Component Tests

**Create `src/__tests__/components/TaskCard.test.tsx`:**

```tsx
import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import { TaskCard, Task } from '../../components/TaskCard';

const mockTask: Task = {
  id: '1',
  title: 'Test Task',
  description: 'Test Description',
  priority: 'high',
  status: 'todo',
  dueDate: '2024-12-20',
};

describe('TaskCard', () => {
  it('renders task information correctly', () => {
    const { getByText } = render(
      <TaskCard task={mockTask} />
    );

    expect(getByText('Test Task')).toBeTruthy();
    expect(getByText('Test Description')).toBeTruthy();
    expect(getByText('Due: 2024-12-20')).toBeTruthy();
  });

  it('calls onPress when tapped', () => {
    const onPress = jest.fn();
    const { getByTestId } = render(
      <TaskCard task={mockTask} onPress={onPress} />
    );

    fireEvent.press(getByTestId('task-card'));
    expect(onPress).toHaveBeenCalledWith(mockTask);
  });

  it('calls onStatusToggle when status button is pressed', () => {
    const onStatusToggle = jest.fn();
    const { getByTestId } = render(
      <TaskCard task={mockTask} onStatusToggle={onStatusToggle} />
    );

    fireEvent.press(getByTestId('status-toggle'));
    expect(onStatusToggle).toHaveBeenCalledWith(mockTask);
  });

  it('displays different colors for different priorities', () => {
    const priorities = ['low', 'medium', 'high'];
    const expectedColors = ['#2ecc71', '#f39c12', '#e74c3c'];

    priorities.forEach((priority, index) => {
      const task = { ...mockTask, priority: priority as any };
      const { getByTestId } = render(<TaskCard task={task} />);
      const priorityIndicator = getByTestId('priority-indicator');

      // Check style contains the expected color
      expect(priorityIndicator.props.style).toContainEqual(
        expect.objectContaining({ backgroundColor: expectedColors[index] })
      );
    });
  });
});
```

---

### Step 6: Write Store Tests

**Create `src/__tests__/stores/authStore.test.ts`:**

```tsx
import { act, renderHook } from '@testing-library/react-hooks';
import { useAuthStore } from '../../stores/authStore';

describe('AuthStore', () => {
  beforeEach(() => {
    act(() => {
      useAuthStore.setState({
        user: null,
        token: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,
      });
    });
  });

  it('should initialize with default values', () => {
    const { result } = renderHook(() => useAuthStore());

    expect(result.current.user).toBeNull();
    expect(result.current.token).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.isLoading).toBe(false);
    expect(result.current.error).toBeNull();
  });

  it('should handle successful login', async () => {
    const { result } = renderHook(() => useAuthStore());

    await act(async () => {
      await result.current.login('demo@example.com', 'password');
    });

    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.user).not.toBeNull();
    expect(result.current.user?.email).toBe('demo@example.com');
    expect(result.current.token).toBe('mock-jwt-token-12345');
    expect(result.current.error).toBeNull();
    expect(result.current.isLoading).toBe(false);
  });

  it('should handle login failure', async () => {
    const { result } = renderHook(() => useAuthStore());

    await act(async () => {
      try {
        await result.current.login('wrong@example.com', 'wrong');
      } catch (error) {
        // Expected error
      }
    });

    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.user).toBeNull();
    expect(result.current.token).toBeNull();
    expect(result.current.error).toBe('Invalid email or password');
    expect(result.current.isLoading).toBe(false);
  });

  it('should handle logout correctly', () => {
    const { result } = renderHook(() => useAuthStore());

    act(() => {
      result.current.logout();
    });

    expect(result.current.user).toBeNull();
    expect(result.current.token).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.error).toBeNull();
    expect(result.current.isLoading).toBe(false);
  });
});
```

---

### Step 7: Run Tests

```bash
# Run all tests
npm test

# Run tests with coverage
npm test -- --coverage

# Run tests in watch mode
npm test -- --watch

# Run specific test file
npm test -- src/__tests__/components/TaskCard.test.tsx
```

**Record your test results:**

```
Test Suites: ___ passed, ___ total
Tests: ___ passed, ___ total
Coverage: ___%
```

---

### Challenge Tasks

1. **Write Integration Tests:**
   - Test task creation flow
   - Test authentication flow

2. **Add Snapshot Tests:**
   - Capture snapshots of components
   - Verify UI consistency

3. **Set Up CI Testing:**
   - Configure GitHub Actions to run tests
   - Block merges on test failures

---

### Reflection Questions

1. What was the most challenging test to write?
   ___________________________________________________________________
   ___________________________________________________________________

2. How do you decide what to test?
   ___________________________________________________________________
   ___________________________________________________________________

3. What is the value of test coverage?
   ___________________________________________________________________
   ___________________________________________________________________

---

## Lab 4.2: Performance Optimization

### Lab Objectives
- Profile app performance
- Implement memoization
- Optimize FlatList
- Reduce bundle size

### Prerequisites
- Labs 1.1-4.1 completed
- Understanding of performance concepts

---

### Step 1: Profile with React DevTools

**Wrap component with Profiler:**

```tsx
import { Profiler } from 'react';

function App() {
  const onRender = (id, phase, actualDuration) => {
    if (actualDuration > 16) {
      console.warn(`⚠️ Slow render: ${id} took ${actualDuration}ms`);
    }
  };

  return (
    <Profiler id="App" onRender={onRender}>
      <MainNavigator />
    </Profiler>
  );
}
```

**Record performance metrics:**

| Component | Render Time | Re-renders | Notes |
|-----------|-------------|------------|-------|
| App | | | |
| TaskList | | | |
| TaskCard | | | |

---

### Step 2: Implement Memoization

**Optimize TaskCard with React.memo:**

```tsx
import React, { memo } from 'react';

export const TaskCard = memo(({ task, onPress, onStatusToggle }) => {
  // Component implementation
});

TaskCard.displayName = 'TaskCard';
```

**Optimize parent component:**

```tsx
import React, { useCallback, useMemo } from 'react';

function TaskList({ tasks, onTaskPress, onStatusToggle }) {
  // Memoize callbacks
  const handlePress = useCallback((task) => {
    onTaskPress(task);
  }, [onTaskPress]);

  const handleStatusToggle = useCallback((task) => {
    onStatusToggle(task);
  }, [onStatusToggle]);

  // Memoize filtered tasks
  const filteredTasks = useMemo(() => {
    return tasks.filter(task => task.status !== 'done');
  }, [tasks]);

  // Memoize renderItem
  const renderItem = useCallback(({ item }) => (
    <TaskCard
      task={item}
      onPress={handlePress}
      onStatusToggle={handleStatusToggle}
    />
  ), [handlePress, handleStatusToggle]);

  return (
    <FlatList
      data={filteredTasks}
      renderItem={renderItem}
      keyExtractor={(item) => item.id}
    />
  );
}
```

---

### Step 3: Optimize FlatList

```tsx
<FlatList
  data={tasks}
  renderItem={renderItem}
  keyExtractor={keyExtractor}

  // Performance optimizations
  removeClippedSubviews={Platform.OS === 'android'}
  maxToRenderPerBatch={10}
  updateCellsBatchingPeriod={50}
  windowSize={10}
  initialNumToRender={20}

  // getItemLayout for fixed heights
  getItemLayout={(data, index) => ({
    length: 80, // Item height
    offset: 80 * index,
    index,
  })}

  // Optimize scrolling
  scrollEventThrottle={16}
  decelerationRate="normal"

  // Enable recycling
  recycleItems
/>
```

---

### Step 4: Bundle Analysis

**Add bundle analysis scripts to package.json:**

```json
{
  "scripts": {
    "bundle:analyze": "npx expo export --platform ios --dump-sourcemap && npx source-map-explorer dist/bundles/*.js",
    "bundle:size": "npx expo export --platform ios && ls -lh dist/bundles/"
  }
}
```

**Record bundle sizes:**

| Before | After | Change |
|--------|-------|--------|
| ___ MB | ___ MB | ___ |

---

### Step 5: Image Optimization

**Implement image optimization:**

```tsx
import * as ImageManipulator from 'expo-image-manipulator';

const optimizeImage = async (uri: string) => {
  const result = await ImageManipulator.manipulateAsync(
    uri,
    [
      {
        resize: {
          width: 800,
          height: 800,
        },
      },
    ],
    {
      compress: 0.7,
      format: ImageManipulator.SaveFormat.JPEG,
    }
  );
  return result.uri;
};
```

**Use OptimizedImage component:**

```tsx
<Image
  source={{ uri: optimizedUri }}
  style={styles.image}
  resizeMode="cover"
  // Add loading and error handling
  onLoad={() => console.log('Image loaded')}
  onError={() => console.log('Error loading image')}
/>
```

---

### Step 6: Performance Checklist

**Complete performance checklist:**

- [ ] React DevTools shows < 10ms renders
- [ ] FlatList scrolling maintains 60fps
- [ ] Memory usage < 50MB
- [ ] App bundle size < 15MB
- [ ] Startup time < 2 seconds
- [ ] No memory leaks detected

---

### Challenge Tasks

1. **Implement Lazy Loading:**
   - Lazy load screens with React.lazy
   - Implement code splitting

2. **Add Performance Monitoring:**
   - Track FPS in production
   - Monitor memory usage

3. **Implement Caching:**
   - Cache images locally
   - Implement data caching

---

### Reflection Questions

1. What made the biggest performance improvement?
   ___________________________________________________________________
   ___________________________________________________________________

2. How do you identify performance bottlenecks?
   ___________________________________________________________________
   ___________________________________________________________________

3. What performance metrics are most important?
   ___________________________________________________________________
   ___________________________________________________________________

---

## Lab 4.3: Deployment

### Lab Objectives
- Configure EAS Build
- Set up GitHub Actions
- Prepare app store metadata
- Submit to stores

### Prerequisites
- Labs 1.1-4.2 completed
- Apple Developer account (iOS)
- Google Play Developer account (Android)

---

### Step 1: Configure EAS Build

**Install EAS CLI:**

```bash
npm install -g eas-cli
eas login
```

**Create `eas.json`:**

```json
{
  "cli": {
    "version": ">= 3.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "channel": "development",
      "ios": {
        "simulator": true
      },
      "android": {
        "buildType": "apk"
      }
    },
    "preview": {
      "distribution": "internal",
      "channel": "preview",
      "ios": {
        "simulator": false
      },
      "android": {
        "buildType": "apk"
      }
    },
    "production": {
      "distribution": "store",
      "channel": "production",
      "autoIncrement": true,
      "ios": {
        "image": "latest",
        "simulator": false,
        "resourceClass": "m1-medium"
      },
      "android": {
        "buildType": "app-bundle",
        "image": "latest",
        "resourceClass": "medium"
      },
      "env": {
        "APP_ENV": "production",
        "API_URL": "https://api.taskflow.app"
      }
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "$APPLE_ID",
        "ascAppId": "$ASC_APP_ID",
        "appleTeamId": "$APPLE_TEAM_ID"
      },
      "android": {
        "track": "production",
        "serviceAccountKeyPath": "./service-account-key.json",
        "packageName": "com.yourcompany.taskflow"
      }
    }
  }
}
```

---

### Step 2: Configure App Metadata

**Update `app.json`:**

```json
{
  "expo": {
    "name": "TaskFlow",
    "slug": "taskflow",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "userInterfaceStyle": "automatic",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "assetBundlePatterns": ["**/*"],
    "ios": {
      "supportsTablet": true,
      "bundleIdentifier": "com.yourcompany.taskflow",
      "buildNumber": "1",
      "infoPlist": {
        "NSCameraUsageDescription": "TaskFlow uses your camera to attach photos to tasks.",
        "NSPhotoLibraryUsageDescription": "TaskFlow uses your photo library to attach images to tasks.",
        "NSLocationWhenInUseUsageDescription": "TaskFlow uses your location to tag tasks with your current location."
      }
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#ffffff"
      },
      "package": "com.yourcompany.taskflow",
      "versionCode": 1,
      "permissions": [
        "android.permission.CAMERA",
        "android.permission.READ_EXTERNAL_STORAGE",
        "android.permission.WRITE_EXTERNAL_STORAGE",
        "android.permission.ACCESS_FINE_LOCATION"
      ]
    },
    "extra": {
      "eas": {
        "projectId": "your-project-id"
      }
    }
  }
}
```

---

### Step 3: Build Production

```bash
# Build for iOS
eas build --platform ios --profile production

# Build for Android
eas build --platform android --profile production

# Build for both
eas build --platform all --profile production
```

**Record build results:**

| Platform | Build Time | Status | Notes |
|----------|------------|--------|-------|
| iOS | ___ | | |
| Android | ___ | | |

---

### Step 4: Submit to Stores

```bash
# Submit to iOS App Store
eas submit --platform ios --profile production

# Submit to Android Google Play
eas submit --platform android --profile production
```

---

### Step 5: Deployment Checklist

- [ ] All tests passing
- [ ] Bundle size optimized
- [ ] App icon and splash screen ready
- [ ] Screenshots prepared
- [ ] Privacy policy available
- [ ] Support contact set up
- [ ] Code signing certificates valid
- [ ] App metadata complete

---

### Challenge Tasks

1. **Set Up CI/CD:**
   - Configure GitHub Actions
   - Automate builds on push to main

2. **Implement Rollback:**
   - Create rollback script
   - Document rollback procedures

3. **Post-Launch Monitoring:**
   - Set up Sentry for error tracking
   - Configure performance monitoring

---

### Reflection Questions

1. What was the most challenging part of deployment?
   ___________________________________________________________________
   ___________________________________________________________________

2. How would you improve the deployment process?
   ___________________________________________________________________
   ___________________________________________________________________

3. What monitoring would you set up for production?
   ___________________________________________________________________
   ___________________________________________________________________

---

# FINAL PROJECT: COMPLETE TASKFLOW APPLICATION

## Project Overview

Build a complete production-ready task management application incorporating all concepts learned in the course.

### Requirements

**Authentication:**
- Email/password login
- User registration
- Persistent session
- Logout functionality

**Task Management:**
- Create, read, update, delete tasks
- Task priority (low, medium, high)
- Task status (todo, in-progress, done)
- Task due date
- Task category
- Task description

**Offline-First:**
- Local storage with SQLite
- Sync engine with queue
- Conflict resolution
- Optimistic UI updates

**Device Features:**
- Camera for task attachments
- Photo library for images
- Push notifications for reminders
- Location tagging for tasks

**UI/UX:**
- Responsive design
- Gesture interactions (swipe, drag)
- Animations
- Accessibility support
- Dark/light theme

**Testing:**
- Unit tests (80% coverage)
- Component tests
- Integration tests
- E2E tests (critical flows)

**Deployment:**
- EAS Build configuration
- CI/CD pipeline
- App store submission

---

## Project Checklist

### Phase 1: Foundation (Week 1-2)
- [ ] Project setup with Expo
- [ ] Navigation configuration
- [ ] Core components
- [ ] Styling system

### Phase 2: State Management (Week 3-4)
- [ ] Auth store
- [ ] Task store
- [ ] UI store
- [ ] Store persistence

### Phase 3: Features (Week 5-6)
- [ ] Task CRUD
- [ ] Task filtering/search
- [ ] Offline sync
- [ ] Image attachments

### Phase 4: UI/UX (Week 7-8)
- [ ] Responsive design
- [ ] Gestures
- [ ] Animations
- [ ] Theming

### Phase 5: Testing (Week 9-10)
- [ ] Unit tests
- [ ] Component tests
- [ ] Integration tests
- [ ] E2E tests

### Phase 6: Deployment (Week 11-12)
- [ ] EAS Build
- [ ] CI/CD
- [ ] Store submission

---

## Project Evaluation

| Criteria | Weight | Score | Notes |
|----------|--------|-------|-------|
| Technical Implementation | 40% | | |
| UI/UX Quality | 20% | | |
| Code Quality & Testing | 20% | | |
| Performance Optimization | 10% | | |
| Deployment | 10% | | |

**Total Score:** ___ / 100

**Instructor Feedback:**
___________________________________________________________________
___________________________________________________________________

---

**[END OF LAB BOOK]**

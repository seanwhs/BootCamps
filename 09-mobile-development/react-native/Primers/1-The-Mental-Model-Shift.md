# Primer: React Native — The Mental Model Shift

Welcome to the **TaskFlow Tutorial Series Primer**. Before we dive into code, setup, and architecture, we need to talk about something more fundamental: **how to think about mobile development with React Native.**

If you're coming from web development (React, Vue, Angular), or even from native development (iOS/Android), React Native requires a **mental model shift**. This primer will help you make that shift before you write a single line of code.

---

## Table of Contents

1. [The Web vs. Mobile Divide](#the-web-vs-mobile-divide)
2. [React Native: What It Actually Is](#react-native-what-it-actually-is)
3. [The Bridge: Understanding the Communication Gap](#the-bridge-understanding-the-communication-gap)
4. [Threads: Where Code Actually Runs](#threads-where-code-actually-runs)
5. [Layout: The Shadow Tree](#layout-the-shadow-tree)
6. [Performance: Thinking in Frames](#performance-thinking-in-frames)
7. [State: Local vs. Global vs. Persisted](#state-local-vs-global-vs-persisted)
8. [The React Native Mindset](#the-react-native-mindset)

---

## The Web vs. Mobile Divide

### What's Different?

Let's start with a simple truth: **mobile is not web.**

On the web, you have a browser that handles rendering, layout, events, and networking. Your JavaScript runs in a single thread, and the browser does the heavy lifting of painting pixels on the screen.

On mobile, **there is no browser**. Your JavaScript code runs in a JavaScript engine, and it must communicate with the native operating system (iOS or Android) to render anything on screen. This communication is the source of both React Native's power and its complexity.

### The Mental Model Map

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEB DEVELOPMENT                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐      ┌───────────────────────────────────┐    │
│  │  Your Code  │─────▶│      Browser (single thread)     │    │
│  │  (React)    │      │  ┌─────────────┐ ┌─────────────┐│    │
│  └─────────────┘      │  │  Layout     │ │  Painting   ││    │
│                       │  └─────────────┘ └─────────────┘│    │
│                       └───────────────────────────────────┘    │
│                                                                 │
│  Everything happens in one place. One thread.                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   REACT NATIVE DEVELOPMENT                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐      ┌───────────────────────────────────┐    │
│  │  Your Code  │─────▶│   JavaScript Thread               │    │
│  │  (React)    │      │   (Runs your React components)    │    │
│  └─────────────┘      └──────────────┬────────────────────┘    │
│                                       │                         │
│                                      ┌▼┐                        │
│                                      │B│   ← The Bridge         │
│                                      │R│                        │
│                                      │I│                        │
│                                      │D│                        │
│                                      │G│                        │
│                                      │E│                        │
│                                      └▼┘                        │
│                                       │                         │
│  ┌─────────────────────────────────────┼─────────────────────┐  │
│  │                                     ▼                      │  │
│  │  ┌─────────────┐    ┌──────────────────────────────────┐ │  │
│  │  │  UI Thread  │    │  Shadow Thread                  │ │  │
│  │  │  (Native)   │    │  (Layout calculations)          │ │  │
│  │  └─────────────┘    └──────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Multiple threads. Communication via bridge.                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Key Differences at a Glance

| Aspect | Web | React Native |
|--------|-----|--------------|
| **Rendering** | Browser paints DOM | Native components render |
| **Threads** | Single thread | Multiple threads (JS, UI, Shadow) |
| **Layout** | CSS (flexbox, grid) | Yoga layout engine (flexbox) |
| **Events** | DOM events | Native gesture system |
| **Styling** | CSS | StyleSheet (CSS-like but different) |
| **Navigation** | URLs/History | Stack/Tab/Drawer navigators |
| **Networking** | XMLHttpRequest/Fetch | Same (Fetch, Axios) + native sockets |
| **Storage** | LocalStorage, IndexedDB | AsyncStorage, MMKV, SQLite |

---

## React Native: What It Actually Is

### The Framework's Identity

React Native is **not** a browser inside your phone. It's **not** a webview wrapper (like Cordova or Ionic). It's **not** a cross-platform interpreter.

**React Native is a bridge between React and native components.**

When you write:

```jsx
<View>
  <Text>Hello World</Text>
</View>
```

You're not writing HTML. You're writing instructions that tell React Native:
1. "I want a container" (`View` → native `UIView` on iOS, `ViewGroup` on Android)
2. "I want text inside it" (`Text` → native `UILabel` on iOS, `TextView` on Android)

React Native **translates** your React components into **real, native UI components** that run on the device.

### The React Native Promise

```
┌─────────────────────────────────────────────────────────────────┐
│                    THE REACT NATIVE PROMISE                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  "Write once, run anywhere"                                    │
│                                                                 │
│  ┌─────────────┐                                               │
│  │             │  ┌───────────────────────────────────────┐    │
│  │ Your React │──▶│  Runs on iOS                        │    │
│  │ Native     │  │  ┌────────────────────────────────┐  │    │
│  │ Code       │  │  │ Native iOS components          │  │    │
│  │             │  │  └────────────────────────────────┘  │    │
│  │             │  └───────────────────────────────────────┘    │
│  │             │  ┌───────────────────────────────────────┐    │
│  │             │──▶│  Runs on Android                   │    │
│  │             │  │  ┌────────────────────────────────┐  │    │
│  │             │  │  │ Native Android components      │  │    │
│  │             │  │  └────────────────────────────────┘  │    │
│  │             │  └───────────────────────────────────────┘    │
│  └─────────────┘                                               │
│                                                                 │
│  ONE codebase. TWO platforms. NATIVE performance.              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Bridge: Understanding the Communication Gap

### What Is the Bridge?

The **bridge** is the communication channel between your JavaScript code and the native platform. It's the most important concept to understand in React Native.

Think of the bridge like a translator between two people who speak different languages:

- **JavaScript** speaks one language (React/JSX)
- **Native** speaks another language (Swift/Objective-C on iOS, Java/Kotlin on Android)

The bridge translates messages between them. But translation is **not instant** and **not free**.

### How the Bridge Works

```
JavaScript Thread                    Native Threads
─────────────────────────────────────────────────────────────────
  ┌─────────────┐
  │             │
  │  "Create a  │
  │  button"    │
  │             │
  └──────┬──────┘
         │
         │  1. Serialize to JSON
         ▼
    ┌─────────────────────┐
    │  { type: "button",  │
    │    title: "Submit", │
    │    color: "blue" }  │
    └─────────────────────┘
         │
         │  2. Send across bridge (asynchronous)
         ▼
  ┌─────────────────────┐
  │                     │
  │  ┌───────────────┐  │  3. Deserialize JSON
  │  │ "button"       │  │
  │  │ "Submit"       │  │  4. Create native button
  │  │ "blue"         │  │
  │  └───────────────┘  │
  │                     │
  └─────────────────────┘
         │
         │  5. Native returns result
         ▼
    ┌─────────────────────┐
    │  { success: true,   │
    │    buttonId: "123" }│
    └─────────────────────┘
         │
         │  6. Send back to JS
         ▼
  ┌─────────────┐
  │             │
  │  "Button    │
  │  created!"  │
  │             │
  └─────────────┘
─────────────────────────────────────────────────────────────────
```

### The Bridge Is Asynchronous

This is crucial: **the bridge is asynchronous**. You cannot send a message across the bridge and expect an immediate response.

If your JavaScript code says:

```javascript
const result = NativeModule.someFunction();
// You CANNOT do this with synchronous calls across the bridge
```

The correct way is:

```javascript
NativeModule.someFunction((result) => {
  // This runs when the native module completes
  console.log(result);
});
```

### Bridge Traffic Is Expensive

Every time you send a message across the bridge, there's overhead:
- Serialization (JavaScript → JSON)
- Deserialization (JSON → Native)
- Thread synchronization
- Memory allocation

**Too much bridge traffic = poor performance.**

---

## Threads: Where Code Actually Runs

### The Three Threads

React Native uses three main threads:

```
┌─────────────────────────────────────────────────────────────────┐
│                       THE THREE THREADS                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. JavaScript Thread                                          │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Runs your React code                               │    │
│     │  Handles component rendering (Virtual DOM)          │    │
│     │  Processes business logic                           │    │
│     │  Makes API calls                                    │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  2. UI Thread (Native)                                         │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Handles all rendering                              │    │
│     │  Responds to user input (taps, swipes)             │    │
│     │  Runs animations                                    │    │
│     │  Manages the screen                                │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  3. Shadow Thread (Native)                                     │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Calculates layouts                                 │    │
│     │  Processes flexbox and positioning                  │    │
│     │  Measures text                                      │    │
│     └─────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Why This Matters

| Thread | What It Does | What Blocks It |
|--------|--------------|----------------|
| **JavaScript** | Your React code | Heavy JS computation |
| **UI Thread** | Rendering | Bridge traffic, layout calculation |
| **Shadow Thread** | Layout | Heavy layout work |

**Your goal:** Keep all threads working efficiently, and minimize the communication between them.

### The JavaScript Thread Is Single-Threaded

Just like in the browser, your JavaScript code runs on a single thread. Long-running JavaScript operations will block everything else:

```javascript
// ❌ BAD: This blocks the JavaScript thread for 2 seconds
function heavyComputation() {
  let sum = 0;
  for (let i = 0; i < 1000000000; i++) {
    sum += i;
  }
  return sum;
}

// ✅ GOOD: Break up heavy work
function heavyComputation() {
  let sum = 0;
  let i = 0;
  
  function step() {
    for (let j = 0; j < 100000; j++) {
      sum += i;
      i++;
    }
    if (i < 1000000000) {
      requestAnimationFrame(step);
    }
    return sum;
  }
  
  return step();
}
```

---

## Layout: The Shadow Tree

### The Layout Process

When you write a React Native component with flexbox:

```jsx
<View style={{ flexDirection: 'row' }}>
  <View style={{ flex: 1 }}>
    <Text>Left</Text>
  </View>
  <View style={{ flex: 1 }}>
    <Text>Right</Text>
  </View>
</View>
```

Here's what happens:

```
┌─────────────────────────────────────────────────────────────────┐
│                    THE LAYOUT PROCESS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. JavaScript Thread                                           │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  React renders component tree                       │    │
│     │  ┌─────────────────────────────────────────────┐    │    │
│     │  │ <View>                                     │    │    │
│     │  │   <View><Text>Left</Text></View>            │    │    │
│     │  │   <View><Text>Right</Text></View>           │    │    │
│     │  │ </View>                                    │    │    │
│     │  └─────────────────────────────────────────────┘    │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  2. Bridge (Send layout instructions to Shadow Thread)         │
│                              │                                  │
│                              ▼                                  │
│  3. Shadow Thread                                               │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Calculates positions and sizes                    │    │
│     │  ┌─────────────────────────────────────────────┐    │    │
│     │  │ <View x=0 y=0 w=375 h=812>                  │    │    │
│     │  │   <View x=0 y=0 w=187 h=812>                │    │    │
│     │  │     <Text x=0 y=0 w=187 h=20>Left</Text>    │    │    │
│     │  │   </View>                                   │    │    │
│     │  │   <View x=187 y=0 w=187 h=812>              │    │    │
│     │  │     <Text x=187 y=0 w=187 h=20>Right</Text> │    │    │
│     │  │   </View>                                   │    │    │
│     │  │ </View>                                     │    │    │
│     │  └─────────────────────────────────────────────┘    │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  4. UI Thread                                                   │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Renders pixels on screen                          │    │
│     │  ┌──────────────┐  ┌──────────────┐                │    │
│     │  │    Left      │  │    Right     │                │    │
│     │  │              │  │              │                │    │
│     │  └──────────────┘  └──────────────┘                │    │
│     └─────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### The Shadow Tree Is Async

The shadow tree calculation happens on a separate thread. This means:

1. Your JavaScript tells the shadow thread what to calculate
2. The shadow thread calculates
3. The shadow thread sends the result to the UI thread
4. The UI thread renders

**This is why flexbox in React Native is so powerful but also why layout changes can be expensive.**

### Layout Thrashing

If you constantly change layout properties, you're causing multiple passes through this pipeline. This is called **layout thrashing** and it kills performance.

```javascript
// ❌ BAD: Multiple layout passes
const [width, setWidth] = useState(100);

// On every frame:
setWidth(width + 1); // Causes layout recalculation

// ✅ GOOD: Animate using native driver
const animatedValue = useRef(new Animated.Value(100)).current;

Animated.timing(animatedValue, {
  toValue: 200,
  duration: 300,
  useNativeDriver: true, // Native driver = no JS thread involvement
}).start();
```

---

## Performance: Thinking in Frames

### The 60 FPS Target

Mobile screens refresh at **60 frames per second** (or 120 FPS on ProMotion devices). That means you have **16.67 milliseconds** to render each frame.

```
┌─────────────────────────────────────────────────────────────────┐
│                    60 FPS = 16.67ms per frame                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Frame 1 (16.67ms)     Frame 2 (16.67ms)     Frame 3          │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │ ████████████████ │  │ ████████████████ │  │ ████████████ │ │
│  │ ██     UI       │  │ ██     UI       │  │ ██   UI      │ │
│  │ ██    Render    │  │ ██    Render    │  │ ██  Render   │ │
│  │ ██              │  │ ██              │  │ ██           │ │
│  └──────────────────┘  └──────────────────┘  └──────────────┘ │
│                                                                 │
│  If your JavaScript or layout takes more than 16.67ms...        │
│                                                                 │
│  Frame 1 (20ms!)                                                │
│  ┌────────────────────────────────────────────────────┐         │
│  │ ████████████████████████████████████████████████████         │
│  │ ██    UI Render + Heavy JS                     ██         │
│  └────────────────────────────────────────────────────┘         │
│                                                                 │
│  ...you drop frames. Dropped frames = jank = bad UX.           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### What Causes Frame Drops?

1. **Heavy JavaScript execution** (blocking the JS thread)
2. **Excessive bridge traffic** (slow communication)
3. **Complex layout calculations** (blocking the shadow thread)
4. **Large images and memory** (slow painting)
5. **Many re-renders** (wasting CPU cycles)

### The Performance Mindset

When building React Native apps, **always think about frames**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    PERFORMANCE MINDSET                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  When you write code, ask:                                     │
│                                                                 │
│  1. "Will this block the JavaScript thread?"                   │
│     → If yes, move heavy work off the main thread              │
│                                                                 │
│  2. "Will this cause bridge traffic?"                          │
│     → If yes, batch your updates                               │
│                                                                 │
│  3. "Will this cause layout recalculations?"                   │
│     → If yes, use native animations instead                    │
│                                                                 │
│  4. "Will this cause re-renders?"                              │
│     → If yes, use memo and useMemo                            │
│                                                                 │
│  5. "Will this use a lot of memory?"                           │
│     → If yes, use virtualization and cleanup                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## State: Local vs. Global vs. Persisted

### The Three Types of State

In React Native, you'll manage three types of state:

```
┌─────────────────────────────────────────────────────────────────┐
│                    THREE TYPES OF STATE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Local State                                                │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  useState, useReducer                              │    │
│     │  Lives in a single component                       │    │
│     │  Example: "Is this modal open?"                    │    │
│     │  Example: "What's the current text input value?"   │    │
│     └─────────────────────────────────────────────────────┘    │
│                                                                 │
│  2. Global State                                               │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Zustand, Redux, Context                           │    │
│     │  Lives across the entire app                      │    │
│     │  Example: "Who is the current user?"               │    │
│     │  Example: "What tasks exist?"                     │    │
│     └─────────────────────────────────────────────────────┘    │
│                                                                 │
│  3. Persisted State                                            │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  AsyncStorage, MMKV, SQLite                       │    │
│     │  Lives between app sessions                       │    │
│     │  Example: "User preferences"                      │    │
│     │  Example: "Tasks created offline"                 │    │
│     └─────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### When to Use Each

| Type | When to Use | When NOT to Use |
|------|-------------|-----------------|
| **Local** | Component-specific state | State needed by multiple components |
| **Global** | State needed by many components | State that's only needed in one component |
| **Persisted** | Data that must survive app restarts | Transient data |

### The State Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    STATE FLOW IN TASKFLOW                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. User interacts with UI                                     │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Tap "Create Task" button                          │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  2. Local state updates                                        │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  formData changes, validation runs                 │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  3. Action dispatched to global store                         │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  useTaskStore.getState().addTask(newTask)         │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  4. Optimistic update                                         │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Task appears in list immediately                 │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  5. Persist locally                                            │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Task saved to SQLite for offline access            │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  6. Sync to server                                             │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Task sent to API in background                    │    │
│     └─────────────────────────────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  7. UI updates if needed                                      │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Success/failure notification shown to user        │    │
│     └─────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## The React Native Mindset

### Core Principles

```
┌─────────────────────────────────────────────────────────────────┐
│                    REACT NATIVE MINDSET                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Think in Components, Not Pages                             │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Every screen is composed of reusable components    │    │
│     │  Components should be small, focused, and testable │    │
│     └─────────────────────────────────────────────────────┘    │
│                                                                 │
│  2. Think Native First                                         │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Design for mobile gestures, not web clicks        │    │
│     │  Consider touch targets (44x44pt minimum)          │    │
│     │  Think about navigation patterns                  │    │
│     └─────────────────────────────────────────────────────┘    │
│                                                                 │
│  3. Think Performance                                           │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Every render costs something                      │    │
│     │  Every bridge call costs something                 │    │
│     │  Every layout recalculation costs something        │    │
│     │  Optimize early, optimize often                   │    │
│     └─────────────────────────────────────────────────────┘    │
│                                                                 │
│  4. Think Offline-First                                        │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  Your app should work without internet             │    │
│     │  Sync should be seamless and automatic             │    │
│     │  Users should never see "No internet" errors       │    │
│     └─────────────────────────────────────────────────────┘    │
│                                                                 │
│  5. Think Accessibility                                        │
│     ┌─────────────────────────────────────────────────────┐    │
│     │  All users should be able to use your app          │    │
│     │  Screen reader support is non-negotiable           │    │
│     │  Color contrast, touch targets, focus order       │    │
│     └─────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Ready for the Series

You now have the mental model needed to succeed with React Native. You understand:

- Why mobile is different from web
- What the bridge is and why it matters
- How threads work and what runs where
- Why layout is complex and how to optimize it
- How to think about performance in frames
- The three types of state and when to use them
- The mindset needed for React Native development


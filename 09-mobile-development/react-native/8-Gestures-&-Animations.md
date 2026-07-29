# Part 3: Device Capabilities & Native Interfacing
## Phase 2: Gestures & Animations

Welcome to the most visually exciting phase of the series! Your TaskFlow app is now feature-rich, but a great mobile app isn't just about functionality—it's about feel. In this phase, you'll master gestures and animations to create fluid, responsive, and delightful user experiences that rival native apps.

---

## Target 1: Understanding Gesture Handler & Reanimated

**The Target:** Master the React Native Gesture Handler and Reanimated libraries.

**The Concept:** Think of gestures as the conversation between your user's fingers and your app. Gesture Handler listens to this conversation, and Reanimated responds with buttery-smooth animations. Together, they create the illusion of physical interaction.

### Installation

```bash
# Core gesture and animation libraries
npx expo install react-native-gesture-handler react-native-reanimated

# For gesture handling
npx expo install react-native-gesture-handler

# For animations (we're using Reanimated 2)
npx expo install react-native-reanimated

# For UI feedback
npx expo install react-native-haptic-feedback
```

### Configuration

```typescript
// babel.config.js - Add Reanimated plugin
module.exports = {
  presets: ['babel-preset-expo'],
  plugins: ['react-native-reanimated/plugin'],
};
```

### Gesture Handler vs Reanimated: The Dynamic Duo

```typescript
// src/examples/GestureBasics.tsx
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  Platform,
} from 'react-native';
import {
  GestureDetector,
  Gesture,
  GestureHandlerRootView,
} from 'react-native-gesture-handler';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
  withTiming,
  withSequence,
  withDelay,
  runOnJS,
  Easing,
} from 'react-native-reanimated';

/**
 * GestureBasics - Demonstrates core gesture and animation patterns
 * 
 * This component showcases the fundamental building blocks
 * of gesture-driven animations in React Native.
 */
export const GestureBasics: React.FC = () => {
  // Shared values - the foundation of Reanimated
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);
  const scale = useSharedValue(1);
  const rotation = useSharedValue(0);
  const opacity = useSharedValue(1);

  // 1. Drag gesture - Basic pan
  const panGesture = Gesture.Pan()
    .onUpdate((event) => {
      translateX.value = event.translationX;
      translateY.value = event.translationY;
    })
    .onEnd(() => {
      // Spring back to original position
      translateX.value = withSpring(0);
      translateY.value = withSpring(0);
    });

  // 2. Tap gesture with haptic feedback
  const tapGesture = Gesture.Tap()
    .onStart(() => {
      // Animate with spring
      scale.value = withSpring(1.2, { damping: 10, stiffness: 200 });
    })
    .onEnd(() => {
      scale.value = withSpring(1);
    });

  // 3. Long press with sequence
  const longPressGesture = Gesture.LongPress()
    .minDuration(300)
    .onStart(() => {
      // Sequence: shrink → grow → rotate
      scale.value = withSequence(
        withTiming(0.8, { duration: 200 }),
        withTiming(1.2, { duration: 300 }),
        withTiming(1, { duration: 200 })
      );
      rotation.value = withSequence(
        withTiming(-0.2, { duration: 300 }),
        withTiming(0.2, { duration: 300 }),
        withTiming(0, { duration: 300 })
      );
    });

  // 4. Combined gestures
  const combinedGesture = Gesture.Simultaneous(
    Gesture.Pan()
      .onUpdate((event) => {
        translateX.value = event.translationX;
      })
      .onEnd(() => {
        translateX.value = withSpring(0);
      }),
    Gesture.Rotation()
      .onUpdate((event) => {
        rotation.value = event.rotation;
      })
      .onEnd(() => {
        rotation.value = withSpring(0);
      })
  );

  // Animated styles
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value },
      { scale: scale.value },
      { rotate: `${rotation.value}rad` },
    ],
    opacity: opacity.value,
  }));

  return (
    <GestureHandlerRootView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Gesture & Animation Basics</Text>

        {/* 1. Drag Demo */}
        <View style={styles.demoSection}>
          <Text style={styles.demoTitle}>1. Drag (Pan) Gesture</Text>
          <GestureDetector gesture={panGesture}>
            <Animated.View style={[styles.box, animatedStyle]}>
              <Text style={styles.boxText}>Drag Me</Text>
            </Animated.View>
          </GestureDetector>
        </View>

        {/* 2. Tap Demo */}
        <View style={styles.demoSection}>
          <Text style={styles.demoTitle}>2. Tap Gesture</Text>
          <GestureDetector gesture={tapGesture}>
            <Animated.View style={[styles.box, animatedStyle, { backgroundColor: '#2ecc71' }]}>
              <Text style={styles.boxText}>Tap Me</Text>
            </Animated.View>
          </GestureDetector>
        </View>

        {/* 3. Long Press Demo */}
        <View style={styles.demoSection}>
          <Text style={styles.demoTitle}>3. Long Press</Text>
          <GestureDetector gesture={longPressGesture}>
            <Animated.View style={[styles.box, animatedStyle, { backgroundColor: '#e74c3c' }]}>
              <Text style={styles.boxText}>Press & Hold</Text>
            </Animated.View>
          </GestureDetector>
        </View>

        {/* 4. Combined Demo */}
        <View style={styles.demoSection}>
          <Text style={styles.demoTitle}>4. Combined Gestures</Text>
          <GestureDetector gesture={combinedGesture}>
            <Animated.View style={[styles.box, animatedStyle, { backgroundColor: '#f39c12' }]}>
              <Text style={styles.boxText}>Drag & Rotate</Text>
            </Animated.View>
          </GestureDetector>
        </View>
      </View>
    </GestureHandlerRootView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  content: {
    flex: 1,
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 20,
    textAlign: 'center',
  },
  demoSection: {
    marginBottom: 30,
    alignItems: 'center',
  },
  demoTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#34495e',
    marginBottom: 10,
  },
  box: {
    width: 120,
    height: 120,
    backgroundColor: '#3498db',
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.15,
        shadowRadius: 8,
      },
      android: {
        elevation: 4,
      },
    }),
  },
  boxText: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '600',
    textAlign: 'center',
  },
});
```

---

## Target 2: Building Swipe-to-Delete

**The Target:** Implement a swipe-to-delete gesture for task items.

**The Concept:** Swipe-to-delete is a classic mobile pattern. Users swipe a list item to reveal a delete button, providing a satisfying and intuitive way to remove items.

### Swipeable Task Item

```typescript
// src/components/SwipeableTaskItem.tsx
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

interface Task {
  id: string;
  title: string;
  priority: 'low' | 'medium' | 'high';
  status: 'todo' | 'in-progress' | 'done';
  dueDate: string;
}

interface SwipeableTaskItemProps {
  task: Task;
  onDelete: (id: string) => void;
  onPress: (task: Task) => void;
  onSwipeLeft?: (task: Task) => void;
  onSwipeRight?: (task: Task) => void;
}

/**
 * SwipeableTaskItem - Task item with swipe gestures
 * 
 * This component demonstrates swipe-to-delete with:
 * - Left and right swipe actions
 * - Smooth spring animations
 * - Haptic feedback
 * - Action confirmation
 */
export const SwipeableTaskItem: React.FC<SwipeableTaskItemProps> = ({
  task,
  onDelete,
  onPress,
  onSwipeLeft,
  onSwipeRight,
}) => {
  const translateX = useSharedValue(0);
  const [isSwiped, setIsSwiped] = useState(false);
  const swipeThreshold = 80;

  // Get priority color
  const getPriorityColor = (priority: Task['priority']) => {
    switch (priority) {
      case 'high': return '#e74c3c';
      case 'medium': return '#f39c12';
      case 'low': return '#2ecc71';
      default: return '#95a5a6';
    }
  };

  // Handle swipe completion
  const handleSwipeComplete = (direction: 'left' | 'right') => {
    if (direction === 'left') {
      // Show delete confirmation
      Alert.alert(
        'Delete Task',
        `Are you sure you want to delete "${task.title}"?`,
        [
          { text: 'Cancel', style: 'cancel', onPress: () => resetSwipe() },
          { 
            text: 'Delete', 
            style: 'destructive',
            onPress: () => {
              onDelete(task.id);
            },
          },
        ]
      );
    } else if (direction === 'right') {
      onSwipeRight?.(task);
    }
  };

  // Reset swipe position
  const resetSwipe = () => {
    translateX.value = withSpring(0, { damping: 15, stiffness: 150 });
    setIsSwiped(false);
  };

  // Pan gesture for swipe
  const panGesture = Gesture.Pan()
    .onUpdate((event) => {
      // Constrain to left and right
      const newX = Math.min(Math.max(event.translationX, -200), 200);
      translateX.value = newX;
      
      // Update swipe state
      if (Math.abs(newX) > swipeThreshold) {
        runOnJS(setIsSwiped)(true);
      } else {
        runOnJS(setIsSwiped)(false);
      }
    })
    .onEnd((event) => {
      const velocity = event.velocityX;
      const translation = event.translationX;
      
      // Determine if swipe should complete
      const shouldComplete = 
        Math.abs(translation) > swipeThreshold || 
        Math.abs(velocity) > 500;

      if (shouldComplete) {
        const direction = translation > 0 ? 'right' : 'left';
        runOnJS(handleSwipeComplete)(direction);
      } else {
        // Reset position
        translateX.value = withSpring(0, { 
          damping: 15, 
          stiffness: 150,
          restDisplacementThreshold: 1,
          restSpeedThreshold: 1,
        });
        runOnJS(setIsSwiped)(false);
      }
    });

  // Animated styles
  const animatedStyle = useAnimatedStyle(() => {
    // Calculate background color based on swipe position
    const bgColor = interpolate(
      translateX.value,
      [-200, -swipeThreshold, 0, swipeThreshold, 200],
      ['#e74c3c', '#e74c3c', '#ffffff', '#2ecc71', '#2ecc71'],
      Extrapolate.CLAMP
    );

    // Scale effect during swipe
    const scale = interpolate(
      Math.abs(translateX.value),
      [0, 200],
      [1, 0.95],
      Extrapolate.CLAMP
    );

    // Rotation effect
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

  // Action buttons shown behind the item
  const renderActions = () => {
    return (
      <View style={styles.actionsContainer}>
        <View style={[styles.action, styles.actionLeft]}>
          <Text style={styles.actionText}>✓</Text>
          <Text style={styles.actionLabel}>Complete</Text>
        </View>
        <View style={[styles.action, styles.actionRight]}>
          <Text style={styles.actionText}>🗑️</Text>
          <Text style={styles.actionLabel}>Delete</Text>
        </View>
      </View>
    );
  };

  return (
    <View style={styles.wrapper}>
      {renderActions()}
      <GestureDetector gesture={panGesture}>
        <Animated.View style={[styles.container, animatedStyle]}>
          <TouchableOpacity
            style={styles.content}
            onPress={() => {
              if (!isSwiped) {
                onPress(task);
              } else {
                resetSwipe();
              }
            }}
            activeOpacity={0.7}
          >
            <View style={styles.priorityIndicator}>
              <View style={[
                styles.priorityDot,
                { backgroundColor: getPriorityColor(task.priority) }
              ]} />
            </View>

            <View style={styles.taskInfo}>
              <Text style={styles.taskTitle} numberOfLines={1}>
                {task.title}
              </Text>
              <Text style={styles.taskMeta}>
                Due: {task.dueDate} • {task.status.replace('-', ' ')}
              </Text>
            </View>

            <View style={styles.statusBadge}>
              <Text style={styles.statusText}>
                {task.status === 'done' ? '✓' : '○'}
              </Text>
            </View>
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
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    backgroundColor: '#ffffff',
  },
  priorityIndicator: {
    marginRight: 12,
  },
  priorityDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
  },
  taskInfo: {
    flex: 1,
  },
  taskTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: '#2c3e50',
    marginBottom: 4,
  },
  taskMeta: {
    fontSize: 12,
    color: '#7f8c8d',
  },
  statusBadge: {
    width: 30,
    height: 30,
    borderRadius: 15,
    backgroundColor: '#f8f9fa',
    alignItems: 'center',
    justifyContent: 'center',
  },
  statusText: {
    fontSize: 16,
    color: '#2c3e50',
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
  actionText: {
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

## Target 3: Building a Drag-to-Reorder List

**The Target:** Implement drag-to-reorder functionality for task lists.

**The Concept:** Drag-to-reorder allows users to prioritize tasks by dragging them up and down the list. This is a power user feature that dramatically improves productivity.

### Drag-to-Reorder Implementation

```typescript
// src/components/DragReorderList.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  FlatList,
  StyleSheet,
  Platform,
  TouchableOpacity,
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
  useDerivedValue,
} from 'react-native-reanimated';

interface Task {
  id: string;
  title: string;
  priority: 'low' | 'medium' | 'high';
  order: number;
}

interface DragReorderListProps {
  data: Task[];
  onReorder: (newData: Task[]) => void;
  renderItem: (item: Task, index: number) => React.ReactNode;
}

interface DragItemProps {
  item: Task;
  index: number;
  data: Task[];
  onReorder: (newData: Task[]) => void;
}

/**
 * DragItem - Individual draggable item
 * 
 * This component handles the drag gesture and visual feedback
 * during drag operations.
 */
const DragItem: React.FC<DragItemProps> = ({
  item,
  index,
  data,
  onReorder,
}) => {
  const translateY = useSharedValue(0);
  const scale = useSharedValue(1);
  const dragActive = useSharedValue(false);
  const [currentIndex, setCurrentIndex] = useState(index);

  // Get priority color
  const getPriorityColor = (priority: Task['priority']) => {
    switch (priority) {
      case 'high': return '#e74c3c';
      case 'medium': return '#f39c12';
      case 'low': return '#2ecc71';
      default: return '#95a5a6';
    }
  };

  // Handle reorder logic
  const handleReorder = (fromIndex: number, toIndex: number) => {
    if (fromIndex === toIndex) return;

    const newData = [...data];
    const [movedItem] = newData.splice(fromIndex, 1);
    newData.splice(toIndex, 0, movedItem);
    
    // Update order property
    const reordered = newData.map((item, idx) => ({
      ...item,
      order: idx,
    }));
    
    onReorder(reordered);
  };

  // Pan gesture for dragging
  const dragGesture = Gesture.Pan()
    .onStart(() => {
      dragActive.value = true;
      scale.value = withSpring(1.05, { damping: 20, stiffness: 200 });
      // Provide haptic feedback
      if (Platform.OS === 'ios') {
        // Haptic feedback - would use react-native-haptic-feedback
      }
    })
    .onUpdate((event) => {
      translateY.value = event.translationY;
      
      // Calculate target index based on position
      const rowHeight = 80; // Approximate height
      const targetIndex = Math.round(
        index + event.translationY / rowHeight
      );
      
      const clampedIndex = Math.max(0, Math.min(data.length - 1, targetIndex));
      
      if (clampedIndex !== currentIndex && clampedIndex !== index) {
        runOnJS(setCurrentIndex)(clampedIndex);
        runOnJS(handleReorder)(index, clampedIndex);
      }
    })
    .onEnd(() => {
      dragActive.value = false;
      translateY.value = withSpring(0, { damping: 20, stiffness: 200 });
      scale.value = withSpring(1, { damping: 20, stiffness: 200 });
      runOnJS(setCurrentIndex)(index);
    });

  // Animated styles
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateY: translateY.value },
      { scale: scale.value },
    ],
    zIndex: dragActive.value ? 100 : 1,
    opacity: dragActive.value ? 0.9 : 1,
  }));

  // Shadow effect when dragging
  const shadowStyle = useAnimatedStyle(() => ({
    ...Platform.select({
      ios: {
        shadowOpacity: dragActive.value ? 0.3 : 0.05,
        shadowRadius: dragActive.value ? 12 : 4,
      },
      android: {
        elevation: dragActive.value ? 8 : 2,
      },
    }),
  }));

  return (
    <GestureDetector gesture={dragGesture}>
      <Animated.View style={[styles.itemWrapper, animatedStyle, shadowStyle]}>
        <View style={styles.dragHandle}>
          <Text style={styles.dragIcon}>⠿</Text>
        </View>
        
        <View style={styles.itemContent}>
          <View style={styles.priorityIndicator}>
            <View style={[
              styles.priorityDot,
              { backgroundColor: getPriorityColor(item.priority) }
            ]} />
          </View>
          
          <Text style={styles.itemTitle}>{item.title}</Text>
          
          <View style={styles.orderBadge}>
            <Text style={styles.orderText}>{item.order + 1}</Text>
          </View>
        </View>
      </Animated.View>
    </GestureDetector>
  );
};

/**
 * DragReorderList - Main component for drag-to-reorder
 * 
 * This demonstrates how to implement drag-to-reorder
 * using Gesture Handler and Reanimated.
 */
export const DragReorderList: React.FC<DragReorderListProps> = ({
  data,
  onReorder,
  renderItem,
}) => {
  const [items, setItems] = useState(data);

  const handleReorder = (newItems: Task[]) => {
    setItems(newItems);
    onReorder(newItems);
  };

  const renderDragItem = ({ item, index }: { item: Task; index: number }) => {
    return (
      <DragItem
        item={item}
        index={index}
        data={items}
        onReorder={handleReorder}
      />
    );
  };

  return (
    <View style={styles.container}>
      <FlatList
        data={items}
        renderItem={renderDragItem}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.listContent}
        showsVerticalScrollIndicator={false}
        // Disable scroll when dragging
        scrollEnabled={true}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  listContent: {
    padding: 16,
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
  },
  dragIcon: {
    fontSize: 20,
    color: '#95a5a6',
  },
  itemContent: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 14,
    paddingRight: 16,
    paddingLeft: 36,
  },
  priorityIndicator: {
    marginRight: 12,
  },
  priorityDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
  },
  itemTitle: {
    flex: 1,
    fontSize: 16,
    color: '#2c3e50',
  },
  orderBadge: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: '#f1f2f6',
    alignItems: 'center',
    justifyContent: 'center',
  },
  orderText: {
    fontSize: 12,
    color: '#7f8c8d',
    fontWeight: '600',
  },
});
```

---

## Target 4: Building a Pull-to-Refresh Animation

**The Target:** Create a custom pull-to-refresh animation.

**The Concept:** Pull-to-refresh is a staple of mobile UX. We'll build a custom version with a circular progress indicator and a satisfying spring animation.

### Custom Pull-to-Refresh

```typescript
// src/components/CustomPullToRefresh.tsx
import React, { useState, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Platform,
  ActivityIndicator,
  FlatList,
  RefreshControl,
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
  interpolate,
  Extrapolate,
  useDerivedValue,
  runOnJS,
} from 'react-native-reanimated';
import * as Haptics from 'expo-haptics';

interface CustomPullToRefreshProps {
  children: React.ReactNode;
  onRefresh: () => Promise<void>;
  refreshing: boolean;
  threshold?: number;
  maxPullDistance?: number;
}

/**
 * CustomPullToRefresh - Custom pull-to-refresh implementation
 * 
 * This component demonstrates a custom pull-to-refresh
 * with smooth animations and haptic feedback.
 */
export const CustomPullToRefresh: React.FC<CustomPullToRefreshProps> = ({
  children,
  onRefresh,
  refreshing,
  threshold = 80,
  maxPullDistance = 150,
}) => {
  const translateY = useSharedValue(0);
  const isRefreshing = useSharedValue(false);
  const [isRefreshingState, setIsRefreshingState] = useState(false);

  // Progress for circular animation
  const progress = useDerivedValue(() => {
    return Math.min(translateY.value / threshold, 1);
  });

  // Pan gesture for pull
  const panGesture = Gesture.Pan()
    .onStart(() => {
      if (refreshing || isRefreshingState) {
        return;
      }
    })
    .onUpdate((event) => {
      if (refreshing || isRefreshingState) {
        return;
      }

      // Only allow downward pull at top of scroll
      if (translateY.value > -10) {
        const newY = Math.max(0, Math.min(event.translationY, maxPullDistance));
        translateY.value = newY;
      }
    })
    .onEnd((event) => {
      if (refreshing || isRefreshingState) {
        return;
      }

      const shouldRefresh = translateY.value > threshold;
      
      if (shouldRefresh) {
        // Trigger refresh
        isRefreshing.value = true;
        runOnJS(setIsRefreshingState)(true);
        
        // Haptic feedback
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
        
        // Animate to refresh state
        translateY.value = withSpring(threshold, {
          damping: 20,
          stiffness: 150,
        });
        
        // Call refresh
        runOnJS(handleRefresh)();
      } else {
        // Spring back
        translateY.value = withSpring(0, {
          damping: 20,
          stiffness: 150,
        });
      }
    });

  // Handle refresh completion
  const handleRefresh = async () => {
    await onRefresh();
    
    // Reset after refresh
    isRefreshing.value = false;
    runOnJS(setIsRefreshingState)(false);
    translateY.value = withSpring(0, {
      damping: 20,
      stiffness: 150,
    });
  };

  // Animated container style
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateY: translateY.value }],
  }));

  // Animated progress indicator style
  const progressStyle = useAnimatedStyle(() => {
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
    <View style={styles.container}>
      <GestureDetector gesture={panGesture}>
        <Animated.View style={[styles.scrollContainer, animatedStyle]}>
          {/* Refresh Indicator */}
          <View style={styles.indicatorContainer}>
            <Animated.View style={[styles.indicator, progressStyle]}>
              {refreshing || isRefreshingState ? (
                <ActivityIndicator size="large" color="#3498db" />
              ) : (
                <View style={styles.arrowContainer}>
                  <Text style={styles.arrow}>⟳</Text>
                </View>
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

          {/* Content */}
          {children}
        </Animated.View>
      </GestureDetector>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  scrollContainer: {
    flex: 1,
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
  arrowContainer: {
    width: 40,
    height: 40,
    alignItems: 'center',
    justifyContent: 'center',
  },
  arrow: {
    fontSize: 28,
    color: '#3498db',
  },
  indicatorText: {
    fontSize: 12,
    color: '#95a5a6',
    marginTop: 8,
  },
});

// Usage example with FlatList
export const PullToRefreshExample: React.FC = () => {
  const [refreshing, setRefreshing] = useState(false);
  const [data, setData] = useState(
    Array.from({ length: 20 }, (_, i) => `Item ${i + 1}`)
  );

  const handleRefresh = async () => {
    await new Promise(resolve => setTimeout(resolve, 1500));
    setData(prev => [`New Item ${Date.now()}`, ...prev]);
  };

  return (
    <CustomPullToRefresh
      onRefresh={handleRefresh}
      refreshing={refreshing}
    >
      <FlatList
        data={data}
        renderItem={({ item }) => (
          <View style={styles.listItem}>
            <Text style={styles.listItemText}>{item}</Text>
          </View>
        )}
        keyExtractor={(item, index) => `item-${index}`}
        contentContainerStyle={styles.listContent}
      />
    </CustomPullToRefresh>
  );
};

const pullStyles = StyleSheet.create({
  listContent: {
    padding: 16,
  },
  listItem: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
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
  listItemText: {
    fontSize: 16,
    color: '#2c3e50',
  },
});
```

---

## Target 5: Shared Element Transitions

**The Target:** Implement smooth shared element transitions between screens.

**The Concept:** Shared element transitions create a visual connection between screens—an image that expands, a card that transforms. This provides a premium, polished feel.

### Shared Element Transition with React Navigation

```typescript
// src/components/SharedElementTransition.tsx
import React, { useRef } from 'react';
import {
  View,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
  Platform,
} from 'react-native';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
  withTiming,
  runOnJS,
} from 'react-native-reanimated';
import { useNavigation } from '@react-navigation/native';

interface SharedElementProps {
  id: string;
  children: React.ReactNode;
  style?: any;
}

/**
 * SharedElement - Wrapper for elements that transition between screens
 * 
 * This component manages shared element transitions using
 * Reanimated and a global state.
 */
export class SharedElementManager {
  private static instance: SharedElementManager;
  private elements: Map<string, { ref: any; layout: any }> = new Map();
  private listeners: Map<string, Function> = new Map();

  static getInstance(): SharedElementManager {
    if (!SharedElementManager.instance) {
      SharedElementManager.instance = new SharedElementManager();
    }
    return SharedElementManager.instance;
  }

  registerElement(id: string, ref: any, layout: any) {
    this.elements.set(id, { ref, layout });
  }

  unregisterElement(id: string) {
    this.elements.delete(id);
  }

  getElement(id: string) {
    return this.elements.get(id);
  }

  startTransition(fromId: string, toId: string) {
    const from = this.elements.get(fromId);
    const to = this.elements.get(toId);
    
    if (from && to) {
      // Animate from element to to element
      const fromLayout = from.layout;
      const toLayout = to.layout;
      
      // Calculate scale and position differences
      const scaleX = toLayout.width / fromLayout.width;
      const scaleY = toLayout.height / fromLayout.height;
      
      // Trigger animations
      // This would be implemented with Reanimated
    }
  }
}

/**
 * SharedElementTransition - Example implementation
 * 
 * This demonstrates a shared element transition between
 * a list item and a detail screen.
 */
export const SharedElementExample: React.FC = () => {
  const navigation = useNavigation();

  const items = [
    { id: '1', title: 'Mountain View', color: '#3498db' },
    { id: '2', title: 'Ocean Sunset', color: '#e74c3c' },
    { id: '3', title: 'Forest Trail', color: '#2ecc71' },
  ];

  const handlePress = (item: any) => {
    navigation.navigate('Detail', { 
      item,
      // Shared element ID
      sharedId: `image-${item.id}`,
    });
  };

  return (
    <View style={sharedStyles.container}>
      <Text style={sharedStyles.title}>Shared Element Transition</Text>
      
      {items.map((item) => (
        <TouchableOpacity
          key={item.id}
          style={sharedStyles.card}
          onPress={() => handlePress(item)}
          activeOpacity={0.8}
        >
          <SharedElement id={`image-${item.id}`}>
            <View style={[sharedStyles.image, { backgroundColor: item.color }]}>
              <Text style={sharedStyles.imageText}>{item.title}</Text>
            </View>
          </SharedElement>
          <Text style={sharedStyles.cardTitle}>{item.title}</Text>
        </TouchableOpacity>
      ))}
    </View>
  );
};

const sharedStyles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 20,
    textAlign: 'center',
  },
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    marginBottom: 16,
    overflow: 'hidden',
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
  image: {
    height: 150,
    justifyContent: 'center',
    alignItems: 'center',
  },
  imageText: {
    color: '#ffffff',
    fontSize: 18,
    fontWeight: '600',
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: '#2c3e50',
    padding: 12,
  },
});

// Detail screen with shared element
export const DetailScreen: React.FC<{ route: any }> = ({ route }) => {
  const { item, sharedId } = route.params;
  const scale = useSharedValue(1);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  return (
    <View style={detailStyles.container}>
      <Animated.View style={[detailStyles.imageContainer, animatedStyle]}>
        <View style={[detailStyles.image, { backgroundColor: item.color }]}>
          <Text style={detailStyles.imageText}>{item.title}</Text>
        </View>
      </Animated.View>
      
      <Text style={detailStyles.detailTitle}>{item.title}</Text>
      <Text style={detailStyles.detailDescription}>
        This is a shared element transition example. The image expands
        from the list item to the detail screen.
      </Text>
    </View>
  );
};

const detailStyles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  imageContainer: {
    width: '100%',
    height: 300,
  },
  image: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  imageText: {
    color: '#ffffff',
    fontSize: 32,
    fontWeight: 'bold',
  },
  detailTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2c3e50',
    padding: 16,
    paddingBottom: 8,
  },
  detailDescription: {
    fontSize: 16,
    color: '#7f8c8d',
    padding: 16,
    paddingTop: 0,
    lineHeight: 24,
  },
});
```

---

## Target 6: Advanced Animations - Staggered List

**The Target:** Create a staggered list animation for loading tasks.

**The Concept:** Staggered animations bring life to lists by animating items one after another in a wave-like pattern. This creates a polished, professional feel.

### Staggered Animation Implementation

```typescript
// src/components/StaggeredTaskList.tsx
import React, { useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  Platform,
} from 'react-native';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withDelay,
  withSpring,
  withTiming,
  useDerivedValue,
  runOnJS,
} from 'react-native-reanimated';

interface Task {
  id: string;
  title: string;
  priority: 'low' | 'medium' | 'high';
  status: 'todo' | 'in-progress' | 'done';
  dueDate: string;
}

interface StaggeredTaskListProps {
  tasks: Task[];
  onTaskPress?: (task: Task) => void;
  animationDelay?: number;
  staggerDelay?: number;
}

/**
 * StaggeredTaskItem - Individual item with stagger animation
 */
const StaggeredTaskItem: React.FC<{
  task: Task;
  index: number;
  delay: number;
  onPress?: (task: Task) => void;
}> = ({ task, index, delay, onPress }) => {
  // Animation values
  const translateX = useSharedValue(50);
  const opacity = useSharedValue(0);
  const scale = useSharedValue(0.8);

  // Start animation on mount
  useEffect(() => {
    // Staggered animation with delay based on index
    translateX.value = withDelay(
      index * delay,
      withSpring(0, { damping: 15, stiffness: 150 })
    );
    opacity.value = withDelay(
      index * delay,
      withTiming(1, { duration: 400 })
    );
    scale.value = withDelay(
      index * delay,
      withSpring(1, { damping: 20, stiffness: 180 })
    );
  }, []);

  // Animated styles
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { scale: scale.value },
    ],
    opacity: opacity.value,
  }));

  const getPriorityColor = (priority: Task['priority']) => {
    switch (priority) {
      case 'high': return '#e74c3c';
      case 'medium': return '#f39c12';
      case 'low': return '#2ecc71';
      default: return '#95a5a6';
    }
  };

  return (
    <Animated.View style={[staggeredStyles.itemWrapper, animatedStyle]}>
      <View
        style={[
          staggeredStyles.item,
          { borderLeftColor: getPriorityColor(task.priority) },
        ]}
      >
        <View style={staggeredStyles.content}>
          <Text style={staggeredStyles.title}>{task.title}</Text>
          <View style={staggeredStyles.metaContainer}>
            <Text style={staggeredStyles.meta}>{task.status.replace('-', ' ')}</Text>
            <Text style={staggeredStyles.meta}>•</Text>
            <Text style={staggeredStyles.meta}>Due: {task.dueDate}</Text>
          </View>
        </View>
        <View style={[
          staggeredStyles.statusDot,
          { backgroundColor: task.status === 'done' ? '#2ecc71' : '#95a5a6' }
        ]} />
      </View>
    </Animated.View>
  );
};

/**
 * StaggeredTaskList - List with staggered enter animations
 * 
 * This component demonstrates how to create a list where
 * items animate in one after another with a staggered delay.
 */
export const StaggeredTaskList: React.FC<StaggeredTaskListProps> = ({
  tasks,
  onTaskPress,
  animationDelay = 150, // Delay between each item
  staggerDelay = 0, // Initial delay before animations start
}) => {
  const renderItem = ({ item, index }: { item: Task; index: number }) => (
    <StaggeredTaskItem
      task={item}
      index={index}
      delay={animationDelay}
      onPress={onTaskPress}
    />
  );

  return (
    <FlatList
      data={tasks}
      renderItem={renderItem}
      keyExtractor={(item) => item.id}
      contentContainerStyle={staggeredStyles.listContent}
      showsVerticalScrollIndicator={false}
    />
  );
};

const staggeredStyles = StyleSheet.create({
  listContent: {
    padding: 16,
    paddingBottom: 40,
  },
  itemWrapper: {
    marginBottom: 8,
  },
  item: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    flexDirection: 'row',
    alignItems: 'center',
    borderLeftWidth: 4,
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
    flex: 1,
  },
  title: {
    fontSize: 16,
    fontWeight: '500',
    color: '#2c3e50',
    marginBottom: 4,
  },
  metaContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  meta: {
    fontSize: 12,
    color: '#7f8c8d',
  },
  statusDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginLeft: 8,
  },
});
```

---

## Target 7: Haptic Feedback Integration

**The Target:** Add haptic feedback for tactile interactions.

**The Concept:** Haptic feedback provides physical sensations that enhance the user experience. Light taps, medium impacts, and notification patterns make interactions feel more real.

### Haptic Service

```typescript
// src/services/hapticService.ts
import * as Haptics from 'expo-haptics';
import { Platform } from 'react-native';

export type HapticType = 
  | 'light'
  | 'medium'
  | 'heavy'
  | 'success'
  | 'warning'
  | 'error'
  | 'selection'
  | 'impactLight'
  | 'impactMedium'
  | 'impactHeavy'
  | 'notificationSuccess'
  | 'notificationWarning'
  | 'notificationError';

/**
 * HapticService - Provides haptic feedback across the app
 * 
 * This service abstracts haptic feedback for consistent
 * tactile experiences across platforms.
 */
export class HapticService {
  private static instance: HapticService;

  private constructor() {}

  static getInstance(): HapticService {
    if (!HapticService.instance) {
      HapticService.instance = new HapticService();
    }
    return HapticService.instance;
  }

  /**
   * Trigger haptic feedback
   */
  trigger(type: HapticType): void {
    // Only available on physical devices
    if (Platform.OS === 'web') return;

    try {
      switch (type) {
        // Impact feedback
        case 'light':
        case 'impactLight':
          Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
          break;
        case 'medium':
        case 'impactMedium':
          Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
          break;
        case 'heavy':
        case 'impactHeavy':
          Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
          break;

        // Selection feedback
        case 'selection':
          Haptics.selectionAsync();
          break;

        // Notification feedback
        case 'success':
        case 'notificationSuccess':
          Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
          break;
        case 'warning':
        case 'notificationWarning':
          Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
          break;
        case 'error':
        case 'notificationError':
          Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
          break;

        default:
          console.warn(`Unknown haptic type: ${type}`);
      }
    } catch (error) {
      console.error('Haptic feedback error:', error);
    }
  }

  /**
   * Trigger haptic for common interactions
   */
  onPress(): void {
    this.trigger('impactLight');
  }

  onLongPress(): void {
    this.trigger('impactMedium');
  }

  onSuccess(): void {
    this.trigger('success');
  }

  onError(): void {
    this.trigger('error');
  }

  onSwipe(): void {
    this.trigger('selection');
  }

  onReorder(): void {
    this.trigger('light');
  }

  onRefresh(): void {
    this.trigger('medium');
  }

  /**
   * Custom haptic pattern (Android only for custom patterns)
   */
  customPattern(timings: number[]): void {
    // Android: Use React Native Haptic Feedback library
    // iOS: Not supported natively
    if (Platform.OS === 'android') {
      // Implementation would use Android's vibration API
    }
  }
}

export const haptic = HapticService.getInstance();
```

### Usage in Components

```typescript
// src/components/HapticButton.tsx
import React from 'react';
import { TouchableOpacity, TouchableOpacityProps } from 'react-native';
import { haptic } from '../services/hapticService';

interface HapticButtonProps extends TouchableOpacityProps {
  hapticType?: HapticType;
  children: React.ReactNode;
}

export const HapticButton: React.FC<HapticButtonProps> = ({
  hapticType = 'impactLight',
  onPress,
  children,
  ...props
}) => {
  const handlePress = (e: any) => {
    haptic.trigger(hapticType);
    onPress?.(e);
  };

  return (
    <TouchableOpacity {...props} onPress={handlePress}>
      {children}
    </TouchableOpacity>
  );
};
```

---

## Verification: Test Gestures and Animations

```bash
# Run the app
cd ~/projects/TaskFlow
expo start
```

### Gesture and Animation Checklist

1. **Gesture Basics:**
   - [ ] Drag gesture moves box smoothly
   - [ ] Tap gesture scales box
   - [ ] Long press triggers sequence animation
   - [ ] Combined gestures work simultaneously

2. **Swipe-to-Delete:**
   - [ ] Swipe right reveals delete action
   - [ ] Swipe left reveals complete action
   - [ ] Confirmation dialog appears
   - [ ] Item animates out on delete
   - [ ] Haptic feedback on swipe completion

3. **Drag-to-Reorder:**
   - [ ] Items can be dragged up and down
   - [ ] Visual feedback during drag
   - [ ] Reorder persists correctly
   - [ ] Haptic feedback on drag start

4. **Pull-to-Refresh:**
   - [ ] Pull down reveals refresh indicator
   - [ ] Circular progress animation
   - [ ] Release to refresh works
   - [ ] Content refreshes correctly

5. **Staggered Animation:**
   - [ ] Items animate in one by one
   - [ ] Smooth spring animation
   - [ ] Items appear in a wave pattern

6. **Haptic Feedback:**
   - [ ] Light impact on button press
   - [ ] Medium impact on long press
   - [ ] Success notification on completion
   - [ ] Selection feedback on swipe

---

## What We've Accomplished

Congratulations! Your TaskFlow app now feels truly native with gestures and animations:

1. **Gesture Handler Mastery:** Pan, tap, long press, and combined gestures
2. **Reanimated Animations:** Springs, timing, sequences, and interpolations
3. **Swipe-to-Delete:** Fluid swipe actions with confirmation
4. **Drag-to-Reorder:** Intuitive list reordering
5. **Pull-to-Refresh:** Custom refresh with progress animation
6. **Staggered Lists:** Wave-like enter animations
7. **Haptic Feedback:** Tactile user interactions

### What's Next: Part 4 - Testing, Performance & Production

In the final part, you'll learn:
- **Testing:** Unit tests, integration tests, and E2E testing
- **Performance:** Optimization strategies and profiling
- **CI/CD:** Automated builds and deployments
- **App Store:** Submitting to Apple App Store and Google Play

*Your app is now visually stunning and responds beautifully to user interactions! Next, we'll focus on making it bulletproof with comprehensive testing, optimizing performance, and deploying to the app stores. You're in the final stretch of becoming a complete React Native developer!*

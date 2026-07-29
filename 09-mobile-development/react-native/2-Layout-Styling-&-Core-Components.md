# Part 1: Foundations & Environment Architecture
## Phase 2: Layout, Styling & Core Components

Welcome back! Now that your environment is fully configured, it's time to build the visual foundation of TaskFlow. In this phase, you'll master React Native's styling system, understand mobile layout fundamentals, and build reusable components that will form the backbone of your application.

---

## Target 1: Understanding Flexbox in React Native

**The Target:** Master Flexbox layout for mobile app design.

**The Concept:** Think of Flexbox as a magic box that can arrange its children in any direction, automatically adjusting to different screen sizes. Unlike web development where you often use both Flexbox and Grid, React Native exclusively uses Flexbox—so mastering it is essential.

### The Flexbox Mental Model

Imagine you're organizing books on a shelf:

```
┌─────────────────────────────────────────────────────────────┐
│                    THE SHELF (Container)                    │
│                                                             │
│  flexDirection: 'row' (Horizontal arrangement)             │
│  ┌───────┐  ┌───────┐  ┌───────┐  ┌───────┐              │
│  │ Book1 │  │ Book2 │  │ Book3 │  │ Book4 │              │
│  └───────┘  └───────┘  └───────┘  └───────┘              │
│                                                             │
│  flexDirection: 'column' (Vertical arrangement)            │
│  ┌───────┐                                                 │
│  │ Book1 │                                                 │
│  ├───────┤                                                 │
│  │ Book2 │                                                 │
│  ├───────┤                                                 │
│  │ Book3 │                                                 │
│  ├───────┤                                                 │
│  │ Book4 │                                                 │
│  └───────┘                                                 │
└─────────────────────────────────────────────────────────────┘
```

### Core Flexbox Properties

Let's create a comprehensive demonstration of every Flexbox property:

```typescript
// src/screens/FlexboxDemo.tsx
import React from 'react';
import { View, Text, StyleSheet, ScrollView, Platform } from 'react-native';

/**
 * FlexboxDemo - A visual reference for all Flexbox properties
 * 
 * This component demonstrates every Flexbox property with visual examples.
 * Keep this file as a reference throughout your development journey.
 */
export const FlexboxDemo: React.FC = () => {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.sectionTitle}>Flexbox Fundamentals</Text>
      
      {/* flexDirection: row */}
      <View style={styles.propertyCard}>
        <Text style={styles.propertyName}>flexDirection: 'row'</Text>
        <View style={[styles.flexContainer, { flexDirection: 'row' }]}>
          <View style={[styles.box, { backgroundColor: '#e74c3c' }]} />
          <View style={[styles.box, { backgroundColor: '#2ecc71' }]} />
          <View style={[styles.box, { backgroundColor: '#3498db' }]} />
        </View>
      </View>

      {/* flexDirection: column */}
      <View style={styles.propertyCard}>
        <Text style={styles.propertyName}>flexDirection: 'column' (default)</Text>
        <View style={[styles.flexContainer, { flexDirection: 'column' }]}>
          <View style={[styles.box, { backgroundColor: '#e74c3c' }]} />
          <View style={[styles.box, { backgroundColor: '#2ecc71' }]} />
          <View style={[styles.box, { backgroundColor: '#3498db' }]} />
        </View>
      </View>

      {/* justifyContent: center */}
      <View style={styles.propertyCard}>
        <Text style={styles.propertyName}>justifyContent: 'center'</Text>
        <View style={[styles.flexContainer, { justifyContent: 'center' }]}>
          <View style={[styles.smallBox, { backgroundColor: '#e74c3c' }]} />
          <View style={[styles.smallBox, { backgroundColor: '#2ecc71' }]} />
        </View>
      </View>

      {/* justifyContent: space-between */}
      <View style={styles.propertyCard}>
        <Text style={styles.propertyName}>justifyContent: 'space-between'</Text>
        <View style={[styles.flexContainer, { justifyContent: 'space-between' }]}>
          <View style={[styles.smallBox, { backgroundColor: '#e74c3c' }]} />
          <View style={[styles.smallBox, { backgroundColor: '#2ecc71' }]} />
          <View style={[styles.smallBox, { backgroundColor: '#3498db' }]} />
        </View>
      </View>

      {/* alignItems: center */}
      <View style={styles.propertyCard}>
        <Text style={styles.propertyName}>alignItems: 'center'</Text>
        <View style={[styles.flexContainer, { alignItems: 'center' }]}>
          <View style={[styles.smallBox, { backgroundColor: '#e74c3c', height: 30 }]} />
          <View style={[styles.smallBox, { backgroundColor: '#2ecc71', height: 50 }]} />
          <View style={[styles.smallBox, { backgroundColor: '#3498db', height: 40 }]} />
        </View>
      </View>

      {/* flex: 1 (expands to fill space) */}
      <View style={styles.propertyCard}>
        <Text style={styles.propertyName}>flex: 1 (expands to fill space)</Text>
        <View style={[styles.flexContainer, { height: 120 }]}>
          <View style={[styles.flexBox, { flex: 1, backgroundColor: '#e74c3c' }]}>
            <Text style={styles.boxLabel}>flex: 1</Text>
          </View>
          <View style={[styles.flexBox, { flex: 2, backgroundColor: '#2ecc71' }]}>
            <Text style={styles.boxLabel}>flex: 2</Text>
          </View>
          <View style={[styles.flexBox, { flex: 1, backgroundColor: '#3498db' }]}>
            <Text style={styles.boxLabel}>flex: 1</Text>
          </View>
        </View>
      </View>

      {/* flexWrap */}
      <View style={styles.propertyCard}>
        <Text style={styles.propertyName}>flexWrap: 'wrap'</Text>
        <View style={[styles.flexContainer, { flexWrap: 'wrap', flexDirection: 'row' }]}>
          {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((item) => (
            <View 
              key={item} 
              style={[
                styles.wrapBox, 
                { backgroundColor: item % 2 === 0 ? '#3498db' : '#2ecc71' }
              ]}
            >
              <Text style={styles.boxLabel}>{item}</Text>
            </View>
          ))}
        </View>
      </View>

      {/* alignSelf */}
      <View style={styles.propertyCard}>
        <Text style={styles.propertyName}>alignSelf: 'flex-end'</Text>
        <View style={[styles.flexContainer, { alignItems: 'flex-start' }]}>
          <View style={[styles.smallBox, { backgroundColor: '#e74c3c' }]} />
          <View style={[styles.smallBox, { backgroundColor: '#2ecc71', alignSelf: 'flex-end' }]} />
          <View style={[styles.smallBox, { backgroundColor: '#3498db' }]} />
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
  contentContainer: {
    padding: 16,
    paddingBottom: 40,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 20,
    marginTop: 10,
    textAlign: 'center',
  },
  propertyCard: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
      },
      android: {
        elevation: 3,
      },
    }),
  },
  propertyName: {
    fontSize: 14,
    fontWeight: '600',
    color: '#34495e',
    marginBottom: 12,
    fontFamily: Platform.OS === 'ios' ? 'Menlo' : 'monospace',
  },
  flexContainer: {
    height: 100,
    backgroundColor: '#f1f2f6',
    borderRadius: 8,
    padding: 8,
  },
  box: {
    width: 50,
    height: 50,
    borderRadius: 8,
  },
  smallBox: {
    width: 40,
    height: 40,
    borderRadius: 6,
  },
  flexBox: {
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
    margin: 4,
  },
  wrapBox: {
    width: 45,
    height: 45,
    borderRadius: 6,
    justifyContent: 'center',
    alignItems: 'center',
    margin: 4,
  },
  boxLabel: {
    color: '#ffffff',
    fontSize: 12,
    fontWeight: '600',
  },
});
```

### The Flexbox Cheat Sheet

Save this mental model:

```typescript
// Flexbox Decision Tree
// 
// 1. Which direction?
//    flexDirection: 'row' → Horizontal
//    flexDirection: 'column' → Vertical (default)
// 
// 2. How to distribute space along the main axis?
//    justifyContent: 'flex-start' → Left/Top
//    justifyContent: 'center' → Center
//    justifyContent: 'flex-end' → Right/Bottom
//    justifyContent: 'space-between' → Evenly spaced
//    justifyContent: 'space-around' → Evenly spaced with half margins
//    justifyContent: 'space-evenly' → Evenly spaced with equal margins
// 
// 3. How to align along the cross axis?
//    alignItems: 'flex-start' → Top/Left
//    alignItems: 'center' → Center
//    alignItems: 'flex-end' → Bottom/Right
//    alignItems: 'stretch' → Fill container (default)
// 
// 4. How should items grow/shrink?
//    flex: 0 → Fixed size (default)
//    flex: 1 → Fill available space
//    flex: 2 → Take twice as much space as flex: 1
```

---

## Target 2: Responsive Design - Adapting to Any Screen

**The Target:** Build UIs that look great on every device, from iPhone SE to iPad Pro.

**The Concept:** Unlike web development where you can use media queries for different screen sizes, React Native requires a different approach. You'll use a combination of percentage-based sizing, flexbox, and dynamic calculations.

### Understanding Screen Dimensions

```typescript
// src/utils/dimensions.ts
import { Dimensions, Platform, PixelRatio } from 'react-native';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');

/**
 * ScreenUtils - Utility functions for responsive design
 * 
 * These utilities help create UIs that adapt to different screen sizes
 * without requiring complex media queries.
 */
export const ScreenUtils = {
  // Get screen width
  getScreenWidth: (): number => SCREEN_WIDTH,
  
  // Get screen height
  getScreenHeight: (): number => SCREEN_HEIGHT,
  
  // Check if device is a tablet (screen width >= 768)
  isTablet: (): boolean => SCREEN_WIDTH >= 768,
  
  // Check if device is a phone
  isPhone: (): boolean => SCREEN_WIDTH < 768,
  
  // Scale based on screen width (for responsive sizing)
  scaleSize: (size: number): number => {
    // Base design: 375px width (iPhone SE/8)
    const BASE_WIDTH = 375;
    const scale = SCREEN_WIDTH / BASE_WIDTH;
    return size * scale;
  },
  
  // Scale font sizes
  scaleFont: (size: number): number => {
    // Use PixelRatio for fine-tuned font scaling
    const scale = Math.min(
      SCREEN_WIDTH / 375,
      1.5 // Max scale
    );
    return Math.round(size * scale);
  },
  
  // Get safe area insets
  getSafeAreaInsets: async (): Promise<{ top: number; bottom: number }> => {
    // In a real app, you'd use react-native-safe-area-context
    // This is a simplified version
    return {
      top: Platform.OS === 'ios' ? 44 : 30,
      bottom: Platform.OS === 'ios' ? 34 : 16,
    };
  },
};

// Export responsive sizing functions for easy use
export const { scaleSize, scaleFont, isTablet, isPhone } = ScreenUtils;
```

### Building a Responsive Layout System

Let's create a complete responsive design system:

```typescript
// src/styles/responsive.ts
import { StyleSheet, Platform, Dimensions } from 'react-native';
import { scaleSize, scaleFont, isTablet } from '../utils/dimensions';

const { width } = Dimensions.get('window');

/**
 * ResponsiveDesign - A comprehensive responsive design system
 * 
 * This provides consistent spacing, sizing, and typography
 * that automatically adapts to any screen size.
 */
export const ResponsiveDesign = {
  // Spacing scale (based on 8px grid)
  spacing: {
    xs: scaleSize(4),
    sm: scaleSize(8),
    md: scaleSize(16),
    lg: scaleSize(24),
    xl: scaleSize(32),
    xxl: scaleSize(48),
    xxxl: scaleSize(64),
  },
  
  // Font sizes
  fontSize: {
    xs: scaleFont(10),
    sm: scaleFont(12),
    md: scaleFont(14),
    lg: scaleFont(16),
    xl: scaleFont(20),
    xxl: scaleFont(24),
    xxxl: scaleFont(32),
    display: scaleFont(40),
  },
  
  // Border radii
  borderRadius: {
    sm: scaleSize(4),
    md: scaleSize(8),
    lg: scaleSize(12),
    xl: scaleSize(16),
    round: 999,
  },
  
  // Layout constraints
  layout: {
    // Maximum width for content (centers on tablets)
    maxContentWidth: isTablet() ? 600 : '100%',
    // Padding for screen edges
    screenPadding: scaleSize(16),
    // Width of side drawer on tablets
    drawerWidth: Math.min(width * 0.75, 320),
  },
  
  // Breakpoints
  breakpoints: {
    phone: 375,
    phablet: 480,
    tablet: 768,
    desktop: 1024,
  },
};

/**
 * ResponsiveStyles - Helper to create responsive styles
 * 
 * Usage:
 * const styles = createResponsiveStyles({
 *   container: {
 *     padding: 16, // Will be scaled automatically
 *   },
 *   title: {
 *     fontSize: 24, // Will be scaled automatically
 *   },
 * });
 */
export const createResponsiveStyles = (styles: Record<string, any>) => {
  const scaledStyles: Record<string, any> = {};
  
  Object.entries(styles).forEach(([key, value]) => {
    if (typeof value === 'object' && !Array.isArray(value)) {
      const scaledValue: Record<string, any> = {};
      
      Object.entries(value).forEach(([propKey, propValue]) => {
        if (typeof propValue === 'number') {
          // Scale spacing and sizing properties
          if (['padding', 'margin', 'width', 'height', 'top', 'bottom', 'left', 'right'].some(
            p => propKey === p || propKey.startsWith(p)
          )) {
            scaledValue[propKey] = scaleSize(propValue);
          } else if (propKey === 'fontSize' || propKey === 'lineHeight') {
            scaledValue[propKey] = scaleFont(propValue);
          } else {
            scaledValue[propKey] = propValue;
          }
        } else {
          scaledValue[propKey] = propValue;
        }
      });
      
      scaledStyles[key] = scaledValue;
    } else {
      scaledStyles[key] = value;
    }
  });
  
  return StyleSheet.create(scaledStyles);
};
```

### Implementing a Responsive Card Component

Now let's build a component that demonstrates responsive design in action:

```typescript
// src/components/ResponsiveCard.tsx
import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Platform } from 'react-native';
import { ResponsiveDesign, createResponsiveStyles } from '../styles/responsive';
import { scaleSize } from '../utils/dimensions';

interface ResponsiveCardProps {
  title: string;
  subtitle?: string;
  onPress?: () => void;
  children?: React.ReactNode;
  variant?: 'default' | 'elevated' | 'outlined';
}

/**
 * ResponsiveCard - A card component that adapts to any screen size
 * 
 * This demonstrates how to build truly responsive components
 * that work well on phones and tablets.
 */
export const ResponsiveCard: React.FC<ResponsiveCardProps> = ({
  title,
  subtitle,
  onPress,
  children,
  variant = 'default',
}) => {
  // Determine card style based on variant
  const getCardStyle = () => {
    switch (variant) {
      case 'elevated':
        return styles.elevatedCard;
      case 'outlined':
        return styles.outlinedCard;
      default:
        return styles.defaultCard;
    }
  };

  // Different layouts for phone vs tablet
  const isTabletDevice = ResponsiveDesign.layout.maxContentWidth !== '100%';

  return (
    <TouchableOpacity 
      onPress={onPress} 
      activeOpacity={onPress ? 0.7 : 1}
      style={[
        styles.cardWrapper,
        isTabletDevice && styles.cardWrapperTablet,
      ]}
      disabled={!onPress}
    >
      <View style={[styles.card, getCardStyle()]}>
        <View style={styles.header}>
          <Text style={styles.title} numberOfLines={1}>
            {title}
          </Text>
          {subtitle && (
            <Text style={styles.subtitle} numberOfLines={2}>
              {subtitle}
            </Text>
          )}
        </View>
        
        {children && <View style={styles.content}>{children}</View>}
        
        {/* Show a subtle indicator if pressable */}
        {onPress && (
          <View style={styles.pressIndicator}>
            <Text style={styles.pressIndicatorText}>Tap to interact</Text>
          </View>
        )}
      </View>
    </TouchableOpacity>
  );
};

// Use createResponsiveStyles for automatic scaling
const styles = createResponsiveStyles({
  cardWrapper: {
    width: '100%',
    marginBottom: 16,
    paddingHorizontal: 8,
  },
  cardWrapperTablet: {
    width: '48%', // Two cards per row on tablets
    marginHorizontal: '1%',
  },
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 20,
    minHeight: 120,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 8,
      },
      android: {
        elevation: 2,
      },
    }),
  },
  defaultCard: {
    backgroundColor: '#ffffff',
    borderWidth: 0,
  },
  elevatedCard: {
    backgroundColor: '#ffffff',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.15,
        shadowRadius: 12,
      },
      android: {
        elevation: 8,
      },
    }),
  },
  outlinedCard: {
    backgroundColor: '#ffffff',
    borderWidth: 1,
    borderColor: '#e1e8ed',
  },
  header: {
    marginBottom: 8,
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 14,
    color: '#7f8c8d',
    lineHeight: 20,
  },
  content: {
    marginTop: 8,
  },
  pressIndicator: {
    marginTop: 12,
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#f0f0f0',
  },
  pressIndicatorText: {
    fontSize: 12,
    color: '#95a5a6',
    textAlign: 'center',
  },
});
```

### Verification: Test Responsive Behavior

Create a test screen to verify responsive design:

```typescript
// src/screens/ResponsiveTestScreen.tsx
import React from 'react';
import { View, Text, ScrollView, StyleSheet } from 'react-native';
import { ResponsiveCard } from '../components/ResponsiveCard';
import { ScreenUtils } from '../utils/dimensions';
import { ResponsiveDesign } from '../styles/responsive';

export const ResponsiveTestScreen: React.FC = () => {
  const screenWidth = ScreenUtils.getScreenWidth();
  const isTablet = ScreenUtils.isTablet();

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Responsive Design Test</Text>
      
      <View style={styles.infoCard}>
        <Text style={styles.infoText}>Screen Width: {screenWidth}px</Text>
        <Text style={styles.infoText}>Device Type: {isTablet ? 'Tablet' : 'Phone'}</Text>
        <Text style={styles.infoText}>Scale Factor: {(screenWidth / 375).toFixed(2)}x</Text>
      </View>

      <View style={styles.cardGrid}>
        <ResponsiveCard 
          title="Task Management"
          subtitle="Organize your tasks efficiently with our intuitive interface"
        />
        <ResponsiveCard 
          title="Offline Sync"
          subtitle="Work seamlessly even without an internet connection"
          variant="elevated"
        />
        <ResponsiveCard 
          title="Collaboration"
          subtitle="Share tasks and work together with your team"
          variant="outlined"
        />
        <ResponsiveCard 
          title="Analytics"
          subtitle="Track your productivity with detailed insights"
          variant="elevated"
        />
      </View>

      <View style={styles.spacingDemo}>
        <Text style={styles.sectionLabel}>Responsive Spacing Demo</Text>
        <View style={styles.spacingRow}>
          <View style={styles.spacingBox} />
          <View style={[styles.spacingBox, { width: ResponsiveDesign.spacing.xl }]} />
          <View style={[styles.spacingBox, { width: ResponsiveDesign.spacing.xxl }]} />
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
  contentContainer: {
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 20,
    textAlign: 'center',
  },
  infoCard: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 20,
    alignItems: 'center',
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
  infoText: {
    fontSize: 14,
    color: '#34495e',
    marginVertical: 2,
  },
  cardGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  spacingDemo: {
    marginTop: 20,
    padding: 16,
    backgroundColor: '#ffffff',
    borderRadius: 12,
  },
  sectionLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 12,
  },
  spacingRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  spacingBox: {
    height: 40,
    backgroundColor: '#3498db',
    borderRadius: 8,
  },
});
```

---

## Target 3: Safe Area Handling - Notches, Status Bars, and Navigation

**The Target:** Properly handle device notches, status bars, and home indicators.

**The Concept:** Modern phones have notches, punch holes, and rounded corners that can obscure your content. Safe area handling ensures your UI stays visible and usable on any device.

### Setting Up Safe Area Context

First, install the required packages:

```bash
# Install safe area packages
npx expo install react-native-safe-area-context react-native-screens
```

### Creating a Safe Area Wrapper

```typescript
// src/components/SafeAreaWrapper.tsx
import React from 'react';
import { SafeAreaView, View, StyleSheet, Platform, StatusBar } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

interface SafeAreaWrapperProps {
  children: React.ReactNode;
  edges?: ('top' | 'bottom' | 'left' | 'right')[];
  backgroundColor?: string;
  statusBarStyle?: 'light' | 'dark' | 'auto';
  statusBarBackground?: string;
}

/**
 * SafeAreaWrapper - Handles safe areas across all devices
 * 
 * This wrapper ensures your content is never hidden by notches,
 * status bars, home indicators, or navigation bars.
 */
export const SafeAreaWrapper: React.FC<SafeAreaWrapperProps> = ({
  children,
  edges = ['top', 'bottom', 'left', 'right'],
  backgroundColor = '#f8f9fa',
  statusBarStyle = 'dark',
  statusBarBackground = '#f8f9fa',
}) => {
  const insets = useSafeAreaInsets();

  // Calculate padding based on which edges to respect
  const getPadding = () => {
    const padding: {
      paddingTop?: number;
      paddingBottom?: number;
      paddingLeft?: number;
      paddingRight?: number;
    } = {};

    if (edges.includes('top')) padding.paddingTop = insets.top;
    if (edges.includes('bottom')) padding.paddingBottom = insets.bottom;
    if (edges.includes('left')) padding.paddingLeft = insets.left;
    if (edges.includes('right')) padding.paddingRight = insets.right;

    return padding;
  };

  // Configure status bar based on platform
  React.useEffect(() => {
    if (Platform.OS === 'android') {
      StatusBar.setBackgroundColor(statusBarBackground);
    }
    StatusBar.setBarStyle(
      statusBarStyle === 'light' 
        ? 'light-content' 
        : statusBarStyle === 'dark' 
        ? 'dark-content' 
        : 'default'
    );
  }, [statusBarStyle, statusBarBackground]);

  return (
    <SafeAreaView 
      style={[
        styles.safeArea,
        { backgroundColor },
        getPadding(),
      ]}
    >
      {children}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
  },
});

// Skeleton loader that uses the safe area wrapper
export const SafeAreaSkeleton: React.FC = () => {
  return (
    <SafeAreaWrapper>
      <View style={styles.skeletonContainer}>
        <View style={styles.skeletonHeader} />
        <View style={styles.skeletonContent}>
          <View style={styles.skeletonLine} />
          <View style={styles.skeletonLine} />
          <View style={[styles.skeletonLine, { width: '60%' }]} />
        </View>
      </View>
    </SafeAreaWrapper>
  );
};

const skeletonStyles = StyleSheet.create({
  skeletonContainer: {
    flex: 1,
    padding: 16,
  },
  skeletonHeader: {
    height: 40,
    backgroundColor: '#e1e8ed',
    borderRadius: 8,
    marginBottom: 20,
  },
  skeletonContent: {
    flex: 1,
  },
  skeletonLine: {
    height: 16,
    backgroundColor: '#e1e8ed',
    borderRadius: 4,
    marginBottom: 12,
  },
});
```

### Creating a Custom Status Bar Component

```typescript
// src/components/CustomStatusBar.tsx
import React from 'react';
import { View, Text, StyleSheet, Platform, StatusBar } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { scaleSize } from '../utils/dimensions';

interface CustomStatusBarProps {
  title: string;
  backgroundColor?: string;
  textColor?: string;
  showBackButton?: boolean;
  onBackPress?: () => void;
  rightComponent?: React.ReactNode;
}

/**
 * CustomStatusBar - A customizable status bar component
 * 
 * This provides a consistent header across your app that
 * properly handles safe areas and status bar insets.
 */
export const CustomStatusBar: React.FC<CustomStatusBarProps> = ({
  title,
  backgroundColor = '#ffffff',
  textColor = '#2c3e50',
  showBackButton = false,
  onBackPress,
  rightComponent,
}) => {
  const insets = useSafeAreaInsets();

  return (
    <>
      {/* Status bar spacer (for Android) */}
      <View style={[styles.statusBarSpacer, { height: insets.top }]} />
      
      {/* Main header */}
      <View style={[
        styles.header,
        { backgroundColor },
        { paddingTop: Platform.OS === 'ios' ? insets.top : 0 },
      ]}>
        <View style={styles.headerContent}>
          <View style={styles.leftContainer}>
            {showBackButton && (
              <View style={styles.backButton}>
                <Text onPress={onBackPress} style={[styles.backText, { color: textColor }]}>
                  ←
                </Text>
              </View>
            )}
          </View>
          
          <Text style={[styles.title, { color: textColor }]}>
            {title}
          </Text>
          
          <View style={styles.rightContainer}>
            {rightComponent}
          </View>
        </View>
      </View>
    </>
  );
};

const styles = StyleSheet.create({
  statusBarSpacer: {
    backgroundColor: 'transparent',
  },
  header: {
    paddingHorizontal: 16,
    paddingBottom: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 2,
      },
      android: {
        elevation: 2,
      },
    }),
  },
  headerContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    minHeight: 44,
  },
  leftContainer: {
    width: 44,
    justifyContent: 'center',
  },
  backButton: {
    width: 40,
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 20,
    backgroundColor: 'rgba(0,0,0,0.05)',
  },
  backText: {
    fontSize: 24,
    fontWeight: '300',
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    textAlign: 'center',
    flex: 1,
  },
  rightContainer: {
    width: 44,
    justifyContent: 'center',
    alignItems: 'flex-end',
  },
});
```

---

## Target 4: Core Components Deep Dive

**The Target:** Master React Native's foundational components.

**The Concept:** These components are the building blocks of every React Native app. Understanding them thoroughly is essential for building complex UIs.

### View - The Universal Container

```typescript
// src/components/ViewExamples.tsx
import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';

export const ViewExamples: React.FC = () => {
  return (
    <ScrollView style={styles.container}>
      {/* Basic View */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>1. Basic View</Text>
        <View style={styles.basicView}>
          <Text>I'm inside a View</Text>
        </View>
      </View>

      {/* View with Borders */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>2. View with Borders</Text>
        <View style={styles.borderedView}>
          <Text>Bordered View</Text>
        </View>
      </View>

      {/* View with Shadow */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>3. View with Shadow</Text>
        <View style={styles.shadowView}>
          <Text>I have a shadow</Text>
        </View>
      </View>

      {/* Nested Views */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>4. Nested Views</Text>
        <View style={styles.parentView}>
          <View style={styles.childView}>
            <Text>Child 1</Text>
          </View>
          <View style={[styles.childView, { backgroundColor: '#2ecc71' }]}>
            <Text>Child 2</Text>
          </View>
          <View style={[styles.childView, { backgroundColor: '#3498db' }]}>
            <Text>Child 3</Text>
          </View>
        </View>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
    padding: 16,
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 12,
  },
  basicView: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 8,
  },
  borderedView: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 8,
    borderWidth: 2,
    borderColor: '#3498db',
    borderStyle: 'dashed',
  },
  shadowView: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 8,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.15,
        shadowRadius: 8,
      },
      android: {
        elevation: 6,
      },
    }),
  },
  parentView: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    padding: 8,
    backgroundColor: '#f1f2f6',
    borderRadius: 8,
  },
  childView: {
    flex: 1,
    margin: 4,
    padding: 12,
    backgroundColor: '#e74c3c',
    borderRadius: 8,
    alignItems: 'center',
  },
});
```

### Text - Displaying Information

```typescript
// src/components/TextExamples.tsx
import React from 'react';
import { View, Text, StyleSheet, ScrollView, Platform } from 'react-native';

export const TextExamples: React.FC = () => {
  return (
    <ScrollView style={styles.container}>
      {/* Basic Text */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>1. Basic Text</Text>
        <Text>This is basic text</Text>
      </View>

      {/* Text with Styling */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>2. Styled Text</Text>
        <Text style={styles.boldText}>Bold Text</Text>
        <Text style={styles.italicText}>Italic Text</Text>
        <Text style={styles.underlinedText}>Underlined Text</Text>
      </View>

      {/* Nested Text */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>3. Nested Text</Text>
        <Text>
          This is a <Text style={styles.highlight}>highlighted</Text> word
          {' '}and this is a <Text style={styles.boldText}>bold</Text> word.
        </Text>
      </View>

      {/* Text with Number of Lines */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>4. Truncated Text</Text>
        <Text numberOfLines={1} style={styles.truncatedText}>
          This is a very long text that should be truncated with an ellipsis
          when it doesn't fit in one line.
        </Text>
      </View>

      {/* Text with Line Height */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>5. Line Height</Text>
        <Text style={styles.lineHeightText}>
          This text has increased line height for better readability.
          It's especially useful for longer paragraphs of text.
        </Text>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
    padding: 16,
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 8,
  },
  boldText: {
    fontWeight: 'bold',
  },
  italicText: {
    fontStyle: 'italic',
  },
  underlinedText: {
    textDecorationLine: 'underline',
  },
  highlight: {
    backgroundColor: '#fff3cd',
    color: '#856404',
    paddingHorizontal: 4,
  },
  truncatedText: {
    fontSize: 16,
    color: '#2c3e50',
  },
  lineHeightText: {
    fontSize: 16,
    lineHeight: 28,
    color: '#2c3e50',
  },
});
```

### ScrollView - Scrollable Content

```typescript
// src/components/ScrollViewExamples.tsx
import React from 'react';
import { View, Text, ScrollView, StyleSheet, Dimensions } from 'react-native';

const { width } = Dimensions.get('window');

export const ScrollViewExamples: React.FC = () => {
  // Generate dummy data
  const items = Array.from({ length: 20 }, (_, i) => ({
    id: i,
    title: `Item ${i + 1}`,
    description: `Description for item ${i + 1}`,
  }));

  return (
    <View style={styles.container}>
      <Text style={styles.header}>ScrollView Examples</Text>
      
      {/* Basic Vertical ScrollView */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>1. Vertical Scroll</Text>
        <ScrollView 
          style={styles.verticalScrollView}
          showsVerticalScrollIndicator={true}
        >
          {items.slice(0, 8).map((item) => (
            <View key={item.id} style={styles.scrollItem}>
              <Text style={styles.itemTitle}>{item.title}</Text>
              <Text style={styles.itemDesc}>{item.description}</Text>
            </View>
          ))}
        </ScrollView>
      </View>

      {/* Horizontal ScrollView */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>2. Horizontal Scroll</Text>
        <ScrollView 
          horizontal={true}
          style={styles.horizontalScrollView}
          showsHorizontalScrollIndicator={true}
          contentContainerStyle={styles.horizontalContent}
        >
          {items.slice(0, 6).map((item) => (
            <View key={item.id} style={styles.horizontalItem}>
              <Text style={styles.horizontalItemText}>{item.title}</Text>
            </View>
          ))}
        </ScrollView>
      </View>

      {/* ScrollView with Pull-to-Refresh */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>3. With Refresh Control</Text>
        <ScrollView
          style={styles.verticalScrollView}
          refreshControl={
            <RefreshControl
              refreshing={false}
              onRefresh={() => {
                // Handle refresh
                console.log('Refreshing...');
              }}
              colors={['#3498db']}
              tintColor="#3498db"
            />
          }
        >
          {items.slice(0, 5).map((item) => (
            <View key={item.id} style={styles.scrollItem}>
              <Text style={styles.itemTitle}>{item.title}</Text>
              <Text style={styles.itemDesc}>{item.description}</Text>
            </View>
          ))}
        </ScrollView>
      </View>
    </View>
  );
};

// Import RefreshControl
import { RefreshControl } from 'react-native';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
    padding: 16,
  },
  header: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 20,
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 8,
  },
  verticalScrollView: {
    height: 200,
    backgroundColor: '#ffffff',
    borderRadius: 8,
  },
  scrollItem: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  itemTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: '#2c3e50',
  },
  itemDesc: {
    fontSize: 14,
    color: '#7f8c8d',
    marginTop: 4,
  },
  horizontalScrollView: {
    height: 120,
    backgroundColor: '#ffffff',
    borderRadius: 8,
  },
  horizontalContent: {
    paddingHorizontal: 8,
    alignItems: 'center',
  },
  horizontalItem: {
    width: 120,
    height: 100,
    marginHorizontal: 8,
    backgroundColor: '#3498db',
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  horizontalItemText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '500',
  },
});
```

### FlatList - Optimized Large Lists

```typescript
// src/components/FlatListExamples.tsx
import React, { useState } from 'react';
import { View, Text, FlatList, StyleSheet, TouchableOpacity, ActivityIndicator } from 'react-native';

interface Item {
  id: string;
  title: string;
  description: string;
  category: 'work' | 'personal' | 'shopping';
}

/**
 * FlatListExamples - Demonstrates optimized list rendering
 * 
 * FlatList is essential for performance when rendering large lists.
 * It only renders items that are visible on screen.
 */
export const FlatListExamples: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [items, setItems] = useState<Item[]>(
    Array.from({ length: 50 }, (_, i) => ({
      id: `item-${i}`,
      title: `Task ${i + 1}`,
      description: `Description for task ${i + 1}`,
      category: ['work', 'personal', 'shopping'][i % 3] as Item['category'],
    }))
  );

  // Render each item
  const renderItem = ({ item, index }: { item: Item; index: number }) => {
    const getCategoryColor = (category: Item['category']) => {
      switch (category) {
        case 'work': return '#3498db';
        case 'personal': return '#2ecc71';
        case 'shopping': return '#e74c3c';
        default: return '#95a5a6';
      }
    };

    return (
      <TouchableOpacity 
        style={[styles.itemContainer, index % 2 === 0 && styles.itemContainerAlt]}
        onPress={() => console.log('Pressed:', item.id)}
      >
        <View style={styles.itemHeader}>
          <Text style={styles.itemTitle}>{item.title}</Text>
          <View style={[
            styles.categoryBadge, 
            { backgroundColor: getCategoryColor(item.category) }
          ]}>
            <Text style={styles.categoryText}>{item.category}</Text>
          </View>
        </View>
        <Text style={styles.itemDescription} numberOfLines={2}>
          {item.description}
        </Text>
      </TouchableOpacity>
    );
  };

  // Header component
  const ListHeader = () => (
    <View style={styles.listHeader}>
      <Text style={styles.listTitle}>Task List</Text>
      <Text style={styles.listSubtitle}>{items.length} tasks total</Text>
    </View>
  );

  // Footer component
  const ListFooter = () => (
    <View style={styles.listFooter}>
      <ActivityIndicator size="small" color="#3498db" />
      <Text style={styles.footerText}>End of list</Text>
    </View>
  );

  // Empty state
  const ListEmpty = () => (
    <View style={styles.emptyContainer}>
      <Text style={styles.emptyText}>No tasks found</Text>
    </View>
  );

  // Separator component
  const ItemSeparator = () => <View style={styles.separator} />;

  // Load more data (pagination simulation)
  const loadMoreData = () => {
    if (loading) return;
    
    setLoading(true);
    setTimeout(() => {
      const newItems = Array.from({ length: 20 }, (_, i) => ({
        id: `item-${items.length + i}`,
        title: `Task ${items.length + i + 1}`,
        description: `Description for task ${items.length + i + 1}`,
        category: ['work', 'personal', 'shopping'][(items.length + i) % 3] as Item['category'],
      }));
      setItems([...items, ...newItems]);
      setLoading(false);
    }, 1500);
  };

  // Key extractor for performance
  const keyExtractor = (item: Item) => item.id;

  // Get item layout for performance optimization
  const getItemLayout = (_: any, index: number) => ({
    length: 80, // Height of each item
    offset: 80 * index,
    index,
  });

  return (
    <View style={styles.container}>
      <FlatList
        data={items}
        renderItem={renderItem}
        keyExtractor={keyExtractor}
        ListHeaderComponent={ListHeader}
        ListFooterComponent={ListFooter}
        ListEmptyComponent={ListEmpty}
        ItemSeparatorComponent={ItemSeparator}
        getItemLayout={getItemLayout}
        onEndReached={loadMoreData}
        onEndReachedThreshold={0.1}
        initialNumToRender={10}
        maxToRenderPerBatch={10}
        windowSize={10}
        showsVerticalScrollIndicator={true}
        refreshing={loading}
        style={styles.flatList}
        contentContainerStyle={styles.contentContainer}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  flatList: {
    flex: 1,
  },
  contentContainer: {
    paddingBottom: 20,
  },
  listHeader: {
    padding: 16,
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  listTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2c3e50',
  },
  listSubtitle: {
    fontSize: 14,
    color: '#7f8c8d',
    marginTop: 4,
  },
  itemContainer: {
    padding: 16,
    backgroundColor: '#ffffff',
  },
  itemContainerAlt: {
    backgroundColor: '#fafafa',
  },
  itemHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  itemTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: '#2c3e50',
  },
  itemDescription: {
    fontSize: 14,
    color: '#7f8c8d',
    marginTop: 4,
  },
  categoryBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
  },
  categoryText: {
    color: '#ffffff',
    fontSize: 10,
    fontWeight: '600',
    textTransform: 'uppercase',
  },
  separator: {
    height: 1,
    backgroundColor: '#f0f0f0',
  },
  listFooter: {
    padding: 16,
    alignItems: 'center',
  },
  footerText: {
    fontSize: 12,
    color: '#95a5a6',
    marginTop: 8,
  },
  emptyContainer: {
    padding: 40,
    alignItems: 'center',
  },
  emptyText: {
    fontSize: 16,
    color: '#95a5a6',
  },
});
```

---

## Target 5: Complete App Integration

**The Target:** Combine everything into our TaskFlow app skeleton.

**The Concept:** Now that we understand each component individually, let's build the initial structure of TaskFlow with proper navigation, safe areas, and responsive design.

### App.tsx - The Root Component

```typescript
// App.tsx
import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { StyleSheet, View, Text, Platform } from 'react-native';

// Import our screens (we'll build these next)
import { HomeScreen } from './src/screens/HomeScreen';
import { TasksScreen } from './src/screens/TasksScreen';
import { ProfileScreen } from './src/screens/ProfileScreen';
import { SettingsScreen } from './src/screens/SettingsScreen';

// Import components
import { CustomStatusBar } from './src/components/CustomStatusBar';
import { SafeAreaWrapper } from './src/components/SafeAreaWrapper';

// Import utilities
import { ScreenUtils } from './src/utils/dimensions';

// Create navigators
const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

// Main tab navigator
const MainTabs: React.FC = () => {
  return (
    <Tab.Navigator
      screenOptions={{
        tabBarActiveTintColor: '#3498db',
        tabBarInactiveTintColor: '#95a5a6',
        tabBarStyle: {
          backgroundColor: '#ffffff',
          borderTopWidth: 1,
          borderTopColor: '#f0f0f0',
          paddingBottom: Platform.OS === 'ios' ? 20 : 8,
          paddingTop: 8,
          height: Platform.OS === 'ios' ? 88 : 64,
        },
        headerShown: false,
      }}
    >
      <Tab.Screen 
        name="Home" 
        component={HomeScreen}
        options={{
          tabBarIcon: ({ color }) => (
            <Text style={{ fontSize: 24, color }}>🏠</Text>
          ),
        }}
      />
      <Tab.Screen 
        name="Tasks" 
        component={TasksScreen}
        options={{
          tabBarIcon: ({ color }) => (
            <Text style={{ fontSize: 24, color }}>📋</Text>
          ),
        }}
      />
      <Tab.Screen 
        name="Profile" 
        component={ProfileScreen}
        options={{
          tabBarIcon: ({ color }) => (
            <Text style={{ fontSize: 24, color }}>👤</Text>
          ),
        }}
      />
      <Tab.Screen 
        name="Settings" 
        component={SettingsScreen}
        options={{
          tabBarIcon: ({ color }) => (
            <Text style={{ fontSize: 24, color }}>⚙️</Text>
          ),
        }}
      />
    </Tab.Navigator>
  );
};

// Main App Component
export default function App() {
  return (
    <SafeAreaProvider>
      <SafeAreaWrapper>
        <NavigationContainer>
          <Stack.Navigator
            screenOptions={{
              headerShown: false,
              contentStyle: {
                backgroundColor: '#f8f9fa',
              },
            }}
          >
            <Stack.Screen name="MainTabs" component={MainTabs} />
          </Stack.Navigator>
        </NavigationContainer>
        <StatusBar style={Platform.OS === 'ios' ? 'dark' : 'auto'} />
      </SafeAreaWrapper>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
});
```

### HomeScreen.tsx

```typescript
// src/screens/HomeScreen.tsx
import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { ResponsiveCard } from '../components/ResponsiveCard';
import { CustomStatusBar } from '../components/CustomStatusBar';
import { ScreenUtils } from '../utils/dimensions';

export const HomeScreen: React.FC = () => {
  const isTablet = ScreenUtils.isTablet();

  return (
    <View style={styles.container}>
      <CustomStatusBar title="TaskFlow" />
      
      <ScrollView 
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
      >
        <View style={styles.welcomeSection}>
          <Text style={styles.welcomeTitle}>Welcome Back!</Text>
          <Text style={styles.welcomeSubtitle}>
            You have 3 tasks due today
          </Text>
        </View>

        <View style={styles.cardGrid}>
          <ResponsiveCard 
            title="Quick Actions"
            subtitle="Tap to get started"
            variant="elevated"
          >
            <View style={styles.actionRow}>
              <TouchableOpacity style={styles.actionButton}>
                <Text style={styles.actionIcon}>➕</Text>
                <Text style={styles.actionLabel}>New Task</Text>
              </TouchableOpacity>
              <TouchableOpacity style={styles.actionButton}>
                <Text style={styles.actionIcon}>📅</Text>
                <Text style={styles.actionLabel}>Calendar</Text>
              </TouchableOpacity>
              <TouchableOpacity style={styles.actionButton}>
                <Text style={styles.actionIcon}>📊</Text>
                <Text style={styles.actionLabel}>Analytics</Text>
              </TouchableOpacity>
            </View>
          </ResponsiveCard>

          <ResponsiveCard 
            title="Today's Progress"
            subtitle="Complete your daily goals"
            variant="outlined"
          >
            <View style={styles.progressContainer}>
              <View style={styles.progressBar}>
                <View style={[styles.progressFill, { width: '60%' }]} />
              </View>
              <Text style={styles.progressText}>60% Complete</Text>
            </View>
          </ResponsiveCard>

          <ResponsiveCard 
            title="Upcoming Deadlines"
            subtitle="3 tasks due this week"
            variant="default"
          >
            <View style={styles.deadlineList}>
              <View style={styles.deadlineItem}>
                <Text style={styles.deadlineTitle}>Complete project proposal</Text>
                <Text style={styles.deadlineDate}>Due: Tomorrow</Text>
              </View>
              <View style={styles.deadlineItem}>
                <Text style={styles.deadlineTitle}>Team meeting prep</Text>
                <Text style={styles.deadlineDate}>Due: Thursday</Text>
              </View>
            </View>
          </ResponsiveCard>
        </View>

        {isTablet && (
          <View style={styles.tabletExtra}>
            <Text style={styles.tabletExtraText}>
              📱 Tablet view with additional content
            </Text>
          </View>
        )}
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
  scrollContent: {
    padding: 16,
    paddingBottom: 40,
  },
  welcomeSection: {
    marginBottom: 24,
  },
  welcomeTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2c3e50',
  },
  welcomeSubtitle: {
    fontSize: 16,
    color: '#7f8c8d',
    marginTop: 4,
  },
  cardGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  actionRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginTop: 8,
  },
  actionButton: {
    alignItems: 'center',
    padding: 8,
  },
  actionIcon: {
    fontSize: 28,
    marginBottom: 4,
  },
  actionLabel: {
    fontSize: 12,
    color: '#34495e',
  },
  progressContainer: {
    marginTop: 8,
  },
  progressBar: {
    height: 8,
    backgroundColor: '#f0f0f0',
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#3498db',
    borderRadius: 4,
  },
  progressText: {
    fontSize: 14,
    color: '#34495e',
    marginTop: 8,
    textAlign: 'center',
  },
  deadlineList: {
    marginTop: 8,
  },
  deadlineItem: {
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  deadlineTitle: {
    fontSize: 14,
    color: '#2c3e50',
  },
  deadlineDate: {
    fontSize: 12,
    color: '#e74c3c',
    marginTop: 2,
  },
  tabletExtra: {
    marginTop: 24,
    padding: 20,
    backgroundColor: '#e8f4fd',
    borderRadius: 12,
    alignItems: 'center',
  },
  tabletExtraText: {
    fontSize: 16,
    color: '#2c3e50',
  },
});
```

### Verification: Run Your App

```bash
# Start the app
cd ~/projects/TaskFlow
expo start

# Press 'i' for iOS, 'a' for Android
# Or scan QR code for physical device
```

**Expected Results:**
1. App launches without errors
2. Status bar appears with "TaskFlow" title
3. Home screen shows welcome message
4. Three cards display with proper styling
5. Tab navigation works between Home, Tasks, Profile, Settings
6. Responsive design adapts to different screen sizes

---

## What We've Accomplished

Congratulations! You've completed Phase 2 of Part 1. Here's what you've mastered:

1. **Flexbox Fundamentals:** You understand every Flexbox property and can create complex layouts
2. **Responsive Design:** Your app adapts to any screen size using utilities and responsive components
3. **Safe Area Handling:** Notches, status bars, and home indicators no longer obscure your content
4. **Core Components:** You've mastered View, Text, ScrollView, and FlatList
5. **App Structure:** TaskFlow has a solid foundation with navigation and properly structured screens

### What's Next: Part 1, Phase 3 - Navigation

Next, we'll implement full navigation with:
- Stack navigation for screen hierarchies
- Tab navigation for primary app sections
- Drawer navigation for additional options
- Navigation guards and authentication flows
- Deep linking support

*Next up: We'll build robust navigation that guides users through TaskFlow. We'll implement stack navigation for nested screens, tab navigation for primary sections, and drawer navigation for advanced features. Your app is about to become fully navigable!*

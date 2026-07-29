# Appendix C: Advanced Styling & Animations Patterns

Welcome to Appendix C! This comprehensive guide dives deep into advanced styling techniques and animation patterns for React Native. You'll learn how to create sophisticated, production-ready UI components with complex animations, custom transitions, and platform-specific styling that will make your TaskFlow app stand out.

---

## Table of Contents

1. [Advanced Styling Techniques](#advanced-styling-techniques)
2. [Custom Theme System](#custom-theme-system)
3. [Complex Animation Patterns](#complex-animation-patterns)
4. [Gesture-Driven Animations](#gesture-driven-animations)
5. [Animated Transitions & Shared Elements](#animated-transitions--shared-elements)
6. [Loading & Skeleton Screens](#loading--skeleton-screens)
7. [Platform-Specific Styling](#platform-specific-styling)
8. [Performance Optimization for Animations](#performance-optimization-for-animations)

---

## Advanced Styling Techniques

### The Complete Styling System

```typescript
// src/styles/advanced.ts
import { StyleSheet, Platform, Dimensions, PixelRatio } from 'react-native';

const { width, height } = Dimensions.get('window');
const scale = width / 375; // Base design on iPhone SE

/**
 * Advanced Design System
 * 
 * This provides a comprehensive styling system with:
 * - Responsive sizing
 * - Theme-aware colors
 * - Typography scale
 * - Spacing system
 * - Shadow presets
 * - Animation presets
 */
export const DesignSystem = {
  // Colors with light/dark themes
  colors: {
    // Primary palette
    primary: {
      50: '#e8f4fd',
      100: '#b8d9f7',
      200: '#8bbef1',
      300: '#5da3eb',
      400: '#3f8fe7',
      500: '#217be3', // Primary
      600: '#1d6fd6',
      700: '#185fb8',
      800: '#134e97',
      900: '#0e3d76',
    },
    // Secondary palette
    secondary: {
      50: '#f0f0f0',
      100: '#d4d4d4',
      200: '#b8b8b8',
      300: '#9c9c9c',
      400: '#808080',
      500: '#646464',
      600: '#484848',
      700: '#2c2c2c',
      800: '#1e1e1e',
      900: '#141414',
    },
    // Semantic colors
    success: {
      50: '#e6f9ed',
      100: '#b3edcc',
      200: '#80e1aa',
      300: '#4dd589',
      400: '#26cc72',
      500: '#00c25a', // Success
      600: '#00af51',
      700: '#009946',
      800: '#00833a',
      900: '#00662e',
    },
    warning: {
      50: '#fef7e6',
      100: '#fce7b3',
      200: '#fad780',
      300: '#f8c74d',
      400: '#f7bb26',
      500: '#f5af00', // Warning
      600: '#e0a000',
      700: '#c48d00',
      800: '#a87a00',
      900: '#8c6600',
    },
    error: {
      50: '#fce8e8',
      100: '#f7b8b8',
      200: '#f18888',
      300: '#ec5858',
      400: '#e83434',
      500: '#e41010', // Error
      600: '#d00e0e',
      700: '#b60c0c',
      800: '#9c0a0a',
      900: '#820808',
    },
    // Neutral palette
    neutral: {
      50: '#fafafa',
      100: '#f5f5f5',
      200: '#eeeeee',
      300: '#e0e0e0',
      400: '#bdbdbd',
      500: '#9e9e9e',
      600: '#757575',
      700: '#616161',
      800: '#424242',
      900: '#212121',
    },
    // Background colors
    background: {
      light: '#ffffff',
      dark: '#121212',
      lightSecondary: '#f8f9fa',
      darkSecondary: '#1e1e1e',
    },
    // Text colors
    text: {
      light: {
        primary: '#212121',
        secondary: '#757575',
        disabled: '#9e9e9e',
        inverse: '#ffffff',
      },
      dark: {
        primary: '#e0e0e0',
        secondary: '#a0a0a0',
        disabled: '#6e6e6e',
        inverse: '#121212',
      },
    },
  },

  // Typography system
  typography: {
    // Headings
    h1: {
      fontSize: 32,
      lineHeight: 40,
      fontWeight: '700' as const,
    },
    h2: {
      fontSize: 28,
      lineHeight: 36,
      fontWeight: '600' as const,
    },
    h3: {
      fontSize: 24,
      lineHeight: 32,
      fontWeight: '600' as const,
    },
    h4: {
      fontSize: 20,
      lineHeight: 28,
      fontWeight: '500' as const,
    },
    h5: {
      fontSize: 18,
      lineHeight: 26,
      fontWeight: '500' as const,
    },
    h6: {
      fontSize: 16,
      lineHeight: 24,
      fontWeight: '500' as const,
    },
    // Body
    body1: {
      fontSize: 16,
      lineHeight: 24,
      fontWeight: '400' as const,
    },
    body2: {
      fontSize: 14,
      lineHeight: 20,
      fontWeight: '400' as const,
    },
    body3: {
      fontSize: 12,
      lineHeight: 18,
      fontWeight: '400' as const,
    },
    // Labels
    label: {
      fontSize: 14,
      lineHeight: 20,
      fontWeight: '500' as const,
    },
    labelSmall: {
      fontSize: 12,
      lineHeight: 16,
      fontWeight: '500' as const,
    },
    // Captions
    caption: {
      fontSize: 12,
      lineHeight: 16,
      fontWeight: '400' as const,
    },
    captionSmall: {
      fontSize: 10,
      lineHeight: 14,
      fontWeight: '400' as const,
    },
  },

  // Spacing system (8px grid)
  spacing: {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
    xxl: 48,
    xxxl: 64,
    huge: 80,
  },

  // Border radius
  radii: {
    none: 0,
    xs: 2,
    sm: 4,
    md: 8,
    lg: 12,
    xl: 16,
    xxl: 24,
    round: 9999,
  },

  // Shadows
  shadows: {
    none: {
      shadowColor: 'transparent',
      shadowOffset: { width: 0, height: 0 },
      shadowOpacity: 0,
      shadowRadius: 0,
      elevation: 0,
    },
    xs: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 1 },
      shadowOpacity: 0.05,
      shadowRadius: 2,
      elevation: 1,
    },
    sm: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.06,
      shadowRadius: 4,
      elevation: 2,
    },
    md: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 4 },
      shadowOpacity: 0.08,
      shadowRadius: 8,
      elevation: 4,
    },
    lg: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 6 },
      shadowOpacity: 0.12,
      shadowRadius: 12,
      elevation: 8,
    },
    xl: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 8 },
      shadowOpacity: 0.16,
      shadowRadius: 16,
      elevation: 12,
    },
    xxl: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 12 },
      shadowOpacity: 0.2,
      shadowRadius: 24,
      elevation: 16,
    },
  },

  // Animation presets
  animations: {
    // Duration
    duration: {
      instant: 0,
      fast: 150,
      normal: 300,
      slow: 500,
      slower: 800,
    },
    // Easing functions
    easing: {
      linear: 'linear' as const,
      easeIn: 'ease-in' as const,
      easeOut: 'ease-out' as const,
      easeInOut: 'ease-in-out' as const,
      spring: 'spring' as const,
    },
    // Common animation presets
    preset: {
      fadeIn: {
        from: { opacity: 0 },
        to: { opacity: 1 },
        duration: 300,
        easing: 'ease-in-out',
      },
      slideUp: {
        from: { translateY: 20, opacity: 0 },
        to: { translateY: 0, opacity: 1 },
        duration: 400,
        easing: 'spring',
      },
      slideDown: {
        from: { translateY: -20, opacity: 0 },
        to: { translateY: 0, opacity: 1 },
        duration: 400,
        easing: 'spring',
      },
      scaleIn: {
        from: { scale: 0.8, opacity: 0 },
        to: { scale: 1, opacity: 1 },
        duration: 300,
        easing: 'spring',
      },
      scaleOut: {
        from: { scale: 1.2, opacity: 0 },
        to: { scale: 1, opacity: 1 },
        duration: 300,
        easing: 'spring',
      },
    },
  },
};

/**
 * Responsive sizing utilities
 */
export const responsive = {
  width: (size: number) => size * scale,
  height: (size: number) => size * scale,
  fontSize: (size: number) => size * PixelRatio.getFontScale(),
  padding: (size: number) => size * scale,
  margin: (size: number) => size * scale,
  borderRadius: (size: number) => size * scale,
};

/**
 * Create a style with responsive values
 */
export const createResponsiveStyle = (styles: any) => {
  const responsiveStyles: any = {};
  
  Object.entries(styles).forEach(([key, value]) => {
    if (typeof value === 'object' && !Array.isArray(value)) {
      const newValue: any = {};
      Object.entries(value).forEach(([propKey, propValue]) => {
        if (typeof propValue === 'number') {
          // Responsive properties
          if (
            ['width', 'height', 'padding', 'margin', 'top', 'bottom', 'left', 'right'].some(
              p => propKey === p || propKey.startsWith(p)
            )
          ) {
            newValue[propKey] = responsive.padding(propValue);
          } else if (propKey === 'fontSize' || propKey === 'lineHeight') {
            newValue[propKey] = responsive.fontSize(propValue);
          } else if (propKey === 'borderRadius') {
            newValue[propKey] = responsive.borderRadius(propValue);
          } else {
            newValue[propKey] = propValue;
          }
        } else {
          newValue[propKey] = propValue;
        }
      });
      responsiveStyles[key] = newValue;
    } else {
      responsiveStyles[key] = value;
    }
  });
  
  return StyleSheet.create(responsiveStyles);
};
```

### Theme-Aware Components

```typescript
// src/context/ThemeContext.tsx
import React, { createContext, useContext, useEffect, useMemo } from 'react';
import { useColorScheme } from 'react-native';
import { DesignSystem } from '../styles/advanced';

type Theme = 'light' | 'dark' | 'system';

interface ThemeContextType {
  theme: Theme;
  colors: typeof DesignSystem.colors;
  isDark: boolean;
  setTheme: (theme: Theme) => void;
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const systemTheme = useColorScheme();
  const [theme, setTheme] = React.useState<Theme>('system');

  const isDark = theme === 'system' ? systemTheme === 'dark' : theme === 'dark';

  // Get color scheme based on theme
  const colors = useMemo(() => {
    const textColors = isDark ? DesignSystem.colors.text.dark : DesignSystem.colors.text.light;
    const backgroundColors = isDark ? DesignSystem.colors.background.dark : DesignSystem.colors.background.light;
    
    return {
      ...DesignSystem.colors,
      text: textColors,
      background: backgroundColors,
    };
  }, [isDark]);

  const toggleTheme = () => {
    setTheme(prev => {
      if (prev === 'light') return 'dark';
      if (prev === 'dark') return 'system';
      return 'light';
    });
  };

  const value = {
    theme,
    colors,
    isDark,
    setTheme,
    toggleTheme,
  };

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
};

// Theme-aware styles hook
export const useThemedStyles = (styles: (colors: any) => any) => {
  const { colors } = useTheme();
  return useMemo(() => styles(colors), [colors]);
};

// Example usage
const themedStyles = (colors: any) => ({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  text: {
    color: colors.text.primary,
    ...DesignSystem.typography.body1,
  },
  button: {
    backgroundColor: colors.primary[500],
    borderRadius: DesignSystem.radii.md,
    padding: DesignSystem.spacing.md,
  },
});
```

---

## Complex Animation Patterns

### Advanced Animation Utilities

```typescript
// src/utils/animations/advancedAnimations.ts
import { Animated, Easing, Platform } from 'react-native';

/**
 * Advanced animation utilities
 * 
 * This provides production-ready animation patterns
 * for complex UI interactions.
 */
export class AnimationUtils {
  /**
   * Create a spring animation with custom config
   */
  static spring(
    value: Animated.Value | Animated.ValueXY,
    toValue: number | { x: number; y: number },
    config: {
      damping?: number;
      mass?: number;
      stiffness?: number;
      overshootClamping?: boolean;
      restSpeedThreshold?: number;
      restDisplacementThreshold?: number;
    } = {}
  ) {
    const {
      damping = 10,
      mass = 1,
      stiffness = 100,
      overshootClamping = false,
      restSpeedThreshold = 0.001,
      restDisplacementThreshold = 0.001,
    } = config;

    return Animated.spring(value, {
      toValue,
      damping,
      mass,
      stiffness,
      overshootClamping,
      restSpeedThreshold,
      restDisplacementThreshold,
      useNativeDriver: true,
    });
  }

  /**
   * Create a sequence of animations with delays
   */
  static sequence(
    animations: Array<{
      animation: Animated.CompositeAnimation;
      delay?: number;
    }>
  ) {
    const sequences: Animated.CompositeAnimation[] = [];

    animations.forEach(({ animation, delay = 0 }) => {
      if (delay > 0) {
        sequences.push(Animated.delay(delay));
      }
      sequences.push(animation);
    });

    return Animated.sequence(sequences);
  }

  /**
   * Create a stagger animation for lists
   */
  static stagger(
    items: any[],
    createAnimation: (item: any, index: number) => Animated.CompositeAnimation,
    staggerDuration: number = 100
  ) {
    const animations = items.map((item, index) => {
      return Animated.delay(index * staggerDuration);
    });

    items.forEach((item, index) => {
      const animation = createAnimation(item, index);
      const delayedAnimation = Animated.delay(index * staggerDuration);
      animations.push(delayedAnimation, animation);
    });

    return Animated.parallel(animations);
  }

  /**
   * Create a flip animation
   */
  static flip(
    value: Animated.Value,
    duration: number = 500
  ) {
    return Animated.timing(value, {
      toValue: 1,
      duration,
      easing: Easing.inOut(Easing.ease),
      useNativeDriver: true,
    });
  }

  /**
   * Create a pulse animation (loop)
   */
  static pulse(
    value: Animated.Value,
    config: {
      minScale?: number;
      maxScale?: number;
      duration?: number;
      easing?: any;
    } = {}
  ) {
    const {
      minScale = 0.9,
      maxScale = 1.1,
      duration = 1000,
      easing = Easing.inOut(Easing.ease),
    } = config;

    return Animated.loop(
      Animated.sequence([
        Animated.timing(value, {
          toValue: maxScale,
          duration: duration / 2,
          easing,
          useNativeDriver: true,
        }),
        Animated.timing(value, {
          toValue: minScale,
          duration: duration / 2,
          easing,
          useNativeDriver: true,
        }),
        Animated.timing(value, {
          toValue: 1,
          duration: duration / 2,
          easing,
          useNativeDriver: true,
        }),
      ])
    );
  }

  /**
   * Create a loading shimmer effect
   */
  static shimmer(
    value: Animated.Value,
    config: {
      duration?: number;
      width?: number;
      height?: number;
    } = {}
  ) {
    const { duration = 1000, width = 200, height = 20 } = config;

    return Animated.loop(
      Animated.timing(value, {
        toValue: 1,
        duration,
        easing: Easing.linear,
        useNativeDriver: false,
      })
    );
  }
}
```

### Complete Animation Component

```typescript
// src/components/AnimatedCard.tsx
import React, { useRef, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Animated,
  Easing,
  Platform,
} from 'react-native';
import { AnimationUtils } from '../utils/animations/advancedAnimations';
import { DesignSystem, responsive } from '../styles/advanced';

interface AnimatedCardProps {
  title: string;
  subtitle?: string;
  onPress?: () => void;
  delay?: number;
  animationType?: 'fadeIn' | 'slideUp' | 'scaleIn' | 'flipIn';
  style?: any;
  children?: React.ReactNode;
}

export const AnimatedCard: React.FC<AnimatedCardProps> = ({
  title,
  subtitle,
  onPress,
  delay = 0,
  animationType = 'slideUp',
  style,
  children,
}) => {
  const opacity = useRef(new Animated.Value(0)).current;
  const translateY = useRef(new Animated.Value(30)).current;
  const scale = useRef(new Animated.Value(0.9)).current;
  const rotateX = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const animations: Animated.CompositeAnimation[] = [];

    // Base animations
    animations.push(
      Animated.timing(opacity, {
        toValue: 1,
        duration: 400,
        easing: Easing.out(Easing.ease),
        useNativeDriver: true,
      })
    );

    // Type-specific animations
    switch (animationType) {
      case 'slideUp':
        animations.push(
          Animated.spring(translateY, {
            toValue: 0,
            damping: 15,
            stiffness: 120,
            useNativeDriver: true,
          })
        );
        break;
      case 'scaleIn':
        animations.push(
          Animated.spring(scale, {
            toValue: 1,
            damping: 15,
            stiffness: 150,
            useNativeDriver: true,
          })
        );
        break;
      case 'flipIn':
        animations.push(
          Animated.timing(rotateX, {
            toValue: 1,
            duration: 500,
            easing: Easing.out(Easing.ease),
            useNativeDriver: true,
          })
        );
        break;
      default:
        // fadeIn
        break;
    }

    // Start animation with delay
    const startAnimations = () => {
      Animated.parallel(animations).start();
    };

    if (delay > 0) {
      setTimeout(startAnimations, delay);
    } else {
      startAnimations();
    }

    // Cleanup
    return () => {
      opacity.setValue(0);
      translateY.setValue(30);
      scale.setValue(0.9);
      rotateX.setValue(0);
    };
  }, [delay, animationType]);

  // Transform interpolations
  const rotateXInterpolate = rotateX.interpolate({
    inputRange: [0, 0.5, 1],
    outputRange: ['90deg', '-10deg', '0deg'],
  });

  const cardStyle = {
    opacity,
    transform: [
      { translateY: translateY },
      { scale: scale },
      { rotateX: rotateXInterpolate },
    ],
  };

  return (
    <Animated.View style={[styles.card, cardStyle, style]}>
      <TouchableOpacity
        style={styles.cardContent}
        onPress={onPress}
        activeOpacity={0.7}
        disabled={!onPress}
      >
        <View style={styles.header}>
          <Text style={styles.title}>{title}</Text>
          {subtitle && <Text style={styles.subtitle}>{subtitle}</Text>}
        </View>
        
        {children && <View style={styles.children}>{children}</View>}
        
        {onPress && (
          <View style={styles.footer}>
            <Text style={styles.tapHint}>Tap to interact</Text>
          </View>
        )}
      </TouchableOpacity>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#ffffff',
    borderRadius: DesignSystem.radii.md,
    marginHorizontal: responsive.padding(16),
    marginVertical: responsive.padding(8),
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.08,
        shadowRadius: 8,
      },
      android: {
        elevation: 4,
      },
    }),
  },
  cardContent: {
    padding: DesignSystem.spacing.md,
  },
  header: {
    marginBottom: DesignSystem.spacing.sm,
  },
  title: {
    ...DesignSystem.typography.h5,
    color: DesignSystem.colors.text.light.primary,
  },
  subtitle: {
    ...DesignSystem.typography.body2,
    color: DesignSystem.colors.text.light.secondary,
    marginTop: DesignSystem.spacing.xs,
  },
  children: {
    marginTop: DesignSystem.spacing.sm,
  },
  footer: {
    marginTop: DesignSystem.spacing.md,
    paddingTop: DesignSystem.spacing.sm,
    borderTopWidth: 1,
    borderTopColor: DesignSystem.colors.neutral[200],
  },
  tapHint: {
    ...DesignSystem.typography.caption,
    color: DesignSystem.colors.text.light.secondary,
    textAlign: 'center',
  },
});
```

---

## Gesture-Driven Animations

### Advanced Gesture Animations

```typescript
// src/components/GestureAnimationExamples.tsx
import React, { useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
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
  interpolate,
  Extrapolate,
  useDerivedValue,
} from 'react-native-reanimated';
import * as Haptics from 'expo-haptics';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');

/**
 * Advanced gesture animations using Reanimated 2
 * 
 * This demonstrates complex gesture-driven animations:
 * - Draggable cards with spring physics
 * - Swipe-to-dismiss with velocity
 * - Pinch-to-zoom with rotation
 * - Multi-touch gestures
 */
export const GestureAnimationExamples: React.FC = () => {
  // 1. Draggable Card with Snap Points
  const DragSnapExample: React.FC = () => {
    const translateX = useSharedValue(0);
    const translateY = useSharedValue(0);
    const scale = useSharedValue(1);

    const gesture = Gesture.Pan()
      .onStart(() => {
        scale.value = withSpring(1.05);
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      })
      .onUpdate((event) => {
        translateX.value = event.translationX;
        translateY.value = event.translationY;
      })
      .onEnd((event) => {
        const velocityX = event.velocityX;
        const velocityY = event.velocityY;
        
        // Snap to nearest position with velocity
        const snapX = Math.round(translateX.value / 50) * 50;
        const snapY = Math.round(translateY.value / 50) * 50;
        
        translateX.value = withSpring(snapX, {
          damping: 15,
          stiffness: 150,
          velocity: velocityX,
        });
        translateY.value = withSpring(snapY, {
          damping: 15,
          stiffness: 150,
          velocity: velocityY,
        });
        scale.value = withSpring(1);
      });

    const animatedStyle = useAnimatedStyle(() => ({
      transform: [
        { translateX: translateX.value },
        { translateY: translateY.value },
        { scale: scale.value },
      ],
    }));

    return (
      <View style={styles.exampleContainer}>
        <Text style={styles.exampleTitle}>1. Draggable Card with Snap Points</Text>
        <GestureDetector gesture={gesture}>
          <Animated.View style={[styles.dragCard, animatedStyle]}>
            <Text style={styles.cardText}>Drag me</Text>
            <Text style={styles.cardSubText}>Snaps to grid</Text>
          </Animated.View>
        </GestureDetector>
      </View>
    );
  };

  // 2. Swipe-to-Dismiss
  const SwipeDismissExample: React.FC = () => {
    const translateX = useSharedValue(0);
    const opacity = useSharedValue(1);
    const scale = useSharedValue(1);

    const gesture = Gesture.Pan()
      .onUpdate((event) => {
        translateX.value = event.translationX;
        
        // Scale and opacity based on swipe distance
        const distance = Math.abs(translateX.value);
        const maxDistance = SCREEN_WIDTH * 0.5;
        scale.value = interpolate(
          distance,
          [0, maxDistance],
          [1, 0.8],
          Extrapolate.CLAMP
        );
        opacity.value = interpolate(
          distance,
          [0, maxDistance],
          [1, 0.5],
          Extrapolate.CLAMP
        );
      })
      .onEnd((event) => {
        const shouldDismiss = Math.abs(translateX.value) > SCREEN_WIDTH * 0.25;
        
        if (shouldDismiss) {
          // Animate out
          const direction = translateX.value > 0 ? 1 : -1;
          translateX.value = withTiming(direction * SCREEN_WIDTH, { duration: 300 });
          opacity.value = withTiming(0, { duration: 300 });
          scale.value = withTiming(0.8, { duration: 300 });
          
          Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
          
          // Reset after animation
          setTimeout(() => {
            translateX.value = 0;
            opacity.value = 1;
            scale.value = 1;
          }, 400);
        } else {
          // Spring back
          translateX.value = withSpring(0, {
            damping: 20,
            stiffness: 150,
            velocity: event.velocityX,
          });
          scale.value = withSpring(1);
          opacity.value = withSpring(1);
        }
      });

    const animatedStyle = useAnimatedStyle(() => ({
      transform: [
        { translateX: translateX.value },
        { scale: scale.value },
      ],
      opacity: opacity.value,
    }));

    // Background that appears on swipe
    const bgStyle = useAnimatedStyle(() => {
      const progress = Math.min(Math.abs(translateX.value) / (SCREEN_WIDTH * 0.25), 1);
      return {
        opacity: progress,
        backgroundColor: translateX.value > 0 ? '#2ecc71' : '#e74c3c',
        transform: [{ scale: progress }],
      };
    });

    return (
      <View style={styles.exampleContainer}>
        <Text style={styles.exampleTitle}>2. Swipe-to-Dismiss</Text>
        <View style={styles.swipeContainer}>
          <Animated.View style={[styles.swipeBackground, bgStyle]}>
            <Text style={styles.swipeIcon}>
              {translateX.value > 0 ? '✓' : '✕'}
            </Text>
          </Animated.View>
          <GestureDetector gesture={gesture}>
            <Animated.View style={[styles.swipeCard, animatedStyle]}>
              <Text style={styles.cardText}>Swipe me</Text>
              <Text style={styles.cardSubText}>
                Swipe right to complete, left to delete
              </Text>
            </Animated.View>
          </GestureDetector>
        </View>
      </View>
    );
  };

  // 3. Pinch-to-Zoom with Rotation
  const PinchZoomExample: React.FC = () => {
    const scale = useSharedValue(1);
    const rotate = useSharedValue(0);

    const gesture = Gesture.Pinch()
      .onUpdate((event) => {
        scale.value = event.scale;
        rotate.value = event.rotation;
      })
      .onEnd(() => {
        scale.value = withSpring(1);
        rotate.value = withSpring(0);
      });

    const animatedStyle = useAnimatedStyle(() => ({
      transform: [
        { scale: scale.value },
        { rotate: `${rotate.value}rad` },
      ],
    }));

    return (
      <View style={styles.exampleContainer}>
        <Text style={styles.exampleTitle}>3. Pinch-to-Zoom</Text>
        <GestureDetector gesture={gesture}>
          <Animated.View style={[styles.zoomBox, animatedStyle]}>
            <Text style={styles.zoomText}>🖼️</Text>
            <Text style={styles.zoomSubText}>Pinch to zoom</Text>
          </Animated.View>
        </GestureDetector>
      </View>
    );
  };

  // 4. Staggered Animation List
  const StaggeredListExample: React.FC = () => {
    const items = ['Task 1', 'Task 2', 'Task 3', 'Task 4', 'Task 5'];
    const translates = items.map(() => useSharedValue(50));
    const opacities = items.map(() => useSharedValue(0));
    const scales = items.map(() => useSharedValue(0.8));

    React.useEffect(() => {
      items.forEach((_, index) => {
        translates[index].value = withDelay(
          index * 100,
          withSpring(0, { damping: 15, stiffness: 120 })
        );
        opacities[index].value = withDelay(
          index * 100,
          withTiming(1, { duration: 400 })
        );
        scales[index].value = withDelay(
          index * 100,
          withSpring(1, { damping: 15, stiffness: 120 })
        );
      });
    }, []);

    const renderItem = (item: string, index: number) => {
      const animatedStyle = useAnimatedStyle(() => ({
        transform: [
          { translateX: translates[index].value },
          { scale: scales[index].value },
        ],
        opacity: opacities[index].value,
      }));

      return (
        <Animated.View key={index} style={[styles.staggeredItem, animatedStyle]}>
          <Text style={styles.staggeredText}>{item}</Text>
        </Animated.View>
      );
    };

    return (
      <View style={styles.exampleContainer}>
        <Text style={styles.exampleTitle}>4. Staggered Animation List</Text>
        {items.map((item, index) => renderItem(item, index))}
      </View>
    );
  };

  return (
    <GestureHandlerRootView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.sectionTitle}>Gesture-Driven Animations</Text>
        <Text style={styles.sectionSubtitle}>
          Interactive animations with haptic feedback
        </Text>

        <DragSnapExample />
        <SwipeDismissExample />
        <PinchZoomExample />
        <StaggeredListExample />
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
    padding: 16,
    paddingBottom: 40,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2c3e50',
    textAlign: 'center',
    marginBottom: 8,
  },
  sectionSubtitle: {
    fontSize: 14,
    color: '#7f8c8d',
    textAlign: 'center',
    marginBottom: 24,
  },
  exampleContainer: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 20,
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
  exampleTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#34495e',
    marginBottom: 12,
  },
  dragCard: {
    width: 120,
    height: 120,
    backgroundColor: '#3498db',
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  cardText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  cardSubText: {
    color: 'rgba(255,255,255,0.7)',
    fontSize: 12,
    marginTop: 4,
  },
  swipeContainer: {
    position: 'relative',
    height: 80,
  },
  swipeBackground: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  swipeIcon: {
    fontSize: 32,
    color: '#ffffff',
  },
  swipeCard: {
    height: 80,
    backgroundColor: '#ffffff',
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#e1e8ed',
  },
  zoomBox: {
    width: 150,
    height: 150,
    backgroundColor: '#f1f2f6',
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    alignSelf: 'center',
  },
  zoomText: {
    fontSize: 48,
  },
  zoomSubText: {
    fontSize: 12,
    color: '#7f8c8d',
    marginTop: 8,
  },
  staggeredItem: {
    backgroundColor: '#f1f2f6',
    padding: 12,
    borderRadius: 8,
    marginBottom: 8,
  },
  staggeredText: {
    fontSize: 14,
    color: '#2c3e50',
  },
});
```

---

## Animated Transitions & Shared Elements

### Shared Element Transition System

```typescript
// src/navigation/SharedElementNavigator.tsx
import React, { createContext, useContext, useRef } from 'react';
import {
  View,
  StyleSheet,
  Platform,
} from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  runOnJS,
} from 'react-native-reanimated';

interface SharedElementContextType {
  register: (id: string, ref: View) => void;
  unregister: (id: string) => void;
  startTransition: (fromId: string, toId: string, config?: any) => void;
}

const SharedElementContext = createContext<SharedElementContextType | undefined>(
  undefined
);

export const useSharedElement = () => {
  const context = useContext(SharedElementContext);
  if (!context) {
    throw new Error('useSharedElement must be used within SharedElementProvider');
  }
  return context;
};

export const SharedElementProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const elements = useRef<Map<string, { ref: View; layout: any }>>(new Map());

  const register = (id: string, ref: View) => {
    ref.measure((x, y, width, height, pageX, pageY) => {
      elements.current.set(id, {
        ref,
        layout: { x: pageX, y: pageY, width, height },
      });
    });
  };

  const unregister = (id: string) => {
    elements.current.delete(id);
  };

  const startTransition = (fromId: string, toId: string, config = {}) => {
    const from = elements.current.get(fromId);
    const to = elements.current.get(toId);

    if (!from || !to) {
      console.warn('Shared element not found');
      return;
    }

    // Calculate transform differences
    const scaleX = to.layout.width / from.layout.width;
    const scaleY = to.layout.height / from.layout.height;
    const translateX = to.layout.x - from.layout.x;
    const translateY = to.layout.y - from.layout.y;

    // Animate from element
    // This would be implemented with Reanimated
    console.log('Transitioning from', fromId, 'to', toId);
  };

  const value = {
    register,
    unregister,
    startTransition,
  };

  return (
    <SharedElementContext.Provider value={value}>
      {children}
    </SharedElementContext.Provider>
  );
};

// SharedElement Component
export const SharedElement: React.FC<{
  id: string;
  children: React.ReactNode;
  style?: any;
}> = ({ id, children, style }) => {
  const ref = useRef<View>(null);
  const { register, unregister } = useSharedElement();

  React.useEffect(() => {
    if (ref.current) {
      register(id, ref.current);
    }
    return () => unregister(id);
  }, [id]);

  return (
    <View ref={ref} style={style} collapsable={false}>
      {children}
    </View>
  );
};
```

---

## Loading & Skeleton Screens

### Complete Skeleton System

```typescript
// src/components/Skeleton/Skeleton.tsx
import React, { useEffect, useRef } from 'react';
import {
  View,
  StyleSheet,
  Animated,
  Easing,
  Dimensions,
  Platform,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { DesignSystem, responsive } from '../../styles/advanced';

interface SkeletonProps {
  width?: number | string;
  height?: number;
  borderRadius?: number;
  style?: any;
  children?: React.ReactNode;
}

/**
 * Skeleton - Base skeleton component with shimmer effect
 */
export const Skeleton: React.FC<SkeletonProps> = ({
  width = '100%',
  height = 20,
  borderRadius = DesignSystem.radii.sm,
  style,
  children,
}) => {
  const shimmer = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.loop(
      Animated.timing(shimmer, {
        toValue: 1,
        duration: 1200,
        easing: Easing.linear,
        useNativeDriver: false,
      })
    ).start();
  }, []);

  const shimmerInterpolate = shimmer.interpolate({
    inputRange: [0, 0.5, 1],
    outputRange: ['-100%', '100%', '200%'],
  });

  return (
    <View
      style={[
        styles.skeleton,
        {
          width,
          height,
          borderRadius,
          overflow: 'hidden',
        },
        style,
      ]}
    >
      {children}
      <Animated.View
        style={[
          styles.shimmer,
          {
            transform: [{ translateX: shimmerInterpolate }],
          },
        ]}
      >
        <LinearGradient
          colors={[
            'rgba(255,255,255,0)',
            'rgba(255,255,255,0.3)',
            'rgba(255,255,255,0)',
          ]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 0 }}
          style={styles.gradient}
        />
      </Animated.View>
    </View>
  );
};

/**
 * SkeletonText - Skeleton for text content
 */
export const SkeletonText: React.FC<{
  lines?: number;
  lineHeight?: number;
  width?: number | string;
}> = ({ lines = 3, lineHeight = 20, width = '100%' }) => {
  return (
    <View style={styles.textContainer}>
      {Array.from({ length: lines }).map((_, index) => (
        <Skeleton
          key={index}
          width={index === lines - 1 ? '60%' : width}
          height={lineHeight}
          style={[styles.textLine, index > 0 && { marginTop: 8 }]}
        />
      ))}
    </View>
  );
};

/**
 * SkeletonCard - Skeleton for card content
 */
export const SkeletonCard: React.FC<{
  image?: boolean;
  title?: boolean;
  subtitle?: boolean;
  actions?: boolean;
}> = ({ image = true, title = true, subtitle = true, actions = true }) => {
  return (
    <View style={styles.card}>
      {image && (
        <Skeleton
          width="100%"
          height={200}
          borderRadius={DesignSystem.radii.md}
        />
      )}
      <View style={styles.cardContent}>
        {title && <SkeletonText lines={1} width="70%" />}
        {subtitle && <SkeletonText lines={2} width="90%" />}
        {actions && (
          <View style={styles.cardActions}>
            <Skeleton width={80} height={36} borderRadius={DesignSystem.radii.md} />
            <Skeleton width={80} height={36} borderRadius={DesignSystem.radii.md} />
          </View>
        )}
      </View>
    </View>
  );
};

/**
 * SkeletonList - Skeleton for list view
 */
export const SkeletonList: React.FC<{
  count?: number;
  showAvatar?: boolean;
}> = ({ count = 5, showAvatar = true }) => {
  return (
    <View style={styles.listContainer}>
      {Array.from({ length: count }).map((_, index) => (
        <View key={index} style={styles.listItem}>
          {showAvatar && (
            <Skeleton
              width={40}
              height={40}
              borderRadius={DesignSystem.radii.round}
              style={styles.avatar}
            />
          )}
          <View style={styles.listContent}>
            <SkeletonText lines={2} width="90%" />
          </View>
        </View>
      ))}
    </View>
  );
};

/**
 * SkeletonScreen - Full screen skeleton
 */
export const SkeletonScreen: React.FC<{
  type?: 'list' | 'card' | 'detail' | 'profile';
}> = ({ type = 'list' }) => {
  switch (type) {
    case 'card':
      return (
        <View style={styles.screenContainer}>
          <SkeletonCard />
          <SkeletonCard />
          <SkeletonCard />
        </View>
      );
    case 'detail':
      return (
        <View style={styles.screenContainer}>
          <Skeleton width="100%" height={250} />
          <View style={styles.detailContent}>
            <SkeletonText lines={3} width="100%" />
            <SkeletonText lines={4} width="100%" />
            <View style={styles.detailActions}>
              <Skeleton width="100%" height={48} borderRadius={DesignSystem.radii.md} />
            </View>
          </View>
        </View>
      );
    case 'profile':
      return (
        <View style={styles.screenContainer}>
          <View style={styles.profileHeader}>
            <Skeleton
              width={80}
              height={80}
              borderRadius={DesignSystem.radii.round}
            />
            <SkeletonText lines={2} width="60%" />
          </View>
          <View style={styles.profileStats}>
            {Array.from({ length: 3 }).map((_, index) => (
              <View key={index} style={styles.statItem}>
                <Skeleton width={40} height={20} />
                <Skeleton width={30} height={12} />
              </View>
            ))}
          </View>
          <SkeletonList count={3} showAvatar={false} />
        </View>
      );
    default:
      return (
        <View style={styles.screenContainer}>
          <SkeletonList count={8} />
        </View>
      );
  }
};

const styles = StyleSheet.create({
  skeleton: {
    backgroundColor: '#e0e0e0',
    position: 'relative',
  },
  shimmer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  gradient: {
    width: '100%',
    height: '100%',
    ...Platform.select({
      ios: {
        transform: [{ skewX: '-20deg' }],
      },
      android: {
        transform: [{ skewX: '-20deg' }],
      },
    }),
  },
  textContainer: {
    gap: 8,
  },
  textLine: {
    backgroundColor: '#e0e0e0',
    borderRadius: DesignSystem.radii.sm,
  },
  card: {
    backgroundColor: '#ffffff',
    borderRadius: DesignSystem.radii.md,
    marginHorizontal: responsive.padding(16),
    marginVertical: responsive.padding(8),
    overflow: 'hidden',
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
  cardContent: {
    padding: DesignSystem.spacing.md,
    gap: 12,
  },
  cardActions: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    gap: 8,
    marginTop: 8,
  },
  listContainer: {
    padding: responsive.padding(16),
    gap: 8,
  },
  listItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#ffffff',
    padding: DesignSystem.spacing.md,
    borderRadius: DesignSystem.radii.md,
    gap: 12,
  },
  avatar: {
    flexShrink: 0,
  },
  listContent: {
    flex: 1,
  },
  screenContainer: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  detailContent: {
    padding: DesignSystem.spacing.md,
    gap: 16,
  },
  detailActions: {
    marginTop: 8,
  },
  profileHeader: {
    alignItems: 'center',
    padding: DesignSystem.spacing.xl,
    backgroundColor: '#ffffff',
    gap: 12,
  },
  profileStats: {
    flexDirection: 'row',
    padding: DesignSystem.spacing.md,
    backgroundColor: '#ffffff',
    marginVertical: 8,
  },
  statItem: {
    flex: 1,
    alignItems: 'center',
    gap: 4,
  },
});
```

---

## Platform-Specific Styling

### Platform-Aware Components

```typescript
// src/utils/platform.ts
import { Platform, StatusBar, Dimensions } from 'react-native';
import * as Device from 'expo-device';

export const PlatformUtils = {
  /**
   * Check if running on iOS
   */
  isIOS: Platform.OS === 'ios',

  /**
   * Check if running on Android
   */
  isAndroid: Platform.OS === 'android',

  /**
   * Check if running on web
   */
  isWeb: Platform.OS === 'web',

  /**
   * Check if running on a tablet
   */
  isTablet: () => {
    const { width, height } = Dimensions.get('window');
    return Math.min(width, height) >= 768;
  },

  /**
   * Get device model name
   */
  getDeviceModel: () => {
    return Device.modelName || 'Unknown';
  },

  /**
   * Check if device has a notch
   */
  hasNotch: () => {
    if (Platform.OS === 'ios') {
      const { height } = Dimensions.get('window');
      return height >= 812; // iPhone X and above
    }
    return false;
  },

  /**
   * Get status bar height
   */
  getStatusBarHeight: () => {
    return StatusBar.currentHeight || 0;
  },

  /**
   * Get navigation bar height (Android)
   */
  getNavigationBarHeight: () => {
    if (Platform.OS === 'android') {
      // Navigation bar height varies by device
      return 48;
    }
    return 0;
  },

  /**
   * Check if device supports haptic feedback
   */
  supportsHaptic: () => {
    return Platform.OS !== 'web';
  },
};

/**
 * Platform-specific style selector
 */
export const platformStyle = <T extends any>(
  ios: T,
  android: T,
  web: T = ios
): T => {
  if (Platform.OS === 'ios') return ios;
  if (Platform.OS === 'android') return android;
  return web;
};

/**
 * Platform-specific stylesheet
 */
export const createPlatformStyles = (styles: {
  ios?: any;
  android?: any;
  web?: any;
  default?: any;
}) => {
  const defaultStyles = styles.default || {};
  const platformStyles = Platform.select({
    ios: styles.ios,
    android: styles.android,
    web: styles.web,
  }) || {};

  return StyleSheet.create({
    ...defaultStyles,
    ...platformStyles,
  });
};

// Usage example
const platformAwareStyles = createPlatformStyles({
  default: {
    container: {
      flex: 1,
      backgroundColor: '#ffffff',
    },
  },
  ios: {
    container: {
      paddingTop: 44,
    },
  },
  android: {
    container: {
      paddingTop: StatusBar.currentHeight,
    },
  },
});
```

---

## Performance Optimization for Animations

### Animation Performance Checklist

```typescript
// src/utils/animations/performance.ts
/**
 * Animation Performance Optimization Guide
 * 
 * Following these guidelines ensures smooth 60fps animations:
 */

export const AnimationPerformanceGuide = {
  // 1. Use Native Driver
  useNativeDriver: {
    description: 'Enable native driver for all animations',
    // ✅ Do this
    good: `
      Animated.timing(value, {
        toValue: 1,
        duration: 300,
        useNativeDriver: true, // ✅
      })
    `,
    // ❌ Avoid this
    bad: `
      Animated.timing(value, {
        toValue: 1,
        duration: 300,
        useNativeDriver: false, // ❌
      })
    `,
  },

  // 2. Animate Only Transform and Opacity
  supportedProperties: {
    description: 'Only animatable properties should be transformed',
    // ✅ Do this
    good: `
      animatedStyle: {
        transform: [{ translateX: x.value }],
        opacity: opacity.value,
      }
    `,
    // ❌ Avoid this
    bad: `
      animatedStyle: {
        width: width.value, // ❌
        backgroundColor: color.value, // ❌
      }
    `,
  },

  // 3. Avoid Creating New Animated Values in Render
  valueCreation: {
    description: 'Create animated values outside render cycle',
    // ✅ Do this
    good: `
      const value = useRef(new Animated.Value(0)).current;
    `,
    // ❌ Avoid this
    bad: `
      const value = new Animated.Value(0); // ❌ Will create on every render
    `,
  },

  // 4. Use Reanimated 2 for Complex Animations
  reanimated: {
    description: 'Use Reanimated 2 for gesture-driven animations',
    // ✅ Do this
    good: `
      import Animated, { useSharedValue, withSpring } from 'react-native-reanimated';
      
      const translateX = useSharedValue(0);
      translateX.value = withSpring(100);
    `,
    // ❌ Avoid this
    bad: `
      // Using Animated for complex gestures
      Animated.spring(value, { toValue: 100 }).start(); // ❌
    `,
  },

  // 5. Batch Animated Updates
  batching: {
    description: 'Batch multiple animations together',
    // ✅ Do this
    good: `
      Animated.parallel([
        Animated.timing(a, { toValue: 1, useNativeDriver: true }),
        Animated.timing(b, { toValue: 1, useNativeDriver: true }),
      ]).start();
    `,
    // ❌ Avoid this
    bad: `
      Animated.timing(a, { toValue: 1 }).start();
      Animated.timing(b, { toValue: 1 }).start(); // ❌ Separate calls
    `,
  },

  // 6. Use InteractionManager for Heavy Operations
  interactionManager: {
    description: 'Schedule heavy operations after interactions',
    // ✅ Do this
    good: `
      InteractionManager.runAfterInteractions(() => {
        // Heavy operation
      });
    `,
    // ❌ Avoid this
    bad: `
      // Heavy operation blocking animation
    `,
  },
};

/**
 * Animation Performance Monitor
 */
export class AnimationPerformanceMonitor {
  private frameCount = 0;
  private lastFrameTime = 0;
  private fps = 60;
  private isRecording = false;

  startMonitoring() {
    this.isRecording = true;
    this.frameCount = 0;
    this.lastFrameTime = performance.now();
    this.measureFrame();
  }

  private measureFrame() {
    if (!this.isRecording) return;

    const now = performance.now();
    this.frameCount++;

    if (now - this.lastFrameTime >= 1000) {
      this.fps = this.frameCount;
      this.frameCount = 0;
      this.lastFrameTime = now;
      
      if (this.fps < 55) {
        console.warn(`⚠️ Low FPS detected: ${this.fps}`);
      }
    }

    requestAnimationFrame(this.measureFrame.bind(this));
  }

  stopMonitoring() {
    this.isRecording = false;
  }

  getFPS(): number {
    return this.fps;
  }
}
```

---

This appendix provides everything you need to create production-ready, beautifully animated, and highly performant React Native applications. The patterns and utilities included here are used in real-world apps and will help you build a polished user experience.

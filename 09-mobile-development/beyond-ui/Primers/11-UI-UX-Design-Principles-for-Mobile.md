# Primer 11: UI/UX Design Principles for Mobile

## Your Complete Guide to Beautiful, User-Friendly Mobile Interfaces

Welcome to the UI/UX Design Primer! This guide covers essential design principles for creating beautiful, intuitive, and user-friendly mobile interfaces. Good design is not just about aesthetics—it's about creating experiences that users love.

---

## D.1 Understanding Mobile UI/UX

### The Concept: Design That Works

UI (User Interface) is what users see—the visual elements, colors, typography, and layout. UX (User Experience) is how users feel when interacting with your app—the flow, ease of use, and satisfaction.

**Simple Analogy:** Think of UI/UX like a well-designed restaurant. UI is the decor, table settings, and menu design. UX is how the service flows—how you're seated, how easy it is to order, how the food arrives, and how you pay. Both must work together for a great experience.

### Mobile Design Principles

| Principle | Description | Example |
|-----------|-------------|---------|
| Clarity | Everything should be obvious and understandable | Clear labels, intuitive icons |
| Consistency | Similar elements should behave similarly | Same button styles throughout |
| Feedback | Users should know what's happening | Loading spinners, success messages |
| Efficiency | Help users accomplish tasks quickly | Shortcuts, autocomplete |
| Accessibility | App should work for everyone | Text sizing, color contrast |
| Simplicity | Less is more | Remove unnecessary elements |
| Familiarity | Use patterns users know | Standard navigation patterns |

---

## D.2 Color Theory

### The Concept: Communicating with Color

Color is one of the most powerful design tools. It communicates mood, creates hierarchy, and guides users.

### Complete Color Guide

```typescript
// 1. Color Palette
// src/themes/colors.ts
export const colors = {
  // Primary Colors
  primary: {
    50: '#e3f2fd',
    100: '#bbdefb',
    200: '#90caf9',
    300: '#64b5f6',
    400: '#42a5f5',
    500: '#2196f3', // Brand primary
    600: '#1e88e5',
    700: '#1976d2',
    800: '#1565c0',
    900: '#0d47a1',
  },
  
  // Secondary Colors
  secondary: {
    50: '#fce4ec',
    100: '#f8bbd0',
    200: '#f48fb1',
    300: '#f06292',
    400: '#ec407a',
    500: '#e91e63',
    600: '#d81b60',
    700: '#c2185b',
    800: '#ad1457',
    900: '#880e4f',
  },
  
  // Semantic Colors
  success: '#4caf50',
  warning: '#ff9800',
  error: '#f44336',
  info: '#2196f3',
  
  // Neutral Colors
  gray: {
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
  
  // Text Colors
  text: {
    primary: '#212121',
    secondary: '#757575',
    disabled: '#9e9e9e',
    inverse: '#ffffff',
  },
  
  // Background Colors
  background: '#ffffff',
  surface: '#f5f5f5',
  card: '#ffffff',
  
  // Status Colors
  status: {
    online: '#4caf50',
    offline: '#9e9e9e',
    busy: '#f44336',
    away: '#ff9800',
  },
};

// 2. Color Usage Guidelines
export const colorUsage = {
  // Use primary color for:
  // - Main actions (buttons, links)
  // - Selected state
  // - Brand emphasis
  
  // Use secondary color for:
  // - Accent elements
  // - Call-to-action buttons
  // - Highlights
  
  // Use semantic colors for:
  // - Success: positive outcomes
  // - Warning: cautionary states
  // - Error: failures and problems
  // - Info: informational messages
  
  // Use neutral colors for:
  // - Text
  // - Borders
  // - Dividers
  // - Backgrounds
};

// 3. Color Contrast
export const contrastCheck = (foreground: string, background: string): number => {
  // Calculate contrast ratio
  // Should be at least 4.5:1 for normal text
  // At least 3:1 for large text
  return 0;
};

// 4. Dark Theme Colors
export const darkColors = {
  ...colors,
  background: '#121212',
  surface: '#1e1e1e',
  card: '#2d2d2d',
  text: {
    primary: '#ffffff',
    secondary: '#b0b0b0',
    disabled: '#6b6b6b',
    inverse: '#212121',
  },
};
```

---

## D.3 Typography

### The Concept: Readable Text

Typography is about more than just choosing a font—it's about creating hierarchy, improving readability, and establishing personality.

### Complete Typography Guide

```typescript
// 1. Typography System
// src/themes/typography.ts
import { Platform } from 'react-native';

export const typography = {
  // Font Families
  fontFamily: Platform.select({
    ios: 'System',
    android: 'Roboto',
    default: 'System',
  }),
  
  fontFamilyBold: Platform.select({
    ios: 'System',
    android: 'Roboto-Bold',
    default: 'System',
  }),
  
  // Font Sizes
  fontSize: {
    xs: 10,
    sm: 12,
    md: 14,
    base: 16,
    lg: 18,
    xl: 20,
    xxl: 24,
    xxxl: 32,
    huge: 40,
    giant: 48,
  },
  
  // Line Heights
  lineHeight: {
    tight: 1.2,
    normal: 1.5,
    relaxed: 1.8,
  },
  
  // Font Weights
  weight: {
    light: '300',
    regular: '400',
    medium: '500',
    semibold: '600',
    bold: '700',
    extrabold: '800',
  } as const,
  
  // Letter Spacing
  letterSpacing: {
    tight: -0.5,
    normal: 0,
    wide: 1,
    wider: 2,
  },
};

// 2. Text Variants
export const textVariants = {
  // Headings
  h1: {
    fontSize: typography.fontSize.huge,
    fontWeight: typography.weight.bold,
    lineHeight: typography.lineHeight.tight * typography.fontSize.huge,
    letterSpacing: typography.letterSpacing.tight,
  },
  h2: {
    fontSize: typography.fontSize.xxxl,
    fontWeight: typography.weight.bold,
    lineHeight: typography.lineHeight.tight * typography.fontSize.xxxl,
    letterSpacing: typography.letterSpacing.tight,
  },
  h3: {
    fontSize: typography.fontSize.xxl,
    fontWeight: typography.weight.semibold,
    lineHeight: typography.lineHeight.tight * typography.fontSize.xxl,
  },
  h4: {
    fontSize: typography.fontSize.xl,
    fontWeight: typography.weight.semibold,
    lineHeight: typography.lineHeight.normal * typography.fontSize.xl,
  },
  
  // Body
  body: {
    fontSize: typography.fontSize.base,
    fontWeight: typography.weight.regular,
    lineHeight: typography.lineHeight.normal * typography.fontSize.base,
  },
  bodyLarge: {
    fontSize: typography.fontSize.lg,
    fontWeight: typography.weight.regular,
    lineHeight: typography.lineHeight.normal * typography.fontSize.lg,
  },
  bodySmall: {
    fontSize: typography.fontSize.md,
    fontWeight: typography.weight.regular,
    lineHeight: typography.lineHeight.normal * typography.fontSize.md,
  },
  
  // Captions
  caption: {
    fontSize: typography.fontSize.sm,
    fontWeight: typography.weight.regular,
    lineHeight: typography.lineHeight.normal * typography.fontSize.sm,
  },
  captionSmall: {
    fontSize: typography.fontSize.xs,
    fontWeight: typography.weight.regular,
    lineHeight: typography.lineHeight.normal * typography.fontSize.xs,
  },
  
  // Buttons
  button: {
    fontSize: typography.fontSize.md,
    fontWeight: typography.weight.semibold,
    lineHeight: typography.lineHeight.normal * typography.fontSize.md,
  },
  
  // Labels
  label: {
    fontSize: typography.fontSize.sm,
    fontWeight: typography.weight.medium,
    lineHeight: typography.lineHeight.normal * typography.fontSize.sm,
  },
};

// 3. Typography Component
import { Text, TextProps } from 'react-native';
import { typography, textVariants } from '@themes/typography';

interface TypographyProps extends TextProps {
  variant?: keyof typeof textVariants;
  color?: string;
}

export const Typography: React.FC<TypographyProps> = ({
  variant = 'body',
  color,
  style,
  children,
  ...props
}) => {
  const variantStyles = textVariants[variant];
  
  return (
    <Text
      style={[
        variantStyles,
        { color: color || colors.text.primary },
        style,
      ]}
      {...props}
    >
      {children}
    </Text>
  );
};
```

---

## D.4 Spacing & Layout

### The Concept: Visual Harmony

Spacing creates rhythm and hierarchy in your design. Proper spacing makes your app feel polished and professional.

### Complete Spacing Guide

```typescript
// 1. Spacing System
// src/themes/spacing.ts
export const spacing = {
  // Base spacing unit (8px grid)
  base: 8,
  
  // Spacing scale
  xs: 2,     // 2px
  sm: 4,     // 4px
  md: 8,     // 8px
  lg: 12,    // 12px
  xl: 16,    // 16px
  xxl: 24,   // 24px
  xxxl: 32,  // 32px
  huge: 48,  // 48px
  giant: 64, // 64px
  
  // Semantic spacing
  padding: {
    screen: 16,
    card: 16,
    button: {
      vertical: 12,
      horizontal: 24,
    },
    input: {
      vertical: 12,
      horizontal: 16,
    },
  },
  
  margin: {
    screen: 16,
    card: 16,
    between: 8,
    section: 24,
  },
  
  gap: {
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
    xxl: 32,
  },
};

// 2. Layout Components
import { View, ViewProps } from 'react-native';
import { spacing } from '@themes/spacing';

interface StackProps extends ViewProps {
  spacing?: keyof typeof spacing.gap;
  direction?: 'column' | 'row';
  align?: 'flex-start' | 'center' | 'flex-end' | 'stretch';
  justify?: 'flex-start' | 'center' | 'flex-end' | 'space-between' | 'space-around';
}

export const Stack: React.FC<StackProps> = ({
  spacing: gap = 'md',
  direction = 'column',
  align = 'stretch',
  justify = 'flex-start',
  style,
  children,
  ...props
}) => {
  return (
    <View
      style={[
        {
          flexDirection: direction,
          alignItems: align,
          justifyContent: justify,
          gap: spacing.gap[gap],
        },
        style,
      ]}
      {...props}
    >
      {children}
    </View>
  );
};

// 3. Spacing Utilities
export const spacingUtils = {
  // Padding
  p: (size: keyof typeof spacing) => ({ padding: spacing[size] }),
  px: (size: keyof typeof spacing) => ({ paddingHorizontal: spacing[size] }),
  py: (size: keyof typeof spacing) => ({ paddingVertical: spacing[size] }),
  pt: (size: keyof typeof spacing) => ({ paddingTop: spacing[size] }),
  pb: (size: keyof typeof spacing) => ({ paddingBottom: spacing[size] }),
  pl: (size: keyof typeof spacing) => ({ paddingLeft: spacing[size] }),
  pr: (size: keyof typeof spacing) => ({ paddingRight: spacing[size] }),
  
  // Margin
  m: (size: keyof typeof spacing) => ({ margin: spacing[size] }),
  mx: (size: keyof typeof spacing) => ({ marginHorizontal: spacing[size] }),
  my: (size: keyof typeof spacing) => ({ marginVertical: spacing[size] }),
  mt: (size: keyof typeof spacing) => ({ marginTop: spacing[size] }),
  mb: (size: keyof typeof spacing) => ({ marginBottom: spacing[size] }),
  ml: (size: keyof typeof spacing) => ({ marginLeft: spacing[size] }),
  mr: (size: keyof typeof spacing) => ({ marginRight: spacing[size] }),
};

// 4. Responsive Layout
import { Dimensions } from 'react-native';

const { width, height } = Dimensions.get('window');

export const responsive = {
  // Width scaling
  w: (percentage: number) => width * (percentage / 100),
  
  // Height scaling
  h: (percentage: number) => height * (percentage / 100),
  
  // Responsive size
  size: (size: number) => Math.min(width, height) * (size / 375),
  
  // Font size responsive
  fontSize: (size: number) => Math.min(width, height) * (size / 375),
};

// 5. Breakpoints
export const breakpoints = {
  small: 375,  // iPhone SE
  medium: 414, // iPhone 12
  large: 768,  // iPad Mini
  xlarge: 1024, // iPad Pro
};

export const isSmallDevice = width < breakpoints.small;
export const isTablet = width >= breakpoints.large;
```

---

## D.5 Component Design

### The Concept: Reusable Building Blocks

Well-designed components create consistency and speed up development.

### Complete Component Design Guide

```typescript
// 1. Button Component
// src/components/common/Button.tsx
import { TouchableOpacity, Text, ActivityIndicator, ViewStyle } from 'react-native';
import { colors } from '@themes/colors';
import { spacing } from '@themes/spacing';
import { typography } from '@themes/typography';

interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'outline' | 'danger' | 'ghost';
  size?: 'small' | 'medium' | 'large';
  loading?: boolean;
  disabled?: boolean;
  fullWidth?: boolean;
  style?: ViewStyle;
  icon?: React.ReactNode;
}

export const Button: React.FC<ButtonProps> = ({
  title,
  onPress,
  variant = 'primary',
  size = 'medium',
  loading = false,
  disabled = false,
  fullWidth = false,
  style,
  icon,
}) => {
  const getVariantStyles = () => {
    switch (variant) {
      case 'primary':
        return {
          backgroundColor: colors.primary[500],
          textColor: '#ffffff',
        };
      case 'secondary':
        return {
          backgroundColor: colors.secondary[500],
          textColor: '#ffffff',
        };
      case 'outline':
        return {
          backgroundColor: 'transparent',
          borderWidth: 1,
          borderColor: colors.primary[500],
          textColor: colors.primary[500],
        };
      case 'danger':
        return {
          backgroundColor: colors.error,
          textColor: '#ffffff',
        };
      case 'ghost':
        return {
          backgroundColor: 'transparent',
          textColor: colors.primary[500],
        };
    }
  };

  const getSizeStyles = () => {
    switch (size) {
      case 'small':
        return {
          paddingVertical: spacing.sm,
          paddingHorizontal: spacing.md,
          fontSize: typography.fontSize.sm,
        };
      case 'large':
        return {
          paddingVertical: spacing.lg,
          paddingHorizontal: spacing.xl,
          fontSize: typography.fontSize.lg,
        };
      default:
        return {
          paddingVertical: spacing.md,
          paddingHorizontal: spacing.lg,
          fontSize: typography.fontSize.md,
        };
    }
  };

  const variantStyles = getVariantStyles();
  const sizeStyles = getSizeStyles();

  return (
    <TouchableOpacity
      onPress={onPress}
      disabled={disabled || loading}
      style={[
        {
          borderRadius: 8,
          alignItems: 'center',
          justifyContent: 'center',
          flexDirection: 'row',
          opacity: disabled ? 0.6 : 1,
          width: fullWidth ? '100%' : 'auto',
        },
        variantStyles,
        sizeStyles,
        style,
      ]}
    >
      {loading ? (
        <ActivityIndicator color={variantStyles.textColor} />
      ) : (
        <>
          {icon}
          <Text style={{ color: variantStyles.textColor, fontSize: sizeStyles.fontSize }}>
            {title}
          </Text>
        </>
      )}
    </TouchableOpacity>
  );
};

// 2. Card Component
// src/components/common/Card.tsx
interface CardProps {
  children: React.ReactNode;
  elevation?: boolean;
  padding?: keyof typeof spacing;
  style?: ViewStyle;
}

export const Card: React.FC<CardProps> = ({
  children,
  elevation = true,
  padding = 'md',
  style,
}) => {
  return (
    <View
      style={[
        {
          backgroundColor: '#ffffff',
          borderRadius: 12,
          padding: spacing[padding],
          shadowColor: '#000',
          shadowOffset: { width: 0, height: 2 },
          shadowOpacity: 0.1,
          shadowRadius: 4,
          elevation: elevation ? 3 : 0,
        },
        style,
      ]}
    >
      {children}
    </View>
  );
};

// 3. Input Component
// src/components/common/Input.tsx
interface InputProps extends TextInputProps {
  label?: string;
  error?: string;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  touched?: boolean;
}

export const Input: React.FC<InputProps> = ({
  label,
  error,
  leftIcon,
  rightIcon,
  touched,
  ...props
}) => {
  const [isFocused, setIsFocused] = useState(false);
  const showError = touched && error;

  return (
    <View style={{ marginBottom: spacing.md }}>
      {label && (
        <Text style={{ marginBottom: spacing.xs, color: colors.text.primary }}>
          {label}
        </Text>
      )}
      
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          borderWidth: 1,
          borderColor: showError ? colors.error : isFocused ? colors.primary[500] : colors.gray[300],
          borderRadius: 8,
          backgroundColor: colors.background,
        }}
      >
        {leftIcon && (
          <View style={{ paddingLeft: spacing.md }}>
            {leftIcon}
          </View>
        )}
        
        <TextInput
          style={{
            flex: 1,
            paddingVertical: spacing.md,
            paddingHorizontal: spacing.md,
            fontSize: typography.fontSize.md,
            color: colors.text.primary,
          }}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          {...props}
        />
        
        {rightIcon && (
          <View style={{ paddingRight: spacing.md }}>
            {rightIcon}
          </View>
        )}
      </View>
      
      {showError && (
        <Text style={{ color: colors.error, fontSize: typography.fontSize.sm, marginTop: spacing.xs }}>
          {error}
        </Text>
      )}
    </View>
  );
};
```

---

## D.6 Accessibility

### The Concept: Design for Everyone

Accessibility ensures your app works for everyone, including people with disabilities.

### Complete Accessibility Guide

```typescript
// 1. Accessibility Properties
// src/components/common/AccessibleButton.tsx
interface AccessibleButtonProps extends ButtonProps {
  accessibilityLabel?: string;
  accessibilityHint?: string;
  role?: 'button' | 'link' | 'checkbox' | 'radio' | 'switch';
}

export const AccessibleButton: React.FC<AccessibleButtonProps> = ({
  accessibilityLabel,
  accessibilityHint,
  role = 'button',
  ...props
}) => {
  return (
    <TouchableOpacity
      accessibilityLabel={accessibilityLabel}
      accessibilityHint={accessibilityHint}
      accessibilityRole={role}
      accessible={true}
      {...props}
    >
      {/* Button content */}
    </TouchableOpacity>
  );
};

// 2. Accessibility Hook
import { AccessibilityInfo } from 'react-native';

export const useAccessibility = () => {
  const [isReduceMotionEnabled, setIsReduceMotionEnabled] = useState(false);
  const [isScreenReaderEnabled, setIsScreenReaderEnabled] = useState(false);

  useEffect(() => {
    // Check if reduce motion is enabled
    AccessibilityInfo.isReduceMotionEnabled().then(setIsReduceMotionEnabled);
    const reduceMotionSubscription = AccessibilityInfo.addEventListener(
      'reduceMotionChanged',
      setIsReduceMotionEnabled
    );

    // Check if screen reader is enabled
    AccessibilityInfo.isScreenReaderEnabled().then(setIsScreenReaderEnabled);
    const screenReaderSubscription = AccessibilityInfo.addEventListener(
      'screenReaderChanged',
      setIsScreenReaderEnabled
    );

    return () => {
      reduceMotionSubscription.remove();
      screenReaderSubscription.remove();
    };
  }, []);

  return {
    isReduceMotionEnabled,
    isScreenReaderEnabled,
  };
};

// 3. Accessible Components
// Use in components:
<View
  accessible={true}
  accessibilityLabel="User profile photo"
  accessibilityHint="Double tap to view full profile"
  accessibilityRole="imagebutton"
>
  <Image source={avatar} />
</View>

// 4. Color Contrast Check
// Ensure color contrast ratio is at least 4.5:1 for normal text
// Use tools like: https://webaim.org/resources/contrastchecker/

// 5. Font Scaling
import { Text } from 'react-native';

// Allow font scaling for accessibility
<Text allowFontScaling={true}>
  This text scales with system font size
</Text>

// 6. Dynamic Type (iOS)
// Use iOS system fonts for better accessibility
const styles = StyleSheet.create({
  text: {
    fontFamily: Platform.OS === 'ios' ? 'System' : 'Roboto',
  },
});
```

---

## D.7 Animation & Feedback

### The Concept: Delightful Interactions

Animations and feedback make your app feel alive and responsive.

### Complete Animation Guide

```typescript
// 1. Basic Animations
import { Animated, Easing } from 'react-native';

// Fade in animation
const FadeInView: React.FC = ({ children }) => {
  const fadeAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(fadeAnim, {
      toValue: 1,
      duration: 300,
      useNativeDriver: true,
      easing: Easing.ease,
    }).start();
  }, []);

  return (
    <Animated.View style={{ opacity: fadeAnim }}>
      {children}
    </Animated.View>
  );
};

// 2. Feedback Animations
const FeedbackButton: React.FC<ButtonProps> = ({ onPress, children }) => {
  const scaleAnim = useRef(new Animated.Value(1)).current;

  const handlePressIn = () => {
    Animated.spring(scaleAnim, {
      toValue: 0.95,
      useNativeDriver: true,
      speed: 50,
    }).start();
  };

  const handlePressOut = () => {
    Animated.spring(scaleAnim, {
      toValue: 1,
      useNativeDriver: true,
      speed: 50,
    }).start();
  };

  return (
    <Animated.View style={{ transform: [{ scale: scaleAnim }] }}>
      <TouchableOpacity
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        onPress={onPress}
      >
        {children}
      </TouchableOpacity>
    </Animated.View>
  );
};

// 3. Skeleton Loading
const SkeletonLoader: React.FC = () => {
  const opacityAnim = useRef(new Animated.Value(0.3)).current;

  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(opacityAnim, {
          toValue: 0.7,
          duration: 800,
          useNativeDriver: true,
        }),
        Animated.timing(opacityAnim, {
          toValue: 0.3,
          duration: 800,
          useNativeDriver: true,
        }),
      ])
    ).start();
  }, []);

  return (
    <Animated.View
      style={{
        opacity: opacityAnim,
        backgroundColor: colors.gray[300],
        borderRadius: 8,
        height: 100,
      }}
    />
  );
};

// 4. Haptic Feedback
import * as Haptics from 'expo-haptics';

const handlePress = () => {
  Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
  // Perform action
};

// 5. Toast Feedback
// src/components/common/Toast.tsx
export const Toast: React.FC<{ message: string; type?: 'success' | 'error' | 'info' }> = ({
  message,
  type = 'info',
}) => {
  const translateY = useRef(new Animated.Value(-100)).current;

  useEffect(() => {
    Animated.spring(translateY, {
      toValue: 0,
      useNativeDriver: true,
      speed: 200,
    }).start();

    setTimeout(() => {
      Animated.timing(translateY, {
        toValue: -100,
        duration: 300,
        useNativeDriver: true,
      }).start();
    }, 3000);
  }, []);

  return (
    <Animated.View
      style={{
        transform: [{ translateY }],
        position: 'absolute',
        top: 40,
        left: 20,
        right: 20,
        padding: 16,
        borderRadius: 8,
        backgroundColor: type === 'success' ? colors.success : colors.error,
        zIndex: 999,
      }}
    >
      <Text style={{ color: '#ffffff', textAlign: 'center' }}>{message}</Text>
    </Animated.View>
  );
};
```

---

## D.8 Quick Reference

### Design Resources

| Resource | Type | URL |
|----------|------|-----|
| Material Design | Guidelines | material.io |
| Apple HIG | Guidelines | developer.apple.com/design |
| Figma | Design Tool | figma.com |
| Adobe Color | Color Tool | color.adobe.com |
| Font Awesome | Icons | fontawesome.com |

### Design Checklist

| Item | Status |
|------|--------|
| Color contrast ≥ 4.5:1 | ✅ |
| Font sizes ≥ 14pt | ✅ |
| Touch targets ≥ 44pt | ✅ |
| Accessible labels | ✅ |
| Consistent spacing | ✅ |
| Clear hierarchy | ✅ |
| Loading states | ✅ |
| Error handling | ✅ |
| Platform conventions | ✅ |
| Dark mode support | ✅ |

---

**Ready to create beautiful, user-friendly designs? Let's build NexusCollect!**

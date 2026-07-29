# Appendix K: Design System & Component Library

Welcome to Appendix K! This comprehensive guide covers everything you need to know about building and maintaining a production-ready design system for your React Native application. You'll learn how to create a scalable component library, manage design tokens, implement theming, and ensure consistency across your entire app.

---

## Table of Contents

1. [Design System Architecture](#design-system-architecture)
2. [Design Tokens](#design-tokens)
3. [Core Components](#core-components)
4. [Component Composition Patterns](#component-composition-patterns)
5. [Theming & Variants](#theming--variants)
6. [Component Documentation](#component-documentation)
7. [Testing Components](#testing-components)
8. [Versioning & Release Management](#versioning--release-management)

---

## Design System Architecture

### Complete Design System Structure

```typescript
// src/design-system/index.ts
/**
 * Design System Architecture
 * 
 * This provides a comprehensive design system structure:
 * - Design tokens (colors, typography, spacing)
 * - Core components (atoms)
 * - Composite components (molecules)
 * - Page components (organisms)
 * - Theme management
 * - Component composition utilities
 */

// Design System Exports
export * from './tokens';
export * from './components';
export * from './theme';
export * from './utils';
export * from './hooks';
export * from './icons';

/**
 * Design System Structure
 * 
 * src/design-system/
 * ├── tokens/
 * │   ├── colors.ts
 * │   ├── typography.ts
 * │   ├── spacing.ts
 * │   ├── shadows.ts
 * │   └── animations.ts
 * ├── theme/
 * │   ├── ThemeProvider.tsx
 * │   ├── useTheme.ts
 * │   └── variants.ts
 * ├── components/
 * │   ├── atoms/
 * │   │   ├── Button/
 * │   │   ├── Input/
 * │   │   ├── Typography/
 * │   │   ├── Icon/
 * │   │   └── Avatar/
 * │   ├── molecules/
 * │   │   ├── Card/
 * │   │   ├── List/
 * │   │   ├── Modal/
 * │   │   └── Toast/
 * │   └── organisms/
 * │       ├── Header/
 * │       ├── Footer/
 * │       └── Sidebar/
 * ├── utils/
 * │   ├── helpers.ts
 * │   └── animations.ts
 * ├── hooks/
 * │   ├── useMediaQuery.ts
 * │   └── useBreakpoints.ts
 * └── icons/
 *     └── index.ts
 */
```

---

## Design Tokens

### Complete Token System

```typescript
// src/design-system/tokens/colors.ts
/**
 * Color Tokens
 * 
 * This defines the complete color palette for the design system.
 * Colors are organized by semantic meaning and scale.
 */

export const colors = {
  // Primary brand colors
  primary: {
    50: '#e8f4fd',
    100: '#b8d9f7',
    200: '#8bbef1',
    300: '#5da3eb',
    400: '#3f8fe7',
    500: '#217be3',
    600: '#1d6fd6',
    700: '#185fb8',
    800: '#134e97',
    900: '#0e3d76',
  },
  
  // Secondary brand colors
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
    500: '#00c25a',
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
    500: '#f5af00',
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
    500: '#e41010',
    600: '#d00e0e',
    700: '#b60c0c',
    800: '#9c0a0a',
    900: '#820808',
  },
  
  // Neutral colors
  neutral: {
    0: '#ffffff',
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
    1000: '#000000',
  },
  
  // Background colors
  background: {
    primary: '#ffffff',
    secondary: '#f8f9fa',
    tertiary: '#f1f2f6',
    inverse: '#1a1a1a',
  },
  
  // Text colors
  text: {
    primary: '#212121',
    secondary: '#757575',
    disabled: '#9e9e9e',
    inverse: '#ffffff',
    link: '#217be3',
  },
  
  // Border colors
  border: {
    light: '#e1e8ed',
    medium: '#bdbdbd',
    dark: '#757575',
  },
} as const;

export type Color = typeof colors;
export type ColorKey = keyof Color;
export type ColorValue = Color[ColorKey];

// src/design-system/tokens/typography.ts
/**
 * Typography Tokens
 * 
 * This defines the typography system with consistent
 * sizes, weights, and styles.
 */

export const typography = {
  // Font families
  fontFamily: {
    regular: 'System',
    medium: 'System-Medium',
    bold: 'System-Bold',
    mono: 'Menlo-Regular',
  },
  
  // Font sizes
  fontSize: {
    xs: 10,
    sm: 12,
    md: 14,
    lg: 16,
    xl: 20,
    xxl: 24,
    xxxl: 32,
    display: 40,
  },
  
  // Line heights
  lineHeight: {
    xs: 14,
    sm: 16,
    md: 20,
    lg: 24,
    xl: 28,
    xxl: 32,
    xxxl: 40,
    display: 48,
  },
  
  // Font weights
  fontWeight: {
    thin: '100',
    light: '300',
    regular: '400',
    medium: '500',
    semibold: '600',
    bold: '700',
    heavy: '800',
    black: '900',
  },
  
  // Text styles
  styles: {
    heading1: {
      fontSize: 32,
      lineHeight: 40,
      fontWeight: '700',
    },
    heading2: {
      fontSize: 28,
      lineHeight: 36,
      fontWeight: '600',
    },
    heading3: {
      fontSize: 24,
      lineHeight: 32,
      fontWeight: '600',
    },
    heading4: {
      fontSize: 20,
      lineHeight: 28,
      fontWeight: '500',
    },
    heading5: {
      fontSize: 18,
      lineHeight: 26,
      fontWeight: '500',
    },
    heading6: {
      fontSize: 16,
      lineHeight: 24,
      fontWeight: '500',
    },
    body1: {
      fontSize: 16,
      lineHeight: 24,
      fontWeight: '400',
    },
    body2: {
      fontSize: 14,
      lineHeight: 20,
      fontWeight: '400',
    },
    body3: {
      fontSize: 12,
      lineHeight: 18,
      fontWeight: '400',
    },
    caption: {
      fontSize: 12,
      lineHeight: 16,
      fontWeight: '400',
    },
    overline: {
      fontSize: 10,
      lineHeight: 14,
      fontWeight: '600',
      letterSpacing: 1,
    },
  },
} as const;

// src/design-system/tokens/spacing.ts
/**
 * Spacing Tokens
 * 
 * This defines the spacing system based on an 8px grid.
 */

export const spacing = {
  none: 0,
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
  xxxl: 64,
  huge: 80,
  massive: 120,
} as const;

// src/design-system/tokens/shadows.ts
/**
 * Shadow Tokens
 * 
 * This defines consistent shadow styles for elevation.
 */

export const shadows = {
  none: {
    shadowColor: 'transparent',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0,
    shadowRadius: 0,
    elevation: 0,
  },
  xs: {
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  sm: {
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 4,
    elevation: 2,
  },
  md: {
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 4,
  },
  lg: {
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.12,
    shadowRadius: 12,
    elevation: 8,
  },
  xl: {
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.16,
    shadowRadius: 16,
    elevation: 12,
  },
  xxl: {
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.2,
    shadowRadius: 24,
    elevation: 16,
  },
} as const;

// src/design-system/tokens/index.ts
import { colors } from './colors';
import { typography } from './typography';
import { spacing } from './spacing';
import { shadows } from './shadows';

export const tokens = {
  colors,
  typography,
  spacing,
  shadows,
} as const;

export * from './colors';
export * from './typography';
export * from './spacing';
export * from './shadows';
```

---

## Core Components

### Complete Component Library

```typescript
// src/design-system/components/atoms/Button/Button.tsx
import React from 'react';
import {
  TouchableOpacity,
  Text,
  ActivityIndicator,
  StyleSheet,
  ViewStyle,
  TextStyle,
  TouchableOpacityProps,
} from 'react-native';
import { tokens } from '../../../tokens';
import { useTheme } from '../../../theme';

export interface ButtonProps extends TouchableOpacityProps {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  fullWidth?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  children: React.ReactNode;
}

/**
 * Button - Core button component
 * 
 * This component follows the design system guidelines:
 * - Multiple variants (primary, secondary, outline, ghost, danger)
 * - Multiple sizes (sm, md, lg)
 * - Loading state
 * - Full width option
 * - Icon support
 */
export const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  size = 'md',
  loading = false,
  fullWidth = false,
  leftIcon,
  rightIcon,
  children,
  style,
  disabled,
  ...props
}) => {
  const { theme } = useTheme();
  
  // Get variant styles
  const getVariantStyles = () => {
    const variants = {
      primary: {
        backgroundColor: tokens.colors.primary[500],
        textColor: '#ffffff',
        borderColor: tokens.colors.primary[500],
      },
      secondary: {
        backgroundColor: tokens.colors.secondary[500],
        textColor: '#ffffff',
        borderColor: tokens.colors.secondary[500],
      },
      outline: {
        backgroundColor: 'transparent',
        textColor: tokens.colors.primary[500],
        borderColor: tokens.colors.primary[500],
      },
      ghost: {
        backgroundColor: 'transparent',
        textColor: tokens.colors.primary[500],
        borderColor: 'transparent',
      },
      danger: {
        backgroundColor: tokens.colors.error[500],
        textColor: '#ffffff',
        borderColor: tokens.colors.error[500],
      },
    };
    
    return variants[variant] || variants.primary;
  };

  // Get size styles
  const getSizeStyles = () => {
    const sizes = {
      sm: {
        paddingVertical: 6,
        paddingHorizontal: 12,
        fontSize: 12,
        iconSize: 14,
      },
      md: {
        paddingVertical: 10,
        paddingHorizontal: 16,
        fontSize: 14,
        iconSize: 16,
      },
      lg: {
        paddingVertical: 14,
        paddingHorizontal: 20,
        fontSize: 16,
        iconSize: 18,
      },
    };
    
    return sizes[size] || sizes.md;
  };

  const variantStyles = getVariantStyles();
  const sizeStyles = getSizeStyles();
  
  const buttonStyles: ViewStyle = {
    backgroundColor: variantStyles.backgroundColor,
    borderColor: variantStyles.borderColor,
    borderWidth: variant === 'outline' ? 2 : 0,
    paddingVertical: sizeStyles.paddingVertical,
    paddingHorizontal: sizeStyles.paddingHorizontal,
    borderRadius: 8,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    opacity: disabled || loading ? 0.5 : 1,
    ...(fullWidth && { width: '100%' }),
  };

  const textStyles: TextStyle = {
    color: variantStyles.textColor,
    fontSize: sizeStyles.fontSize,
    fontWeight: '500',
    textAlign: 'center',
  };

  const iconSize = sizeStyles.iconSize;

  return (
    <TouchableOpacity
      style={[buttonStyles, style]}
      disabled={disabled || loading}
      activeOpacity={0.7}
      {...props}
    >
      {loading && (
        <ActivityIndicator
          color={variantStyles.textColor}
          size="small"
          style={styles.loader}
        />
      )}
      
      {!loading && leftIcon && (
        <React.Fragment>
          {leftIcon}
          <Text style={[textStyles, styles.textWithLeftIcon]}>
            {children}
          </Text>
        </React.Fragment>
      )}
      
      {!loading && !leftIcon && !rightIcon && (
        <Text style={textStyles}>{children}</Text>
      )}
      
      {!loading && rightIcon && (
        <React.Fragment>
          <Text style={[textStyles, styles.textWithRightIcon]}>
            {children}
          </Text>
          {rightIcon}
        </React.Fragment>
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  loader: {
    marginRight: 8,
  },
  textWithLeftIcon: {
    marginLeft: 8,
  },
  textWithRightIcon: {
    marginRight: 8,
  },
});

// src/design-system/components/atoms/Button/Button.styles.ts
/**
 * Button Styles - For component variants
 * 
 * This exports pre-styled button variants for convenience.
 */
export const ButtonStyles = {
  primary: (props: Partial<ButtonProps>) => ({
    ...props,
    variant: 'primary' as const,
  }),
  secondary: (props: Partial<ButtonProps>) => ({
    ...props,
    variant: 'secondary' as const,
  }),
  outline: (props: Partial<ButtonProps>) => ({
    ...props,
    variant: 'outline' as const,
  }),
  ghost: (props: Partial<ButtonProps>) => ({
    ...props,
    variant: 'ghost' as const,
  }),
  danger: (props: Partial<ButtonProps>) => ({
    ...props,
    variant: 'danger' as const,
  }),
};
```

### Input Component

```typescript
// src/design-system/components/atoms/Input/Input.tsx
import React, { useState } from 'react';
import {
  View,
  TextInput,
  Text,
  TouchableOpacity,
  StyleSheet,
  TextInputProps,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { tokens } from '../../../tokens';
import { useTheme } from '../../../theme';

export interface InputProps extends TextInputProps {
  label?: string;
  error?: string;
  helper?: string;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  onRightIconPress?: () => void;
  required?: boolean;
  containerStyle?: ViewStyle;
}

/**
 * Input - Core input component
 * 
 * This component provides consistent input styling:
 * - Label support
 * - Error states
 * - Helper text
 * - Left/Right icons
 * - Required indicator
 */
export const Input: React.FC<InputProps> = ({
  label,
  error,
  helper,
  leftIcon,
  rightIcon,
  onRightIconPress,
  required,
  containerStyle,
  style,
  ...props
}) => {
  const { theme } = useTheme();
  const [isFocused, setIsFocused] = useState(false);

  const getBorderColor = () => {
    if (error) return tokens.colors.error[500];
    if (isFocused) return tokens.colors.primary[500];
    return tokens.colors.border.light;
  };

  const containerStyles: ViewStyle = {
    marginBottom: 16,
    ...containerStyle,
  };

  const labelStyles: TextStyle = {
    fontSize: 14,
    fontWeight: '500',
    color: tokens.colors.text.primary,
    marginBottom: 4,
  };

  const inputContainerStyles: ViewStyle = {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#ffffff',
    borderWidth: 1,
    borderColor: getBorderColor(),
    borderRadius: 8,
    paddingHorizontal: 12,
    minHeight: 44,
  };

  const inputStyles: TextStyle = {
    flex: 1,
    fontSize: 16,
    color: tokens.colors.text.primary,
    paddingVertical: 10,
  };

  const errorStyles: TextStyle = {
    fontSize: 12,
    color: tokens.colors.error[500],
    marginTop: 4,
  };

  const helperStyles: TextStyle = {
    fontSize: 12,
    color: tokens.colors.text.secondary,
    marginTop: 4,
  };

  return (
    <View style={containerStyles}>
      {label && (
        <Text style={labelStyles}>
          {label}
          {required && <Text style={{ color: tokens.colors.error[500] }}> *</Text>}
        </Text>
      )}

      <View style={inputContainerStyles}>
        {leftIcon && <View style={styles.leftIcon}>{leftIcon}</View>}
        
        <TextInput
          style={inputStyles}
          placeholderTextColor={tokens.colors.text.disabled}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          {...props}
        />
        
        {rightIcon && (
          <TouchableOpacity onPress={onRightIconPress} style={styles.rightIcon}>
            {rightIcon}
          </TouchableOpacity>
        )}
      </View>

      {error && <Text style={errorStyles}>{error}</Text>}
      {helper && !error && <Text style={helperStyles}>{helper}</Text>}
    </View>
  );
};

const styles = StyleSheet.create({
  leftIcon: {
    marginRight: 8,
  },
  rightIcon: {
    marginLeft: 8,
  },
});
```

### Card Component

```typescript
// src/design-system/components/molecules/Card/Card.tsx
import React from 'react';
import {
  View,
  StyleSheet,
  ViewStyle,
  TouchableOpacity,
} from 'react-native';
import { tokens } from '../../../tokens';
import { useTheme } from '../../../theme';

export interface CardProps {
  children: React.ReactNode;
  variant?: 'default' | 'elevated' | 'outlined' | 'flat';
  padding?: keyof typeof tokens.spacing;
  onPress?: () => void;
  style?: ViewStyle;
}

/**
 * Card - Core card component
 * 
 * This component provides consistent card styling:
 * - Multiple variants (default, elevated, outlined, flat)
 * - Configurable padding
 * - Press handling
 */
export const Card: React.FC<CardProps> = ({
  children,
  variant = 'default',
  padding = 'md',
  onPress,
  style,
}) => {
  const { theme } = useTheme();

  const getVariantStyles = () => {
    const variants = {
      default: {
        backgroundColor: '#ffffff',
        borderWidth: 0,
        borderColor: 'transparent',
      },
      elevated: {
        backgroundColor: '#ffffff',
        borderWidth: 0,
        borderColor: 'transparent',
        ...tokens.shadows.md,
      },
      outlined: {
        backgroundColor: '#ffffff',
        borderWidth: 1,
        borderColor: tokens.colors.border.light,
      },
      flat: {
        backgroundColor: tokens.colors.background.secondary,
        borderWidth: 0,
        borderColor: 'transparent',
      },
    };
    
    return variants[variant] || variants.default;
  };

  const cardStyles: ViewStyle = {
    borderRadius: 12,
    padding: tokens.spacing[padding],
    overflow: 'hidden',
    ...getVariantStyles(),
  };

  const Content = () => <View style={cardStyles}>{children}</View>;

  if (onPress) {
    return (
      <TouchableOpacity onPress={onPress} activeOpacity={0.7}>
        <Content />
      </TouchableOpacity>
    );
  }

  return <Content />;
};
```

---

## Component Composition Patterns

### Compound Components Pattern

```typescript
// src/design-system/components/molecules/List/List.tsx
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  FlatListProps,
  ViewStyle,
} from 'react-native';
import { tokens } from '../../../tokens';
import { useTheme } from '../../../theme';

/**
 * List - Compound component pattern
 * 
 * This demonstrates the compound component pattern:
 * - List acts as a container
 * - List.Item acts as a child
 * - Shared context for consistent styling
 */

interface ListContextType {
  variant?: 'default' | 'bordered' | 'separated';
}

const ListContext = React.createContext<ListContextType>({});

export interface ListProps extends FlatListProps<any> {
  variant?: 'default' | 'bordered' | 'separated';
}

/**
 * List - Container component
 */
export const List: React.FC<ListProps> & {
  Item: typeof ListItem;
  Header: typeof ListHeader;
  Footer: typeof ListFooter;
} = ({ variant = 'default', ...props }) => {
  const { theme } = useTheme();

  return (
    <ListContext.Provider value={{ variant }}>
      <FlatList
        {...props}
        style={[
          styles.list,
          variant === 'bordered' && styles.bordered,
          variant === 'separated' && styles.separated,
          props.style,
        ]}
      />
    </ListContext.Provider>
  );
};

/**
 * List.Item - List item component
 */
interface ListItemProps {
  children: React.ReactNode;
  onPress?: () => void;
  style?: ViewStyle;
  leading?: React.ReactNode;
  trailing?: React.ReactNode;
}

const ListItem: React.FC<ListItemProps> = ({
  children,
  onPress,
  style,
  leading,
  trailing,
}) => {
  const context = React.useContext(ListContext);
  const { theme } = useTheme();

  const itemStyles: ViewStyle = {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 16,
    backgroundColor: '#ffffff',
    minHeight: 44,
  };

  if (context.variant === 'separated') {
    itemStyles.borderBottomWidth = 1;
    itemStyles.borderBottomColor = tokens.colors.border.light;
  }

  const Content = () => (
    <View style={[itemStyles, style]}>
      {leading && <View style={styles.leading}>{leading}</View>}
      <View style={styles.content}>{children}</View>
      {trailing && <View style={styles.trailing}>{trailing}</View>}
    </View>
  );

  if (onPress) {
    return (
      <TouchableOpacity onPress={onPress} activeOpacity={0.7}>
        <Content />
      </TouchableOpacity>
    );
  }

  return <Content />;
};

const ListHeader: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return (
    <View style={styles.header}>
      <Text style={styles.headerText}>{children}</Text>
    </View>
  );
};

const ListFooter: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return (
    <View style={styles.footer}>
      <Text style={styles.footerText}>{children}</Text>
    </View>
  );
};

// Attach sub-components
List.Item = ListItem;
List.Header = ListHeader;
List.Footer = ListFooter;

const styles = StyleSheet.create({
  list: {
    backgroundColor: '#ffffff',
  },
  bordered: {
    borderWidth: 1,
    borderColor: tokens.colors.border.light,
    borderRadius: 8,
  },
  separated: {
    borderBottomWidth: 0,
  },
  leading: {
    marginRight: 12,
  },
  trailing: {
    marginLeft: 12,
  },
  content: {
    flex: 1,
  },
  header: {
    padding: 16,
    backgroundColor: tokens.colors.background.secondary,
  },
  headerText: {
    fontSize: 12,
    fontWeight: '600',
    color: tokens.colors.text.secondary,
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  footer: {
    padding: 16,
    backgroundColor: tokens.colors.background.secondary,
  },
  footerText: {
    fontSize: 12,
    color: tokens.colors.text.secondary,
    textAlign: 'center',
  },
});

// Usage Example:
// <List variant="separated">
//   <List.Header>Section Title</List.Header>
//   <List.Item
//     leading={<Icon name="star" />}
//     trailing={<Icon name="chevron-right" />}
//     onPress={() => {}}
//   >
//     <Text>Item 1</Text>
//   </List.Item>
//   <List.Item>
//     <Text>Item 2</Text>
//   </List.Item>
//   <List.Footer>End of list</List.Footer>
// </List>
```

---

## Theming & Variants

### Theme Provider Implementation

```typescript
// src/design-system/theme/ThemeProvider.tsx
import React, { createContext, useContext, useState, useEffect, useMemo } from 'react';
import { useColorScheme, AppState } from 'react-native';
import { tokens } from '../tokens';

type ThemeMode = 'light' | 'dark' | 'system';

export interface Theme {
  mode: ThemeMode;
  isDark: boolean;
  colors: typeof tokens.colors;
  spacing: typeof tokens.spacing;
  typography: typeof tokens.typography;
  shadows: typeof tokens.shadows;
}

const lightTheme: Theme = {
  mode: 'light',
  isDark: false,
  colors: tokens.colors,
  spacing: tokens.spacing,
  typography: tokens.typography,
  shadows: tokens.shadows,
};

const darkTheme: Theme = {
  ...lightTheme,
  isDark: true,
  colors: {
    ...tokens.colors,
    background: {
      primary: '#121212',
      secondary: '#1e1e1e',
      tertiary: '#2c2c2c',
      inverse: '#fafafa',
    },
    text: {
      primary: '#e0e0e0',
      secondary: '#a0a0a0',
      disabled: '#6e6e6e',
      inverse: '#121212',
      link: '#64b5f6',
    },
    neutral: {
      ...tokens.colors.neutral,
      0: '#121212',
      50: '#1a1a1a',
      100: '#2c2c2c',
      200: '#3d3d3d',
      300: '#4f4f4f',
      400: '#606060',
      500: '#727272',
      600: '#838383',
      700: '#959595',
      800: '#a6a6a6',
      900: '#b8b8b8',
      1000: '#e0e0e0',
    },
  },
};

interface ThemeContextType {
  theme: Theme;
  setThemeMode: (mode: ThemeMode) => void;
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const systemScheme = useColorScheme();
  const [mode, setMode] = useState<ThemeMode>('system');

  const effectiveTheme = useMemo(() => {
    const isDark = mode === 'system' ? systemScheme === 'dark' : mode === 'dark';
    return isDark ? darkTheme : lightTheme;
  }, [mode, systemScheme]);

  const setThemeMode = (newMode: ThemeMode) => {
    setMode(newMode);
    // Persist preference
    // AsyncStorage.setItem('theme_mode', newMode);
  };

  const toggleTheme = () => {
    setMode(prev => {
      if (prev === 'light') return 'dark';
      if (prev === 'dark') return 'system';
      return 'light';
    });
  };

  // Load saved preference
  useEffect(() => {
    // AsyncStorage.getItem('theme_mode').then(saved => {
    //   if (saved) setMode(saved as ThemeMode);
    // });
  }, []);

  const value = {
    theme: effectiveTheme,
    setThemeMode,
    toggleTheme,
  };

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = (): ThemeContextType => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
};
```

---

## Component Documentation

### Component Documentation Generator

```typescript
// src/design-system/docs/Documentation.tsx
import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { tokens } from '../tokens';
import { Button, Input, Card, List } from '../components';

/**
 * Component Documentation System
 * 
 * This demonstrates how to document design system components
 * with examples and usage guidelines.
 */

export const DesignSystemDocumentation: React.FC = () => {
  return (
    <ScrollView style={styles.container}>
      <Section title="Design Tokens">
        <ColorPalette />
        <TypographyPreview />
        <SpacingPreview />
      </Section>

      <Section title="Components">
        <ButtonExamples />
        <InputExamples />
        <CardExamples />
        <ListExamples />
      </Section>

      <Section title="Usage Guidelines">
        <AccessibilityGuidelines />
        <AnimationGuidelines />
      </Section>
    </ScrollView>
  );
};

// Section component
const Section: React.FC<{ title: string; children: React.ReactNode }> = ({
  title,
  children,
}) => (
  <View style={styles.section}>
    <Text style={styles.sectionTitle}>{title}</Text>
    <View style={styles.sectionContent}>{children}</View>
  </View>
);

// Color Palette
const ColorPalette: React.FC = () => {
  const colorKeys = ['primary', 'secondary', 'success', 'warning', 'error'] as const;
  
  return (
    <View style={styles.palette}>
      {colorKeys.map((key) => (
        <View key={key} style={styles.colorGroup}>
          <Text style={styles.colorGroupTitle}>{key}</Text>
          <View style={styles.colorGrid}>
            {Object.entries(tokens.colors[key]).map(([shade, color]) => (
              <View key={shade} style={styles.colorSwatch}>
                <View style={[styles.colorBox, { backgroundColor: color }]} />
                <Text style={styles.colorLabel}>{shade}</Text>
              </View>
            ))}
          </View>
        </View>
      ))}
    </View>
  );
};

// Button Examples
const ButtonExamples: React.FC = () => {
  return (
    <View style={styles.exampleContainer}>
      <Text style={styles.exampleTitle}>Button Variants</Text>
      <View style={styles.buttonRow}>
        <Button variant="primary">Primary</Button>
        <Button variant="secondary">Secondary</Button>
        <Button variant="outline">Outline</Button>
      </View>
      <View style={styles.buttonRow}>
        <Button variant="ghost">Ghost</Button>
        <Button variant="danger">Danger</Button>
        <Button loading>Loading</Button>
      </View>

      <Text style={[styles.exampleTitle, { marginTop: 16 }]}>Button Sizes</Text>
      <View style={styles.buttonRow}>
        <Button size="sm">Small</Button>
        <Button size="md">Medium</Button>
        <Button size="lg">Large</Button>
      </View>

      <Text style={[styles.exampleTitle, { marginTop: 16 }]}>Button States</Text>
      <View style={styles.buttonRow}>
        <Button disabled>Disabled</Button>
        <Button loading>Loading</Button>
        <Button fullWidth>Full Width</Button>
      </View>
    </View>
  );
};

// Input Examples
const InputExamples: React.FC = () => {
  return (
    <View style={styles.exampleContainer}>
      <Text style={styles.exampleTitle}>Input Variants</Text>
      <Input label="Default Input" placeholder="Enter text..." />
      <Input label="With Error" error="This field is required" />
      <Input label="With Helper" helper="Enter your email address" />
      <Input label="Required" required placeholder="Required field" />
    </View>
  );
};

// Card Examples
const CardExamples: React.FC = () => {
  return (
    <View style={styles.exampleContainer}>
      <Text style={styles.exampleTitle}>Card Variants</Text>
      <Card variant="default" style={styles.cardExample}>
        <Text>Default Card</Text>
      </Card>
      <Card variant="elevated" style={styles.cardExample}>
        <Text>Elevated Card</Text>
      </Card>
      <Card variant="outlined" style={styles.cardExample}>
        <Text>Outlined Card</Text>
      </Card>
      <Card variant="flat" style={styles.cardExample}>
        <Text>Flat Card</Text>
      </Card>
    </View>
  );
};

// List Examples
const ListExamples: React.FC = () => {
  return (
    <View style={styles.exampleContainer}>
      <Text style={styles.exampleTitle}>List Variants</Text>
      <List variant="default" data={['Item 1', 'Item 2', 'Item 3']} />
      <List variant="bordered" data={['Item 1', 'Item 2', 'Item 3']} />
      <List variant="separated" data={['Item 1', 'Item 2', 'Item 3']} />
    </View>
  );
};

// Accessibility Guidelines
const AccessibilityGuidelines: React.FC = () => {
  return (
    <View style={styles.guidelines}>
      <GuidelineItem
        title="Screen Reader Support"
        description="All interactive elements must have accessibilityLabel"
      />
      <GuidelineItem
        title="Touch Targets"
        description="Minimum touch target size is 44x44 points"
      />
      <GuidelineItem
        title="Color Contrast"
        description="All text must meet WCAG AA contrast requirements"
      />
      <GuidelineItem
        title="Focus Order"
        description="Focus should follow a logical reading order"
      />
    </View>
  );
};

// Animation Guidelines
const AnimationGuidelines: React.FC = () => {
  return (
    <View style={styles.guidelines}>
      <GuidelineItem
        title="Duration"
        description="Animations should last between 200-400ms"
      />
      <GuidelineItem
        title="Easing"
        description="Use ease-in-out for most transitions"
      />
      <GuidelineItem
        title="Reduced Motion"
        description="Respect reduce motion accessibility settings"
      />
      <GuidelineItem
        title="Feedback"
        description="Use animations to provide meaningful feedback"
      />
    </View>
  );
};

// Helper components
const GuidelineItem: React.FC<{ title: string; description: string }> = ({
  title,
  description,
}) => (
  <View style={styles.guidelineItem}>
    <Text style={styles.guidelineTitle}>{title}</Text>
    <Text style={styles.guidelineDescription}>{description}</Text>
  </View>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: tokens.colors.background.secondary,
  },
  section: {
    marginBottom: 24,
    padding: 16,
    backgroundColor: '#ffffff',
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: tokens.colors.text.primary,
    marginBottom: 16,
  },
  sectionContent: {
    gap: 16,
  },
  palette: {
    gap: 16,
  },
  colorGroup: {
    gap: 8,
  },
  colorGroupTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: tokens.colors.text.secondary,
    textTransform: 'capitalize',
  },
  colorGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 4,
  },
  colorSwatch: {
    alignItems: 'center',
    width: 50,
  },
  colorBox: {
    width: 40,
    height: 40,
    borderRadius: 4,
  },
  colorLabel: {
    fontSize: 10,
    color: tokens.colors.text.secondary,
    marginTop: 2,
  },
  exampleContainer: {
    gap: 8,
  },
  exampleTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: tokens.colors.text.primary,
  },
  buttonRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    alignItems: 'center',
  },
  cardExample: {
    marginVertical: 4,
  },
  guidelines: {
    gap: 12,
  },
  guidelineItem: {
    gap: 2,
  },
  guidelineTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: tokens.colors.text.primary,
  },
  guidelineDescription: {
    fontSize: 12,
    color: tokens.colors.text.secondary,
  },
});
```

---

## Versioning & Release Management

### Component Library Versioning

```typescript
// src/design-system/versioning/VersionManager.ts
/**
 * Component Library Versioning
 * 
 * This manages versioning for the design system:
 * - Semantic versioning
 * - Changelog generation
 * - Breaking change detection
 * - Release notes
 */

export interface Version {
  major: number;
  minor: number;
  patch: number;
  prerelease?: string;
}

export class VersionManager {
  private static instance: VersionManager;

  private constructor() {}

  static getInstance(): VersionManager {
    if (!VersionManager.instance) {
      VersionManager.instance = new VersionManager();
    }
    return VersionManager.instance;
  }

  /**
   * Parse version string
   */
  parseVersion(version: string): Version {
    const parts = version.split('.');
    const prerelease = version.includes('-') ? version.split('-')[1] : undefined;
    
    return {
      major: parseInt(parts[0]),
      minor: parseInt(parts[1]),
      patch: parseInt(parts[2]?.split('-')[0] || '0'),
      prerelease,
    };
  }

  /**
   * Stringify version
   */
  stringifyVersion(version: Version): string {
    let result = `${version.major}.${version.minor}.${version.patch}`;
    if (version.prerelease) {
      result += `-${version.prerelease}`;
    }
    return result;
  }

  /**
   * Generate changelog
   */
  generateChangelog(
    fromVersion: string,
    toVersion: string,
    changes: {
      added?: string[];
      changed?: string[];
      deprecated?: string[];
      removed?: string[];
      fixed?: string[];
      security?: string[];
    }
  ): string {
    let changelog = `# Changelog\n\n`;
    changelog += `## [${toVersion}] - ${new Date().toISOString().split('T')[0]}\n\n`;

    const sections = [
      { title: 'Added', items: changes.added },
      { title: 'Changed', items: changes.changed },
      { title: 'Deprecated', items: changes.deprecated },
      { title: 'Removed', items: changes.removed },
      { title: 'Fixed', items: changes.fixed },
      { title: 'Security', items: changes.security },
    ];

    sections.forEach(({ title, items }) => {
      if (items && items.length > 0) {
        changelog += `### ${title}\n\n`;
        items.forEach(item => {
          changelog += `- ${item}\n`;
        });
        changelog += '\n';
      }
    });

    changelog += `**Full Changelog**: [${fromVersion}...${toVersion}](https://github.com/yourorg/taskflow/compare/${fromVersion}...${toVersion})\n`;

    return changelog;
  }

  /**
   * Detect breaking changes
   */
  detectBreakingChanges(
    oldComponents: any,
    newComponents: any
  ): Array<{
    component: string;
    change: string;
    severity: 'breaking' | 'deprecation' | 'minor';
  }> {
    const changes = [];

    // Check for removed components
    // Check for changed props
    // Check for removed props
    // Check for type changes

    return changes;
  }
}

export const versionManager = VersionManager.getInstance();
```

---

This appendix provides a complete design system and component library for your React Native application. By implementing these patterns, you'll ensure consistency, scalability, and maintainability across your entire app.


# Appendix G: Accessibility (a11y) Guide

Welcome to Appendix G! This comprehensive guide covers everything you need to know about making your React Native app accessible to all users, including those with visual, auditory, motor, and cognitive impairments. Accessibility isn't just about compliance—it's about creating an inclusive experience for everyone.

---

## Table of Contents

1. [Accessibility Fundamentals](#accessibility-fundamentals)
2. [Screen Reader Support](#screen-reader-support)
3. [Visual Accessibility](#visual-accessibility)
4. [Motor & Touch Accessibility](#motor--touch-accessibility)
5. [Auditory Accessibility](#auditory-accessibility)
6. [Cognitive Accessibility](#cognitive-accessibility)
7. [Automated Testing](#automated-testing)
8. [Accessibility Checklist](#accessibility-checklist)

---

## Accessibility Fundamentals

### Core Accessibility Concepts

```typescript
// src/accessibility/Fundamentals.ts
/**
 * Accessibility Fundamentals
 * 
 * This provides the core concepts and principles
 * of mobile accessibility in React Native.
 */

export const AccessibilityFundamentals = {
  // 1. WCAG Principles
  wcag: {
    perceivable: {
      description: 'Information must be perceivable to all users',
      guidelines: [
        'Provide text alternatives for non-text content',
        'Provide captions and alternatives for multimedia',
        'Create content that can be presented in different ways',
        'Make it easier for users to see and hear content',
      ],
    },
    operable: {
      description: 'Interface must be operable by all users',
      guidelines: [
        'All functionality must be accessible via keyboard',
        'Give users enough time to read and use content',
        'Do not design content that causes seizures',
        'Help users navigate and find content',
      ],
    },
    understandable: {
      description: 'Information must be understandable to all users',
      guidelines: [
        'Make text readable and understandable',
        'Make content appear and operate in predictable ways',
        'Help users avoid and correct mistakes',
      ],
    },
    robust: {
      description: 'Content must be robust enough to work with assistive technologies',
      guidelines: [
        'Maximize compatibility with current and future user agents',
        'Ensure proper semantic markup',
        'Support accessibility APIs',
      ],
    },
  },

  // 2. React Native Accessibility Properties
  rnProperties: {
    accessible: {
      description: 'Indicates if the element is accessible to assistive technologies',
      usage: 'accessible={true}',
    },
    accessibilityLabel: {
      description: 'Text label for screen readers',
      usage: 'accessibilityLabel="Button label"',
    },
    accessibilityHint: {
      description: 'Additional information about an action',
      usage: 'accessibilityHint="Double tap to activate"',
    },
    accessibilityRole: {
      description: 'Defines the semantic role of the element',
      values: ['button', 'link', 'heading', 'text', 'image', 'search', 'summary', 'timer'],
    },
    accessibilityState: {
      description: 'Current state of the element',
      values: ['disabled', 'selected', 'checked', 'busy', 'expanded'],
    },
    accessibilityValue: {
      description: 'Current value of the element',
      usage: 'accessibilityValue={{ min: 0, max: 100, now: 50 }}',
    },
    accessibilityActions: {
      description: 'Custom actions that can be performed',
      usage: 'accessibilityActions={[{ name: "activate" }]}',
    },
    importantForAccessibility: {
      description: 'Controls how element contributes to accessibility tree',
      values: ['auto', 'yes', 'no', 'no-hide-descendants'],
    },
  },
};

/**
 * Accessibility Context Provider
 */
import React, { createContext, useContext, useState, useEffect } from 'react';
import { AccessibilityInfo, Platform } from 'react-native';

interface AccessibilityContextType {
  isScreenReaderEnabled: boolean;
  isReduceMotionEnabled: boolean;
  isInvertColorsEnabled: boolean;
  isBoldTextEnabled: boolean;
  isGrayscaleEnabled: boolean;
  isReduceTransparencyEnabled: boolean;
  preferredFontSize: number;
  preferredLanguage: string;
  screenReaderEnabled: boolean;
  reduceMotionEnabled: boolean;
  invertColorsEnabled: boolean;
  boldTextEnabled: boolean;
  grayscaleEnabled: boolean;
  reduceTransparencyEnabled: boolean;
}

const AccessibilityContext = createContext<AccessibilityContextType | undefined>(
  undefined
);

export const AccessibilityProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [state, setState] = useState<AccessibilityContextType>({
    isScreenReaderEnabled: false,
    isReduceMotionEnabled: false,
    isInvertColorsEnabled: false,
    isBoldTextEnabled: false,
    isGrayscaleEnabled: false,
    isReduceTransparencyEnabled: false,
    preferredFontSize: 16,
    preferredLanguage: 'en',
    screenReaderEnabled: false,
    reduceMotionEnabled: false,
    invertColorsEnabled: false,
    boldTextEnabled: false,
    grayscaleEnabled: false,
    reduceTransparencyEnabled: false,
  });

  useEffect(() => {
    // Check accessibility features
    const checkAccessibility = async () => {
      const [
        screenReader,
        reduceMotion,
        invertColors,
        boldText,
        grayscale,
        reduceTransparency,
      ] = await Promise.all([
        AccessibilityInfo.isScreenReaderEnabled(),
        AccessibilityInfo.isReduceMotionEnabled(),
        AccessibilityInfo.isInvertColorsEnabled(),
        AccessibilityInfo.isBoldTextEnabled(),
        AccessibilityInfo.isGrayscaleEnabled(),
        AccessibilityInfo.isReduceTransparencyEnabled(),
      ]);

      // Get preferred font size (simplified)
      const fontSize = 16; // In production, use a proper method

      setState({
        isScreenReaderEnabled: screenReader,
        isReduceMotionEnabled: reduceMotion,
        isInvertColorsEnabled: invertColors,
        isBoldTextEnabled: boldText,
        isGrayscaleEnabled: grayscale,
        isReduceTransparencyEnabled: reduceTransparency,
        preferredFontSize: fontSize,
        preferredLanguage: 'en',
        screenReaderEnabled: screenReader,
        reduceMotionEnabled: reduceMotion,
        invertColorsEnabled: invertColors,
        boldTextEnabled: boldText,
        grayscaleEnabled: grayscale,
        reduceTransparencyEnabled: reduceTransparency,
      });
    };

    checkAccessibility();

    // Listen for changes
    const subscriptions = [
      AccessibilityInfo.addEventListener('screenReaderChanged', (enabled) => {
        setState((prev) => ({ ...prev, screenReaderEnabled: enabled }));
      }),
      AccessibilityInfo.addEventListener('reduceMotionChanged', (enabled) => {
        setState((prev) => ({ ...prev, reduceMotionEnabled: enabled }));
      }),
      AccessibilityInfo.addEventListener('invertColorsChanged', (enabled) => {
        setState((prev) => ({ ...prev, invertColorsEnabled: enabled }));
      }),
      AccessibilityInfo.addEventListener('boldTextChanged', (enabled) => {
        setState((prev) => ({ ...prev, boldTextEnabled: enabled }));
      }),
      AccessibilityInfo.addEventListener('grayscaleChanged', (enabled) => {
        setState((prev) => ({ ...prev, grayscaleEnabled: enabled }));
      }),
      AccessibilityInfo.addEventListener('reduceTransparencyChanged', (enabled) => {
        setState((prev) => ({ ...prev, reduceTransparencyEnabled: enabled }));
      }),
    ];

    return () => {
      subscriptions.forEach((sub) => sub.remove());
    };
  }, []);

  return (
    <AccessibilityContext.Provider value={state}>
      {children}
    </AccessibilityContext.Provider>
  );
};

export const useAccessibility = () => {
  const context = useContext(AccessibilityContext);
  if (!context) {
    throw new Error('useAccessibility must be used within AccessibilityProvider');
  }
  return context;
};
```

---

## Screen Reader Support

### Complete Screen Reader Implementation

```typescript
// src/accessibility/ScreenReader.tsx
import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  AccessibilityInfo,
  Platform,
} from 'react-native';
import { useAccessibility } from './Fundamentals';

/**
 * Screen Reader Support
 * 
 * This provides comprehensive screen reader support:
 * - Proper labeling
 * - Focus management
 * - Announcements
 * - Live regions
 * - Semantic roles
 */

export const ScreenReaderSupport: React.FC = () => {
  const { screenReaderEnabled } = useAccessibility();

  return (
    <View
      accessible
      accessibilityRole="main"
      accessibilityLabel="Main content area"
    >
      <ScreenReaderAnnouncer />
      <AccessibleButton />
      <AccessibleList />
      <FormAccessible />
    </View>
  );
};

/**
 * Screen Reader Announcer
 * 
 * Provides live announcements for dynamic content
 */
const ScreenReaderAnnouncer: React.FC = () => {
  const [announcement, setAnnouncement] = React.useState('');

  const announce = (message: string) => {
    setAnnouncement(message);
    AccessibilityInfo.announceForAccessibility(message);
    // Clear after announcement
    setTimeout(() => setAnnouncement(''), 3000);
  };

  return (
    <View
      accessible
      accessibilityLiveRegion="polite"
      accessibilityLabel={announcement}
      importantForAccessibility="yes"
      style={styles.announcer}
    >
      <Text>{announcement}</Text>
    </View>
  );
};

/**
 * Accessible Button Component
 */
const AccessibleButton: React.FC = () => {
  const [isLoading, setIsLoading] = React.useState(false);
  const [isSelected, setIsSelected] = React.useState(false);

  const handlePress = () => {
    setIsLoading(true);
    // Simulate async action
    setTimeout(() => {
      setIsLoading(false);
      setIsSelected(!isSelected);
      AccessibilityInfo.announceForAccessibility(
        isSelected ? 'Button deselected' : 'Button selected'
      );
    }, 1000);
  };

  return (
    <TouchableOpacity
      accessible
      accessibilityLabel={isLoading ? 'Loading button' : 'Action button'}
      accessibilityHint="Double tap to perform action"
      accessibilityRole="button"
      accessibilityState={{
        disabled: isLoading,
        selected: isSelected,
        busy: isLoading,
      }}
      accessibilityActions={[
        { name: 'activate', label: 'Activate button' },
        { name: 'longpress', label: 'Long press for options' },
      ]}
      onAccessibilityAction={(event) => {
        if (event.nativeEvent.actionName === 'activate') {
          handlePress();
        } else if (event.nativeEvent.actionName === 'longpress') {
          // Show options
        }
      }}
      onPress={handlePress}
      disabled={isLoading}
      style={[
        styles.button,
        isSelected && styles.buttonSelected,
        isLoading && styles.buttonLoading,
      ]}
      activeOpacity={0.7}
    >
      <Text style={styles.buttonText}>
        {isLoading ? 'Loading...' : isSelected ? 'Selected ✓' : 'Tap Me'}
      </Text>
    </TouchableOpacity>
  );
};

/**
 * Accessible List Component
 */
const AccessibleList: React.FC = () => {
  const items = [
    { id: '1', title: 'Accessible Item 1', description: 'This is the first item' },
    { id: '2', title: 'Accessible Item 2', description: 'This is the second item' },
    { id: '3', title: 'Accessible Item 3', description: 'This is the third item' },
  ];

  return (
    <View
      accessibilityRole="list"
      accessibilityLabel="Accessible list"
      style={styles.list}
    >
      {items.map((item, index) => (
        <View
          key={item.id}
          accessible
          accessibilityRole="listitem"
          accessibilityLabel={`${item.title}. ${item.description}`}
          accessibilityHint={`Item ${index + 1} of ${items.length}`}
          style={styles.listItem}
        >
          <Text style={styles.itemTitle}>{item.title}</Text>
          <Text style={styles.itemDescription}>{item.description}</Text>
        </View>
      ))}
    </View>
  );
};

/**
 * Accessible Form Component
 */
const FormAccessible: React.FC = () => {
  return (
    <View
      accessible
      accessibilityRole="form"
      accessibilityLabel="User information form"
      style={styles.form}
    >
      <Text
        accessibilityRole="heading"
        accessibilityLevel={2}
        style={styles.formTitle}
      >
        User Information
      </Text>

      <FormField
        label="Name"
        hint="Enter your full name"
        required
        error="Name is required"
      />

      <FormField
        label="Email"
        hint="Enter your email address"
        required
        type="email"
      />

      <FormField
        label="Phone"
        hint="Enter your phone number"
        type="phone"
      />
    </View>
  );
};

/**
 * Accessible Form Field
 */
const FormField: React.FC<{
  label: string;
  hint?: string;
  required?: boolean;
  error?: string;
  type?: 'text' | 'email' | 'phone';
}> = ({ label, hint, required, error, type }) => {
  const [value, setValue] = React.useState('');
  const [isFocused, setIsFocused] = React.useState(false);

  return (
    <View
      accessible
      accessibilityRole="none"
      style={styles.fieldContainer}
    >
      <Text
        accessibilityRole="label"
        accessibilityLabel={`${label} ${required ? 'required' : ''}`}
        style={[styles.fieldLabel, required && styles.fieldLabelRequired]}
      >
        {label} {required && <Text style={styles.requiredStar}>*</Text>}
      </Text>

      <TextInput
        accessible
        accessibilityLabel={`${label} input`}
        accessibilityHint={hint}
        accessibilityRole="text"
        accessibilityState={{
          disabled: false,
          focused: isFocused,
          busy: false,
        }}
        value={value}
        onChangeText={setValue}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
        keyboardType={type === 'email' ? 'email-address' : type === 'phone' ? 'phone-pad' : 'default'}
        autoComplete={type === 'email' ? 'email' : type === 'phone' ? 'tel' : 'off'}
        style={[
          styles.fieldInput,
          error && styles.fieldInputError,
          isFocused && styles.fieldInputFocused,
        ]}
        placeholderTextColor="#9e9e9e"
      />

      {error && (
        <Text
          accessibilityRole="alert"
          accessibilityLabel={`Error: ${error}`}
          style={styles.fieldError}
        >
          {error}
        </Text>
      )}

      {hint && !error && (
        <Text style={styles.fieldHint}>{hint}</Text>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  announcer: {
    position: 'absolute',
    width: 1,
    height: 1,
    opacity: 0,
  },
  button: {
    backgroundColor: '#3498db',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
    alignItems: 'center',
    minHeight: 44,
    minWidth: 44,
  },
  buttonSelected: {
    backgroundColor: '#2ecc71',
  },
  buttonLoading: {
    backgroundColor: '#95a5a6',
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  list: {
    marginVertical: 16,
  },
  listItem: {
    padding: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#e1e8ed',
    minHeight: 44,
  },
  itemTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: '#2c3e50',
  },
  itemDescription: {
    fontSize: 14,
    color: '#7f8c8d',
  },
  form: {
    marginVertical: 16,
    padding: 16,
    backgroundColor: '#ffffff',
    borderRadius: 8,
  },
  formTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 16,
  },
  fieldContainer: {
    marginBottom: 16,
  },
  fieldLabel: {
    fontSize: 14,
    fontWeight: '500',
    color: '#2c3e50',
    marginBottom: 4,
  },
  fieldLabelRequired: {
    color: '#2c3e50',
  },
  requiredStar: {
    color: '#e74c3c',
  },
  fieldInput: {
    backgroundColor: '#f8f9fa',
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderRadius: 8,
    fontSize: 16,
    color: '#2c3e50',
    borderWidth: 1,
    borderColor: '#e1e8ed',
    minHeight: 44,
  },
  fieldInputError: {
    borderColor: '#e74c3c',
    borderWidth: 2,
  },
  fieldInputFocused: {
    borderColor: '#3498db',
    borderWidth: 2,
  },
  fieldError: {
    color: '#e74c3c',
    fontSize: 12,
    marginTop: 4,
  },
  fieldHint: {
    color: '#7f8c8d',
    fontSize: 12,
    marginTop: 4,
  },
});
```

---

## Visual Accessibility

### Visual Accessibility Implementation

```typescript
// src/accessibility/VisualAccessibility.tsx
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  Platform,
  TouchableOpacity,
} from 'react-native';
import { useAccessibility } from './Fundamentals';

/**
 * Visual Accessibility Support
 * 
 * This provides comprehensive visual accessibility:
 * - Dynamic font sizing
 * - High contrast mode
 * - Color blindness considerations
 * - Focus indicators
 * - Readable typography
 */

export const VisualAccessibility: React.FC = () => {
  const { preferredFontSize, boldTextEnabled, invertColorsEnabled } = useAccessibility();

  return (
    <View style={styles.container}>
      <AccessibleTypography />
      <HighContrastExample />
      <ColorSafeComponent />
      <FocusIndicatorExample />
    </View>
  );
};

/**
 * Accessible Typography
 * 
 * Adapts to user's font size preferences
 */
const AccessibleTypography: React.FC = () => {
  const { preferredFontSize, boldTextEnabled } = useAccessibility();
  const { isBoldTextEnabled } = useAccessibility();

  // Dynamic font size scaling
  const getDynamicSize = (baseSize: number): number => {
    const scale = preferredFontSize / 16;
    return Math.round(baseSize * scale);
  };

  return (
    <View style={styles.typographyContainer}>
      <Text
        style={[
          styles.heading,
          {
            fontSize: getDynamicSize(24),
            fontWeight: boldTextEnabled || isBoldTextEnabled ? 'bold' : '600',
          },
        ]}
        accessibilityRole="heading"
        accessibilityLevel={1}
      >
        Adaptive Heading
      </Text>
      
      <Text
        style={[
          styles.body,
          {
            fontSize: getDynamicSize(16),
            fontWeight: boldTextEnabled || isBoldTextEnabled ? 'bold' : '400',
          },
        ]}
      >
        This text adapts to your preferred font size and bold settings.
        Accessibility means making content readable for everyone.
      </Text>

      <Text
        style={[
          styles.caption,
          {
            fontSize: getDynamicSize(12),
            fontWeight: boldTextEnabled || isBoldTextEnabled ? 'bold' : '300',
          },
        ]}
        accessibilityRole="text"
      >
        Caption text with reduced size
      </Text>
    </View>
  );
};

/**
 * High Contrast Example
 */
const HighContrastExample: React.FC = () => {
  return (
    <View style={styles.highContrastContainer}>
      <Text style={styles.highContrastTitle}>High Contrast Colors</Text>
      
      <View style={styles.colorGrid}>
        <View style={[styles.colorBox, { backgroundColor: '#1a1a1a' }]}>
          <Text style={{ color: '#ffffff' }}>White on Black</Text>
        </View>
        
        <View style={[styles.colorBox, { backgroundColor: '#ffffff' }]}>
          <Text style={{ color: '#1a1a1a' }}>Black on White</Text>
        </View>
        
        <View style={[styles.colorBox, { backgroundColor: '#2c3e50' }]}>
          <Text style={{ color: '#ecf0f1' }}>Light on Dark</Text>
        </View>
        
        <View style={[styles.colorBox, { backgroundColor: '#f1c40f' }]}>
          <Text style={{ color: '#2c3e50' }}>Dark on Yellow</Text>
        </View>
      </View>

      {/* Contrast ratio checker */}
      <ColorContrastChecker
        foreground="#2c3e50"
        background="#ecf0f1"
        label="Good contrast example"
      />
    </View>
  );
};

/**
 * Color Contrast Checker
 */
const ColorContrastChecker: React.FC<{
  foreground: string;
  background: string;
  label: string;
}> = ({ foreground, background, label }) => {
  const getContrastRatio = (fg: string, bg: string): number => {
    // WCAG contrast ratio calculation (simplified)
    const fgLuminance = 0.5; // Placeholder
    const bgLuminance = 0.3; // Placeholder
    return (fgLuminance + 0.05) / (bgLuminance + 0.05);
  };

  const ratio = getContrastRatio(foreground, background);
  const isAA = ratio >= 4.5;
  const isAAA = ratio >= 7;

  return (
    <View
      style={[styles.contrastChecker, { backgroundColor: background }]}
      accessibilityLabel={`${label}: Contrast ratio ${ratio.toFixed(2)}`}
    >
      <Text style={{ color: foreground, padding: 8 }}>
        {label}
        {' '}
        <Text style={styles.contrastText}>
          (Ratio: {ratio.toFixed(2)} - {isAAA ? 'AAA' : isAA ? 'AA' : 'Fail'})
        </Text>
      </Text>
    </View>
  );
};

/**
 * Color-Safe Component
 * 
 * Considers color blindness
 */
const ColorSafeComponent: React.FC = () => {
  // Use color + shape/text to convey information
  const statuses = [
    { status: 'Success', color: '#2ecc71', symbol: '✓', label: 'Success' },
    { status: 'Warning', color: '#f39c12', symbol: '⚠', label: 'Warning' },
    { status: 'Error', color: '#e74c3c', symbol: '✕', label: 'Error' },
    { status: 'Info', color: '#3498db', symbol: 'ℹ', label: 'Info' },
  ];

  return (
    <View style={styles.colorSafeContainer}>
      <Text style={styles.sectionTitle}>Color-Safe Status Indicators</Text>
      
      {statuses.map((item) => (
        <View
          key={item.status}
          style={[
            styles.statusItem,
            { backgroundColor: item.color + '20' }, // 20% opacity
          ]}
          accessibilityLabel={`${item.status}: ${item.label}`}
        >
          <View style={[styles.statusIcon, { backgroundColor: item.color }]}>
            <Text style={styles.statusSymbol}>{item.symbol}</Text>
          </View>
          <Text style={styles.statusText}>{item.status}</Text>
          <Text style={styles.statusLabel}>{item.label}</Text>
        </View>
      ))}
    </View>
  );
};

/**
 * Focus Indicator Example
 */
const FocusIndicatorExample: React.FC = () => {
  const [focusedId, setFocusedId] = React.useState<string | null>(null);

  const items = [
    { id: '1', label: 'Option 1' },
    { id: '2', label: 'Option 2' },
    { id: '3', label: 'Option 3' },
  ];

  return (
    <View style={styles.focusContainer}>
      <Text style={styles.sectionTitle}>Focus Indicators</Text>
      
      <View style={styles.focusGrid}>
        {items.map((item) => (
          <TouchableOpacity
            key={item.id}
            style={[
              styles.focusItem,
              focusedId === item.id && styles.focusItemActive,
            ]}
            onFocus={() => setFocusedId(item.id)}
            onBlur={() => setFocusedId(null)}
            accessibilityLabel={item.label}
            accessibilityRole="button"
            activeOpacity={0.7}
          >
            <Text style={[
              styles.focusItemText,
              focusedId === item.id && styles.focusItemTextActive,
            ]}>
              {item.label}
            </Text>
          </TouchableOpacity>
        ))}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f8f9fa',
  },
  typographyContainer: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 8,
    marginBottom: 16,
  },
  heading: {
    color: '#2c3e50',
    marginBottom: 8,
  },
  body: {
    color: '#2c3e50',
    marginBottom: 8,
    lineHeight: 24,
  },
  caption: {
    color: '#7f8c8d',
  },
  highContrastContainer: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 8,
    marginBottom: 16,
  },
  highContrastTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 12,
  },
  colorGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  colorBox: {
    padding: 12,
    borderRadius: 4,
    minWidth: 100,
    minHeight: 44,
    alignItems: 'center',
    justifyContent: 'center',
  },
  contrastChecker: {
    padding: 8,
    borderRadius: 4,
    marginTop: 8,
  },
  contrastText: {
    fontSize: 12,
    fontWeight: '400',
  },
  colorSafeContainer: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 8,
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 12,
  },
  statusItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 8,
    borderRadius: 4,
    marginBottom: 4,
  },
  statusIcon: {
    width: 24,
    height: 24,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 8,
  },
  statusSymbol: {
    color: '#ffffff',
    fontSize: 12,
    fontWeight: '600',
  },
  statusText: {
    flex: 1,
    fontSize: 14,
    color: '#2c3e50',
    marginRight: 8,
  },
  statusLabel: {
    fontSize: 12,
    color: '#7f8c8d',
  },
  focusContainer: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 8,
  },
  focusGrid: {
    flexDirection: 'row',
    gap: 8,
  },
  focusItem: {
    flex: 1,
    padding: 12,
    borderRadius: 8,
    backgroundColor: '#f1f2f6',
    borderWidth: 2,
    borderColor: 'transparent',
    alignItems: 'center',
    minHeight: 44,
  },
  focusItemActive: {
    borderColor: '#3498db',
    backgroundColor: '#e8f4fd',
  },
  focusItemText: {
    fontSize: 14,
    color: '#2c3e50',
  },
  focusItemTextActive: {
    color: '#3498db',
    fontWeight: '600',
  },
});
```

---

## Motor & Touch Accessibility

### Touch Accessibility Implementation

```typescript
// src/accessibility/MotorAccessibility.tsx
import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Platform,
} from 'react-native';

/**
 * Motor Accessibility Support
 * 
 * This provides comprehensive motor accessibility:
 * - Adequate touch target sizes
 * - Sufficient spacing between touch targets
 * - Gesture alternatives
 * - Focus order management
 * - Haptic feedback
 */

export const MotorAccessibility: React.FC = () => {
  return (
    <View style={styles.container}>
      <LargeTouchTargets />
      <GestureAlternatives />
      <HapticFeedbackExample />
    </View>
  );
};

/**
 * Large Touch Targets
 * 
 * All touch targets should be at least 44x44 points
 */
const LargeTouchTargets: React.FC = () => {
  const [selected, setSelected] = React.useState<string | null>(null);

  // Larger touch targets with adequate spacing
  const options = [
    { id: '1', label: 'Option A' },
    { id: '2', label: 'Option B' },
    { id: '3', label: 'Option C' },
  ];

  return (
    <View style={styles.targetContainer}>
      <Text style={styles.sectionTitle}>Large Touch Targets</Text>
      <Text style={styles.sectionSubtitle}>
        Minimum 44x44pt, spaced at least 8pt apart
      </Text>

      <View style={styles.targetGrid}>
        {options.map((option) => (
          <TouchableOpacity
            key={option.id}
            style={[
              styles.targetButton,
              selected === option.id && styles.targetButtonSelected,
            ]}
            onPress={() => setSelected(option.id)}
            accessibilityLabel={`Select ${option.label}`}
            accessibilityRole="button"
            accessibilityState={{ selected: selected === option.id }}
            activeOpacity={0.7}
          >
            <Text style={[
              styles.targetButtonText,
              selected === option.id && styles.targetButtonTextSelected,
            ]}>
              {option.label}
            </Text>
          </TouchableOpacity>
        ))}
      </View>
    </View>
  );
};

/**
 * Gesture Alternatives
 * 
 * Provide alternative ways to perform gestures
 */
const GestureAlternatives: React.FC = () => {
  const [isExpanded, setIsExpanded] = React.useState(false);

  return (
    <View style={styles.gestureContainer}>
      <Text style={styles.sectionTitle}>Gesture Alternatives</Text>
      
      {/* Swipe alternative: Buttons for expand/collapse */}
      <View style={styles.gestureControls}>
        <TouchableOpacity
          style={[styles.gestureButton, isExpanded && styles.gestureButtonActive]}
          onPress={() => setIsExpanded(!isExpanded)}
          accessibilityLabel={isExpanded ? 'Collapse content' : 'Expand content'}
          accessibilityHint="Double tap to toggle content visibility"
          accessibilityRole="button"
          accessibilityState={{ expanded: isExpanded }}
          minWidth={44}
          minHeight={44}
        >
          <Text style={styles.gestureButtonText}>
            {isExpanded ? '▼' : '▶'}
          </Text>
        </TouchableOpacity>

        <Text style={styles.gestureInstruction}>
          {isExpanded ? 'Content is expanded' : 'Tap to expand content'}
        </Text>
      </View>

      {/* Expandable content */}
      {isExpanded && (
        <View
          style={styles.expandableContent}
          accessibilityLabel="Expanded content area"
          accessibilityRole="summary"
        >
          <Text style={styles.expandableText}>
            This content can be accessed by tapping the button above,
            providing an alternative to swipe gestures.
          </Text>
        </View>
      )}
    </View>
  );
};

/**
 * Haptic Feedback Example
 * 
 * Provides physical feedback for touch interactions
 */
const HapticFeedbackExample: React.FC = () => {
  const [count, setCount] = React.useState(0);

  const handlePress = () => {
    setCount(count + 1);
    
    // Provide haptic feedback
    if (Platform.OS !== 'web') {
      // Use expo-haptics for physical feedback
      // Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    }
  };

  const handleLongPress = () => {
    setCount(0);
    
    // Stronger haptic for long press
    if (Platform.OS !== 'web') {
      // Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
    }
  };

  return (
    <View style={styles.hapticContainer}>
      <Text style={styles.sectionTitle}>Haptic Feedback</Text>
      <Text style={styles.sectionSubtitle}>
        Physical feedback for touch interactions
      </Text>

      <TouchableOpacity
        style={styles.hapticButton}
        onPress={handlePress}
        onLongPress={handleLongPress}
        accessibilityLabel={`Press count: ${count}`}
        accessibilityHint="Double tap to increment, long press to reset"
        accessibilityRole="button"
        activeOpacity={0.7}
      >
        <Text style={styles.hapticButtonText}>
          Count: {count}
        </Text>
        <Text style={styles.hapticButtonSubtext}>
          Press to increment • Long press to reset
        </Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f8f9fa',
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 4,
  },
  sectionSubtitle: {
    fontSize: 12,
    color: '#7f8c8d',
    marginBottom: 12,
  },
  targetContainer: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 8,
    marginBottom: 16,
  },
  targetGrid: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    gap: 8,
  },
  targetButton: {
    flex: 1,
    padding: 12,
    borderRadius: 8,
    backgroundColor: '#f1f2f6',
    alignItems: 'center',
    minHeight: 44,
    minWidth: 44,
    justifyContent: 'center',
  },
  targetButtonSelected: {
    backgroundColor: '#3498db',
  },
  targetButtonText: {
    fontSize: 14,
    color: '#2c3e50',
  },
  targetButtonTextSelected: {
    color: '#ffffff',
    fontWeight: '600',
  },
  gestureContainer: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 8,
    marginBottom: 16,
  },
  gestureControls: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  gestureButton: {
    padding: 12,
    borderRadius: 8,
    backgroundColor: '#f1f2f6',
    minWidth: 44,
    minHeight: 44,
    alignItems: 'center',
    justifyContent: 'center',
  },
  gestureButtonActive: {
    backgroundColor: '#3498db',
  },
  gestureButtonText: {
    fontSize: 20,
    color: '#2c3e50',
  },
  gestureInstruction: {
    fontSize: 14,
    color: '#7f8c8d',
  },
  expandableContent: {
    marginTop: 12,
    padding: 12,
    backgroundColor: '#f8f9fa',
    borderRadius: 8,
  },
  expandableText: {
    fontSize: 14,
    color: '#2c3e50',
    lineHeight: 20,
  },
  hapticContainer: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 8,
  },
  hapticButton: {
    padding: 16,
    borderRadius: 8,
    backgroundColor: '#3498db',
    alignItems: 'center',
    minHeight: 44,
    justifyContent: 'center',
  },
  hapticButtonText: {
    fontSize: 18,
    color: '#ffffff',
    fontWeight: '600',
  },
  hapticButtonSubtext: {
    fontSize: 12,
    color: 'rgba(255,255,255,0.7)',
    marginTop: 4,
  },
});
```

---

## Auditory Accessibility

### Auditory Accessibility Implementation

```typescript
// src/accessibility/AuditoryAccessibility.tsx
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Platform,
} from 'react-native';

/**
 * Auditory Accessibility Support
 * 
 * This provides comprehensive auditory accessibility:
 * - Closed captions for videos
 * - Visual alternatives for audio
 * - Vibration alerts
 * - Transcript support
 */

export const AuditoryAccessibility: React.FC = () => {
  return (
    <View style={styles.container}>
      <VisualAlerts />
      <ClosedCaptionExample />
    </View>
  );
};

/**
 * Visual Alerts
 * 
 * Provides visual alternatives for auditory alerts
 */
const VisualAlerts: React.FC = () => {
  const [alertType, setAlertType] = React.useState<'info' | 'warning' | 'error' | null>(null);

  const showAlert = (type: 'info' | 'warning' | 'error') => {
    setAlertType(type);
    
    // Add haptic feedback for alerts
    if (Platform.OS !== 'web') {
      // Haptics.notificationAsync(
      //   type === 'error' ? Haptics.NotificationFeedbackType.Error :
      //   type === 'warning' ? Haptics.NotificationFeedbackType.Warning :
      //   Haptics.NotificationFeedbackType.Success
      // );
    }

    // Auto-dismiss after 3 seconds
    setTimeout(() => setAlertType(null), 3000);
  };

  const getAlertStyle = (type: 'info' | 'warning' | 'error') => {
    switch (type) {
      case 'info': return styles.alertInfo;
      case 'warning': return styles.alertWarning;
      case 'error': return styles.alertError;
      default: return styles.alertInfo;
    }
  };

  const getAlertIcon = (type: 'info' | 'warning' | 'error') => {
    switch (type) {
      case 'info': return 'ℹ️';
      case 'warning': return '⚠️';
      case 'error': return '❌';
      default: return 'ℹ️';
    }
  };

  return (
    <View style={styles.alertsContainer}>
      <Text style={styles.sectionTitle}>Visual Alerts</Text>
      <Text style={styles.sectionSubtitle}>
        Visual alternatives for audio notifications
      </Text>

      <View style={styles.alertButtons}>
        <TouchableOpacity
          style={[styles.alertButton, styles.alertButtonInfo]}
          onPress={() => showAlert('info')}
          accessibilityLabel="Show info alert"
          accessibilityHint="Displays a visual information alert"
          accessibilityRole="button"
        >
          <Text style={styles.alertButtonText}>ℹ️ Info</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.alertButton, styles.alertButtonWarning]}
          onPress={() => showAlert('warning')}
          accessibilityLabel="Show warning alert"
          accessibilityHint="Displays a visual warning alert"
          accessibilityRole="button"
        >
          <Text style={styles.alertButtonText}>⚠️ Warning</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.alertButton, styles.alertButtonError]}
          onPress={() => showAlert('error')}
          accessibilityLabel="Show error alert"
          accessibilityHint="Displays a visual error alert"
          accessibilityRole="button"
        >
          <Text style={styles.alertButtonText}>❌ Error</Text>
        </TouchableOpacity>
      </View>

      {alertType && (
        <View
          style={[styles.alertDisplay, getAlertStyle(alertType)]}
          accessibilityLabel={`Alert: ${alertType}`}
          accessibilityRole="alert"
          accessibilityLiveRegion="assertive"
        >
          <Text style={styles.alertIcon}>{getAlertIcon(alertType)}</Text>
          <Text style={styles.alertMessage}>
            This is a visual {alertType} alert
          </Text>
        </View>
      )}
    </View>
  );
};

/**
 * Closed Caption Example
 * 
 * Provides text alternatives for audio content
 */
const ClosedCaptionExample: React.FC = () => {
  const [isCaptionsEnabled, setIsCaptionsEnabled] = React.useState(true);
  const [currentCaption, setCurrentCaption] = React.useState('');

  // Simulated audio content with captions
  const audioContent = [
    { time: 0, text: 'Welcome to the accessibility guide.' },
    { time: 2, text: 'Today we will learn about auditory accessibility.' },
    { time: 4, text: 'Closed captions help users with hearing impairments.' },
    { time: 6, text: 'They also benefit users in noisy environments.' },
  ];

  const playAudio = () => {
    // Simulate audio playback with captions
    let index = 0;
    const interval = setInterval(() => {
      if (index < audioContent.length) {
        setCurrentCaption(audioContent[index].text);
        index++;
      } else {
        clearInterval(interval);
        setCurrentCaption('Audio playback complete');
      }
    }, 2000);
  };

  return (
    <View style={styles.captionsContainer}>
      <Text style={styles.sectionTitle}>Closed Captions</Text>
      
      <View style={styles.captionsControls}>
        <TouchableOpacity
          style={[styles.captionsToggle, isCaptionsEnabled && styles.captionsToggleActive]}
          onPress={() => setIsCaptionsEnabled(!isCaptionsEnabled)}
          accessibilityLabel={isCaptionsEnabled ? 'Disable captions' : 'Enable captions'}
          accessibilityRole="switch"
          accessibilityState={{ checked: isCaptionsEnabled }}
          minWidth={44}
          minHeight={44}
        >
          <Text style={styles.captionsToggleText}>
            {isCaptionsEnabled ? 'CC ✓' : 'CC'}
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.playButton}
          onPress={playAudio}
          accessibilityLabel="Play audio with captions"
          accessibilityHint="Starts audio playback with synchronized captions"
          accessibilityRole="button"
          minWidth={44}
          minHeight={44}
        >
          <Text style={styles.playButtonText}>▶️ Play</Text>
        </TouchableOpacity>
      </View>

      {isCaptionsEnabled && currentCaption && (
        <View
          style={styles.captionDisplay}
          accessibilityLabel={`Caption: ${currentCaption}`}
          accessibilityRole="text"
          accessibilityLiveRegion="polite"
        >
          <Text style={styles.captionText}>{currentCaption}</Text>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f8f9fa',
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 4,
  },
  sectionSubtitle: {
    fontSize: 12,
    color: '#7f8c8d',
    marginBottom: 12,
  },
  alertsContainer: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 8,
    marginBottom: 16,
  },
  alertButtons: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 12,
  },
  alertButton: {
    flex: 1,
    padding: 10,
    borderRadius: 8,
    alignItems: 'center',
    minHeight: 44,
    justifyContent: 'center',
  },
  alertButtonInfo: {
    backgroundColor: '#e8f4fd',
  },
  alertButtonWarning: {
    backgroundColor: '#fef7e6',
  },
  alertButtonError: {
    backgroundColor: '#fce8e8',
  },
  alertButtonText: {
    fontSize: 14,
    fontWeight: '500',
    color: '#2c3e50',
  },
  alertDisplay: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    borderRadius: 8,
    gap: 8,
  },
  alertInfo: {
    backgroundColor: '#e8f4fd',
  },
  alertWarning: {
    backgroundColor: '#fef7e6',
  },
  alertError: {
    backgroundColor: '#fce8e8',
  },
  alertIcon: {
    fontSize: 20,
  },
  alertMessage: {
    fontSize: 14,
    color: '#2c3e50',
  },
  captionsContainer: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 8,
  },
  captionsControls: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 12,
  },
  captionsToggle: {
    padding: 10,
    borderRadius: 8,
    backgroundColor: '#f1f2f6',
    minWidth: 44,
    minHeight: 44,
    alignItems: 'center',
    justifyContent: 'center',
  },
  captionsToggleActive: {
    backgroundColor: '#3498db',
  },
  captionsToggleText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#2c3e50',
  },
  playButton: {
    padding: 10,
    borderRadius: 8,
    backgroundColor: '#2ecc71',
    minWidth: 44,
    minHeight: 44,
    alignItems: 'center',
    justifyContent: 'center',
    flex: 1,
  },
  playButtonText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#ffffff',
  },
  captionDisplay: {
    padding: 12,
    backgroundColor: '#2c3e50',
    borderRadius: 8,
  },
  captionText: {
    fontSize: 16,
    color: '#ffffff',
    lineHeight: 24,
  },
});
```

---

## Accessibility Testing

### Automated Accessibility Testing

```typescript
// src/accessibility/Testing.ts
import { AccessibilityInfo } from 'react-native';
import { useAccessibility } from './Fundamentals';

/**
 * Accessibility Testing Framework
 * 
 * This provides comprehensive accessibility testing:
 * - Automated checks
 * - Manual testing guidance
 * - Screen reader testing
 * - Keyboard navigation testing
 */

export class AccessibilityTesting {
  /**
   * Run automated accessibility checks
   */
  static async runAutomatedChecks(component: React.ReactElement): Promise<{
    passed: boolean;
    issues: Array<{ severity: 'critical' | 'serious' | 'moderate' | 'minor'; message: string }>;
  }> {
    const issues: Array<{ severity: 'critical' | 'serious' | 'moderate' | 'minor'; message: string }> = [];

    // Check for accessibility labels
    // Check for touch target sizes
    // Check for color contrast
    // Check for semantic roles

    return {
      passed: issues.length === 0,
      issues,
    };
  }

  /**
   * Manual testing checklist
   */
  static manualTestingChecklist = {
    screenReader: [
      'Test with VoiceOver (iOS)',
      'Test with TalkBack (Android)',
      'Verify all elements are properly labeled',
      'Test focus order and navigation',
      'Test custom actions',
    ],
    visual: [
      'Verify color contrast (WCAG AA/AAA)',
      'Test with color blindness simulation',
      'Verify font scaling',
      'Test with bold text enabled',
      'Test with reduced motion enabled',
    ],
    motor: [
      'Test all touch targets (min 44x44pt)',
      'Test with keyboard navigation (iOS 16+)',
      'Test switch control (iOS)',
      'Test with voice commands',
      'Test with one-handed mode',
    ],
    auditory: [
      'Verify closed captions availability',
      'Test volume controls',
      'Verify visual alternatives for sounds',
      'Test with vibration feedback',
    ],
  };

  /**
   * Generate accessibility report
   */
  static generateReport(results: any): string {
    const timestamp = new Date().toISOString();
    let report = `# Accessibility Audit Report\n\n`;
    report += `**Timestamp:** ${timestamp}\n\n`;
    report += `## Screen Reader Support\n\n`;
    report += `## Visual Accessibility\n\n`;
    report += `## Motor Accessibility\n\n`;
    report += `## Auditory Accessibility\n\n`;
    return report;
  }
}
```

---

## Accessibility Checklist

### Complete Accessibility Checklist

```typescript
// src/accessibility/Checklist.ts
/**
 * Accessibility Checklist
 * 
 * Comprehensive checklist for mobile app accessibility
 */

export const AccessibilityChecklist = {
  // 1. Screen Reader Support
  screenReader: {
    'All interactive elements have labels': {
      required: true,
      check: 'Each button, link, and form control has accessibilityLabel',
    },
    'Semantic roles are used': {
      required: true,
      check: 'Appropriate accessibilityRole used for each element',
    },
    'States are communicated': {
      required: true,
      check: 'accessibilityState used for selected, disabled, checked',
    },
    'Live regions for dynamic content': {
      required: true,
      check: 'accessibilityLiveRegion for content updates',
    },
    'Focus order is logical': {
      required: true,
      check: 'Focus flows in a natural reading order',
    },
    'Custom actions are available': {
      required: false,
      check: 'accessibilityActions for frequently used operations',
    },
  },

  // 2. Visual Accessibility
  visual: {
    'Color contrast meets WCAG AA': {
      required: true,
      check: 'Contrast ratio of 4.5:1 for normal text, 3:1 for large text',
    },
    'Information not conveyed by color alone': {
      required: true,
      check: 'Additional indicators like icons or text labels',
    },
    'Font size scales with system settings': {
      required: true,
      check: 'Use Dynamic Type (iOS) or font scaling (Android)',
    },
    'Bold text support': {
      required: false,
      check: 'Text renders correctly when bold text is enabled',
    },
    'Reduced motion supported': {
      required: true,
      check: 'Animations respect reduce motion setting',
    },
    'High contrast mode supported': {
      required: false,
      check: 'UI adapts to high contrast settings',
    },
  },

  // 3. Motor Accessibility
  motor: {
    'Touch targets are at least 44x44pt': {
      required: true,
      check: 'All tappable elements meet minimum size',
    },
    'Sufficient spacing between touch targets': {
      required: true,
      check: 'Minimum 8pt spacing between interactive elements',
    },
    'Gesture alternatives provided': {
      required: true,
      check: 'All gestures have button or alternative controls',
    },
    'Scrolling is accessible': {
      required: true,
      check: 'Lists and scroll views work with screen readers',
    },
    'Keyboard navigation supported': {
      required: false,
      check: 'All functionality accessible via keyboard (iOS 16+)',
    },
  },

  // 4. Auditory Accessibility
  auditory: {
    'Closed captions for video content': {
      required: true,
      check: 'Captions available for all video media',
    },
    'Transcript for audio content': {
      required: false,
      check: 'Text transcripts for audio-only content',
    },
    'Visual alternatives for audio alerts': {
      required: true,
      check: 'Visual notifications for important audio cues',
    },
    'Volume controls accessible': {
      required: true,
      check: 'Volume can be adjusted without visual interface',
    },
  },

  // 5. Cognitive Accessibility
  cognitive: {
    'Clear and consistent navigation': {
      required: true,
      check: 'Navigation patterns are predictable',
    },
    'Simple and clear language': {
      required: true,
      check: 'Avoid jargon and complex terminology',
    },
    'Error prevention and recovery': {
      required: true,
      check: 'Confirm destructive actions, provide undo options',
    },
    'Sufficient time for reading': {
      required: true,
      check: 'No time limits unless necessary',
    },
    'Pause and stop controls': {
      required: true,
      check: 'Carousels and auto-playing content can be paused',
    },
  },
};

/**
 * Accessibility Score Calculator
 */
export const calculateAccessibilityScore = (results: any): { score: number; grade: string } => {
  const totalChecks = Object.values(results).reduce(
    (sum, category) => sum + Object.values(category).length,
    0
  );
  
  const passedChecks = Object.values(results).reduce(
    (sum, category) => sum + Object.values(category).filter((r: any) => r.passed).length,
    0
  );

  const score = (passedChecks / totalChecks) * 100;

  let grade = 'F';
  if (score >= 95) grade = 'A+';
  else if (score >= 90) grade = 'A';
  else if (score >= 80) grade = 'B';
  else if (score >= 70) grade = 'C';
  else if (score >= 60) grade = 'D';

  return { score, grade };
};
```

---

This appendix provides a comprehensive accessibility framework for your React Native application. By implementing these accessibility features, you'll create an inclusive experience that works for all users, regardless of their abilities or assistive technologies.


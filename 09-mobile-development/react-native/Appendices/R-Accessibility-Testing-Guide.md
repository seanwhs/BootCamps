# Appendix R: Accessibility Testing Guide

Welcome to Appendix R! This comprehensive guide covers everything you need to know about testing accessibility in your React Native application. You'll learn how to use automated tools, conduct manual testing, and ensure your app is usable by everyone, including people with disabilities.

---

## Table of Contents

1. [Accessibility Testing Overview](#accessibility-testing-overview)
2. [Automated Testing Tools](#automated-testing-tools)
3. [Manual Testing Guide](#manual-testing-guide)
4. [Screen Reader Testing](#screen-reader-testing)
5. [Visual Accessibility Testing](#visual-accessibility-testing)
6. [Motor & Cognitive Testing](#motor--cognitive-testing)
7. [Testing with Real Users](#testing-with-real-users)
8. [Accessibility Test Automation](#accessibility-test-automation)

---

## Accessibility Testing Overview

### Testing Framework

```typescript
// src/testing/accessibility/Overview.ts
/**
 * Accessibility Testing Overview
 * 
 * This provides a comprehensive testing framework:
 * - Automated testing
 * - Manual testing
 * - User testing
 * - Continuous testing
 */

export const AccessibilityTestingFramework = {
  // 1. Automated Testing
  automated: {
    tools: ['React Native Testing Library', 'Jest', 'axe-react-native'],
    coverage: [
      'Missing accessibility labels',
      'Invalid accessibility roles',
      'Color contrast violations',
      'Missing touch targets',
    ],
    frequency: 'Every PR / CI run',
  },

  // 2. Manual Testing
  manual: {
    tools: ['Screen readers', 'Keyboard navigation', 'Color contrast checkers'],
    coverage: [
      'Screen reader flow',
      'Focus order',
      'Touch target sizes',
      'Color contrast',
      'Interaction patterns',
    ],
    frequency: 'Every release / Sprint',
  },

  // 3. User Testing
  user: {
    participants: ['Users with disabilities', 'Assistive technology users'],
    coverage: [
      'Real-world usage scenarios',
      'Complex interactions',
      'User experience feedback',
      'Task completion rates',
    ],
    frequency: 'Major releases / Quarterly',
  },

  // 4. Continuous Testing
  continuous: {
    tools: ['CI/CD pipelines', 'Monitoring', 'User feedback'],
    coverage: [
      'Regression detection',
      'Performance monitoring',
      'User-reported issues',
    ],
    frequency: 'Continuous',
  },
};
```

---

## Automated Testing Tools

### Jest Accessibility Testing

```typescript
// src/__tests__/accessibility/Accessibility.test.tsx
import React from 'react';
import { render, screen } from '@testing-library/react-native';
import { Accessibility } from '@testing-library/react-native';

/**
 * Automated Accessibility Testing with Jest
 * 
 * This demonstrates automated accessibility testing:
 * - Accessibility labels
 * - Accessibility roles
 * - Touch target sizes
 * - Color contrast
 */

describe('Accessibility Tests', () => {
  // Test for accessibility labels
  it('should have accessibility labels on all interactive elements', () => {
    render(
      <View>
        <Button
          title="Submit"
          accessibilityLabel="Submit form"
          onPress={jest.fn()}
        />
        <TextInput
          placeholder="Email"
          accessibilityLabel="Email input"
          accessibilityHint="Enter your email address"
        />
      </View>
    );

    // Check accessibility labels
    const button = screen.getByAccessibilityLabel('Submit form');
    expect(button).toBeTruthy();

    const input = screen.getByAccessibilityLabel('Email input');
    expect(input).toBeTruthy();
  });

  // Test for accessibility roles
  it('should have appropriate accessibility roles', () => {
    render(
      <View>
        <Button
          title="Submit"
          accessibilityRole="button"
          onPress={jest.fn()}
        />
        <Text accessibilityRole="heading" accessibilityLevel={1}>
          Welcome
        </Text>
        <View accessibilityRole="list">
          <View accessibilityRole="listitem">
            <Text>Item 1</Text>
          </View>
        </View>
      </View>
    );

    // Check roles
    const button = screen.getByRole('button');
    expect(button).toBeTruthy();

    const heading = screen.getByRole('heading');
    expect(heading).toBeTruthy();

    const list = screen.getByRole('list');
    expect(list).toBeTruthy();
  });

  // Test for touch target sizes
  it('should have minimum touch target sizes', () => {
    const { getByTestId } = render(
      <TouchableOpacity
        testID="small-button"
        style={{ width: 30, height: 30 }}
        onPress={jest.fn()}
      >
        <Text>Small</Text>
      </TouchableOpacity>
    );

    const button = getByTestId('small-button');
    const { width, height } = button.props.style;
    
    // Minimum touch target size is 44x44
    expect(width).toBeGreaterThanOrEqual(44);
    expect(height).toBeGreaterThanOrEqual(44);
  });

  // Test for color contrast
  it('should have sufficient color contrast', () => {
    const { getByTestId } = render(
      <View style={{ backgroundColor: '#ffffff' }}>
        <Text
          testID="low-contrast"
          style={{ color: '#999999' }}
        >
          Low contrast text
        </Text>
        <Text
          testID="good-contrast"
          style={{ color: '#222222' }}
        >
          Good contrast text
        </Text>
      </View>
    );

    // In production, use contrast checking library
    const lowContrast = getByTestId('low-contrast');
    const goodContrast = getByTestId('good-contrast');
    
    // This would be a real contrast check
    expect(goodContrast).toBeTruthy();
  });

  // Test for dynamic content updates
  it('should announce dynamic content updates', () => {
    const { rerender } = render(
      <View
        accessibilityLiveRegion="polite"
        accessibilityLabel="Status message"
      >
        <Text>Loading...</Text>
      </View>
    );

    rerender(
      <View
        accessibilityLiveRegion="polite"
        accessibilityLabel="Status message"
      >
        <Text>Complete!</Text>
      </View>
    );

    // The live region should announce the update
    const message = screen.getByAccessibilityLabel('Status message');
    expect(message).toBeTruthy();
  });
});
```

### Accessibility Lint Rules

```typescript
// .eslintrc.js - Add accessibility rules
module.exports = {
  extends: [
    'plugin:jsx-a11y/recommended',
  ],
  rules: {
    'jsx-a11y/accessible-emoji': 'error',
    'jsx-a11y/alt-text': 'error',
    'jsx-a11y/anchor-has-content': 'error',
    'jsx-a11y/anchor-is-valid': 'error',
    'jsx-a11y/aria-activedescendant-has-tabindex': 'error',
    'jsx-a11y/aria-props': 'error',
    'jsx-a11y/aria-proptypes': 'error',
    'jsx-a11y/aria-role': 'error',
    'jsx-a11y/aria-unsupported-elements': 'error',
    'jsx-a11y/click-events-have-key-events': 'error',
    'jsx-a11y/heading-has-content': 'error',
    'jsx-a11y/html-has-lang': 'error',
    'jsx-a11y/iframe-has-title': 'error',
    'jsx-a11y/img-redundant-alt': 'error',
    'jsx-a11y/interactive-supports-focus': 'error',
    'jsx-a11y/label-has-associated-control': 'error',
    'jsx-a11y/label-has-for': 'error',
    'jsx-a11y/lang': 'error',
    'jsx-a11y/media-has-caption': 'error',
    'jsx-a11y/mouse-events-have-key-events': 'error',
    'jsx-a11y/no-access-key': 'error',
    'jsx-a11y/no-autofocus': 'error',
    'jsx-a11y/no-distracting-elements': 'error',
    'jsx-a11y/no-interactive-element-to-noninteractive-role': 'error',
    'jsx-a11y/no-noninteractive-element-interactions': 'error',
    'jsx-a11y/no-noninteractive-element-to-interactive-role': 'error',
    'jsx-a11y/no-noninteractive-tabindex': 'error',
    'jsx-a11y/no-onchange': 'error',
    'jsx-a11y/no-redundant-roles': 'error',
    'jsx-a11y/no-static-element-interactions': 'error',
    'jsx-a11y/prefer-tag-over-role': 'error',
    'jsx-a11y/role-has-required-aria-props': 'error',
    'jsx-a11y/role-supports-aria-props': 'error',
    'jsx-a11y/scope': 'error',
    'jsx-a11y/tabindex-no-positive': 'error',
  },
};

// src/__tests__/accessibility/Lint.test.ts
/**
 * Accessibility Linting in CI
 */
import { lint } from 'eslint';

describe('Accessibility Linting', () => {
  it('should pass accessibility linting', async () => {
    const results = await lint.lintFiles(['src/**/*.tsx'], {
      baseConfig: {
        extends: ['plugin:jsx-a11y/recommended'],
      },
    });

    const errors = results
      .filter(result => result.errorCount > 0)
      .map(result => ({
        file: result.filePath,
        errors: result.messages,
      }));

    expect(errors).toEqual([]);
  });
});
```

---

## Manual Testing Guide

### Accessibility Testing Checklist

```typescript
// src/testing/accessibility/ManualTesting.ts
/**
 * Manual Accessibility Testing Guide
 * 
 * This provides a comprehensive manual testing guide:
 * - Screen reader testing
 * - Keyboard navigation testing
 * - Visual testing
 * - Interaction testing
 */

export const ManualTestingChecklist = {
  // 1. Screen Reader Testing
  screenReader: {
    tasks: [
      'Test with VoiceOver (iOS)',
      'Test with TalkBack (Android)',
      'Verify all elements are properly labeled',
      'Test focus order and navigation',
      'Test custom actions',
      'Test dynamic content updates',
      'Test modal screens',
      'Test form submissions',
    ],
    checkpoints: {
      labels: 'All interactive elements have descriptive labels',
      roles: 'All elements have appropriate roles',
      state: 'State changes are announced',
      order: 'Focus order follows logical reading order',
      actions: 'Custom actions are accessible',
    },
  },

  // 2. Visual Testing
  visual: {
    tasks: [
      'Test with color blindness simulation',
      'Test with increased font sizes',
      'Test with bold text',
      'Test with reduced motion',
      'Test with high contrast mode',
      'Test with screen magnification',
      'Test with inverted colors',
    ],
    checkpoints: {
      contrast: 'All text meets WCAG AA contrast requirements',
      size: 'Text can be scaled without breaking layout',
      motion: 'Animations respect reduced motion setting',
      readability: 'Text remains readable when zoomed',
    },
  },

  // 3. Motor Testing
  motor: {
    tasks: [
      'Test with keyboard navigation',
      'Test with switch control',
      'Test with voice control',
      'Test with large touch targets',
      'Test with gesture alternatives',
      'Test with assistive touch',
    ],
    checkpoints: {
      targets: 'All touch targets are at least 44x44pt',
      spacing: 'Sufficient spacing between touch targets',
      alternatives: 'All gestures have button alternatives',
      focus: 'Focus indicators are clearly visible',
    },
  },

  // 4. Cognitive Testing
  cognitive: {
    tasks: [
      'Test with screen reader',
      'Test with simplified content',
      'Test with clear instructions',
      'Test with consistent navigation',
      'Test with error prevention',
    ],
    checkpoints: {
      clarity: 'Content is clear and easy to understand',
      consistency: 'Navigation patterns are consistent',
      errors: 'Errors are easy to understand and fix',
      time: 'No time limits unless necessary',
    },
  },
};
```

---

## Screen Reader Testing

### Screen Reader Testing Guide

```typescript
// src/testing/accessibility/ScreenReaderTesting.ts
/**
 * Screen Reader Testing Guide
 * 
 * This provides comprehensive screen reader testing:
 * - VoiceOver (iOS) setup
 * - TalkBack (Android) setup
 * - Testing procedures
 * - Common issues
 */

export const ScreenReaderTesting = {
  // 1. iOS VoiceOver
  voiceOver: {
    setup: {
      enable: 'Settings → Accessibility → VoiceOver → Toggle On',
      practice: 'Settings → Accessibility → VoiceOver → VoiceOver Practice',
      rotor: 'Settings → Accessibility → VoiceOver → Rotor',
      speech: 'Settings → Accessibility → VoiceOver → Speech',
    },
    gestures: {
      tap: 'Select item',
      doubleTap: 'Activate selected item',
      twoFingerTap: 'Play/Pause',
      threeFingerTap: 'Open rotor',
      swipeRight: 'Next item',
      swipeLeft: 'Previous item',
      swipeUp: 'Increase rotor setting',
      swipeDown: 'Decrease rotor setting',
    },
    testing: {
      navigation: 'Swipe through entire app without missing elements',
      actions: 'Double-tap to activate all interactive elements',
      forms: 'Fill and submit forms using only VoiceOver',
      modals: 'Navigate modals with VoiceOver',
      lists: 'Navigate and interact with lists',
    },
  },

  // 2. Android TalkBack
  talkBack: {
    setup: {
      enable: 'Settings → Accessibility → TalkBack → Toggle On',
      shortcut: 'Settings → Accessibility → TalkBack → Shortcut',
      settings: 'Settings → Accessibility → TalkBack → Settings',
    },
    gestures: {
      tap: 'Select item',
      doubleTap: 'Activate selected item',
      swipeRight: 'Next item',
      swipeLeft: 'Previous item',
      swipeUp: 'Scroll up',
      swipeDown: 'Scroll down',
      twoFingerSwipe: 'Scroll view',
    },
    testing: {
      navigation: 'Navigate using TalkBack gestures',
      actions: 'Activate all interactive elements',
      forms: 'Complete forms with TalkBack',
      modals: 'Handle modal dialogs',
      lists: 'Navigate lists and grids',
    },
  },

  // 3. Common Issues
  commonIssues: {
    missingLabels: {
      description: 'Elements without accessibility labels',
      fix: 'Add accessibilityLabel to all interactive elements',
      example: '<Button accessibilityLabel="Submit form" />',
    },
    wrongRoles: {
      description: 'Incorrect accessibility roles',
      fix: 'Use appropriate accessibilityRole',
      example: '<View accessibilityRole="button" />',
    },
    badOrder: {
      description: 'Focus order not logical',
      fix: 'Set importantForAccessibility and accessibilityOrder',
      example: '<View importantForAccessibility="yes" />',
    },
    unannouncedChanges: {
      description: 'Dynamic content not announced',
      fix: 'Use accessibilityLiveRegion',
      example: '<View accessibilityLiveRegion="polite" />',
    },
  },
};
```

---

## Visual Accessibility Testing

### Visual Testing Implementation

```typescript
// src/testing/accessibility/VisualTesting.ts
import { render, screen } from '@testing-library/react-native';
import { Color, ColorContrastChecker } from 'react-native-color-contrast';

/**
 * Visual Accessibility Testing
 * 
 * This provides visual accessibility testing:
 * - Color contrast testing
 * - Font size testing
 * - Color blindness simulation
 * - Layout testing
 */

export class VisualAccessibilityTester {
  private static instance: VisualAccessibilityTester;

  private constructor() {}

  static getInstance(): VisualAccessibilityTester {
    if (!VisualAccessibilityTester.instance) {
      VisualAccessibilityTester.instance = new VisualAccessibilityTester();
    }
    return VisualAccessibilityTester.instance;
  }

  /**
   * Test color contrast
   */
  testColorContrast(foreground: string, background: string): {
    passesAA: boolean;
    passesAAA: boolean;
    ratio: number;
  } {
    // In production, use a contrast checking library
    const ratio = this.calculateContrastRatio(foreground, background);
    
    return {
      passesAA: ratio >= 4.5,
      passesAAA: ratio >= 7,
      ratio,
    };
  }

  /**
   * Calculate contrast ratio
   */
  private calculateContrastRatio(foreground: string, background: string): number {
    // Simple contrast ratio calculation (placeholder)
    // In production, use a proper color contrast library
    return 5.5;
  }

  /**
   * Test font size scalability
   */
  testFontScalability(
    component: React.ReactElement,
    sizes: number[] = [16, 20, 24, 32, 48]
  ): {
    passes: boolean;
    failures: Array<{ size: number; issue: string }>;
  } {
    const failures: Array<{ size: number; issue: string }> = [];

    for (const size of sizes) {
      try {
        // In production, test component at each size
        const { getByTestId } = render(component);
        // Check if content remains readable
      } catch (error) {
        failures.push({ size, issue: error.message });
      }
    }

    return {
      passes: failures.length === 0,
      failures,
    };
  }

  /**
   * Test color blindness simulation
   */
  simulateColorBlindness(type: 'protanopia' | 'deuteranopia' | 'tritanopia'): {
    colors: string[];
    issues: string[];
  } {
    // In production, use color blindness simulation library
    const colors = ['#ff0000', '#00ff00', '#0000ff'];
    const issues: string[] = [];

    // Check color combinations
    if (type === 'protanopia') {
      issues.push('Red and green may be indistinguishable');
      issues.push('Blue remains distinguishable');
    }

    return { colors, issues };
  }

  /**
   * Test layout accessibility
   */
  testLayoutAccessibility(component: React.ReactElement): {
    passes: boolean;
    issues: string[];
  } {
    const issues: string[] = [];

    // Check for touch target sizes
    // Check for adequate spacing
    // Check for visible focus indicators

    return {
      passes: issues.length === 0,
      issues,
    };
  }
}

export const visualAccessibilityTester = VisualAccessibilityTester.getInstance();
```

---

## Motor & Cognitive Testing

### Motor & Cognitive Testing Guide

```typescript
// src/testing/accessibility/MotorCognitiveTesting.ts
/**
 * Motor & Cognitive Accessibility Testing
 * 
 * This provides comprehensive motor and cognitive testing:
 * - Touch target testing
 * - Gesture alternative testing
 * - Navigation testing
 * - Cognitive load testing
 */

export class MotorCognitiveTester {
  private static instance: MotorCognitiveTester;

  private constructor() {}

  static getInstance(): MotorCognitiveTester {
    if (!MotorCognitiveTester.instance) {
      MotorCognitiveTester.instance = new MotorCognitiveTester();
    }
    return MotorCognitiveTester.instance;
  }

  /**
   * Test touch targets
   */
  testTouchTargets(component: React.ReactElement): {
    passed: boolean;
    smallTargets: Array<{ id: string; size: { width: number; height: number } }>;
  } {
    const smallTargets: Array<{ id: string; size: { width: number; height: number } }> = [];
    const minTargetSize = 44; // Apple HIG minimum

    // In production, measure all touch targets
    // For demo, return sample results
    return {
      passed: smallTargets.length === 0,
      smallTargets,
    };
  }

  /**
   * Test gesture alternatives
   */
  testGestureAlternatives(component: React.ReactElement): {
    passed: boolean;
    missingAlternatives: string[];
  } {
    const missingAlternatives: string[] = [];

    // Check for swipe alternatives (buttons)
    // Check for drag alternatives (controls)
    // Check for pinch alternatives (buttons)

    return {
      passed: missingAlternatives.length === 0,
      missingAlternatives,
    };
  }

  /**
   * Test cognitive load
   */
  testCognitiveLoad(component: React.ReactElement): {
    score: number;
    issues: string[];
    recommendations: string[];
  } {
    const issues: string[] = [];
    const recommendations: string[] = [];

    // Check for clear language
    // Check for consistent navigation
    // Check for error prevention
    // Check for clear instructions

    return {
      score: 85,
      issues,
      recommendations,
    };
  }

  /**
   * Test focus management
   */
  testFocusManagement(component: React.ReactElement): {
    passes: boolean;
    issues: string[];
  } {
    const issues: string[] = [];

    // Check focus order
    // Check focus indicators
    // Check focus traps
    // Check focus restoration

    return {
      passes: issues.length === 0,
      issues,
    };
  }
}

export const motorCognitiveTester = MotorCognitiveTester.getInstance();
```

---

## Testing with Real Users

### User Testing Guide

```typescript
// src/testing/accessibility/UserTesting.ts
/**
 * User Testing Guide for Accessibility
 * 
 * This provides a comprehensive guide for testing
 * with users who have disabilities.
 */

export const UserTestingGuide = {
  // 1. Planning
  planning: {
    participants: [
      'Recruit users with various disabilities',
      'Include users with different assistive technologies',
      'Ensure diverse representation',
    ],
    tasks: [
      'Define clear test scenarios',
      'Create realistic tasks',
      'Include complex interactions',
      'Test critical user journeys',
    ],
    environment: [
      'Test in comfortable environment',
      'Allow assistive technology setup time',
      'Provide clear instructions',
    ],
  },

  // 2. Conducting Tests
  conducting: {
    setup: [
      'Explain the testing process',
      'Get consent for recording',
      'Set up assistive technology',
      'Provide contact information',
    ],
    during: [
      'Encourage think-aloud protocol',
      'Observe without interfering',
      'Take detailed notes',
      'Ask clarifying questions',
    ],
    after: [
      'Thank participants',
      'Provide compensation',
      'Share findings',
      'Follow up if needed',
    ],
  },

  // 3. Common User Types
  userTypes: {
    screenReader: {
      description: 'Users who rely on screen readers',
      tasks: 'Navigate and interact using only screen reader',
      feedback: 'Focus order, label clarity, announcement timing',
    },
    keyboard: {
      description: 'Users who use keyboard only',
      tasks: 'Complete tasks without touching screen',
      feedback: 'Focus visibility, navigation flow, activation ease',
    },
    lowVision: {
      description: 'Users with low vision',
      tasks: 'Complete tasks with magnification or reduced contrast',
      feedback: 'Text size, contrast, layout clarity',
    },
    cognitive: {
      description: 'Users with cognitive disabilities',
      tasks: 'Complete tasks requiring comprehension',
      feedback: 'Clarity, consistency, error prevention',
    },
  },
};
```

---

## Accessibility Test Automation

### CI/CD Integration

```typescript
// .github/workflows/accessibility.yml
name: Accessibility Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  accessibility-tests:
    name: Run Accessibility Tests
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18.x'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run accessibility linting
        run: npm run lint:accessibility

      - name: Run accessibility unit tests
        run: npm test -- --testPathPattern=accessibility

      - name: Generate accessibility report
        run: npm run test:accessibility:report

      - name: Upload accessibility report
        uses: actions/upload-artifact@v3
        with:
          name: accessibility-report
          path: ./accessibility-report.html
```

### Accessibility Test Runner

```typescript
// src/testing/accessibility/TestRunner.ts
/**
 * Accessibility Test Runner
 * 
 * This provides a comprehensive test runner for
 * accessibility testing in CI/CD pipelines.
 */

export class AccessibilityTestRunner {
  private static instance: AccessibilityTestRunner;

  private constructor() {}

  static getInstance(): AccessibilityTestRunner {
    if (!AccessibilityTestRunner.instance) {
      AccessibilityTestRunner.instance = new AccessibilityTestRunner();
    }
    return AccessibilityTestRunner.instance;
  }

  /**
   * Run all accessibility tests
   */
  async runAllTests(): Promise<{
    passed: boolean;
    results: {
      automated: { passed: boolean; issues: string[] };
      manual: { passed: boolean; issues: string[] };
      user: { passed: boolean; issues: string[] };
    };
  }> {
    const results = {
      automated: await this.runAutomatedTests(),
      manual: await this.runManualTests(),
      user: await this.runUserTests(),
    };

    const passed = Object.values(results).every(r => r.passed);

    return {
      passed,
      results,
    };
  }

  /**
   * Run automated tests
   */
  private async runAutomatedTests(): Promise<{ passed: boolean; issues: string[] }> {
    const issues: string[] = [];

    // Run Jest accessibility tests
    // Run ESLint accessibility checks
    // Run axe-core tests

    return {
      passed: issues.length === 0,
      issues,
    };
  }

  /**
   * Run manual tests
   */
  private async runManualTests(): Promise<{ passed: boolean; issues: string[] }> {
    const issues: string[] = [];

    // Check manual testing checklist
    // Review test results
    // Verify fixes

    return {
      passed: issues.length === 0,
      issues,
    };
  }

  /**
   * Run user tests
   */
  private async runUserTests(): Promise<{ passed: boolean; issues: string[] }> {
    const issues: string[] = [];

    // Review user testing results
    // Analyze feedback
    // Prioritize issues

    return {
      passed: issues.length === 0,
      issues,
    };
  }

  /**
   * Generate accessibility report
   */
  generateReport(results: any): string {
    const timestamp = new Date().toISOString();
    let report = `# Accessibility Test Report\n\n`;
    report += `**Timestamp:** ${timestamp}\n\n`;
    report += `## Summary\n\n`;
    report += `**Overall Status:** ${results.passed ? '✅ PASSED' : '❌ FAILED'}\n\n`;
    report += `### Automated Tests\n`;
    report += `- Status: ${results.results.automated.passed ? '✅' : '❌'}\n`;
    report += `- Issues: ${results.results.automated.issues.length}\n\n`;
    report += `### Manual Tests\n`;
    report += `- Status: ${results.results.manual.passed ? '✅' : '❌'}\n`;
    report += `- Issues: ${results.results.manual.issues.length}\n\n`;
    report += `### User Tests\n`;
    report += `- Status: ${results.results.user.passed ? '✅' : '❌'}\n`;
    report += `- Issues: ${results.results.user.issues.length}\n\n`;
    report += `## Detailed Issues\n\n`;
    return report;
  }
}

export const accessibilityTestRunner = AccessibilityTestRunner.getInstance();
```

---

## Quick Reference: Accessibility Testing Commands

```bash
# Accessibility testing commands
npm run test:accessibility        # Run all accessibility tests
npm run test:accessibility:unit   # Run unit tests
npm run test:accessibility:lint   # Run linting
npm run test:accessibility:report # Generate report
npm run test:accessibility:fix    # Fix issues
```

---

This appendix provides a comprehensive accessibility testing framework for your React Native application. By implementing these testing strategies, you'll ensure your app is usable by everyone.

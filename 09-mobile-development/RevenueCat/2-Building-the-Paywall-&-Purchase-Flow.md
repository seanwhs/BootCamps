# Part 2: Building the Paywall & Purchase Flow

## Module Overview

Welcome to Part 2! Now that we have RevenueCat configured and initialized, it's time to build the user-facing purchase experience. This is where design meets monetization, and getting it right is crucial for your app's success.

By the end of this module, you'll have:

- ✅ A beautiful, production-quality paywall UI
- ✅ Proper handling of all purchase states (loading, success, error)
- ✅ Subscription comparison with feature highlighting
- ✅ Introductory offer and free trial display
- ✅ Purchase restoration with elegant UX
- ✅ Error handling that actually helps users
- ✅ Accessibility support

Think of this as building the "checkout counter" of your app – it needs to be inviting, clear, and trustworthy while guiding users toward making a purchase.

---

## Phase 1: Designing the Paywall Architecture

### The Target

Create the foundational components and styling system for our paywall, including a reusable design system and screen structure.

### The Concept

A paywall is more than just a price list. It's a conversion-optimized screen that:
1. Communicates the value of your product
2. Shows clear pricing options
3. Builds trust with social proof or guarantees
4. Makes it easy to purchase
5. Complies with app store guidelines

Think of it as the sales page of your app – it needs to be persuasive without being pushy.

### Implementation

#### Step 1.1: Create the Design System

Let's start by establishing our design system – colors, typography, spacing, and reusable components.

**File: `FitTrackPro/src/theme/colors.ts`**

```typescript
/**
 * Design System - Colors
 * 
 * Centralizes all color definitions for the app.
 * This ensures consistency across all components and makes it easy
 * to implement dark mode later.
 */

export const colors = {
  // Primary brand colors
  primary: {
    main: '#4A90D9',
    light: '#6BAAE8',
    dark: '#2E6BB5',
    gradient: ['#4A90D9', '#357ABD'],
  },
  
  // Secondary accent colors
  secondary: {
    main: '#34A853',
    light: '#5CC67A',
    dark: '#1E7C3A',
  },
  
  // Pricing tier colors
  premium: {
    main: '#FF6B35',
    light: '#FF8F5A',
    dark: '#E55A2A',
  },
  
  // Background colors
  background: {
    primary: '#F5F7FA',
    secondary: '#FFFFFF',
    tertiary: '#F0F2F5',
    overlay: 'rgba(0, 0, 0, 0.5)',
  },
  
  // Text colors
  text: {
    primary: '#1A2B3C',
    secondary: '#657786',
    tertiary: '#A0B0C0',
    inverse: '#FFFFFF',
  },
  
  // Border colors
  border: {
    light: '#E8ECF0',
    medium: '#D0D7DD',
    dark: '#A0B0C0',
  },
  
  // Status colors
  status: {
    success: '#34A853',
    warning: '#FBBC04',
    error: '#E74C3C',
    info: '#4A90D9',
  },
  
  // Shadow colors
  shadow: {
    light: 'rgba(0, 0, 0, 0.05)',
    medium: 'rgba(0, 0, 0, 0.1)',
    dark: 'rgba(0, 0, 0, 0.15)',
  },
  
  // Transparent and utility
  transparent: 'transparent',
  white: '#FFFFFF',
  black: '#000000',
};

export type ColorPalette = typeof colors;
export default colors;
```

**File: `FitTrackPro/src/theme/typography.ts`**

```typescript
/**
 * Design System - Typography
 * 
 * Centralizes all text styles for the app.
 * Uses React Native's TextStyle type for type safety.
 */

import { TextStyle } from 'react-native';

export interface TypographyStyles {
  h1: TextStyle;
  h2: TextStyle;
  h3: TextStyle;
  h4: TextStyle;
  body: TextStyle;
  bodyBold: TextStyle;
  bodySmall: TextStyle;
  caption: TextStyle;
  button: TextStyle;
  buttonSmall: TextStyle;
  price: TextStyle;
  priceSmall: TextStyle;
}

export const typography: TypographyStyles = {
  h1: {
    fontSize: 32,
    fontWeight: '700',
    lineHeight: 40,
    letterSpacing: -0.5,
  },
  h2: {
    fontSize: 28,
    fontWeight: '700',
    lineHeight: 34,
    letterSpacing: -0.5,
  },
  h3: {
    fontSize: 24,
    fontWeight: '600',
    lineHeight: 30,
    letterSpacing: -0.3,
  },
  h4: {
    fontSize: 20,
    fontWeight: '600',
    lineHeight: 26,
    letterSpacing: -0.2,
  },
  body: {
    fontSize: 16,
    fontWeight: '400',
    lineHeight: 24,
  },
  bodyBold: {
    fontSize: 16,
    fontWeight: '600',
    lineHeight: 24,
  },
  bodySmall: {
    fontSize: 14,
    fontWeight: '400',
    lineHeight: 20,
  },
  caption: {
    fontSize: 12,
    fontWeight: '400',
    lineHeight: 16,
    letterSpacing: 0.2,
  },
  button: {
    fontSize: 16,
    fontWeight: '600',
    lineHeight: 24,
    letterSpacing: 0.3,
  },
  buttonSmall: {
    fontSize: 14,
    fontWeight: '600',
    lineHeight: 20,
    letterSpacing: 0.2,
  },
  price: {
    fontSize: 34,
    fontWeight: '700',
    lineHeight: 40,
    letterSpacing: -0.5,
  },
  priceSmall: {
    fontSize: 24,
    fontWeight: '700',
    lineHeight: 30,
    letterSpacing: -0.3,
  },
};

export default typography;
```

**File: `FitTrackPro/src/theme/spacing.ts`**

```typescript
/**
 * Design System - Spacing
 * 
 * Centralizes all spacing values for consistent layout.
 * Uses a scale-based system for predictable spacing.
 */

export const spacing = {
  // Base spacing unit
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  xxl: 32,
  xxxl: 48,
  
  // Common spacing combinations
  screen: {
    horizontal: 20,
    vertical: 24,
  },
  card: {
    padding: 16,
    margin: 12,
  },
  section: {
    padding: 20,
    margin: 16,
  },
  button: {
    padding: 12,
    margin: 8,
  },
};

export type Spacing = typeof spacing;
export default spacing;
```

**File: `FitTrackPro/src/theme/index.ts`**

```typescript
/**
 * Design System - Theme Index
 * 
 * Exports all theme-related constants for easy import.
 */

export { colors } from './colors';
export { typography } from './typography';
export { spacing } from './spacing';

// Export a combined theme object
export const theme = {
  colors,
  typography,
  spacing,
};

export default theme;
```

#### Step 1.2: Create Reusable UI Components

**File: `FitTrackPro/src/components/common/Button.tsx`**

```typescript
import React from 'react';
import {
  TouchableOpacity,
  Text,
  ActivityIndicator,
  StyleSheet,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { colors } from '../../theme/colors';
import { typography } from '../../theme/typography';
import { spacing } from '../../theme/spacing';

/**
 * Button Component
 * 
 * A versatile button with multiple variants and states.
 * Supports:
 * - Primary, secondary, outline variants
 * - Loading state
 * - Disabled state
 * - Different sizes
 * 
 * 🎯 This is the main call-to-action component in the app.
 * 
 * @param variant - 'primary' | 'secondary' | 'outline' | 'danger'
 * @param size - 'default' | 'small' | 'large'
 * @param loading - Shows loading spinner
 * @param disabled - Disables button interaction
 * @param onPress - Callback when button is pressed
 */

interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'outline' | 'danger';
  size?: 'default' | 'small' | 'large';
  loading?: boolean;
  disabled?: boolean;
  style?: ViewStyle;
  textStyle?: TextStyle;
  testID?: string;
}

export const Button: React.FC<ButtonProps> = ({
  title,
  onPress,
  variant = 'primary',
  size = 'default',
  loading = false,
  disabled = false,
  style,
  textStyle,
  testID,
}) => {
  // Determine button colors based on variant
  const getButtonStyles = (): ViewStyle => {
    const baseStyle: ViewStyle = {
      borderRadius: 12,
      justifyContent: 'center',
      alignItems: 'center',
      flexDirection: 'row',
    };

    // Size styles
    const sizeStyles: Record<string, ViewStyle> = {
      small: {
        paddingHorizontal: spacing.md,
        paddingVertical: spacing.sm,
        minHeight: 40,
      },
      default: {
        paddingHorizontal: spacing.xl,
        paddingVertical: spacing.md,
        minHeight: 52,
      },
      large: {
        paddingHorizontal: spacing.xxl,
        paddingVertical: spacing.lg,
        minHeight: 60,
      },
    };

    // Variant styles
    const variantStyles: Record<string, ViewStyle> = {
      primary: {
        backgroundColor: colors.primary.main,
      },
      secondary: {
        backgroundColor: colors.secondary.main,
      },
      outline: {
        backgroundColor: colors.transparent,
        borderWidth: 2,
        borderColor: colors.primary.main,
      },
      danger: {
        backgroundColor: colors.status.error,
      },
    };

    // Disabled styles
    const disabledStyle: ViewStyle = disabled ? {
      opacity: 0.5,
    } : {};

    return {
      ...baseStyle,
      ...sizeStyles[size],
      ...variantStyles[variant],
      ...disabledStyle,
      ...style,
    };
  };

  // Determine text color based on variant
  const getTextColor = (): string => {
    switch (variant) {
      case 'primary':
      case 'secondary':
      case 'danger':
        return colors.text.inverse;
      case 'outline':
        return colors.primary.main;
      default:
        return colors.text.inverse;
    }
  };

  // Determine text size based on button size
  const getTextSize = (): TextStyle => {
    switch (size) {
      case 'small':
        return typography.buttonSmall;
      case 'default':
      case 'large':
        return typography.button;
      default:
        return typography.button;
    }
  };

  return (
    <TouchableOpacity
      onPress={onPress}
      disabled={disabled || loading}
      style={getButtonStyles()}
      activeOpacity={0.7}
      testID={testID}
    >
      {loading ? (
        <ActivityIndicator
          color={variant === 'outline' ? colors.primary.main : colors.white}
          size="small"
        />
      ) : (
        <Text
          style={[
            getTextSize(),
            {
              color: getTextColor(),
              textAlign: 'center',
            },
            textStyle,
          ]}
        >
          {title}
        </Text>
      )}
    </TouchableOpacity>
  );
};

export default Button;
```

**File: `FitTrackPro/src/components/common/Card.tsx`**

```typescript
import React from 'react';
import { View, StyleSheet, ViewStyle, StyleProp } from 'react-native';
import { colors } from '../../theme/colors';
import { spacing } from '../../theme/spacing';

/**
 * Card Component
 * 
 * A container component with consistent styling for content cards.
 * Used to group related content with a clean, elevated look.
 */

interface CardProps {
  children: React.ReactNode;
  style?: StyleProp<ViewStyle>;
  variant?: 'default' | 'elevated' | 'outlined';
  testID?: string;
}

export const Card: React.FC<CardProps> = ({
  children,
  style,
  variant = 'default',
  testID,
}) => {
  const getCardStyles = (): ViewStyle => {
    const baseStyle: ViewStyle = {
      backgroundColor: colors.background.secondary,
      borderRadius: 12,
      padding: spacing.lg,
    };

    const variantStyles: Record<string, ViewStyle> = {
      default: {
        borderWidth: 1,
        borderColor: colors.border.light,
      },
      elevated: {
        shadowColor: colors.shadow.dark,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.1,
        shadowRadius: 8,
        elevation: 4,
      },
      outlined: {
        borderWidth: 2,
        borderColor: colors.primary.main,
      },
    };

    return {
      ...baseStyle,
      ...variantStyles[variant],
    };
  };

  return (
    <View style={[getCardStyles(), style]} testID={testID}>
      {children}
    </View>
  );
};

export default Card;
```

**File: `FitTrackPro/src/components/common/Badge.tsx`**

```typescript
import React from 'react';
import { View, Text, StyleSheet, ViewStyle } from 'react-native';
import { colors } from '../../theme/colors';
import { typography } from '../../theme/typography';
import { spacing } from '../../theme/spacing';

/**
 * Badge Component
 * 
 * A small label for displaying status, discounts, or promotional messages.
 * Used to highlight special offers like "Best Value" or "Save 20%".
 */

interface BadgeProps {
  text: string;
  variant?: 'primary' | 'success' | 'warning' | 'premium' | 'info';
  style?: ViewStyle;
}

export const Badge: React.FC<BadgeProps> = ({
  text,
  variant = 'primary',
  style,
}) => {
  const getBadgeColors = () => {
    switch (variant) {
      case 'primary':
        return { background: colors.primary.main, text: colors.white };
      case 'success':
        return { background: colors.secondary.main, text: colors.white };
      case 'warning':
        return { background: colors.status.warning, text: colors.text.primary };
      case 'premium':
        return { background: colors.premium.main, text: colors.white };
      case 'info':
        return { background: colors.primary.light, text: colors.white };
      default:
        return { background: colors.primary.main, text: colors.white };
    }
  };

  const badgeColors = getBadgeColors();

  return (
    <View
      style={[
        styles.badge,
        {
          backgroundColor: badgeColors.background,
        },
        style,
      ]}
    >
      <Text style={[styles.text, { color: badgeColors.text }]}>{text}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  badge: {
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: 20,
    alignSelf: 'flex-start',
  },
  text: {
    ...typography.caption,
    fontWeight: '600',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
});

export default Badge;
```

---

## Phase 2: Building the Paywall Screen

### The Target

Create the complete paywall screen with all its components: header, feature list, pricing cards, and action buttons.

### The Concept

The paywall is your app's revenue engine. It needs to:

1. **Communicate Value**: Show users what they get
2. **Present Options**: Display pricing tiers clearly
3. **Build Trust**: Include testimonials, guarantees, or social proof
4. **Drive Action**: Make the purchase button obvious and easy to tap

We'll build this as a scrollable screen with sections for different information, following Apple's Human Interface Guidelines and Google's Material Design principles.

### Implementation

#### Step 2.1: Create the Paywall Screen

**File: `FitTrackPro/src/screens/PaywallScreen.tsx`**

```typescript
import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
  SafeAreaView,
  TouchableOpacity,
  Dimensions,
  Platform,
  Linking,
  Alert,
} from 'react-native';
import { useRevenueCat } from '../hooks/useRevenueCat';
import { Button } from '../components/common/Button';
import { Card } from '../components/common/Card';
import { Badge } from '../components/common/Badge';
import { colors } from '../theme/colors';
import { typography } from '../theme/typography';
import { spacing } from '../theme/spacing';
import { Package } from 'react-native-purchases';

const { width: screenWidth } = Dimensions.get('window');

/**
 * PaywallScreen
 * 
 * The main subscription purchase screen.
 * 
 * Features:
 * - Hero section with value proposition
 * - Feature comparison list
 * - Pricing cards for each tier
 * - Monthly/Annual toggle (future enhancement)
 * - Purchase button with loading states
 * - Restore purchases option
 * - Terms and privacy policy links
 * 
 * 🎯 This is the most important screen for monetization.
 * Every element is optimized for conversion.
 */

export const PaywallScreen: React.FC = () => {
  // RevenueCat hook for purchase functionality
  const {
    isLoading,
    offerings,
    customerInfo,
    purchasePackage,
    restorePurchases,
    refreshCustomerInfo,
  } = useRevenueCat();

  // Local state
  const [selectedPackage, setSelectedPackage] = useState<Package | null>(null);
  const [isPurchasing, setIsPurchasing] = useState(false);
  const [isRestoring, setIsRestoring] = useState(false);
  const [purchaseError, setPurchaseError] = useState<string | null>(null);
  const [showAnnual, setShowAnnual] = useState(false);

  // Get packages from the current offering
  const packages = offerings?.current?.availablePackages || [];
  
  // Separate packages by subscription period
  const monthlyPackages = packages.filter((pkg) => 
    pkg.identifier.includes('monthly') || pkg.identifier === 'monthly'
  );
  
  const annualPackages = packages.filter((pkg) => 
    pkg.identifier.includes('annual') || pkg.identifier === 'annual'
  );

  // Default to first package if none selected
  useEffect(() => {
    if (!selectedPackage && packages.length > 0) {
      // Prefer annual for better LTV (lifetime value)
      const annualPkg = annualPackages[0];
      const monthlyPkg = monthlyPackages[0];
      
      // If showing annual, select annual; otherwise select monthly
      setSelectedPackage(showAnnual ? annualPkg || monthlyPkg : monthlyPkg || annualPkg);
    }
  }, [packages, selectedPackage, showAnnual, annualPackages, monthlyPackages]);

  /**
   * Handle purchase button press
   */
  const handlePurchase = async () => {
    if (!selectedPackage) {
      setPurchaseError('Please select a subscription plan.');
      return;
    }

    setIsPurchasing(true);
    setPurchaseError(null);

    try {
      const result = await purchasePackage(selectedPackage);
      
      // Check if purchase was successful
      const grantedEntitlements = Object.keys(result.customerInfo.entitlements.active);
      
      if (grantedEntitlements.length > 0) {
        // Success! Show a success message or navigate away
        Alert.alert(
          '🎉 Welcome to FitTrack Pro!',
          `You now have access to:\n\n${grantedEntitlements.map(e => '• ' + e.replace('_', ' ')).join('\n')}`,
          [
            {
              text: 'Get Started',
              onPress: () => {
                // Navigate to the main app
                // We'll implement navigation later
              },
            },
          ]
        );
      } else {
        // Purchase succeeded but no entitlements - this shouldn't happen normally
        Alert.alert(
          'Purchase Complete',
          'Your purchase was successful. If you don\'t see your premium features, please try restoring purchases.'
        );
      }
    } catch (error) {
      // Handle specific purchase errors
      const errorMessage = error instanceof Error ? error.message : 'Purchase failed. Please try again.';
      setPurchaseError(errorMessage);
      
      // Only show error for non-cancellation errors
      if (!errorMessage.includes('cancelled')) {
        Alert.alert('Purchase Failed', errorMessage);
      }
    } finally {
      setIsPurchasing(false);
    }
  };

  /**
   * Handle restore purchases
   */
  const handleRestore = async () => {
    setIsRestoring(true);
    setPurchaseError(null);

    try {
      const info = await restorePurchases();
      const grantedEntitlements = Object.keys(info.entitlements.active);
      
      if (grantedEntitlements.length > 0) {
        Alert.alert(
          '✅ Purchases Restored',
          `Your subscription has been restored. You have access to:\n\n${grantedEntitlements.map(e => '• ' + e.replace('_', ' ')).join('\n')}`
        );
      } else {
        Alert.alert(
          'No Purchases Found',
          'We couldn\'t find any existing purchases to restore. If you believe this is an error, please contact support.'
        );
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Restore failed. Please try again.';
      Alert.alert('Restore Failed', errorMessage);
    } finally {
      setIsRestoring(false);
    }
  };

  /**
   * Format price with currency
   */
  const formatPrice = (packageToFormat: Package): string => {
    return packageToFormat.localizedPriceString;
  };

  /**
   * Get discount percentage for annual vs monthly
   */
  const getDiscountPercentage = (annualPkg: Package, monthlyPkg: Package): number | null => {
    if (!annualPkg || !monthlyPkg) return null;
    
    // Extract numeric price from localized string (remove currency symbols)
    const annualPrice = parseFloat(annualPkg.localizedPriceString.replace(/[^0-9.]/g, ''));
    const monthlyPrice = parseFloat(monthlyPkg.localizedPriceString.replace(/[^0-9.]/g, ''));
    
    if (isNaN(annualPrice) || isNaN(monthlyPrice) || monthlyPrice === 0) return null;
    
    const annualMonthlyEquivalent = annualPrice / 12;
    const discount = ((monthlyPrice - annualMonthlyEquivalent) / monthlyPrice) * 100;
    
    return Math.round(discount);
  };

  // Calculate discount if we have both packages
  const monthlyPkg = monthlyPackages[0];
  const annualPkg = annualPackages[0];
  const discountPercentage = getDiscountPercentage(annualPkg, monthlyPkg);

  // Determine which packages to show
  const displayedPackages = showAnnual ? annualPackages : monthlyPackages;

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView 
        style={styles.scrollView}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
      >
        {/* Hero Section */}
        <View style={styles.heroSection}>
          <View style={styles.logoContainer}>
            <Text style={styles.emoji}>💪</Text>
          </View>
          <Text style={styles.heroTitle}>Unlock Your Full Potential</Text>
          <Text style={styles.heroSubtitle}>
            Get unlimited access to premium workouts, nutrition tracking, and personal trainer guidance
          </Text>
        </View>

        {/* Feature List */}
        <View style={styles.featuresSection}>
          <Card variant="elevated">
            <View style={styles.featureItem}>
              <Text style={styles.featureIcon}>🏋️</Text>
              <View style={styles.featureContent}>
                <Text style={styles.featureTitle}>Premium Workouts</Text>
                <Text style={styles.featureDescription}>Access 500+ exercises, custom routines, and advanced training programs</Text>
              </View>
            </View>
            
            <View style={styles.divider} />
            
            <View style={styles.featureItem}>
              <Text style={styles.featureIcon}>🥗</Text>
              <View style={styles.featureContent}>
                <Text style={styles.featureTitle}>Nutrition Tracking</Text>
                <Text style={styles.featureDescription}>Log meals, track macros, and get personalized meal recommendations</Text>
              </View>
            </View>
            
            <View style={styles.divider} />
            
            <View style={styles.featureItem}>
              <Text style={styles.featureIcon}>💬</Text>
              <View style={styles.featureContent}>
                <Text style={styles.featureTitle}>Personal Trainer Chat</Text>
                <Text style={styles.featureDescription}>Get 1-on-1 guidance from certified trainers, anytime</Text>
              </View>
            </View>
          </Card>
        </View>

        {/* Pricing Section */}
        <View style={styles.pricingSection}>
          <View style={styles.pricingHeader}>
            <Text style={styles.pricingTitle}>Choose Your Plan</Text>
            
            {/* Toggle between Monthly and Annual */}
            {monthlyPackages.length > 0 && annualPackages.length > 0 && (
              <View style={styles.toggleContainer}>
                <TouchableOpacity
                  style={[styles.toggleOption, !showAnnual && styles.toggleActive]}
                  onPress={() => setShowAnnual(false)}
                >
                  <Text style={[styles.toggleText, !showAnnual && styles.toggleTextActive]}>
                    Monthly
                  </Text>
                </TouchableOpacity>
                <TouchableOpacity
                  style={[styles.toggleOption, showAnnual && styles.toggleActive]}
                  onPress={() => setShowAnnual(true)}
                >
                  <Text style={[styles.toggleText, showAnnual && styles.toggleTextActive]}>
                    Annual
                  </Text>
                  {discountPercentage && (
                    <Badge 
                      text={`Save ${discountPercentage}%`} 
                      variant="premium" 
                      style={styles.discountBadge}
                    />
                  )}
                </TouchableOpacity>
              </View>
            )}
          </View>

          {/* Package Cards */}
          {displayedPackages.map((pkg) => {
            const isSelected = selectedPackage?.identifier === pkg.identifier;
            const isBestValue = pkg.identifier.includes('annual') && discountPercentage && discountPercentage > 15;
            
            // Check if this package has a free trial
            const hasTrial = pkg.presentedOfferingContext?.offeringIdentifier !== undefined;
            
            return (
              <TouchableOpacity
                key={pkg.identifier}
                style={[
                  styles.packageCard,
                  isSelected && styles.packageCardSelected,
                  isBestValue && styles.packageCardBestValue,
                ]}
                onPress={() => setSelectedPackage(pkg)}
                activeOpacity={0.8}
              >
                {isBestValue && (
                  <View style={styles.bestValueBadge}>
                    <Text style={styles.bestValueText}>⭐ Best Value</Text>
                  </View>
                )}
                
                <View style={styles.packageHeader}>
                  <Text style={styles.packageName}>
                    {pkg.identifier === 'monthly' ? 'Monthly' : 
                     pkg.identifier === 'annual' ? 'Annual' :
                     pkg.identifier}
                  </Text>
                  {hasTrial && (
                    <Badge text="7-day free trial" variant="success" />
                  )}
                </View>
                
                <Text style={styles.packagePrice}>
                  {formatPrice(pkg)}
                  {pkg.identifier === 'annual' && (
                    <Text style={styles.priceSubtext}> / year</Text>
                  )}
                  {pkg.identifier === 'monthly' && (
                    <Text style={styles.priceSubtext}> / month</Text>
                  )}
                </Text>
                
                {pkg.identifier === 'annual' && monthlyPkg && (
                  <Text style={styles.savingsText}>
                    Only {formatPrice(monthlyPkg)}/month if paid annually
                  </Text>
                )}
                
                <View style={styles.packageBenefits}>
                  {pkg.identifier === 'annual' && (
                    <Text style={styles.benefitText}>✅ Save 20% vs monthly</Text>
                  )}
                  <Text style={styles.benefitText}>✅ Full access to all features</Text>
                  <Text style={styles.benefitText}>✅ Cancel anytime</Text>
                  {pkg.identifier === 'annual' && (
                    <Text style={styles.benefitText}>✅ Priority support</Text>
                  )}
                </View>
              </TouchableOpacity>
            );
          })}

          {/* Purchase Button */}
          <Button
            title={isPurchasing ? 'Processing...' : 
                   selectedPackage?.identifier === 'annual' ? 'Subscribe Annually' :
                   selectedPackage?.identifier === 'monthly' ? 'Subscribe Monthly' :
                   'Subscribe'}
            onPress={handlePurchase}
            variant="primary"
            size="large"
            loading={isPurchasing}
            disabled={!selectedPackage || isPurchasing}
            style={styles.purchaseButton}
          />

          {purchaseError && (
            <Text style={styles.errorText}>{purchaseError}</Text>
          )}

          {/* Terms and Conditions */}
          <View style={styles.termsContainer}>
            <Text style={styles.termsText}>
              By continuing, you agree to our{' '}
              <Text 
                style={styles.termsLink}
                onPress={() => Linking.openURL('https://example.com/terms')}
              >
                Terms of Service
              </Text>
              {' '}and{' '}
              <Text 
                style={styles.termsLink}
                onPress={() => Linking.openURL('https://example.com/privacy')}
              >
                Privacy Policy
              </Text>
            </Text>
          </View>
        </View>

        {/* Restore Purchases */}
        <View style={styles.restoreSection}>
          <TouchableOpacity
            onPress={handleRestore}
            disabled={isRestoring}
            style={styles.restoreButton}
          >
            <Text style={styles.restoreText}>
              {isRestoring ? 'Restoring...' : 'Already have a subscription? Restore Purchases'}
            </Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background.primary,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: spacing.xxxl,
  },
  
  // Hero Section
  heroSection: {
    paddingHorizontal: spacing.xl,
    paddingTop: spacing.xxl,
    paddingBottom: spacing.xl,
    alignItems: 'center',
    backgroundColor: colors.background.primary,
  },
  logoContainer: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: colors.primary.main,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: spacing.lg,
    shadowColor: colors.primary.main,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 6,
  },
  emoji: {
    fontSize: 40,
  },
  heroTitle: {
    ...typography.h2,
    textAlign: 'center',
    color: colors.text.primary,
    marginBottom: spacing.sm,
  },
  heroSubtitle: {
    ...typography.body,
    textAlign: 'center',
    color: colors.text.secondary,
    paddingHorizontal: spacing.lg,
  },
  
  // Features Section
  featuresSection: {
    paddingHorizontal: spacing.xl,
    marginBottom: spacing.xl,
  },
  featureItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    paddingVertical: spacing.sm,
  },
  featureIcon: {
    fontSize: 24,
    marginRight: spacing.lg,
    marginTop: 2,
  },
  featureContent: {
    flex: 1,
  },
  featureTitle: {
    ...typography.bodyBold,
    color: colors.text.primary,
    marginBottom: 2,
  },
  featureDescription: {
    ...typography.bodySmall,
    color: colors.text.secondary,
  },
  divider: {
    height: 1,
    backgroundColor: colors.border.light,
    marginVertical: spacing.sm,
  },
  
  // Pricing Section
  pricingSection: {
    paddingHorizontal: spacing.xl,
  },
  pricingHeader: {
    marginBottom: spacing.lg,
  },
  pricingTitle: {
    ...typography.h3,
    color: colors.text.primary,
    marginBottom: spacing.md,
  },
  toggleContainer: {
    flexDirection: 'row',
    backgroundColor: colors.background.tertiary,
    borderRadius: 25,
    padding: 4,
    alignSelf: 'flex-start',
  },
  toggleOption: {
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderRadius: 20,
    position: 'relative',
  },
  toggleActive: {
    backgroundColor: colors.background.secondary,
    shadowColor: colors.shadow.light,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  toggleText: {
    ...typography.bodySmall,
    color: colors.text.secondary,
    fontWeight: '500',
  },
  toggleTextActive: {
    color: colors.text.primary,
    fontWeight: '600',
  },
  discountBadge: {
    position: 'absolute',
    top: -12,
    right: -12,
  },
  
  // Package Cards
  packageCard: {
    backgroundColor: colors.background.secondary,
    borderRadius: 16,
    padding: spacing.lg,
    marginBottom: spacing.md,
    borderWidth: 2,
    borderColor: colors.border.light,
    position: 'relative',
  },
  packageCardSelected: {
    borderColor: colors.primary.main,
    shadowColor: colors.primary.main,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  packageCardBestValue: {
    borderColor: colors.premium.main,
    backgroundColor: colors.background.secondary,
  },
  bestValueBadge: {
    position: 'absolute',
    top: -12,
    right: spacing.lg,
    backgroundColor: colors.premium.main,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderRadius: 20,
  },
  bestValueText: {
    ...typography.caption,
    color: colors.white,
    fontWeight: '700',
  },
  packageHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  packageName: {
    ...typography.h4,
    color: colors.text.primary,
  },
  packagePrice: {
    ...typography.price,
    color: colors.text.primary,
    marginBottom: spacing.xs,
  },
  priceSubtext: {
    ...typography.body,
    color: colors.text.secondary,
    fontSize: 16,
  },
  savingsText: {
    ...typography.bodySmall,
    color: colors.secondary.main,
    marginBottom: spacing.sm,
  },
  packageBenefits: {
    marginTop: spacing.sm,
  },
  benefitText: {
    ...typography.bodySmall,
    color: colors.text.secondary,
    marginBottom: 2,
  },
  
  // Purchase Button
  purchaseButton: {
    marginTop: spacing.md,
    marginBottom: spacing.sm,
  },
  errorText: {
    ...typography.bodySmall,
    color: colors.status.error,
    textAlign: 'center',
    marginTop: spacing.sm,
  },
  
  // Terms
  termsContainer: {
    marginTop: spacing.md,
    paddingHorizontal: spacing.md,
  },
  termsText: {
    ...typography.caption,
    color: colors.text.tertiary,
    textAlign: 'center',
    lineHeight: 18,
  },
  termsLink: {
    ...typography.caption,
    color: colors.primary.main,
    fontWeight: '600',
    textDecorationLine: 'underline',
  },
  
  // Restore
  restoreSection: {
    paddingHorizontal: spacing.xl,
    marginTop: spacing.lg,
    alignItems: 'center',
  },
  restoreButton: {
    padding: spacing.md,
  },
  restoreText: {
    ...typography.bodySmall,
    color: colors.primary.main,
    fontWeight: '500',
  },
});

export default PaywallScreen;
```

#### Step 2.2: Update the App Entry Point

**File: `FitTrackPro/App.tsx`**

```typescript
import React from 'react';
import { SafeAreaView, StatusBar } from 'react-native';
import { PaywallScreen } from './src/screens/PaywallScreen';
import { colors } from './src/theme/colors';

/**
 * Main Application Component
 * 
 * For Part 2, we'll just show the paywall screen directly.
 * In future parts, we'll add navigation and multiple screens.
 */
const App = () => {
  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background.primary }}>
      <StatusBar barStyle="dark-content" backgroundColor={colors.background.primary} />
      <PaywallScreen />
    </SafeAreaView>
  );
};

export default App;
```

---

## Phase 3: Advanced Purchase Flow

### The Target

Implement sophisticated purchase handling with proper state management, error recovery, and user feedback.

### The Concept

Purchasing is a multi-step process that can fail at any point. Users might:
- Cancel the purchase
- Lose network connection
- Have insufficient funds
- Encounter store errors
- Have payment pending

We need to handle all these scenarios gracefully and keep the user informed.

### Implementation

#### Step 3.1: Purchase Flow Component

**File: `FitTrackPro/src/components/paywall/PurchaseFlow.tsx`**

```typescript
import React, { useState, useCallback } from 'react';
import {
  View,
  Text,
  Modal,
  ActivityIndicator,
  StyleSheet,
  TouchableOpacity,
  Animated,
  Easing,
} from 'react-native';
import { colors } from '../../theme/colors';
import { typography } from '../../theme/typography';
import { spacing } from '../../theme/spacing';

/**
 * Purchase Flow Component
 * 
 * Manages the purchase flow states and shows appropriate UI for each state.
 * 
 * States:
 * - idle: Ready to purchase
 * - processing: Purchase is being processed
 * - success: Purchase completed successfully
 * - error: Purchase failed
 * - restoring: Restoring purchases
 */

type PurchaseState = 'idle' | 'processing' | 'success' | 'error' | 'restoring';

interface PurchaseFlowProps {
  isVisible: boolean;
  state: PurchaseState;
  errorMessage?: string;
  onClose: () => void;
  onRetry?: () => void;
}

export const PurchaseFlow: React.FC<PurchaseFlowProps> = ({
  isVisible,
  state,
  errorMessage,
  onClose,
  onRetry,
}) => {
  // Animated value for fade in
  const [fadeAnim] = useState(new Animated.Value(0));

  React.useEffect(() => {
    if (isVisible) {
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 300,
        easing: Easing.ease,
        useNativeDriver: true,
      }).start();
    } else {
      Animated.timing(fadeAnim, {
        toValue: 0,
        duration: 200,
        easing: Easing.ease,
        useNativeDriver: true,
      }).start();
    }
  }, [isVisible, fadeAnim]);

  const renderContent = () => {
    switch (state) {
      case 'processing':
        return (
          <View style={styles.content}>
            <ActivityIndicator size="large" color={colors.primary.main} />
            <Text style={styles.title}>Processing Purchase</Text>
            <Text style={styles.subtitle}>Please wait while we complete your transaction...</Text>
          </View>
        );

      case 'restoring':
        return (
          <View style={styles.content}>
            <ActivityIndicator size="large" color={colors.primary.main} />
            <Text style={styles.title}>Restoring Purchases</Text>
            <Text style={styles.subtitle}>Looking for your existing subscriptions...</Text>
          </View>
        );

      case 'success':
        return (
          <View style={styles.content}>
            <View style={styles.successIcon}>
              <Text style={styles.emoji}>🎉</Text>
            </View>
            <Text style={styles.title}>Welcome Aboard!</Text>
            <Text style={styles.subtitle}>
              Your subscription has been activated. Enjoy all the premium features!
            </Text>
            <TouchableOpacity style={styles.successButton} onPress={onClose}>
              <Text style={styles.successButtonText}>Get Started</Text>
            </TouchableOpacity>
          </View>
        );

      case 'error':
        return (
          <View style={styles.content}>
            <View style={styles.errorIcon}>
              <Text style={styles.emoji}>😕</Text>
            </View>
            <Text style={[styles.title, styles.errorTitle]}>Something Went Wrong</Text>
            <Text style={styles.subtitle}>
              {errorMessage || 'We encountered an issue processing your purchase. Please try again.'}
            </Text>
            <View style={styles.errorButtons}>
              {onRetry && (
                <TouchableOpacity style={styles.retryButton} onPress={onRetry}>
                  <Text style={styles.retryButtonText}>Try Again</Text>
                </TouchableOpacity>
              )}
              <TouchableOpacity style={styles.errorCloseButton} onPress={onClose}>
                <Text style={styles.errorCloseButtonText}>Cancel</Text>
              </TouchableOpacity>
            </View>
          </View>
        );

      default:
        return null;
    }
  };

  return (
    <Modal
      transparent
      visible={isVisible}
      animationType="none"
      statusBarTranslucent
      onRequestClose={onClose}
    >
      <Animated.View style={[styles.overlay, { opacity: fadeAnim }]}>
        <View style={styles.modalContainer}>
          <View style={styles.modalContent}>{renderContent()}</View>
        </View>
      </Animated.View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: colors.background.overlay,
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContainer: {
    padding: spacing.xl,
    width: '100%',
    maxWidth: 400,
  },
  modalContent: {
    backgroundColor: colors.background.secondary,
    borderRadius: 24,
    padding: spacing.xxl,
    minHeight: 300,
    justifyContent: 'center',
    shadowColor: colors.shadow.dark,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.2,
    shadowRadius: 16,
    elevation: 8,
  },
  content: {
    alignItems: 'center',
  },
  title: {
    ...typography.h3,
    color: colors.text.primary,
    textAlign: 'center',
    marginTop: spacing.lg,
    marginBottom: spacing.sm,
  },
  subtitle: {
    ...typography.body,
    color: colors.text.secondary,
    textAlign: 'center',
    marginBottom: spacing.xl,
    lineHeight: 24,
  },
  emoji: {
    fontSize: 48,
  },
  successIcon: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: colors.secondary.main,
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorIcon: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: colors.status.error,
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorTitle: {
    color: colors.status.error,
  },
  successButton: {
    backgroundColor: colors.primary.main,
    paddingHorizontal: spacing.xxl,
    paddingVertical: spacing.md,
    borderRadius: 12,
    minWidth: 200,
    alignItems: 'center',
  },
  successButtonText: {
    ...typography.button,
    color: colors.text.inverse,
  },
  errorButtons: {
    flexDirection: 'row',
    gap: spacing.md,
    marginTop: spacing.md,
  },
  retryButton: {
    backgroundColor: colors.primary.main,
    paddingHorizontal: spacing.xl,
    paddingVertical: spacing.md,
    borderRadius: 12,
    minWidth: 120,
    alignItems: 'center',
  },
  retryButtonText: {
    ...typography.button,
    color: colors.text.inverse,
  },
  errorCloseButton: {
    backgroundColor: colors.border.light,
    paddingHorizontal: spacing.xl,
    paddingVertical: spacing.md,
    borderRadius: 12,
    minWidth: 120,
    alignItems: 'center',
  },
  errorCloseButtonText: {
    ...typography.button,
    color: colors.text.secondary,
  },
});

export default PurchaseFlow;
```

---

## Phase 4: Error Handling & UX Best Practices

### The Target

Implement comprehensive error handling with user-friendly messaging and recovery strategies.

### The Concept

Good error handling is invisible when things work and helpful when they don't. Users should never feel confused or stuck.

### Implementation

#### Step 4.1: Error Utility

**File: `FitTrackPro/src/utils/errorUtils.ts`**

```typescript
import { Platform } from 'react-native';

/**
 * Error Utilities
 * 
 * Provides error handling utilities for the app.
 * Includes:
 * - Error type detection
 * - User-friendly error messages
 * - Error logging
 * - Recovery suggestions
 */

export enum ErrorType {
  NETWORK = 'network',
  PURCHASE_CANCELLED = 'purchase_cancelled',
  PRODUCT_NOT_AVAILABLE = 'product_not_available',
  PURCHASE_NOT_ALLOWED = 'purchase_not_allowed',
  INVALID_CREDENTIALS = 'invalid_credentials',
  RECEIPT_INVALID = 'receipt_invalid',
  UNKNOWN = 'unknown',
}

export interface AppError {
  type: ErrorType;
  message: string;
  userMessage: string;
  recoverable: boolean;
  recoverySuggestion?: string;
  originalError?: Error;
}

/**
 * Parse an error and return a structured AppError
 */
export const parseError = (error: any): AppError => {
  console.error('Original error:', error);

  // Handle RevenueCat errors
  if (error?.code) {
    switch (error.code) {
      case 'PURCHASE_CANCELLED':
      case 'USER_CANCELLED':
        return {
          type: ErrorType.PURCHASE_CANCELLED,
          message: 'Purchase was cancelled by the user.',
          userMessage: 'You cancelled the purchase. No charges were made.',
          recoverable: true,
          recoverySuggestion: 'You can try again whenever you\'re ready.',
          originalError: error,
        };
      
      case 'PRODUCT_NOT_AVAILABLE':
        return {
          type: ErrorType.PRODUCT_NOT_AVAILABLE,
          message: 'Product is not available for purchase.',
          userMessage: 'This subscription is currently not available. Please try again later.',
          recoverable: false,
          recoverySuggestion: 'Please try again later.',
          originalError: error,
        };
      
      case 'PURCHASE_NOT_ALLOWED':
        return {
          type: ErrorType.PURCHASE_NOT_ALLOWED,
          message: 'In-app purchases are not allowed.',
          userMessage: Platform.select({
            ios: 'In-app purchases are not allowed on this device. Please check your Restrictions settings.',
            android: 'In-app purchases are not allowed on this device. Please check your Google Play settings.',
          }),
          recoverable: false,
          recoverySuggestion: Platform.select({
            ios: 'Go to Settings → Screen Time → Content & Privacy Restrictions and enable In-app Purchases.',
            android: 'Check that Google Play is installed and you have a valid payment method.',
          }),
          originalError: error,
        };
      
      case 'NETWORK_ERROR':
        return {
          type: ErrorType.NETWORK,
          message: 'Network connection error.',
          userMessage: 'Please check your internet connection and try again.',
          recoverable: true,
          recoverySuggestion: 'Make sure you have a stable internet connection.',
          originalError: error,
        };
      
      case 'INVALID_CREDENTIALS':
        return {
          type: ErrorType.INVALID_CREDENTIALS,
          message: 'Invalid API credentials.',
          userMessage: 'There was a problem with your account. Please contact support.',
          recoverable: false,
          originalError: error,
        };
      
      default:
        return {
          type: ErrorType.UNKNOWN,
          message: error.message || 'Unknown error occurred.',
          userMessage: 'Something went wrong. Please try again.',
          recoverable: true,
          originalError: error,
        };
    }
  }

  // Handle network errors
  if (error?.message?.includes('network') || error?.message?.includes('connection')) {
    return {
      type: ErrorType.NETWORK,
      message: 'Network connection error.',
      userMessage: 'Please check your internet connection and try again.',
      recoverable: true,
      recoverySuggestion: 'Make sure you have a stable internet connection.',
      originalError: error,
    };
  }

  // Default: unknown error
  return {
    type: ErrorType.UNKNOWN,
    message: error?.message || 'Unknown error occurred.',
    userMessage: 'Something went wrong. Please try again.',
    recoverable: true,
    originalError: error,
  };
};

/**
 * Log error for analytics/monitoring
 */
export const logError = (error: AppError, context?: Record<string, any>) => {
  // In production, this would send to a service like Sentry or Firebase Crashlytics
  console.error(`[ERROR] ${error.type}:`, {
    message: error.message,
    context,
    originalError: error.originalError,
  });
};

/**
 * Check if an error is recoverable
 */
export const isErrorRecoverable = (error: AppError): boolean => {
  return error.recoverable;
};

/**
 * Get a user-friendly message for the error
 */
export const getUserFriendlyMessage = (error: AppError): string => {
  return error.userMessage;
};

export default {
  parseError,
  logError,
  isErrorRecoverable,
  getUserFriendlyMessage,
};
```

#### Step 4.2: Integrating Error Handling in Paywall

Now let's update the PaywallScreen to use our error handling utilities:

**File: `FitTrackPro/src/screens/PaywallScreen.tsx` (Update)**

Add these imports and update the handlePurchase method:

```typescript
// Add to imports
import { parseError, logError } from '../utils/errorUtils';
import { PurchaseFlow } from '../components/paywall/PurchaseFlow';

// Add state for purchase flow
const [purchaseFlowState, setPurchaseFlowState] = useState<'idle' | 'processing' | 'success' | 'error' | 'restoring'>('idle');
const [flowErrorMessage, setFlowErrorMessage] = useState<string>('');

// Update handlePurchase method
const handlePurchase = async () => {
  if (!selectedPackage) {
    setPurchaseError('Please select a subscription plan.');
    return;
  }

  setPurchaseFlowState('processing');
  setPurchaseError(null);

  try {
    const result = await purchasePackage(selectedPackage);
    
    // Check if purchase was successful
    const grantedEntitlements = Object.keys(result.customerInfo.entitlements.active);
    
    if (grantedEntitlements.length > 0) {
      setPurchaseFlowState('success');
    } else {
      // Purchase succeeded but no entitlements - restore might work
      setPurchaseFlowState('success');
      // We'll let the success flow handle it
    }
  } catch (error) {
    // Use our error parsing utility
    const appError = parseError(error);
    logError(appError, { context: 'purchase' });
    
    setPurchaseFlowState('error');
    setFlowErrorMessage(appError.userMessage);
    
    // Log to analytics
    // trackEvent('purchase_error', { error_type: appError.type, error_message: appError.message });
  }
};

// Update handleRestore
const handleRestore = async () => {
  setPurchaseFlowState('restoring');
  setPurchaseError(null);

  try {
    const info = await restorePurchases();
    const grantedEntitlements = Object.keys(info.entitlements.active);
    
    if (grantedEntitlements.length > 0) {
      setPurchaseFlowState('success');
    } else {
      // No purchases found - show error with helpful message
      setPurchaseFlowState('error');
      setFlowErrorMessage('No existing subscriptions found to restore.');
    }
  } catch (error) {
    const appError = parseError(error);
    logError(appError, { context: 'restore' });
    
    setPurchaseFlowState('error');
    setFlowErrorMessage(appError.userMessage);
  }
};

// Add PurchaseFlow component at the end of the render
return (
  <>
    {/* ... existing JSX ... */}
    
    {/* Purchase Flow Modal */}
    <PurchaseFlow
      isVisible={purchaseFlowState !== 'idle'}
      state={purchaseFlowState}
      errorMessage={flowErrorMessage}
      onClose={() => {
        setPurchaseFlowState('idle');
        // If success, navigate or refresh
        if (purchaseFlowState === 'success') {
          refreshCustomerInfo();
        }
      }}
      onRetry={() => {
        setPurchaseFlowState('idle');
        handlePurchase();
      }}
    />
  </>
);
```

---

## Verification

### Test the Paywall

1. **Display Test**: Verify the paywall shows with all components:
   - Hero section with value proposition
   - Feature list
   - Pricing cards with correct prices
   - Toggle between monthly/annual
   - Purchase button
   - Restore button

2. **Purchase Flow Test**:
   - Select a package
   - Click "Subscribe"
   - Use sandbox/test account to complete purchase
   - Verify success state shows
   - Check entitlements are granted

3. **Error Handling Test**:
   - Cancel a purchase mid-flow
   - Verify appropriate error message shows
   - Verify retry option works

4. **Restore Test**:
   - Click "Restore Purchases"
   - Verify flow shows correctly
   - If purchases exist, show success state

### Common Verification Commands

```bash
# Clear iOS build cache
cd ios && pod deintegrate && pod install

# Clear React Native cache
npx react-native start --reset-cache

# Run on iOS
npx react-native run-ios

# Run on Android
npx react-native run-android
```

---

## Module Summary

Congratulations! You've completed Part 2 of the RevenueCat tutorial series. Here's what you've accomplished:

✅ **Built a Production Paywall**: Created a beautiful, conversion-optimized subscription screen
✅ **Implemented Design System**: Established colors, typography, and spacing for consistency
✅ **Created Reusable Components**: Built Button, Card, and Badge components
✅ **Handled Multiple Subscription Tiers**: Supported monthly and annual plans with dynamic pricing
✅ **Implemented Purchase Flow**: Complete purchase handling with loading and success states
✅ **Added Error Handling**: Comprehensive error parsing and user-friendly messages
✅ **Supported Purchase Restoration**: Users can restore existing purchases
✅ **Included Legal Requirements**: Terms of Service and Privacy Policy links

### What You Can Do Now

Your app now has:
- A professional-looking paywall screen
- Working purchase flow with proper state management
- Graceful error handling
- Purchase restoration functionality

### Next Steps

In **Part 3: Subscription State Management & Access Control**, we'll:
- Build a subscription status dashboard
- Implement premium feature gating
- Add user authentication integration
- Handle cross-device synchronization
- Build admin features for managing subscription status

---

## Reference: Paywall Design Best Practices

### Conversion Optimization Tips

1. **Value First, Price Second**: Always show the value before the price
2. **Use Social Proof**: Include testimonials or user counts
3. **Highlight the Best Deal**: Make your annual plan the obvious choice
4. **Use Urgency Sparingly**: "Limited time offer" can work but don't abuse it
5. **Clear CTAs**: Make the purchase button obvious and action-oriented
6. **Reduce Friction**: Minimize required steps to purchase
7. **Build Trust**: Include security badges, money-back guarantees
8. **Test Everything**: A/B test different layouts, pricing, and copy

### Common Mistakes to Avoid

1. **Hiding the Price**: Users want to know what they're paying
2. **Too Many Options**: 2-3 options is optimal
3. **Confusing Language**: Use plain English, avoid jargon
4. **Forgetting the Free Tier**: Show what they get vs. what they could get
5. **No Value Proposition**: Why should they subscribe?
6. **Hidden Terms**: Always show terms and conditions clearly

---

You now have a beautiful, functional paywall with robust purchase handling. In Part 3, we'll build the infrastructure for managing subscription state and gating premium features throughout your app.

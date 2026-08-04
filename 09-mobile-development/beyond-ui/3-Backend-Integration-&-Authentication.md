# Part 3: Backend Integration & Authentication

## Connecting Your App to the Cloud

Now that we have our application architecture in place, it's time to connect NexusCollect to a real backend. Think of this as installing the plumbing and electrical systems in our house—the app is now ready to receive water (data) and power (authentication) from external sources.

In this part, we'll build a complete, production-ready authentication system using Supabase as our backend. This includes user registration, login, session management, social authentication, and secure data access.

### The Target

By the end of this part, you will have:

1. A fully configured Supabase backend with database tables and security policies
2. Complete authentication flow (login, register, logout, password reset)
3. Social login integration (Google and Apple)
4. Secure session management with automatic token refresh
5. Protected API routes with Row Level Security (RLS)
6. Real-time subscriptions for live data updates
7. User profile management with avatar uploads
8. Comprehensive error handling and validation

---

## Phase 3.1: Supabase Backend Setup

### The Concept: Your App's Brain

Think of Supabase as the brain of your application. It stores all user data, handles authentication, and manages real-time updates. It's built on PostgreSQL, which means you get a powerful, relational database with built-in security features.

### The Implementation: Database Configuration

#### Step 3.1.1: Create Supabase Project

1. **Go to [Supabase Dashboard](https://app.supabase.com)**
   - Sign up or log in to your account
   - Click "New Project"
   - Fill in the project details:
     - **Name:** `nexuscollect`
     - **Database Password:** (create a strong password and save it)
     - **Region:** Choose the closest to your users
     - **Pricing Plan:** Free tier works for development

2. **Wait for the database to be initialized** (2-3 minutes)

3. **Get your project credentials:**
   - Go to Project Settings → API
   - Copy the **URL** and **anon public** key
   - We'll use these in our environment variables

#### Step 3.1.2: Update Environment Variables

```env
# .env.development
API_URL=http://localhost:3000
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
ENVIRONMENT=development
LOG_LEVEL=debug

# .env.production
API_URL=https://api.nexuscollect.com
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
ENVIRONMENT=production
LOG_LEVEL=error
```

#### Step 3.1.3: Create Database Tables

Go to the Supabase SQL Editor and run these migrations:

```sql
-- 1. Create profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  last_login TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT TRUE,
  settings JSONB DEFAULT '{}'::jsonb,
  metadata JSONB DEFAULT '{}'::jsonb
);

-- 2. Create forms table
CREATE TABLE IF NOT EXISTS public.forms (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  fields JSONB NOT NULL,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  is_public BOOLEAN DEFAULT FALSE,
  is_template BOOLEAN DEFAULT FALSE,
  version INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb
);

-- 3. Create collections table (entries)
CREATE TABLE IF NOT EXISTS public.collections (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  form_id UUID REFERENCES public.forms(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  data JSONB NOT NULL,
  location JSONB,
  photos TEXT[],
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'synced', 'archived')),
  synced_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  submitted_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB DEFAULT '{}'::jsonb
);

-- 4. Create sync_queue table for offline sync
CREATE TABLE IF NOT EXISTS public.sync_queue (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  operation TEXT NOT NULL CHECK (operation IN ('create', 'update', 'delete')),
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  data JSONB NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  retry_count INTEGER DEFAULT 0,
  last_attempt TIMESTAMP WITH TIME ZONE,
  error_message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  processed_at TIMESTAMP WITH TIME ZONE
);

-- 5. Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  read_at TIMESTAMP WITH TIME ZONE
);

-- 6. Create audit_logs table
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  action TEXT NOT NULL,
  resource TEXT NOT NULL,
  resource_id UUID,
  details JSONB,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 7. Create indexes for performance
CREATE INDEX idx_profiles_email ON public.profiles(email);
CREATE INDEX idx_forms_user_id ON public.forms(user_id);
CREATE INDEX idx_collections_user_id ON public.collections(user_id);
CREATE INDEX idx_collections_form_id ON public.collections(form_id);
CREATE INDEX idx_collections_status ON public.collections(status);
CREATE INDEX idx_sync_queue_user_id ON public.sync_queue(user_id);
CREATE INDEX idx_sync_queue_status ON public.sync_queue(status);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX idx_audit_logs_user_id ON public.audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON public.audit_logs(created_at DESC);

-- 8. Enable Row Level Security (RLS) on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- 9. Create RLS Policies

-- Profiles: Users can read/update their own profile
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Forms: Users can CRUD their own forms
CREATE POLICY "Users can view their own forms"
  ON public.forms FOR SELECT
  USING (auth.uid() = user_id OR is_public = true);

CREATE POLICY "Users can create their own forms"
  ON public.forms FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own forms"
  ON public.forms FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own forms"
  ON public.forms FOR DELETE
  USING (auth.uid() = user_id);

-- Collections: Users can CRUD their own collections
CREATE POLICY "Users can view their own collections"
  ON public.collections FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own collections"
  ON public.collections FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own collections"
  ON public.collections FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own collections"
  ON public.collections FOR DELETE
  USING (auth.uid() = user_id);

-- Sync Queue: Users can manage their own sync items
CREATE POLICY "Users can view their own sync queue"
  ON public.sync_queue FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own sync queue items"
  ON public.sync_queue FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own sync queue items"
  ON public.sync_queue FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own sync queue items"
  ON public.sync_queue FOR DELETE
  USING (auth.uid() = user_id);

-- Notifications: Users can view their own notifications
CREATE POLICY "Users can view their own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Audit Logs: Users can view their own audit logs
CREATE POLICY "Users can view their own audit logs"
  ON public.audit_logs FOR SELECT
  USING (auth.uid() = user_id);

-- 10. Create function to handle user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, avatar_url, metadata)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url',
    NEW.raw_user_meta_data->'metadata'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 11. Trigger to automatically create profile on user signup
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 12. Create function to update updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 13. Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_forms_updated_at
  BEFORE UPDATE ON public.forms
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_collections_updated_at
  BEFORE UPDATE ON public.collections
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_sync_queue_updated_at
  BEFORE UPDATE ON public.sync_queue
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at
  BEFORE UPDATE ON public.notifications
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 14. Seed data (optional, for development)
INSERT INTO public.forms (title, description, fields, user_id, is_template)
VALUES (
  'Sample Form',
  'A sample form for testing',
  '[
    {"id": "field1", "label": "Name", "type": "text", "required": true},
    {"id": "field2", "label": "Email", "type": "text", "required": true},
    {"id": "field3", "label": "Message", "type": "text", "required": false}
  ]'::jsonb,
  (SELECT id FROM auth.users LIMIT 1),
  true
) ON CONFLICT DO NOTHING;
```

---

## Phase 3.2: Authentication Flow Implementation

### The Concept: Securing Access

Authentication is like a security checkpoint at a building entrance. Users must prove who they are (identity) before they can access the building's resources. We'll implement multiple ways for users to authenticate:

- Email/Password (traditional)
- Google OAuth (one-click login)
- Apple Sign In (privacy-focused)

### The Implementation: Complete Auth Screens

#### Step 3.2.1: Login Screen

```typescript
// src/screens/auth/LoginScreen.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { useAuth } from '@hooks/useAuth';
import { Button } from '@components/common/Button';
import { Input } from '@components/common/Input';
import { useTheme } from '@themes';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { AuthScreenNavigationProp } from '@types/navigation';
import * as Google from 'expo-auth-session/providers/google';
import * as Apple from 'expo-auth-session/providers/apple';
import { supabase } from '@api/supabase';
import { ActivityIndicator } from 'react-native';

/**
 * Login Screen
 * 
 * Allows users to log in with email/password or social providers.
 * Handles validation, error states, and navigation.
 */
export default function LoginScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [emailError, setEmailError] = useState('');
  const [passwordError, setPasswordError] = useState('');
  const [isSocialLoading, setIsSocialLoading] = useState(false);
  const [touched, setTouched] = useState({ email: false, password: false });
  
  const { login, isLoading, error } = useAuth();
  const theme = useTheme();
  const navigation = useNavigation<AuthScreenNavigationProp>();

  // Google OAuth
  const [googleRequest, googleResponse, googlePromptAsync] = Google.useAuthRequest({
    expoClientId: 'your-google-expo-client-id',
    iosClientId: 'your-google-ios-client-id',
    androidClientId: 'your-google-android-client-id',
  });

  // Apple Sign In
  const [appleRequest, appleResponse, applePromptAsync] = Apple.useAuthRequest({
    clientId: 'com.yourcompany.nexuscollect',
    redirectUri: 'nexuscollect://apple-callback',
    scopes: ['email', 'name'],
  });

  /**
   * Validate form before submission
   */
  const validateForm = (): boolean => {
    let isValid = true;
    
    // Email validation
    if (!email) {
      setEmailError('Email is required');
      isValid = false;
    } else if (!email.includes('@') || !email.includes('.')) {
      setEmailError('Please enter a valid email');
      isValid = false;
    } else {
      setEmailError('');
    }
    
    // Password validation
    if (!password) {
      setPasswordError('Password is required');
      isValid = false;
    } else if (password.length < 6) {
      setPasswordError('Password must be at least 6 characters');
      isValid = false;
    } else {
      setPasswordError('');
    }
    
    return isValid;
  };

  /**
   * Handle email/password login
   */
  const handleLogin = async () => {
    setTouched({ email: true, password: true });
    
    if (!validateForm()) {
      return;
    }
    
    const result = await login(email, password);
    if (!result.success && result.error) {
      Alert.alert('Login Failed', result.error);
    }
  };

  /**
   * Handle Google login
   */
  const handleGoogleLogin = async () => {
    try {
      setIsSocialLoading(true);
      const result = await googlePromptAsync();
      
      if (result?.type === 'success') {
        const { access_token, id_token } = result.params;
        const { data, error } = await supabase.auth.signInWithIdToken({
          provider: 'google',
          token: id_token,
          access_token: access_token,
        });
        
        if (error) throw error;
        // User is now authenticated
      } else {
        Alert.alert('Google Login Cancelled', 'You cancelled the Google login process.');
      }
    } catch (error: any) {
      Alert.alert('Google Login Error', error.message || 'Failed to sign in with Google');
    } finally {
      setIsSocialLoading(false);
    }
  };

  /**
   * Handle Apple login
   */
  const handleAppleLogin = async () => {
    try {
      setIsSocialLoading(true);
      const result = await applePromptAsync();
      
      if (result?.type === 'success') {
        const { id_token } = result.params;
        const { data, error } = await supabase.auth.signInWithIdToken({
          provider: 'apple',
          token: id_token,
        });
        
        if (error) throw error;
        // User is now authenticated
      } else {
        Alert.alert('Apple Login Cancelled', 'You cancelled the Apple login process.');
      }
    } catch (error: any) {
      Alert.alert('Apple Login Error', error.message || 'Failed to sign in with Apple');
    } finally {
      setIsSocialLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={[styles.container, { backgroundColor: theme.colors.background }]}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 64 : 0}
    >
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.header}>
          <Text style={[styles.title, { color: theme.colors.text }]}>
            Welcome Back
          </Text>
          <Text style={[styles.subtitle, { color: theme.colors.textSecondary }]}>
            Sign in to continue to NexusCollect
          </Text>
        </View>

        <View style={styles.form}>
          <Input
            label="Email Address"
            value={email}
            onChangeText={setEmail}
            placeholder="you@example.com"
            keyboardType="email-address"
            autoCapitalize="none"
            autoCorrect={false}
            leftIcon="mail-outline"
            error={emailError}
            touched={touched.email}
            onBlur={() => setTouched({ ...touched, email: true })}
          />

          <Input
            label="Password"
            value={password}
            onChangeText={setPassword}
            placeholder="Enter your password"
            secureTextEntry
            leftIcon="lock-closed-outline"
            error={passwordError}
            touched={touched.password}
            onBlur={() => setTouched({ ...touched, password: true })}
          />

          <TouchableOpacity
            style={styles.forgotPassword}
            onPress={() => navigation.navigate('ForgotPassword')}
          >
            <Text style={[styles.forgotPasswordText, { color: theme.colors.primary[500] }]}>
              Forgot Password?
            </Text>
          </TouchableOpacity>

          {error && (
            <View style={[styles.errorContainer, { backgroundColor: theme.colors.error + '10' }]}>
              <Text style={[styles.errorText, { color: theme.colors.error }]}>
                {error}
              </Text>
            </View>
          )}

          <Button
            title="Sign In"
            onPress={handleLogin}
            variant="primary"
            size="large"
            loading={isLoading}
            style={styles.loginButton}
          />

          <View style={styles.divider}>
            <View style={[styles.dividerLine, { backgroundColor: theme.colors.border }]} />
            <Text style={[styles.dividerText, { color: theme.colors.textSecondary }]}>
              OR
            </Text>
            <View style={[styles.dividerLine, { backgroundColor: theme.colors.border }]} />
          </View>

          <View style={styles.socialButtons}>
            <Button
              title="Google"
              onPress={handleGoogleLogin}
              variant="outline"
              style={styles.socialButton}
              loading={isSocialLoading && googleRequest}
            />
            <Button
              title="Apple"
              onPress={handleAppleLogin}
              variant="outline"
              style={styles.socialButton}
              loading={isSocialLoading && appleRequest}
            />
          </View>

          <View style={styles.footer}>
            <Text style={[styles.footerText, { color: theme.colors.textSecondary }]}>
              Don't have an account?{' '}
            </Text>
            <TouchableOpacity onPress={() => navigation.navigate('Register')}>
              <Text style={[styles.footerLink, { color: theme.colors.primary[500] }]}>
                Sign Up
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    paddingHorizontal: 24,
    paddingTop: 60,
    paddingBottom: 40,
  },
  header: {
    marginBottom: 40,
  },
  title: {
    fontSize: 32,
    fontWeight: '700',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
  },
  form: {
    flex: 1,
  },
  forgotPassword: {
    alignSelf: 'flex-end',
    marginTop: 4,
    marginBottom: 24,
  },
  forgotPasswordText: {
    fontSize: 14,
    fontWeight: '500',
  },
  errorContainer: {
    padding: 12,
    borderRadius: 8,
    marginBottom: 16,
  },
  errorText: {
    fontSize: 14,
  },
  loginButton: {
    marginTop: 8,
  },
  divider: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: 24,
  },
  dividerLine: {
    flex: 1,
    height: 1,
  },
  dividerText: {
    paddingHorizontal: 16,
    fontSize: 14,
  },
  socialButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: 12,
  },
  socialButton: {
    flex: 1,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 24,
  },
  footerText: {
    fontSize: 14,
  },
  footerLink: {
    fontSize: 14,
    fontWeight: '600',
  },
});
```

#### Step 3.2.2: Register Screen

```typescript
// src/screens/auth/RegisterScreen.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { useAuth } from '@hooks/useAuth';
import { Button } from '@components/common/Button';
import { Input } from '@components/common/Input';
import { useTheme } from '@themes';
import { useNavigation } from '@react-navigation/native';
import { AuthScreenNavigationProp } from '@types/navigation';

export default function RegisterScreen() {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    confirmPassword: '',
    fullName: '',
  });
  const [errors, setErrors] = useState({
    email: '',
    password: '',
    confirmPassword: '',
    fullName: '',
  });
  const [touched, setTouched] = useState({
    email: false,
    password: false,
    confirmPassword: false,
    fullName: false,
  });
  
  const { register, isLoading } = useAuth();
  const theme = useTheme();
  const navigation = useNavigation<AuthScreenNavigationProp>();

  /**
   * Validate the registration form
   */
  const validateForm = (): boolean => {
    let isValid = true;
    const newErrors = { email: '', password: '', confirmPassword: '', fullName: '' };

    // Full Name validation
    if (!formData.fullName.trim()) {
      newErrors.fullName = 'Full name is required';
      isValid = false;
    } else if (formData.fullName.length < 2) {
      newErrors.fullName = 'Name must be at least 2 characters';
      isValid = false;
    }

    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!formData.email) {
      newErrors.email = 'Email is required';
      isValid = false;
    } else if (!emailRegex.test(formData.email)) {
      newErrors.email = 'Please enter a valid email';
      isValid = false;
    }

    // Password validation
    if (!formData.password) {
      newErrors.password = 'Password is required';
      isValid = false;
    } else if (formData.password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters';
      isValid = false;
    }

    // Confirm Password validation
    if (!formData.confirmPassword) {
      newErrors.confirmPassword = 'Please confirm your password';
      isValid = false;
    } else if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = 'Passwords do not match';
      isValid = false;
    }

    setErrors(newErrors);
    return isValid;
  };

  /**
   * Handle registration submission
   */
  const handleRegister = async () => {
    setTouched({
      email: true,
      password: true,
      confirmPassword: true,
      fullName: true,
    });

    if (!validateForm()) {
      return;
    }

    const result = await register(
      formData.email,
      formData.password,
      formData.fullName
    );

    if (!result.success && result.error) {
      Alert.alert('Registration Failed', result.error);
    }
  };

  return (
    <KeyboardAvoidingView
      style={[styles.container, { backgroundColor: theme.colors.background }]}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 64 : 0}
    >
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.header}>
          <Text style={[styles.title, { color: theme.colors.text }]}>
            Create Account
          </Text>
          <Text style={[styles.subtitle, { color: theme.colors.textSecondary }]}>
            Join NexusCollect and start collecting data
          </Text>
        </View>

        <View style={styles.form}>
          <Input
            label="Full Name"
            value={formData.fullName}
            onChangeText={(text) => setFormData({ ...formData, fullName: text })}
            placeholder="John Doe"
            leftIcon="person-outline"
            error={errors.fullName}
            touched={touched.fullName}
            onBlur={() => setTouched({ ...touched, fullName: true })}
          />

          <Input
            label="Email Address"
            value={formData.email}
            onChangeText={(text) => setFormData({ ...formData, email: text })}
            placeholder="you@example.com"
            keyboardType="email-address"
            autoCapitalize="none"
            autoCorrect={false}
            leftIcon="mail-outline"
            error={errors.email}
            touched={touched.email}
            onBlur={() => setTouched({ ...touched, email: true })}
          />

          <Input
            label="Password"
            value={formData.password}
            onChangeText={(text) => setFormData({ ...formData, password: text })}
            placeholder="Create a password"
            secureTextEntry
            leftIcon="lock-closed-outline"
            error={errors.password}
            touched={touched.password}
            onBlur={() => setTouched({ ...touched, password: true })}
          />

          <Input
            label="Confirm Password"
            value={formData.confirmPassword}
            onChangeText={(text) => setFormData({ ...formData, confirmPassword: text })}
            placeholder="Confirm your password"
            secureTextEntry
            leftIcon="lock-closed-outline"
            error={errors.confirmPassword}
            touched={touched.confirmPassword}
            onBlur={() => setTouched({ ...touched, confirmPassword: true })}
          />

          <Button
            title="Create Account"
            onPress={handleRegister}
            variant="primary"
            size="large"
            loading={isLoading}
            style={styles.registerButton}
          />

          <View style={styles.footer}>
            <Text style={[styles.footerText, { color: theme.colors.textSecondary }]}>
              Already have an account?{' '}
            </Text>
            <TouchableOpacity onPress={() => navigation.navigate('Login')}>
              <Text style={[styles.footerLink, { color: theme.colors.primary[500] }]}>
                Sign In
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    paddingHorizontal: 24,
    paddingTop: 40,
    paddingBottom: 40,
  },
  header: {
    marginBottom: 32,
  },
  title: {
    fontSize: 32,
    fontWeight: '700',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
  },
  form: {
    flex: 1,
  },
  registerButton: {
    marginTop: 16,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 24,
  },
  footerText: {
    fontSize: 14,
  },
  footerLink: {
    fontSize: 14,
    fontWeight: '600',
  },
});
```

#### Step 3.2.3: Forgot Password Screen

```typescript
// src/screens/auth/ForgotPasswordScreen.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { Button } from '@components/common/Button';
import { Input } from '@components/common/Input';
import { useTheme } from '@themes';
import { authService } from '@api/services/authService';
import { useNavigation } from '@react-navigation/native';
import { AuthScreenNavigationProp } from '@types/navigation';

export default function ForgotPasswordScreen() {
  const [email, setEmail] = useState('');
  const [error, setError] = useState('');
  const [touched, setTouched] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  
  const theme = useTheme();
  const navigation = useNavigation<AuthScreenNavigationProp>();

  const handleResetPassword = async () => {
    // Validate email
    if (!email) {
      setError('Email is required');
      setTouched(true);
      return;
    }
    if (!email.includes('@') || !email.includes('.')) {
      setError('Please enter a valid email');
      setTouched(true);
      return;
    }

    setError('');
    setIsLoading(true);

    try {
      await authService.resetPassword(email);
      setIsSuccess(true);
      Alert.alert(
        'Password Reset',
        'We have sent a password reset link to your email. Please check your inbox.',
        [
          {
            text: 'OK',
            onPress: () => navigation.navigate('Login'),
          },
        ]
      );
    } catch (err: any) {
      Alert.alert(
        'Reset Failed',
        err.message || 'Failed to send password reset email. Please try again.'
      );
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={[styles.container, { backgroundColor: theme.colors.background }]}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Text style={[styles.backText, { color: theme.colors.primary[500] }]}>
            ← Back
          </Text>
        </TouchableOpacity>

        <View style={styles.header}>
          <Text style={[styles.title, { color: theme.colors.text }]}>
            Reset Password
          </Text>
          <Text style={[styles.subtitle, { color: theme.colors.textSecondary }]}>
            Enter your email address and we'll send you a link to reset your password.
          </Text>
        </View>

        <View style={styles.form}>
          <Input
            label="Email Address"
            value={email}
            onChangeText={setEmail}
            placeholder="you@example.com"
            keyboardType="email-address"
            autoCapitalize="none"
            autoCorrect={false}
            leftIcon="mail-outline"
            error={error}
            touched={touched}
            onBlur={() => setTouched(true)}
          />

          <Button
            title="Send Reset Link"
            onPress={handleResetPassword}
            variant="primary"
            size="large"
            loading={isLoading}
            disabled={isLoading}
            style={styles.resetButton}
          />

          <TouchableOpacity
            style={styles.loginLink}
            onPress={() => navigation.navigate('Login')}
          >
            <Text style={[styles.loginText, { color: theme.colors.textSecondary }]}>
              Remember your password?{' '}
              <Text style={{ color: theme.colors.primary[500], fontWeight: '600' }}>
                Sign In
              </Text>
            </Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    paddingHorizontal: 24,
    paddingTop: 20,
    paddingBottom: 40,
  },
  backButton: {
    marginBottom: 20,
  },
  backText: {
    fontSize: 16,
    fontWeight: '500',
  },
  header: {
    marginBottom: 32,
  },
  title: {
    fontSize: 32,
    fontWeight: '700',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    lineHeight: 24,
  },
  form: {
    flex: 1,
  },
  resetButton: {
    marginTop: 16,
  },
  loginLink: {
    marginTop: 24,
    alignItems: 'center',
  },
  loginText: {
    fontSize: 14,
  },
});
```

---

## Phase 3.3: User Profile Management

### The Concept: User Identity

The profile is the user's identity within your app. It stores their personal information, preferences, and avatar. Think of it as a digital ID card that represents the user across the application.

### The Implementation: Profile Management

```typescript
// src/screens/main/ProfileScreen.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Image,
  TouchableOpacity,
  ScrollView,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { useAuth } from '@hooks/useAuth';
import { useTheme } from '@themes';
import { Button } from '@components/common/Button';
import { Input } from '@components/common/Input';
import { Card } from '@components/common/Card';
import { Ionicons } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import { supabase } from '@api/supabase';
import { useNavigation } from '@react-navigation/native';
import { MainScreenNavigationProp } from '@types/navigation';

export default function ProfileScreen() {
  const { user, updateProfile, logout } = useAuth();
  const theme = useTheme();
  const navigation = useNavigation<MainScreenNavigationProp>();
  const [isEditing, setIsEditing] = useState(false);
  const [fullName, setFullName] = useState(user?.fullName || '');
  const [isUploading, setIsUploading] = useState(false);
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  /**
   * Handle profile update
   */
  const handleUpdateProfile = async () => {
    if (!fullName.trim()) {
      Alert.alert('Error', 'Full name is required');
      return;
    }

    const result = await updateProfile({ fullName: fullName.trim() });
    if (result.success) {
      setIsEditing(false);
      Alert.alert('Success', 'Profile updated successfully');
    } else {
      Alert.alert('Error', result.error || 'Failed to update profile');
    }
  };

  /**
   * Handle avatar upload
   */
  const handleUploadAvatar = async () => {
    try {
      // Request permissions
      const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Permission Denied', 'Please grant access to your photo library');
        return;
      }

      // Pick image
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.8,
        base64: true,
      });

      if (!result.canceled && result.assets[0]) {
        const asset = result.assets[0];
        const fileExt = asset.uri?.split('.').pop() || 'jpg';
        const fileName = `${user?.id}-${Date.now()}.${fileExt}`;
        const filePath = `avatars/${fileName}`;

        setIsUploading(true);

        // Upload to Supabase Storage
        const formData = new FormData();
        formData.append('file', {
          uri: asset.uri,
          type: `image/${fileExt}`,
          name: fileName,
        } as any);

        const { data, error } = await supabase.storage
          .from('avatars')
          .upload(filePath, formData);

        if (error) throw error;

        // Get public URL
        const { data: urlData } = supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

        // Update profile with avatar URL
        await updateProfile({ avatarUrl: urlData.publicUrl });
        
        Alert.alert('Success', 'Profile picture updated successfully');
      }
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Failed to upload avatar');
    } finally {
      setIsUploading(false);
    }
  };

  /**
   * Handle logout
   */
  const handleLogout = async () => {
    Alert.alert(
      'Logout',
      'Are you sure you want to logout?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Logout',
          style: 'destructive',
          onPress: async () => {
            setIsLoggingOut(true);
            try {
              await logout();
            } catch (error) {
              Alert.alert('Error', 'Failed to logout');
            } finally {
              setIsLoggingOut(false);
            }
          },
        },
      ]
    );
  };

  if (!user) {
    return (
      <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
        <Text style={{ color: theme.colors.text }}>Loading...</Text>
      </View>
    );
  }

  return (
    <ScrollView
      style={[styles.container, { backgroundColor: theme.colors.background }]}
      showsVerticalScrollIndicator={false}
    >
      {/* Profile Header */}
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.avatarContainer}
          onPress={handleUploadAvatar}
          disabled={isUploading}
        >
          {isUploading ? (
            <View style={[styles.avatar, styles.avatarLoading, { borderColor: theme.colors.border }]}>
              <ActivityIndicator size="large" color={theme.colors.primary[500]} />
            </View>
          ) : user.avatarUrl ? (
            <Image source={{ uri: user.avatarUrl }} style={styles.avatar} />
          ) : (
            <View style={[styles.avatar, styles.avatarPlaceholder, { backgroundColor: theme.colors.primary[100] }]}>
              <Text style={[styles.avatarText, { color: theme.colors.primary[500] }]}>
                {user.fullName?.charAt(0)?.toUpperCase() || '?'}
              </Text>
            </View>
          )}
          <View style={[styles.avatarBadge, { backgroundColor: theme.colors.primary[500] }]}>
            <Ionicons name="camera" size={16} color="#fff" />
          </View>
        </TouchableOpacity>

        <Text style={[styles.userName, { color: theme.colors.text }]}>
          {user.fullName}
        </Text>
        <Text style={[styles.userEmail, { color: theme.colors.textSecondary }]}>
          {user.email}
        </Text>
      </View>

      {/* Profile Form */}
      <Card style={styles.card}>
        <View style={styles.cardHeader}>
          <Text style={[styles.cardTitle, { color: theme.colors.text }]}>
            Personal Information
          </Text>
          <TouchableOpacity onPress={() => setIsEditing(!isEditing)}>
            <Text style={{ color: theme.colors.primary[500], fontSize: 14, fontWeight: '600' }}>
              {isEditing ? 'Cancel' : 'Edit'}
            </Text>
          </TouchableOpacity>
        </View>

        <View style={styles.infoSection}>
          <View style={styles.infoRow}>
            <Text style={[styles.infoLabel, { color: theme.colors.textSecondary }]}>
              Full Name
            </Text>
            {isEditing ? (
              <Input
                value={fullName}
                onChangeText={setFullName}
                containerStyle={styles.inputContainer}
                inputStyle={styles.input}
              />
            ) : (
              <Text style={[styles.infoValue, { color: theme.colors.text }]}>
                {user.fullName}
              </Text>
            )}
          </View>

          <View style={styles.infoRow}>
            <Text style={[styles.infoLabel, { color: theme.colors.textSecondary }]}>
              Email
            </Text>
            <Text style={[styles.infoValue, { color: theme.colors.text }]}>
              {user.email}
            </Text>
          </View>

          <View style={styles.infoRow}>
            <Text style={[styles.infoLabel, { color: theme.colors.textSecondary }]}>
              Member Since
            </Text>
            <Text style={[styles.infoValue, { color: theme.colors.text }]}>
              {new Date(user.createdAt).toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric',
              })}
            </Text>
          </View>

          {isEditing && (
            <Button
              title="Save Changes"
              onPress={handleUpdateProfile}
              variant="primary"
              style={styles.saveButton}
            />
          )}
        </View>
      </Card>

      {/* Stats Card */}
      <Card style={styles.card}>
        <Text style={[styles.cardTitle, { color: theme.colors.text }]}>
          Statistics
        </Text>
        <View style={styles.statsGrid}>
          <View style={styles.statItem}>
            <Text style={[styles.statNumber, { color: theme.colors.text }]}>
              12
            </Text>
            <Text style={[styles.statLabel, { color: theme.colors.textSecondary }]}>
              Forms Created
            </Text>
          </View>
          <View style={styles.statItem}>
            <Text style={[styles.statNumber, { color: theme.colors.text }]}>
              45
            </Text>
            <Text style={[styles.statLabel, { color: theme.colors.textSecondary }]}>
              Collections
            </Text>
          </View>
          <View style={styles.statItem}>
            <Text style={[styles.statNumber, { color: theme.colors.text }]}>
              89%
            </Text>
            <Text style={[styles.statLabel, { color: theme.colors.textSecondary }]}>
              Sync Rate
            </Text>
          </View>
        </View>
      </Card>

      {/* Actions */}
      <Card style={styles.card}>
        <TouchableOpacity
          style={styles.actionItem}
          onPress={() => navigation.navigate('Settings')}
        >
          <View style={styles.actionLeft}>
            <Ionicons name="settings-outline" size={24} color={theme.colors.textSecondary} />
            <Text style={[styles.actionText, { color: theme.colors.text }]}>
              App Settings
            </Text>
          </View>
          <Ionicons name="chevron-forward" size={24} color={theme.colors.textSecondary} />
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.actionItem}
          onPress={() => navigation.navigate('Diagnostics')}
        >
          <View style={styles.actionLeft}>
            <Ionicons name="medkit-outline" size={24} color={theme.colors.textSecondary} />
            <Text style={[styles.actionText, { color: theme.colors.text }]}>
              Diagnostics
            </Text>
          </View>
          <Ionicons name="chevron-forward" size={24} color={theme.colors.textSecondary} />
        </TouchableOpacity>
      </Card>

      {/* Logout Button */}
      <Button
        title={isLoggingOut ? 'Logging out...' : 'Logout'}
        onPress={handleLogout}
        variant="danger"
        size="large"
        loading={isLoggingOut}
        style={styles.logoutButton}
      />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    alignItems: 'center',
    paddingTop: 20,
    paddingBottom: 16,
  },
  avatarContainer: {
    position: 'relative',
    marginBottom: 12,
  },
  avatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
    borderWidth: 3,
    borderColor: '#fff',
  },
  avatarLoading: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarPlaceholder: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: {
    fontSize: 40,
    fontWeight: '600',
  },
  avatarBadge: {
    position: 'absolute',
    bottom: 0,
    right: 0,
    width: 32,
    height: 32,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  userName: {
    fontSize: 24,
    fontWeight: '700',
  },
  userEmail: {
    fontSize: 16,
    marginTop: 4,
  },
  card: {
    marginHorizontal: 16,
    marginBottom: 16,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: '600',
  },
  infoSection: {
    gap: 16,
  },
  infoRow: {
    marginBottom: 12,
  },
  infoLabel: {
    fontSize: 14,
    marginBottom: 4,
  },
  infoValue: {
    fontSize: 16,
    fontWeight: '500',
  },
  inputContainer: {
    marginBottom: 0,
  },
  input: {
    marginTop: 4,
  },
  saveButton: {
    marginTop: 8,
  },
  statsGrid: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginTop: 12,
  },
  statItem: {
    alignItems: 'center',
  },
  statNumber: {
    fontSize: 28,
    fontWeight: '700',
  },
  statLabel: {
    fontSize: 14,
    marginTop: 4,
  },
  actionItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
  },
  actionLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  actionText: {
    fontSize: 16,
  },
  logoutButton: {
    marginHorizontal: 16,
    marginBottom: 32,
  },
});
```

---

## Phase 3.4: Real-time Subscriptions

### The Concept: Live Updates

Real-time subscriptions are like a live news feed for your data. Instead of polling the server for changes, the server pushes updates to your app as they happen. This is crucial for collaborative features and immediate notifications.

### The Implementation: Realtime Setup

```typescript
// src/hooks/useRealtime.ts
import { useEffect, useState } from 'react';
import { supabase } from '@api/supabase';
import { useAuth } from './useAuth';

/**
 * Real-time Subscription Hook
 * 
 * Subscribes to real-time changes for a given table.
 * Updates the component when data changes.
 * 
 * Example:
 * const { data, loading, error } = useRealtime('collections', { form_id: '123' });
 */
export const useRealtime = <T extends { id: string }>(
  table: string,
  filter?: Record<string, any>
) => {
  const [data, setData] = useState<T[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const { user } = useAuth();

  useEffect(() => {
    if (!user) {
      setLoading(false);
      return;
    }

    let isMounted = true;

    const fetchInitialData = async () => {
      try {
        let query = supabase.from(table).select('*');
        
        // Apply filters
        if (filter) {
          Object.entries(filter).forEach(([key, value]) => {
            query = query.eq(key, value);
          });
        }
        
        // Apply RLS - only get user's data
        query = query.eq('user_id', user.id);
        
        const { data: initialData, error: fetchError } = await query;
        
        if (fetchError) throw fetchError;
        if (isMounted) {
          setData(initialData || []);
          setLoading(false);
        }
      } catch (err) {
        if (isMounted) {
          setError(err as Error);
          setLoading(false);
        }
      }
    };

    fetchInitialData();

    // Set up real-time subscription
    const subscription = supabase
      .channel(`${table}-changes`)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: table,
          filter: filter 
            ? Object.entries(filter)
                .map(([key, value]) => `${key}=eq.${value}`)
                .join('&')
            : undefined,
        },
        async (payload) => {
          // Handle different events
          switch (payload.eventType) {
            case 'INSERT':
              setData(prev => [...prev, payload.new as T]);
              break;
            case 'UPDATE':
              setData(prev =>
                prev.map(item =>
                  item.id === payload.new.id ? payload.new as T : item
                )
              );
              break;
            case 'DELETE':
              setData(prev => prev.filter(item => item.id !== payload.old.id));
              break;
          }
        }
      )
      .subscribe((status) => {
        console.log(`Realtime subscription status for ${table}:`, status);
      });

    // Cleanup subscription on unmount
    return () => {
      isMounted = false;
      subscription.unsubscribe();
    };
  }, [table, user?.id, JSON.stringify(filter)]);

  return { data, loading, error };
};
```

---

## Phase 3.5: Testing the Authentication Flow

### The Concept: Verification

Now we need to test that everything works together. We'll verify:
1. User registration works
2. Email/password login works
3. Social login works (if configured)
4. Password reset works
5. Profile updates work
6. Session persistence works

### The Implementation: Manual Test Cases

```typescript
// __tests__/integration/auth.test.tsx
import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import LoginScreen from '@screens/auth/LoginScreen';
import { useAuth } from '@hooks/useAuth';
import { useNavigation } from '@react-navigation/native';

// Mock the auth hook
jest.mock('@hooks/useAuth');
jest.mock('@react-navigation/native');

describe('Authentication Flow', () => {
  const mockLogin = jest.fn();
  const mockNavigate = jest.fn();

  beforeEach(() => {
    (useAuth as jest.Mock).mockReturnValue({
      login: mockLogin,
      isLoading: false,
      error: null,
    });
    (useNavigation as jest.Mock).mockReturnValue({
      navigate: mockNavigate,
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  test('should render login screen correctly', () => {
    const { getByText, getByPlaceholderText } = render(<LoginScreen />);
    
    expect(getByText('Welcome Back')).toBeTruthy();
    expect(getByPlaceholderText('you@example.com')).toBeTruthy();
    expect(getByPlaceholderText('Enter your password')).toBeTruthy();
    expect(getByText('Sign In')).toBeTruthy();
  });

  test('should handle email input correctly', () => {
    const { getByPlaceholderText } = render(<LoginScreen />);
    const input = getByPlaceholderText('you@example.com');
    
    fireEvent.changeText(input, 'test@example.com');
    expect(input.props.value).toBe('test@example.com');
  });

  test('should validate email format', async () => {
    const { getByPlaceholderText, getByText, getByTestId } = render(<LoginScreen />);
    const emailInput = getByPlaceholderText('you@example.com');
    const loginButton = getByText('Sign In');
    
    fireEvent.changeText(emailInput, 'invalid-email');
    fireEvent.press(loginButton);
    
    await waitFor(() => {
      expect(getByTestId('email-error')).toBeTruthy();
    });
  });

  test('should call login with correct credentials', async () => {
    const { getByPlaceholderText, getByText } = render(<LoginScreen />);
    const emailInput = getByPlaceholderText('you@example.com');
    const passwordInput = getByPlaceholderText('Enter your password');
    const loginButton = getByText('Sign In');
    
    fireEvent.changeText(emailInput, 'test@example.com');
    fireEvent.changeText(passwordInput, 'password123');
    fireEvent.press(loginButton);
    
    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith('test@example.com', 'password123');
    });
  });
});
```

### Manual Test Steps

**Step 1: Test Registration**
```bash
# Start the app
$ npx expo start --clear

# On the emulator/simulator:
1. Navigate to the Register screen
2. Fill in the form with valid data
3. Submit the form
4. ✅ Verify you're logged in automatically
5. ✅ Check Supabase: new user exists in auth.users and profiles
```

**Step 2: Test Login**
```bash
# Log out (if logged in)
1. Go to Profile → Logout

# Log in:
1. Navigate to Login screen
2. Enter valid credentials
3. Submit the form
4. ✅ Verify you're redirected to the main app
5. ✅ Check auth store: user data is stored
6. ✅ Check session persists after app restart
```

**Step 3: Test Password Reset**
```bash
1. Go to Login screen
2. Click "Forgot Password"
3. Enter your email
4. ✅ Check email for reset link
5. Click the link in email
6. Reset password
7. ✅ Login with new password works
```

**Step 4: Test Profile Updates**
```bash
1. Go to Profile screen
2. Click "Edit"
3. Change full name
4. Save changes
5. ✅ Verify name updates immediately
6. Upload avatar photo
7. ✅ Verify avatar updates
```

---

## Phase 3.6: Security Enhancements

### The Concept: Defense in Depth

Security isn't just about authentication—it's about protecting data at every layer. We'll implement several security measures:

1. **Row Level Security (RLS):** Users can only see their own data
2. **Encrypted Storage:** Sensitive data is encrypted at rest
3. **Secure Headers:** Proper HTTP security headers
4. **Rate Limiting:** Prevent brute force attacks
5. **Input Validation:** Validate all user input

### The Implementation: Security Configuration

```typescript
// src/utils/security.ts
import * as Crypto from 'expo-crypto';
import * as SecureStore from 'expo-secure-store';
import { Alert, Platform } from 'react-native';
import DeviceInfo from 'react-native-device-info';
import { CONFIG } from '@constants/config';

/**
 * Security Utilities
 * 
 * Provides security-related functions for the application.
 */

/**
 * Generate a secure random string
 */
export const generateSecureId = (length: number = 32): string => {
  const bytes = Crypto.getRandomBytes(length);
  return bytes.toString('base64').substring(0, length);
};

/**
 * Hash a string using SHA-256
 */
export const hashString = async (input: string): Promise<string> => {
  const digest = await Crypto.digestStringAsync(
    Crypto.CryptoDigestAlgorithm.SHA256,
    input
  );
  return digest;
};

/**
 * Store sensitive data securely
 */
export const secureStore = {
  set: async (key: string, value: string): Promise<void> => {
    await SecureStore.setItemAsync(key, value);
  },
  get: async (key: string): Promise<string | null> => {
    return await SecureStore.getItemAsync(key);
  },
  delete: async (key: string): Promise<void> => {
    await SecureStore.deleteItemAsync(key);
  },
};

/**
 * Device fingerprinting for security
 */
export const getDeviceFingerprint = async (): Promise<string> => {
  const components = [
    await DeviceInfo.getDeviceId(),
    await DeviceInfo.getModel(),
    Platform.OS,
    await DeviceInfo.getSystemVersion(),
  ];
  
  return components.join('-');
};

/**
 * Rate limiter for API calls
 */
class RateLimiter {
  private requests: Map<string, number[]> = new Map();
  private readonly maxRequests: number;
  private readonly timeWindow: number;

  constructor(maxRequests: number = 100, timeWindow: number = 60000) {
    this.maxRequests = maxRequests;
    this.timeWindow = timeWindow;
  }

  canMakeRequest(key: string): boolean {
    const now = Date.now();
    const timestamps = this.requests.get(key) || [];
    const recentRequests = timestamps.filter(time => now - time < this.timeWindow);
    
    if (recentRequests.length >= this.maxRequests) {
      return false;
    }
    
    recentRequests.push(now);
    this.requests.set(key, recentRequests);
    return true;
  }

  reset(key: string): void {
    this.requests.delete(key);
  }
}

export const apiRateLimiter = new RateLimiter(100, 60000);
export const authRateLimiter = new RateLimiter(5, 300000); // 5 attempts per 5 minutes

/**
 * Validate input against common injection attacks
 */
export const sanitizeInput = (input: string): string => {
  // Remove script tags
  let sanitized = input.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
  // Remove on* event handlers
  sanitized = sanitized.replace(/ on\w+="[^"]*"/gi, '');
  // Remove javascript: protocol
  sanitized = sanitized.replace(/javascript:/gi, '');
  return sanitized.trim();
};

/**
 * Check if the app is running on a jailbroken/rooted device
 */
export const isDeviceCompromised = async (): Promise<boolean> => {
  try {
    const isRooted = await DeviceInfo.isRooted();
    const isEmulator = await DeviceInfo.isEmulator();
    
    // In production, you'd check for more indicators:
    // - Debug mode
    // - Suspicious apps
    // - Hooked frameworks
    
    return isRooted || isEmulator;
  } catch {
    // If we can't determine, assume not compromised
    return false;
  }
};

/**
 * Show security alert if device is compromised
 */
export const checkDeviceSecurity = async (): Promise<void> => {
  const isCompromised = await isDeviceCompromised();
  
  if (isCompromised && CONFIG.isProduction) {
    Alert.alert(
      'Security Warning',
      'Your device appears to be compromised. For your security, some features may be limited.',
      [{ text: 'OK' }]
    );
  }
};
```

---

## Phase 3.7: Final Integration Test

### The Concept: End-to-End Verification

Now we'll test the entire authentication flow end-to-end, verifying that all components work together correctly.

### The Implementation: Integration Test Script

```typescript
// __tests__/e2e/auth.e2e.ts
import { describe, it, beforeAll, expect } from '@jest/globals';
import { supabase } from '@api/supabase';
import { authService } from '@api/services/authService';

describe('Authentication E2E Flow', () => {
  const testUser = {
    email: `test-${Date.now()}@example.com`,
    password: 'TestPassword123!',
    fullName: 'Test User',
  };

  beforeAll(async () => {
    // Clean up any existing test users
    await supabase.auth.signOut();
  });

  it('should register a new user', async () => {
    const result = await authService.register(testUser);
    
    expect(result.user).toBeDefined();
    expect(result.user.email).toBe(testUser.email);
    expect(result.user.fullName).toBe(testUser.fullName);
    expect(result.session).toBeDefined();
  });

  it('should login with credentials', async () => {
    // Logout first
    await supabase.auth.signOut();
    
    const result = await authService.login({
      email: testUser.email,
      password: testUser.password,
    });
    
    expect(result.user).toBeDefined();
    expect(result.user.email).toBe(testUser.email);
    expect(result.session).toBeDefined();
  });

  it('should fetch user profile', async () => {
    const session = await authService.getSession();
    expect(session).toBeDefined();
    expect(session?.user).toBeDefined();
  });

  it('should update user profile', async () => {
    const session = await authService.getSession();
    const userId = session?.user?.id;
    
    if (!userId) {
      throw new Error('No user session');
    }
    
    const updatedUser = await authService.updateProfile(userId, {
      fullName: 'Updated Name',
    });
    
    expect(updatedUser.fullName).toBe('Updated Name');
  });

  it('should logout successfully', async () => {
    await authService.logout();
    const session = await authService.getSession();
    expect(session).toBeNull();
  });
});
```

### The Verification

```bash
# Run the integration tests
$ npm test -- --testPathPattern=auth

# Run the E2E tests (if configured)
$ npm run test:e2e

# Manual verification steps:
1. ✅ Create new account - works
2. ✅ Login with account - works
3. ✅ Logout and login again - session persists
4. ✅ Update profile - works
5. ✅ Upload avatar - works
6. ✅ Reset password - works
7. ✅ Social login (if configured) - works
8. ✅ RLS policies - users can only see their own data
```

---

## Part 3 Summary

### ✅ Completed

1. **Supabase Backend Setup**
   - Database tables with proper relationships
   - Row Level Security policies
   - Triggers for automatic profile creation
   - Indexes for performance

2. **Authentication Flow**
   - Email/Password registration and login
   - Social login (Google, Apple)
   - Password reset flow
   - Secure session management

3. **User Profile Management**
   - Profile viewing and editing
   - Avatar upload to Supabase Storage
   - Statistics display

4. **Real-time Subscriptions**
   - Live data updates
   - Efficient subscription management
   - Cleanup on unmount

5. **Security Enhancements**
   - Rate limiting
   - Input sanitization
   - Device fingerprinting
   - Compromised device detection

6. **Testing**
   - Integration tests
   - Manual test cases
   - End-to-end verification

### Key Concepts Learned

- **Backend-as-a-Service:** Supabase provides a complete backend solution
- **Row Level Security:** Database-level access control
- **OAuth Flow:** Social login implementation
- **Session Management:** Token handling and persistence
- **Real-time Updates:** WebSocket subscriptions
- **Security Best Practices:** Defense in depth

### What's Coming in Part 4

In **Part 4: Data Management & Offline Sync**, you'll:
- Set up WatermelonDB for local data persistence
- Implement offline-first architecture
- Build the sync engine
- Handle conflict resolution
- Create the form builder and entry system
- Implement offline queue management
- Build comprehensive caching strategies

---

## Quick Reference: Authentication Commands

```bash
# Supabase CLI (if installed)
$ supabase start                     # Start local development
$ supabase db diff                   # Generate schema diff
$ supabase db push                   # Push schema changes

# Testing
$ npm test                           # Run unit tests
$ npm test -- --watch                # Watch mode
$ npm run test:e2e                   # Run E2E tests

# Environment
$ echo $SUPABASE_URL                 # Check Supabase URL
$ echo $SUPABASE_ANON_KEY            # Check anon key

# Database
$ npx supabase sql "SELECT * FROM profiles"  # Query database
```

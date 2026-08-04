# Part 6 — Production Patterns

## Section 25: Forms

Forms are the backbone of user interaction in most applications. From simple login forms to complex multi‑step wizards with validation, draft saving, and undo/redo, managing form state effectively is crucial. In this section, you'll learn how to build robust form management systems using Zustand.

---

## The Target: Production-Ready Form Management

By the end of this section, you'll be able to:
- Build multi‑step forms with state persistence
- Implement real‑time validation with error messages
- Save and restore form drafts (auto‑save)
- Add undo/redo functionality for form fields
- Handle complex nested form data
- Integrate with React Hook Form or build custom form state

---

## The Concept: Form as a State Machine

Think of form management like a **wizard's spellbook**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    FORM STATE MACHINE                          │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Multi‑Step Form                                        │  │
│  │  Step 1: Personal Info → Step 2: Address → Step 3: Review│  │
│  │  • Current step index                                    │  │
│  │  • Data per step                                         │  │
│  │  • Validation per step                                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Draft Management                                       │  │
│  │  • Auto‑save to localStorage                            │  │
│  │  • Restore on page reload                               │  │
│  │  • Expiry handling                                      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Undo/Redo                                              │  │
│  │  • History of changes                                    │  │
│  │  • Revert to previous state                             │  │
│  │  • Keyboard shortcuts (Ctrl+Z, Ctrl+Y)                  │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Implementation: Form Store

### Step 1: Define Types

```typescript
// src/types/form.types.ts
export interface FieldError {
  field: string;
  message: string;
  type?: 'error' | 'warning' | 'info';
}

export interface FormStep {
  id: string;
  title: string;
  fields: string[]; // Field names belonging to this step
  validate?: (data: any) => FieldError[];
}

export interface FormHistory {
  past: any[];
  present: any;
  future: any[];
}

export interface FormState<T = any> {
  // Form data
  data: T;
  
  // Step management
  currentStep: number;
  steps: FormStep[];
  
  // Validation
  errors: FieldError[];
  touched: Record<string, boolean>;
  isValidating: boolean;
  isValid: boolean;
  
  // Draft
  draftId: string | null;
  draftSavedAt: Date | null;
  isDraftSaving: boolean;
  
  // History (undo/redo)
  history: FormHistory;
  maxHistory: number;
  
  // Submission
  isSubmitting: boolean;
  submitError: string | null;
  submitSuccess: boolean;
  submittedAt: Date | null;
}
```

### Step 2: Create the Form Store

```typescript
// src/store/formStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import { FormState, FormStep, FieldError, FormHistory } from '../types/form.types';

// Type-safe form store factory
export function createFormStore<T extends Record<string, any>>(
  initialData: T,
  steps: FormStep[],
  validateField?: (field: keyof T, value: any, data: T) => string | null,
  validateStep?: (stepIndex: number, data: T) => FieldError[],
  validateAll?: (data: T) => FieldError[],
  options: {
    maxHistory?: number;
    draftKey?: string;
    autoSaveInterval?: number;
  } = {}
) {
  const { maxHistory = 50, draftKey = 'form-draft', autoSaveInterval = 30000 } = options;

  type StoreState = FormState<T>;

  return create<StoreState>()(
    persist(
      immer((set, get) => ({
        // Data
        data: initialData,
        
        // Step management
        currentStep: 0,
        steps,
        
        // Validation
        errors: [],
        touched: {},
        isValidating: false,
        isValid: false,
        
        // Draft
        draftId: null,
        draftSavedAt: null,
        isDraftSaving: false,
        
        // History
        history: { past: [], present: initialData, future: [] },
        maxHistory,
        
        // Submission
        isSubmitting: false,
        submitError: null,
        submitSuccess: false,
        submittedAt: null,

        // --- Field Updates ---
        setField: (field: keyof T, value: any) => {
          set((state) => {
            // Update data
            (state.data as any)[field] = value;
            
            // Mark as touched
            state.touched[field as string] = true;
            
            // Push to history for undo/redo
            state.history.past.push(state.history.present);
            if (state.history.past.length > state.maxHistory) {
              state.history.past.shift();
            }
            state.history.present = { ...state.data };
            state.history.future = [];
            
            // Validate field
            if (validateField) {
              const error = validateField(field, value, state.data);
              state.errors = state.errors.filter(e => e.field !== field);
              if (error) {
                state.errors.push({ field: field as string, message: error });
              }
            }
            
            // Update overall validity
            state.isValid = get().validateForm();
          });
        },

        setFields: (fields: Partial<T>) => {
          set((state) => {
            // Update multiple fields
            for (const [key, value] of Object.entries(fields)) {
              (state.data as any)[key] = value;
              state.touched[key] = true;
            }
            
            // Push to history
            state.history.past.push(state.history.present);
            if (state.history.past.length > state.maxHistory) {
              state.history.past.shift();
            }
            state.history.present = { ...state.data };
            state.history.future = [];
            
            // Re-validate all touched fields
            if (validateField) {
              for (const key of Object.keys(fields)) {
                const error = validateField(key as keyof T, (state.data as any)[key], state.data);
                state.errors = state.errors.filter(e => e.field !== key);
                if (error) {
                  state.errors.push({ field: key, message: error });
                }
              }
            }
            
            state.isValid = get().validateForm();
          });
        },

        // --- Step Navigation ---
        goToStep: (stepIndex: number) => {
          const state = get();
          if (stepIndex < 0 || stepIndex >= state.steps.length) return;
          
          // Validate current step before leaving
          if (state.currentStep < stepIndex) {
            // Going forward - validate current step
            const errors = get().validateCurrentStep();
            if (errors.length > 0) {
              set({ errors });
              return;
            }
          }
          
          set({ currentStep: stepIndex });
        },

        nextStep: () => {
          const state = get();
          const errors = get().validateCurrentStep();
          if (errors.length > 0) {
            set({ errors });
            return;
          }
          
          if (state.currentStep < state.steps.length - 1) {
            set({ currentStep: state.currentStep + 1 });
          }
        },

        prevStep: () => {
          const state = get();
          if (state.currentStep > 0) {
            set({ currentStep: state.currentStep - 1 });
          }
        },

        // --- Validation ---
        validateField: (field: keyof T) => {
          const state = get();
          if (!validateField) return null;
          return validateField(field, state.data[field], state.data);
        },

        validateCurrentStep: () => {
          const state = get();
          if (validateStep) {
            return validateStep(state.currentStep, state.data);
          }
          
          // Fallback: validate all fields in current step
          const step = state.steps[state.currentStep];
          if (!step || !validateField) return [];
          
          const errors: FieldError[] = [];
          for (const field of step.fields) {
            const error = validateField(field as keyof T, state.data[field], state.data);
            if (error) {
              errors.push({ field, message: error });
            }
          }
          return errors;
        },

        validateForm: () => {
          if (validateAll) {
            const errors = validateAll(get().data);
            set({ errors, isValid: errors.length === 0 });
            return errors.length === 0;
          }
          
          // Fallback: validate all fields
          if (!validateField) {
            set({ isValid: true });
            return true;
          }
          
          const state = get();
          const errors: FieldError[] = [];
          for (const key of Object.keys(state.data)) {
            const error = validateField(key as keyof T, state.data[key], state.data);
            if (error) {
              errors.push({ field: key, message: error });
            }
          }
          set({ errors, isValid: errors.length === 0 });
          return errors.length === 0;
        },

        validateAllFields: () => {
          const state = get();
          if (!validateAll) {
            // Use field validation
            const errors: FieldError[] = [];
            if (validateField) {
              for (const key of Object.keys(state.data)) {
                const error = validateField(key as keyof T, state.data[key], state.data);
                if (error) {
                  errors.push({ field: key, message: error });
                }
              }
            }
            set({ errors, isValid: errors.length === 0 });
            return errors;
          }
          
          const errors = validateAll(state.data);
          set({ errors, isValid: errors.length === 0 });
          return errors;
        },

        clearErrors: () => {
          set({ errors: [] });
        },

        clearFieldError: (field: string) => {
          set((state) => ({
            errors: state.errors.filter(e => e.field !== field),
          }));
        },

        // --- Undo/Redo ---
        undo: () => {
          set((state) => {
            if (state.history.past.length === 0) return;
            
            const previous = state.history.past.pop()!;
            state.history.future.push(state.history.present);
            state.history.present = previous;
            state.data = { ...previous };
          });
        },

        redo: () => {
          set((state) => {
            if (state.history.future.length === 0) return;
            
            const next = state.history.future.pop()!;
            state.history.past.push(state.history.present);
            state.history.present = next;
            state.data = { ...next };
          });
        },

        canUndo: () => {
          return get().history.past.length > 0;
        },

        canRedo: () => {
          return get().history.future.length > 0;
        },

        clearHistory: () => {
          set((state) => ({
            history: { past: [], present: state.data, future: [] },
          }));
        },

        // --- Draft Management ---
        saveDraft: async () => {
          const state = get();
          set({ isDraftSaving: true });
          
          try {
            // In production, this would save to localStorage or server
            const draftData = {
              data: state.data,
              currentStep: state.currentStep,
              timestamp: Date.now(),
            };
            localStorage.setItem(draftKey, JSON.stringify(draftData));
            
            set({
              draftId: `draft-${Date.now()}`,
              draftSavedAt: new Date(),
              isDraftSaving: false,
            });
          } catch (error) {
            set({
              isDraftSaving: false,
              submitError: error instanceof Error ? error.message : 'Failed to save draft',
            });
          }
        },

        loadDraft: () => {
          try {
            const saved = localStorage.getItem(draftKey);
            if (!saved) return false;
            
            const draftData = JSON.parse(saved);
            // Check expiry (e.g., 7 days)
            if (Date.now() - draftData.timestamp > 7 * 24 * 60 * 60 * 1000) {
              localStorage.removeItem(draftKey);
              return false;
            }
            
            set({
              data: draftData.data,
              currentStep: draftData.currentStep || 0,
              draftId: `draft-${draftData.timestamp}`,
              draftSavedAt: new Date(draftData.timestamp),
            });
            return true;
          } catch {
            return false;
          }
        },

        clearDraft: () => {
          localStorage.removeItem(draftKey);
          set({ draftId: null, draftSavedAt: null });
        },

        // --- Form Submission ---
        submitForm: async (submitFn: (data: T) => Promise<any>) => {
          const state = get();
          
          // Validate all fields before submission
          const errors = state.validateAllFields();
          if (errors.length > 0) {
            set({ submitError: 'Please fix all errors before submitting' });
            return;
          }
          
          set({ isSubmitting: true, submitError: null, submitSuccess: false });
          
          try {
            await submitFn(state.data);
            set({
              isSubmitting: false,
              submitSuccess: true,
              submittedAt: new Date(),
            });
            // Clear draft on successful submission
            get().clearDraft();
            // Clear history
            get().clearHistory();
          } catch (error) {
            set({
              isSubmitting: false,
              submitError: error instanceof Error ? error.message : 'Submission failed',
            });
          }
        },

        // --- Reset ---
        resetForm: () => {
          set({
            data: { ...initialData },
            currentStep: 0,
            errors: [],
            touched: {},
            isValidating: false,
            isValid: false,
            isSubmitting: false,
            submitError: null,
            submitSuccess: false,
            submittedAt: null,
            history: { past: [], present: initialData, future: [] },
          });
        },

        resetToStep: (stepIndex: number) => {
          set({ currentStep: stepIndex });
        },

        // --- Touch Management ---
        touchField: (field: string) => {
          set((state) => {
            state.touched[field] = true;
          });
        },

        touchAll: () => {
          const state = get();
          const touched: Record<string, boolean> = {};
          for (const key of Object.keys(state.data)) {
            touched[key] = true;
          }
          set({ touched });
        },

        // --- Utility ---
        getFieldError: (field: string) => {
          return get().errors.find(e => e.field === field);
        },

        isFieldTouched: (field: string) => {
          return !!get().touched[field];
        },

        isFieldValid: (field: string) => {
          return !get().errors.some(e => e.field === field);
        },

        getStepData: (stepIndex: number) => {
          const state = get();
          const step = state.steps[stepIndex];
          if (!step) return null;
          
          const data: any = {};
          for (const field of step.fields) {
            data[field] = state.data[field];
          }
          return data;
        },
      })),
      {
        name: `${draftKey}-storage`,
        storage: createJSONStorage(() => localStorage),
        partialize: (state) => ({
          data: state.data,
          currentStep: state.currentStep,
          // Don't persist: errors, touched, history, submission state
        }),
      }
    )
  );
}
```

### Step 3: Example: User Registration Form

```typescript
// src/forms/registrationForm.ts
import { createFormStore } from '../store/formStore';
import { FormStep, FieldError } from '../types/form.types';

// Define form data type
interface RegistrationData {
  email: string;
  password: string;
  confirmPassword: string;
  firstName: string;
  lastName: string;
  company: string;
  phone: string;
  acceptedTerms: boolean;
  newsletter: boolean;
}

// Initial data
const initialData: RegistrationData = {
  email: '',
  password: '',
  confirmPassword: '',
  firstName: '',
  lastName: '',
  company: '',
  phone: '',
  acceptedTerms: false,
  newsletter: false,
};

// Define steps
const steps: FormStep[] = [
  {
    id: 'account',
    title: 'Account Information',
    fields: ['email', 'password', 'confirmPassword'],
  },
  {
    id: 'profile',
    title: 'Personal Information',
    fields: ['firstName', 'lastName', 'company', 'phone'],
  },
  {
    id: 'preferences',
    title: 'Preferences',
    fields: ['acceptedTerms', 'newsletter'],
  },
];

// Validation functions
function validateEmail(email: string): string | null {
  if (!email) return 'Email is required';
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return 'Invalid email format';
  return null;
}

function validatePassword(password: string): string | null {
  if (!password) return 'Password is required';
  if (password.length < 8) return 'Password must be at least 8 characters';
  if (!/[A-Z]/.test(password)) return 'Password must contain at least one uppercase letter';
  if (!/[a-z]/.test(password)) return 'Password must contain at least one lowercase letter';
  if (!/[0-9]/.test(password)) return 'Password must contain at least one number';
  return null;
}

function validateField(field: keyof RegistrationData, value: any, data: RegistrationData): string | null {
  switch (field) {
    case 'email':
      return validateEmail(value);
    case 'password':
      return validatePassword(value);
    case 'confirmPassword':
      if (value !== data.password) return 'Passwords do not match';
      return null;
    case 'firstName':
      if (!value) return 'First name is required';
      return null;
    case 'lastName':
      if (!value) return 'Last name is required';
      return null;
    case 'acceptedTerms':
      if (!value) return 'You must accept the terms and conditions';
      return null;
    default:
      return null;
  }
}

function validateStep(stepIndex: number, data: RegistrationData): FieldError[] {
  const step = steps[stepIndex];
  const errors: FieldError[] = [];
  
  for (const field of step.fields) {
    const error = validateField(field as keyof RegistrationData, data[field], data);
    if (error) {
      errors.push({ field, message: error });
    }
  }
  
  return errors;
}

function validateAll(data: RegistrationData): FieldError[] {
  const errors: FieldError[] = [];
  for (const field of Object.keys(data) as (keyof RegistrationData)[]) {
    const error = validateField(field, data[field], data);
    if (error) {
      errors.push({ field: field as string, message: error });
    }
  }
  return errors;
}

// Create the form store
export const useRegistrationForm = createFormStore<RegistrationData>(
  initialData,
  steps,
  validateField,
  validateStep,
  validateAll,
  {
    maxHistory: 30,
    draftKey: 'registration-draft',
    autoSaveInterval: 15000,
  }
);
```

### Step 4: React Form Component

```tsx
// src/components/RegistrationForm.tsx
'use client';

import React, { useEffect, useState } from 'react';
import { useRegistrationForm } from '../forms/registrationForm';
import { FieldError } from '../types/form.types';

// Field component with validation
function FormField({
  label,
  name,
  type = 'text',
  value,
  onChange,
  onBlur,
  error,
  touched,
  required = false,
  ...props
}: {
  label: string;
  name: string;
  type?: string;
  value: any;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  onBlur: (e: React.FocusEvent<HTMLInputElement>) => void;
  error?: FieldError;
  touched?: boolean;
  required?: boolean;
  [key: string]: any;
}) {
  const showError = touched && error;

  return (
    <div className="mb-4">
      <label className="block text-sm font-medium text-gray-700 mb-1">
        {label} {required && <span className="text-red-500">*</span>}
      </label>
      <input
        type={type}
        name={name}
        value={value || ''}
        onChange={onChange}
        onBlur={onBlur}
        className={`w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 ${
          showError ? 'border-red-500' : 'border-gray-300'
        }`}
        {...props}
      />
      {showError && (
        <p className="mt-1 text-sm text-red-600">{error.message}</p>
      )}
    </div>
  );
}

export function RegistrationForm() {
  const {
    data,
    currentStep,
    steps,
    errors,
    touched,
    isValid,
    isSubmitting,
    submitError,
    submitSuccess,
    submittedAt,
    canUndo,
    canRedo,
    setField,
    touchField,
    nextStep,
    prevStep,
    goToStep,
    undo,
    redo,
    saveDraft,
    loadDraft,
    clearDraft,
    submitForm,
    resetForm,
    clearErrors,
    validateAllFields,
  } = useRegistrationForm();

  const [draftLoaded, setDraftLoaded] = useState(false);

  // Load draft on mount
  useEffect(() => {
    const hasDraft = loadDraft();
    setDraftLoaded(true);
    if (hasDraft) {
      console.log('Loaded draft');
    }
  }, []);

  // Auto-save draft
  useEffect(() => {
    if (draftLoaded) {
      const interval = setInterval(() => {
        saveDraft();
      }, 15000);
      return () => clearInterval(interval);
    }
  }, [draftLoaded, saveDraft]);

  // Handle field change
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type, checked } = e.target;
    const val = type === 'checkbox' ? checked : value;
    setField(name as keyof typeof data, val);
  };

  // Handle field blur (mark as touched)
  const handleBlur = (e: React.FocusEvent<HTMLInputElement>) => {
    touchField(e.target.name);
  };

  // Submit form
  const handleSubmit = async () => {
    // Validate all fields first
    validateAllFields();
    
    await submitForm(async (formData) => {
      // In production, send to API
      console.log('Submitting:', formData);
      await new Promise(resolve => setTimeout(resolve, 1500));
      return { success: true };
    });
  };

  const step = steps[currentStep];
  const isLastStep = currentStep === steps.length - 1;
  const isFirstStep = currentStep === 0;

  if (submitSuccess) {
    return (
      <div className="max-w-2xl mx-auto p-6 bg-white rounded-lg shadow">
        <div className="text-center py-8">
          <div className="text-6xl mb-4">🎉</div>
          <h2 className="text-2xl font-bold text-gray-900">Registration Successful!</h2>
          <p className="text-gray-600 mt-2">Thank you for registering.</p>
          <p className="text-sm text-gray-500 mt-4">
            Submitted at: {submittedAt?.toLocaleString()}
          </p>
          <button
            onClick={resetForm}
            className="mt-6 px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            Start Over
          </button>
        </div>
      </div>
    );
  }

  // Show step indicator
  const renderStepIndicator = () => {
    return (
      <div className="flex items-center justify-center mb-8">
        {steps.map((s, index) => (
          <React.Fragment key={s.id}>
            <button
              onClick={() => goToStep(index)}
              className={`w-10 h-10 rounded-full flex items-center justify-center text-sm font-medium ${
                index === currentStep
                  ? 'bg-blue-600 text-white'
                  : index < currentStep
                  ? 'bg-green-500 text-white'
                  : 'bg-gray-200 text-gray-600'
              }`}
            >
              {index + 1}
            </button>
            {index < steps.length - 1 && (
              <div
                className={`w-12 h-0.5 ${
                  index < currentStep ? 'bg-green-500' : 'bg-gray-300'
                }`}
              />
            )}
          </React.Fragment>
        ))}
      </div>
    );
  };

  return (
    <div className="max-w-2xl mx-auto p-6 bg-white rounded-lg shadow">
      <h2 className="text-2xl font-bold text-gray-900 mb-6">
        {step.title}
      </h2>

      {renderStepIndicator()}

      <div className="space-y-4">
        {/* Step fields */}
        {step.fields.map((fieldName) => {
          const fieldValue = data[fieldName as keyof typeof data];
          const error = errors.find(e => e.field === fieldName);
          const isTouched = touched[fieldName];

          let label = fieldName;
          let type = 'text';
          let required = false;

          // Customize field display
          switch (fieldName) {
            case 'email':
              label = 'Email Address';
              type = 'email';
              required = true;
              break;
            case 'password':
              label = 'Password';
              type = 'password';
              required = true;
              break;
            case 'confirmPassword':
              label = 'Confirm Password';
              type = 'password';
              required = true;
              break;
            case 'firstName':
              label = 'First Name';
              required = true;
              break;
            case 'lastName':
              label = 'Last Name';
              required = true;
              break;
            case 'company':
              label = 'Company';
              break;
            case 'phone':
              label = 'Phone Number';
              type = 'tel';
              break;
            case 'acceptedTerms':
              label = 'I accept the terms and conditions';
              type = 'checkbox';
              required = true;
              break;
            case 'newsletter':
              label = 'Subscribe to newsletter';
              type = 'checkbox';
              break;
          }

          if (type === 'checkbox') {
            return (
              <div key={fieldName} className="flex items-center gap-2 mb-4">
                <input
                  type="checkbox"
                  name={fieldName}
                  checked={fieldValue || false}
                  onChange={handleChange}
                  onBlur={handleBlur}
                  className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                />
                <label className="text-sm text-gray-700">
                  {label} {required && <span className="text-red-500">*</span>}
                </label>
                {error && isTouched && (
                  <p className="text-sm text-red-600">{error.message}</p>
                )}
              </div>
            );
          }

          return (
            <FormField
              key={fieldName}
              label={label}
              name={fieldName}
              type={type}
              value={fieldValue}
              onChange={handleChange}
              onBlur={handleBlur}
              error={error}
              touched={isTouched}
              required={required}
              autoComplete={fieldName}
            />
          );
        })}

        {/* Form errors */}
        {submitError && (
          <div className="p-3 bg-red-100 text-red-700 rounded">
            {submitError}
          </div>
        )}

        {/* Navigation buttons */}
        <div className="flex justify-between items-center pt-4 border-t">
          <div className="flex gap-2">
            <button
              type="button"
              onClick={undo}
              disabled={!canUndo()}
              className="px-4 py-2 border border-gray-300 rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              ↶ Undo
            </button>
            <button
              type="button"
              onClick={redo}
              disabled={!canRedo()}
              className="px-4 py-2 border border-gray-300 rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              ↷ Redo
            </button>
          </div>

          <div className="flex gap-2">
            <button
              type="button"
              onClick={saveDraft}
              className="px-4 py-2 border border-gray-300 rounded hover:bg-gray-100"
            >
              Save Draft
            </button>
            <button
              type="button"
              onClick={clearDraft}
              className="px-4 py-2 border border-red-300 text-red-600 rounded hover:bg-red-50"
            >
              Clear Draft
            </button>
          </div>
        </div>

        <div className="flex justify-between pt-4">
          <button
            type="button"
            onClick={prevStep}
            disabled={isFirstStep}
            className="px-6 py-2 border border-gray-300 rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Previous
          </button>

          <div className="flex gap-2">
            <button
              type="button"
              onClick={validateAllFields}
              className="px-6 py-2 border border-gray-300 rounded hover:bg-gray-100"
            >
              Validate
            </button>

            {isLastStep ? (
              <button
                type="button"
                onClick={handleSubmit}
                disabled={isSubmitting || !isValid}
                className="px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isSubmitting ? 'Submitting...' : 'Submit'}
              </button>
            ) : (
              <button
                type="button"
                onClick={nextStep}
                className="px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
              >
                Next
              </button>
            )}
          </div>
        </div>

        {/* Debug info (development only) */}
        {process.env.NODE_ENV === 'development' && (
          <details className="mt-6 p-4 bg-gray-100 rounded">
            <summary className="cursor-pointer font-mono text-sm">Debug Info</summary>
            <pre className="text-xs mt-2 overflow-auto max-h-60">
              {JSON.stringify(
                {
                  currentStep,
                  steps: steps.length,
                  touched,
                  errors,
                  isValid,
                  canUndo: canUndo(),
                  canRedo: canRedo(),
                  draftId: useRegistrationForm.getState().draftId,
                  historyPast: useRegistrationForm.getState().history.past.length,
                  data: data,
                },
                null,
                2
              )}
            </pre>
          </details>
        )}
      </div>
    </div>
  );
}
```

### Step 5: Multi-Step Form with Context

For complex forms, you can wrap the form in a context provider:

```tsx
// src/context/FormContext.tsx
'use client';

import React, { createContext, useContext, ReactNode } from 'react';
import { useRegistrationForm } from '../forms/registrationForm';
import { RegistrationData } from '../forms/registrationForm';

type FormContextType = ReturnType<typeof useRegistrationForm>;

const FormContext = createContext<FormContextType | null>(null);

export function FormProvider({ children }: { children: ReactNode }) {
  const form = useRegistrationForm();
  return <FormContext.Provider value={form}>{children}</FormContext.Provider>;
}

export function useForm() {
  const context = useContext(FormContext);
  if (!context) {
    throw new Error('useForm must be used within a FormProvider');
  }
  return context;
}
```

---

## The Verification: Testing Forms

### Step 1: Test Component

```tsx
// src/app/register/page.tsx
import { RegistrationForm } from '@/components/RegistrationForm';

export default function RegisterPage() {
  return (
    <div className="min-h-screen bg-gray-100 py-12">
      <RegistrationForm />
    </div>
  );
}
```

### Step 2: Manual Testing

1. **Field Updates**: Type in fields → state updates
2. **Validation**: Invalid values → error messages appear
3. **Step Navigation**: Next/Previous → steps change, data persists
4. **Undo/Redo**: Ctrl+Z/Ctrl+Y → changes revert/restore
5. **Draft Save**: Auto-save → reload page → data restored
6. **Submission**: Submit → success/error states

### Step 3: Keyboard Shortcuts

```tsx
// Add keyboard shortcuts for undo/redo
useEffect(() => {
  const handleKeyDown = (e: KeyboardEvent) => {
    if ((e.ctrlKey || e.metaKey) && e.key === 'z') {
      e.preventDefault();
      if (e.shiftKey) {
        form.redo();
      } else {
        form.undo();
      }
    }
  };
  window.addEventListener('keydown', handleKeyDown);
  return () => window.removeEventListener('keydown', handleKeyDown);
}, []);
```

---

## Deep Dive: Form Validation Patterns

### Schema Validation with Zod

```typescript
// src/forms/registrationSchema.ts
import { z } from 'zod';

const registrationSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Must contain uppercase letter')
    .regex(/[a-z]/, 'Must contain lowercase letter')
    .regex(/[0-9]/, 'Must contain a number'),
  confirmPassword: z.string(),
  firstName: z.string().min(1, 'First name is required'),
  lastName: z.string().min(1, 'Last name is required'),
  company: z.string().optional(),
  phone: z.string().optional(),
  acceptedTerms: z.boolean().refine(v => v === true, {
    message: 'You must accept the terms',
  }),
  newsletter: z.boolean().optional(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ['confirmPassword'],
});

// Use in validation
function validateAll(data: RegistrationData): FieldError[] {
  const result = registrationSchema.safeParse(data);
  if (result.success) return [];
  return result.error.errors.map(err => ({
    field: err.path.join('.'),
    message: err.message,
  }));
}
```

### Debounced Validation

```tsx
// Debounce field validation to avoid excessive re-renders
import { useDebounce } from '../hooks/useDebounce';

function DebouncedFormField({ ...props }) {
  const [value, setValue] = useState(props.value);
  const debouncedValue = useDebounce(value, 300);
  
  useEffect(() => {
    props.onChange(debouncedValue);
  }, [debouncedValue]);
  
  return <input {...props} value={value} onChange={(e) => setValue(e.target.value)} />;
}
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Not Saving Drafts on Page Unload

```typescript
// ❌ BAD: No draft save on unload
// User leaves page → data lost

// ✅ GOOD: Save before unload
useEffect(() => {
  const handleBeforeUnload = () => {
    saveDraft();
  };
  window.addEventListener('beforeunload', handleBeforeUnload);
  return () => window.removeEventListener('beforeunload', handleBeforeUnload);
}, []);
```

### Pitfall 2: Not Handling Async Validation

```typescript
// ❌ BAD: Synchronous validation only
const error = validateEmail(email);

// ✅ GOOD: Async validation with loading state
const [isValidating, setIsValidating] = useState(false);
const validateEmailAsync = async (email: string) => {
  setIsValidating(true);
  try {
    const result = await checkEmailExists(email);
    return result ? 'Email already taken' : null;
  } finally {
    setIsValidating(false);
  }
};
```

### Pitfall 3: Losing Form State on Navigation

```typescript
// ❌ BAD: No persistence
const form = useRegistrationForm(); // Resets on navigation

// ✅ GOOD: Use persist middleware (already in the store)
// The store persists data across page reloads
```

---

## Form Checklist

- [ ] Multi‑step navigation with validation per step
- [ ] Field‑level validation with real‑time feedback
- [ ] Form‑level validation on submission
- [ ] Draft saving (auto‑save and manual)
- [ ] Draft restoration on page load
- [ ] Undo/redo functionality
- [ ] Touch tracking (show errors only after blur)
- [ ] Submission states (loading, success, error)
- [ ] Reset functionality
- [ ] Keyboard shortcuts (undo/redo)
- [ ] Accessibility (labels, aria attributes, focus management)

---

## Key Takeaways

1. **Multi‑step forms** – Break complex forms into manageable steps
2. **Field‑level validation** – Validate each field independently
3. **Step validation** – Validate before allowing step transitions
4. **Draft saving** – Auto‑save prevents data loss
5. **Undo/Redo** – History management for user errors
6. **Touch tracking** – Show errors only after user interaction
7. **Persistence** – Use `persist` middleware for drafts
8. **Submission states** – Loading, success, and error handling
9. **Keyboard shortcuts** – Ctrl+Z/Ctrl+Y for undo/redo
10. **Testing** – Test validation, navigation, and submission flows

---

## What's Next

You've mastered forms with Zustand. Next, you'll learn how to build real‑time applications with WebSockets, notifications, and presence tracking.

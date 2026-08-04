# Appendix A: Complete Dependency List & Configuration Files

## A Comprehensive Reference for All Dependencies

This appendix serves as a complete reference for all the libraries, tools, and configuration files used throughout the NexusCollect application. Use this as a quick reference when setting up a new project or troubleshooting dependency issues.

---

## A.1 Core Dependencies

### Production Dependencies

```json
{
  "dependencies": {
    // Core Framework
    "expo": "~50.0.0",
    "expo-status-bar": "~1.11.0",
    "react": "18.2.0",
    "react-native": "0.73.0",
    "react-dom": "18.2.0",
    "react-native-web": "~0.19.6",

    // Navigation
    "@react-navigation/native": "^6.1.9",
    "@react-navigation/native-stack": "^6.9.17",
    "@react-navigation/bottom-tabs": "^6.5.11",
    "@react-navigation/drawer": "^6.6.6",
    "react-native-screens": "~3.29.0",
    "react-native-safe-area-context": "4.8.2",
    "react-native-gesture-handler": "~2.14.0",
    "react-native-reanimated": "~3.6.0",

    // State Management
    "zustand": "^4.5.0",
    "zustand-middleware": "^1.0.0",

    // Data Management
    "@nozbe/watermelondb": "^0.27.0",
    "@nozbe/with-observables": "^1.0.8",
    "expo-sqlite": "~11.0.0",
    "@react-native-async-storage/async-storage": "1.18.2",

    // API & Backend
    "@supabase/supabase-js": "^2.38.0",
    "@supabase/realtime-js": "^2.8.7",
    "axios": "^1.6.0",

    // UI Components & Icons
    "react-native-vector-icons": "^10.0.0",
    "@expo/vector-icons": "^13.0.0",
    "react-native-svg": "13.9.0",

    // Forms & Validation
    "react-hook-form": "^7.48.0",
    "zod": "^3.22.0",

    // Hardware Integration
    "expo-camera": "~13.4.0",
    "expo-image-picker": "~14.4.0",
    "expo-media-library": "~15.4.0",
    "expo-location": "~16.5.0",
    "expo-local-authentication": "~13.4.0",
    "expo-notifications": "~0.27.0",
    "expo-device": "~5.9.0",
    "react-native-device-info": "^10.12.0",

    // Security
    "expo-secure-store": "~12.3.0",
    "expo-crypto": "~12.8.0",

    // File System
    "expo-file-system": "~11.4.0",
    "react-native-fs": "^2.20.0",

    // Performance & Monitoring
    "sentry-expo": "~7.0.0",

    // Utilities
    "date-fns": "^2.30.0",
    "uuid": "^9.0.0",
    "lodash": "^4.17.21",
    "react-native-dotenv": "^3.4.9",
    "react-native-keychain": "^8.0.0",
    "expo-constants": "~15.4.0",
    "expo-updates": "~0.24.0",
    "expo-build-properties": "~0.10.0",

    // Storage & Caching
    "@tanstack/react-query": "^5.12.0",
    "react-native-mmkv": "^2.11.0"
  }
}
```

### Development Dependencies

```json
{
  "devDependencies": {
    // TypeScript
    "typescript": "^5.3.0",
    "@types/react": "~18.2.0",
    "@types/react-native": "^0.73.0",
    "@types/lodash": "^4.14.0",
    "@types/uuid": "^9.0.0",
    "@types/jest": "^29.5.0",

    // Testing
    "jest": "^29.7.0",
    "jest-expo": "~50.0.0",
    "@testing-library/react-native": "^12.4.0",
    "@testing-library/jest-native": "^5.4.0",
    "react-test-renderer": "18.2.0",
    "@testing-library/react-hooks": "^8.0.1",

    // E2E Testing
    "detox": "^20.0.0",
    "jest-jasmine2": "^29.7.0",

    // Code Quality
    "@typescript-eslint/eslint-plugin": "^6.13.0",
    "@typescript-eslint/parser": "^6.13.0",
    "eslint": "^8.54.0",
    "eslint-plugin-react": "^7.33.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-native": "^4.1.0",
    "prettier": "^3.1.0",

    // Git Hooks
    "husky": "^8.0.0",
    "lint-staged": "^15.1.0",

    // Build Tools
    "@expo/config-plugins": "~7.8.0",
    "@expo/metro-config": "~0.17.0",
    "react-native-svg-transformer": "^1.0.0",

    // TypeScript Paths
    "@types/node": "^20.9.0",
    "ts-node": "^10.9.0",
    "tsconfig-paths": "^4.2.0",

    // Coverage
    "@types/istanbul-lib-coverage": "^2.0.0",
    "codecov": "^3.8.0"
  }
}
```

---

## A.2 Complete Configuration Files

### A.2.1 TypeScript Configuration

```json
// tsconfig.json
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "esModuleInterop": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@screens/*": ["./src/screens/*"],
      "@utils/*": ["./src/utils/*"],
      "@types/*": ["./src/types/*"],
      "@hooks/*": ["./src/hooks/*"],
      "@store/*": ["./src/store/*"],
      "@api/*": ["./src/api/*"],
      "@themes/*": ["./src/themes/*"],
      "@database/*": ["./src/database/*"],
      "@services/*": ["./src/services/*"],
      "@constants/*": ["./src/constants/*"],
      "@navigation/*": ["./src/navigation/*"]
    },
    "target": "ES2020",
    "module": "ES2020",
    "lib": ["ES2020", "DOM"],
    "jsx": "react-native",
    "allowJs": true,
    "checkJs": false,
    "noEmit": true,
    "allowSyntheticDefaultImports": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "useDefineForClassFields": true
  },
  "include": [
    "**/*.ts",
    "**/*.tsx",
    "**/*.js",
    "**/*.jsx",
    ".expo/types/**/*.ts",
    "expo-env.d.ts"
  ],
  "exclude": [
    "node_modules",
    "**/__tests__/*",
    "**/*.test.ts",
    "**/*.test.tsx",
    "**/*.spec.ts",
    "**/*.spec.tsx",
    "e2e/**/*",
    "coverage/**/*"
  ]
}
```

### A.2.2 Babel Configuration

```javascript
// babel.config.js
module.exports = function(api) {
  api.cache(true);
  
  const presets = [
    'babel-preset-expo',
    '@babel/preset-typescript',
    '@babel/preset-react',
  ];
  
  const plugins = [
    // Environment variables
    [
      'module:react-native-dotenv',
      {
        envName: 'APP_ENV',
        moduleName: '@env',
        path: '.env',
        safe: false,
        allowUndefined: true,
        verbose: false,
      },
    ],
    // Path aliases
    [
      'module-resolver',
      {
        root: ['./src'],
        extensions: ['.ios.js', '.android.js', '.js', '.ts', '.tsx', '.json'],
        alias: {
          '@': './src',
          '@components': './src/components',
          '@screens': './src/screens',
          '@utils': './src/utils',
          '@types': './src/types',
          '@hooks': './src/hooks',
          '@store': './src/store',
          '@api': './src/api',
          '@themes': './src/themes',
          '@database': './src/database',
          '@services': './src/services',
          '@constants': './src/constants',
          '@navigation': './src/navigation',
        },
      },
    ],
    // Reanimated
    'react-native-reanimated/plugin',
    // Optional: Decorators for WatermelonDB
    ['@babel/plugin-proposal-decorators', { legacy: true }],
    ['@babel/plugin-proposal-class-properties', { loose: true }],
    // Transform for testing
    '@babel/plugin-transform-runtime',
  ];
  
  // Add testing specific plugins
  if (process.env.NODE_ENV === 'test') {
    plugins.push('@babel/plugin-transform-modules-commonjs');
  }
  
  return {
    presets,
    plugins,
    env: {
      production: {
        plugins: [
          'transform-remove-console',
          ['@babel/plugin-transform-react-inline-elements'],
        ],
      },
      development: {
        plugins: [
          '@babel/plugin-transform-react-jsx-source',
        ],
      },
    },
  };
};
```

### A.2.3 Metro Configuration

```javascript
// metro.config.js
const { getDefaultConfig } = require('@expo/metro-config');
const { createHash } = require('crypto');

const defaultConfig = getDefaultConfig(__dirname);

// Add SVG transformer
defaultConfig.transformer = {
  ...defaultConfig.transformer,
  babelTransformerPath: require.resolve('react-native-svg-transformer'),
};

// Configure for production optimizations
const isProduction = process.env.NODE_ENV === 'production';

module.exports = {
  ...defaultConfig,
  resolver: {
    ...defaultConfig.resolver,
    assetExts: defaultConfig.resolver.assetExts.filter(ext => ext !== 'svg'),
    sourceExts: [...defaultConfig.resolver.sourceExts, 'svg'],
  },
  transformer: {
    ...defaultConfig.transformer,
    minifierConfig: isProduction ? {
      compress: {
        drop_console: true,
        drop_debugger: true,
        pure_funcs: ['console.log', 'console.debug', 'console.info'],
        passes: 2,
      },
      mangle: {
        reserved: ['require', 'exports', 'module'],
        properties: {
          regex: /^_/,
        },
      },
      output: {
        comments: false,
        beautify: false,
      },
    } : undefined,
  },
  serializer: {
    ...defaultConfig.serializer,
    createModuleIdFactory: isProduction ? () => {
      return (path) => {
        const hash = createHash('sha256')
          .update(path)
          .digest('hex')
          .substring(0, 8);
        return `m${hash}`;
      };
    } : undefined,
  },
  server: {
    ...defaultConfig.server,
    enhanceMiddleware: (middleware) => {
      return (req, res, next) => {
        // Add security headers in production
        if (isProduction) {
          res.setHeader('X-Content-Type-Options', 'nosniff');
          res.setHeader('X-Frame-Options', 'DENY');
          res.setHeader('X-XSS-Protection', '1; mode=block');
        }
        return middleware(req, res, next);
      };
    },
  },
};
```

### A.2.4 Jest Configuration

```javascript
// jest.config.js
module.exports = {
  preset: 'jest-expo',
  transformIgnorePatterns: [
    'node_modules/(?!((jest-)?react-native|@react-native(-community)?)|expo(nent)?|@expo(nent)?/.*|@expo-google-fonts/.*|react-navigation|@react-navigation/.*|@unimodules/.*|unimodules|sentry-expo|native-base|react-native-svg|@nozbe/watermelondb)',
  ],
  setupFilesAfterEnv: [
    '@testing-library/jest-native/extend-expect',
    '<rootDir>/jest.setup.ts',
  ],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  testRegex: '(/__tests__/.*|(\\.|/)(test|spec))\\.[jt]sx?$',
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/index.ts',
    '!src/**/types.ts',
    '!src/**/*.stories.tsx',
    '!src/**/*.e2e.ts',
    '!src/database/migrations/**',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
    './src/services/': {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
    './src/database/': {
      branches: 75,
      functions: 75,
      lines: 75,
      statements: 75,
    },
  },
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@components/(.*)$': '<rootDir>/src/components/$1',
    '^@screens/(.*)$': '<rootDir>/src/screens/$1',
    '^@utils/(.*)$': '<rootDir>/src/utils/$1',
    '^@types/(.*)$': '<rootDir>/src/types/$1',
    '^@hooks/(.*)$': '<rootDir>/src/hooks/$1',
    '^@store/(.*)$': '<rootDir>/src/store/$1',
    '^@api/(.*)$': '<rootDir>/src/api/$1',
    '^@themes/(.*)$': '<rootDir>/src/themes/$1',
    '^@database/(.*)$': '<rootDir>/src/database/$1',
    '^@services/(.*)$': '<rootDir>/src/services/$1',
    '^@constants/(.*)$': '<rootDir>/src/constants/$1',
    '^@navigation/(.*)$': '<rootDir>/src/navigation/$1',
    '\\.(svg)$': '<rootDir>/__mocks__/svgMock.js',
  },
  verbose: true,
  testEnvironment: 'node',
  cacheDirectory: '.jest/cache',
  reporters: [
    'default',
    ['jest-junit', {
      outputDirectory: 'reports',
      outputName: 'junit.xml',
    }],
  ],
  globals: {
    __DEV__: true,
  },
};
```

### A.2.5 ESLint Configuration

```javascript
// .eslintrc.js
module.exports = {
  root: true,
  extends: [
    '@react-native-community',
    'plugin:@typescript-eslint/recommended',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'plugin:react-native/all',
    'prettier',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true,
    },
    project: './tsconfig.json',
  },
  plugins: [
    '@typescript-eslint',
    'react',
    'react-hooks',
    'react-native',
    'import',
    'jsx-a11y',
  ],
  settings: {
    react: {
      version: 'detect',
    },
    'import/resolver': {
      'babel-module': {
        extensions: ['.js', '.jsx', '.ts', '.tsx'],
        alias: {
          '@': './src',
          '@components': './src/components',
          '@screens': './src/screens',
          '@utils': './src/utils',
          '@types': './src/types',
          '@hooks': './src/hooks',
          '@store': './src/store',
          '@api': './src/api',
          '@themes': './src/themes',
          '@database': './src/database',
          '@services': './src/services',
          '@constants': './src/constants',
          '@navigation': './src/navigation',
        },
      },
    },
  },
  rules: {
    // React Rules
    'react/react-in-jsx-scope': 'off',
    'react/prop-types': 'off',
    'react/display-name': 'off',
    'react/jsx-key': 'error',
    'react/jsx-no-duplicate-props': 'error',
    'react/jsx-no-undef': 'error',
    'react/no-array-index-key': 'warn',
    'react/no-unused-state': 'warn',
    'react/no-unescaped-entities': 'warn',

    // React Hooks Rules
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',

    // React Native Rules
    'react-native/no-inline-styles': 'warn',
    'react-native/no-color-literals': 'warn',
    'react-native/no-raw-text': ['warn', { skip: ['Text'] }],
    'react-native/sort-styles': 'off',

    // TypeScript Rules
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unused-vars': ['error', {
      argsIgnorePattern: '^_',
      varsIgnorePattern: '^_',
      ignoreRestSiblings: true,
    }],
    '@typescript-eslint/no-empty-interface': 'warn',
    '@typescript-eslint/no-inferrable-types': 'off',
    '@typescript-eslint/no-var-requires': 'warn',
    '@typescript-eslint/ban-ts-comment': 'warn',
    '@typescript-eslint/ban-types': 'warn',

    // Import Rules
    'import/order': ['error', {
      groups: ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
      'newlines-between': 'always',
      alphabetize: {
        order: 'asc',
        caseInsensitive: true,
      },
    }],
    'import/no-duplicates': 'error',
    'import/no-unresolved': 'error',

    // General Rules
    'no-console': ['warn', { allow: ['warn', 'error', 'info'] }],
    'no-debugger': 'error',
    'prefer-const': 'error',
    'quotes': ['error', 'single', { avoidEscape: true }],
    'semi': ['error', 'always'],
    'indent': ['error', 2, { SwitchCase: 1 }],
    'comma-dangle': ['error', 'always-multiline'],
    'object-curly-spacing': ['error', 'always'],
    'arrow-body-style': ['error', 'as-needed'],
    'no-var': 'error',
    'eqeqeq': ['error', 'always'],
    'no-unused-expressions': 'error',
    'camelcase': ['error', { properties: 'never' }],
    'max-len': ['error', { code: 120, ignoreComments: true, ignoreStrings: true }],
  },
  overrides: [
    {
      files: ['**/__tests__/**/*.{ts,tsx}', '**/*.test.{ts,tsx}', '**/*.spec.{ts,tsx}'],
      rules: {
        '@typescript-eslint/no-explicit-any': 'off',
        'react-native/no-raw-text': 'off',
        'no-console': 'off',
      },
    },
    {
      files: ['e2e/**/*.js', 'e2e/**/*.ts'],
      rules: {
        'no-console': 'off',
        '@typescript-eslint/no-var-requires': 'off',
      },
    },
  ],
  ignorePatterns: [
    'node_modules/',
    'dist/',
    'build/',
    'coverage/',
    '**/__tests__/**/*',
    '**/e2e/**/*',
    '*.config.js',
    '*.config.ts',
    '*.setup.js',
    '*.setup.ts',
  ],
};
```

### A.2.6 Prettier Configuration

```javascript
// .prettierrc.js
module.exports = {
  // General
  printWidth: 100,
  tabWidth: 2,
  useTabs: false,
  semi: true,
  singleQuote: true,
  quoteProps: 'as-needed',
  jsxSingleQuote: false,
  trailingComma: 'all',
  bracketSpacing: true,
  bracketSameLine: true,
  arrowParens: 'avoid',
  
  // React Native
  endOfLine: 'lf',
  embeddedLanguageFormatting: 'auto',
  
  // Overrides for specific files
  overrides: [
    {
      files: ['*.json', '*.json5', '*.jsonc'],
      options: {
        tabWidth: 2,
      },
    },
    {
      files: ['*.md', '*.markdown'],
      options: {
        printWidth: 80,
        proseWrap: 'always',
      },
    },
    {
      files: ['*.yml', '*.yaml'],
      options: {
        tabWidth: 2,
        singleQuote: false,
      },
    },
  ],
};
```

---

## A.3 Environment Variables

### A.3.1 Environment Files

```env
# .env.development
# Development Environment Configuration

# API Configuration
API_URL=http://localhost:3000
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-development-anon-key

# App Configuration
ENVIRONMENT=development
LOG_LEVEL=debug
APP_VERSION=1.0.0-dev

# Feature Flags
ENABLE_ANALYTICS=false
ENABLE_CRASH_REPORTING=false
ENABLE_OTA_UPDATES=false
ENABLE_BIOMETRIC=true
ENABLE_PUSH_NOTIFICATIONS=true

# Debugging
DEBUG_NAVIGATION=true
DEBUG_SYNC=true
DEBUG_DATABASE=true
DEBUG_NETWORK=true

# Security
SENTRY_DSN=
ENABLE_SSL_PINNING=false
```

```env
# .env.staging
# Staging Environment Configuration

# API Configuration
API_URL=https://staging-api.nexuscollect.com
SUPABASE_URL=https://staging-project-id.supabase.co
SUPABASE_ANON_KEY=your-staging-anon-key

# App Configuration
ENVIRONMENT=staging
LOG_LEVEL=info
APP_VERSION=1.0.0-staging

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
ENABLE_OTA_UPDATES=true
ENABLE_BIOMETRIC=true
ENABLE_PUSH_NOTIFICATIONS=true

# Debugging
DEBUG_NAVIGATION=false
DEBUG_SYNC=false
DEBUG_DATABASE=false
DEBUG_NETWORK=false

# Security
SENTRY_DSN=your-sentry-dsn
ENABLE_SSL_PINNING=true
```

```env
# .env.production
# Production Environment Configuration

# API Configuration
API_URL=https://api.nexuscollect.com
SUPABASE_URL=https://production-project-id.supabase.co
SUPABASE_ANON_KEY=your-production-anon-key

# App Configuration
ENVIRONMENT=production
LOG_LEVEL=error
APP_VERSION=1.0.0

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
ENABLE_OTA_UPDATES=true
ENABLE_BIOMETRIC=true
ENABLE_PUSH_NOTIFICATIONS=true

# Debugging
DEBUG_NAVIGATION=false
DEBUG_SYNC=false
DEBUG_DATABASE=false
DEBUG_NETWORK=false

# Security
SENTRY_DSN=your-production-sentry-dsn
ENABLE_SSL_PINNING=true
```

### A.3.2 Environment Types

```typescript
// src/types/environment.d.ts
declare module '@env' {
  // API Configuration
  export const API_URL: string;
  export const SUPABASE_URL: string;
  export const SUPABASE_ANON_KEY: string;
  
  // App Configuration
  export const ENVIRONMENT: 'development' | 'staging' | 'production' | 'test';
  export const LOG_LEVEL: 'debug' | 'info' | 'warn' | 'error';
  export const APP_VERSION: string;
  
  // Feature Flags
  export const ENABLE_ANALYTICS: boolean;
  export const ENABLE_CRASH_REPORTING: boolean;
  export const ENABLE_OTA_UPDATES: boolean;
  export const ENABLE_BIOMETRIC: boolean;
  export const ENABLE_PUSH_NOTIFICATIONS: boolean;
  
  // Debugging
  export const DEBUG_NAVIGATION: boolean;
  export const DEBUG_SYNC: boolean;
  export const DEBUG_DATABASE: boolean;
  export const DEBUG_NETWORK: boolean;
  
  // Security
  export const SENTRY_DSN: string;
  export const ENABLE_SSL_PINNING: boolean;
}
```

---

## A.4 Git Configuration

### A.4.1 .gitignore

```gitignore
# .gitignore

# Dependencies
node_modules/
vendor/
.idea/
.workspace/
*.iml
*.log
*.pid

# Build directories
build/
dist/
out/
android/app/build/
ios/build/
ios/Pods/

# Expo
.expo/
.expo-shared/
expo-env.d.ts

# Coverage
coverage/
.nyc_output/
.lcov/

# Testing
__tests__/coverage/
e2e/reports/
junit.xml

# Environment
.env
.env.*
!.env.example
*.env.local
*.env.development.local
*.env.production.local

# Logs
*.log
npm-debug.*
yarn-debug.*
yarn-error.*
lerna-debug.*
logs/

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# System files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
Desktop.ini

# IDE files
.vscode/
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
*.code-workspace

# Temporary files
*.tmp
*.temp
*.swp
*.swo
*~

# Certificates and keys
*.p12
*.p8
*.pem
*.key
*.crt
*.csr
*.keystore
*.jks

# Secrets
secrets/
credentials/
keys/
*.secret

# Build artifacts
*.apk
*.aab
*.ipa
*.dSYM.zip
*.xcarchive
```

### A.4.2 Husky Git Hooks

```javascript
// .husky/pre-commit
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npm run precommit
```

```javascript
// .husky/pre-push
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npm run prepush
```

### A.4.3 Commitlint Configuration

```javascript
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // New feature
        'fix',      // Bug fix
        'docs',     // Documentation
        'style',    // Code style
        'refactor', // Code refactoring
        'perf',     // Performance improvement
        'test',     // Testing
        'chore',    // Build process / dependencies
        'revert',   // Revert changes
        'build',    // Build system changes
        'ci',       // CI configuration
        'release',  // Release version
      ],
    ],
    'type-case': [2, 'always', 'lower-case'],
    'type-empty': [2, 'never'],
    'scope-case': [2, 'always', 'lower-case'],
    'subject-case': [1, 'always', 'sentence-case'],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 72],
  },
};
```

---

## A.5 Database Migration Files

### A.5.1 Migration Template

```typescript
// src/database/migrations/001_initial_schema.ts
import { Database } from '@nozbe/watermelondb';
import { tableSchema } from '@nozbe/watermelondb/Schema';

export default {
  version: 1,
  up: async (db: Database) => {
    // Create tables
    // This is handled by the schema definition
    console.log('Migration 001: Initial schema created');
  },
  down: async (db: Database) => {
    // Rollback migration
    // This would drop all tables
    console.log('Migration 001: Rolling back');
  },
};
```

### A.5.2 Migration Runner

```typescript
// src/database/migrations/index.ts
import { Database } from '@nozbe/watermelondb';
import migration001 from './001_initial_schema';
import migration002 from './002_add_sync_fields';
import migration003 from './003_add_encryption';

export const migrations = [
  migration001,
  migration002,
  migration003,
];

export const runMigrations = async (database: Database): Promise<void> => {
  const currentVersion = await getCurrentVersion(database);
  const targetVersion = migrations.length;

  if (currentVersion === targetVersion) {
    console.log(`Database is at version ${currentVersion}, no migrations needed`);
    return;
  }

  console.log(`Migrating database from version ${currentVersion} to ${targetVersion}`);

  for (let i = currentVersion; i < targetVersion; i++) {
    const migration = migrations[i];
    if (migration) {
      console.log(`Running migration ${i + 1}: ${migration.version}`);
      await migration.up(database);
    }
  }

  await setCurrentVersion(database, targetVersion);
  console.log(`Database migration complete, version ${targetVersion}`);
};

const getCurrentVersion = async (database: Database): Promise<number> => {
  // Get current version from database metadata
  return 0; // Placeholder
};

const setCurrentVersion = async (database: Database, version: number): Promise<void> => {
  // Store version in database metadata
  console.log(`Setting database version to ${version}`);
};
```

---

## A.6 Quick Reference: Installation Commands

### A.6.1 Complete Project Setup

```bash
# Create new project
npx create-expo-app NexusCollect --template

# Navigate to project
cd NexusCollect

# Install all dependencies
npm install

# Install iOS pods (macOS only)
cd ios && pod install && cd ..

# Start development server
npx expo start

# Run on iOS
npx expo start --ios

# Run on Android
npx expo start --android

# Run on Web
npx expo start --web
```

### A.6.2 Testing Commands

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm test -- --watch

# Run specific test file
npm test -- --testPathPattern=button

# Run E2E tests
npm run test:e2e

# Run E2E tests with specific config
detox test -c ios.sim.debug
detox test -c android.emu.debug
```

### A.6.3 Build Commands

```bash
# Build for production
npm run build:prod

# Build iOS only
npm run build:prod:ios

# Build Android only
npm run build:prod:android

# Build with EAS
eas build --platform all --profile production

# Submit to App Store
npm run submit:ios

# Submit to Play Store
npm run submit:android
```

### A.6.4 Deployment Commands

```bash
# Deploy to App Store
npm run deploy:ios

# Deploy to Play Store
npm run deploy:android

# Deploy to both stores
npm run deploy:all

# Push OTA update
npm run deploy:ota

# Push OTA update to staging
npm run deploy:ota:staging
```

---

## A.7 Troubleshooting Common Issues

### A.7.1 iOS Build Issues

**Issue: `pod install` fails**
```bash
# Solution
sudo gem install cocoapods
pod install --repo-update
```

**Issue: Build fails with "No such module"**
```bash
# Solution
cd ios
pod deintegrate
pod install
cd ..
npx expo start --clear
```

### A.7.2 Android Build Issues

**Issue: Gradle build fails**
```bash
# Solution
cd android
./gradlew clean
./gradlew build
cd ..
```

**Issue: SDK not found**
```bash
# Solution
# Set ANDROID_HOME environment variable
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### A.7.3 Test Issues

**Issue: Tests won't run**
```bash
# Solution
npm install --force
npx jest --clearCache
npm test
```

### A.7.4 Database Issues

**Issue: WatermelonDB not working**
```bash
# Solution
npx expo install @nozbe/watermelondb expo-sqlite
cd ios && pod install && cd ..
```

---

This appendix provides a complete reference for all dependencies, configurations, and commands used throughout the NexusCollect project. Use it as a quick reference for setup, troubleshooting, and deployment.

---

**[END OF APPENDIX A]**

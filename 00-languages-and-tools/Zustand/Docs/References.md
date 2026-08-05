# References and Resources

## Official Documentation

| Resource | Description | URL |
|----------|-------------|-----|
| **Zustand Documentation** | Complete API reference, guides, and examples for Zustand | [zustand.docs.pmnd.rs](https://zustand.docs.pmnd.rs) |
| **Introduction Guide** | Getting started with Zustand's hook-based API | [Introduction](https://zustand.docs.pmnd.rs/getting-started/introduction) |
| **Updating State** | Guide to the `set` function and state updates | [Updating State](https://zustand.docs.pmnd.rs/guides/updating-state) |
| **TypeScript Guide** | Strongly typed stores with TypeScript | [TypeScript Guide](https://zustand.docs.pmnd.rs/guides/typescript) |
| **Slices Pattern** | Splitting stores into smaller modular slices | [Slices Pattern](https://zustand.docs.pmnd.rs/guides/slices-pattern) |
| **Testing Guide** | Writing tests for Zustand stores | [Testing](https://zustand.docs.pmnd.rs/guides/testing) |
| **Third-Party Libraries** | Community extensions and integrations | [Third-Party Libraries](https://zustand.docs.pmnd.rs/ecosystem/third-party-libraries) |

---

## GitHub Repositories

| Repository | Description | URL |
|------------|-------------|-----|
| **pmndrs/zustand** | Official Zustand source code, examples, and issues | [github.com/pmndrs/zustand](https://github.com/pmndrs/zustand) |
| **zustand-slices** | Slice pattern utilities and examples | [github.com/zustandjs/zustand-slices](https://github.com/zustandjs/zustand-slices) |
| **zustand-middleware-pipe** | Stack middleware in logical order | [github.com/zustandjs/zustand-middleware-pipe](https://github.com/zustandjs/zustand-middleware-pipe) |
| **zustand-mmkv-storage** | MMKV storage adapter for React Native | [github.com/1mehdifaraji/zustand-mmkv-storage](https://github.com/1mehdifaraji/zustand-mmkv-storage) |
| **zustand-refined** | Best practices wrapper | [github.com/scottrippey/zustand-refined](https://github.com/scottrippey/zustand-refined) |
| **zest** | Test generator for Zustand stores | [github.com/kyrwing/zest](https://github.com/kyrwing/zest) |

---

## Community & Support

| Resource | Description | Link |
|----------|-------------|------|
| **Poimandres Discord** | Official community chat for Zustand and related libraries | [discord.gg/poimandres](https://discord.gg/poimandres) |
| **Stack Overflow** | Zustand-tagged questions and answers | [stackoverflow.com/questions/tagged/zustand](https://stackoverflow.com/questions/tagged/zustand) |
| **Twitter/X** | Follow @pmndrs for updates | [twitter.com/pmndrs](https://twitter.com/pmndrs) |
| **GitHub Discussions** | Ask questions and share ideas | [github.com/pmndrs/zustand/discussions](https://github.com/pmndrs/zustand/discussions) |
| **Open Collective** | Support the project financially | [opencollective.com/pmndrs](https://opencollective.com/pmndrs) |

---

## Related Libraries & Middleware

### Core Middleware
| Middleware | Purpose | Documentation |
|------------|---------|---------------|
| **devtools** | Redux DevTools integration | [docs](https://zustand.docs.pmnd.rs/middleware/devtools) |
| **persist** | State persistence to storage | [docs](https://zustand.docs.pmnd.rs/middleware/persist) |
| **immer** | Immutable updates with mutable syntax | [docs](https://zustand.docs.pmnd.rs/middleware/immer) |
| **subscribeWithSelector** | Selective subscriptions | [docs](https://zustand.docs.pmnd.rs/middleware/subscribe-with-selector) |
| **combine** | Combine state and actions | [docs](https://zustand.docs.pmnd.rs/middleware/combine) |

### Storage Adapters
| Adapter | Description |
|---------|-------------|
| **localStorage** | Default web storage |
| **sessionStorage** | Tab-session storage |
| **AsyncStorage** | React Native storage |
| **MMKV** | High-performance React Native storage (~30x faster) |
| **IndexedDB** | Large data storage |
| **react-native-keychain** | Secure token storage |

### Ecosystem Integrations
| Library | Purpose | Notes |
|---------|---------|-------|
| **React Query** | Server state management | Use for API data, not Zustand |
| **Reselect** | Memoized selectors | For expensive computations |
| **Immer** | Immutable updates | Bundled as middleware |
| **React Hook Form** | Form management | Zustand for global state, RHF for forms |
| **Framer Motion** | Animations | Zustand drives animation state |
| **MSW** | API mocking | For testing Zustand stores |
| **Sentry** | Error tracking | Monitor Zustand errors in production |

---

## Articles & Tutorials

### Getting Started
| Title | Description |
|-------|-------------|
| **An Introduction to Zustand** | Simple, hook-based API for React global state |
| **Zustand: The Minimalist State Architecture** | Feature-sliced design approach |

### Advanced Topics
| Topic | Description |
|-------|-------------|
| **Middleware Order** | `devtools(persist(immer(...)))` – order matters |
| **Slice Pattern** | Modular store composition |
| **Next.js Integration** | SSR, hydration, and Server Components |
| **React Native** | AsyncStorage and MMKV persistence |

---

## Books & Courses

| Resource | Type | Description |
|----------|------|-------------|
| **Zustand Mastery Series** | Course | Complete 5-day tutorial series (this guide) |
| **React State Management** | Book | Zustand chapter included |
| **Zustand: The Complete Guide** | Course | Video course covering Zustand fundamentals |

---

## Quick Reference Card

### Create a Store
```typescript
import { create } from 'zustand';

const useStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));
```

### Add Middleware
```typescript
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

const useStore = create(
  devtools(
    persist(
      (set) => ({ /* ... */ }),
      { name: 'storage' }
    )
  )
);
```

### Use Selectors
```typescript
const count = useStore((state) => state.count);
```

### Test a Store
```typescript
import { describe, it, expect, beforeEach } from 'vitest';

describe('Store', () => {
  beforeEach(() => useStore.setState({ count: 0 }));

  it('should increment', () => {
    useStore.getState().increment();
    expect(useStore.getState().count).toBe(1);
  });
});
```

---

*Last Updated: August 2026*

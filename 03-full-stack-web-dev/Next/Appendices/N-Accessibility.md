# Appendix N: Accessibility and UX Verification Reference

This appendix provides a practical checklist for ensuring LaunchPad remains usable for keyboard users, screen-reader users, zoomed interfaces, reduced-motion users, and people on narrow screens.

Accessibility is not a final visual polish step. It is part of correct application behavior.

---

# N.1 Accessibility Principles Used in LaunchPad

LaunchPad follows these core principles:

```text
Perceivable
- Content can be seen, heard, or otherwise understood.

Operable
- Users can navigate and operate controls.

Understandable
- Labels, feedback, and errors are clear.

Robust
- Markup and interaction work with browsers and assistive technology.
```

In practice, that means:

- Real semantic HTML
- Visible keyboard focus
- Connected form labels
- Text-based status messages
- Clear loading and error states
- Responsive layouts
- Reduced-motion support
- No color-only meaning
- Proper page landmarks

---

# N.2 Semantic Landmark Map

A typical LaunchPad workspace page contains these landmarks:

```text
<body>
├── Skip link
├── <header>
│   └── Public navigation
├── Account bar
├── Workspace shell
│   ├── <aside>
│   │   └── <nav aria-label="Workspace navigation">
│   └── Main route content
│       └── <main>
└── <footer>
```

Important landmark elements include:

| Element | Purpose |
|---|---|
| `<header>` | Introductory or navigational content |
| `<nav>` | Navigation links |
| `<main>` | Main route content |
| `<aside>` | Supporting workspace navigation |
| `<footer>` | Closing site information |
| `<section>` | Named content grouping |
| `<article>` | Self-contained project or task item |

Do not replace semantic elements with generic `<div>` elements without a reason.

---

# N.3 Skip Link Verification

LaunchPad includes:

```tsx
<a className="skip-link" href="#main-content">
  Skip to main content
</a>
```

The target must exist once per page:

```tsx
<div id="main-content" tabIndex={-1}>
  {children}
</div>
```

## Manual test

1. Load a route.
2. Press `Tab`.
3. Confirm **Skip to main content** appears.
4. Press `Enter`.
5. Confirm focus moves beyond repeated navigation.
6. Press `Tab` again.
7. Confirm focus reaches the first meaningful route control.

Test these routes:

```text
/
/about
/sign-in
/dashboard
/projects
/projects/:projectId
```

## Verify duplicate IDs

```bash
for path in \
  "/" \
  "/about" \
  "/sign-in" \
  "/dashboard" \
  "/projects"
do
  count="$(
    curl --silent "http://localhost:3000${path}" |
      grep -o 'id="main-content"' |
      wc -l |
      tr -d " "
  )"

  printf "%-20s main-content count: %s\n" \
    "${path}" \
    "${count}"
done
```

Every route should report:

```text
main-content count: 1
```

---

# N.4 Keyboard Navigation Checklist

Every interactive element must be reachable and usable without a pointer device.

## Required keyboard behavior

| Control | Keyboard behavior |
|---|---|
| Link | `Tab`, then `Enter` |
| Button | `Tab`, then `Enter` or `Space` |
| Select | `Tab`, arrow keys, `Enter` |
| Text field | `Tab`, type text |
| Disclosure | `Tab`, then `Enter` or `Space` |
| Form | `Tab` through controls, `Enter` submit where appropriate |

## Workspace keyboard test

Open:

```text
http://localhost:3000/projects
```

Then:

1. Press `Tab` to reveal the skip link.
2. Press `Enter`.
3. Tab through workspace navigation.
4. Tab through status filtering controls.
5. Tab through project search.
6. Tab through project links.
7. Open a project.
8. Tab through:
   - Copy-link button
   - Disclosure buttons
   - Task status selectors
   - Update buttons
   - Task creation form
9. Confirm every control has visible focus.

## Focus failure examples

Bad:

```css
button:focus {
  outline: none;
}
```

Better:

```css
button:focus-visible {
  outline: 0.2rem solid var(--color-focus);
  outline-offset: 0.2rem;
}
```

LaunchPad provides global focus styling through:

```text
src/styles/accessibility.css
```

---

# N.5 Form Accessibility Checklist

Every form field should have:

- A visible `<label>`
- A matching `htmlFor`
- A matching control `id`
- Helpful instructions where needed
- Clear validation feedback
- `aria-invalid` for invalid fields
- Error text that explains the problem

## Good pattern

```tsx
<div className="form-field">
  <label htmlFor="project-name">
    Project name
  </label>

  <input
    id="project-name"
    name="name"
    type="text"
    required
    aria-invalid={
      state.fieldErrors?.name ? true : undefined
    }
  />

  {state.fieldErrors?.name?.map((error) => (
    <p className="field-error" key={error}>
      {error}
    </p>
  ))}
</div>
```

## Bad pattern

```tsx
<input placeholder="Project name" />
```

A placeholder is not a replacement for a label because it:

- Disappears as the user types
- May have weak contrast
- Is not always announced as a persistent field label
- Does not explain required input reliably

---

# N.6 Error Message Verification

Validation errors should answer:

```text
What is wrong?
How can the user correct it?
```

Good:

```text
Enter a project name.
Passwords must contain at least 12 characters.
The passwords do not match.
```

Weak:

```text
Invalid input.
Something went wrong.
Error 422.
```

## Screen-reader behavior

Form-level errors should use:

```tsx
role="alert"
```

or:

```tsx
role="status"
```

depending on urgency.

Example:

```tsx
<p
  className="form-message form-message--error"
  role="alert"
>
  {state.message}
</p>
```

A form submission failure should not silently change color without announcing the reason.

---

# N.7 Status and Color Verification

LaunchPad uses badges for:

```text
Planned
Active
Completed
```

Color supports meaning, but text supplies the actual meaning.

Correct:

```tsx
<StatusBadge status="COMPLETED" />
```

Visible result:

```text
Completed
```

Incorrect design:

```text
Green badge with no label
Purple badge with no label
Blue badge with no label
```

A user who cannot distinguish color should still understand the state.

The same rule applies to:

```text
Priority
Error state
Success state
Warning state
Loading state
```

---

# N.8 Disclosure Accessibility

LaunchPad disclosures use:

```tsx
<button
  type="button"
  aria-expanded={isOpen}
  aria-controls={contentId}
>
  {title}
</button>

<div
  id={contentId}
  hidden={!isOpen}
>
  {children}
</div>
```

## Manual test

1. Tab to the disclosure.
2. Confirm the button has focus.
3. Confirm assistive technology can announce collapsed or expanded state.
4. Press `Enter`.
5. Confirm the content appears.
6. Press `Space`.
7. Confirm the content hides again.

Do not implement a disclosure with a clickable `<div>`:

```tsx
<div onClick={toggle}>
  More details
</div>
```

That pattern is not keyboard-accessible by default.

---

# N.9 Live Region Verification

LaunchPad uses live regions for changing result counts and form feedback.

Example:

```tsx
<p
  aria-live="polite"
  aria-atomic="true"
>
  {visibleProjects.length} projects
</p>
```

## When to use `aria-live="polite"`

Use for nonurgent updates such as:

```text
- Search result counts
- Successful task creation
- Copy-link success
- Background completion messages
```

## When to use `role="alert"`

Use for urgent errors requiring attention:

```text
- Form submission failure
- Invalid credentials
- Unexpected destructive-operation failure
```

Avoid putting large changing sections inside live regions. Screen readers may announce too much content.

---

# N.10 Image Alternative Text

Meaningful images need meaningful alternative text.

LaunchPad’s dashboard illustration uses:

```tsx
<Image
  src="/launchpad-dashboard.png"
  alt="Illustration of the LaunchPad dashboard with project statistics and progress cards"
  width={1600}
  height={900}
/>
```

The alternative describes the image’s purpose.

## Decorative image

If an image adds no information, use:

```tsx
<Image
  src="/decorative-shape.png"
  alt=""
  width={400}
  height={400}
/>
```

Do not use:

```tsx
alt="image"
```

or:

```tsx
alt="dashboard.png"
```

Those do not help users understand the content.

---

# N.11 Responsive and Zoom Verification

Accessibility includes layout resilience.

Test these viewport widths:

```text
1440px
1024px
768px
390px
320px
```

Test browser zoom:

```text
200%
```

Verify:

- Text remains readable.
- No essential content overlaps.
- Form controls remain reachable.
- Navigation remains usable.
- Project titles wrap inside cards.
- Task cards stack correctly.
- Sidebars become usable horizontal navigation when necessary.
- Buttons remain large enough to activate.
- No unintended horizontal scrolling occurs.

A small amount of horizontal scrolling may be acceptable for intentionally scrollable navigation, but ordinary page content should not overflow.

---

# N.12 Reduced-Motion Verification

LaunchPad respects:

```css
@media (prefers-reduced-motion: reduce)
```

## Test procedure

In browser developer tools:

1. Open rendering or accessibility emulation settings.
2. Emulate:

   ```text
   prefers-reduced-motion: reduce
   ```

3. Reload the route.

Verify:

- Skeleton shimmer stops.
- Card hover movement stops.
- Skip-link transition stops.
- Smooth scrolling stops.
- No essential state information disappears.

Reduced motion should remove decorative motion, not essential feedback.

---

# N.13 Print Verification

Open print preview for:

```text
/projects
/projects/:projectId
```

LaunchPad print CSS should:

```text
- Hide site navigation
- Hide workspace navigation
- Hide mutation controls
- Hide copy-link actions
- Remove decorative shadows
- Keep project details and tasks readable
- Use black-on-white content
```

Test:

1. Open browser print dialog.
2. Inspect each printed page.
3. Confirm no content is clipped.
4. Confirm project data remains visible.
5. Cancel the print job unless an actual print is needed.

---

# N.14 Screen Reader Testing Suggestions

You do not need to become an expert in every screen reader before beginning accessibility testing.

Start with one platform:

| Platform | Common screen reader |
|---|---|
| macOS | VoiceOver |
| Windows | NVDA |
| Windows | JAWS |
| Android | TalkBack |
| iOS | VoiceOver |

Test these flows:

```text
- Navigate by headings
- Navigate by landmarks
- Find main content
- Read project status
- Submit invalid sign-in form
- Search project list
- Open disclosure
- Change task status
- Sign out
```

Listen for:

```text
- Clear page title
- Landmark names
- Visible labels
- Error announcements
- Expanded/collapsed disclosure state
- Meaningful button names
- Status text
```

---

# N.15 Accessibility Regression Checklist

Before merging an interface change:

- [ ] New interactive controls use real semantic elements.
- [ ] Buttons use `<button>`.
- [ ] Navigation uses `<a>` or Next.js `Link`.
- [ ] Form controls have labels.
- [ ] Error text explains the correction.
- [ ] Focus remains visible.
- [ ] Keyboard operation works.
- [ ] New images have correct alternative text.
- [ ] Meaning is not communicated only through color.
- [ ] Dynamic state is announced where needed.
- [ ] Headings remain hierarchical.
- [ ] Route has one main-content target.
- [ ] Narrow viewport layout works.
- [ ] 200% zoom layout works.
- [ ] Reduced-motion behavior works.
- [ ] Print output remains reasonable.
- [ ] Production build still succeeds.

---

# N.16 Useful Accessibility Tools

Useful tools include:

```text
Browser developer tools accessibility tree
Lighthouse accessibility report
Axe DevTools
WAVE browser extension
NVDA
VoiceOver
Playwright accessibility snapshots
Color contrast checkers
Browser zoom and device emulation
```

Tools can find many structural issues, but they cannot fully determine whether the interface is understandable or pleasant to use.

Manual testing remains required.

---

# N.17 Final Accessibility Rule

When adding a feature, do not ask only:

> Does it work with a mouse on my screen?

Also ask:

```text
- Can I reach it with Tab?
- Can I identify its purpose without color?
- Does it have a label?
- Is its state announced?
- Does it work at 200% zoom?
- Does it work on a narrow screen?
- Does it respect reduced motion?
- Does it still make sense when printed?
```

If the answer is yes, the feature is much more likely to work for everyone.

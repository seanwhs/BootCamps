# Appendix G: Accessibility Checklist and Implementation Guide

Accessibility means designing software that people with different abilities can use effectively.

For a browser application, accessibility includes:

- Keyboard operation.
- Screen-reader support.
- Visible focus.
- Clear labels.
- Sufficient color contrast.
- Understandable error messages.
- Predictable interaction behavior.
- Support for different screen sizes and input methods.

Accessibility is not a separate feature added at the end. It is part of creating a reliable interface.

---

# 1. Accessibility Goals

The completed Async Task Manager should allow a user to:

- Navigate every control with a keyboard.
- Understand what each input and button does.
- Submit a task without using a mouse.
- Identify loading, success, and error states.
- Determine which tasks are completed.
- Operate the filter control.
- Delete tasks intentionally.
- See visible focus indicators.
- Use the application with a screen reader.
- Use the application on a narrow screen.
- Understand errors without relying only on color.

---

# 2. Use Semantic HTML

Semantic HTML uses elements according to their meaning.

Prefer:

```html
<header>
  <main>
  <section>
  <form>
  <label>
  <button>
  <ul>
  <li>
</section>
```

over generic elements:

```html
<div class="header">
  <div class="content">
    <div class="button" onclick="...">
```

Semantic elements provide built-in browser behavior and improve assistive-technology interpretation.

---

# 3. Page Landmarks

The final application uses a main landmark:

```html
<main class="app-shell">
  <!-- Application content -->
</main>
```

A larger application can include:

```html
<header>
  <!-- Branding and navigation -->
</header>

<main>
  <!-- Primary application content -->
</main>

<footer>
  <!-- Supporting information -->
</footer>
```

Landmarks help screen-reader users navigate directly to major areas.

---

# 4. Heading Structure

Headings should describe the page hierarchy.

The application uses:

```html
<h1>Async Task Manager</h1>

<h2>Add a task</h2>
<h2>Asynchronous loading</h2>
<h2>Task filter</h2>
<h2>Application status</h2>
<h2>Tasks</h2>
```

Rules:

- Use one primary `h1` for the page or application.
- Use `h2` for major sections.
- Do not choose heading levels based only on font size.
- Do not skip levels without a good reason.
- Use CSS to control appearance.

Incorrect:

```html
<h1>Async Task Manager</h1>
<h4>Add a task</h4>
```

Correct:

```html
<h1>Async Task Manager</h1>
<h2>Add a task</h2>
```

---

# 5. Form Labels

Every form control should have an accessible name.

## Explicit Label

```html
<label for="task-title">Task title</label>

<input
  id="task-title"
  name="taskTitle"
  type="text"
/>
```

The `for` value must match the input’s `id`.

## Why Placeholder Text Is Not a Label

This is insufficient:

```html
<input
  type="text"
  placeholder="Enter a task"
/>
```

Placeholder text:

- Disappears while typing.
- May have poor contrast.
- Is not a reliable replacement for a label.
- Can confuse users when the input is empty after an error.

Use both a visible label and an optional placeholder:

```html
<label for="task-title">Task title</label>

<input
  id="task-title"
  name="taskTitle"
  type="text"
  placeholder="For example: Study browser storage"
/>
```

---

# 6. Input Validation and Accessible Errors

Native HTML validation is useful:

```html
<input
  id="task-title"
  name="taskTitle"
  type="text"
  required
  maxlength="120"
/>
```

However, server or JavaScript validation may still be necessary.

An accessible error pattern includes:

```html
<label for="task-title">Task title</label>

<input
  id="task-title"
  name="taskTitle"
  type="text"
  required
  aria-describedby="task-title-error"
  aria-invalid="false"
/>

<p
  id="task-title-error"
  class="field-error"
  hidden
></p>
```

When invalid:

```javascript
function showTaskTitleError(input, errorElement, message) {
  input.setAttribute("aria-invalid", "true");
  errorElement.textContent = message;
  errorElement.hidden = false;
}
```

When valid:

```javascript
function clearTaskTitleError(input, errorElement) {
  input.setAttribute("aria-invalid", "false");
  errorElement.textContent = "";
  errorElement.hidden = true;
}
```

The error text should explain:

- What went wrong.
- How to correct it.

Good:

```text
Task title cannot be empty. Enter a title before submitting.
```

Less useful:

```text
Invalid input.
```

---

# 7. Improve the Final Form Markup

The current form can be enhanced with a field-level error area.

## `index.html`

Replace the task form section with:

```html
<section class="panel" aria-labelledby="add-task-heading">
  <h2 id="add-task-heading">Add a task</h2>

  <form id="task-form" novalidate>
    <div class="form-row">
      <label for="task-title">Task title</label>

      <div class="input-row">
        <input
          id="task-title"
          name="taskTitle"
          type="text"
          maxlength="120"
          autocomplete="off"
          placeholder="For example: Study browser storage"
          aria-describedby="task-title-help task-title-error"
          aria-invalid="false"
          required
        />

        <button type="submit">Add task</button>
      </div>

      <p id="task-title-help" class="field-help">
        Use between 1 and 120 characters.
      </p>

      <p
        id="task-title-error"
        class="field-error"
        role="alert"
        hidden
      ></p>
    </div>
  </form>
</section>
```

The `novalidate` attribute prevents the browser’s default popup validation so the application can display its own consistent error message. JavaScript must then perform the validation.

If you prefer native browser validation, omit `novalidate` and still retain server-side or application-level validation.

---

# 8. Update the Form Module

## The Target

Update `js/ui/task-form.js` so it supports field-level validation feedback.

## Implementation

### `js/ui/task-form.js`

```javascript
"use strict";

export function bindTaskForm(
  formElement,
  {
    onSubmit,
    onValidationError,
  }
) {
  if (!(formElement instanceof HTMLFormElement)) {
    throw new TypeError("A form element is required.");
  }

  if (typeof onSubmit !== "function") {
    throw new TypeError("onSubmit must be a function.");
  }

  if (typeof onValidationError !== "function") {
    throw new TypeError(
      "onValidationError must be a function."
    );
  }

  const titleInput = formElement.elements.namedItem("taskTitle");

  if (!(titleInput instanceof HTMLInputElement)) {
    throw new Error("The task title input could not be found.");
  }

  const errorElement = document.querySelector(
    "#task-title-error"
  );

  if (!(errorElement instanceof HTMLElement)) {
    throw new Error(
      "The task title error element could not be found."
    );
  }

  formElement.addEventListener("submit", (event) => {
    event.preventDefault();

    try {
      onSubmit(titleInput.value);

      titleInput.setAttribute("aria-invalid", "false");
      errorElement.textContent = "";
      errorElement.hidden = true;

      titleInput.value = "";
      titleInput.focus();
    } catch (error) {
      onValidationError(error);

      titleInput.setAttribute("aria-invalid", "true");
      errorElement.textContent = error.message;
      errorElement.hidden = false;
      titleInput.focus();
    }
  });
}
```

This version assumes the application’s `onSubmit` callback throws validation errors instead of handling them internally. If the application continues to catch errors inside `handleAddTask`, use the simpler original form module and update the input state from the application coordinator.

---

# 9. Focus Management

Keyboard users need to know where they are.

The browser typically provides a focus outline, but application CSS can accidentally remove it.

Avoid:

```css
*:focus {
  outline: none;
}
```

This removes an essential navigation signal.

Use a clear focus style:

```css
button:focus-visible,
input:focus-visible,
select:focus-visible {
  outline: 3px solid #173f9f;
  outline-offset: 3px;
}
```

`focus-visible` shows the outline when keyboard focus needs to be communicated without unnecessarily changing every mouse interaction.

For broad browser support, also provide a fallback:

```css
button:focus,
input:focus,
select:focus {
  outline: 3px solid #173f9f;
  outline-offset: 3px;
}
```

---

# 10. Focus After Form Submission

After successfully adding a task, returning focus to the input is useful because users may want to add another task.

The final form module already does this:

```javascript
titleInput.focus();
```

After an error, focus should also return to the invalid field:

```javascript
titleInput.focus();
```

This avoids forcing the user to search for the input again.

---

# 11. Focus After Deletion

When a task is deleted, the clicked button disappears.

If focus is not managed, keyboard users may lose their position.

A basic approach is to focus the task list after rendering:

```javascript
taskList.setAttribute("tabindex", "-1");
taskList.focus();
```

However, moving focus unnecessarily can be disruptive.

A better approach is to focus:

1. The next task’s action.
2. The previous task’s action.
3. The task list.
4. A status message.

The exact behavior depends on the application’s interaction model.

For a small application, a status announcement may be sufficient:

```javascript
this.status.show("Task deleted.", "success");
```

If focus must move, make the destination clear:

```javascript
clearTasksButton.focus();
```

---

# 12. Buttons Must Be Buttons

Use:

```html
<button type="button">Delete</button>
```

Avoid clickable generic elements:

```html
<div onclick="deleteTask()">Delete</div>
```

A real button provides:

- Keyboard activation.
- Focus behavior.
- Button semantics.
- Expected screen-reader announcements.
- Built-in disabled behavior.

If a control performs an action, use a button.

If a control navigates to another location, use a link:

```html
<a href="/settings">Settings</a>
```

---

# 13. Button Types

Inside a form, always specify the button type.

Submit button:

```html
<button type="submit">Add task</button>
```

Non-submit action:

```html
<button type="button">Load example tasks</button>
```

Without `type="button"`, a button inside a form may behave as a submit button by default.

---

# 14. Accessible Button Names

A button’s visible text usually provides its accessible name:

```html
<button type="button">Delete</button>
```

If an icon-only button is used, provide an accessible label:

```html
<button
  type="button"
  aria-label="Delete task"
>
  <span aria-hidden="true">🗑</span>
</button>
```

Do not rely on the icon alone.

For task-specific buttons, include the task title when helpful:

```html
<button
  type="button"
  aria-label="Delete task: Study browser storage"
>
  Delete
</button>
```

The final renderer can assign this dynamically:

```javascript
deleteButton.setAttribute(
  "aria-label",
  `Delete task: ${task.title}`
);
```

Because the task title comes from user or external data, `setAttribute` safely treats it as an attribute value rather than HTML markup.

---

# 15. Improve Task Action Labels

Update `js/ui/task-list.js` so buttons have task-specific accessible names.

Inside the task loop, use:

```javascript
toggleButton.setAttribute(
  "aria-label",
  task.isCompleted()
    ? `Mark task incomplete: ${task.title}`
    : `Mark task complete: ${task.title}`
);

deleteButton.setAttribute(
  "aria-label",
  `Delete task: ${task.title}`
);
```

The visible text remains short:

```javascript
toggleButton.textContent = task.isCompleted()
  ? "Mark as incomplete"
  : "Mark as complete";

deleteButton.textContent = "Delete";
```

The visible label and accessible label can provide different levels of detail.

---

# 16. Status Messages

The application uses:

```html
<p
  id="status-message"
  class="status-message"
  role="status"
  aria-live="polite"
>
  Starting application...
</p>
```

This tells assistive technologies that the content may change and should be announced politely.

Use `role="status"` for non-urgent updates:

```text
Task added.
Tasks loaded.
Task deleted.
```

Use `role="alert"` for urgent errors:

```html
<p
  id="error-message"
  role="alert"
></p>
```

Avoid making every minor update an alert. Excessive announcements can be distracting.

---

# 17. Loading States

During asynchronous loading:

```javascript
this.status.show(
  "Loading example tasks...",
  "loading"
);
```

Also disable the button:

```javascript
this.loadTasksButton.disabled = true;
```

The disabled state communicates that the action is temporarily unavailable.

For more explicit semantics, add:

```javascript
this.loadTasksButton.setAttribute(
  "aria-busy",
  "true"
);
```

Restore it afterward:

```javascript
this.loadTasksButton.removeAttribute(
  "aria-busy"
);
```

A complete pattern:

```javascript
this.loadTasksButton.disabled = true;
this.loadTasksButton.setAttribute(
  "aria-busy",
  "true"
);

try {
  await fetchExampleTasks();
} finally {
  this.loadTasksButton.disabled = false;
  this.loadTasksButton.removeAttribute(
    "aria-busy"
  );
}
```

---

# 18. Loading Indicators

A text status is often sufficient:

```html
<p role="status" aria-live="polite">
  Loading example tasks...
</p>
```

If a visual spinner is added, hide decorative content from screen readers:

```html
<span
  class="spinner"
  aria-hidden="true"
></span>

<span>Loading example tasks...</span>
```

Do not rely only on a spinning animation or color change.

---

# 19. Task Completion Semantics

The final application uses styling:

```css
.task-completed .task-title {
  text-decoration: line-through;
}
```

A strikethrough is useful visually, but it should not be the only signal.

The application also renders text:

```javascript
metadata.textContent = task.getStatusLabel();
```

which produces:

```text
Completed
```

This gives users a textual completion state.

A task row can also expose state through `aria-label`:

```javascript
listItem.setAttribute(
  "aria-label",
  `${task.title}. ${task.getStatusLabel()}`
);
```

Do not add redundant labels if the child content already communicates the same information clearly.

---

# 20. Lists and Dynamic Content

The task list uses:

```html
<ul id="task-list" class="task-list"></ul>
```

Each task is rendered as:

```html
<li class="task-item">
  <!-- Task content -->
</li>
```

This is semantically appropriate because the tasks form a list.

Avoid placing interactive elements directly inside a paragraph:

```html
<p>
  Task title
  <button>Delete</button>
</p>
```

A list item with separate content and action areas is clearer:

```html
<li>
  <div>
    <p>Task title</p>
    <p>Completed</p>
  </div>

  <div>
    <button>Complete</button>
    <button>Delete</button>
  </div>
</li>
```

---

# 21. Improve Task List Semantics

The renderer can add a group label:

```html
<section
  class="panel"
  aria-labelledby="tasks-heading"
>
  <div class="section-heading">
    <div>
      <h2 id="tasks-heading">Tasks</h2>
      <p id="task-count">0 tasks</p>
    </div>
  </div>

  <ul
    id="task-list"
    class="task-list"
    aria-labelledby="tasks-heading"
  ></ul>
</section>
```

This associates the list with its heading.

Do not add unnecessary ARIA when native HTML already communicates the meaning. Native semantics should be the first choice.

---

# 22. Select Controls

The filter uses a native select:

```html
<label class="filter-control">
  <span class="visually-hidden">
    Filter tasks
  </span>

  <select id="task-filter">
    <option value="all">All tasks</option>
    <option value="active">Active tasks</option>
    <option value="completed">Completed tasks</option>
  </select>
</label>
```

The label wraps the select, so the control has an accessible name.

A visible label may be clearer:

```html
<label for="task-filter">Show</label>

<select id="task-filter">
  <option value="all">All tasks</option>
  <option value="active">Active tasks</option>
  <option value="completed">Completed tasks</option>
</select>
```

This is usually preferable because users can see what the control does.

---

# 23. Recommended Filter Markup

Replace the filter control with:

```html
<div class="filter-control">
  <label for="task-filter">Show</label>

  <select id="task-filter">
    <option value="all">All tasks</option>
    <option value="active">Active tasks</option>
    <option value="completed">Completed tasks</option>
  </select>
</div>
```

Add CSS:

```css
.filter-control {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  color: #536078;
  font-weight: 700;
}
```

This improves clarity for sighted users while retaining native accessibility.

---

# 24. Color Contrast

Text and interactive controls must have enough contrast against their background.

Do not use color as the only status indicator:

```css
.status-success {
  background: green;
}

.status-error {
  background: red;
}
```

The application also uses text:

```text
Task added.
Could not load example tasks.
```

That is important because users may:

- Have color-vision deficiencies.
- Use a monochrome display.
- Have low vision.
- View the page in bright light.
- Use high-contrast settings.

Check contrast with browser accessibility tools or a contrast analyzer.

---

# 25. Focus Styles and Contrast

A focus indicator must contrast against the surrounding page.

Recommended:

```css
button:focus-visible,
input:focus-visible,
select:focus-visible {
  outline: 3px solid #173f9f;
  outline-offset: 3px;
}
```

Do not use a subtle focus style such as:

```css
button:focus {
  outline: 1px solid #dce2eb;
}
```

It may be difficult to see.

---

# 26. Reduced Motion

Some users prefer reduced motion.

Respect the operating-system preference:

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    scroll-behavior: auto !important;
    transition-duration: 0.01ms !important;
  }
}
```

The application currently uses short transitions:

```css
transition:
  background 150ms ease,
  transform 150ms ease,
  opacity 150ms ease;
```

The reduced-motion rule prevents those effects from becoming uncomfortable for users who request less motion.

---

# 27. Do Not Disable Zoom

Do not use:

```html
<meta
  name="viewport"
  content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"
/>
```

This can prevent users from enlarging the page.

Use:

```html
<meta
  name="viewport"
  content="width=device-width, initial-scale=1.0"
/>
```

Users should be able to zoom the page.

---

# 28. Responsive Layout

The application should work at narrow widths.

The final stylesheet includes:

```css
@media (max-width: 600px) {
  .input-row,
  .section-heading {
    align-items: stretch;
    flex-direction: column;
  }

  .task-item {
    align-items: flex-start;
    flex-direction: column;
  }
}
```

Test at:

```text
320px
375px
768px
1024px
```

Check:

- No horizontal scrolling.
- Buttons remain fully visible.
- Text wraps.
- Form controls remain large enough to use.
- The filter remains understandable.

---

# 29. Touch Target Size

Interactive controls should have enough area to activate comfortably.

The application uses:

```css
button {
  padding: 0.7rem 1rem;
}
```

Avoid tiny controls:

```css
button {
  width: 12px;
  height: 12px;
}
```

If an icon-only button is used, provide a sufficiently large clickable area:

```css
.icon-button {
  min-width: 2.75rem;
  min-height: 2.75rem;
  padding: 0.5rem;
}
```

The visible icon may be small, but the interactive target should remain usable.

---

# 30. Accessible Empty States

The task list displays:

```text
No tasks match the selected filter.
```

This is useful because it explains why the list is empty.

Different empty conditions may deserve different messages:

```text
No tasks have been created yet.
```

versus:

```text
No active tasks match the selected filter.
```

A more informative renderer can receive the current filter:

```javascript
function getEmptyMessage(filter) {
  if (filter === "active") {
    return "No active tasks.";
  }

  if (filter === "completed") {
    return "No completed tasks.";
  }

  return "No tasks have been created yet.";
}
```

---

# 31. Accessible Confirmation for Destructive Actions

Deleting a task is destructive.

A simple confirmation can prevent accidental deletion:

```javascript
const confirmed = window.confirm(
  `Delete task "${task.title}"?`
);

if (!confirmed) {
  return;
}

onDelete(task.id);
```

However, native `window.confirm()` dialogs:

- Interrupt the page.
- Have inconsistent browser presentation.
- Can be difficult to customize.
- May not fit every interaction model.

For a larger application, use an accessible dialog with:

- A clear heading.
- A description.
- Cancel and confirm buttons.
- Focus moved into the dialog.
- Focus returned to the original control after closing.
- Escape-key support.
- Background interaction disabled.

---

# 32. Accessible Dialog Requirements

A custom dialog should generally include:

```html
<div
  role="dialog"
  aria-modal="true"
  aria-labelledby="delete-dialog-title"
  aria-describedby="delete-dialog-description"
>
  <h2 id="delete-dialog-title">
    Delete task?
  </h2>

  <p id="delete-dialog-description">
    This action cannot be undone.
  </p>

  <button type="button">Cancel</button>
  <button type="button">Delete</button>
</div>
```

Do not create a custom dialog unless you can implement focus management correctly. A native confirmation dialog is often safer for a small application.

---

# 33. Screen Reader Testing

Use at least one screen reader where possible.

Common options:

- NVDA on Windows.
- VoiceOver on macOS and iOS.
- TalkBack on Android.
- Orca on Linux.

Test:

- Page heading.
- Form label.
- Input instructions.
- Validation errors.
- Status updates.
- Task titles.
- Completion state.
- Action buttons.
- Filter control.

Listen for whether the user can understand:

```text
Task title, edit text
Task title cannot be empty
Study browser storage, not completed
Mark task complete
Delete task
```

---

# 34. Keyboard Test Procedure

Use only the keyboard.

1. Refresh the page.
2. Press `Tab` repeatedly.
3. Observe each focus location.
4. Type into the task input.
5. Press `Enter`.
6. Navigate to the load button.
7. Press `Enter`.
8. Navigate to the filter.
9. Change its value.
10. Navigate to a task action.
11. Press `Enter` or `Space`.
12. Verify the task updates.
13. Navigate to delete.
14. Activate it.
15. Confirm the result.

Expected behavior:

- Every control is reachable.
- Focus order follows the visual order.
- No control traps focus unexpectedly.
- Focus does not disappear.
- Buttons activate without a mouse.

---

# 35. Automated Accessibility Checks

Browser tools can detect common issues.

Use:

- Lighthouse.
- axe DevTools.
- Accessibility Insights.
- Firefox Accessibility Inspector.
- Chrome Accessibility pane.

These tools can identify:

- Missing labels.
- Low contrast.
- Missing button names.
- Incorrect ARIA.
- Heading problems.
- Missing landmarks.

Automated tools do not replace human testing. They detect only some categories of accessibility problems.

---

# 36. Accessibility Test Page

Create a temporary page containing the final application and test it with keyboard navigation.

The application itself is already suitable for this test, so run:

```bash
python3 -m http.server 8000
```

Open:

```text
http://localhost:8000
```

Then verify:

```text
Tab → task input
Tab → add button
Tab → load button
Tab → filter
Tab → clear button
Tab → task actions
```

If the order is unexpected, inspect the HTML order and avoid using positive `tabindex` values.

---

# 37. Avoid Positive `tabindex`

Avoid:

```html
<button tabindex="1">First</button>
<button tabindex="2">Second</button>
```

Positive `tabindex` values create a separate navigation order that is difficult to maintain.

Prefer natural DOM order:

```html
<button type="button">First</button>
<button type="button">Second</button>
```

Use:

```html
tabindex="0"
```

only when a custom focusable element genuinely needs to enter the normal focus order.

Use:

```html
tabindex="-1"
```

when an element should be focusable programmatically but not reached through normal Tab navigation.

---

# 38. Hide Decorative Content Correctly

For decorative content:

```html
<span aria-hidden="true">✓</span>
```

For visually hidden but semantically important text, use a visually hidden class:

```css
.visually-hidden {
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip: rect(0 0 0 0);
  clip-path: inset(50%);
  white-space: nowrap;
}
```

Do not use:

```css
display: none;
```

when screen readers still need to access the content. `display: none` removes the element from the accessibility tree.

---

# 39. Do Not Use ARIA to Repair Incorrect HTML

Prefer:

```html
<button type="button">Delete</button>
```

over:

```html
<div
  role="button"
  tabindex="0"
>
  Delete
</div>
```

The native button already provides:

- Role.
- Keyboard behavior.
- Focus behavior.
- Expected interaction semantics.

ARIA should enhance correct HTML, not replace it unnecessarily.

---

# 40. Improve the Final Stylesheet for Accessibility

Add these rules to `styles.css`:

```css
button:focus-visible,
input:focus-visible,
select:focus-visible {
  outline: 3px solid #173f9f;
  outline-offset: 3px;
}

input[aria-invalid="true"] {
  border-color: #8c1f2d;
  outline-color: rgba(140, 31, 45, 0.25);
}

.field-help {
  margin: 0;
  color: #66728a;
  font-size: 0.85rem;
}

.field-error {
  margin: 0;
  color: #8c1f2d;
  font-size: 0.9rem;
  font-weight: 700;
}

.filter-control {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  color: #536078;
  font-weight: 700;
}

@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    scroll-behavior: auto !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

# 41. Accessibility Verification Checklist

## Structure

- [ ] The page has a meaningful `h1`.
- [ ] Major sections use headings.
- [ ] The application uses semantic landmarks.
- [ ] The task list uses `ul` and `li`.

## Forms

- [ ] Every input has a label.
- [ ] Labels are associated correctly.
- [ ] Required fields are identified.
- [ ] Error messages explain how to recover.
- [ ] Invalid fields use `aria-invalid`.
- [ ] Help text uses `aria-describedby`.

## Keyboard

- [ ] All controls are reachable with Tab.
- [ ] Focus is visible.
- [ ] Buttons activate with Enter or Space.
- [ ] No positive `tabindex` values are used.
- [ ] Focus does not disappear after dynamic updates.

## Dynamic Updates

- [ ] Loading state is announced.
- [ ] Success state is announced.
- [ ] Error state is announced.
- [ ] Completed status is textual, not only visual.
- [ ] Empty states explain why content is absent.

## Visual Design

- [ ] Text contrast is sufficient.
- [ ] Focus contrast is sufficient.
- [ ] Color is not the only status signal.
- [ ] The page works when zoomed.
- [ ] The page works at narrow widths.
- [ ] Reduced-motion preferences are respected.

## Security and Semantics

- [ ] User text is rendered with `textContent`.
- [ ] Native buttons are used for actions.
- [ ] Links are used for navigation.
- [ ] ARIA is not used unnecessarily.
- [ ] Decorative content is hidden from assistive technologies.

---

# 42. Accessibility Definition of Done

The application should not be considered complete until a user can:

1. Load the page with a keyboard.
2. Find the task input.
3. Understand the input’s purpose.
4. Submit a valid task.
5. Understand validation errors.
6. Navigate to an existing task.
7. Understand whether it is completed.
8. Complete or reopen it.
9. Delete it intentionally.
10. Understand loading and failure messages.
11. Use the filter.
12. Navigate without losing focus.
13. Use the application at increased zoom.
14. Use the application without relying on color alone.

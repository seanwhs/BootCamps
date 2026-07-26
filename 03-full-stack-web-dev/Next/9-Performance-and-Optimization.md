# Part 9: Performance and Optimization

LaunchPad is now a secure, database-backed, multi-user application. Before optimizing it, we need to distinguish measurable improvements from changes that merely sound fast.

Performance work should follow this cycle:

```text
Measure
   ↓
Identify a bottleneck
   ↓
Make one deliberate change
   ↓
Measure again
   ↓
Keep, revise, or remove the change
```

In this part, we will improve both actual and perceived performance without compromising authorization or data freshness.

By the end of Part 9, LaunchPad will include:

- A repeatable performance baseline
- Optimized local images with `next/image`
- Intentional image sizing and loading priority
- Font and CSS verification
- Reduced Client Component boundaries
- On-demand code splitting for optional project insights
- Parallel server data loading
- Database query-plan inspection
- Private-data cache protections
- Static marketing and dynamic workspace verification
- Bundle analysis
- Lighthouse auditing
- Production performance checks

---

# Step 1: Establish a Production Performance Baseline

## The Target

Measure LaunchPad in production mode before changing its performance architecture.

## The Concept

Development mode is not suitable for performance measurement.

It performs additional work for:

- File watching
- Fast Refresh
- Detailed diagnostics
- Development source maps
- On-demand compilation

Measuring development mode is like timing a race car while mechanics are actively changing its tires.

We will establish a baseline from the optimized production build.

Important performance categories include:

- **Server response time:** How quickly the server begins returning a response.
- **Transfer size:** How many bytes cross the network.
- **JavaScript execution:** How much browser-side code must load and run.
- **Largest Contentful Paint:** When the main visible content appears.
- **Cumulative Layout Shift:** How much content unexpectedly moves.
- **Interaction to Next Paint:** How quickly the interface responds to user input.

## The Implementation

Reset the development database:

```bash
npm run db:start
npm run db:seed
```

Build the application:

```bash
npm run typecheck
npm run lint
npm run build
```

Start the production server:

```bash
npm run start
```

Open another terminal.

Measure the public home page:

```bash
curl --silent \
  --output /dev/null \
  --write-out $'Route: /\
\nStatus: %{http_code}\
\nDNS: %{time_namelookup}s\
\nConnect: %{time_connect}s\
\nFirst byte: %{time_starttransfer}s\
\nTotal: %{time_total}s\
\nDownloaded: %{size_download} bytes\
\n\n' \
  http://localhost:3000
```

Measure the public health API:

```bash
curl --silent \
  --output /dev/null \
  --write-out $'Route: /api/health\
\nStatus: %{http_code}\
\nFirst byte: %{time_starttransfer}s\
\nTotal: %{time_total}s\
\nDownloaded: %{size_download} bytes\
\n' \
  http://localhost:3000/api/health
```

### Create a reusable timing script

Create the scripts directory:

```bash
mkdir -p scripts
```

Create this file.

### `scripts/measure-routes.sh`

```bash
#!/usr/bin/env bash

set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:3000}"

PUBLIC_ROUTES=(
  "/"
  "/about"
  "/features"
  "/sign-in"
  "/api/health"
)

printf "LaunchPad public-route performance check\n"
printf "Base URL: %s\n\n" "${BASE_URL}"

for route in "${PUBLIC_ROUTES[@]}"; do
  curl \
    --silent \
    --show-error \
    --output /dev/null \
    --write-out \
      "route=${route} status=%{http_code} first_byte=%{time_starttransfer}s total=%{time_total}s bytes=%{size_download}\n" \
    "${BASE_URL}${route}"
done
```

Make it executable:

```bash
chmod +x scripts/measure-routes.sh
```

Run it:

```bash
./scripts/measure-routes.sh
```

Expected output resembles:

```text
LaunchPad public-route performance check
Base URL: http://localhost:3000

route=/ status=200 first_byte=0.012345s total=0.013456s bytes=...
route=/about status=200 first_byte=0.004321s total=0.005432s bytes=...
route=/features status=200 first_byte=0.004123s total=0.005123s bytes=...
route=/sign-in status=200 first_byte=0.010123s total=0.011234s bytes=...
route=/api/health status=200 first_byte=0.007123s total=0.007789s bytes=...
```

Your values will differ by hardware and operating system.

## The Verification

Run the script three times:

```bash
for run in 1 2 3; do
  echo "Run ${run}"
  ./scripts/measure-routes.sh
  echo
done
```

Do not interpret one unusually fast or slow request as a reliable trend.

Record the approximate values somewhere outside the application source or in a development note. We will rerun the same script after the optimizations.

Stop the production server:

```text
Ctrl+C
```

[GENERATED: Part 9, Step 1: Production Performance Baseline] [STARTING: Part 9, Step 2: Optimized Image Asset]

---

# Step 2: Create a Reproducible Local Image Asset

## The Target

Generate a local PNG image for the LaunchPad home page without depending on an external image service.

## The Concept

External tutorial images introduce avoidable failure points:

- The remote host may become unavailable.
- URLs may change.
- Privacy rules may prohibit the request.
- Image dimensions may become unpredictable.
- Next.js requires remote-host configuration.

We will generate a deterministic PNG with Python’s standard library.

A **deterministic asset** is created from fixed instructions and produces the same visual result every time.

The generated image will be committed as an application asset, while the script documents exactly how to recreate it.

## The Implementation

Create this generator.

### `scripts/generate-launchpad-image.py`

```python
#!/usr/bin/env python3

"""
Generate a dependency-free PNG illustration for the LaunchPad home page.

The script uses only Python's standard library. It writes raw RGB scanlines,
compresses them with zlib, and assembles the required PNG chunks.
"""

from __future__ import annotations

import binascii
import pathlib
import struct
import zlib

WIDTH = 1600
HEIGHT = 900

OUTPUT_PATH = (
    pathlib.Path(__file__).resolve().parent.parent
    / "public"
    / "launchpad-dashboard.png"
)


def png_chunk(chunk_type: bytes, data: bytes) -> bytes:
    """Create one valid PNG chunk with length and CRC fields."""

    checksum = binascii.crc32(chunk_type + data) & 0xFFFFFFFF

    return (
        struct.pack(">I", len(data))
        + chunk_type
        + data
        + struct.pack(">I", checksum)
    )


def blend(
    first: tuple[int, int, int],
    second: tuple[int, int, int],
    amount: float,
) -> tuple[int, int, int]:
    """Linearly blend two RGB colors."""

    return tuple(
        round(start + (end - start) * amount)
        for start, end in zip(first, second, strict=True)
    )


def inside_rounded_rectangle(
    x: int,
    y: int,
    left: int,
    top: int,
    right: int,
    bottom: int,
    radius: int,
) -> bool:
    """Return whether a point sits inside a rounded rectangle."""

    if left + radius <= x <= right - radius:
        return top <= y <= bottom

    if top + radius <= y <= bottom - radius:
        return left <= x <= right

    corners = (
        (left + radius, top + radius),
        (right - radius, top + radius),
        (left + radius, bottom - radius),
        (right - radius, bottom - radius),
    )

    return any(
        (x - center_x) ** 2 + (y - center_y) ** 2 <= radius**2
        for center_x, center_y in corners
    )


def pixel_color(x: int, y: int) -> tuple[int, int, int]:
    """Render the illustration one pixel at a time."""

    background_start = (35, 49, 91)
    background_end = (52, 87, 213)
    vertical_amount = y / max(HEIGHT - 1, 1)
    color = blend(background_start, background_end, vertical_amount)

    # Soft radial highlight near the upper-left corner.
    distance = ((x - 300) ** 2 + (y - 120) ** 2) ** 0.5
    highlight_amount = max(0.0, 1.0 - distance / 900) * 0.28
    color = blend(color, (164, 180, 255), highlight_amount)

    # Main dashboard surface.
    if inside_rounded_rectangle(
        x,
        y,
        150,
        110,
        1450,
        790,
        48,
    ):
        color = (247, 249, 253)

    # Sidebar.
    if inside_rounded_rectangle(
        x,
        y,
        190,
        155,
        470,
        745,
        30,
    ):
        color = (233, 237, 255)

    # Sidebar navigation rows.
    sidebar_rows = (
        (230, 250, 430, 305, (52, 87, 213)),
        (230, 330, 430, 385, (255, 255, 255)),
        (230, 410, 430, 465, (255, 255, 255)),
    )

    for left, top, right, bottom, row_color in sidebar_rows:
        if inside_rounded_rectangle(
            x,
            y,
            left,
            top,
            right,
            bottom,
            14,
        ):
            color = row_color

    # Dashboard statistic cards.
    statistic_cards = (
        (530, 185, 790, 355, (255, 255, 255)),
        (830, 185, 1090, 355, (255, 255, 255)),
        (1130, 185, 1390, 355, (255, 255, 255)),
    )

    for left, top, right, bottom, card_color in statistic_cards:
        if inside_rounded_rectangle(
            x,
            y,
            left,
            top,
            right,
            bottom,
            24,
        ):
            color = card_color

    # Project cards.
    project_cards = (
        (530, 405, 940, 700, (255, 255, 255)),
        (980, 405, 1390, 700, (255, 255, 255)),
    )

    for left, top, right, bottom, card_color in project_cards:
        if inside_rounded_rectangle(
            x,
            y,
            left,
            top,
            right,
            bottom,
            24,
        ):
            color = card_color

    # Progress bars.
    if inside_rounded_rectangle(
        x,
        y,
        570,
        625,
        900,
        650,
        12,
    ):
        color = (220, 226, 236)

    if inside_rounded_rectangle(
        x,
        y,
        570,
        625,
        760,
        650,
        12,
    ):
        color = (52, 87, 213)

    if inside_rounded_rectangle(
        x,
        y,
        1020,
        625,
        1350,
        650,
        12,
    ):
        color = (220, 226, 236)

    if inside_rounded_rectangle(
        x,
        y,
        1020,
        625,
        1140,
        650,
        12,
    ):
        color = (23, 107, 69)

    return color


def generate_png() -> bytes:
    """Return the complete PNG file."""

    raw_rows = bytearray()

    for y in range(HEIGHT):
        # Filter type zero means no per-row PNG filtering.
        raw_rows.append(0)

        for x in range(WIDTH):
            raw_rows.extend(pixel_color(x, y))

    header = struct.pack(
        ">IIBBBBB",
        WIDTH,
        HEIGHT,
        8,
        2,
        0,
        0,
        0,
    )

    return (
        b"\x89PNG\r\n\x1a\n"
        + png_chunk(b"IHDR", header)
        + png_chunk(
            b"IDAT",
            zlib.compress(bytes(raw_rows), level=9),
        )
        + png_chunk(b"IEND", b"")
    )


def main() -> None:
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_bytes(generate_png())

    print(
        f"Generated {OUTPUT_PATH} "
        f"({WIDTH}x{HEIGHT}, {OUTPUT_PATH.stat().st_size} bytes)"
    )


if __name__ == "__main__":
    main()
```

Generate the image:

```bash
python3 scripts/generate-launchpad-image.py
```

PowerShell with Python installed:

```powershell
python scripts/generate-launchpad-image.py
```

Expected output resembles:

```text
Generated .../public/launchpad-dashboard.png (1600x900, ... bytes)
```

## The Verification

Inspect the file:

```bash
file public/launchpad-dashboard.png
```

Expected output contains:

```text
PNG image data, 1600 x 900
```

If `file` is unavailable, use Python:

```bash
python3 -c "
from pathlib import Path
path = Path('public/launchpad-dashboard.png')
assert path.read_bytes().startswith(b'\x89PNG\r\n\x1a\n')
print(f'Valid PNG signature: {path.stat().st_size} bytes')
"
```

Open the image directly:

```text
http://localhost:3000/launchpad-dashboard.png
```

The browser should display a stylized blue project dashboard.

[GENERATED: Part 9, Step 2: Reproducible Image Asset] [STARTING: Part 9, Step 3: Next.js Image Optimization]

---

# Step 3: Add the Optimized Image to the Home Page

## The Target

Render the dashboard illustration with `next/image`, explicit dimensions, responsive sizing, and appropriate loading priority.

## The Concept

A normal image element works:

```html
<img src="/launchpad-dashboard.png" alt="..." />
```

Next.js’s `Image` component adds production-oriented behavior, including:

- Responsive image generation
- Appropriate output formats when supported
- Lazy loading by default
- Dimension-based layout stability
- Device-aware image sizes

Explicit dimensions help prevent **layout shift**. The browser reserves the correct aspect ratio before the image finishes loading.

The home-page illustration appears in the first major visible section, so we will mark it as high priority.

## The Implementation

Completely replace the marketing home page.

### `src/app/(marketing)/page.tsx`

```tsx
import Image from "next/image";
import Link from "next/link";

const plannedFeatures = [
  {
    title: "Organize projects",
    description:
      "Create focused project spaces with clear descriptions, statuses, and ownership.",
  },
  {
    title: "Track meaningful work",
    description:
      "Break projects into tasks, set priorities, and follow progress from one dashboard.",
  },
  {
    title: "Work securely",
    description:
      "Protect private data with server-side authentication, authorization, and validation.",
  },
] as const;

export default function HomePage() {
  return (
    <main className="site-shell">
      <section className="hero" aria-labelledby="hero-heading">
        <div className="hero__content">
          <p className="eyebrow">Built with Next.js 16</p>

          <h1 id="hero-heading">
            Turn ambitious ideas into organized work.
          </h1>

          <p className="hero-description">
            LaunchPad is a secure project and task management application.
            It combines a server-first architecture with focused browser
            interaction and production-oriented engineering practices.
          </p>

          <div className="hero-actions">
            <Link className="primary-link" href="/sign-up">
              Create an account
            </Link>

            <Link className="secondary-link" href="/about">
              Learn how it works
            </Link>
          </div>
        </div>

        <div className="hero__visual">
          <Image
            className="hero__image"
            src="/launchpad-dashboard.png"
            alt="Illustration of the LaunchPad dashboard with project statistics and progress cards"
            width={1600}
            height={900}
            sizes="(max-width: 56rem) calc(100vw - 2rem), 50vw"
            priority
          />
        </div>
      </section>

      <section
        className="feature-section"
        id="planned-features"
        aria-labelledby="features-heading"
      >
        <div className="section-heading">
          <p className="eyebrow">Production foundations</p>
          <h2 id="features-heading">
            Everything needed to move work forward
          </h2>
          <p>
            LaunchPad combines useful product behavior with deliberate
            security, performance, accessibility, and operational boundaries.
          </p>
        </div>

        <div className="feature-grid">
          {plannedFeatures.map((feature) => (
            <article className="feature-card" key={feature.title}>
              <h3>{feature.title}</h3>
              <p>{feature.description}</p>
            </article>
          ))}
        </div>
      </section>
    </main>
  );
}
```

Append these styles.

### `src/app/globals.css`

```css
/* Part 9: optimized home-page visual */

.hero {
  grid-template-columns:
    minmax(0, 0.9fr)
    minmax(22rem, 1.1fr);
  align-items: center;
  align-content: center;
  gap: clamp(var(--space-8), 6vw, var(--space-16));
}

.hero__content {
  min-width: 0;
}

.hero__visual {
  min-width: 0;
}

.hero__image {
  display: block;
  width: 100%;
  height: auto;
  border: 0.0625rem solid rgb(255 255 255 / 35%);
  border-radius: var(--radius-large);
  box-shadow: var(--shadow-raised);
}

@media (max-width: 56rem) {
  .hero {
    grid-template-columns: 1fr;
  }

  .hero__content {
    max-width: var(--reading-width);
  }
}
```

### Why `sizes` matters

This property tells the browser how much viewport width the image is expected to occupy:

```tsx
sizes="(max-width: 56rem) calc(100vw - 2rem), 50vw"
```

Without an accurate `sizes` value, the browser may download an unnecessarily large responsive candidate.

### Why `priority` is not used everywhere

Priority loading should be reserved for images likely to contribute to initial above-the-fold content.

Marking every image as high priority forces them to compete for network bandwidth.

## The Verification

Start the development server:

```bash
npm run dev
```

Open:

```text
http://localhost:3000
```

Confirm:

- The image appears beside the hero text on wide screens.
- The image moves below the text on narrow screens.
- The page does not jump when the image finishes loading.
- The image has meaningful alternative text.
- The image does not overflow the viewport.

Inspect the rendered image markup:

```bash
curl --silent http://localhost:3000 |
  grep -o 'srcset="[^"]*"' |
  head -n 1
```

The response should contain responsive image candidates.

Open browser developer tools and inspect the Network panel. The image request should use a URL resembling:

```text
/_next/image?url=...
```

Run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 9, Step 3: Next.js Image Optimization] [STARTING: Part 9, Step 4: Optional Feature Code Splitting]

---

# Step 4: Build an On-Demand Project Insights Module

## The Target

Create an optional interactive project-insights panel that is loaded only after the user requests it.

## The Concept

**Code splitting** divides browser JavaScript into smaller files, often called chunks.

Instead of sending every possible feature immediately:

```text
Initial page
├── Core interaction JavaScript
├── Optional chart JavaScript
├── Rare modal JavaScript
└── Administrative JavaScript
```

we can defer optional features:

```text
Initial page
└── Core interaction JavaScript

User selects "Load insights"
└── Download optional insights chunk
```

This reduces initial browser work.

The insights panel will be a Client Component because its display is controlled by browser state. It will receive only already-authorized, serializable project information.

## The Implementation

Create the optional panel.

### `src/components/project-insights.tsx`

```tsx
"use client";

import {
  calculateProjectProgress,
  type ProjectSummary,
} from "@/lib/project-types";

type ProjectInsightsProps = {
  project: ProjectSummary;
};

export default function ProjectInsights({
  project,
}: ProjectInsightsProps) {
  const progress = calculateProjectProgress(project);
  const remainingTasks =
    project.taskCount - project.completedTaskCount;

  let summary: string;

  if (project.taskCount === 0) {
    summary =
      "This project has no tasks yet. Add a task to begin measuring progress.";
  } else if (progress === 100) {
    summary =
      "Every tracked task is complete. The project is ready for final review.";
  } else if (progress >= 50) {
    summary =
      "More than half of the tracked work is complete. Keep the remaining tasks focused.";
  } else {
    summary =
      "Most tracked work remains. Review priorities and choose the next important task.";
  }

  return (
    <section
      className="project-insights"
      aria-labelledby="project-insights-heading"
    >
      <p className="eyebrow">On-demand analysis</p>
      <h2 id="project-insights-heading">Project insights</h2>
      <p>{summary}</p>

      <dl className="project-insights__metrics">
        <div>
          <dt>Completion</dt>
          <dd>{progress}%</dd>
        </div>

        <div>
          <dt>Remaining tasks</dt>
          <dd>{remainingTasks}</dd>
        </div>

        <div>
          <dt>Current status</dt>
          <dd>{project.status.toLowerCase()}</dd>
        </div>
      </dl>
    </section>
  );
}
```

Create the dynamic loader.

### `src/components/project-insights-loader.tsx`

```tsx
"use client";

import dynamic from "next/dynamic";
import { useState } from "react";

import type { ProjectSummary } from "@/lib/project-types";

const ProjectInsights = dynamic(
  () => import("@/components/project-insights"),
  {
    ssr: false,
    loading: () => (
      <div
        className="project-insights-loading"
        role="status"
        aria-live="polite"
      >
        Loading project insights…
      </div>
    ),
  },
);

type ProjectInsightsLoaderProps = {
  project: ProjectSummary;
};

export function ProjectInsightsLoader({
  project,
}: ProjectInsightsLoaderProps) {
  const [isVisible, setIsVisible] = useState(false);

  if (!isVisible) {
    return (
      <button
        className="secondary-button"
        type="button"
        onClick={() => {
          setIsVisible(true);
        }}
      >
        Load project insights
      </button>
    );
  }

  return <ProjectInsights project={project} />;
}
```

### Why `ssr: false` is used here

This optional feature is not necessary for the initial document and does not contain essential project content.

The authoritative project details remain server-rendered elsewhere on the page.

Do not disable server rendering for important headings, navigation, or content simply to demonstrate code splitting.

### Add the loader to the project page

In:

```text
src/app/(workspace)/projects/[projectId]/page.tsx
```

add this import:

```tsx
import { ProjectInsightsLoader } from "@/components/project-insights-loader";
```

Insert the following block after `project-disclosures` and before `project-tasks-section`:

```tsx
<section
  className="project-insights-section"
  aria-labelledby="optional-insights-heading"
>
  <div>
    <p className="eyebrow">Optional feature</p>
    <h2 id="optional-insights-heading">
      Load additional project analysis
    </h2>
    <p>
      This browser-only module is downloaded only when requested, keeping the
      initial project route focused on essential content.
    </p>
  </div>

  <ProjectInsightsLoader project={project} />
</section>
```

Append the styles.

### `src/app/globals.css`

```css
/* Part 9: dynamically loaded project insights */

.project-insights-section {
  display: grid;
  margin-block: var(--space-8);
  padding: var(--space-6);
  border: 0.0625rem solid var(--color-border);
  border-radius: var(--radius-large);
  background: var(--color-surface);
  grid-template-columns: minmax(0, 1fr) auto;
  align-items: center;
  gap: var(--space-6);
}

.project-insights-section h2,
.project-insights h2 {
  margin: 0;
  font-size: var(--font-size-heading-medium);
  line-height: var(--line-height-tight);
}

.project-insights-section > div > p:last-child,
.project-insights > p {
  max-width: var(--reading-width);
  margin: var(--space-3) 0 0;
  color: var(--color-text-muted);
}

.project-insights {
  margin-block: var(--space-6);
  padding: var(--space-6);
  border: 0.0625rem solid var(--color-primary);
  border-radius: var(--radius-large);
  background: var(--color-primary-soft);
}

.project-insights__metrics {
  display: grid;
  margin: var(--space-6) 0 0;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: var(--space-4);
}

.project-insights__metrics div {
  padding: var(--space-4);
  border-radius: var(--radius-medium);
  background: var(--color-surface);
}

.project-insights__metrics dt {
  color: var(--color-text-muted);
  font-size: var(--font-size-small);
  font-weight: 700;
}

.project-insights__metrics dd {
  margin: var(--space-2) 0 0;
  font-size: var(--font-size-heading-small);
  font-weight: 800;
  text-transform: capitalize;
}

.project-insights-loading {
  margin-block: var(--space-4);
  padding: var(--space-4);
  border-radius: var(--radius-medium);
  background: var(--color-surface-subtle);
  color: var(--color-text-muted);
}

@media (max-width: 48rem) {
  .project-insights-section {
    grid-template-columns: 1fr;
    align-items: start;
  }

  .project-insights__metrics {
    grid-template-columns: 1fr;
  }
}
```

## The Verification

Open a project:

```text
http://localhost:3000/projects/10000000-0000-4000-8000-000000000001
```

Confirm the initial page displays:

```text
Load project insights
```

Open browser developer tools:

1. Select the Network panel.
2. Filter requests by JavaScript.
3. Clear existing requests.
4. Select **Load project insights**.
5. Confirm a new JavaScript chunk is requested.
6. Confirm the insights panel appears.
7. Confirm the button works with keyboard activation.

Run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 9, Step 4: Optional Code Splitting] [STARTING: Part 9, Step 5: Parallel Server Data Loading]

---

# Step 5: Verify Parallel Server Data Loading

## The Target

Ensure independent project and task queries begin together rather than waiting on one another.

## The Concept

Sequential loading behaves like this:

```text
Start project query
      ↓ wait
Finish project query
      ↓
Start task query
      ↓ wait
Finish task query
```

Parallel loading behaves like this:

```text
Start project query ───────┐
                           ├── wait for both
Start task query ──────────┘
```

The project detail page already uses `Promise.all`, but we will make the intent explicit and verify there are no accidental sequential queries.

## The Implementation

In:

```text
src/app/(workspace)/projects/[projectId]/page.tsx
```

confirm the page’s primary data-loading block is exactly:

```tsx
const projectPromise = getProjectById(
  user.id,
  parsedProjectId.data,
);

const tasksPromise = getTasksForProject(
  user.id,
  parsedProjectId.data,
);

const [project, tasks] = await Promise.all([
  projectPromise,
  tasksPromise,
]);

if (!project) {
  notFound();
}
```

Replace the existing direct `Promise.all` block with this version if necessary.

The resulting behavior is the same, but the separate promise declarations make it visually clear that both operations start before either is awaited.

### Why metadata remains separate

`generateMetadata` also requests the project. The query function uses React’s `cache`, so identical project lookups during one rendering request can be deduplicated.

Tasks are not needed for metadata, so metadata should not query them.

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

Search for accidental sequential loading in the project page:

```bash
grep -n \
  'projectPromise\|tasksPromise\|Promise.all' \
  'src/app/(workspace)/projects/[projectId]/page.tsx'
```

Expected output contains all three declarations.

Open the project page and confirm all content remains correct.

[GENERATED: Part 9, Step 5: Parallel Server Loading] [STARTING: Part 9, Step 6: Database Query Plans]

---

# Step 6: Inspect Database Query Plans

## The Target

Use PostgreSQL’s query planner to verify that owner-scoped project and task queries can use the indexes created in earlier migrations.

## The Concept

Application code can be efficient while the database query remains slow.

PostgreSQL uses a **query plan** to decide how to retrieve rows.

Common plan operations include:

- **Sequential scan:** Inspect many or all table rows.
- **Index scan:** Use an index to locate matching rows.
- **Nested loop:** Combine related rows through repeated lookups.
- **Hash join:** Build a temporary hash structure to join datasets.

For tiny development tables, PostgreSQL may intentionally choose a sequential scan because reading four rows is cheaper than using an index. That does not mean the index is broken.

`EXPLAIN ANALYZE` both plans and executes a query, then reports actual timing.

## The Implementation

Inspect the owner-and-status query:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    EXPLAIN (
      ANALYZE,
      BUFFERS,
      FORMAT TEXT
    )
    SELECT
      p.id,
      p.name,
      p.status
    FROM projects AS p
    WHERE p.owner_id =
      '30000000-0000-4000-8000-000000000001'
      AND p.status = 'ACTIVE'
    ORDER BY p.updated_at DESC;
  "
```

Inspect the task lookup:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    EXPLAIN (
      ANALYZE,
      BUFFERS,
      FORMAT TEXT
    )
    SELECT
      t.id,
      t.title,
      t.status
    FROM tasks AS t
    INNER JOIN projects AS p
      ON p.id = t.project_id
    WHERE t.project_id =
      '10000000-0000-4000-8000-000000000001'
      AND p.owner_id =
      '30000000-0000-4000-8000-000000000001';
  "
```

List relevant indexes:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      tablename,
      indexname,
      indexdef
    FROM pg_indexes
    WHERE tablename IN ('projects', 'tasks', 'sessions')
    ORDER BY tablename, indexname;
  "
```

Expected indexes include:

```text
projects_owner_id_index
projects_owner_status_index
tasks_project_id_index
tasks_project_status_index
sessions_token_hash_unique_index
```

## The Verification

Confirm each plan reports:

```text
Planning Time
Execution Time
```

Do not attempt to optimize microsecond-scale development queries merely because a sequential scan appears.

A query becomes a performance concern when production evidence shows:

- High execution time
- High row counts
- Excessive buffers
- Frequent execution
- Lock contention
- Poor selectivity
- Repeated full-table scans on large tables

[GENERATED: Part 9, Step 6: Database Query Plans] [STARTING: Part 9, Step 7: Intentional Cache Policy]

---

# Step 7: Define Public and Private Cache Boundaries

## The Target

Make cache behavior explicit for public APIs and authenticated project APIs.

## The Concept

Caching can improve performance, but incorrect caching can expose private data.

These responses have different requirements:

### Public marketing page

The same content is suitable for every visitor and can be statically generated.

### Health response

It must describe the current service state and must not be reused as an old success result.

### Authenticated project API

Its response depends on a private session and user ownership. Shared caches must not reuse it for another user.

For private API responses, we will send:

```text
Cache-Control: private, no-store
```

- `private` prevents shared caches from treating the response as public.
- `no-store` instructs caches not to retain the response.

## The Implementation

Update the success helper so callers can supply headers safely.

Completely replace:

### `src/lib/api-response.ts`

```ts
import { NextResponse } from "next/server";
import type { ZodError } from "zod";

type ApiErrorCode =
  | "BAD_REQUEST"
  | "INVALID_JSON"
  | "VALIDATION_ERROR"
  | "UNAUTHORIZED"
  | "FORBIDDEN"
  | "NOT_FOUND"
  | "METHOD_NOT_ALLOWED"
  | "INTERNAL_ERROR"
  | "SERVICE_UNAVAILABLE";

export const PRIVATE_NO_STORE_HEADERS = {
  "Cache-Control": "private, no-store",
  Vary: "Cookie",
} as const;

export const PUBLIC_NO_STORE_HEADERS = {
  "Cache-Control": "no-store",
} as const;

export function apiSuccess<T>(
  data: T,
  init?: ResponseInit,
): NextResponse<{ data: T }> {
  return NextResponse.json(
    { data },
    init,
  );
}

export function apiError(
  status: number,
  code: ApiErrorCode,
  message: string,
  details?: unknown,
  headers?: HeadersInit,
): NextResponse {
  return NextResponse.json(
    {
      error: {
        code,
        message,
        ...(details === undefined ? {} : { details }),
      },
    },
    {
      status,
      headers,
    },
  );
}

export function zodErrorDetails(error: ZodError) {
  return error.issues.map((issue) => ({
    path: issue.path.join("."),
    message: issue.message,
  }));
}

export async function readJsonBody(
  request: Request,
): Promise<
  | { success: true; data: unknown }
  | { success: false; response: NextResponse }
> {
  const contentType = request.headers.get("content-type");

  if (!contentType?.toLowerCase().includes("application/json")) {
    return {
      success: false,
      response: apiError(
        400,
        "BAD_REQUEST",
        "Content-Type must be application/json.",
        undefined,
        PRIVATE_NO_STORE_HEADERS,
      ),
    };
  }

  try {
    return {
      success: true,
      data: await request.json(),
    };
  } catch {
    return {
      success: false,
      response: apiError(
        400,
        "INVALID_JSON",
        "The request body is not valid JSON.",
        undefined,
        PRIVATE_NO_STORE_HEADERS,
      ),
    };
  }
}
```

### Update the project collection API

In:

```text
src/app/api/projects/route.ts
```

add this import:

```ts
import { PRIVATE_NO_STORE_HEADERS } from "@/lib/api-response";
```

Merge it into the existing grouped import.

Add this route configuration near the imports:

```ts
export const dynamic = "force-dynamic";
```

Change the successful GET response from:

```ts
return apiSuccess(projects);
```

to:

```ts
return apiSuccess(projects, {
  headers: PRIVATE_NO_STORE_HEADERS,
});
```

Change the successful POST response headers to:

```ts
headers: {
  ...PRIVATE_NO_STORE_HEADERS,
  Location: `/api/projects/${project.id}`,
},
```

For every `apiError` in this private handler, pass:

```ts
PRIVATE_NO_STORE_HEADERS
```

as the final argument.

For example:

```ts
return apiError(
  401,
  "UNAUTHORIZED",
  "Authentication is required.",
  undefined,
  PRIVATE_NO_STORE_HEADERS,
);
```

Apply the same policy to:

```text
src/app/api/projects/[projectId]/route.ts
```

Add:

```ts
import { PRIVATE_NO_STORE_HEADERS } from "@/lib/api-response";

export const dynamic = "force-dynamic";
```

Successful item reads and updates should use:

```ts
return apiSuccess(project, {
  headers: PRIVATE_NO_STORE_HEADERS,
});
```

The `204` delete response should become:

```ts
return new Response(null, {
  status: 204,
  headers: PRIVATE_NO_STORE_HEADERS,
});
```

### Update the health endpoint

In:

```text
src/app/api/health/route.ts
```

import:

```ts
import { PUBLIC_NO_STORE_HEADERS } from "@/lib/api-response";
```

Change the success response to:

```ts
return apiSuccess(
  {
    status: "ok",
    database: "reachable",
    checkedAt,
  },
  {
    headers: PUBLIC_NO_STORE_HEADERS,
  },
);
```

Pass the same headers to the health error:

```ts
return apiError(
  503,
  "SERVICE_UNAVAILABLE",
  "A required application service is unavailable.",
  {
    status: "degraded",
    checkedAt,
  },
  PUBLIC_NO_STORE_HEADERS,
);
```

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

Start the development server and inspect health headers:

```bash
curl --silent \
  --dump-header - \
  --output /dev/null \
  http://localhost:3000/api/health
```

Expected output includes:

```text
Cache-Control: no-store
```

Inspect the anonymous private API response:

```bash
curl --silent \
  --dump-header - \
  --output /dev/null \
  http://localhost:3000/api/projects
```

Expected output includes:

```text
Cache-Control: private, no-store
Vary: Cookie
```

After signing in, repeat the authenticated request with the session cookie. The same private cache policy should remain.

[GENERATED: Part 9, Step 7: Intentional Cache Policy] [STARTING: Part 9, Step 8: Bundle Analyzer]

---

# Step 8: Add Production Bundle Analysis

## The Target

Configure an optional bundle analyzer that visualizes server and browser JavaScript composition.

## The Concept

A bundle analyzer answers questions such as:

- Which dependencies contribute the most JavaScript?
- Did a server-only package accidentally enter a browser chunk?
- Is an optional component split into its own chunk?
- Are several copies of the same library included?
- Did a small feature add a disproportionately large dependency?

We should analyze before adding aggressive memoization or removing useful features.

## The Implementation

Install the analyzer:

```bash
npm install --save-dev @next/bundle-analyzer
```

Completely replace the Next.js configuration.

### `next.config.ts`

```ts
import bundleAnalyzer from "@next/bundle-analyzer";
import type { NextConfig } from "next";

const withBundleAnalyzer = bundleAnalyzer({
  enabled: process.env.ANALYZE === "true",
});

const nextConfig: NextConfig = {
  /**
   * Keep the production identifier out of response headers. This removes an
   * unnecessary framework-identification detail.
   */
  poweredByHeader: false,

  /**
   * Compress eligible responses when Next.js serves the application
   * directly. Some hosting platforms apply compression at their edge layer.
   */
  compress: true,

  images: {
    /**
     * Modern browsers generally prefer AVIF or WebP. Next.js negotiates a
     * supported format from the request's Accept header.
     */
    formats: [
      "image/avif",
      "image/webp",
    ],

    /**
     * These widths cover the responsive layouts used by LaunchPad without
     * creating an unnecessarily broad candidate set.
     */
    deviceSizes: [
      640,
      750,
      828,
      1080,
      1200,
      1600,
    ],
  },
};

export default withBundleAnalyzer(nextConfig);
```

Add an analysis script to `package.json`:

```json
"analyze": "ANALYZE=true next build"
```

The complete scripts object should retain all existing scripts and add:

```json
"analyze": "ANALYZE=true next build"
```

### Windows PowerShell

PowerShell users can run analysis without the npm script:

```powershell
$env:ANALYZE = "true"
npm run build
Remove-Item Env:ANALYZE
```

## The Verification

Run the ordinary build first:

```bash
npm run typecheck
npm run lint
npm run build
```

Then run bundle analysis:

```bash
npm run analyze
```

The analyzer should generate and usually open reports for browser and server bundles. Depending on the package version and environment, generated reports may be placed under `.next/analyze`.

Inspect the browser report and confirm:

- `postgres` is not in a client bundle.
- `bcryptjs` is not in a client bundle.
- Database query modules are not in a client bundle.
- `project-insights` appears as an optional chunk rather than core page code.
- No unexpected large client dependency dominates the bundle.

Generated `.next` artifacts remain ignored by Git.

[GENERATED: Part 9, Step 8: Bundle Analysis] [STARTING: Part 9, Step 9: Client JavaScript Audit]

---

# Step 9: Audit Client Component Boundaries

## The Target

Inventory every Client Component and verify that each one requires browser behavior.

## The Concept

A Client Component is not inherently bad. Unnecessary Client Components are the problem.

Every client boundary has potential costs:

- Browser JavaScript transfer
- Parsing
- Execution
- Hydration
- Memory
- Dependency expansion

A component should be client-side because it needs capabilities such as:

- State
- Effects
- Event handlers
- Browser APIs
- Client router hooks

It should not become client-side merely because it contains CSS or renders a button submitted through a normal form.

## The Implementation

List all client entry points:

```bash
grep -R -l \
  '"use client"' \
  src \
  --include="*.tsx" |
  sort
```

Expected files include:

```text
src/app/(workspace)/error.tsx
src/components/copy-project-link.tsx
src/components/create-project-form.tsx
src/components/create-task-form.tsx
src/components/interactive-disclosure.tsx
src/components/project-insights-loader.tsx
src/components/project-insights.tsx
src/components/project-list.tsx
src/components/sign-in-form.tsx
src/components/sign-up-form.tsx
src/components/workspace-navigation.tsx
```

Review their reasons:

| Component | Client-side reason |
|---|---|
| Workspace error boundary | `reset`, effect logging |
| Copy project link | Clipboard and `window` |
| Create forms | `useActionState`, pending UI |
| Disclosure | Local open state |
| Insights loader | On-demand visibility state |
| Insights panel | Dynamically loaded browser module |
| Project list | Immediate search state |
| Auth forms | `useActionState`, pending UI |
| Workspace navigation | `usePathname` |

Confirm visual components remain server-compatible:

```bash
for file in \
  src/components/project-card.tsx \
  src/components/status-badge.tsx \
  src/components/task-list.tsx \
  src/components/site-header.tsx \
  src/components/site-footer.tsx \
  src/components/account-menu.tsx
do
  if grep --quiet '"use client"' "${file}"; then
    echo "Unexpected client directive: ${file}"
    exit 1
  fi
done

echo "Static visual components remain server-compatible."
```

## The Verification

Confirm Client Components do not import server infrastructure:

```bash
for file in $(grep -R -l '"use client"' src --include="*.tsx"); do
  if grep -E \
    'database/|auth/session|server-only|environment' \
    "${file}"; then
    echo "Unsafe server import in ${file}"
    exit 1
  fi
done

echo "Client components do not import server infrastructure."
```

Expected output:

```text
Client components do not import server infrastructure.
```

Run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 9, Step 9: Client JavaScript Audit] [STARTING: Part 9, Step 10: Rendering Strategy Verification]

---

# Step 10: Verify Static and Dynamic Rendering Strategies

## The Target

Confirm that public marketing content can be statically optimized while authenticated workspace routes remain request-aware.

## The Concept

A static route can be prepared and reused because its content is the same for every visitor.

A private workspace route depends on:

- A session cookie
- An authenticated user
- User-owned database rows

It must not be converted into globally shared static output.

The desired architecture is:

```text
Public marketing routes
└── Static where possible

Authentication routes
└── Request-aware because they inspect sessions

Workspace routes
└── Dynamic because they inspect sessions and private data

Health endpoint
└── Dynamic and uncached

Project APIs
└── Dynamic, authenticated, private, and no-store
```

## The Implementation

No new source files are required.

Create a production build:

```bash
npm run build
```

Inspect the route table printed by Next.js.

The exact symbols can vary by Next.js patch release. Look for the distinction between prerendered/static and dynamic routes.

Public routes should include:

```text
/
/about
/features
```

Request-aware routes should include:

```text
/sign-in
/sign-up
/dashboard
/projects
/projects/[projectId]
/api/health
/api/projects
/api/projects/[projectId]
```

### Verify private routes do not render user data anonymously

Start the production server:

```bash
npm run start
```

Request the dashboard without a session:

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code} %{redirect_url}\n" \
  http://localhost:3000/dashboard
```

The response must redirect to:

```text
/sign-in
```

Request the private API without a session:

```bash
curl --silent \
  --dump-header - \
  --output /dev/null \
  http://localhost:3000/api/projects
```

Expected properties:

```text
401
Cache-Control: private, no-store
Vary: Cookie
```

## The Verification

Inspect the public home response twice:

```bash
curl --silent \
  --output /dev/null \
  --write-out "first=%{time_total}s\n" \
  http://localhost:3000

curl --silent \
  --output /dev/null \
  --write-out "second=%{time_total}s\n" \
  http://localhost:3000
```

The exact times are not guaranteed, but both responses should succeed without database authentication.

Stop the production server:

```text
Ctrl+C
```

[GENERATED: Part 9, Step 10: Rendering Strategy Verification] [STARTING: Part 9, Step 11: Lighthouse Audit]

---

# Step 11: Run a Lighthouse Production Audit

## The Target

Audit the public application for performance, accessibility, best practices, and search-engine fundamentals.

## The Concept

Lighthouse runs automated browser checks and reports scores and diagnostics.

It can identify issues such as:

- Render-blocking resources
- Large JavaScript bundles
- Unsized images
- Layout shifts
- Missing accessible names
- Poor color contrast
- Incorrect metadata

Lighthouse is useful, but it is not a complete measure of real user experience.

Its result depends on:

- Hardware
- Browser version
- Background processes
- Network simulation
- Route content
- Authentication state

Use it as one signal rather than a target to game.

## The Implementation

Build and start production mode:

```bash
npm run build
npm run start
```

Open Chrome or Chromium.

Navigate to:

```text
http://localhost:3000
```

Then:

1. Open developer tools.
2. Select **Lighthouse**.
3. Choose **Navigation** mode.
4. Select:
   - Performance
   - Accessibility
   - Best Practices
   - SEO
5. Select **Mobile**.
6. Run the analysis.
7. Save the report outside the repository if desired.

Repeat for:

```text
http://localhost:3000/sign-in
```

For authenticated routes, sign in and run Lighthouse through the browser session.

### Optional command-line Lighthouse

If Chrome is installed, run:

```bash
npx --yes lighthouse \
  http://localhost:3000 \
  --only-categories=performance,accessibility,best-practices,seo \
  --output=html \
  --output-path=/tmp/launchpad-lighthouse.html \
  --chrome-flags="--headless"
```

Open:

```text
/tmp/launchpad-lighthouse.html
```

The command downloads a temporary Lighthouse package through `npx --yes`; it does not add the package to `package.json`.

## The Verification

Inspect the report for:

- Largest Contentful Paint
- Cumulative Layout Shift
- Total Blocking Time
- Image sizing
- JavaScript usage
- Font loading
- Color contrast
- Form labels
- Link names
- Page titles
- Metadata

Do not require a universal score of `100`. Local and CI scores vary.

Instead, confirm there are no serious regressions such as:

- A missing image size
- A large layout shift
- An inaccessible form control
- Server packages in client JavaScript
- Multi-megabyte unnecessary scripts
- Missing route titles

[GENERATED: Part 9, Step 11: Lighthouse Audit] [STARTING: Part 9, Step 12: Production Performance Recheck]

---

# Step 12: Recheck Production Performance

## The Target

Run the original timing script and verify that the optimized application remains responsive and correct.

## The Concept

Optimization is not complete until we measure after the changes.

Some changes improve one dimension while increasing another:

- An image improves communication but adds network bytes.
- A dynamic feature improves capability but adds optional JavaScript.
- Strong no-store policies reduce cache reuse but protect private data.
- Server rendering reduces client work but uses server resources.

The correct goal is not the smallest possible application. It is an application that delivers its required behavior efficiently and safely.

## The Implementation

Ensure the production server is running:

```bash
npm run start
```

Run the original script three times:

```bash
for run in 1 2 3; do
  echo "Optimized run ${run}"
  ./scripts/measure-routes.sh
  echo
done
```

Inspect home-page headers:

```bash
curl --silent \
  --compressed \
  --dump-header - \
  --output /dev/null \
  http://localhost:3000
```

Because compression negotiation depends on the server and client headers, `curl --compressed` requests a supported compressed response.

Inspect the optimized image:

```bash
curl --silent \
  --header "Accept: image/avif,image/webp,image/*" \
  --output /dev/null \
  --write-out $'Status: %{http_code}\
\nContent-Type: %{content_type}\
\nDownloaded: %{size_download} bytes\
\n' \
  "http://localhost:3000/_next/image?url=%2Flaunchpad-dashboard.png&w=1080&q=75"
```

Expected output should report a successful image response and an optimized image content type supported by the local Next.js image pipeline.

## The Verification

Confirm all of the following:

- Public routes still return `200`.
- Protected routes still redirect without a session.
- Private APIs still return `401` anonymously.
- Private APIs use `private, no-store`.
- The health endpoint uses `no-store`.
- The home image does not shift surrounding layout.
- Optional insights load only after interaction.
- Client-side project search remains responsive.
- Database-backed routes remain owner-scoped.
- No security behavior was weakened for caching.

Stop the production server:

```text
Ctrl+C
```

[GENERATED: Part 9, Step 12: Production Performance Recheck] [STARTING: Part 9, Step 13: Complete Quality Gate]

---

# Step 13: Run the Complete Part 9 Quality Gate

## The Target

Verify source correctness, database availability, production compilation, security behavior, static assets, and route responses together.

## The Concept

A performance change is a regression if it makes the application:

- Incorrect
- Inaccessible
- Insecure
- Unbuildable
- Operationally unreliable

Performance is one quality attribute among several.

## The Implementation

Reset the database:

```bash
npm run db:start
npm run db:seed
```

Run source checks:

```bash
npm run typecheck
npm run lint
```

Run the production build:

```bash
npm run build
```

Start the server:

```bash
npm run start
```

In another terminal, verify public routes:

```bash
for path in \
  "/" \
  "/about" \
  "/features" \
  "/sign-in" \
  "/sign-up" \
  "/api/health"
do
  status_code="$(
    curl --silent \
      --output /dev/null \
      --write-out "%{http_code}" \
      "http://localhost:3000${path}"
  )"

  printf "%-30s %s\n" "${path}" "${status_code}"
done
```

Every route should return:

```text
200
```

Verify anonymous private API behavior:

```bash
curl --silent \
  --dump-header /tmp/launchpad-api-headers.txt \
  --output /tmp/launchpad-api-body.json \
  http://localhost:3000/api/projects

cat /tmp/launchpad-api-headers.txt
python -m json.tool /tmp/launchpad-api-body.json
```

Expected behavior:

- Status `401`
- Error code `UNAUTHORIZED`
- `Cache-Control: private, no-store`
- `Vary: Cookie`

Verify the generated image asset:

```bash
curl --fail --silent \
  --output /dev/null \
  http://localhost:3000/launchpad-dashboard.png

echo "Local image asset is reachable."
```

Verify responsive optimization:

```bash
curl --fail --silent \
  --output /dev/null \
  "http://localhost:3000/_next/image?url=%2Flaunchpad-dashboard.png&w=750&q=75"

echo "Next.js image optimization endpoint succeeded."
```

## The Verification

Complete these browser checks:

1. Open the home page.
2. Verify the responsive hero image.
3. Sign in.
4. Verify dashboard streaming.
5. Open a project.
6. Load optional project insights.
7. Confirm an additional chunk loads.
8. Use project search.
9. Create and update a task.
10. Sign out.
11. Confirm private pages become inaccessible.

Stop the production server:

```text
Ctrl+C
```

[GENERATED: Part 9, Step 13: Complete Quality Gate] [STARTING: Part 9, Step 14: Git Checkpoint]

---

# Step 14: Create the Part 9 Git Checkpoint

## The Target

Commit the image, code-splitting, cache-policy, bundle-analysis, and performance-verification work.

## The Concept

This commit should capture measured and intentional optimization rather than arbitrary micro-optimizations.

It includes:

- Reproducible image generation
- Generated local image asset
- `next/image`
- Optional dynamic import
- Explicit parallel query starts
- Private API cache policy
- Health no-store policy
- Bundle analyzer
- Route measurement script
- Responsive performance styles

## The Implementation

Inspect the repository:

```bash
git status
git diff --stat
git diff
```

Run the final quality gate:

```bash
npm run typecheck
npm run lint
npm run build
```

Stage the changes:

```bash
git add \
  next.config.ts \
  package.json \
  package-lock.json \
  public/launchpad-dashboard.png \
  scripts \
  src
```

Inspect staged files:

```bash
git diff --cached --stat
git status --short
```

Create the commit:

```bash
git commit -m "perf: optimize assets rendering and client bundles"
```

## The Verification

Inspect the latest commit:

```bash
git log -1 --oneline
```

Expected output resembles:

```text
f6a7b8c perf: optimize assets rendering and client bundles
```

Confirm a clean working tree:

```bash
git status
```

Expected output:

```text
nothing to commit, working tree clean
```

[GENERATED: Part 9, Step 14: Git Checkpoint] [STARTING: Part 9 Reference Sections]

---

# Part 9 Reference A: Core Web Vitals

Core Web Vitals are user-centered performance measurements.

## Largest Contentful Paint

**Largest Contentful Paint**, or LCP, measures when the largest major visible content element finishes rendering.

Common causes of poor LCP include:

- Slow server response
- Large unoptimized images
- Render-blocking resources
- Client-only initial data fetching
- Slow font delivery

LaunchPad addresses these with:

- Server rendering
- Static public routes
- `next/image`
- `next/font`
- Focused Client Components

## Cumulative Layout Shift

**Cumulative Layout Shift**, or CLS, measures unexpected visual movement.

Common causes include:

- Images without dimensions
- Late font changes
- Dynamically inserted content above existing content
- Advertisements without reserved space

LaunchPad provides image dimensions:

```tsx
<Image
  width={1600}
  height={900}
/>
```

## Interaction to Next Paint

**Interaction to Next Paint**, or INP, measures how quickly the page visually responds to interaction.

Common causes of poor INP include:

- Large client bundles
- Expensive event handlers
- Long JavaScript tasks
- Excessive rerendering
- Heavy third-party scripts

LaunchPad keeps most rendering server-side and limits interactive JavaScript to focused components.

---

# Part 9 Reference B: `next/image`

A basic optimized image:

```tsx
import Image from "next/image";

<Image
  src="/example.png"
  alt="Description of meaningful image content"
  width={1200}
  height={800}
  sizes="(max-width: 48rem) 100vw, 50vw"
/>
```

## Meaningful images

Use descriptive alternative text:

```tsx
alt="Project dashboard showing task progress"
```

## Decorative images

Use an empty alternative:

```tsx
alt=""
```

Do not repeat nearby text unnecessarily.

## Priority

Use high-priority loading only for likely initial viewport content.

Do not mark large below-the-fold galleries as priority.

## `sizes`

The `sizes` property should reflect actual CSS layout. An inaccurate value can make the browser download images larger than necessary.

---

# Part 9 Reference C: Code Splitting

Next.js automatically splits code by route.

Dynamic imports add another boundary:

```tsx
const HeavyComponent = dynamic(
  () => import("./heavy-component"),
);
```

Good candidates include:

- Rich editors
- Large charts
- Map libraries
- Optional modals
- Administrative tools
- Rarely used analysis panels

Poor candidates include:

- Primary page headings
- Essential navigation
- Small components
- Critical form controls
- Content required for search or accessibility

Code splitting has overhead. Too many tiny chunks can create excessive requests and complexity.

---

# Part 9 Reference D: `ssr: false`

This configuration:

```tsx
dynamic(
  () => import("./browser-feature"),
  {
    ssr: false,
  },
);
```

prevents the dynamically imported component from rendering on the server.

Use it when the module:

- Requires browser-only globals during initialization
- Is genuinely optional
- Does not contain critical initial content
- Cannot safely render on the server

Do not use `ssr: false` as a universal fix for hydration errors. Correct the underlying unstable render whenever possible.

---

# Part 9 Reference E: Caching and Private Data

Private data requires conservative caching.

Dangerous architecture:

```text
Cache key: /api/projects
Cached value: User A's projects
Next caller: User B
```

If identity is not part of the cache boundary, private data may leak.

LaunchPad currently uses:

```text
Cache-Control: private, no-store
Vary: Cookie
```

for authenticated project APIs.

Workspace pages derive identity from cookies and query by owner. We do not apply a globally shared persistent cache to those query results.

Future private caching must answer:

- Is user identity part of the key?
- Can two users ever share this result?
- Which mutation invalidates it?
- How long may it remain stale?
- What happens after ownership changes?
- What happens after sign-out?

---

# Part 9 Reference F: Request Memoization

The project lookup is wrapped with React’s `cache`:

```ts
export const getProjectById = cache(
  async (userId: string, projectId: string) => {
    // Query database.
  },
);
```

This can deduplicate identical work during one server rendering request.

Its key includes both:

```text
userId
projectId
```

That is essential. Caching only by project ID while authorization varies by user would create an unsafe abstraction.

Request memoization is not the same as a long-lived shared cache.

---

# Part 9 Reference G: Parallel Data Fetching

Sequential:

```tsx
const project = await getProject();
const tasks = await getTasks();
```

Parallel:

```tsx
const projectPromise = getProject();
const tasksPromise = getTasks();

const [project, tasks] = await Promise.all([
  projectPromise,
  tasksPromise,
]);
```

Use parallel loading only when operations are independent.

If the second query needs the first result, sequential loading is correct:

```tsx
const project = await getProject();

const tasks = await getTasks(project.id);
```

Do not force logical dependencies into artificial parallelism.

---

# Part 9 Reference H: Streaming Versus Parallel Loading

Parallel loading and streaming solve different problems.

## Parallel loading

Reduces total waiting time by starting independent work together.

## Streaming

Allows completed interface sections to reach the browser before all sections finish.

They can be combined:

```text
Start metrics query
Start active projects query
        ↓
Stream each section as it completes
```

LaunchPad’s dashboard uses separate Suspense boundaries around independent async Server Components.

---

# Part 9 Reference I: Database Performance

Database optimization should be evidence-based.

Useful tools include:

```sql
EXPLAIN
EXPLAIN ANALYZE
EXPLAIN (ANALYZE, BUFFERS)
```

Investigate:

- Rows scanned versus rows returned
- Execution time
- Buffer reads
- Join strategy
- Sort operations
- Index usage
- Lock waits
- Query frequency

An index improves reads but has costs:

- Additional storage
- Slower inserts
- Slower updates
- Maintenance overhead

Do not add indexes for every column automatically.

---

# Part 9 Reference J: Bundle Analysis

A bundle report helps detect:

- Large dependencies
- Duplicate dependencies
- Unexpected client code
- Server packages entering browser bundles
- Optional features bundled eagerly

Important LaunchPad checks include:

```text
postgres must remain server-side
bcryptjs must remain server-side
environment validation must remain server-side
session storage must remain server-side
```

Bundle size alone does not measure runtime cost perfectly. A small script can perform expensive work, while a larger declarative dataset may execute cheaply.

Use bundle analysis together with browser profiling.

---

# Part 9 Reference K: Memoization

Memoization remembers a calculation result.

React provides tools such as:

- `cache`
- `useMemo`
- `useCallback`
- Component memoization

Do not apply them indiscriminately.

Memoization has costs:

- Dependency tracking
- Memory
- More complex code
- Stale-value risks
- Debugging difficulty

Use it when:

- Measurement identifies repeated expensive work
- Stable identity is required
- Request-level query deduplication is useful
- A child’s rerenders are demonstrably expensive

LaunchPad uses `useMemo` for project searching and `cache` for request-level project and session lookup.

---

# Part 9 Reference L: Prefetching

Next.js `Link` can prefetch route resources when appropriate.

```tsx
<Link href="/projects">
  Projects
</Link>
```

Prefetching can improve perceived navigation speed, but it also consumes network and server resources.

For links that are unlikely to be used or expensive to prepare, prefetching may be disabled:

```tsx
<Link href="/rare-route" prefetch={false}>
  Rare route
</Link>
```

Do not disable prefetching globally without measurement.

Private routes still perform authentication and authorization when requested. Prefetching must never bypass those server checks.

---

# Part 9 Reference M: Performance and Accessibility

Performance and accessibility often reinforce each other.

Examples include:

- Server-rendered content reaches users sooner.
- Smaller client bundles reduce input delay.
- Stable image dimensions reduce disorientation.
- Reduced motion avoids discomfort.
- Visible loading states communicate progress.
- Semantic HTML reduces the need for heavy custom widgets.

An optimization that removes labels, feedback, or keyboard behavior is not an acceptable improvement.

---

# Part 9 Reference N: Performance and Security

Performance must not weaken security.

Unsafe “optimizations” include:

- Globally caching private user data
- Removing authorization checks to reduce query time
- Sending all records to the browser for local filtering
- Storing session data in readable browser storage
- Caching health success indefinitely
- Exposing secrets to avoid a server request

Secure boundaries are requirements, not optional overhead.

Optimize within those boundaries.

---

# Part 9 Reference O: Current Performance Architecture

LaunchPad now uses:

```text
Public marketing routes
├── Server Components
├── Static optimization where possible
├── next/font
└── next/image

Authenticated workspace
├── Dynamic server rendering
├── Owner-scoped PostgreSQL queries
├── Parallel project and task loading
├── Suspense dashboard streaming
└── Request-level memoization

Browser JavaScript
├── Active navigation
├── Local project search
├── Form pending feedback
├── Disclosure controls
├── Clipboard control
└── On-demand project insights

Private APIs
├── Authentication
├── Owner-scoped queries
├── Cache-Control: private, no-store
└── Vary: Cookie
```

---

# Part 9 Reference P: Common Performance Mistakes

## Mistake 1: Measuring development mode

Development mode includes debugging and compilation overhead.

## Mistake 2: Optimizing without a baseline

Without measurements, you cannot reliably identify improvement.

## Mistake 3: Marking the whole application `"use client"`

That expands browser JavaScript and moves work away from the server.

## Mistake 4: Using `priority` on every image

Priority resources compete with genuinely critical resources.

## Mistake 5: Omitting image sizes

That can produce layout shifts.

## Mistake 6: Globally caching authenticated data

That can expose one user’s information to another.

## Mistake 7: Adding `useMemo` everywhere

Memoization adds complexity and can provide no measurable benefit.

## Mistake 8: Dynamically importing tiny essential components

Code splitting has request and coordination overhead.

## Mistake 9: Adding indexes without query evidence

Indexes slow writes and consume storage.

## Mistake 10: Treating Lighthouse as the only source of truth

Synthetic tests do not replace real-user monitoring.

## Mistake 11: Removing loading feedback to appear faster

A blank interface often feels slower than a stable loading state.

## Mistake 12: Sacrificing correctness or security

A fast data leak is still a data leak.

---

# Part 9 Completion Checklist

Before continuing, confirm every item:

- [ ] Production timing was measured before optimization.
- [ ] The measurement script runs successfully.
- [ ] The dashboard image can be generated reproducibly.
- [ ] The generated image has valid PNG dimensions.
- [ ] The home page uses `next/image`.
- [ ] The image has meaningful alternative text.
- [ ] The image declares width and height.
- [ ] The image uses an accurate responsive `sizes` value.
- [ ] Only the above-the-fold hero image uses priority.
- [ ] The home page remains responsive.
- [ ] The image does not produce visible layout shift.
- [ ] Optional project insights use a dynamic import.
- [ ] The optional insights chunk loads after interaction.
- [ ] Essential project content remains server-rendered.
- [ ] Project and task queries start in parallel.
- [ ] Metadata does not fetch unnecessary task data.
- [ ] PostgreSQL query plans were inspected.
- [ ] Ownership indexes exist.
- [ ] Session-token indexes exist.
- [ ] Private APIs use `Cache-Control: private, no-store`.
- [ ] Private APIs include `Vary: Cookie`.
- [ ] The health endpoint uses `Cache-Control: no-store`.
- [ ] Private routes remain dynamic and request-aware.
- [ ] Public marketing routes remain statically optimizable.
- [ ] The bundle analyzer runs successfully.
- [ ] PostgreSQL code does not enter client bundles.
- [ ] Password-hashing code does not enter client bundles.
- [ ] Every Client Component has a browser-side responsibility.
- [ ] Static visual components remain server-compatible.
- [ ] Lighthouse was run against production mode.
- [ ] Serious accessibility or layout-shift findings were addressed.
- [ ] Production timing was measured after optimization.
- [ ] Authentication remains enforced after optimization.
- [ ] Authorization remains owner-scoped after optimization.
- [ ] `npm run typecheck` succeeds.
- [ ] `npm run lint` succeeds.
- [ ] `npm run build` succeeds.
- [ ] Public production routes return `200`.
- [ ] Anonymous private API requests return `401`.
- [ ] Next.js image optimization succeeds.
- [ ] Git contains the Part 9 checkpoint.
- [ ] `git status` reports a clean working tree.

LaunchPad now applies performance optimization as an engineering discipline rather than a collection of tricks. Public content is statically optimized where appropriate, private content remains request-aware and owner-scoped, images and fonts use Next.js’s built-in pipeline, independent data loads in parallel, and optional browser features are split from the essential route bundle.

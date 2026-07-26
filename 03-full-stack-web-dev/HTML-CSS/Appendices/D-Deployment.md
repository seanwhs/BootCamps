# Appendix D: Deployment Deep Dive

### Why This Appendix Exists

Throughout this series, "verification" has meant Live Server on your own machine. That's the right tool for building — but it's not the internet. This appendix walks through **actually publishing your capstone portfolio** so it has a real, public URL you can put on a resume, share in a message, or hand to an employer. We'll cover three levels: the simplest possible option (GitHub Pages), a slightly more powerful option with extra developer conveniences (Netlify), and finally attaching a custom domain name to either one.

We'll use your **Part 9 capstone (`my-portfolio/`)** as the running example, since it's the project you'd realistically want to actually publish.

---

## D.1 — A Quick Mental Model: What Does "Deploying" Actually Mean?

**The Concept:** Your project currently lives only on your own hard drive. When you open it with Live Server, your own computer is temporarily acting as a tiny web server — a program that listens for requests and responds by sending back your files — but only reachable by you, on your own machine (`127.0.0.1`, also called `localhost`, literally means "this same computer").

**Deploying** means copying your files onto a computer that is *always on* and *connected to the public internet*, running that same kind of web server software permanently, with a real public address instead of `127.0.0.1`. Analogy: Live Server is like rehearsing a play in your living room — real, functional, but only visible to people physically in the room. Deploying is opening on an actual stage where anyone with a ticket (a URL) can walk in and watch, at any hour, from anywhere.

The good news: **GitHub Pages and Netlify do all of that server-hosting work for you, for free**, for a static site like this one (a "static site" means plain HTML/CSS/images with no server-side processing — exactly what you've built this entire series).

---

## D.2 — Prerequisite: Getting Git and GitHub Set Up

**The Target:** A GitHub account and Git installed on your machine, if you don't have them already.

**The Concept:** **Git** is version control software — think of it as an extremely powerful "track changes" system for your entire project folder, letting you save snapshots of your work over time. **GitHub** is a website that hosts copies of Git projects online, and — conveniently for us — can also serve those files directly as a live website via a feature called **GitHub Pages**. You don't need to become a Git expert for this appendix; we'll use just enough commands to get your files published.

**The Implementation:**

1. Create a free account at [github.com](https://github.com/) if you haven't already.
2. Install Git from [git-scm.com](https://git-scm.com/downloads) (Windows/Mac/Linux installers available).
3. Open a terminal (on Windows, "Git Bash," installed alongside Git, is the friendliest option; on Mac, the built-in Terminal app works fine) and confirm Git installed correctly:

```bash
git --version
```

**The Verification:**

You should see output like `git version 2.42.0` (exact number may vary). If you instead see "command not found," reinstall Git and restart your terminal/computer before continuing.

---

## D.3 — Deploying via GitHub Pages

**The Target:** A live URL in the form `https://yourusername.github.io/my-portfolio/` serving your capstone project.

**The Concept:** GitHub Pages watches a specific folder (called a **repository**, or "repo" for short — essentially a project folder that Git is tracking) and automatically republishes it as a live website every time you upload new changes. It's genuinely free, requires no credit card, and is the standard first deployment method for exactly this kind of project.

**The Implementation:**

**Step 1 — Create the repository on GitHub:**

1. Log into GitHub, click the **+** icon in the top-right corner → **New repository**.
2. Name it `my-portfolio`.
3. Leave it **Public** (required for free GitHub Pages hosting).
4. **Do not** check "Add a README file" — we'll be uploading an existing folder, and starting with an empty repo avoids a merge conflict in the next step.
5. Click **Create repository**.

**Step 2 — Connect your local folder to GitHub and upload it:**

Open your terminal, navigate into your project folder, and run these commands one at a time:

```bash
cd build-as-you-learn/my-portfolio
```

```bash
git init
```
*(This turns the current folder into a Git-tracked project — like officially opening a "track changes" log for it.)*

```bash
git add .
```
*(This stages every file in the folder — telling Git "these are the files I want to include in my next snapshot." The `.` means "everything in this folder.")*

```bash
git commit -m "Initial capstone portfolio upload"
```
*(This actually takes the snapshot, with a short descriptive message explaining what this snapshot represents.)*

```bash
git branch -M main
```
*(This names your primary snapshot timeline "main" — the modern standard convention.)*

```bash
git remote add origin https://github.com/YOUR-USERNAME/my-portfolio.git
```
*(Replace `YOUR-USERNAME` with your actual GitHub username. This tells your local Git project "here is the online copy of yourself, on GitHub, that you should sync with.")*

```bash
git push -u origin main
```
*(This is the actual upload step — it sends your committed snapshot up to GitHub. You may be prompted to log in via a browser popup the first time.)*

**Step 3 — Enable GitHub Pages:**

1. On your repository's GitHub page, click **Settings** (top navigation).
2. In the left sidebar, click **Pages**.
3. Under "Build and deployment" → "Source," select **Deploy from a branch**.
4. Under "Branch," select `main` and folder `/ (root)`, then click **Save**.
5. Wait about 1–2 minutes, then refresh the Pages settings screen — a green banner should appear: *"Your site is live at https://yourusername.github.io/my-portfolio/"*.

**The Verification:**

Open that URL in your browser. You should see your capstone's home page, live on the actual internet. Click through to About, Projects, and Contact — confirm navigation works identically to how it did locally with Live Server.

---

## D.4 — Fixing Broken Links to Sibling Project Folders

**The Target:** Resolve the "View Project" links on your Projects page, which currently point to sibling folders (`../part-4-photo-gallery/index.html`, etc.) that don't exist inside the `my-portfolio` repository you just uploaded.

**The Concept:** Recall from Part 9 that your Projects page links out to your original standalone project folders using relative paths like `../part-4-photo-gallery/`. Those folders live on *your computer*, as siblings to `my-portfolio/` — but GitHub Pages only published the *contents of the `my-portfolio` repository itself*. The relative path `../` (meaning "go up one folder level") now points to nothing, because there is no "up one level" in the context of a single deployed repository.

You have two clean solutions:

**Option A (simplest): Upload each project folder as its own separate repository**, and update your Projects page links to point to each project's own separate GitHub Pages URL instead of a relative path.

```bash
cd build-as-you-learn/part-4-photo-gallery
git init
git add .
git commit -m "Initial upload of Flexbox photo gallery"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/part-4-photo-gallery.git
git push -u origin main
```

Repeat this same five-step pattern for each of your other standalone project folders (`part-2-recipe-page`, `part-6-blog-layout`, `part-7-product-card`), remembering to also enable GitHub Pages (Step 3 above) individually for each new repository.

Then update your capstone's `projects.html`:

```html
<!-- my-portfolio/projects.html (updated links) -->
<a href="https://yourusername.github.io/part-7-product-card/" class="btn btn-secondary">View Project</a>
<a href="https://yourusername.github.io/part-4-photo-gallery/" class="btn btn-secondary">View Project</a>
<a href="https://yourusername.github.io/part-6-blog-layout/" class="btn btn-secondary">View Project</a>
```

**Option B (more advanced, mentioned for awareness): Combine everything into one single repository**, with `my-portfolio` and every `part-X` folder nested together as subfolders inside it, so the original relative paths work unmodified. This keeps everything in one place but means a single repository holding your entire series' output — a reasonable choice, but Option A more closely mirrors how real portfolio projects are typically organized (one repository per deployed project).

**The Verification:**

After choosing and implementing one option, refresh your live Projects page and click each "View Project" button — confirm every link now correctly resolves to a live, working page rather than a 404.

---

## D.5 — Deploying via Netlify (A More Powerful Alternative)

**The Target:** The same live site, deployed via Netlify instead of GitHub Pages — worth knowing because Netlify offers a few genuinely useful extras: drag-and-drop deployment with no Git commands required, instant deploy previews, and (relevantly for a future JavaScript-enabled version of your contact form) built-in form submission handling.

**The Concept:** Netlify is a hosting platform built specifically around modern static sites. Its standout beginner-friendly feature is **drag-and-drop deployment** — you can publish a site by literally dragging a folder into your browser, no terminal required at all.

**The Implementation:**

1. Create a free account at [netlify.com](https://www.netlify.com/).
2. From your Netlify dashboard, look for the **"Deploy manually"** or drag-and-drop area (usually labeled "Want to deploy a new site without connecting to Git? Drag and drop your site folder here").
3. Drag your entire `my-portfolio` folder directly from your file explorer into that browser area.
4. Netlify uploads and publishes it within seconds, assigning a random URL like `https://cheerful-kitten-abc123.netlify.app`.
5. Optionally, click **"Change site name"** in your site's settings to choose a more memorable subdomain, like `alexrivera-portfolio.netlify.app`.

**The Verification:**

Open the provided Netlify URL and confirm your site loads identically to the GitHub Pages version. Note: this method deploys a **snapshot** — if you later edit your files locally, you'd need to drag-and-drop the folder again to update the live version, unless you connect Netlify directly to your GitHub repository instead (Netlify's dashboard has a "Import from Git" option that, once connected, automatically redeploys every time you `git push` new changes — a nice upgrade once you're comfortable with the Git workflow from D.3).

---

## D.6 — Attaching a Custom Domain Name (Optional)

**The Target:** Replacing `https://yourusername.github.io/my-portfolio/` with something like `https://alexrivera.dev`.

**The Concept:** A domain name is a human-readable address (`alexrivera.dev`) that maps to your site's actual hosting location behind the scenes, through a global system called **DNS (Domain Name System)** — think of DNS as the internet's phone book, translating a name you can remember into the technical address computers actually use to find each other.

**The Implementation (overview, since exact steps vary by domain registrar):**

1. Purchase a domain from a registrar (e.g., Namecheap, Google Domains, Porkbun) — typically $10–15/year for a common extension.
2. In your registrar's DNS settings, add the DNS records GitHub Pages or Netlify specifically instructs you to add (usually a few "A" records pointing to their servers, plus a "CNAME" record for a `www` subdomain).
3. Back in your GitHub repository's **Settings → Pages** (or Netlify's **Domain settings**), enter your custom domain in the provided field and save.
4. Wait for DNS propagation — this can take anywhere from a few minutes to 24–48 hours, since DNS changes spread gradually across the internet's many caching servers worldwide.

**The Verification:**

Once propagation completes, visiting your custom domain directly in a browser should load your portfolio site, with your hosting provider (GitHub Pages or Netlify) automatically issuing a free HTTPS security certificate for it (look for the padlock icon in your browser's address bar, confirming the connection is encrypted).

---

## D.7 — A Pre-Deployment Checklist

Before publishing any version of your site, run through this list (much of it a condensed callback to Part 9's polish checklist, reframed specifically for "is this safe/correct to make public"):

1. **No placeholder content left behind** — replace every "Lorem ipsum," "Your Name Here," or `https://github.com/` dummy link with your real information.
2. **No leftover DevTools experimental edits** — since those never persist to disk, this is naturally handled, but worth a final fresh-reload sanity check.
3. **Relative paths confirmed correct** — especially cross-project links (D.4).
4. **Images optimized in file size** — very large photos (multiple MB each) slow down real-world loading noticeably more than they did locally; consider compressing images with a free tool like [squoosh.app](https://squoosh.app/) before final upload.
5. **Meta description and title tags present on every page** (Part 9, Step 11) — these are what appear in search engine results and social media link previews.
6. **A working favicon** — confirms the site feels finished and intentional, not like a work-in-progress.

---

## Quick Reference: Deployment Options Compared

| | GitHub Pages | Netlify (drag-and-drop) | Netlify (Git-connected) |
|---|---|---|---|
| Requires Git knowledge? | Yes | No | Yes |
| Auto-updates on file changes? | Yes, on every `git push` | No — manual re-drag required | Yes, on every `git push` |
| Custom domain support | Yes, free | Yes, free | Yes, free |
| Free tier sufficient for a portfolio? | Yes | Yes | Yes |
| Best for | Learning real Git workflow alongside deployment | Fastest possible first publish | Best long-term workflow once comfortable with Git |

For this series specifically, I'd recommend starting with **GitHub Pages (D.3)** — the Git skills you practice doing so are broadly transferable and expected in nearly every professional development environment you'll encounter going forward, making this appendix's terminal commands a genuinely valuable investment beyond just this one deployment.

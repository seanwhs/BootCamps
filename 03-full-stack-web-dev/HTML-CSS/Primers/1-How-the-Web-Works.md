# Primer 1: How the Web Actually Works

### Why This Primer Exists

Before Part 0's sanity check, you opened a file in a browser and saw it render as a page. That worked so smoothly it's easy to skip right past a question worth actually answering: **what *is* a browser, actually doing, when it shows you a web page?** And when we get to Appendix D and suddenly your files live on a server somewhere else in the world, reachable by a URL — what changed, mechanically, to make that possible?

You don't need this primer to *follow* the series step-by-step — Part 0 already gets you productive without it. But understanding this will make every subsequent concept (why `<meta charset="UTF-8">` matters, why deployment works the way it does, why a broken image shows a specific error in DevTools' Console) feel like a logical consequence of a system you understand, rather than a magic incantation you're trusting blindly.

---

## P1.1 — What "The Internet" Actually Is

**The Concept:** Strip away the mystique: the internet is simply **millions of computers, connected by cables and wireless signals, capable of sending small packages of data to each other.** That's the entire idea. Analogy: think of the global postal system — millions of houses, connected by roads, capable of exchanging letters. The internet is the same idea, just electronic, and almost instantaneous.

Every computer connected to this network — including yours right now — has an **IP address** (Internet Protocol address): a unique numerical identifier, like `142.250.premises.14`, that functions exactly like a street address. It's how one computer says "send this data specifically to *that* computer, not any other."

**Why this matters for you:** every single "request" you make (typing a URL, clicking a link) is, underneath everything else, your computer sending a small data packet to another computer's IP address, and waiting for a response packet to come back.

---

## P1.2 — Client and Server: The Two Roles Every Web Interaction Plays

**The Concept:** In virtually every web interaction, one computer plays the **client** role (the one *asking* for something — almost always, this is your own laptop or phone, running a browser) and another plays the **server** role (the one *storing and providing* something, waiting to respond to requests).

Analogy: a restaurant. You (the client) don't walk into the kitchen and cook your own food — you sit at a table and ask a waiter for something specific. The kitchen (the server) prepares it and sends it back out to you. You never see the kitchen directly; you just send a request and receive a response.

**Concretely, for this series:** every time you used Live Server (Part 0), your own laptop was temporarily playing *both* roles simultaneously — client and server — which is why it only worked for you, locally. When you deployed via GitHub Pages (Appendix D), GitHub's computers became the permanent *server*, and now anyone's browser, anywhere, can be the *client* asking them for your files.

---

## P1.3 — URLs: The Addressing System for Specific Files, Not Just Computers

**The Concept:** An IP address gets you to the right *computer*, but a server usually hosts many different files. A **URL (Uniform Resource Locator)** is the full, precise address — computer *and* specific file — all in one readable string. Let's break one down piece by piece, using a real example:

```
https://github.com/yourusername/my-portfolio/about.html
└──┬──┘   └────────────┬────────────┘└─────┬──────┘
 scheme            domain name          path to a specific file
```

- **Scheme** (`https://`) — the *protocol*, or agreed-upon "language" the client and server will use to communicate. `https` (the `s` stands for "secure") means the data is encrypted in transit — nobody eavesdropping on the network connection between you and the server can read what's being sent. This is why your browser shows a padlock icon for sites using it.
- **Domain name** (`github.com`) — a human-readable stand-in for a server's actual numerical IP address. This translation is handled by **DNS (Domain Name System)** — mentioned briefly in Appendix D — which acts like a global phone book, converting `github.com` into the real IP address behind the scenes, automatically, every time you visit.
- **Path** (`/yourusername/my-portfolio/about.html`) — tells the server exactly *which file*, among potentially millions it hosts, you're requesting. This is the exact same concept as the relative file paths you've been writing all series (`images/profile.jpg`, `../part-4-photo-gallery/index.html`) — just extended to also specify *which computer* to look on, not only where within that computer's own folder structure.

---

## P1.4 — The Request/Response Cycle, Step by Step

**The Concept:** Let's trace, in full, precise detail, exactly what happens the moment you type a URL into a browser and press Enter — the same cycle underlying every single page load in this entire series, whether local or deployed.

1. **You type or click a URL.** Say, `https://yourusername.github.io/my-portfolio/about.html`.
2. **Your browser looks up the domain via DNS**, translating `yourusername.github.io` into GitHub's actual server IP address.
3. **Your browser sends an HTTP request** to that IP address — a small, structured message that essentially says: *"GET me the file located at `/my-portfolio/about.html`, please."* (`GET` is the specific request type used for simply retrieving a file — you'll meet its counterpart, `POST`, again in a moment.)
4. **The server receives the request**, looks in its own storage for a file matching that exact path, and — assuming it finds one — sends back an **HTTP response**: the raw contents of `about.html`, as plain text, along with a **status code** (a three-digit number summarizing what happened).
5. **Your browser receives that raw HTML text** and does the work you've been implicitly relying on this entire series: it **parses** the text (reads it top to bottom, understanding the tags), builds an internal model of the page's structure (the same DOM tree you've been inspecting in DevTools' Elements panel since Appendix A), fetches any additional linked files it discovers along the way (your `<link rel="stylesheet">` CSS files, your `<img>` images — each one triggering its *own* separate request/response cycle, which is exactly what you were watching in Appendix A.7's Network panel), and finally **renders** the fully assembled result as the visual page you see.

**Where you've already directly seen every piece of this:**
- Appendix A.7 — the Network panel literally showing you each request and its outcome
- Appendix C.1 and C.3 — status codes appearing as `404` when a file isn't found
- Appendix D — you deliberately setting up the *server* half of this cycle for the first time (previously, Live Server had quietly played both roles for you)

---

## P1.5 — HTTP Status Codes: The Server's Reply, in Shorthand

**The Concept:** Every single HTTP response includes a three-digit status code summarizing the outcome — you've already encountered these indirectly (Appendix C's `404` diagnosis), but let's understand the actual system behind that number.

| Code Range | Category | Example You've Encountered |
|---|---|---|
| `200`–`299` | Success | `200 OK` — the file was found and sent successfully (Appendix A.7) |
| `300`–`399` | Redirection | The requested address has permanently or temporarily moved elsewhere |
| `400`–`499` | Client error | `404 Not Found` — you asked for a file that doesn't exist at that path (Appendix C.1, C.3) |
| `500`–`599` | Server error | Something broke on the server's end while trying to respond (not something you'll typically cause with a static HTML/CSS site, since there's no server-side logic to fail) |

**How to see this directly, right now:** Open DevTools' Network panel (Appendix A.7) on any of your deployed pages, and look at the **Status** column next to each request. Every single one you see is a real HTTP status code, exactly as described above — not an abstraction, the literal three-digit number the server sent back.

---

## P1.6 — `GET` vs `POST`: Why Your Part 8 Form Used `method="post"`

**The Concept:** Recall Part 8's contact form:

```html
<form action="#" method="post">
```

You now have the vocabulary to understand *why* `post` specifically, rather than the default `get`. Both are HTTP request types (like the `GET` we traced in P1.4), but they differ in *how* they send data to the server:

- **`GET`** appends data directly onto the *URL itself* as visible text (you'll have seen this as `?query=something` in search engine URLs) — appropriate for simple, non-sensitive requests like "fetch me this specific page," but a poor fit for a form, since form data (a name, an email, a message) would get awkwardly stuffed into a URL, visible in browser history, and subject to length limits.
- **`POST`** sends data hidden inside the *body* of the request, separately from the URL — the correct, conventional choice for form submissions, exactly as Part 8 modeled for you.

---

## P1.7 — Where Your Own Machine Fits Into All of This (Tying Back to Part 0)

**The Concept:** Let's close the loop on something Part 0 deliberately simplified. When you right-clicked and chose "Open with Live Server," here's what was actually happening, now that you have the full mental model:

1. VS Code's Live Server extension started a **tiny local web server** running on your own machine, listening on a specific numbered "door" (called a **port** — `5500`, which is why the URL was `http://127.0.0.1:5500/...`).
2. `127.0.0.1` is a special, reserved IP address that always means **"this same computer"** — regardless of which computer runs it. It's called the **loopback address**, because the request never actually leaves your machine; it loops right back to itself.
3. Your browser (the client) sent a `GET` request to `127.0.0.1:5500/sanity-check.html`.
4. Live Server (acting as the server, on that same physical machine) received it, found the matching file, and sent it back as an HTTP response — the exact same cycle from P1.4, just with the client and server both being *the same computer*, which is why it only ever worked for you, and why it required no domain name, no DNS lookup, and no real internet connection at all.

This is precisely why Appendix D's deployment step felt like a meaningful transition: you were replacing "my own computer, temporarily and locally, playing the server role" with "GitHub's computers, permanently and publicly, playing the server role" — same cycle, same roles, genuinely different *reach*.

---

## Quick Reference: The Vocabulary This Primer Introduced

| Term | Plain Definition |
|---|---|
| IP address | A unique numerical address identifying a specific computer on a network |
| Client | The computer *requesting* data (typically your browser) |
| Server | The computer *storing and providing* data in response to requests |
| URL | A full address specifying both which server and which specific file |
| DNS | The system translating human-readable domain names into IP addresses |
| HTTP | The agreed-upon "language" browsers and servers use to exchange requests/responses |
| `GET` / `POST` | Two types of HTTP requests — retrieving data vs. submitting data |
| Status code | A three-digit number summarizing the outcome of an HTTP response |
| `127.0.0.1` / localhost | The special address always meaning "this same computer" |
| Port | A numbered "door" a server listens on for incoming requests (e.g., `5500`) |

---

## What This Unlocks Going Forward

Every remaining concept in this series that touches "how does my file get from my computer to someone else's screen" now has a real mechanical explanation underneath it, rather than being taken on faith. When you open DevTools' Network tab again, you're not just checking for errors anymore — you're watching a real request/response cycle, with real status codes, that you now understand end to end.

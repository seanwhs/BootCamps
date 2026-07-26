# Primer 1: How the Web Actually Works

## Why this primer exists

This entire series is about building a web application — but "the web" is something almost everyone *uses* daily without ever needing to understand *how* it works. Before we write a single line of React, it's worth spending a few minutes on the actual mechanics: what happens when you type a URL into a browser, what a "server" really is, and what job HTML, CSS, and JavaScript each do. Every concept in this primer will be referenced constantly starting in Part 0 — think of this as the stage the entire rest of the series performs on.

This is written for someone who has never thought about this before. If you already know it, feel free to skip ahead — nothing here is React-specific.

---

## 1. Two computers, having a conversation

Imagine you want a specific book from a library, but you're not allowed inside — you can only talk to a librarian through a small window. You say the book's name; the librarian goes and finds it, and hands it back to you through the window.

This is almost exactly what happens every time you visit a website:

* **Your computer** (specifically, your web browser — Chrome, Firefox, Safari, Edge) is you, standing at the window.
* **A server** — another computer, somewhere else in the world, usually running non-stop in a data center — is the librarian.
* **A URL** (like `https://example.com`) is the name of the book you're asking for.
* **HTTP** (HyperText Transfer Protocol) is the *language* you and the librarian speak to each other — a shared, agreed-upon set of rules for how a request should be phrased, and how a response should be structured, so both sides understand each other no matter who built the browser or who built the server.

This request-and-response conversation is called a **client-server model**. Your browser is "the client" — the one asking. The server is the one answering. This vocabulary will come back constantly: in Phase 4 of this series, when our React app becomes "the client" making requests to our own backend server, we're using this exact same relationship, just with our own code playing both roles.

---

## 2. What actually happens when you type a URL and press Enter

Let's trace the full journey, step by step, using a concrete example: typing `https://example.com` into your browser's address bar.

1. **DNS lookup.** `example.com` is a human-friendly name, but computers actually locate each other using numeric addresses called **IP addresses** (like `93.184.216.34`). Your browser asks a system called **DNS** (Domain Name System) — essentially the internet's phone book — "what's the actual address for `example.com`?" and gets back the real number.
2. **Connecting.** Your browser opens a connection to the server at that address.
3. **The request.** Your browser sends an HTTP **request** — a structured message that says, in effect, "please `GET` me your homepage." (`GET` is one of several HTTP **methods** — we'll meet a few more, like `POST` and `PATCH`, starting in Phase 4, when our React app needs to *create* and *update* data on a server, not just read it.)
4. **The response.** The server processes that request and sends back an HTTP **response** — a structured message containing a **status code** (a number summarizing what happened — `200` means "success," `404` means "not found," `500` means "the server had an error" — we'll see these exact codes checked directly in our own code in Phase 4) plus a **body** (the actual content: usually HTML for a webpage, or raw data like JSON for an API).
5. **Rendering.** Your browser reads that HTML and draws ("renders") it on your screen as the webpage you see.

This entire round trip typically takes well under a second. Every time you click a normal link on a traditional website, this whole sequence repeats from scratch — a completely new request, a completely new response, a completely fresh page drawn on screen. Keep this in mind: it's precisely the "flash and reload" this sequence causes that React's **Single Page Application** model (which we'll build starting in Phase 1) is specifically designed to avoid, by handling most of this dance with JavaScript instead of full page reloads.

---

## 3. The three languages of the web, and what each one actually does

Every webpage you've ever visited is built from some combination of three fundamentally different technologies. It's worth being precise about what each one's job actually is, since confusing them is a common source of confusion for beginners.

### HTML — the structure ("what's on the page")

**HTML** (HyperText Markup Language) describes the *content and structure* of a page: this is a heading, this is a paragraph, this is a button, this is an image. It uses **tags** — words wrapped in angle brackets — to label pieces of content:

```html
<h1>Task & Habit Tracker</h1>
<p>Welcome! Let's get started.</p>
<button>Add Task</button>
```

Read this literally as: "here is a top-level heading, here is a paragraph, here is a button." HTML says *nothing* about color, size, or position — and nothing about what happens when you click that button. It's a skeleton, not a finished body.

### CSS — the appearance ("how it looks")

**CSS** (Cascading Style Sheets) describes *presentation*: colors, spacing, fonts, layout, what happens on hover. It works by **selecting** HTML elements and attaching style rules to them:

```css
button {
  background-color: #2f6fed;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 8px;
}
```

Read this as: "find every `<button>` element on the page, and make it look like this." The same HTML can look dramatically different depending entirely on what CSS is attached to it — this is precisely the mechanism our dark mode feature (Phase 5) relies on: identical HTML structure, entirely different CSS variable values, producing two completely different visual themes.

### JavaScript — the behavior ("what happens when...")

**JavaScript** is a real programming language — the only one of these three that can make *decisions*, *remember things*, and *react to events*. It's what makes a page interactive rather than a static, unchanging document:

```javascript
const button = document.querySelector('button')

button.addEventListener('click', function () {
  alert('Task added!')
})
```

Read this as: "find the button; when someone clicks it, run this code." Without JavaScript, a webpage is a digital piece of paper — you can look at it, but it can't respond to you. **React, which this entire series is about, is a JavaScript library** — everything we build is fundamentally JavaScript, just organized and written in React's particular style (which we'll unpack starting in Part 0 and Phase 1).

### A simple analogy to tie all three together

Think of a house:
* **HTML** is the frame and rooms — where the walls, doors, and windows actually are.
* **CSS** is the paint, furniture, and decor — how it all looks.
* **JavaScript** is the electricity and plumbing — the parts that actually *do* something when you flip a switch or turn a tap.

You need all three to make a fully functional, good-looking, interactive house — exactly as a real web application needs all three, working together.

---

## 4. "Frontend" and "backend" — the two halves of a web application

You'll hear these two terms constantly throughout this series, especially starting in Phase 4:

* **Frontend** — everything that runs *inside the user's own browser*. This is our entire React application: the HTML it produces, the CSS styling it, and the JavaScript logic controlling it. The user's computer does all the work of running it.
* **Backend** — code that runs on a *server*, somewhere else, that the frontend talks to over HTTP requests (exactly the request/response dance from Section 2) to fetch or save data. In this series, our backend starts as a simple local tool (`json-server`, introduced in Phase 4) and later becomes real serverless functions (Phase 9).

A useful mental split: **the frontend is responsible for what the user sees and interacts with; the backend is responsible for storing and protecting the actual data.** This distinction is the entire reason our project will eventually have two separate top-level folders — `src/` for frontend code, `api/` for backend code — and it's why, when we build authentication in Phase 6, we'll be explicit that only the backend can provide *genuine* security, no matter how convincing the frontend's UI looks.

---

## 5. What "the internet" and "a browser" actually are, briefly

Two last pieces of vocabulary worth being precise about, since they're easy to conflate:

* **The internet** is the physical and logical infrastructure — cables, satellites, routers, servers — that lets computers all over the world send data to each other. It existed before the web, and supports far more than just websites (email, file transfers, video calls).
* **The web** (the World Wide Web) is one particular *system built on top of* the internet — specifically, the system of HTML documents, linked together by URLs, transferred using HTTP, and displayed by browsers. When people casually say "the internet," they very often actually mean "the web" — a harmless mix-up in everyday conversation, but worth knowing they're technically different things.
* **A browser** (Chrome, Firefox, Safari, Edge) is simply the program on your computer that knows how to speak HTTP, request pages, and correctly interpret and display HTML, CSS, and JavaScript. Every single thing this series builds will ultimately be viewed inside one of these.

---

## Quick-reference summary

| Term | One-line definition |
|---|---|
| Client | The one making a request — in web contexts, your browser |
| Server | The one responding to requests — a computer, elsewhere, usually always on |
| HTTP | The shared "language"/rules for how requests and responses are structured |
| URL | The address of a specific resource you're requesting |
| DNS | The system that translates human-friendly domain names into numeric IP addresses |
| Status code | A number in an HTTP response summarizing what happened (200 = success, 404 = not found, etc.) |
| HTML | Describes structure/content — what's on the page |
| CSS | Describes appearance — how it looks |
| JavaScript | Describes behavior — what happens when something occurs |
| Frontend | Code that runs in the user's browser |
| Backend | Code that runs on a server, handling data storage and real security |

---

With this foundation in place, you're ready for the rest of this series to make full sense: when Part 0 talks about building a "Single Page Application," you'll understand exactly what problem that solves relative to the traditional full-reload request/response cycle described above. When Phase 4 has our React app "fetch data from an API," you'll recognize it as the exact same client/server HTTP conversation this primer just walked through — just one computer program initiating the request instead of a human typing a URL.

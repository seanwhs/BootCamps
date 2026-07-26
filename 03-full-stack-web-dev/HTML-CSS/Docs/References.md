# Build As You Learn: HTML & CSS from Zero to Portfolio
## References & Resource Guide

---

### How to Use This Guide

This is the series' **external companion map** — every tool, standard, documentation site, and further-reading resource referenced or implied across all nine Parts, five Appendices, and five Primers, organized so you can find the right external resource the moment you need it, rather than searching blindly. Entries are grouped by theme, each with **what it is, why it's here, and when in the series you'd first reach for it.**

Treat the tools marked ⭐ as the small, permanent core toolkit worth bookmarking regardless of where your web development path goes next.

---

## 1. Primary Reference Documentation

These are the sources professional developers actually consult daily — not tutorials, but authoritative technical references. Bookmark all of these now; you will return to them for the rest of your development life.

**⭐ MDN Web Docs — developer.mozilla.org**
The single most trusted, comprehensive reference for HTML, CSS, and JavaScript on the web, maintained by Mozilla with contributions from browser vendors themselves. Every tag, every CSS property, and every pseudo-class covered in this series (Parts 1–9) has a corresponding MDN page with full browser-support tables, syntax breakdowns, and live examples. When Appendix B's glossary gives you a one-line definition, MDN is where you go for the exhaustive version.
*First relevant: Part 1 onward, for any tag/property lookup.*

**W3Schools — w3schools.com**
A friendlier, example-heavy alternative to MDN, popular specifically with beginners for its interactive "Try It" editors. Slightly less rigorous/authoritative than MDN but genuinely useful for quick syntax refreshers when MDN's academic tone feels like too much at once.
*First relevant: Part 1–2, as a lighter-weight lookup companion.*

**Can I Use — caniuse.com**
A browser-compatibility lookup tool. Search any CSS property (e.g., `gap`, `aspect-ratio`) to see exactly which browsers and versions support it. Genuinely useful once you start using newer CSS features (Grid's `auto-fit`/`minmax()` in Part 6, CSS custom properties in Part 9) and want to confirm broad support before shipping something publicly.
*First relevant: Part 6 and Part 9, when introducing more modern CSS features.*

**The W3C (World Wide Web Consortium) — w3.org**
The actual standards body that defines HTML and CSS specifications. Rarely needed directly as a beginner (the specs are dense and written for implementers, not learners), but worth knowing this is the ultimate source of truth behind everything MDN documents in friendlier language.
*First relevant: purely for context, referenced conceptually in Primer 3's discussion of syntax rules.*

---

## 2. Tools Used Directly in This Series

**⭐ Visual Studio Code — code.visualstudio.com**
The free code editor used throughout the entire series, starting in Part 0's environment setup.

**⭐ Live Server (VS Code Extension)**
Search "Live Server" by Ritwick Dey inside VS Code's Extensions panel. Provides the auto-refresh-on-save workflow that underlies every single verification step in Parts 1–9.

**Google Chrome / Mozilla Firefox / Microsoft Edge**
Any modern browser works throughout this series; DevTools (Appendix A) is built into all three, though exact panel names/positions vary slightly between them.

**Git — git-scm.com/downloads**
The version control tool required for Appendix D's deployment workflow and explained conceptually in Primer 5.

**⭐ GitHub — github.com**
Hosting platform for your repositories, and the source of GitHub Pages, the primary free deployment method covered in Appendix D.

**Netlify — netlify.com**
The alternative deployment platform covered in Appendix D.5, notable for its drag-and-drop deployment requiring no Git knowledge.

**Squoosh — squoosh.app**
A free, browser-based image compression tool, referenced in Appendix D.7's pre-deployment checklist for optimizing photo file sizes before publishing.

---

## 3. Accessibility Tools & References

Referenced across Part 1 (`alt` text), Part 3 (semantic tags), Part 8 (form labels/focus states), Part 9 (production polish), and Appendix E.

**⭐ WebAIM's WAVE — wave.webaim.org**
A free browser extension that scans any live page and flags accessibility issues directly, referenced in Appendix E.2 as the go-to automated audit tool for your finished capstone.

**Google Lighthouse (built into Chrome DevTools)**
Click the "Lighthouse" tab directly inside the same DevTools panel covered in Appendix A — generates a full report covering accessibility, performance, and SEO for any page, referenced in Appendix E.2.

**Web Content Accessibility Guidelines (WCAG) — w3.org/WAI/standards-guidelines/wcag**
The internationally recognized standard defining what "accessible" formally means, referenced in Appendix E.2 as the underlying framework behind tools like WAVE and Lighthouse.

**VoiceOver (built into macOS) / NVDA — nvaccess.org (free, Windows)**
Screen readers referenced in Appendix E.2 for genuinely testing your site the way a visually impaired user would experience it — a recommended, humbling exercise once your capstone is complete.

**WebAIM Contrast Checker — webaim.org/resources/contrastchecker**
A free tool for verifying text/background color contrast ratios meet accessibility standards, directly relevant to Part 9's production polish checklist item on contrast.

---

## 4. Color & Design Tools

Referenced throughout, especially Primer 4 and Part 9's design-token system.

**Coolors — coolors.co**
A free color palette generator, useful for picking a `:root` design-token palette (Part 9, Step 2) that feels cohesive rather than arbitrary.

**Adobe Color — color.adobe.com**
An alternative color palette tool with color-theory-based generation modes (complementary, analogous, etc.).

**Google Fonts — fonts.google.com**
Referenced implicitly wherever this series used system font stacks (`"Segoe UI", Arial, sans-serif`) — Google Fonts is the natural next step once you want custom, embeddable web fonts beyond system defaults, via a `<link>` tag in `<head>`, identical in spirit to Part 2's stylesheet linking.

---

## 5. Deployment & Domain Resources

Referenced in Appendix D.

**GitHub Pages Documentation — docs.github.com/pages**
The official documentation for the exact deployment workflow walked through step-by-step in Appendix D.3.

**Netlify Documentation — docs.netlify.com**
Official docs for the drag-and-drop and Git-connected deployment flows in Appendix D.5.

**Domain Registrars** (for Appendix D.6's custom domain section):
- Namecheap — namecheap.com
- Google Domains / Squarespace Domains — domains.squarespace.com
- Porkbun — porkbun.com

**DNS Checker — dnschecker.org**
A free tool to check DNS propagation status worldwide, useful while waiting for a custom domain (Appendix D.6) to finish propagating after setup.

---

## 6. Version Control & Command Line Learning

Referenced in Primer 5 and Appendix D.

**⭐ Git Documentation — git-scm.com/doc**
The official Git reference manual, for anyone wanting to go beyond the handful of commands (`init`, `add`, `commit`, `push`) covered in Primer 5.

**GitHub Skills — skills.github.com**
Free, interactive, browser-based courses directly from GitHub for learning Git/GitHub workflows more deeply than this series' deployment-focused introduction.

**Learn Git Branching — learngitbranching.js.org**
A free, visual, interactive tool for understanding Git's branching model — useful once you outgrow the single-branch (`main`) workflow used throughout this series.

---

## 7. Where-to-Go-Next Resources (Appendix E Companions)

**JavaScript Fundamentals:**
- **⭐ MDN JavaScript Guide** — developer.mozilla.org/en-US/docs/Web/JavaScript/Guide — the recommended starting point per Appendix E.1.
- **JavaScript.info** — javascript.info — a free, thorough, modern alternative course, often praised for its depth without excessive jargon.
- **The Odin Project** — theodinproject.com — a free, full-stack curriculum that picks up naturally from where this series leaves off, with a similar project-based philosophy.

**CSS at Scale:**
- **Sass Documentation** — sass-lang.com/documentation — for the CSS preprocessor mentioned in Appendix E.3.
- **BEM Methodology** — getbem.com — the official reference for the naming convention discussed in Appendix E.3.
- **Tailwind CSS** — tailwindcss.com — the utility-first framework referenced in Appendix E.3 as a contrasting philosophy worth knowing about.

**Component Frameworks:**
- **React Documentation** — react.dev — the official, modern React docs, relevant once Appendix E.1's JavaScript fundamentals are comfortable.
- **Vue.js** — vuejs.org — an alternative framework, often considered a gentler on-ramp than React for developers coming directly from HTML/CSS.

**Build Tools:**
- **Vite** — vitejs.dev — the modern, fast build tool referenced in Appendix E.5, commonly paired with React in current tutorials.

---

## 8. Series Cross-Reference Index

A quick lookup table mapping *where in the series* each resource category first becomes relevant — useful for knowing what to bookmark before you need it.

| Resource Category | First Needed |
|---|---|
| VS Code, Live Server, browser | Part 0 |
| MDN / W3Schools (tag & property lookup) | Part 1 |
| Coolors / Google Fonts | Part 1–2, Part 9 |
| Can I Use | Part 6, Part 9 |
| WAVE / Lighthouse / WCAG | Part 8–9, Appendix E |
| Git & GitHub | Appendix D |
| Squoosh (image compression) | Appendix D |
| Domain registrars / DNS Checker | Appendix D.6 (optional) |
| MDN JavaScript Guide / The Odin Project | Appendix E |
| Sass / BEM / Tailwind | Appendix E |
| React / Vue / Vite | Appendix E |

---

## 9. A Note on Using External Resources Responsibly

A closing piece of guidance worth internalizing now: this series deliberately built everything from first principles so you'd understand *why* code works, not just *that* it works. As you branch out into the resources above, apply the same standard — favor primary documentation (MDN, official framework docs) over random blog posts or AI-generated snippets you can't verify, and always ask "do I understand why this works?" before copy-pasting anything into a real project. That habit, more than any single tool in this list, is what actually separates a durable developer skillset from a fragile one.

---

*End of References & Resource Guide. Recommended bookmarks, at minimum: MDN Web Docs, Can I Use, GitHub, and WebAIM's WAVE — these four alone will serve you well past the end of this series.*

# Primer 12: Open Source Licenses, Ownership, and Safe Reuse

A Git repository can store code, documentation, images, configuration, and release artifacts. But Git does not automatically tell other people what they are allowed to do with those materials.

A **license** defines permissions and conditions for using, copying, modifying, and distributing a project.

This primer explains the basics needed before making a repository public, copying code from another project, or accepting outside contributions.

> This primer provides general technical guidance, not legal advice. For commercial, regulated, or high-risk projects, consult qualified legal counsel.

---

# P12.1 Understand Copyright and Repository Ownership

## The Target

Understand why publishing code on GitHub does not automatically grant reuse rights.

## The Concept

When someone creates original code or documentation, copyright generally applies automatically in many jurisdictions.

That means a public GitHub repository without a license may be visible to everyone, but other people may not have clear legal permission to reuse its contents.

Think of it this way:

```text
Public repository
    ≠
Automatically reusable repository
```

A license answers questions such as:

```text
Can someone copy this code?
Can they modify it?
Can they use it commercially?
Must they include attribution?
Must they publish their modifications under the same license?
```

## The Implementation

Inspect whether your repository already has a license file:

```bash
git ls-files LICENSE LICENSE.md COPYING NOTICE
```

If the command produces no output, the repository may not yet declare a license.

## The Verification

Confirm you understand:

| Repository state | Clear reuse permission? |
|---|---:|
| Public repository with no license | Usually no clear permission |
| Public repository with `MIT` license | Broad permission with attribution and license notice |
| Private repository | Access is controlled, but ownership and reuse terms still matter |
| Public repository with `LICENSE` file | Depends on the license text |

---

# P12.2 Compare Common Open Source License Families

## The Target

Recognize the practical differences between common license choices.

## The Concept

Licenses are not interchangeable. Each has different conditions.

| License | General idea | Common use case |
|---|---|---|
| MIT | Very permissive; preserve copyright and license notice | Small libraries, examples, tools |
| Apache-2.0 | Permissive; includes patent grant and notice requirements | Corporate-friendly projects and libraries |
| BSD-3-Clause | Permissive; includes attribution conditions | Libraries and academic or infrastructure projects |
| GPL-3.0 | Strong copyleft; distributed derivative works generally remain GPL-compatible | Projects prioritizing reciprocal openness |
| AGPL-3.0 | Strong network copyleft; may require source availability for network services | Projects protecting hosted-service modifications |
| MPL-2.0 | File-level copyleft | Projects balancing reuse with reciprocal file changes |
| Unlicense / CC0 | Attempts broad public-domain-style dedication | Small examples, where legally appropriate |

A simplified choice guide:

```text
Want broad reuse with simple conditions?
    → MIT or Apache-2.0

Want a patent grant and detailed legal terms?
    → Apache-2.0

Want changes distributed with the software to remain open?
    → GPL-3.0

Want hosted-service modifications to be shared too?
    → AGPL-3.0
```

## The Implementation

No command is required.

Read the official SPDX license list:

```text
https://spdx.org/licenses/
```

Read GitHub’s license guidance:

```text
https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository
```

## The Verification

Before selecting a license, confirm you can answer:

```text
[ ] Is this project intended for public reuse?
[ ] Does an employer, client, or organization own the work?
[ ] Does the project include third-party code or assets?
[ ] Does the chosen license fit the project’s distribution goals?
[ ] Have maintainers agreed on the license choice?
```

---

# P12.3 Add an MIT License to a Personal Open Source Project

## The Target

Add a standard MIT license file to a project when that license is appropriate.

## The Concept

The MIT License is common because it permits broad reuse while requiring preservation of copyright and license text.

It is often suitable for personal learning projects, examples, and small developer tools.

Do not add it if:

- Your employer or client owns the project.
- The repository already has a different license.
- The project includes code whose licensing is incompatible.
- You have not decided whether public reuse is appropriate.

## The Implementation

Create a feature branch:

```bash
git switch main
git pull --ff-only
git switch -c docs/add-mit-license
```

Create this file. Replace `YOUR NAME OR ORGANIZATION` and `YEAR` before committing.

### `release-notes-manager/LICENSE`

```text
MIT License

Copyright (c) YEAR YOUR NAME OR ORGANIZATION

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

Add a license section to the README.

### `release-notes-manager/README.md` — append this section

```md
## License

This project is licensed under the [MIT License](LICENSE).
```

Review, test, and commit:

```bash
git diff -- LICENSE README.md
npm test
git add LICENSE README.md
git commit -m "docs: add MIT license"
git push -u origin docs/add-mit-license
```

Open a pull request and merge it through the normal review process.

## The Verification

After merge, confirm Git tracks the license:

```bash
git switch main
git pull --ff-only
git ls-files LICENSE
```

Expected output:

```text
LICENSE
```

On GitHub, the repository page should display a license indicator near the repository information.

---

# P12.4 Understand Third-Party Dependencies and License Obligations

## The Target

Recognize that dependencies and copied code can carry their own license requirements.

## The Concept

A project’s own license does not erase obligations from dependencies, copied snippets, images, fonts, templates, or other third-party assets.

For example:

```text
Your project: MIT License
Dependency A: Apache-2.0
Dependency B: GPL-3.0
Image asset: Creative Commons license
```

Each item may have different requirements.

Common obligations include:

```text
Preserve copyright notices.
Include license text.
Include attribution.
Provide source under certain circumstances.
Avoid using trademarks without permission.
```

For npm dependencies, inspect package metadata and license fields.

## The Implementation

List project dependencies:

```bash
npm ls --depth=0
```

For the current dependency-free project, output may resemble:

```text
release-notes-manager@1.0.0
└── (empty)
```

If a package is installed, inspect its metadata:

```bash
npm view PACKAGE_NAME license
```

For example:

```bash
npm view eslint license
```

Inspect package files after installation:

```bash
cat node_modules/PACKAGE_NAME/package.json
```

Do not add a dependency merely to perform this exercise.

## The Verification

Before adding a dependency or copied resource, ask:

```text
[ ] What license applies?
[ ] Is the dependency trusted and actively maintained?
[ ] Does the license require attribution or notices?
[ ] Is it compatible with the project’s intended license?
[ ] Does the dependency introduce unnecessary security or maintenance risk?
```

---

# P12.5 Attribute Copied Code and Documentation

## The Target

Use clear attribution when adapting meaningful code or documentation from another source.

## The Concept

Copying a short generic idea may not require attribution, but copying meaningful code, a full function, a template, an image, or documentation text often requires attention to license terms and attribution.

A good attribution record says:

```text
What was adapted?
Where did it come from?
Which license applies?
What was changed?
```

## The Implementation

Use this comment pattern when adapting code where attribution is required or appropriate:

```js
/**
 * Adapted from PROJECT_NAME:
 * https://github.com/OWNER/REPOSITORY/blob/COMMIT_HASH/path/to/file.js
 *
 * Original license: LICENSE_IDENTIFIER
 * Changes: Renamed the helper and added input validation for this project.
 */
```

For documentation or templates, add a notice such as:

```md
## Attribution

This document was adapted from [PROJECT_NAME](SOURCE_URL), licensed under
LICENSE_IDENTIFIER. It has been modified for Release Notes Manager.
```

Do not copy code or content first and investigate licensing later.

## The Verification

Before merging copied or adapted material, confirm:

```text
[ ] The source URL is recorded.
[ ] The source license is known.
[ ] Required notices are preserved.
[ ] The adaptation is allowed by the source license.
[ ] The pull request explains the origin and changes.
```

---

# P12.6 Understand Contributor License Agreements and DCOs

## The Target

Recognize common methods projects use to confirm contribution rights.

## The Concept

When contributors submit code, maintainers need confidence that contributors have the right to submit it.

Two common approaches are:

### Contributor License Agreement (CLA)

A **CLA** is an agreement between contributors and the project owner or organization.

It may clarify copyright, licensing, patents, and contribution rights.

### Developer Certificate of Origin (DCO)

A **DCO** is a lighter-weight statement often attached to commits using:

```text
Signed-off-by: Contributor Name <email@example.com>
```

It indicates that the contributor certifies they have the right to submit the work under the project’s terms.

A DCO sign-off is not the same as cryptographically signing a commit.

| Feature | DCO sign-off | Cryptographic commit signature |
|---|---|---|
| Purpose | Certify contribution origin | Prove a key signed a commit |
| Typical command | `git commit -s` | `git commit -S` |
| Adds | `Signed-off-by` line | Cryptographic signature |
| Replaces legal review? | No | No |

## The Implementation

Do not add a CLA or DCO requirement without project-owner approval.

To create a signed-off commit in a project that requires DCO:

```bash
git commit -s -m "docs: clarify contribution guidance"
```

Git adds a footer similar to:

```text
Signed-off-by: Your Name <you@example.com>
```

Inspect the commit:

```bash
git show --format=full HEAD
```

## The Verification

Confirm you can distinguish:

```bash
git commit -s
```

from:

```bash
git commit -S
```

```text
-s:
Adds a Developer Certificate of Origin sign-off.

-S:
Creates a cryptographic commit signature.
```

---

# P12.7 Add License and Attribution Guidance to Contributions

## The Target

Document how contributors should handle third-party material.

## The Concept

A contributor guide should make expectations visible before someone accidentally copies incompatible content into the project.

## The Implementation

Append this section to `CONTRIBUTING.md`.

### `release-notes-manager/CONTRIBUTING.md` — append this section

```md
## Licensing and Third-Party Material

Only submit code, documentation, images, templates, or other material that you have the right to contribute.

When adapting meaningful third-party material:

- Verify the source license.
- Preserve required copyright and license notices.
- Add attribution when required or appropriate.
- Explain the source and changes in the pull request.
- Do not copy proprietary, confidential, or employer-owned material without permission.

Do not add new dependencies or assets without reviewing their license and maintenance status.
```

Create a feature branch:

```bash
git switch main
git pull --ff-only
git switch -c docs/add-licensing-guidance
```

Run tests:

```bash
npm test
```

Commit and push:

```bash
git add CONTRIBUTING.md
git commit -m "docs: add third-party contribution guidance"
git push -u origin docs/add-licensing-guidance
```

## The Verification

Open a pull request and confirm the guidance is:

- Clear.
- Appropriate for the project.
- Consistent with the repository’s actual license.
- Free of legal claims the maintainers cannot support.

---

# P12.8 License and Ownership Checklist

## The Target

Use a short checklist before publishing or reusing repository content.

## The Concept

Licensing decisions are easiest before a project becomes widely used.

## The Implementation

Use this checklist:

```text
Project ownership
[ ] I know whether I, my employer, a client, or an organization owns this work.
[ ] I have permission to publish the repository.
[ ] I have permission to choose or apply a license.

Repository licensing
[ ] The repository includes a deliberate LICENSE file when public reuse is intended.
[ ] README documentation links to the license.
[ ] License choice matches project goals.

Third-party material
[ ] Dependencies have been reviewed for license and maintenance status.
[ ] Copied code and assets have known origins.
[ ] Required notices and attribution are preserved.
[ ] No proprietary or confidential material is included.

Contributions
[ ] CONTRIBUTING.md explains contribution expectations.
[ ] CLA or DCO requirements are documented if applicable.
[ ] Pull requests disclose meaningful third-party material.
```

## The Verification

Before making a repository public, inspect:

```bash
git status
git ls-files LICENSE CONTRIBUTING.md README.md SECURITY.md
```

Confirm expected files are present and project-specific placeholders are resolved.

---

# Primer 12 Reference: License and Contribution Commands

## Check for License Files

```bash
git ls-files LICENSE LICENSE.md COPYING NOTICE
```

## Inspect Dependency Tree

```bash
npm ls --depth=0
```

## Inspect an npm Package License

```bash
npm view PACKAGE_NAME license
```

## Create a DCO-Signed Commit

```bash
git commit -s -m "docs: clarify contribution guidance"
```

## Inspect Commit Footer and Author Information

```bash
git show --format=full HEAD
```

---

# Primer 12 Completion Check

Before publishing or contributing to an open-source repository, confirm that you can:

- [ ] Explain why public visibility does not automatically grant reuse permission.
- [ ] Recognize the purpose of a repository license.
- [ ] Distinguish permissive and copyleft license families at a high level.
- [ ] Add a license only when it is appropriate for the project owner and dependencies.
- [ ] Review third-party dependency and asset licenses.
- [ ] Preserve attribution and required notices for adapted material.
- [ ] Explain the difference between DCO sign-off and cryptographic commit signing.
- [ ] Document third-party contribution expectations.
- [ ] Identify when legal or organizational guidance is needed.

# Primer 10: Version Numbers, Releases, and Delivery Basics

A commit records a project snapshot. A **release** identifies a project snapshot that is ready for users, contributors, or deployment systems.

Git commit hashes are exact but not friendly:

```text
a1b2c3d4e5f67890...
```

A release version is easier to communicate:

```text
v1.0.0
```

This primer explains the vocabulary behind releases before you create Git tags, GitHub Releases, release notes, and automated delivery workflows.

You will learn:

- What a release is.
- Why version numbers matter.
- The basics of Semantic Versioning.
- The difference between commits, tags, and GitHub Releases.
- What release notes communicate.
- Why a release needs verification.
- How patch, minor, and major changes differ.

---

# P10.1 Understand a Release

## The Target

Understand what makes a commit into a release.

## The Concept

A commit is a recorded project snapshot.

A release is a deliberately selected commit that the project identifies as ready for use.

Think of a book-writing process:

```text
Commit
= A saved draft revision.

Tag
= A label identifying one exact edition.

Release
= The public announcement and distribution of that edition.
```

A project history may look like this:

```text
A → B → C → D
          │
          └── v1.0.0
```

Here:

- `A`, `B`, `C`, and `D` are commits.
- `v1.0.0` is a tag pointing to commit `C`.
- GitHub may publish a release page based on `v1.0.0`.

The release tag makes the released source code reproducible:

```text
“Which code did version 1.0.0 contain?”
    ↓
Check out tag v1.0.0.
```

## The Implementation

Inspect existing tags:

```bash
git tag --list
```

Inspect a specific release tag if one exists:

```bash
git show v1.0.0
```

If the project does not yet have a `v1.0.0` tag, Git reports an error. That is expected until the release process is completed.

## The Verification

Confirm you can explain:

```text
Commit:
A recorded project snapshot.

Tag:
A stable name pointing to a specific commit.

GitHub Release:
A public release page built around a tag.
```

---

# P10.2 Understand Semantic Versioning

## The Target

Learn how a version number communicates the type of change in a release.

## The Concept

**Semantic Versioning**, often called **SemVer**, uses this format:

```text
MAJOR.MINOR.PATCH
```

For example:

```text
1.4.2
```

Each number has a purpose:

| Segment | Example | Meaning |
|---|---|---|
| MAJOR | `1.4.2` → `2.0.0` | Breaking changes |
| MINOR | `1.4.2` → `1.5.0` | New backward-compatible features |
| PATCH | `1.4.2` → `1.4.3` | Backward-compatible fixes |

Think of a version number as a change summary:

```text
2.0.0
│ │ │
│ │ └── Fix level
│ └──── New feature level
└────── Compatibility-breaking level
```

## The Implementation

Classify these changes.

| Change | Suggested version change |
|---|---|
| Correct a date-validation bug | Patch |
| Add an optional `security` section to release notes | Minor |
| Rename required input property `releaseDate` to `date` | Major |
| Correct a README typo only | Usually no release required |

Example progression:

```text
1.0.0
    ↓ bug fix
1.0.1
    ↓ new backward-compatible feature
1.1.0
    ↓ breaking API change
2.0.0
```

## The Verification

Confirm these mappings:

```text
fix:
1.0.0 → 1.0.1

new compatible feature:
1.0.0 → 1.1.0

breaking change:
1.0.0 → 2.0.0
```

---

# P10.3 Understand Backward Compatibility

## The Target

Recognize whether a change is compatible with existing users.

## The Concept

A change is **backward-compatible** when existing users can continue using the project without changing their code or workflow.

Suppose the formatter currently accepts:

```js
formatReleaseNotes({
  version: "1.0.0",
  releaseDate: "2026-07-25"
});
```

Adding an optional property is usually backward-compatible:

```js
formatReleaseNotes({
  version: "1.0.0",
  releaseDate: "2026-07-25",
  security: ["Improve token validation."]
});
```

Existing calls still work because `security` is optional.

Changing a required property name is breaking:

```js
formatReleaseNotes({
  version: "1.0.0",
  date: "2026-07-25"
});
```

Existing callers using `releaseDate` would fail unless they update their code.

## The Implementation

Use this decision guide:

```text
Will existing users need to change their code or workflow?
    │
    ├── No
    │   ├── Is this a bug fix? → PATCH
    │   └── Is this new functionality? → MINOR
    │
    └── Yes
        └── MAJOR
```

## The Verification

Classify these examples:

| Change | Compatible? | Typical version impact |
|---|---:|---|
| Fix incorrect output for impossible dates | Yes | Patch |
| Add optional formatting option | Yes | Minor |
| Remove `fixed` section support | No | Major |
| Require a new mandatory `author` field | No | Major |

---

# P10.4 Understand Pre-Release Versions

## The Target

Recognize version labels used for testing before a stable release.

## The Concept

A project may publish a version for testing before declaring it stable.

Common pre-release forms:

```text
1.1.0-alpha.1
1.1.0-beta.1
1.1.0-rc.1
```

Their typical meaning:

| Label | Meaning |
|---|---|
| `alpha` | Early experimental version |
| `beta` | Feature-complete or near-complete testing version |
| `rc` | Release candidate; expected to become stable if no important problems are found |

For example:

```text
1.1.0-beta.1
```

means:

> “This is the first beta candidate for the future stable 1.1.0 release.”

Pre-release versions should be clearly labeled so users do not mistake them for stable production releases.

## The Implementation

No repository change is needed.

Read these version relationships:

```text
1.1.0-alpha.1
    ↓
1.1.0-beta.1
    ↓
1.1.0-rc.1
    ↓
1.1.0
```

## The Verification

Confirm:

```text
1.1.0-beta.1
```

is not the same as:

```text
1.1.0
```

The first is a testing release. The second is the stable release.

---

# P10.5 Understand Release Notes

## The Target

Understand what release notes should communicate.

## The Concept

Release notes explain meaningful changes to people.

They are not merely a copy of every commit message.

A useful release note answers:

```text
What is new?
What changed?
What was fixed?
Are there known limitations?
Does anyone need to take action?
```

A common structure is:

```md
## [1.1.0] - YYYY-MM-DD

### Added

- New capabilities.

### Changed

- Existing behavior that changed.

### Fixed

- Bugs that were corrected.

### Security

- Security-related improvements or fixes.
```

Release notes should describe user impact.

Technical commit:

```text
refactor: simplify section normalization
```

Potential user-facing release note:

```text
- Improve reliability when formatting optional release-note sections.
```

## The Implementation

Read this example release note:

```md
## [1.0.0] - 2026-07-25

### Added

- A validated JavaScript release-note formatter.
- Automated tests using Node.js.
- GitHub Actions continuous integration.

### Fixed

- Release-date validation rejects malformed and impossible calendar dates.
```

## The Verification

Confirm that the example tells readers:

```text
[ ] What capabilities were added.
[ ] What behavior was fixed.
[ ] Which version contains the changes.
[ ] When the release was published.
```

---

# P10.6 Understand a Release Checklist

## The Target

Learn why releases require verification beyond “tests passed once.”

## The Concept

A release is a public or operational promise. A checklist reduces the chance of publishing the wrong code, wrong version, wrong notes, or unreviewed work.

Think of it as a preflight checklist.

A small release checklist includes:

```text
Repository state
[ ] main is current and clean.
[ ] Relevant pull requests are merged.
[ ] No uncommitted files remain.

Quality
[ ] Tests pass locally.
[ ] CI passes on main.
[ ] Required reviews are complete.

Documentation
[ ] Release notes are accurate.
[ ] README examples match current behavior.

Versioning
[ ] package.json version is correct.
[ ] Git tag uses the matching v-prefixed version.

Publication
[ ] Tag points to the intended commit.
[ ] GitHub Release is created from the tag.
```

## The Implementation

Before creating a real release, run:

```bash
git switch main
git pull --ff-only
git status
npm test
git log --oneline --decorate -10
```

## The Verification

Expected status:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Expected tests:

```text
# fail 0
```

Do not create a release tag while the working tree is dirty or CI is failing.

---

# P10.7 Understand Annotated Tags

## The Target

Understand why releases use annotated Git tags.

## The Concept

Git has two common tag types.

### Lightweight Tag

A lightweight tag is only a named pointer:

```bash
git tag v1.0.0
```

### Annotated Tag

An annotated tag stores metadata:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
```

Annotated tags include:

```text
Tag name
Tagger name and email
Tag date
Message
Referenced commit
```

For releases, prefer annotated tags.

Think of the difference:

```text
Lightweight tag:
A sticky note with a version label.

Annotated tag:
A signed release card with a label, author, date, and message.
```

## The Implementation

Do not create a fake production release tag.

Inspect existing tags:

```bash
git tag --list
```

If `v1.0.0` exists, inspect it:

```bash
git show v1.0.0
```

For a future real release, the command is:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
```

Then publish it:

```bash
git push origin v1.0.0
```

## The Verification

An annotated tag displayed with:

```bash
git show v1.0.0
```

typically includes:

```text
tag v1.0.0
Tagger: Your Name <you@example.com>
Date:   ...

Release version 1.0.0
```

---

# P10.8 Understand GitHub Releases

## The Target

Understand how GitHub Releases build on Git tags.

## The Concept

A GitHub Release is a GitHub-hosted publication page based on a tag.

It may include:

```text
Release title
Release notes
Tag reference
Source-code archives
Uploaded files or binaries
Links to changes
```

The safe relationship is:

```text
Git tag
    ↓
points to exact source code
    ↓
GitHub Release
    ↓
explains and publishes that version
```

Avoid creating a GitHub Release from an unreviewed branch or an unpushed local tag.

## The Implementation

For a future release:

1. Create and push an annotated tag:

   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

2. On GitHub, open:

   ```text
   Repository → Releases → Draft a new release
   ```

3. Select the tag:

   ```text
   v1.0.0
   ```

4. Write release notes.
5. Publish the release.

With GitHub CLI:

```bash
gh release create v1.0.0 \
  --title "Release Notes Manager v1.0.0" \
  --generate-notes
```

Review generated notes before publishing them.

## The Verification

After publishing, inspect the release:

```bash
gh release view v1.0.0
```

Or open the GitHub Releases page.

Confirm:

```text
[ ] Release version matches the Git tag.
[ ] Release notes are accurate.
[ ] Tag points to the intended main commit.
[ ] Source archives are available.
```

---

# P10.9 Understand Hotfix Releases

## The Target

Recognize when a patch release should be created quickly from a known-good release.

## The Concept

A **hotfix** is an urgent correction for a released version.

Example:

```text
v1.0.0 is released.
    ↓
A critical bug is discovered.
    ↓
Create focused hotfix.
    ↓
Release v1.0.1.
```

A hotfix should be small and focused.

Do not include unrelated future features in an urgent patch release unless they are required for the fix.

## The Implementation

The basic hotfix pattern is:

```bash
git fetch origin --tags
git switch -c hotfix/critical-fix v1.0.0
```

Then:

```bash
npm test
git add <intended-files>
git commit -m "fix: correct critical release behavior"
git push -u origin hotfix/critical-fix
```

After review and merge, create a patch version:

```text
v1.0.1
```

## The Verification

Confirm the hotfix starts from the intended release:

```bash
git describe --tags --exact-match HEAD
```

At branch creation, expected output:

```text
v1.0.0
```

---

# P10.10 Release Vocabulary Reference

| Term | Meaning |
|---|---|
| Commit | A recorded Git snapshot |
| Version | Human-friendly identifier such as `1.0.0` |
| Tag | Git reference naming one exact commit |
| Annotated tag | Tag with metadata and a message |
| Release | Published version information, often on GitHub |
| Release notes | Human-readable summary of meaningful changes |
| Patch release | Backward-compatible bug-fix release |
| Minor release | Backward-compatible feature release |
| Major release | Breaking-change release |
| Pre-release | Testing version such as `1.1.0-beta.1` |
| Hotfix | Urgent focused patch for a released version |

---

# Primer 10 Completion Check

Before creating production releases, confirm that you can:

- [ ] Explain the difference between a commit, tag, and GitHub Release.
- [ ] Read a Semantic Version number.
- [ ] Distinguish patch, minor, and major version changes.
- [ ] Explain backward compatibility.
- [ ] Recognize pre-release version labels.
- [ ] Write user-focused release notes.
- [ ] Use a release checklist before tagging.
- [ ] Explain why annotated tags are preferred for releases.
- [ ] Describe the relationship between a Git tag and a GitHub Release.
- [ ] Explain the purpose of a focused hotfix release.

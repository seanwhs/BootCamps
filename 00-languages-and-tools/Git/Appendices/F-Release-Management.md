# Appendix F: Release Management, Semantic Versioning, and Git Tags

This appendix explains how to turn a stable commit into a recognizable software release.

A Git commit hash is precise, but not friendly:

```text
a1b2c3d4e5f67890...
```

A release version is easier for people and tools to understand:

```text
v1.0.0
```

Release management is the discipline of deciding:

- What is ready to ship.
- Which commit represents the shipped version.
- How the version should change.
- How users can find release notes and download the correct code.
- How urgent fixes are handled after a release.

For the `release-notes-manager` project, you will use:

- A protected `main` branch.
- Pull requests for changes.
- Git tags for release points.
- GitHub Releases for human-readable release notes.
- Semantic Versioning for version numbers.

---

# F.1 Understand the Difference Between a Commit, Tag, and GitHub Release

## The Target

Distinguish the three concepts used to identify published software.

## The Concept

These three terms are related but different.

| Concept | What it is | Example |
|---|---|---|
| Commit | A Git snapshot of project changes | `a1b2c3d` |
| Tag | A stable Git name pointing to a specific commit | `v1.0.0` |
| GitHub Release | A GitHub page built around a tag, with notes and downloadable source archives | “Release v1.0.0” |

Think of a book:

```text
Commit       = one saved manuscript revision
Tag          = the edition number printed on the cover
GitHub Release = the public launch announcement for that edition
```

A GitHub Release should normally be based on a Git tag.

```text
main history

A ── B ── C ── D
               ▲
               │
            v1.0.0 tag
               │
               ▼
      GitHub Release: v1.0.0
```

The tag ensures that anyone can retrieve the exact source code associated with the release.

---

# F.2 Semantic Versioning Basics

## The Target

Use a predictable version-number format for releases.

## The Concept

**Semantic Versioning**, often shortened to **SemVer**, uses this format:

```text
MAJOR.MINOR.PATCH
```

For example:

```text
1.4.2
```

Each number communicates the type of change:

| Segment | Example change | Meaning |
|---|---|---|
| MAJOR | `1.4.2` → `2.0.0` | Breaking changes that require users to change how they use the project |
| MINOR | `1.4.2` → `1.5.0` | New backward-compatible functionality |
| PATCH | `1.4.2` → `1.4.3` | Backward-compatible bug fixes |

Examples for Release Notes Manager:

```text
1.0.0
```

First stable public release.

```text
1.1.0
```

Adds a new backward-compatible section, such as `Security`, to the formatter.

```text
1.1.1
```

Fixes an incorrect date-validation edge case.

```text
2.0.0
```

Changes the formatter API in a way that breaks existing import or input usage.

For Git tags, prefix versions with `v`:

```text
v1.0.0
v1.1.0
v1.1.1
```

The `v` is a common Git convention. The project version in `package.json` generally omits it:

```json
{
  "version": "1.0.0"
}
```

---

# F.3 Define a Release Readiness Checklist

## The Target

Create a repeatable process for deciding whether `main` is ready to become a release.

## The Concept

A release should not be “the commit that happened to be latest when someone clicked a button.”

A release checklist is like an aircraft preflight inspection. It is repetitive on purpose: the cost of checking is small compared with the cost of shipping a known problem.

## The Implementation

Before creating a release, run these commands from the repository root:

```bash
git switch main
git pull --ff-only
git status
npm test
git log --oneline --decorate -10
```

Use this release checklist:

```text
Repository state
[ ] I am on the main branch.
[ ] main is synchronized with origin/main.
[ ] The working tree is clean.
[ ] No uncommitted generated files, logs, or secrets exist.

Quality
[ ] npm test passes locally.
[ ] The latest GitHub Actions workflow on main is green.
[ ] Pull-request discussions are resolved.
[ ] Required branch-protection checks passed before merged work entered main.

Documentation
[ ] README usage information matches the current behavior.
[ ] RELEASE_NOTES.md contains accurate release information.
[ ] Known limitations are documented when relevant.

Versioning
[ ] The new version follows Semantic Versioning.
[ ] package.json contains the intended version.
[ ] The Git tag will use the matching v-prefixed version.

Publication
[ ] The release tag points to the intended main commit.
[ ] GitHub Release notes accurately summarize user-visible changes.
```

## The Verification

Confirm the following command produces no uncommitted-file output:

```bash
git status
```

Expected output:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Confirm tests pass:

```bash
npm test
```

Expected output includes:

```text
# fail 0
```

---

# F.4 Prepare Release Notes for Version 1.0.0

## The Target

Add a stable release entry to `RELEASE_NOTES.md`.

## The Concept

Release notes explain what changed for users and contributors.

They are not a raw list of commit messages. They should summarize meaningful outcomes.

For the first stable version of this project, the release notes should describe:

- The formatter.
- Tests.
- Collaboration guidance.
- CI automation.
- Security guidance.

## The Implementation

Replace the complete contents of `RELEASE_NOTES.md` with this version.

### `release-notes-manager/RELEASE_NOTES.md`

```md
# Release Notes

## Unreleased

### Added

- No unreleased changes recorded yet.

## [1.0.0] - 2026-07-25

### Added

- A validated JavaScript release-note formatter.
- Automated tests using the built-in Node.js test runner.
- GitHub Actions continuous integration for pushes and pull requests.
- Pull request, issue, and code review guidance.
- Security guidance for secrets, credentials, and repository hygiene.
- Release checklists and documentation for local and remote Git workflows.

### Changed

- Project documentation now includes contributor and collaboration guidance.

### Fixed

- Release-date validation rejects malformed and impossible calendar dates.
```

Review the change:

```bash
git diff -- RELEASE_NOTES.md
```

Run tests:

```bash
npm test
```

Create a branch for the release preparation work:

```bash
git switch -c release/1.0.0
```

Stage and commit the release notes:

```bash
git add RELEASE_NOTES.md
git commit -m "Prepare release notes for version 1.0.0"
```

Push the branch:

```bash
git push -u origin release/1.0.0
```

Open a pull request from:

```text
release/1.0.0
```

into:

```text
main
```

Use this pull request title:

```text
Prepare version 1.0.0 release
```

Use this body:

```md
## Summary

Prepares the project for the first stable release.

## Changes

- Add release notes for version 1.0.0.
- Document user-visible formatter, testing, CI, collaboration, and security capabilities.

## Verification

```bash
npm test
```

## Release Checklist

- [ ] Release notes are accurate.
- [ ] Required CI checks pass.
- [ ] The pull request is reviewed.
- [ ] The branch is ready to merge into `main`.
```

## The Verification

On GitHub, confirm:

- The pull request targets `main`.
- CI succeeds.
- The rendered `RELEASE_NOTES.md` contains the `1.0.0` section.
- The PR does not include unrelated files.

Merge the PR through the repository’s normal protected-branch workflow.

Then update local `main`:

```bash
git switch main
git pull --ff-only
git fetch --prune
```

---

# F.5 Update the Project Version

## The Target

Confirm that `package.json` identifies the release as version `1.0.0`.

## The Concept

The Git tag tells Git which commit is released. The `package.json` version tells Node.js tooling and humans which project version they are using.

These version values should agree:

```text
package.json: 1.0.0
Git tag:      v1.0.0
GitHub Release: v1.0.0
```

If the version in `package.json` is different, users and automation can become confused about what source code corresponds to what release.

## The Implementation

Inspect the current version:

```bash
node --input-type=module --eval "import packageJson from './package.json' with { type: 'json' }; console.log(packageJson.version);"
```

If the result is already:

```text
1.0.0
```

no file change is required.

If your `package.json` version is not `1.0.0`, update it to this complete content.

### `release-notes-manager/package.json`

```json
{
  "name": "release-notes-manager",
  "version": "1.0.0",
  "private": true,
  "description": "A small project for learning professional Git and GitHub workflows.",
  "type": "module",
  "scripts": {
    "test": "node --test",
    "test:watch": "node --test --watch"
  },
  "engines": {
    "node": ">=18"
  }
}
```

Then commit the version update through a release-preparation pull request:

```bash
git switch -c release/confirm-version-1.0.0
git add package.json
git commit -m "Set project version to 1.0.0"
git push -u origin release/confirm-version-1.0.0
```

## The Verification

Run:

```bash
node --input-type=module --eval "import packageJson from './package.json' with { type: 'json' }; console.log(packageJson.version);"
```

Expected output:

```text
1.0.0
```

Run tests:

```bash
npm test
```

---

# F.6 Create an Annotated Git Tag

## The Target

Create an annotated `v1.0.0` tag on the final release commit.

## The Concept

An annotated tag is the Git-level release marker.

It identifies one exact commit as the release point and stores a message, tagger identity, and timestamp.

Use an annotated tag for releases:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
```

Avoid moving a published release tag. Once users depend on `v1.0.0`, that tag should always refer to the same source code.

## The Implementation

Confirm that `main` is clean, current, and tested:

```bash
git switch main
git pull --ff-only
git status
npm test
```

Confirm the version:

```bash
node --input-type=module --eval "import packageJson from './package.json' with { type: 'json' }; console.log(packageJson.version);"
```

Create the annotated tag:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
```

Inspect it:

```bash
git show v1.0.0
```

Push the tag:

```bash
git push origin v1.0.0
```

## The Verification

List the tag:

```bash
git tag --list v1.0.0
```

Expected output:

```text
v1.0.0
```

Confirm the tag points to the current `main` commit:

```bash
git rev-parse v1.0.0^{}
git rev-parse main
```

The two full hashes should match.

The `^{}` notation tells Git to dereference the annotated tag and return the commit it identifies.

Confirm the remote contains the tag:

```bash
git ls-remote --tags origin v1.0.0
```

Expected output resembles:

```text
<hash>    refs/tags/v1.0.0
<hash>    refs/tags/v1.0.0^{}
```

---

# F.7 Create a GitHub Release

## The Target

Create a public GitHub Release from the `v1.0.0` tag.

## The Concept

A Git tag identifies the code. A GitHub Release communicates the release to people.

A GitHub Release can include:

- A title.
- Release notes.
- Links to commit comparisons.
- Automatically generated source archives.
- Optional compiled assets, such as application binaries.

For this project, GitHub’s generated ZIP and TAR.GZ source archives are sufficient.

## The Implementation

On GitHub:

1. Open the repository.
2. Open the **Releases** page.
3. Select **Draft a new release**.
4. Under **Choose a tag**, select:

   ```text
   v1.0.0
   ```

5. Set the release title:

   ```text
   Release Notes Manager v1.0.0
   ```

6. Use this release description:

   ```md
   ## First Stable Release

   Release Notes Manager v1.0.0 provides a practical foundation for creating consistent Markdown release notes and managing project changes with professional GitHub workflows.

   ### Highlights

   - Validated `formatReleaseNotes` JavaScript API.
   - Automated Node.js tests.
   - GitHub Actions CI for pushes and pull requests.
   - Pull request, issue, contribution, and code review guidance.
   - Security and repository-hygiene documentation.
   - Release management workflow using Semantic Versioning and Git tags.

   ### Verification

   ```bash
   npm test
   ```

   ### Full Changelog

   See [RELEASE_NOTES.md](https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager/blob/v1.0.0/RELEASE_NOTES.md) for detailed release notes.
   ```

7. Replace `YOUR_GITHUB_USERNAME` with your actual account name.
8. Leave **Set as a pre-release** unchecked.
9. Leave **Set as the latest release** checked.
10. Select **Publish release**.

## The Verification

On the GitHub Releases page, confirm:

- `v1.0.0` appears as the latest release.
- The release title is correct.
- The release notes render correctly.
- GitHub provides source-code download links.
- The release is connected to the expected tag.

Open the tag’s commit and confirm it matches your intended release commit.

---

# F.8 Compare Releases and Inspect Changes Since a Tag

## The Target

Use Git to inspect changes made after a release.

## The Concept

After releasing `v1.0.0`, development continues on `main`.

To answer:

> “What changed since version 1.0.0?”

compare the tag to the current branch.

```text
v1.0.0 → commits added later on main
```

This is useful when preparing the next release notes.

## The Implementation

Show commits since the tag:

```bash
git log --oneline v1.0.0..main
```

Show changed files since the tag:

```bash
git diff --stat v1.0.0..main
```

Show complete file changes since the tag:

```bash
git diff v1.0.0..main
```

Show the code as it existed in the release:

```bash
git show v1.0.0:src/releaseNotes.js
```

## The Verification

Immediately after tagging and before later changes, this command may produce no output:

```bash
git log --oneline v1.0.0..main
```

That is expected. As new commits are merged, it will show the commits that belong in a future release.

---

# F.9 Create a Patch Release

## The Target

Understand the workflow for a backward-compatible bug-fix release.

## The Concept

A patch release fixes behavior without changing the public contract in a breaking way.

Example:

```text
v1.0.0 → v1.0.1
```

For example, if the formatter incorrectly rejects a valid leap-day date such as:

```text
2028-02-29
```

you would:

1. Open an issue.
2. Create a fix branch.
3. Add a regression test proving the failure.
4. Fix the implementation.
5. Open and merge a pull request.
6. Update release notes.
7. Update `package.json` to `1.0.1`.
8. Create and push tag `v1.0.1`.
9. Publish a GitHub Release.

## The Implementation

The safe command sequence is:

```bash
git switch main
git pull --ff-only
git switch -c fix/valid-leap-day-date
```

After implementing and testing the fix:

```bash
npm test
git add src/releaseNotes.js src/releaseNotes.test.js
git commit -m "Fix leap-day release date validation"
git push -u origin fix/valid-leap-day-date
```

After the pull request merges:

```bash
git switch main
git pull --ff-only
```

Update the version:

```json
{
  "version": "1.0.1"
}
```

Update `RELEASE_NOTES.md` with:

```md
## [1.0.1] - YYYY-MM-DD

### Fixed

- Accept valid leap-day release dates.
```

Then commit through a release PR, merge it, and create the tag:

```bash
git tag -a v1.0.1 -m "Release version 1.0.1"
git push origin v1.0.1
```

## The Verification

Before publishing, verify:

```bash
npm test
git status
git show v1.0.1
```

The release tag should point to a clean, tested `main` commit.

---

# F.10 Create a Minor Release

## The Target

Understand the workflow for a backward-compatible feature release.

## The Concept

A minor release adds functionality without breaking existing usage.

Example:

```text
v1.0.1 → v1.1.0
```

Suppose you add an optional `security` release-note section while preserving all existing formatter behavior.

That is a minor release because callers using only `added`, `changed`, and `fixed` continue to work.

## The Implementation

A typical feature sequence is:

```bash
git switch main
git pull --ff-only
git switch -c feature/add-security-release-section
```

Then:

```bash
npm test
git add src/releaseNotes.js src/releaseNotes.test.js README.md
git commit -m "Add security release note section"
git push -u origin feature/add-security-release-section
```

After the feature PR is merged, prepare the release:

```text
package.json version: 1.1.0
Git tag: v1.1.0
Release notes heading: ## [1.1.0] - YYYY-MM-DD
```

## The Verification

Before tagging:

```bash
git log --oneline v1.0.1..main
npm test
git status
```

The commit history should contain only changes intended for the upcoming minor release.

---

# F.11 Plan a Major Release Carefully

## The Target

Understand how to prepare a breaking-change release.

## The Concept

A major release changes a public behavior in a way that requires users to change their code or workflow.

For example, this is breaking:

```js
// Version 1.x API
formatReleaseNotes({
  version: "1.0.0",
  releaseDate: "2026-07-25"
});
```

```js
// Hypothetical Version 2.x API requiring a changed object shape
formatReleaseNotes({
  release: {
    version: "2.0.0",
    date: "2026-07-25"
  }
});
```

A major release requires more communication than a patch or minor release.

## The Implementation

For a planned breaking change:

1. Open a GitHub Issue explaining the migration impact.
2. Create a milestone such as:

   ```text
   v2.0.0
   ```

3. Document the old and new APIs.
4. Add a migration guide.
5. Consider deprecation warnings in a preceding minor release.
6. Update tests and documentation.
7. Clearly label breaking changes in the release notes.

Example release-note section:

```md
## [2.0.0] - YYYY-MM-DD

### Changed

- **Breaking:** `formatReleaseNotes` now expects the release date in the `date` property instead of `releaseDate`.

## Migration Guide

Before:

```js
formatReleaseNotes({
  version: "1.5.0",
  releaseDate: "2026-07-25"
});
```

After:

```js
formatReleaseNotes({
  version: "2.0.0",
  date: "2026-07-25"
});
```
```

## The Verification

Before publishing a major version, confirm:

```text
[ ] Breaking changes are clearly identified.
[ ] A migration path exists.
[ ] Tests cover old and new expectations where applicable.
[ ] README examples use the new API.
[ ] Release notes explain the migration.
[ ] Maintainers agree that the version increment is justified.
```

---

# F.12 Hotfix Branches for Urgent Production Problems

## The Target

Use a short-lived hotfix branch for an urgent bug in a released version.

## The Concept

A hotfix is an urgent patch for a released version.

Imagine version `v1.1.0` is released and a critical bug is discovered. You may need to fix it immediately rather than waiting for unrelated work currently in progress.

A hotfix branch begins from the released tag:

```text
main:      A ── B ── C ── D
                    ▲
                    │
                 v1.1.0

hotfix:             C ── H
```

The hotfix is then merged into `main`, tested, and released as `v1.1.1`.

## The Implementation

Create a hotfix branch from a release tag:

```bash
git fetch --tags origin
git switch -c hotfix/fix-critical-date-format v1.1.0
```

Implement the smallest safe correction, then:

```bash
npm test
git add src/releaseNotes.js src/releaseNotes.test.js
git commit -m "Fix critical release date formatting"
git push -u origin hotfix/fix-critical-date-format
```

Open a pull request into `main`.

After review and CI pass, merge it. Then prepare:

```text
package.json: 1.1.1
Git tag: v1.1.1
```

## The Verification

Confirm that the hotfix branch started from the intended release tag:

```bash
git merge-base --is-ancestor v1.1.0 hotfix/fix-critical-date-format
echo $?
```

On PowerShell:

```powershell
git merge-base --is-ancestor v1.1.0 hotfix/fix-critical-date-format
if ($LASTEXITCODE -eq 0) { Write-Output "The hotfix branch includes v1.1.0." }
```

A zero exit status indicates that `v1.1.0` is an ancestor of the hotfix branch.

---

# F.13 Release Command Reference

## Inspect Current Release State

```bash
git status
git log --oneline --decorate -10
git tag --list
git show v1.0.0
```

## Create an Annotated Tag

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
```

## Push One Tag

```bash
git push origin v1.0.0
```

## Push All Tags Intentionally

```bash
git push origin --tags
```

## Delete a Local Tag Before It Is Published

```bash
git tag -d v1.0.0
```

## Delete a Published Remote Tag

Avoid this for released versions unless the release was created in error and all users are informed.

```bash
git push origin --delete v1.0.0
git tag -d v1.0.0
```

## Compare a Release Tag with Current Main

```bash
git log --oneline v1.0.0..main
git diff --stat v1.0.0..main
```

## Create a Branch from a Release Tag

```bash
git switch -c hotfix/short-description v1.0.0
```

---

# Appendix F Completion Check

You should now be able to:

- [ ] Explain the difference between a commit, Git tag, and GitHub Release.
- [ ] Apply Semantic Versioning to patch, minor, and major changes.
- [ ] Use a release-readiness checklist.
- [ ] Write useful release notes for users.
- [ ] Create and inspect annotated tags.
- [ ] Push release tags to GitHub.
- [ ] Create GitHub Releases from tags.
- [ ] Compare current work against a prior release.
- [ ] Plan patch, feature, major, and hotfix releases safely.

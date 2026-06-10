# Agent Instructions

This is a personal GNU Guix channel.

It contains Guix package definitions for personal packages. The repository is intentionally small. Keep it boring, explicit, and easy to audit.

## Repository conventions

Package modules live under `omiya/packages`.

The file path must match the Guile module name:

```scheme
omiya/packages/example.scm -> (omiya packages example)
```

Every Guix package defined in this repository must use the `omiya-` package-name prefix.

Good:

```scheme
(define-public omiya-example
  (package
    (name "omiya-example")
    ...))
```

Bad:

```scheme
(define-public example
  (package
    (name "example")
    ...))
```

The installed command does not need the `omiya-` prefix. For example, package `omiya-antigravity` may install a command named `antigravity`.

## Channel authentication

This is an authenticated Guix channel.

Do not rewrite Git history unless explicitly instructed.

Do not create unsigned commits. Use signed commits:

```sh
git commit -S
```

Before pushing, verify the newest commit:

```sh
git log --show-signature -1
```

Do not edit `.guix-authorizations` unless the task is specifically about channel authentication. If it must be edited, verify the file with Guix before pushing.

The `.guix-authorizations` file must contain an `(authorizations ...)` form. Do not add unrelated top-level forms.

## Source policy

Prefer ordinary Guix `origin` sources when an upstream source archive is publicly available and redistributable.

For nonfree or local-only binary packages, it is acceptable to use `local-file`, but make that explicit in the package:

```scheme
(define %example-source-directory
  "/some/local/path")
```

Add a short comment explaining that the package is local and non-substitutable.

Do not commit proprietary binary payloads, vendored application directories, credentials, API keys, caches, build outputs, or local machine state.

## Binary package policy

For prebuilt ELF binaries, do not manually call `patchelf` from a custom build phase unless there is no better build-system support.

Prefer declarative Nonguix build systems:

* Use `nonguix build-system binary` with `#:patchelf-plan` for simple prebuilt binary packages.
* Use `nonguix build-system chromium-binary` with `#:wrapper-plan` for Electron/Chromium-style application bundles.

The build system may use `patchelf` internally. That is fine. The rule is: package definitions should describe patching declaratively instead of shelling out to `patchelf` manually.

## Testing requirements

Before committing a package change, test from the repository root.

For a changed package named `omiya-example`, run:

```sh
guix build -L . omiya-example
guix search -L . omiya-example
```

If the package installs a command, also check that the command exists in the build result:

```sh
test -x result/bin/example
```

For CLI tools, run a lightweight smoke test when possible:

```sh
timeout 10s result/bin/example --version || true
timeout 10s result/bin/example --help || true
```

Do not treat an expected GUI startup failure in a headless environment as fatal. Do treat missing executables, missing dynamic linkers, missing shared libraries, and immediate loader errors as fatal.

For binary packages, inspect ELF patching when relevant:

```sh
guix shell patchelf -- patchelf --print-interpreter result/bin/example
guix shell patchelf -- patchelf --print-rpath result/bin/example
guix shell patchelf -- patchelf --print-needed result/bin/example
```

If `result/bin/example` is a wrapper script or symlink, inspect the real target:

```sh
readlink -f result/bin/example
file "$(readlink -f result/bin/example)"
```

For Electron/Chromium-style packages, also verify that the installed launcher exists and points into the installed application tree:

```sh
test -x result/bin/example
readlink -f result/bin/example
```

Optional but useful:

```sh
guix lint -L . omiya-example
```

Report lint warnings. Do not make broad unrelated changes just to silence warnings, especially for local nonfree binary packages where some warnings are expected.

## Testing the whole channel

After changes that affect channel structure, module names, package names, or authentication, run broader checks:

```sh
guix package -L . --list-available='^omiya-'
guix build -L . omiya-hello
```

If a new package is added, make sure it appears in package search:

```sh
guix search -L . omiya-new-package
```

If channel authentication changed, test authentication before pushing:

```sh
guix git authenticate COMMIT FINGERPRINT --stats
```

Use the channel introduction commit and authorized OpenPGP fingerprint from the user's `channels.scm`.

## Commit discipline

Keep commits small and conceptual.

Good commit examples:

```text
Add omiya-example package
Fix omiya-antigravity launcher
Update omiya-opencode to 1.18.0
```

Bad commit examples:

```text
misc
fix stuff
update
```

Run `git diff` before committing. Do not include unrelated formatting churn unless the task is explicitly a formatting cleanup.

Use signed commits:

```sh
git add FILES
git commit -S -m "Meaningful commit message"
git log --show-signature -1
```

Only push after the relevant build and smoke checks pass.

## Do not speak of the dead

Do not write comments or documentation that describe the previous implementation, the prompt, the agent's process, or how the new version is better than the old one.

The repository should describe what exists now.

Good:

```scheme
;; Local non-substitutable binary directory.
```

Bad:

```scheme
;; Previously this used a hardcoded path, but now it is better.
```

Good:

```markdown
Use `binary-build-system` for simple prebuilt ELF packages.
```

Bad:

```markdown
The agent changed this from `trivial-build-system`.
```

Only the current codebase matters.

## Final report format

When finishing a task, report:

* files changed
* packages changed
* commands run
* whether each required build passed
* whether runtime smoke checks passed
* whether the commit was signed
* whether the push succeeded

Be explicit about anything not tested.

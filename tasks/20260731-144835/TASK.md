# Release flow: CHANGELOG, semver tags, GitHub release notes

- STATUS: CLOSED
- PRIORITY: 0
- TAGS: release, tooling
- KIND: TASK
- FLOW STEP: DONE
- PLAN STATUS: APPROVED

Give macros.nvim a release flow modelled on `~/personal/nova-protocol`:
Keep a Changelog `CHANGELOG.md`, semver `vX.Y.Z` tags, a tag-triggered GitHub
Release, and a written procedure in a new root `AGENTS.md`. Choices recorded in
`DECISION.md` (LuaRocks job dropped). Deliberately small: no extraction script,
no new tooling - the CHANGELOG is written by hand and the release page is
GitHub's own generated notes.

## Definition of Done

- `CHANGELOG.md` follows Keep a Changelog with a rolling empty `## [Unreleased]` heading (cmd: `grep -q '^## \[Unreleased\]$' CHANGELOG.md && grep -q 'Keep a Changelog' CHANGELOG.md`).
- The backfill covers the shipped feature surface from the 2024-02-04 initial commit through 2026-07-31 (cmd: `[ "$(grep -ciE 'MacrosInsert|telescope|cmp' CHANGELOG.md)" -ge 3 ]`).
- `.github/workflows/release.yml` publishes a GitHub Release on a semver tag and no longer touches LuaRocks (cmd: `! grep -riq luarocks .github/ && grep -q 'gh release create' .github/workflows/release.yml`).
- `lint-test.yml` is callable, so the release gates on lint+tests instead of erroring on a non-`workflow_call` workflow (cmd: `grep -q 'workflow_call' .github/workflows/lint-test.yml`).
- Root `AGENTS.md` carries the cutting-a-release procedure and the `## Agent workflow` cache (cmd: `grep -q '^## Agent workflow' AGENTS.md && grep -q 'git tag' AGENTS.md`).
- The plugin test suite still passes (cmd: `make test`).
- Cutting `v0.1.0` produces a GitHub Release that reads as the release (manual: user judgement).

## Steps

1. Add `CHANGELOG.md`: Keep a Changelog + SemVer preamble, empty
   `## [Unreleased]`, and the backfilled history under it (Added/Changed/Fixed,
   one short line each) from `git log --reverse` - `:Macros`, `:MacrosInsert`,
   file-backed then data-dir database, fractional amounts, query database,
   nvim-cmp completion, telescope picker + query-inserts-macros, CLI tool,
   config validation. No `[0.1.0]` heading yet: the first tag promotes
   `[Unreleased]`, so the CHANGELOG never claims a release that has no tag.
   Bottom link block: `[unreleased]` -> `.../commits/main` until the first tag.
2. Add `workflow_call:` to the `on:` triggers of
   `.github/workflows/lint-test.yml` (currently `[push, pull_request]`, which
   makes release.yml's `uses: ./.github/workflows/lint-test.yml` fail).
3. Rewrite `.github/workflows/release.yml`: trigger on
   `v[0-9]+.[0-9]+.[0-9]+*`, keep the `test` job calling lint-test, drop the
   `luarocks-upload` job, add a `release` job (`needs: test`,
   `permissions: contents: write`) that checks out and runs
   `gh release create "$TAG" --title "$TAG" --generate-notes` with `TAG` from
   `GITHUB_REF` and `GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`.
4. Add root `AGENTS.md`: project one-liner, layout, `make test`, the CHANGELOG
   contract (every user-visible change gets an `[Unreleased]` line), the
   cutting-a-release procedure (promote `[Unreleased]` to
   `[X.Y.Z] - YYYY-MM-DD`, fresh empty `[Unreleased]`, repoint the link block,
   `chore(release): vX.Y.Z` commit, `git tag vX.Y.Z`, push branch then tag,
   `gh run watch`, then optionally paste the CHANGELOG section over the
   generated notes with `gh release edit`), and a `## Agent workflow` section
   with the tracker/examples/docs/checks pointers.
5. Run every DoD proof; hand the manual `v0.1.0` tag step to the user.

## Notes

- CORRECTED DURING WORK: the repo does carry a version, twice - `VERSION` in
  `macros.lua:7` and `version` in `flake.nix:30`, both `0.1.0`. The plan's
  "no version constant" note came from grepping only `lua/` and `plugin/`. The
  procedure bumps both and the release job guards the tag against them.
- `.github/workflows/release.yml` on `main` is already broken: it calls
  lint-test.yml as a reusable workflow, but that file declares no
  `workflow_call` trigger. Step 2 fixes it.
- Release notes are GitHub's `--generate-notes` (commit/PR list). The CHANGELOG
  stays the curated human record; pasting it into the release page is an
  optional manual step in the procedure, not CI machinery.
- ASSUMPTION: first tag is `v0.1.0`, cut by the user after landing.
- `docs/` guard, news posts, and multi-platform build jobs from nova-protocol
  do not transfer - no such surfaces here.

## Close-out

WHAT: `CHANGELOG.md` (Keep a Changelog, backfilled history under a rolling
`[Unreleased]`), a rewritten `.github/workflows/release.yml` that gates on
lint+tests, checks the tag against the declared version and publishes a GitHub
Release with generated notes, `workflow_call` on `lint-test.yml`, and a root
`AGENTS.md` holding the release procedure and the `## Agent workflow` cache.

WHY: the repo had no changelog, no tags and a release workflow that could not
run. Modelled on `~/personal/nova-protocol`, minus the surfaces that do not
exist here.

ALTERNATIVES: a `changelog-extract.sh` feeding `--notes-file` was planned and
rejected by the user as overcomplicated; GitHub's generated notes carry the
release page and the CHANGELOG stays the human record.

DIFFICULTIES: two discoveries the plan missed, both found by reading the code
and running actionlint rather than by the plan's greps -
(1) `macros.lua` and `flake.nix` each declare a version, so "the tag is the
sole version of record" was false; hence the two-file bump step and the tag
guard.
(2) every workflow pinned `actions/checkout@v3` / `actions/cache@v3`, which
GitHub no longer runs - so the release's own lint+test gate would have failed
on the first tag. Bumped to `@v4` across `lint-test.yml` and `docs.yml`; in
scope because the release depends on that workflow succeeding.

EVIDENCE: all six `cmd:` proofs green in the worktree, `make test` green,
`actionlint` clean on all three workflows, and the guard's shell logic
exercised locally (`v0.1.0` passes, `v0.2.0` fails).

REFLECTION: the plan asserted a repo-wide absence from a two-directory grep.
An absence claim needs a repo-wide search before it becomes a Note. Reaching
for actionlint early would have surfaced the `@v3` break at plan time.

PENDING MANUAL: cut `v0.1.0` and confirm the release page reads correctly.

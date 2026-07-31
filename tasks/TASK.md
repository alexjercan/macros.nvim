# Release flow: CHANGELOG, semver tags, GitHub release notes

- STATUS: IN_PROGRESS
- PRIORITY: 0
- TAGS: release, tooling
- KIND: TASK
- FLOW STEP: WORKING
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

- No version constant exists anywhere in the repo (`grep -rn version lua plugin`
  finds only a Neovim-version health check, no rockspec) - the tag is the sole
  version of record, so the procedure has no bump step.
- `.github/workflows/release.yml` on `main` is already broken: it calls
  lint-test.yml as a reusable workflow, but that file declares no
  `workflow_call` trigger. Step 2 fixes it.
- Release notes are GitHub's `--generate-notes` (commit/PR list). The CHANGELOG
  stays the curated human record; pasting it into the release page is an
  optional manual step in the procedure, not CI machinery.
- ASSUMPTION: first tag is `v0.1.0`, cut by the user after landing.
- `docs/` guard, news posts, and multi-platform build jobs from nova-protocol
  do not transfer - no such surfaces here.

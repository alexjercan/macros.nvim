# Review: Release flow: CHANGELOG, semver tags, GitHub release notes

- TASK: 20260731-144835
- BRANCH: feature/release-flow

## Round 1

- REVIEWER: in-session (operator constraint: this session may not spawn
  subagents; diff is CI config plus docs, no plugin code)
- VERDICT: APPROVE

- [x] R1.1 (MINOR) CHANGELOG.md:34 - "A queried food item's macros are inserted
  on the next line instead of overwriting the current one" is wrong on both
  halves. Only the telescope path inserts a new line
  (`lua/macros/telescope.lua:98`, `nvim_buf_set_lines` at `target_line`);
  `:MacrosQuery` / `:MacrosQuery2` append to the end of the current line
  (`lua/macros.lua:146`, `nvim_buf_set_text` at column `#lines[line]`), and
  neither ever overwrote it. Narrow the line to the telescope picker and drop
  the "instead of overwriting" clause.
  - Response: CHANGELOG.md entry narrowed to the telescope picker; the "instead of overwriting" clause is gone.
- [x] R1.2 (MINOR) .github/workflows/release.yml:5 - the tag glob
  `v[0-9]+.[0-9]+.[0-9]+*` admits prerelease tags (`v0.2.0-rc1`) that the
  version guard below can never satisfy: it compares the whole `${tag#v}`
  against the literals in `macros.lua` / `flake.nix`, so `0.2.0-rc1` fails
  (verified locally, rc=1) and the workflow dies at the guard. Drop the
  trailing `*` so the trigger matches exactly what the guard accepts.
  - Response: Trailing `*` dropped from the tag glob, with a comment tying it to the guard.
- [x] R1.3 (NIT) .github/workflows/lint-test.yml:2 - `push:` carries no branch
  filter, so a release tag triggers lint-test standalone AND through
  release.yml's `test` job: two identical matrix runs per tag. Add
  `branches: [main]` under `push:`.
  - Response: `push:` filtered to `branches: [main]`.
- [x] R1.4 (NIT) .github/workflows/release.yml:26 - the guard greps for
  `"X.Y.Z"` anywhere in the file. Anchor it (`VERSION = "X.Y.Z"`,
  `version = "X.Y.Z"`) so an unrelated occurrence of the string cannot satisfy
  it.
  - Response: Guard anchored to `^local VERSION = "X.Y.Z"$` and `version = "X.Y.Z";`, one check per file with its own message.

Verified in this round:

- All six `cmd:` proofs re-run in the worktree: green.
- `make test`: green.
- `actionlint` on all three workflows: clean (rc=0). The `@v3` -> `@v4` bump in
  the diff is what makes it clean; on `main` actionlint rejects those pins, so
  the release's own lint+test gate would have failed at the first tag.
- Version guard logic re-derived by hand: `v0.1.0` passes against
  `macros.lua:7` and `flake.nix:30`, `v0.2.0` fails.
- Close-out claims in TASK.md check out against the diff; the plan's corrected
  "no version constant" note is recorded in both TASK.md and DECISION.md.
- Spot-checked changelog entries against code/history: config validation
  (76910ed), numbered query results (ba49f9a), lazy telescope
  (`lua/macros.lua:193` `pcall`), cmp source, units per README. Only the
  next-line entry (R1.1) is inaccurate.

Pending user checks:

- `manual:` cutting `v0.1.0` and confirming the GitHub Release page reads as
  the release. Not resolvable in review.

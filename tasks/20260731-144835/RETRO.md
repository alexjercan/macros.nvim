# Retro: Release flow: CHANGELOG, semver tags, GitHub release notes

- TASK: 20260731-144835
- BRANCH: feature/release-flow
- REVIEW ROUNDS: 1

## What went well

- Reading the reference repo (`~/personal/nova-protocol`) for the SHAPE and
  then discarding the surfaces it has that this repo does not (docs guard, news
  posts, binary builds) kept the transfer honest instead of cargo-culted.
- The user cut the plan down mid-flow (no extraction script). The reduced plan
  was re-proofed before building, so nothing half-removed survived into work.
- Review re-derived claims from the code rather than from the close-out, which
  is the only reason the inaccurate telescope changelog entry was caught.

## What went wrong

- The plan asserted "no version constant exists anywhere in the repo" from a
  grep over `lua/` and `plugin/` only. Two existed (`macros.lua:7`,
  `flake.nix:30`). It seemed sound because those directories are where a
  Neovim plugin's code lives - but the CLI entry point and the flake sit at the
  root, outside that mental model of "the code". The shape of the release
  procedure (bump step, CI version guard) depended on that false claim.
- The plan never linted the CI it was about to build on. Every workflow pinned
  `actions/checkout@v3` / `actions/cache@v3`, which GitHub no longer runs, so
  the release's own lint+test gate would have failed at the first tag. One
  `actionlint` run at plan time would have surfaced it.

## What to improve next time

- Any "no X exists in this repo" claim is repo-wide or it is not made.
- When a task's deliverable is CI, run the CI linter over the existing
  workflows during planning - the base state is part of the spec.

## Action items

- None requiring a follow-up task. Both lessons are ledger entries.

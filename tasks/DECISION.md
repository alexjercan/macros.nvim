# Decision: Release flow: CHANGELOG, semver tags, GitHub release notes

- DATE: 20260731-145412
- STATUS: ACCEPTED
- TASK: 20260731-144835
- TAGS: release, tooling

## Context

macros.nvim has no CHANGELOG, no tags, no release procedure and no AGENTS.md.
`.github/workflows/release.yml` fires on `v*` tags and only uploads to
LuaRocks. Goal: a release flow modelled on `~/personal/nova-protocol` -
Keep a Changelog + semver tags.

Transferable from nova-protocol: CHANGELOG format with a rolling
`## [Unreleased]` and compare links, a tag-triggered release workflow, a
written cutting-a-release procedure, an `## Agent workflow` cache in AGENTS.md.
NOT transferable: multi-platform binary builds, news posts, wiki, docs/ guard
(no such surfaces here).

## Decision

1. Tag `vX.Y.Z` publishes a GitHub Release whose notes are that version's
   section extracted from `CHANGELOG.md`. The LuaRocks upload job is REMOVED -
   user has no LuaRocks presence and does not want one.
2. Release procedure lives in a new repo-root `AGENTS.md`, including the
   `## Agent workflow` pointer lines the global agent rules expect.
3. `CHANGELOG.md` is backfilled from git history (2024-02-04 .. now) as an
   initial released version, with an empty `## [Unreleased]` on top.
4. No version constant to bump - nothing in the repo carries a version, so the
   tag is the sole version of record.

## Alternatives considered

- Keep the LuaRocks job: rejected by the user.
- Procedure in CONTRIBUTING.md or README: rejected - AGENTS.md doubles as the
  agent workflow cache the global rules require.
- Empty CHANGELOG seeded only with `[Unreleased]`: rejected - two years of
  shipped behaviour would be unattributed.

## Consequences

- First tag must be chosen deliberately (backfill version) - see plan.
- Release notes quality is now a function of CHANGELOG discipline during a
  cycle; every user-visible change needs a CHANGELOG line.
- CI gains a dependency on the extraction script; a malformed CHANGELOG
  section fails the release rather than shipping empty notes.

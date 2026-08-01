# AGENTS.md

macros.nvim - a Neovim plugin that computes the macros (protein, carbs, fats)
of a food item written as `<name> <amount><unit>`.

## Layout

| Path | What |
| --- | --- |
| `plugin/macros.lua` | User commands. |
| `lua/macros/` | Plugin modules (database, food parsing, units, cmp source, telescope picker, health). |
| `macros.lua` | Standalone CLI over the same modules, via a `vim` shim. |
| `tests/` | plenary busted specs. |
| `doc/` | vimdoc, auto-generated from `README.md` by `.github/workflows/docs.yml`. Never hand-edit. |
| `tasks/` | tatr task records. |

## Checks

- `make test` - plenary suite (the only local check).
- Lint in CI: `stylua --check lua`, `luacheck lua/`.
- `nix develop` provides lua, luacheck and stylua.

## Changelog

Every user-visible change adds one short line under `## [Unreleased]` in
`CHANGELOG.md`, in `Added` / `Changed` / `Fixed`. Internal refactors and task
records do not. Rationale and worked examples belong in the README or the task
record, not the changelog.

## Cutting a release

The version is declared in two places and CI refuses a tag that disagrees with
them: `VERSION` in `macros.lua` and `version` in `flake.nix`.

On `main`, for version `X.Y.Z`:

1. Bump `VERSION` in `macros.lua` and `version` in `flake.nix`.
2. In `CHANGELOG.md`, promote `## [Unreleased]` to `## [X.Y.Z] - YYYY-MM-DD`,
   leave a fresh empty `## [Unreleased]` above it, and merge any duplicate
   section headings that grew during the cycle.
3. Repoint the link block at the bottom: `[unreleased]` compares
   `vX.Y.Z...HEAD`, and add `[X.Y.Z]` (a compare against the previous tag, or
   `releases/tag/vX.Y.Z` for the first one).
4. `git commit -m "chore(release): vX.Y.Z"` with exactly those three files.
5. `git tag vX.Y.Z`
6. `git push origin main && git push origin vX.Y.Z`
7. Watch it (`gh run watch`). The `release` workflow runs lint+tests, checks
   the tag against the declared version, and publishes a GitHub Release with
   generated notes.
8. Optional: replace the generated notes with the changelog section -
   `gh release edit vX.Y.Z --notes-file <section>`.

## Agent workflow

- Tracker: `tatr` over `tasks/`; one task per change, records in `tasks/<id>/`.
- Examples and scripts: none - this repo has no `scripts/`; the CLI at
  `macros.lua` is the runnable example.
- Domain docs: `README.md` is the source of truth; `doc/` is generated from it.
- Research and network: none required; the food database is local CSV.
- Checks and records: `make test` before every commit; durable task evidence
  stays in task records.
- Knowledge: central repo `/home/alex/personal/agent-knowledge`; project=macros.nvim; tags=neovim,lua,macros. Advisory only; failed writes stay in RETRO.

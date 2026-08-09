# AGENTS.md

Repository guidance. Global `~/AGENTS.md` applies.

## Project

- Neovim plugin and standalone Lua CLI for food macro calculations.
- Plugin code: `lua/macros/`. Commands: `plugin/macros.lua`.
- `macros.lua` is the CLI over the same modules through a `vim` shim.

## Agent workflow

- Tracker/epics: tatr records under `tasks/<id>/`; one requested change per
  task.
- Examples/retention: `macros.lua` is the runnable example; no separate example
  or script directory.
- Domain docs: `README.md` is authoritative; `doc/` is generated from it.
- Research/network: use the local CSV and source; no network is required.
- Checks/records: run `make test`; keep durable evidence in the task directory.

## Rules

- Never hand-edit `doc/`.
- CI also runs `stylua --check lua` and `luacheck lua`.
- User-visible changes need one short `CHANGELOG.md` line under Unreleased.
  Skip internal refactors, tests, and task records.
- Put rationale and worked examples in README or the task record.

## Release

- Keep `VERSION` in `macros.lua` equal to `version` in `flake.nix`.
- Promote the Unreleased changelog section and update compare links.
- Commit only `macros.lua`, `flake.nix`, and `CHANGELOG.md` for the release.
- Tag `vX.Y.Z`. Push and edit release notes only when requested.

# AGENTS.md

Global `~/AGENTS.md` applies.

## Project

- Neovim plugin and standalone Lua CLI for food macro calculations.
- Plugin modules live in `lua/macros/`. Commands live in `plugin/macros.lua`.
- `macros.lua` provides the CLI over the same modules through a `vim` shim.

## Agent workflow

- Work directly on `main` unless the user requests an isolated worktree.
- Use tatr for tracked work. Create a task only when the user requests one.
- Use one task for one user request and its follow-up work. Create dependent
  tasks only when the user requests decomposition.
- Store task records under `tasks/<id>/` and keep durable evidence with the
  task.
- Treat `README.md` as authoritative. `doc/` is generated from it.
- Use the local CSV and source before network research.

## Conventions

- Keep plugin and standalone CLI behavior in shared `lua/macros/` modules.
- Match neighboring Lua style and format Lua with StyLua.
- Lint Lua with Luacheck.
- Never hand-edit generated files under `doc/`.
- Use `macros.lua` as the runnable CLI example. Do not add a separate examples
  or scripts directory without a concrete need.
- Add one short `CHANGELOG.md` line under Unreleased for user-visible changes.
  Skip internal refactors, tests, and task records.
- Put durable rationale and worked examples in `README.md`. Keep transient
  evidence with the task.

## Verification

Run the relevant checks:

```bash
make test
stylua --check lua
luacheck lua
```

## Release

- Keep `VERSION` in `macros.lua` equal to `version` in `flake.nix`.
- Promote the Unreleased changelog section and update compare links.
- Commit only `macros.lua`, `flake.nix`, and `CHANGELOG.md` for the release.
- Tag `vX.Y.Z`. Push and edit release notes only when requested.

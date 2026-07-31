# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). Entries are short -
one line each. Breaking changes are tagged **(breaking)**.

## [Unreleased]

## [0.1.0] - 2026-07-31

The first tagged release. Everything below shipped before the project started
tagging.

### Added

- `:Macros` - annotate the food item under the cursor with its protein, carbs and fats.
- `:MacrosInsert` - add the food item on the current line to the database.
- `:MacrosQuery` (prefix search) and `:MacrosQuery2` (fuzzy search) - prompt for input, list matching food items and insert the pick.
- `:MacrosTelescope` - telescope.nvim picker with live fuzzy search that inserts the selected item's macros.
- `:MacrosReload` - re-run `setup()` with the current config.
- nvim-cmp completion source for food items, by name and unit.
- `:checkhealth macros` - Neovim compatibility, database state, CSV availability and optional integrations.
- Food database from a CSV in the Neovim data directory, plus inline `items` passed to `setup()`.
- Standalone `macros.lua` CLI (`macros "egg 2p"`), packaged by the flake with an overlay.
- Grams (`g`, `gr`, `gram`, `grams`) and pieces (`p`, `pc`, `pcs`, `piece`, `pieces`) as measuring units.

### Changed

- The database path is no longer required in the config: it defaults to the Neovim data directory.
- telescope.nvim is lazy-loaded, so the plugin no longer needs it installed.
- The telescope picker inserts the selected item's macros on the next line, and moves the cursor there.

### Fixed

- Food items with fractional amounts parse correctly.
- `setup()` validates the config object rather than its own arguments.
- Query results are numbered.

[unreleased]: https://github.com/alexjercan/macros.nvim/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/alexjercan/macros.nvim/releases/tag/v0.1.0

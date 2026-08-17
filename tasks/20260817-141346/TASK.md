# Add JSON food search and calculation CLI

- STATUS: CLOSED
- PRIORITY: 100
- TAGS: cli, json, dashboardd

Add a deterministic machine-readable food search and calculation interface for Today dashboard integration.

## Requirements

- Replace the ad hoc standalone CLI grammar with explicit `search`, `calculate`, and `insert` commands.
- Support JSON output for search and calculation.
- Return stable food IDs, canonical units, and deterministic fuzzy results.
- Accept an explicit database path through `--database` or `MACROS_DATABASE`.
- Keep the Neovim plugin behavior intact.
- Add CLI integration tests and update public documentation.

## Definition of Done

- Search JSON is safe to consume without parsing display text.
- Calculation uses a selected food ID and positive quantity.
- Gram and piece entries calculate correctly.
- Errors are nonzero and go to stderr.
- `make test` and lint checks pass.

## Implementation

- Added stable food IDs in the form `<lowercase-name>:<canonical-unit>`.
- Added deterministic machine-readable fuzzy search and ID-based calculation.
- Replaced the standalone CLI grammar with explicit `search`, `calculate`, and
  `insert` commands.
- Added `--json`, `--database`, and `MACROS_DATABASE` support.
- Kept plugin query and lookup behavior on the shared database model.

## Verification

- `stylua --check lua macros.lua tests/macros`: passed.
- `luacheck lua macros.lua`: passed with zero warnings.
- `make test`: passed 31 Lua tests and the CLI integration script.
- `nix build .#default`: passed.
- The packaged executable returned valid search and calculation JSON for a
  piece-based fixture.

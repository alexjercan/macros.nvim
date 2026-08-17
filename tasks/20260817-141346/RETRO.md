# Retro: Add JSON food search and calculation CLI

- TASK: 20260817-141346
- BRANCH: main
- REVIEW ROUNDS: 1

## What went well

- Stable IDs reuse the database's natural name-and-unit identity, so search and
  calculation do not need another persistent identifier.
- Keeping search and calculation in the database model lets the Neovim plugin
  and standalone CLI share parsing and scaling behavior.
- A shell integration test validates the exact JSON consumed by Today and the
  packaged executable was tested separately.

## What went wrong

- The first check stopped on formatting differences in the rewritten root CLI.
  Running Stylua before the full check fixed it.

## What to improve next time

- Format complete rewrites before the first lint batch.
- Test machine interfaces by exact output and through the packaged executable.

## Action items

- Today must pin this package and consume only its JSON interface.

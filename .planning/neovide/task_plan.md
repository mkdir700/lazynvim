# Neovide configuration

## Goal
Provide a complete, maintainable Neovide setup without affecting terminal Neovim.

## Completion criteria
- [x] Neovide-only settings live in one focused module.
- [x] Font, window appearance, cursor animation, zoom, and macOS clipboard shortcuts work.
- [ ] Existing unrelated working-tree changes are preserved.
- [ ] Headless Neovim loads without errors.
- [ ] Neovide starts and remains running without startup errors.

## Phases
- [complete] Inspect current configuration and local Neovide capabilities.
- [complete] Implement the smallest complete configuration.
- [in_progress] Run static, headless, and GUI startup verification.

## Errors Encountered
- The initial terminal isolation check assumed `guifont` would be empty, but LazyVim supplies its own default. Replaced this with checks for Neovide-only globals and mappings.

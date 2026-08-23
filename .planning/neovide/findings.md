# Findings

- Neovide is installed at `/opt/homebrew/bin/neovide`.
- Neovim 0.12.4 is installed.
- Existing Neovide globals are embedded in `lua/config/options.lua`, including two assignments to the same cursor effect.
- Installed font: `JetBrainsMono Nerd Font Mono` with regular and bold faces.
- Existing user changes in `lazy-lock.json`, `lua/plugins/flatten.lua`, and `lua/plugins/ui/colorscheme.lua` must remain untouched.

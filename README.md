# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Quickstart

- Make a backup of your current configuration

```bash
# required
mv ~/.config/nvim{,.bak}

# optional but recommended
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}
```

- Clone the repository

```bash
git clone https://github.com/mkdir700/lazynvim.git ~/.config/nvim
```

- Remove the `.git` folder, so you can add it to your own repository

```bash
rm -rf ~/.config/nvim/.git
```

- Start Neovim!

```bash
nvim
```

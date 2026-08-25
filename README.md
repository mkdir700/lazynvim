# Neovim 配置

一套基于 [LazyVim](https://www.lazyvim.org/) 的个人开发配置，重点优化代码导航、
终端、剪贴板、会话恢复、AI 辅助和 Neovide 桌面体验。

## 主要特性

- 使用 Kanagawa Wave 主题、浮动文件树和紧凑状态栏。
- 内置 TypeScript、Python、Rust、.NET、Markdown、JSON 和 TOML 开发支持。
- Rust 和 .NET 支持会根据本机是否安装 `rustup`、`dotnet` 自动启用。
- 粘贴多行代码到空括号时自动缩进；重命名符号后自动保存受影响的文件。
- 终端会记住上次所在的上、下、左、右位置，并可快速隐藏和恢复。
- 支持恢复当前目录或上一次编辑会话。
- 支持 GitHub Copilot 的下一处编辑建议，以及 Sidekick 中的 Codex 等命令行助手。
- 在 SSH 和 WSL 环境中提供更可靠的系统剪贴板支持。
- Neovide 下提供窗口留白、平滑动画、模糊背景和 macOS 常用快捷键。

## 安装

需要：

- Neovim 0.11.2 或更高版本
- Git

建议同时准备支持图标的 Nerd Font，以免界面图标显示为空白。

先备份已有配置：

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

克隆并启动：

```bash
git clone https://github.com/mkdir700/lazynvim.git ~/.config/nvim
nvim
```

首次启动时会自动安装插件。进入 Neovim 后运行 `:checkhealth`，可以检查本机缺少的语言工具和剪贴板程序。

## 可选增强

- Rust：安装 [rustup](https://rustup.rs/)。
- .NET：安装 `dotnet`；临时禁用时设置 `NVIM_ENABLE_DOTNET=0`。
- Neovide：建议安装 `JetVictor Mono`，否则修改
  [`lua/config/neovide.lua`](lua/config/neovide.lua) 中的字体。
- AI：安装需要使用的命令行助手；直接打开 Codex 还需要本机存在 `codex` 命令。
- Sidekick Reader：设置 `NVIM_ENABLE_SIDEKICK_READER=1` 后启用；开发本地版本时可通过
  `SIDEKICK_READER_DIR` 指定插件目录。
- 输入法状态：macOS 安装 `macism`；Linux 使用 `fcitx5-remote`、`ibus` 或 `im-select` 之一。没有这些工具时，状态栏会自动隐藏该段。

Squirrel/Rime 的英文和中文内部模式使用同一个 macOS 输入源，若要在状态栏中精确区分 `EN` 和 `中`，还需要在本机 Rime 配置中启用对应的状态导出脚本。

## 常用按键

`<leader>` 默认为空格。LazyVim 自带的按键可在 Neovim 中按空格后查看；下面只列本配置中最常用的定制项。

| 按键 | 作用 |
| --- | --- |
| `jk` | 在插入模式返回普通模式 |
| `<C-i>` / `<C-o>` | 沿跳转历史向前 / 向后 |
| `<leader>e` | 打开当前目录的浮动文件树 |
| `<leader>E` | 打开项目根目录的浮动文件树 |
| Ctrl-反引号 / `<leader>ft` | 打开或隐藏当前目录终端 |
| `<leader>fT` | 打开或隐藏项目根目录终端 |
| `<C-q>` | 终端中单击切换模式，快速双击隐藏终端 |
| `<leader>fr` | 查找最近创建或打开的文件 |
| `<leader>qs` | 恢复当前目录的编辑会话 |
| `<leader>ql` | 恢复上一次编辑会话 |
| `<leader>an` | 跳到或应用下一处 AI 编辑建议 |
| `<leader>aa` | 打开或隐藏 Sidekick |
| `<leader>ac` | 直接打开或隐藏 Codex |
| `<leader>sp` | 打开复制历史 |
| `<leader>cp` | 复制选中文本所在的文件和行号 |

Neovide 在 macOS 下额外支持 `Cmd-S` 保存、`Cmd-C` 复制、`Cmd-V` 粘贴，
以及 `Cmd-+`、`Cmd--`、`Cmd-0` 调整界面大小。

## 目录

```text
lua/config/     基础选项、自动命令和全局按键
lua/plugins/    插件配置，按用途和语言分类
lua/util/       可独立测试的辅助功能
tests/          自动化测试
```

## 检查

修改配置后可运行：

```bash
git diff --check
nvim --headless +qa
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests { minimal_init = 'tests/minimal_init.lua' }"
```

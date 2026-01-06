# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概述

这是一个基于 LazyVim 的 Neovim 配置，通过 Lua 配置文件提供了丰富的插件生态系统和开发环境。

## 代码格式化命令

```bash
stylua lua/                    # 格式化 Lua 代码
```

## 架构说明

### 核心结构
- `init.lua` - 启动文件，加载 lazy.nvim 配置
- `lua/config/lazy.lua` - LazyVim 核心配置和插件加载
- `lua/config/` - 基础配置目录
  - `options.lua` - Neovim 选项配置
  - `keymaps.lua` - 键位映射配置
  - `autocmds.lua` - 自定义命令配置

### 插件组织结构
插件按功能分类组织在 `lua/plugins/` 目录下：

- `ai/` - AI 相关插件（Claude Code、Copilot、Avante 等）
- `editor/` - 编辑器功能插件（自动配对、补全、注释等）
- `jump/` - 跳转和导航插件（Flash、窗口管理、书签等）
- `lang/` - 语言特定配置（Python、Go、C# 等）
- `ui/` - UI 相关插件（主题、状态栏、通知等）
- `tool/` - 工具类插件（HTTP 客户端等）

### 重要配置文件
- `stylua.toml` - Lua 代码格式化配置
- `lazy-lock.json` - 插件版本锁定文件
- `lazyvim.json` - LazyVim 配置文件

## 插件管理

使用 lazy.nvim 作为插件管理器，配置文件位于 `lua/config/lazy.lua`。

### 启用的 LazyVim 扩展模块
- 语言支持：Python、TypeScript、Markdown、JSON、TOML、C#
- 工具：DAP 调试、测试框架、代码格式化（Prettier、Black）
- 编辑器：Mini-diff、Outline、重构工具
- AI：Supermaven 代码补全

### 自定义插件模块
- AI 集成：Claude Code、Copilot、ChatGPT
- 编辑器增强：自动保存、代码折叠、彩虹括号
- 导航工具：Flash 跳转、预览、书签管理
- UI 美化：光标动画、滚动条、缓冲区标签

## 关键快捷键

### Claude Code 集成
- `<leader>ac` - 切换 Claude Code
- `<leader>af` - 聚焦 Claude Code
- `<leader>ar` - 恢复 Claude Code 会话
- `<leader>aC` - 继续 Claude Code 对话
- `<leader>ab` - 添加当前缓冲区到 Claude Code
- `<leader>as` - 发送选中内容到 Claude Code（可视模式）
- `<leader>aA` - 接受差异
- `<leader>aD` - 拒绝差异

### 基础编辑
- `jk` - 退出插入模式
- `Q` - 退出所有窗口
- `<leader>we` - 聚焦文件树

## 特殊配置

### 代码格式化
- Stylua 配置：2 空格缩进，120 字符行宽
- Prettier 不需要配置文件即可使用

### LSP 配置
- Python：使用 pyright 和 ruff
- 支持标签跳转和跳转栈

### 主题和 UI
- 默认主题：Tokyo Night
- 支持透明背景（Neovide）
- 启用动画效果

## 开发工作流

1. 使用 `nvim` 启动编辑器
2. 通过 `<leader>ac` 启动 Claude Code 进行 AI 辅助编程
3. 使用 `stylua lua/` 格式化代码
4. 通过 LazyVim 的内置功能进行 LSP、调试和测试
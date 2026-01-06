return {
  prompt = [[
请你查看 git 缓冲区已暂存的内容，完成这两件事情：

1. 结合上下文生成 commit message，消息必须遵循以下规则：
   1. 请你遵循 Conventional Commits 风格；
   2. 请你使用英文；
2. 结合上下文生成分支名

下面给你一些输出例子：

<example>
Commit Message:
```
fix(RunLocator): implement recursive paragraph search with comprehensive document coverage

- Replace redundant attribute checking logic with elegant LINQ-based approach
- Add recursive paragraph search to handle nested structures (tables, text boxes, etc.)
- Extend search scope to include headers, footers, footnotes, endnotes, and comments
- Improve performance with early termination and depth-first traversal
- Add comprehensive documentation with ASCII diagrams for search strategy

Changes:

- FindParagraphById: Remove duplicate paraId value checking logic
- Add FindParagraphInDocument: Search across all document parts
- Add FindParagraphRecursively: Handle nested paragraph structures
- Enhanced logging for better debugging of paragraph location

This fix ensures paragraphs are found regardless of their nesting level or
container type, addressing cases where paragraphs exist in complex document
structures beyond the main body element

```

Branch Name:
```

fix/runlocator-recursive-paragraph-search

```

Reason:

`fix/runlocator-recursive-paragraph-search` is the best choice because:

1. fix/ - clearly indicates a bug fix
2. runlocator - specifies the component being fixed
3. recursive-paragraph-search - accurately describes the core functionality being addressed

This branch name:

- ✅ is concise (under 35 characters)
- ✅ accurately describes the fix
- ✅ follows the type/scope-description convention
  </example>
]],
}

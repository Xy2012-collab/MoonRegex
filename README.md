# MoonRegex

纯 MoonBit 正则表达式引擎，基于 AST 编译 + 递归回溯匹配。

## 功能

- **基础语法**：字面量、`.`、`*`、`+`、`?`、`|`、`()`、`[]`、`[^ ]`
- **字符范围**：`[a-z]`、`[0-9]`、`[A-Z]`
- **转义**：`\d`、`\D`、`\w`、`\W`、`\s`、`\S`
- **计数重复**：`{n}`、`{n,}`、`{n,m}`
- **锚点**：`^`、`$`
- **API**：match / find / find_all / replace / split / count / match_result

## 安装

```
moon add placeholder/MoonRegex
```

## 快速开始

```moonbit
let re = Regex::new("\\d{4}-\\d{2}-\\d{2}").unwrap()
assert!(re.matches("2026-07-04"))
assert!(re.replace("a1b2c3", "\\d", "X") == "aXbXcX")
```

## API

| 方法 | 说明 |
|------|------|
| `Regex::new(pattern)` | 编译正则表达式 |
| `.matches(input)` | 完整匹配 |
| `.find(input)` | 查找首次匹配位置 |
| `.find_all(input)` | 查找所有匹配位置 |
| `.replace(input, repl)` | 替换所有匹配 |
| `.split(input)` | 按匹配分割字符串 |
| `.count(input)` | 统计匹配次数 |
| `.match_result(input)` | 返回详细匹配结果 |

## 许可证

Apache-2.0

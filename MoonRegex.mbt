// MoonRegex — Pure MoonBit Regular Expression Engine
//
// Features:
//   - AST-based regex compilation with recursive backtracking matching
//   - Literal, ., *, +, ?, |, (), [], [^ ], [a-z], \d, \w, \s, \D, \W, \S
//   - Counted repetition: {n}, {n,}, {n,m}
//   - match, find, find_all, replace, split, count, match_result
//
// Usage:
//   let re = Regex::new("a(b|c)*d")
//   if re.matches("abcbcd") { ... }

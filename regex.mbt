// MoonRegex — Pure MoonBit Regular Expression Engine
// Uses recursive backtracking with AST representation

// --- AST Types ---
enum RegexAST {
  Lit(String)
  Dot
  Star(RegexAST)
  Plus(RegexAST)
  Opt(RegexAST)
  Alt(RegexAST, RegexAST)
  Seq(RegexAST, RegexAST)
  Class(Array[String], Bool)
  Escape(String)
  Anchor(String)
  Empty
}

// --- Parser ---
fn parse_regex(pattern : String, pos : Int) -> (RegexAST, Int) {
  let (left, p1) = parse_branch(pattern, pos)
  if p1 < pattern.length() && pattern.substring(start=p1, end=p1 + 1) == "|" {
    let (right, p2) = parse_regex(pattern, p1 + 1)
    (RegexAST::Alt(left, right), p2)
  } else {
    (left, p1)
  }
}

fn parse_branch(pattern : String, pos : Int) -> (RegexAST, Int) {
  if pos >= pattern.length() { return (RegexAST::Empty, pos) }
  let ch = pattern.substring(start=pos, end=pos + 1)
  if ch == ")" || ch == "|" || ch == "$" { return (RegexAST::Empty, pos) }
  let (piece, p1) = parse_piece(pattern, pos)
  let (rest, p2) = parse_branch(pattern, p1)
  match rest {
    RegexAST::Empty => (piece, p2)
    _ => (RegexAST::Seq(piece, rest), p2)
  }
}

fn parse_piece(pattern : String, pos : Int) -> (RegexAST, Int) {
  let (atom, p1) = parse_atom(pattern, pos)
  if p1 >= pattern.length() { return (atom, p1) }
  let qch = pattern.substring(start=p1, end=p1 + 1)
  if qch == "*" { (RegexAST::Star(atom), p1 + 1) }
  else if qch == "+" { (RegexAST::Plus(atom), p1 + 1) }
  else if qch == "?" { (RegexAST::Opt(atom), p1 + 1) }
  else if qch == "{" { parse_counted(atom, pattern, p1 + 1) }
  else { (atom, p1) }
}

fn parse_counted(atom : RegexAST, pattern : String, pos : Int) -> (RegexAST, Int) {
  let (min_str, p1) = read_number(pattern, pos)
  if p1 >= pattern.length() { return (atom, pos) }
  let ch = pattern.substring(start=p1, end=p1 + 1)
  if ch == "}" {
    let min_val = parse_int_str(min_str)
    (repeat_exact(atom, min_val), p1 + 1)
  } else if ch == "," {
    let p2 = p1 + 1
    if p2 < pattern.length() && pattern.substring(start=p2, end=p2 + 1) == "}" {
      // {n,} — at least n
      let min_val = parse_int_str(min_str)
      (repeat_at_least(atom, min_val), p2 + 1)
    } else {
      let (max_str, p3) = read_number(pattern, p2)
      if p3 < pattern.length() && pattern.substring(start=p3, end=p3 + 1) == "}" {
        let min_val = parse_int_str(min_str)
        let max_val = parse_int_str(max_str)
        (repeat_range_ast(atom, min_val, max_val), p3 + 1)
      } else {
        (atom, pos)
      }
    }
  } else {
    (atom, pos)
  }
}

fn read_number(pattern : String, pos : Int) -> (String, Int) {
  read_digits(pattern, pos, "")
}

fn read_digits(pattern : String, pos : Int, acc : String) -> (String, Int) {
  if pos >= pattern.length() { (acc, pos) }
  else {
    let ch = pattern.substring(start=pos, end=pos + 1)
    if ch >= "0" && ch <= "9" { read_digits(pattern, pos + 1, acc + ch) }
    else { (acc, pos) }
  }
}

fn parse_int_str(s : String) -> Int {
  parse_int_rec(s, 0, 0)
}

fn parse_int_rec(s : String, idx : Int, acc : Int) -> Int {
  if idx >= s.length() { acc }
  else {
    let ch = s.substring(start=idx, end=idx + 1)
    let d = match ch {
      "0" => 0; "1" => 1; "2" => 2; "3" => 3; "4" => 4
      "5" => 5; "6" => 6; "7" => 7; "8" => 8; "9" => 9
      _ => 0
    }
    parse_int_rec(s, idx + 1, acc * 10 + d)
  }
}

fn repeat_exact(ast : RegexAST, n : Int) -> RegexAST {
  repeat_concat(ast, n, RegexAST::Empty)
}

fn repeat_concat(ast : RegexAST, n : Int, acc : RegexAST) -> RegexAST {
  match acc {
    RegexAST::Empty => {
      if n <= 0 { RegexAST::Empty }
      else if n == 1 { ast }
      else { repeat_concat(ast, n - 1, ast) }
    }
    _ => {
      if n <= 0 { acc }
      else { repeat_concat(ast, n - 1, RegexAST::Seq(ast, acc)) }
    }
  }
}

fn repeat_at_least(ast : RegexAST, min_val : Int) -> RegexAST {
  let required = repeat_exact(ast, min_val)
  match required {
    RegexAST::Empty => RegexAST::Star(ast)
    _ => RegexAST::Seq(required, RegexAST::Star(ast))
  }
}

fn repeat_range_ast(ast : RegexAST, min_val : Int, max_val : Int) -> RegexAST {
  if min_val >= max_val { return repeat_exact(ast, min_val) }
  let required = repeat_exact(ast, min_val)
  let optional_count = max_val - min_val
  let opt_part = repeat_optional(ast, optional_count)
  match required {
    RegexAST::Empty => opt_part
    _ => match opt_part {
      RegexAST::Empty => required
      _ => RegexAST::Seq(required, opt_part)
    }
  }
}

fn repeat_optional(ast : RegexAST, n : Int) -> RegexAST {
  if n <= 0 { RegexAST::Empty }
  else {
    RegexAST::Seq(RegexAST::Opt(ast), repeat_optional(ast, n - 1))
  }
}

fn parse_atom(pattern : String, pos : Int) -> (RegexAST, Int) {
  if pos >= pattern.length() { return (RegexAST::Empty, pos) }
  let ch = pattern.substring(start=pos, end=pos + 1)
  if ch == "(" {
    let (inner, p1) = parse_regex(pattern, pos + 1)
    if p1 < pattern.length() && pattern.substring(start=p1, end=p1 + 1) == ")" {
      (inner, p1 + 1)
    } else {
      (inner, p1)
    }
  } else if ch == "[" {
    let negate = if pos + 1 < pattern.length() && pattern.substring(start=pos + 1, end=pos + 2) == "^" { true } else { false }
    let start = if negate { pos + 2 } else { pos + 1 }
    parse_class(pattern, start, negate)
  } else if ch == "." {
    (RegexAST::Dot, pos + 1)
  } else if ch == "\\" {
    if pos + 1 < pattern.length() {
      let esc = pattern.substring(start=pos + 1, end=pos + 2)
      (RegexAST::Escape(esc), pos + 2)
    } else {
      (RegexAST::Empty, pos + 1)
    }
  } else if ch == "^" {
    (RegexAST::Anchor("start"), pos + 1)
  } else if ch == "$" {
    (RegexAST::Anchor("end"), pos + 1)
  } else if ch == ")" || ch == "|" || ch == "*" || ch == "+" || ch == "?" {
    (RegexAST::Empty, pos)
  } else {
    (RegexAST::Lit(ch), pos + 1)
  }
}

fn parse_class(pattern : String, pos : Int, negate : Bool) -> (RegexAST, Int) {
  let chars : Array[String] = []
  parse_class_inner(pattern, pos, chars, negate)
}

fn parse_class_inner(pattern : String, pos : Int, chars : Array[String], negate : Bool) -> (RegexAST, Int) {
  if pos >= pattern.length() { return (RegexAST::Class(chars, negate), pos) }
  let ch = pattern.substring(start=pos, end=pos + 1)
  if ch == "]" {
    (RegexAST::Class(chars, negate), pos + 1)
  } else if pos + 2 < pattern.length() && pattern.substring(start=pos + 1, end=pos + 2) == "-" {
    // Character range: a-z
    let next_ch = pattern.substring(start=pos + 2, end=pos + 3)
    if next_ch != "]" {
      expand_range(ch, next_ch, chars)
      parse_class_inner(pattern, pos + 3, chars, negate)
    } else {
      chars.push(ch)
      parse_class_inner(pattern, pos + 1, chars, negate)
    }
  } else {
    chars.push(ch)
    parse_class_inner(pattern, pos + 1, chars, negate)
  }
}

fn expand_range(start_ch : String, end_ch : String, chars : Array[String]) -> Unit {
  let start = char_to_int(start_ch)
  let end = char_to_int(end_ch)
  range_add(start, end, chars)
}

fn range_add(start : Int, end : Int, chars : Array[String]) -> Unit {
  if start <= end {
    chars.push(int_to_char(start))
    range_add(start + 1, end, chars)
  } else {
    // done
  }
}

fn char_to_int(ch : String) -> Int {
  if ch == "0" { 48 } else if ch == "1" { 49 } else if ch == "2" { 50 } else if ch == "3" { 51 } else if ch == "4" { 52 }
  else if ch == "5" { 53 } else if ch == "6" { 54 } else if ch == "7" { 55 } else if ch == "8" { 56 } else if ch == "9" { 57 }
  else if ch == "A" { 65 } else if ch == "B" { 66 } else if ch == "C" { 67 } else if ch == "D" { 68 } else if ch == "E" { 69 }
  else if ch == "F" { 70 } else if ch == "G" { 71 } else if ch == "H" { 72 } else if ch == "I" { 73 } else if ch == "J" { 74 }
  else if ch == "K" { 75 } else if ch == "L" { 76 } else if ch == "M" { 77 } else if ch == "N" { 78 } else if ch == "O" { 79 }
  else if ch == "P" { 80 } else if ch == "Q" { 81 } else if ch == "R" { 82 } else if ch == "S" { 83 } else if ch == "T" { 84 }
  else if ch == "U" { 85 } else if ch == "V" { 86 } else if ch == "W" { 87 } else if ch == "X" { 88 } else if ch == "Y" { 89 }
  else if ch == "Z" { 90 } else if ch == "a" { 97 } else if ch == "b" { 98 } else if ch == "c" { 99 } else if ch == "d" { 100 }
  else if ch == "e" { 101 } else if ch == "f" { 102 } else if ch == "g" { 103 } else if ch == "h" { 104 } else if ch == "i" { 105 }
  else if ch == "j" { 106 } else if ch == "k" { 107 } else if ch == "l" { 108 } else if ch == "m" { 109 } else if ch == "n" { 110 }
  else if ch == "o" { 111 } else if ch == "p" { 112 } else if ch == "q" { 113 } else if ch == "r" { 114 } else if ch == "s" { 115 }
  else if ch == "t" { 116 } else if ch == "u" { 117 } else if ch == "v" { 118 } else if ch == "w" { 119 } else if ch == "x" { 120 }
  else if ch == "y" { 121 } else if ch == "z" { 122 } else { 0 }
}

fn int_to_char(code : Int) -> String {
  if code == 48 { "0" } else if code == 49 { "1" } else if code == 50 { "2" }
  else if code == 51 { "3" } else if code == 52 { "4" } else if code == 53 { "5" }
  else if code == 54 { "6" } else if code == 55 { "7" } else if code == 56 { "8" } else if code == 57 { "9" }
  else if code >= 65 && code <= 90 {
    upper_to_char(code)
  } else if code >= 97 && code <= 122 {
    lower_to_char(code)
  } else { "?" }
}

fn upper_to_char(code : Int) -> String {
  if code == 65 { "A" } else if code == 66 { "B" } else if code == 67 { "C" } else if code == 68 { "D" }
  else if code == 69 { "E" } else if code == 70 { "F" } else if code == 71 { "G" } else if code == 72 { "H" }
  else if code == 73 { "I" } else if code == 74 { "J" } else if code == 75 { "K" } else if code == 76 { "L" }
  else if code == 77 { "M" } else if code == 78 { "N" } else if code == 79 { "O" } else if code == 80 { "P" }
  else if code == 81 { "Q" } else if code == 82 { "R" } else if code == 83 { "S" } else if code == 84 { "T" }
  else if code == 85 { "U" } else if code == 86 { "V" } else if code == 87 { "W" } else if code == 88 { "X" }
  else if code == 89 { "Y" } else { "Z" }
}

fn lower_to_char(code : Int) -> String {
  if code == 97 { "a" } else if code == 98 { "b" } else if code == 99 { "c" } else if code == 100 { "d" }
  else if code == 101 { "e" } else if code == 102 { "f" } else if code == 103 { "g" } else if code == 104 { "h" }
  else if code == 105 { "i" } else if code == 106 { "j" } else if code == 107 { "k" } else if code == 108 { "l" }
  else if code == 109 { "m" } else if code == 110 { "n" } else if code == 111 { "o" } else if code == 112 { "p" }
  else if code == 113 { "q" } else if code == 114 { "r" } else if code == 115 { "s" } else if code == 116 { "t" }
  else if code == 117 { "u" } else if code == 118 { "v" } else if code == 119 { "w" } else if code == 120 { "x" }
  else if code == 121 { "y" } else { "z" }
}

// --- Matcher ---
fn match_ast(ast : RegexAST, input : String, pos : Int) -> Int {
  match ast {
    RegexAST::Empty => pos
    RegexAST::Lit(s) => {
      if pos < input.length() && input.substring(start=pos, end=pos + 1) == s { pos + 1 }
      else { -1 }
    }
    RegexAST::Dot => {
      if pos < input.length() { pos + 1 } else { -1 }
    }
    RegexAST::Seq(first, second) => {
      let p1 = match_ast(first, input, pos)
      if p1 < 0 { -1 } else { match_ast(second, input, p1) }
    }
    RegexAST::Alt(left, right) => {
      let p1 = match_ast(left, input, pos)
      if p1 >= 0 { p1 } else { match_ast(right, input, pos) }
    }
    RegexAST::Star(child) => match_star(child, input, pos)
    RegexAST::Plus(child) => {
      let p1 = match_ast(child, input, pos)
      if p1 < 0 { -1 } else { match_star(child, input, p1) }
    }
    RegexAST::Opt(child) => {
      let p1 = match_ast(child, input, pos)
      if p1 < 0 { pos } else { p1 }
    }
    RegexAST::Class(chars, negate) => {
      if pos >= input.length() { return -1 }
      let ch = input.substring(start=pos, end=pos + 1)
      let found = contains_in_class(chars, ch)
      if (found && !negate) || (!found && negate) { pos + 1 } else { -1 }
    }
    RegexAST::Escape(esc_type) => match_escape(esc_type, input, pos)
    RegexAST::Anchor(_) => pos
  }
}

fn match_star(ast : RegexAST, input : String, pos : Int) -> Int {
  let p1 = match_ast(ast, input, pos)
  if p1 < 0 { pos }
  else if p1 == pos { pos }
  else {
    let p2 = match_star(ast, input, p1)
    if p2 > p1 { p2 } else { p1 }
  }
}

fn match_escape(esc_type : String, input : String, pos : Int) -> Int {
  if pos >= input.length() { return -1 }
  let ch = input.substring(start=pos, end=pos + 1)
  let matched = match esc_type {
    "d" => ch >= "0" && ch <= "9"
    "D" => ch < "0" || ch > "9"
    "w" => (ch >= "a" && ch <= "z") || (ch >= "A" && ch <= "Z") || (ch >= "0" && ch <= "9") || ch == "_"
    "W" => !((ch >= "a" && ch <= "z") || (ch >= "A" && ch <= "Z") || (ch >= "0" && ch <= "9") || ch == "_")
    "s" => ch == " " || ch == "\t" || ch == "\n" || ch == "\r"
    "S" => ch != " " && ch != "\t" && ch != "\n" && ch != "\r"
    _ => ch == esc_type
  }
  if matched { pos + 1 } else { -1 }
}

fn contains_in_class(chars : Array[String], target : String) -> Bool {
  for i = 0; i < chars.length(); i = i + 1 {
    if chars[i] == target { return true }
  }
  false
}

// --- Public Regex type ---
pub(all) struct Regex {
  ast : RegexAST
  pattern : String
}

pub fn Regex::new(pattern : String) -> Regex? {
  let (ast, pos) = parse_regex(pattern, 0)
  Some(Regex::{ ast, pattern })
}

pub fn Regex::matches(self : Regex, input : String) -> Bool {
  let result = match_ast(self.ast, input, 0)
  result == input.length()
}

pub fn Regex::find(self : Regex, input : String) -> Int {
  let mut i = 0
  while i < input.length() {
    if match_ast(self.ast, input, i) >= 0 { return i }
    i = i + 1
  }
  -1
}

pub fn Regex::find_all(self : Regex, input : String) -> Array[Int] {
  let positions : Array[Int] = []
  let mut i = 0
  while i < input.length() {
    if match_ast(self.ast, input, i) >= 0 {
      positions.push(i)
      i = i + 1
    } else {
      i = i + 1
    }
  }
  positions
}

// --- Match Result with captured groups ---
pub(all) struct MatchResult {
  matched : Bool
  start : Int
  end : Int
  groups : Array[String]
}

pub fn MatchResult::new(matched : Bool, start : Int, end : Int, groups : Array[String]) -> MatchResult {
  MatchResult::{ matched, start, end, groups }
}

pub fn Regex::match_result(self : Regex, input : String) -> MatchResult {
  let end = match_ast(self.ast, input, 0)
  if end >= 0 {
    MatchResult::new(true, 0, end, [])
  } else {
    MatchResult::new(false, -1, -1, [])
  }
}

// --- Split string by regex ---
pub fn Regex::split(self : Regex, input : String) -> Array[String] {
  let parts : Array[String] = []
  split_rec(self.ast, input, 0, 0, parts)
}

fn split_rec(ast : RegexAST, input : String, pos : Int, last : Int, parts : Array[String]) -> Array[String] {
  if pos >= input.length() {
    let remaining = input.substring(start=last, end=input.length())
    parts.push(remaining)
    parts
  } else {
    let end = match_ast(ast, input, pos)
    if end > pos {
      let before = input.substring(start=last, end=pos)
      parts.push(before)
      split_rec(ast, input, end, end, parts)
    } else {
      split_rec(ast, input, pos + 1, last, parts)
    }
  }
}

// --- Count matches ---
pub fn Regex::count(self : Regex, input : String) -> Int {
  count_rec(self.ast, input, 0, 0)
}

fn count_rec(ast : RegexAST, input : String, pos : Int, count : Int) -> Int {
  if pos >= input.length() { count }
  else {
    let end = match_ast(ast, input, pos)
    if end > pos {
      count_rec(ast, input, end, count + 1)
    } else {
      count_rec(ast, input, pos + 1, count)
    }
  }
}

pub fn Regex::replace(self : Regex, input : String, replacement : String) -> String {
  replace_rec(self.ast, input, replacement, 0, "")
}

fn replace_rec(ast : RegexAST, input : String, replacement : String, pos : Int, result : String) -> String {
  if pos >= input.length() { result }
  else {
    let end = match_ast(ast, input, pos)
    if end > pos {
      replace_rec(ast, input, replacement, end, result + replacement)
    } else {
      let ch = input.substring(start=pos, end=pos + 1)
      replace_rec(ast, input, replacement, pos + 1, result + ch)
    }
  }
}

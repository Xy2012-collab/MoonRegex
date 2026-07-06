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
  else { (atom, p1) }
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
  } else {
    chars.push(ch)
    parse_class_inner(pattern, pos + 1, chars, negate)
  }
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

// Blackbox tests for MoonRegex public API

test "literal match public" {
  match @MoonRegex.Regex::new("abc") {
    Some(r) => assert_eq!(r.matches("abc"), true)
    None => assert_eq!(true, false)
  }
}

test "star quantifier public" {
  match @MoonRegex.Regex::new("x*y") {
    Some(r) => {
      assert_eq!(r.matches("y"), true)
      assert_eq!(r.matches("xy"), true)
      assert_eq!(r.matches("xxxxy"), true)
    }
    None => assert_eq!(true, false)
  }
}

test "find public" {
  match @MoonRegex.Regex::new("needle") {
    Some(r) => {
      assert_eq!(r.find("the needle in haystack"), 4)
      assert_eq!(r.find("no match here"), -1)
    }
    None => assert_eq!(true, false)
  }
}

test "replace public" {
  match @MoonRegex.Regex::new("red") {
    Some(r) => assert_eq!(r.replace("red apple, red car", "blue"), "blue apple, blue car")
    None => assert_eq!(true, false)
  }
}

test "count public" {
  match @MoonRegex.Regex::new("a") {
    Some(r) => assert_eq!(r.count("banana"), 3)
    None => assert_eq!(true, false)
  }
}

test "split public" {
  match @MoonRegex.Regex::new("\\s+") {
    Some(r) => {
      let parts = r.split("one two three")
      assert_eq!(parts.length(), 3)
    }
    None => assert_eq!(true, false)
  }
}

test "match result public" {
  match @MoonRegex.Regex::new("hello") {
    Some(r) => {
      let result = r.match_result("hello world")
      assert_eq!(result.matched, true)
      assert_eq!(result.start, 0)
      assert_eq!(result.end, 5)
    }
    None => assert_eq!(true, false)
  }
}

test "counted repetition public" {
  match @MoonRegex.Regex::new("a{3}") {
    Some(r) => assert_eq!(r.matches("aaa"), true)
    None => assert_eq!(true, false)
  }
}

test "complex regex public" {
  match @MoonRegex.Regex::new("[A-Z][a-z]+ \\d{4}") {
    Some(r) => {
      assert_eq!(r.matches("July 2026"), true)
      assert_eq!(r.matches("july 2026"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "email validation public" {
  match @MoonRegex.Regex::new("\\w+@\\w+\\.\\w+") {
    Some(r) => {
      assert_eq!(r.matches("user@example.com"), true)
      assert_eq!(r.matches("not-valid"), false)
    }
    None => assert_eq!(true, false)
  }
}

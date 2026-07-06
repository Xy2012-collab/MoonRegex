// Whitebox tests for MoonRegex

test "literal match" {
  let re = Regex::new("hello")
  match re {
    Some(r) => assert_eq!(r.matches("hello"), true)
    None => assert_eq!(true, false)
  }
}

test "literal no match" {
  match Regex::new("hello") {
    Some(r) => assert_eq!(r.matches("world"), false)
    None => assert_eq!(true, false)
  }
}

test "dot matches any char" {
  match Regex::new("h.llo") {
    Some(r) => assert_eq!(r.matches("hello"), true)
    None => assert_eq!(true, false)
  }
}

test "star zero or more" {
  match Regex::new("ab*c") {
    Some(r) => {
      assert_eq!(r.matches("ac"), true)
      assert_eq!(r.matches("abc"), true)
      assert_eq!(r.matches("abbbbc"), true)
    }
    None => assert_eq!(true, false)
  }
}

test "plus one or more" {
  match Regex::new("ab+c") {
    Some(r) => {
      assert_eq!(r.matches("abc"), true)
      assert_eq!(r.matches("abbbc"), true)
      assert_eq!(r.matches("ac"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "optional zero or one" {
  match Regex::new("ab?c") {
    Some(r) => {
      assert_eq!(r.matches("ac"), true)
      assert_eq!(r.matches("abc"), true)
      assert_eq!(r.matches("abbc"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "alternation" {
  match Regex::new("cat|dog") {
    Some(r) => {
      assert_eq!(r.matches("cat"), true)
      assert_eq!(r.matches("dog"), true)
      assert_eq!(r.matches("bird"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "character class" {
  match Regex::new("[aeiou]") {
    Some(r) => {
      assert_eq!(r.matches("a"), true)
      assert_eq!(r.matches("e"), true)
      assert_eq!(r.matches("x"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "negated character class" {
  match Regex::new("[^aeiou]") {
    Some(r) => {
      assert_eq!(r.matches("x"), true)
      assert_eq!(r.matches("a"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "digit escape" {
  match Regex::new("\\d") {
    Some(r) => {
      assert_eq!(r.matches("5"), true)
      assert_eq!(r.matches("a"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "word escape" {
  match Regex::new("\\w+") {
    Some(r) => {
      assert_eq!(r.matches("hello123"), true)
      assert_eq!(r.matches("hi there"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "space escape" {
  match Regex::new("a\\sb") {
    Some(r) => {
      assert_eq!(r.matches("a b"), true)
      assert_eq!(r.matches("ab"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "grouping with parentheses" {
  match Regex::new("a(bc)*d") {
    Some(r) => {
      assert_eq!(r.matches("ad"), true)
      assert_eq!(r.matches("abcd"), true)
      assert_eq!(r.matches("abcbcd"), true)
    }
    None => assert_eq!(true, false)
  }
}

test "find returns position" {
  match Regex::new("cat") {
    Some(r) => assert_eq!(r.find("the cat sat"), 4)
    None => assert_eq!(true, false)
  }
}

test "find returns -1 when not found" {
  match Regex::new("cat") {
    Some(r) => assert_eq!(r.find("the dog sat"), -1)
    None => assert_eq!(true, false)
  }
}

test "find all returns positions" {
  match Regex::new("is") {
    Some(r) => assert_eq!(r.find_all("this is a test").length(), 2)
    None => assert_eq!(true, false)
  }
}

test "replace all matches" {
  match Regex::new("cat") {
    Some(r) => assert_eq!(r.replace("the cat and a cat", "dog"), "the dog and a dog")
    None => assert_eq!(true, false)
  }
}

test "empty regex matches anything" {
  match Regex::new("") {
    Some(r) => assert_eq!(r.matches(""), true)
    None => assert_eq!(true, false)
  }
}

test "plus with digit class" {
  match Regex::new("\\d+") {
    Some(r) => {
      assert_eq!(r.matches("12345"), true)
      assert_eq!(r.matches("abc"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "escape non-special char" {
  match Regex::new("\\*") {
    Some(r) => assert_eq!(r.matches("*"), true)
    None => assert_eq!(true, false)
  }
}

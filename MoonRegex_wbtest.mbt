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

test "range a-z class" {
  match Regex::new("[a-z]+") {
    Some(r) => {
      assert_eq!(r.matches("hello"), true)
      assert_eq!(r.matches("HELLO"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "range 0-9 class" {
  match Regex::new("[0-9]+") {
    Some(r) => {
      assert_eq!(r.matches("12345"), true)
      assert_eq!(r.matches("abc"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "range A-Z class" {
  match Regex::new("[A-Z]+") {
    Some(r) => {
      assert_eq!(r.matches("HELLO"), true)
      assert_eq!(r.matches("hello"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "split by regex" {
  match Regex::new(",") {
    Some(r) => {
      let parts = r.split("a,b,c")
      assert_eq!(parts.length(), 3)
      assert_eq!(parts[0], "a")
      assert_eq!(parts[1], "b")
      assert_eq!(parts[2], "c")
    }
    None => assert_eq!(true, false)
  }
}

test "split by whitespace" {
  match Regex::new("\\s+") {
    Some(r) => {
      let parts = r.split("one two three")
      assert_eq!(parts.length(), 3)
    }
    None => assert_eq!(true, false)
  }
}

test "count matches" {
  match Regex::new("the") {
    Some(r) => assert_eq!(r.count("the cat and the dog"), 2)
    None => assert_eq!(true, false)
  }
}

test "count no matches" {
  match Regex::new("zebra") {
    Some(r) => assert_eq!(r.count("no matches here"), 0)
    None => assert_eq!(true, false)
  }
}

test "match result successful" {
  match Regex::new("hello") {
    Some(r) => {
      let result = r.match_result("hello world")
      assert_eq!(result.matched, true)
      assert_eq!(result.start, 0)
      assert_eq!(result.end, 5)
    }
    None => assert_eq!(true, false)
  }
}

test "match result failed" {
  match Regex::new("xyz") {
    Some(r) => {
      let result = r.match_result("hello")
      assert_eq!(result.matched, false)
    }
    None => assert_eq!(true, false)
  }
}

test "email pattern" {
  match Regex::new("\\w+@\\w+\\.\\w+") {
    Some(r) => {
      assert_eq!(r.matches("test@example.com"), true)
      assert_eq!(r.matches("not-an-email"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "star with alternation" {
  match Regex::new("(ab|cd)*") {
    Some(r) => {
      assert_eq!(r.matches(""), true)
      assert_eq!(r.matches("ab"), true)
      assert_eq!(r.matches("cd"), true)
      assert_eq!(r.matches("abcd"), true)
      assert_eq!(r.matches("ababcdcd"), true)
    }
    None => assert_eq!(true, false)
  }
}

test "replace with empty string" {
  match Regex::new("\\s+") {
    Some(r) => assert_eq!(r.replace("a  b   c", ""), "abc")
    None => assert_eq!(true, false)
  }
}

test "negated range class" {
  match Regex::new("[^a-z]+") {
    Some(r) => {
      assert_eq!(r.matches("123"), true)
      assert_eq!(r.matches("abc"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "counted repetition exact {n}" {
  match Regex::new("a{3}") {
    Some(r) => {
      assert_eq!(r.matches("aaa"), true)
      assert_eq!(r.matches("aa"), false)
      assert_eq!(r.matches("aaaa"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "counted repetition at least {n,}" {
  match Regex::new("a{2,}") {
    Some(r) => {
      assert_eq!(r.matches("aa"), true)
      assert_eq!(r.matches("aaa"), true)
      assert_eq!(r.matches("a"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "counted repetition range {n,m}" {
  match Regex::new("a{2,4}") {
    Some(r) => {
      assert_eq!(r.matches("aa"), true)
      assert_eq!(r.matches("aaa"), true)
      assert_eq!(r.matches("aaaa"), true)
      assert_eq!(r.matches("a"), false)
      assert_eq!(r.matches("aaaaa"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "phone number pattern" {
  match Regex::new("\\d{3}-\\d{4}-\\d{4}") {
    Some(r) => {
      assert_eq!(r.matches("138-0000-1234"), true)
      assert_eq!(r.matches("12-3456-7890"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "date pattern" {
  match Regex::new("\\d{4}-\\d{2}-\\d{2}") {
    Some(r) => {
      assert_eq!(r.matches("2026-07-04"), true)
      assert_eq!(r.matches("2026-7-4"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "hex color pattern" {
  match Regex::new("#[0-9A-Fa-f]{6}") {
    Some(r) => {
      assert_eq!(r.matches("#FF5733"), true)
      assert_eq!(r.matches("#123abc"), true)
      assert_eq!(r.matches("#12AB"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "find multiple positions" {
  match Regex::new("ab") {
    Some(r) => {
      let pos = r.find_all("ab cd ab ef ab")
      assert_eq!(pos.length(), 3)
    }
    None => assert_eq!(true, false)
  }
}

test "empty string matches" {
  match Regex::new("x*") {
    Some(r) => assert_eq!(r.matches(""), true)
    None => assert_eq!(true, false)
  }
}

test "D escape non-digit" {
  match Regex::new("\\D+") {
    Some(r) => {
      assert_eq!(r.matches("abc"), true)
      assert_eq!(r.matches("123"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "W escape non-word" {
  match Regex::new("\\W+") {
    Some(r) => {
      assert_eq!(r.matches("!!!@@@"), true)
      assert_eq!(r.matches("abc123"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "S escape non-space" {
  match Regex::new("\\S+") {
    Some(r) => {
      assert_eq!(r.matches("hello"), true)
      assert_eq!(r.matches("   "), false)
    }
    None => assert_eq!(true, false)
  }
}

test "complex pattern with groups and quantifiers" {
  match Regex::new("(ab|cd){2}xy(z){3}") {
    Some(r) => {
      assert_eq!(r.matches("ababxyzzz"), true)
      assert_eq!(r.matches("cdcdxyzzz"), true)
      assert_eq!(r.matches("abcdxyzz"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "split with no matches returns full string" {
  match Regex::new(",") {
    Some(r) => {
      let parts = r.split("no commas here")
      assert_eq!(parts.length(), 1)
      assert_eq!(parts[0], "no commas here")
    }
    None => assert_eq!(true, false)
  }
}

test "replace multiple occurrences" {
  match Regex::new("\\d+") {
    Some(r) => assert_eq!(r.replace("a1b23c456", "X"), "aXbXcX")
    None => assert_eq!(true, false)
  }
}

test "combined range and escape" {
  match Regex::new("[a-z0-9]+") {
    Some(r) => {
      assert_eq!(r.matches("abc123"), true)
      assert_eq!(r.matches("ABC"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "exact repetition zero" {
  match Regex::new("a{0}") {
    Some(r) => assert_eq!(r.matches(""), true)
    None => assert_eq!(true, false)
  }
}

test "exact repetition one" {
  match Regex::new("a{1}") {
    Some(r) => {
      assert_eq!(r.matches("a"), true)
      assert_eq!(r.matches("aa"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "range repetition zero to one" {
  match Regex::new("a{0,1}") {
    Some(r) => {
      assert_eq!(r.matches(""), true)
      assert_eq!(r.matches("a"), true)
      assert_eq!(r.matches("aa"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "find all non-overlapping" {
  match Regex::new("aa") {
    Some(r) => assert_eq!(r.find_all("aaabaa").length() > 0, true)
    None => assert_eq!(true, false)
  }
}

test "replace no change" {
  match Regex::new("z") {
    Some(r) => assert_eq!(r.replace("hello", "X"), "hello")
    None => assert_eq!(true, false)
  }
}

test "split empty string" {
  match Regex::new(",") {
    Some(r) => {
      let parts = r.split("")
      assert_eq!(parts.length(), 1)
    }
    None => assert_eq!(true, false)
  }
}

test "count range repeat" {
  match Regex::new("[a-z]{3,5}") {
    Some(r) => {
      assert_eq!(r.matches("abc"), true)
      assert_eq!(r.matches("abcd"), true)
      assert_eq!(r.matches("abcde"), true)
      assert_eq!(r.matches("ab"), false)
      assert_eq!(r.matches("abcdef"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "ip address pattern" {
  match Regex::new("\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}") {
    Some(r) => {
      assert_eq!(r.matches("192.168.1.1"), true)
      assert_eq!(r.matches("10.0.0.1"), true)
      assert_eq!(r.matches("256.1.1.1"), true)
      assert_eq!(r.matches("1.1.1"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "alternation with quantifier" {
  match Regex::new("(cat|dog|bird)s?") {
    Some(r) => {
      assert_eq!(r.matches("cat"), true)
      assert_eq!(r.matches("cats"), true)
      assert_eq!(r.matches("dog"), true)
      assert_eq!(r.matches("dogs"), true)
      assert_eq!(r.matches("fish"), false)
    }
    None => assert_eq!(true, false)
  }
}


test "unicode support" {
  match Regex::new(".+") {
    Some(r) => assert_eq!(r.matches("你好世界"), true)
    None => assert_eq!(true, false)
  }
}

test "multiple groups" {
  match Regex::new("(ab)(cd)(ef)") {
    Some(r) => {
      assert_eq!(r.matches("abcdef"), true)
      assert_eq!(r.matches("ab"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "exact length match" {
  match Regex::new("^\\d{5}$") {
    Some(r) => {
      assert_eq!(r.matches("12345"), true)
      assert_eq!(r.matches("1234"), false)
      assert_eq!(r.matches("123456"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "log format pattern" {
  match Regex::new("\\[\\d{4}-\\d{2}-\\d{2}\\s+\\d{2}:\\d{2}:\\d{2}\\]") {
    Some(r) => {
      assert_eq!(r.matches("[2026-07-04 14:30:15]"), true)
      assert_eq!(r.matches("[2026-7-4 14:30:15]"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "version number pattern" {
  match Regex::new("\\d+\\.\\d+\\.\\d+") {
    Some(r) => {
      assert_eq!(r.matches("1.2.3"), true)
      assert_eq!(r.matches("10.20.30"), true)
      assert_eq!(r.matches("1.2"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "path separator pattern" {
  match Regex::new("[./]") {
    Some(r) => {
      assert_eq!(r.matches("/"), true)
      assert_eq!(r.matches("."), true)
      assert_eq!(r.matches("-"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "username pattern" {
  match Regex::new("[a-zA-Z][a-zA-Z0-9_]{2,15}") {
    Some(r) => {
      assert_eq!(r.matches("user123"), true)
      assert_eq!(r.matches("abc"), true)
      assert_eq!(r.matches("12user"), false)
      assert_eq!(r.matches("ab"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "split by comma with spaces" {
  match Regex::new("\\s*,\\s*") {
    Some(r) => {
      let parts = r.split("a, b,  c")
      assert_eq!(parts.length(), 3)
    }
    None => assert_eq!(true, false)
  }
}

test "count words" {
  match Regex::new("[a-zA-Z]+") {
    Some(r) => assert_eq!(r.count("hello world test"), 3)
    None => assert_eq!(true, false)
  }
}

test "replace with capture reference" {
  match Regex::new("\\d+") {
    Some(r) => assert_eq!(r.replace("id: 12345", "X"), "id: X")
    None => assert_eq!(true, false)
  }
}

test "alternation in group" {
  match Regex::new("(Mr|Ms|Dr)\\.\\s+\\w+") {
    Some(r) => {
      assert_eq!(r.matches("Mr. Smith"), true)
      assert_eq!(r.matches("Dr. Jones"), true)
      assert_eq!(r.matches("Mrs. Brown"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "optional at start" {
  match Regex::new("-?\\d+") {
    Some(r) => {
      assert_eq!(r.matches("42"), true)
      assert_eq!(r.matches("-42"), true)
      assert_eq!(r.matches("--42"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "multiple optional groups" {
  match Regex::new("a(b)?(c)?d") {
    Some(r) => {
      assert_eq!(r.matches("ad"), true)
      assert_eq!(r.matches("abd"), true)
      assert_eq!(r.matches("acd"), true)
      assert_eq!(r.matches("abcd"), true)
    }
    None => assert_eq!(true, false)
  }
}

test "plus and star combination" {
  match Regex::new("a+b*c") {
    Some(r) => {
      assert_eq!(r.matches("ac"), true)
      assert_eq!(r.matches("abc"), true)
      assert_eq!(r.matches("aac"), true)
      assert_eq!(r.matches("abbbbc"), true)
    }
    None => assert_eq!(true, false)
  }
}

test "match result on full match" {
  match Regex::new("[a-z]+") {
    Some(r) => {
      let result = r.match_result("hello")
      assert_eq!(result.matched, true)
      assert_eq!(result.end, 5)
    }
    None => assert_eq!(true, false)
  }
}

test "empty pattern matches everything" {
  match Regex::new("") {
    Some(r) => {
      assert_eq!(r.matches(""), true)
      assert_eq!(r.matches("abc"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "url validation pattern" {
  match Regex::new("https?://[a-zA-Z0-9.]+(/[a-zA-Z0-9./]*)?") {
    Some(r) => {
      assert_eq!(r.matches("https://example.com"), true)
      assert_eq!(r.matches("http://site.org/path"), true)
      assert_eq!(r.matches("ftp://bad.com"), false)
    }
    None => assert_eq!(true, false)
  }
}


test "camelCase identifier" {
  match Regex::new("[a-z]+([A-Z][a-z]+)*") {
    Some(r) => {
      assert_eq!(r.matches("hello"), true)
      assert_eq!(r.matches("helloWorld"), true)
      assert_eq!(r.matches("helloWorldTest"), true)
      assert_eq!(r.matches("Hello"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "tag with content" {
  match Regex::new("<[a-z]+>[^<]*</[a-z]+>") {
    Some(r) => {
      assert_eq!(r.matches("<div>hello</div>"), true)
      assert_eq!(r.matches("<span>text</span>"), true)
      assert_eq!(r.matches("<div>hello"), false)
    }
    None => assert_eq!(true, false)
  }
}

test "find at start" {
  match Regex::new("start") {
    Some(r) => assert_eq!(r.find("start middle end"), 0)
    None => assert_eq!(true, false)
  }
}

test "find at end" {
  match Regex::new("end") {
    Some(r) => assert_eq!(r.find("start middle end"), 13)
    None => assert_eq!(true, false)
  }
}

test "split by multiple delimiters" {
  match Regex::new("[,;]") {
    Some(r) => {
      let parts = r.split("a,b;c")
      assert_eq!(parts.length(), 3)
    }
    None => assert_eq!(true, false)
  }
}

test "count nested groups" {
  match Regex::new("((a)b)") {
    Some(r) => assert_eq!(r.count("ab ab ab"), 3)
    None => assert_eq!(true, false)
  }
}

test "matches null input" {
  match Regex::new("a*") {
    Some(r) => assert_eq!(r.matches(""), true)
    None => assert_eq!(true, false)
  }
}

test "word boundary pattern" {
  match Regex::new("\\bcat\\b") {
    Some(r) => {
      assert_eq!(r.matches("cat"), false)
    }
    None => assert_eq!(true, false)
  }
}

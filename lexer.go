package main

import (
	"log"
	"math/big"
	"regexp"
	"unicode"
	"unicode/utf8"
)

//go:generate goyacc -o build/nix.go -p nix nix.go.y
//go:generate bash -c "cp *.go build && mv y.output build"
//go:generate bash -c "gofmt -s -w ./build/*.go"
//go:generate bash -c "goimports -w ./build/*.go"
//go:generate bash -c "gofmt -s -w ./build/*.go"

type nixLex struct {
	source []byte
	peek   rune
	stack  []StrType
	braces []int
}

// The parser expects the lexer to return 0 on EOF. Give it a name for clarity.
const eof = 0

var Regex = map[int]*regexp.Regexp{}

func init() {
	Regex[NUM] = regexp.MustCompile(`^[0-9][0-9\.eE]*`)
	Regex[VAR] = regexp.MustCompile(`^[\pL\pN][\pL\pN-_]*`)
}

// Return the next rune for the lexer.
func (x *nixLex) next() rune {
	if x.peek != eof {
		r := x.peek
		x.peek = eof
		return r
	}
	if len(x.source) == 0 {
		return eof
	}
	c, size := utf8.DecodeRune(x.source)
	if c == utf8.RuneError && size == 1 {
		log.Print("invalid utf8")
		return x.next()
	}
	return c
}

func (x *nixLex) fromRegex(ret int, yylval *nixSymType) string {
	out := Regex[ret].Find(x.source)
	if len(out) == 0 {
		log.Fatalf("Failed parse at: %c%s%s\n", x.source[:10], "...")
	}
	x.source = x.source[len(out):]
	return string(out)
}

// Lex a variable.
func (x *nixLex) variable(yylval *nixSymType) int {
	keywords := map[string]int{
		"rec":    REC,
		"or":     OR,
		"true":   TRUE,
		"false":  FALSE,
		"null":   NULL,
		"let":    LET,
		"in":     IN,
		"if":     IF,
		"then":   THEN,
		"else":   ELSE,
		"assert": ASSERT,
		"with":   WITH,
	}
	v := x.fromRegex(VAR, yylval)
	if ret, ok := keywords[v]; ok {
		return ret
	}
	yylval.Var = Var(v)
	return VAR
}

// Lex a number.
func (x *nixLex) num(yylval *nixSymType) int {
	yylval.Num = &big.Rat{}
	b := x.fromRegex(NUM, yylval)
	_, ok := yylval.Num.SetString(b)
	if !ok {
		log.Printf("bad number %q", b)
		return eof
	}
	return NUM
}

func (x *nixLex) stringNorm(yylval *nixSymType) int {
	return NormStrM.RunState(S0, x, yylval)
}

func (x *nixLex) stringMult(yylval *nixSymType) int {
	return MultStrM.RunState(S0, x, yylval)
}

// The parser calls this method to get each new token. This implementation
// returns operators and NUM.
func (x *nixLex) Lex(yylval *nixSymType) int {
	for {
		c := x.next()
		switch {
		case c == eof:
			return eof
		case InSlice(c, []rune("0123456789")):
			return x.num(yylval)
		case InSlice(c, []rune("+-*/()=,[];@.")):
			x.source = x.source[size(c):]
			return int(c)

		// Recognize Unicode multiplication and division
		// symbols, returning what the parser expects.
		case c == '×':
			x.source = x.source[size(c):]
			return '*'
		case c == '÷':
			x.source = x.source[size(c):]
			return '/'

		case c == '{':
			x.source = x.source[size(c):]
			x.braces[len(x.braces)-1] += 1

		case c == '}':
			if x.braces[len(x.braces)-1] > 0 {
				x.source = x.source[size(c):]
				x.braces[len(x.braces)-1] -= 1
			} else {
				x.braces = x.braces[:len(x.braces)-1]
				strType := x.stack[len(x.stack)-1]
				x.stack = x.stack[:len(x.stack)-1]
				end := "\""
				if strType == MULT {
					end = "''"
				}
				x.source = append([]byte("+ "+end), x.source[size(c):]...)
			}

		case c == '"':
			return x.stringNorm(yylval)
		case c == '\'':
			return x.stringMult(yylval)
		case unicode.IsLetter(c):
			return x.variable(yylval)
		case InSlice(c, []rune(" \t\n\r")):
			x.source = x.source[size(c):]
		default:
			log.Printf("unrecognized character %q", c)
		}
	}
}

func size(r rune) int {
	return len(string(r))
}

// The parser calls this method on a parse error.
func (x *nixLex) Error(s string) {
	log.Printf("parse error: %s", s)
}

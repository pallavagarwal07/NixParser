%{

package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"log"
	"math/big"
	"os"
	"unicode/utf8"
)

%}

%union {
	Num Num
	Var Var
	Str Str
	All All
}

%type <All> expr expr1 expr2 expr3
%type <All> set attr list expr1 expr1List attrList letexpr func varSet orexpr
%type <All> varList pattern ifexpr assert withexpr selection selectionList
%type <All> value

%token '+' '-' '*' '/' '(' ')' '{' '}' '=' '[' ']' ';' '.' ',' '@' '?'
%token OR REC TRUE FALSE NULL LET IN IF THEN ELSE ASSERT WITH

%token	<Num>	NUM
%token	<Var>	VAR
%token	<Str>	STR

%%

top
	: expr

expr1List
	: /* Empty */    { $$ = "a" }
	| expr1List expr1

attr
	: VAR '=' expr ';' { $$ = $3 }
	| STR '=' expr ';' { $$ = $3 }

attrList
	: attr             { $$ = $1 }
	| attrList attr

emptySet
	: '{' '}'

set
	: emptySet             { fmt.Println("emptySet") }
	| '{' attrList '}'     { $$ = $2 }
	| REC '{' attrList '}' { $$ = $3 }

list
	: '[' expr1List ']' { $$ = $2 }

expr
	: expr1
	| '-' expr { $$ = $2 }
	| letexpr  { $$ = $1 }
	| func
	| ifexpr
	| assert
	| withexpr
	| orexpr

expr1
	: expr2
	| expr1 '+' expr2
	| expr1 '-' expr2

expr2
	: expr3
	| expr2 '*' expr3
	| expr2 '/' expr3

expr3
	: list
	| set
	| value             {  }
	| VAR               { $$ = "a" }
	| STR               { $$ = "a" }
	| NUM               { $$ = "a" }
	| '(' expr ')'      { $$ = $2  }

orexpr
	: value OR expr

value
	: set selectionList        {  }
	| VAR selectionList        {  }

selection
	: '.' STR           {  }
	| '.' VAR           {  }

selectionList
	: selection                { $$ = $1 }
	| selectionList selection  { $$ = $1 }

letexpr
	: LET attrList IN expr  { $$ = $4 }

withexpr
	: WITH expr ';' expr {  }

func
	: pattern ':' expr { $$ = $3 }

pattern
	: VAR              { $$ = "Hi" }
	| varSet
	| VAR '@' varSet   { $$ = "Hi" }

varSet
	: emptySet                             { $$ = "a" }
	| '{' varList '}'                      { $$ = $2 }
	| '{' '.' '.' '.' '}'                  { println("no") }
	| '{' varList ',' '.' '.' '.' '}'      { $$ = $2 }

varList
	: listElem              { $$ = "hi" }
	| varList ',' listElem  { $$ = $1   }

listElem
	: VAR
	| VAR '?' expr

ifexpr
	: IF expr THEN expr ELSE expr  { println("hi") }

assert
	: ASSERT expr ';' expr  { $$ = $4 }

%%

func main() {
	if len(os.Args) < 2 {
		fmt.Printf("USAGE: %s filename\n", filepath.Base(os.Args[0]))
		os.Exit(1)
	}
	content, err := ioutil.ReadFile(os.Args[1])
	if err != nil {
		log.Fatalln("Unable to read file:", err)
	}
	lexer := &nixLex{source: content}
	counter := nixSymType{}
	for {
		ret := lexer.Lex(&counter)
		if ret == 0 {
			return
		}
		switch ret {
		case NUM:
			fmt.Println("NUM", counter.Num)
		case STR:
			fmt.Println("STR", counter.Str)
		case VAR:
			fmt.Println("VAR", counter.Var)
		case REC:
			fmt.Println("REC")
		case OR:
			fmt.Println("OR")
		default:
			fmt.Println("RUNE", string(rune(ret)))
		}
	}
}

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
%type <All> set attr list expr1List attrList letexpr func varSet orexpr
%type <All> varList pattern ifexpr assert withexpr selection selectionList
%type <All> value

%token '+' '-' '*' '/' '(' ')' '{' '}' '=' '[' ']' ';' '.' ',' '@' '?' ':'
%token OR REC TRUE FALSE NULL LET IN IF THEN ELSE ASSERT WITH INHERIT

%token	<Num>	NUM
%token	<Var>	VAR
%token	<Str>	STR

%%

top
	: expr  { println("top", "expr") }

expr1List
	: /* Empty */  { println("expr1List", "/* Empty */") }
	| expr1List expr1  { println("expr1List", "expr1List expr1") }

attr
	: VAR '=' expr ';'  { println("attr", "VAR '=' expr ';'") }
	| STR '=' expr ';'  { println("attr", "STR '=' expr ';'") }

attrList
	: attr  { println("attrList", "attr") }
	| attrList attr  { println("attrList", "attrList attr") }

emptySet
	: '{' '}'  { println("emptySet", "'{' '}'") }

set
	: emptySet  { println("set", "emptySet") }
	| '{' setContentList '}'  { println("set", "'{' setContentList '}'") }
	| REC '{' setContentList '}'  { println("set", "REC '{' setContentList '}'") }

setContent
	: attr      { println("setContent", "attr") }
	| inherit   { println("setContent", "inherit") }

setContentList
	: setContent { println("setContentList", "setContent") }
	| setContentList setContent { println("setContentList", "setContentList setContent") }

inherit
	: INHERIT VAR ';' { println("inherit", "INHERIT VAR ';'") }

list
	: '[' expr1List ']'  { println("list", "'[' expr1List ']'") }

expr
	: expr1  { println("expr", "expr1") }
	| '-' expr  { println("expr", "'-' expr") }
	| letexpr  { println("expr", "letexpr") }
	| func  { println("expr", "func") }
	| ifexpr  { println("expr", "ifexpr") }
	| assert  { println("expr", "assert") }
	| withexpr  { println("expr", "withexpr") }
	| orexpr  { println("expr", "orexpr") }
	| expr3 expr3 { println("expr", "expr3 expr3") }

expr1
	: expr2  { println("expr1", "expr2") }
	| expr1 '+' expr2  { println("expr1", "expr1 '+' expr2") }
	| expr1 '-' expr2  { println("expr1", "expr1 '-' expr2") }

expr2
	: expr3  { println("expr2", "expr3") }
	| expr2 '*' expr3  { println("expr2", "expr2 '*' expr3") }
	| expr2 '/' expr3  { println("expr2", "expr2 '/' expr3") }

expr3
	: list  { println("expr3", "list") }
	| set  { println("expr3", "set") }
	| value  { println("expr3", "value") }
	| VAR  { println("expr3", "VAR") }
	| STR  { println("expr3", "STR") }
	| NUM  { println("expr3", "NUM") }
	| '(' expr ')'  { println("expr3", "'(' expr ')'") }

orexpr
	: value OR expr  { println("orexpr", "value OR expr") }

value
	: set selectionList  { println("value", "set selectionList") }
	| VAR selectionList  { println("value", "VAR selectionList") }

selection
	: '.' STR  { println("selection", "'.' STR") }
	| '.' VAR  { println("selection", "'.' VAR") }

selectionList
	: selection  { println("selectionList", "selection") }
	| selectionList selection  { println("selectionList", "selectionList selection") }

letexpr
	: LET attrList IN expr  { println("letexpr", "LET attrList IN expr") }

withexpr
	: WITH expr ';' expr  { println("withexpr", "WITH expr ';' expr") }

func
	: pattern ':' expr  { println("func", "pattern ':' expr") }

pattern
	: VAR  { println("pattern", "VAR") }
	| varSet  { println("pattern", "varSet") }
	| VAR '@' varSet  { println("pattern", "VAR '@' varSet") }

varSet
	: emptySet  { println("varSet", "emptySet") }
	| '{' varList '}'  { println("varSet", "'{' varList '}'") }
	| '{' '.' '.' '.' '}'  { println("varSet", "'{' '.' '.' '.' '}'") }
	| '{' varList ',' '.' '.' '.' '}'  { println("varSet", "'{' varList ',' '.' '.' '.' '}'") }

varList
	: listElem  { println("varList", "listElem") }
	| varList ',' listElem  { println("varList", "varList ',' listElem") }

listElem
	: VAR  { println("listElem", "VAR") }
	| VAR '?' expr  { println("listElem", "VAR '?' expr") }

ifexpr
	: IF expr THEN expr ELSE expr  { println("ifexpr", "IF expr THEN expr ELSE expr") }

assert
	: ASSERT expr ';' expr  { println("assert", "ASSERT expr ';' expr") }

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
	lexer := &nixLex{
		source: content,
		braces: []int{0},
	}
	nixParse(lexer)
	// counter := nixSymType{}
	// for {
	// 	ret := lexer.Lex(&counter)
	// 	if ret == 0 {
	// 		return
	// 	}
	// 	switch ret {
	// 	case NUM:
	// 		fmt.Println("NUM", counter.Num)
	// 	case STR:
	// 		fmt.Println("STR", counter.Str)
	// 	case VAR:
	// 		fmt.Println("VAR", counter.Var)
	// 	case REC:
	// 		fmt.Println("REC")
	// 	case OR:
	// 		fmt.Println("OR")
	// 	default:
	// 		fmt.Println("RUNE", string(rune(ret)))
	// 	}
	// }
}

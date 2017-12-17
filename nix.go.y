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
}

%type	<Num>	expr expr1 expr2 expr3

%token '+' '-' '*' '/' '(' ')' '{' '}' '='

%token	<Num>	NUM
%token	<Var>	VAR
%token	<Str>	STR

%%

top:
	expr
	{
		if $1.IsInt() {
			fmt.Println($1.Num().String())
		} else {
			fmt.Println($1.String())
		}
	}
|	VAR top
	{
		fmt.Println("Variable:", $1)
	}

expr:
	expr1
|	'+' expr
	{
		$$ = $2
	}
|	'-' expr
	{
		$$ = $2.Neg($2)
	}

expr1:
	expr2
|	expr1 '+' expr2
	{
		$$ = $1.Add($1, $3)
	}
|	expr1 '-' expr2
	{
		$$ = $1.Sub($1, $3)
	}

expr2:
	expr3
|	expr2 '*' expr3
	{
		$$ = $1.Mul($1, $3)
	}
|	expr2 '/' expr3
	{
		$$ = $1.Quo($1, $3)
	}

expr3:
	NUM
|	'(' expr ')'
	{
		$$ = $2
	}


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
		default:
			fmt.Println("RUNE", string([]rune{rune(ret)}))
		}
	}
}

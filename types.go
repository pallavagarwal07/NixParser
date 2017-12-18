package main

import (
	"math/big"
)

type Num = *big.Rat
type Str string
type Var string

type StrType int

// String Type.
// NORM = normal string using double quotes `"`
// MULT = multiline string using 2 single quotes `''`
const (
	NORM StrType = iota
	MULT
)

type StrTerm int

// Termination type.
// STR = Terminated using proper closing quotation.
// VAR = Parser terminated string due to anti-quotation.
const (
	STR StrTerm = iota
	VAR
)

type FSM map[State]map[rune]State
type State int

// Reusable state variables.
const (
	AC State = iota
	RJ
	S0
	S1
	S2
	S3
	S4
	S5
	S6
	S7
	S8
)

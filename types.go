package main

import (
	"math/big"
)

type Num = *big.Rat
type Str string
type Var string
type All interface{}

type StrType int

// String Type.
// NORM = normal string using double quotes `"`
// MULT = multiline string using 2 single quotes `''`
const (
	NORM StrType = iota
	MULT
)

type StrTerm int

type FSM struct {
	St  map[State]map[rune]State
	Ac  []State
	Rj  []State
	End string
	Var []State
}
type State int

// Reusable state variables.
const (
	S0 State = iota
	S1
	S2
	S3
	S4
	S5
	S6
	S7
	S8

	PEEK State = 1 << 30
	U0   State = iota | PEEK
	U1
	U2
	U3
	U4
	U5
	U6
	U7
	U8
)

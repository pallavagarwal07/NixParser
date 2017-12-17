package main

import (
	"math/big"
)

type Num = *big.Rat
type Str string
type Var string

type StrType int

const (
	NORM StrType = iota
	MULT
)

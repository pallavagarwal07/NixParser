package main

import (
	"log"
	"runtime"
	"unicode/utf8"
)

var NormStrM = FSM{
	St: map[State]map[rune]State{
		S0: {0: U0, '"': S1},
		S1: {0: S1, '\\': S2, '$': S3, '"': S4},
		S2: {0: S1},
		S3: {0: S1, '\\': S2, '$': S3, '{': S5, '"': S4},
		S4: {0: S4},
		S5: {0: S5},
	},
	Ac:  []State{S4, S5},
	Rj:  []State{U0},
	End: "\"",
	Var: []State{S5},
}

var MultStrM = FSM{
	St: map[State]map[rune]State{
		S0: {0: U1, '\'': S1},
		S1: {0: U1, '\'': S2},
		S2: {0: S2, '$': S3, '\'': S4},
		S3: {0: S2, '$': S3, '{': S5},
		S4: {0: S2, '$': S3, '\'': S6},
		S5: {0: S5},                                      // REJECT
		S6: {0: U0, -1: U0, '\'': S2, '$': S2, '\\': S2}, // PEEK
		U0: {0: U0},                                      // ACCEPT
		U1: {0: U1},
	},
	Ac:  []State{U0, S5},
	Rj:  []State{U1},
	End: "''",
	Var: []State{S5},
}

func dbg(c rune) {
	_, fn, line, _ := runtime.Caller(1)
	log.Printf("%s:%d for rune %c", fn, line, c)
}

func (fsm FSM) getStrType() StrType {
	if fsm.End == "''" {
		return MULT
	}
	return NORM
}

func (fsm FSM) RunState(start State, x *nixLex, yylval *nixSymType) int {
	state := start
	result := []rune{}
	for i, w := 0, 0; i < len(x.source); i += w {
		c, width := utf8.DecodeRune(x.source[i:])
		w = width

		if m, ok := fsm.St[state]; !ok {
			log.Fatalln("Machine state not available", state)
		} else if s, ok := m[c]; ok {
			state = s
		} else if s, ok := m[0]; ok {
			state = s
		} else {
			log.Fatalln("Machine transition 0 not available")
		}

		if state&PEEK == 0 {
			// Not a peek.
			result = append(result, c)
		}
		if InSlice(state, fsm.Ac) || InSlice(state, fsm.Rj) {
			break
		}
	}

OUT:
	if InSlice(state, fsm.Ac) {
		if InSlice(state, fsm.Var) {
			x.source = x.source[len(string(result))-1:]
			x.source[0] = '+'
			x.stack = append(x.stack, fsm.getStrType())
			x.braces = append(x.braces, 0)
			result = result[:len(result)-2]             // Remove `${`
			result = append(result, []rune(fsm.End)...) // Add the `"` or `''`
		} else {
			x.source = x.source[len(string(result)):]
		}
		yylval.Str = Str(result)
	} else if InSlice(state, fsm.Rj) {
		log.Fatalln("Not a string")
	} else if m, ok := fsm.St[state]; !ok {
		log.Fatalln("Machine state not available", state)
	} else if s, ok := m[-1]; ok {
		state = s
		goto OUT
	} else {
		log.Fatalln("Unterminated string")
	}
	//fmt.Printf("%q %d\n", string(result))
	return STR
}

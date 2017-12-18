package main

import (
	"log"
	"runtime"
)

var NormStrM = FSM{
	AC: {0: AC},
	RJ: {0: RJ},
	S0: {0: RJ, '"': S1},
	S1: {0: S1, '\\': S2, '$': S3, '"': AC},
	S2: {0: S1},
	S3: {0: S1, '\\': S2, '$': S3, '{': RJ, '"': AC},
}

func dbg(c rune) {
	_, fn, line, _ := runtime.Caller(1)
	log.Printf("%s:%d for rune %c", fn, line, c)
}

func (fsm FSM) RunState(start State, str string) StrTerm {
	state := start
	for _, c := range str {
		if m, ok := fsm[state]; !ok {
			log.Fatalln("Machine state not available", state)
		} else if s, ok := m[c]; ok {
			state = s
		} else if s, ok := m[0]; ok {
			state = s
		} else {
			log.Fatalln("Machine transition 0 not available")
		}
		if state == AC || state == RJ {
			break
		}
	}
	if state == AC {
		return STR
	} else if state == RJ {
		return VAR
	} else {
		log.Fatalln("Unterminated string")
	}
	return 0
}

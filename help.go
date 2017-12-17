package main

import (
	"reflect"
)

func InSlice(needle interface{}, haystack interface{}) bool {
	rv := reflect.ValueOf(haystack)
	if rv.Kind() != reflect.Slice {
		panic("Second argument to InSlice not a slice")
	}
	for i := 0; i < rv.Len(); i++ {
		if reflect.DeepEqual(needle, rv.Index(i).Interface()) {
			return true
		}
	}
	return false
}

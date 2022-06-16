package graph

import (
	"sync"
	"thegame/graph/model"
)


func UpdateDice(observers sync.Map, val int) {
	observers.Range(func (key interface{}, value interface{}) bool {
		value.(chan int) <- val
		return true
	})
}

func CardEvent(observers sync.Map, val *model.CardEvent) {
	observers.Range(func (key interface{}, value interface{}) bool {
		value.(chan *model.CardEvent) <- val
		return true
	})
}

func ChipEvent(observers sync.Map, val *model.ChipEvent) {
	observers.Range(func (key interface{}, value interface{}) bool {
		value.(chan *model.ChipEvent) <- val
		return true
	})
}

func IntuitionEvent(observers sync.Map, val bool) {
	observers.Range(func (key interface{}, value interface{}) bool {
		value.(chan bool) <- val
		return true
	})
}

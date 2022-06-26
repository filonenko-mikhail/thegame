package graph

import (
	"context"
	"sync"
	"thegame/graph/model"
	"time"
)


func UpdateDice(observers sync.Map, val int) {
	observers.Range(func (key interface{}, value interface{}) bool {
		value.(chan int) <- val
		return true
	})
}

func CardEvent(observers sync.Map, val *model.CardEvent, resolver *cardMutationsResolver) {
	resolver.CardEventMutex.Lock()
	defer resolver.CardEventMutex.Unlock()
	resolver.CardEvents = append(resolver.CardEvents, val)
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


func CardLoop(ctx context.Context, ticker *time.Ticker, resolver *Resolver) {
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			resolver.CardEventMutex.Lock()
			defer resolver.CardEventMutex.Unlock()

			for _, cardEvent := range resolver.CardEvents {
				resolver.CardObservers.Range(func (key interface{}, value interface{}) bool {
					value.(chan *model.CardEvent) <- cardEvent
					return true
				})
			}
		}
	}
}

func PingLoop(ctx context.Context, ticker *time.Ticker, resolver *Resolver) {
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			resolver.PingObservers.Range(func(key interface{}, value interface{}) bool {
				value.(chan bool) <- true
				return true
			})
		}
	}
}

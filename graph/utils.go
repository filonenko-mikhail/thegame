package graph

import (
	"context"
	"sync"
	"thegame/graph/model"
	"time"

	"github.com/sirupsen/logrus"
)


func UpdateDice(observers sync.Map, val int, resolver *diceMutationsResolver) {
	resolver.PushMutex.Lock()
	defer resolver.PushMutex.Unlock()
	observers.Range(func (key interface{}, value interface{}) bool {
		select {
		case value.(chan int) <- val:
		default:
		  logrus.Printf("could not send message to %q\n", key)
		}
		return true
	})
}

func CardEvent(observers sync.Map, cardEvent *model.CardEvent, resolver *cardMutationsResolver) {
	resolver.PushMutex.Lock()
	defer resolver.PushMutex.Unlock()

	resolver.CardObservers.Range(func (key interface{}, value interface{}) bool {
		select {
		case value.(chan *model.CardEvent) <- cardEvent:
		default:
		  logrus.Printf("could not send message to %q\n", key)
		}
		return true
	})
}

func ChipEvent(observers sync.Map, val *model.ChipEvent, resolver *chipMutationsResolver) {
	resolver.PushMutex.Lock()
	defer resolver.PushMutex.Unlock()

	observers.Range(func (key interface{}, value interface{}) bool {
		select {
		case value.(chan *model.ChipEvent) <- val:
		default:
		  logrus.Printf("could not send message to %q\n", key)
		}
		return true
	})
}

func IntuitionEvent(observers sync.Map, val bool, resolver *intuitionMutationsResolver) {
	resolver.PushMutex.Lock()
	defer resolver.PushMutex.Unlock()

	observers.Range(func (key interface{}, value interface{}) bool {
		select {
		case value.(chan bool) <- val:
		default:
		  logrus.Printf("could not send message to %q\n", key)
		}
		return true
	})
}


func PingLoop(ctx context.Context, ticker *time.Ticker, resolver *Resolver) {
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			resolver.PingObservers.Range(func(key interface{}, value interface{}) bool {
				select {
				case value.(chan bool) <- true:
				default:
				  logrus.Printf("could not send message to %q\n", key)
				}
				return true
			})
		}
	}
}

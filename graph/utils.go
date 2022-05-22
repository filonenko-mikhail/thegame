package graph

import (
	"sync"
	"thegame/graph/model"
)

func Update(chatMessages []*model.Update, 
	chatObservers map[string]chan []*model.Update,
	mu sync.Mutex,
	id string) {
	
	// Construct the newly sent message and append it to the existing messages
	msg := model.Update{
		ID: id,
	}
	chatMessages = append(chatMessages, &msg)
	mu.Lock()
	// Notify all active subscriptions that a new message has been posted by posted. In this case we push the now
	// updated ChatMessages array to all clients that care about it.
	for _, observer := range chatObservers {
		observer <- chatMessages
	}
	mu.Unlock()

}

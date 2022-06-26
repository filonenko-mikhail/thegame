package graph

import (
	"database/sql"
	"sync"
	"thegame/graph/model"
)

// This file will not be regenerated automatically.
//
// It serves as dependency injection for your app, add any dependencies you require here.

type Resolver struct{
	Db *sql.DB
	Dice int
	Card sync.Map // map[string]*model.Card
	Chip sync.Map // map[string]*model.Card
	Content sync.Map // map[string]*model.Content
	Intuition bool

	// All active subscriptions
	DiceObservers sync.Map
	CardObservers sync.Map
	ChipObservers sync.Map
	IntuitionObservers sync.Map
	PingObservers sync.Map

	CardEventMutex sync.Mutex
	CardEvents []*model.CardEvent
}

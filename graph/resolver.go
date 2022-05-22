package graph

import (
	"database/sql"
	"sync"
	"thegame/graph/model"

	"golang.org/x/sync/syncmap"
)

// This file will not be regenerated automatically.
//
// It serves as dependency injection for your app, add any dependencies you require here.

type Resolver struct{
	Db *sql.DB
	Dice int
	Card syncmap.Map // map[string]*model.Card
	Chip syncmap.Map // map[string]*model.Card
	Intuition bool

	// All messages since launching the GraphQL endpoint
	ChatMessages  []*model.Update
	// All active subscriptions
	ChatObservers map[string]chan []*model.Update
	mu            sync.Mutex
}

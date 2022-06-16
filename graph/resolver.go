package graph

import (
	"database/sql"
	"sync"

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

	// All active subscriptions
	DiceObservers sync.Map
	CardObservers sync.Map
}

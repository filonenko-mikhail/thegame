package graph

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.

import (
	"context"
	"fmt"
	"thegame/graph/generated"
	"thegame/graph/model"

	"github.com/google/uuid"
	"github.com/sirupsen/logrus"
)

func (r *cardMutationsResolver) Add(ctx context.Context, obj *model.CardMutations, payload model.CardAddPayload) (*model.Card, error) {
	_, err := r.Db.ExecContext(ctx,
		`INSERT INTO cards(card_id, body, x, y, color, flipable, flip, fliptext, prio, sizex, sizey)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		payload.ID, payload.Text, payload.X, payload.Y, payload.Color, payload.Flipable, payload.Flip, payload.Fliptext, payload.Prio, payload.Sizex, payload.Sizey)
	if err != nil {
		logrus.Info(err)
		return nil, err
	}

	item := &model.Card{
		ID:       payload.ID,
		Text:     payload.Text,
		X:        payload.X,
		Y:        payload.Y,
		Color:    payload.Color,
		Flipable: payload.Flipable,
		Flip:     payload.Flip,
		Fliptext: payload.Fliptext,
		Prio:     payload.Prio,
		Sizex:    payload.Sizex,
		Sizey:    payload.Sizey,
	}
	r.Card.Store(payload.ID, item)

	event := &model.CardEvent{
		Add: &model.CardAddEvent{
			ID:       payload.ID,
			Text:     payload.Text,
			X:        payload.X,
			Y:        payload.Y,
			Color:    payload.Color,
			Flipable: payload.Flipable,
			Flip:     payload.Flip,
			Fliptext: payload.Fliptext,
			Prio:     payload.Prio,
			Sizex:    payload.Sizex,
			Sizey:    payload.Sizey,
		},
	}
	CardEvent(r.CardObservers, event, r)

	return item, nil
}

func (r *cardMutationsResolver) Move(ctx context.Context, obj *model.CardMutations, payload *model.CardMovePayload) (*model.Card, error) {
	if val, ok := r.Card.Load(payload.ID); ok {
		_, err := r.Db.ExecContext(ctx,
			`UPDATE cards SET x = ?, y = ? WHERE card_id = ?`,
			payload.X, payload.Y, payload.ID)
		if err != nil {
			logrus.Info(err)
			return nil, err
		}

		item := val.(*model.Card)
		item.X = payload.X
		item.Y = payload.Y

		CardEvent(r.CardObservers, &model.CardEvent{
			Move: &model.CardMoveEvent{
				ID: payload.ID,
				X:  payload.X,
				Y:  payload.Y,
			},
		}, r)

		return item, nil
	}
	return nil, fmt.Errorf("no card for id: %s", payload.ID)
}

func (r *cardMutationsResolver) Remove(ctx context.Context, obj *model.CardMutations, payload *model.CardRemovePayload) (*model.Card, error) {
	if val, ok := r.Card.Load(payload.ID); ok {
		_, err := r.Db.ExecContext(ctx, `DELETE FROM cards WHERE card_id = ?`, payload.ID)
		if err != nil {
			logrus.Info(err)
			return nil, err
		}

		item := val.(*model.Card)
		r.Card.Delete(payload.ID)

		event := &model.CardEvent{
			Remove: &model.CardRemoveEvent{
				ID: payload.ID,
			},
		}
		CardEvent(r.CardObservers, event, r)

		return item, nil
	}

	return nil, fmt.Errorf("no card when delete for id: %s", payload.ID)
}

func (r *cardMutationsResolver) Flip(ctx context.Context, obj *model.CardMutations, payload *model.CardFlipPayload) (*model.Card, error) {
	if val, ok := r.Card.Load(payload.ID); ok {
		_, err := r.Db.ExecContext(ctx,
			`UPDATE cards SET flip = ? WHERE card_id = ?`,
			payload.Flip, payload.ID)
		if err != nil {
			logrus.Info(err)
			return nil, err
		}

		item := val.(*model.Card)
		item.Flip = payload.Flip

		CardEvent(r.CardObservers,
			&model.CardEvent{
				Flip: &model.CardFlipEvent{
					ID:   payload.ID,
					Flip: payload.Flip,
				},
			},
			r)

		return item, nil
	}
	return nil, fmt.Errorf("no card for id: %s", payload.ID)
}

func (r *cardMutationsResolver) Prio(ctx context.Context, obj *model.CardMutations, payload *model.CardPrioPayload) (*model.Card, error) {
	if val, ok := r.Card.Load(payload.ID); ok {
		_, err := r.Db.ExecContext(ctx,
			`UPDATE cards SET prio = ? WHERE card_id = ?`,
			payload.Prio, payload.ID)
		if err != nil {
			logrus.Info(err)
			return nil, err
		}

		item := val.(*model.Card)
		item.Prio = payload.Prio

		CardEvent(r.CardObservers,
			&model.CardEvent{
				Prio: &model.CardPrioEvent{
					ID:   payload.ID,
					Prio: payload.Prio,
				},
			}, r)
		return item, nil
	}
	return nil, fmt.Errorf("no card for id: %s", payload.ID)
}

func (r *cardQueriesResolver) List(ctx context.Context, obj *model.CardQueries) ([]*model.Card, error) {
	result := make([]*model.Card, 0)
	r.Card.Range(
		func(k interface{}, val interface{}) bool {
			item := val.(*model.Card)
			result = append(result, item)
			return true
		})

	return result, nil
}

func (r *chipMutationsResolver) Add(ctx context.Context, obj *model.ChipMutations, payload model.ChipAddPayload) (*model.Chip, error) {
	_, err := r.Db.ExecContext(ctx,
		`INSERT INTO chips(chip_id, color, x, y)
		VALUES (?, ?, ?, ?)`,
		payload.ID, payload.Color, payload.X, payload.Y)
	if err != nil {
		logrus.Info(err)
		return nil, err
	}

	item := &model.Chip{
		ID:    payload.ID,
		X:     payload.X,
		Y:     payload.Y,
		Color: payload.Color,
	}
	r.Chip.Store(payload.ID, item)

	ChipEvent(r.ChipObservers, &model.ChipEvent{
		Add: &model.ChipAddEvent{
			ID:    payload.ID,
			X:     payload.X,
			Y:     payload.Y,
			Color: payload.Color,
		},
	}, r)

	return item, nil
}

func (r *chipMutationsResolver) Move(ctx context.Context, obj *model.ChipMutations, payload *model.CardMovePayload) (*model.Chip, error) {
	if val, ok := r.Chip.Load(payload.ID); ok {
		_, err := r.Db.ExecContext(ctx,
			`UPDATE cards SET x = ?, y = ? WHERE card_id = ?`,
			payload.X, payload.Y, payload.ID)
		if err != nil {
			logrus.Info(err)
			return nil, err
		}

		item := val.(*model.Chip)
		item.X = payload.X
		item.Y = payload.Y

		ChipEvent(r.ChipObservers, &model.ChipEvent{
			Move: &model.ChipMoveEvent{
				ID: payload.ID,
				X:  payload.X,
				Y:  payload.Y,
			},
		}, r)

		return item, nil
	}
	return nil, fmt.Errorf("no card for id: %s", payload.ID)
}

func (r *chipMutationsResolver) Remove(ctx context.Context, obj *model.ChipMutations, payload *model.CardRemovePayload) (*model.Chip, error) {
	if val, ok := r.Chip.Load(payload.ID); ok {
		_, err := r.Db.ExecContext(ctx, `DELETE FROM chips WHERE chip_id = ?`, payload.ID)
		if err != nil {
			logrus.Info(err)
			return nil, err
		}

		item := val.(*model.Chip)
		r.Chip.Delete(payload.ID)

		ChipEvent(r.ChipObservers, &model.ChipEvent{
			Remove: &model.ChipRemoveEvent{
				ID: payload.ID,
			},
		}, r)

		return item, nil
	}

	return nil, fmt.Errorf("no chip when delete for id: %s", payload.ID)
}

func (r *chipQueriesResolver) List(ctx context.Context, obj *model.ChipQueries) ([]*model.Chip, error) {
	result := make([]*model.Chip, 0)
	r.Chip.Range(
		func(k interface{}, val interface{}) bool {
			item := val.(*model.Chip)
			result = append(result, item)
			return true
		})
	return result, nil
}

func (r *contentQueriesResolver) List(ctx context.Context, obj *model.ContentQueries) ([]*model.Content, error) {
	result := make([]*model.Content, 0)
	r.Content.Range(
		func(k interface{}, val interface{}) bool {
			item := val.(*model.Content)
			result = append(result, item)
			return true
		})

	return result, nil
}

func (r *diceMutationsResolver) Set(ctx context.Context, obj *model.DiceMutations, val int) (int, error) {
	r.Dice = val

	UpdateDice(r.DiceObservers, val, r)

	return r.Dice, nil
}

func (r *diceQueriesResolver) Val(ctx context.Context, obj *model.DiceQueries) (int, error) {
	return r.Dice, nil
}

func (r *intuitionMutationsResolver) Set(ctx context.Context, obj *model.IntuitionMutations, val bool) (bool, error) {
	r.Intuition = val

	IntuitionEvent(r.IntuitionObservers, val, r)

	return r.Intuition, nil
}

func (r *intuitionQueriesResolver) Val(ctx context.Context, obj *model.IntuitionQueries) (bool, error) {
	return r.Intuition, nil
}

func (r *mutationResolver) Dice(ctx context.Context) (*model.DiceMutations, error) {
	return &model.DiceMutations{}, nil
}

func (r *mutationResolver) Card(ctx context.Context) (*model.CardMutations, error) {
	return &model.CardMutations{}, nil
}

func (r *mutationResolver) Chip(ctx context.Context) (*model.ChipMutations, error) {
	return &model.ChipMutations{}, nil
}

func (r *mutationResolver) Intuition(ctx context.Context) (*model.IntuitionMutations, error) {
	return &model.IntuitionMutations{}, nil
}

func (r *queryResolver) Dice(ctx context.Context) (*model.DiceQueries, error) {
	return &model.DiceQueries{}, nil
}

func (r *queryResolver) Card(ctx context.Context) (*model.CardQueries, error) {
	return &model.CardQueries{}, nil
}

func (r *queryResolver) Chip(ctx context.Context) (*model.ChipQueries, error) {
	return &model.ChipQueries{}, nil
}

func (r *queryResolver) Intuition(ctx context.Context) (*model.IntuitionQueries, error) {
	return &model.IntuitionQueries{}, nil
}

func (r *queryResolver) Content(ctx context.Context) (*model.ContentQueries, error) {
	return &model.ContentQueries{}, nil
}

func (r *subscriptionResolver) Dice(ctx context.Context) (<-chan int, error) {
	id := uuid.NewString()
	msgs := make(chan int)

	go func() {
		<-ctx.Done()

		r.PushMutex.Lock()
		defer r.PushMutex.Unlock()
		r.DiceObservers.Delete(id)
		close(msgs)
	}()
	r.DiceObservers.Store(id, msgs)

	return msgs, nil
}

func (r *subscriptionResolver) Card(ctx context.Context) (<-chan *model.CardEvent, error) {
	id := uuid.NewString()
	msgs := make(chan *model.CardEvent)

	go func() {
		<-ctx.Done()

		r.PushMutex.Lock()
		defer r.PushMutex.Unlock()
		r.CardObservers.Delete(id)
		close(msgs)
	}()
	r.CardObservers.Store(id, msgs)

	return msgs, nil
}

func (r *subscriptionResolver) Chip(ctx context.Context) (<-chan *model.ChipEvent, error) {
	id := uuid.NewString()
	msgs := make(chan *model.ChipEvent)

	go func() {
		<-ctx.Done()

		r.PushMutex.Lock()
		defer r.PushMutex.Unlock()
		r.ChipObservers.Delete(id)
		close(msgs)
	}()
	r.ChipObservers.Store(id, msgs)

	return msgs, nil
}

func (r *subscriptionResolver) Intuition(ctx context.Context) (<-chan bool, error) {
	id := uuid.NewString()
	msgs := make(chan bool)

	go func() {
		<-ctx.Done()

		r.PushMutex.Lock()
		defer r.PushMutex.Unlock()
		r.IntuitionObservers.Delete(id)
		close(msgs)
	}()
	r.IntuitionObservers.Store(id, msgs)

	return msgs, nil
}

func (r *subscriptionResolver) Ping(ctx context.Context) (<-chan bool, error) {
	id := uuid.NewString()
	msgs := make(chan bool)

	go func() {
		<-ctx.Done()

		r.PushMutex.Lock()
		defer r.PushMutex.Unlock()
		r.PingObservers.Delete(id)
		close(msgs)
	}()
	r.PingObservers.Store(id, msgs)

	return msgs, nil
}

// CardMutations returns generated.CardMutationsResolver implementation.
func (r *Resolver) CardMutations() generated.CardMutationsResolver { return &cardMutationsResolver{r} }

// CardQueries returns generated.CardQueriesResolver implementation.
func (r *Resolver) CardQueries() generated.CardQueriesResolver { return &cardQueriesResolver{r} }

// ChipMutations returns generated.ChipMutationsResolver implementation.
func (r *Resolver) ChipMutations() generated.ChipMutationsResolver { return &chipMutationsResolver{r} }

// ChipQueries returns generated.ChipQueriesResolver implementation.
func (r *Resolver) ChipQueries() generated.ChipQueriesResolver { return &chipQueriesResolver{r} }

// ContentQueries returns generated.ContentQueriesResolver implementation.
func (r *Resolver) ContentQueries() generated.ContentQueriesResolver {
	return &contentQueriesResolver{r}
}

// DiceMutations returns generated.DiceMutationsResolver implementation.
func (r *Resolver) DiceMutations() generated.DiceMutationsResolver { return &diceMutationsResolver{r} }

// DiceQueries returns generated.DiceQueriesResolver implementation.
func (r *Resolver) DiceQueries() generated.DiceQueriesResolver { return &diceQueriesResolver{r} }

// IntuitionMutations returns generated.IntuitionMutationsResolver implementation.
func (r *Resolver) IntuitionMutations() generated.IntuitionMutationsResolver {
	return &intuitionMutationsResolver{r}
}

// IntuitionQueries returns generated.IntuitionQueriesResolver implementation.
func (r *Resolver) IntuitionQueries() generated.IntuitionQueriesResolver {
	return &intuitionQueriesResolver{r}
}

// Mutation returns generated.MutationResolver implementation.
func (r *Resolver) Mutation() generated.MutationResolver { return &mutationResolver{r} }

// Query returns generated.QueryResolver implementation.
func (r *Resolver) Query() generated.QueryResolver { return &queryResolver{r} }

// Subscription returns generated.SubscriptionResolver implementation.
func (r *Resolver) Subscription() generated.SubscriptionResolver { return &subscriptionResolver{r} }

type cardMutationsResolver struct{ *Resolver }
type cardQueriesResolver struct{ *Resolver }
type chipMutationsResolver struct{ *Resolver }
type chipQueriesResolver struct{ *Resolver }
type contentQueriesResolver struct{ *Resolver }
type diceMutationsResolver struct{ *Resolver }
type diceQueriesResolver struct{ *Resolver }
type intuitionMutationsResolver struct{ *Resolver }
type intuitionQueriesResolver struct{ *Resolver }
type mutationResolver struct{ *Resolver }
type queryResolver struct{ *Resolver }
type subscriptionResolver struct{ *Resolver }

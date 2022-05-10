package graph

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.

import (
	"context"
	"fmt"
	"thegame/graph/generated"
	"thegame/graph/model"

	"github.com/sirupsen/logrus"
)

func (r *cardMutationsResolver) Add(ctx context.Context, obj *model.CardMutations, payload model.CardAddPayload) (*model.Card, error) {
	_, err := r.Db.ExecContext(ctx, `INSERT INTO cards(card_id, body, x, y, color) VALUES (?, ?, ?, ?, ?)`, payload.ID, payload.Text, payload.X, payload.Y, payload.Color)
	if err != nil {
		logrus.Info(err)
		return nil, err
	}

	item := &model.Card{
		ID:   payload.ID,
		Text: payload.Text,
		X:    payload.X,
		Y:    payload.Y,
		Color: payload.Color,
	}
	r.Card.Store(payload.ID, item)

	return item, nil
}

func (r *cardMutationsResolver) Move(ctx context.Context, obj *model.CardMutations, payload *model.CardMovePayload) (*model.Card, error) {
	if val, ok := r.Card.Load(payload.ID); ok {
		_, err := r.Db.ExecContext(ctx, `UPDATE cards SET x = ?, y = ? WHERE card_id = ?`, payload.X, payload.Y, payload.ID)
		if err != nil {
			logrus.Info(err)
			return nil, err
		}

		item := val.(*model.Card)
		item.X = payload.X
		item.Y = payload.Y
		return item, nil
	}
	return nil, fmt.Errorf("no card for id: %s", payload.ID)
}

func (r *cardMutationsResolver) Delete(ctx context.Context, obj *model.CardMutations, id *string) (*model.Card, error) {
	if val, ok := r.Card.Load(*id); ok {
		_, err := r.Db.ExecContext(ctx, `DELETE FROM cards WHERE card_id = ?`, id)
		if err != nil {
			logrus.Info(err)
			return nil, err
		}

		item := val.(*model.Card)
		r.Card.Delete(*id)
		return item, nil
	}

	return nil, fmt.Errorf("no card when delete for id: %s", id)
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

func (r *diceMutationsResolver) Set(ctx context.Context, obj *model.DiceMutations, val int) (int, error) {
	r.Dice = val
	return r.Dice, nil
}

func (r *diceQueriesResolver) Val(ctx context.Context, obj *model.DiceQueries) (int, error) {
	return r.Dice, nil
}

func (r *mutationResolver) Dice(ctx context.Context) (*model.DiceMutations, error) {
	return &model.DiceMutations{}, nil
}

func (r *mutationResolver) Card(ctx context.Context) (*model.CardMutations, error) {
	return &model.CardMutations{}, nil
}

func (r *queryResolver) Dice(ctx context.Context) (*model.DiceQueries, error) {
	return &model.DiceQueries{}, nil
}

func (r *queryResolver) Card(ctx context.Context) (*model.CardQueries, error) {
	return &model.CardQueries{}, nil
}

// CardMutations returns generated.CardMutationsResolver implementation.
func (r *Resolver) CardMutations() generated.CardMutationsResolver { return &cardMutationsResolver{r} }

// CardQueries returns generated.CardQueriesResolver implementation.
func (r *Resolver) CardQueries() generated.CardQueriesResolver { return &cardQueriesResolver{r} }

// DiceMutations returns generated.DiceMutationsResolver implementation.
func (r *Resolver) DiceMutations() generated.DiceMutationsResolver { return &diceMutationsResolver{r} }

// DiceQueries returns generated.DiceQueriesResolver implementation.
func (r *Resolver) DiceQueries() generated.DiceQueriesResolver { return &diceQueriesResolver{r} }

// Mutation returns generated.MutationResolver implementation.
func (r *Resolver) Mutation() generated.MutationResolver { return &mutationResolver{r} }

// Query returns generated.QueryResolver implementation.
func (r *Resolver) Query() generated.QueryResolver { return &queryResolver{r} }

type cardMutationsResolver struct{ *Resolver }
type cardQueriesResolver struct{ *Resolver }
type diceMutationsResolver struct{ *Resolver }
type diceQueriesResolver struct{ *Resolver }
type mutationResolver struct{ *Resolver }
type queryResolver struct{ *Resolver }

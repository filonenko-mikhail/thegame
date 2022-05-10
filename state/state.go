package state

import (
	"context"
	"database/sql"
	"encoding/json"
	"log"
	"sync"

	"github.com/sirupsen/logrus"
	"nhooyr.io/websocket"
	"nhooyr.io/websocket/wsjson"
)


type ClientInfo struct {
	Id string;
	Name string;
	RemoteAddr string;
}

type Game struct {
	mu        sync.RWMutex
	clients   sync.Map
	ctx       context.Context
	Db        *sql.DB
}

var (
	game            *Game
	gameInitializer sync.Once
)

func Get() *Game {
	gameInitializer.Do(func() {
		game = constructor()
	})
	return game
}

func constructor() *Game {
	return &Game{
		mu:  sync.RWMutex{},
		ctx: context.TODO(),
	}
}

func (g *Game) Add(client *websocket.Conn, remoteAddr string, clientId string) {
	newinfo := ClientInfo{
		Id: clientId,
		Name: "",
		RemoteAddr: remoteAddr,
	}
	g.clients.Store(client, newinfo)
	logrus.Printf("New client connected %v %v", remoteAddr, clientId)
}

func (g *Game) Remove(client *websocket.Conn) {
	g.clients.Delete(client)
	value, ok := g.clients.Load(client)
	if !ok {
		logrus.Warn("Event without client")
		return
	}
	
	info := value.(ClientInfo)
	event := map[string]interface{}{
		"event-type": "client_disconnected",
		"source": info.Id,
	}

	g.Broadcast(event, &info.Id)
}

func (g *Game) Broadcast(event map[string]interface{}, exceptId *string) {
	g.clients.Range(func (key interface{}, value interface{}) bool {
		conn := key.(*websocket.Conn)
		info := value.(ClientInfo)
		if exceptId != nil && info.Id == *exceptId {
			return true
		}
		err := wsjson.Write(g.ctx, conn, event)
		if err != nil {
			log.Default().Printf("error while sending to %v: %v", info.RemoteAddr, err)
		}
		return true
	})
}

func (g *Game) NewCard(ctx context.Context, card map[string]interface{}) error {
	info, err := json.Marshal(card)
	if err != nil {
		return err
	}
	_, err = g.Db.ExecContext(ctx, 
		`INSERT INTO 
			cards(card_id, info)
		VALUES (?, ?)`,
			card["card_id"], info)
	return err
}

func (g *Game) UpdateCard(ctx context.Context, card map[string]interface{}) error {
	info, err := json.Marshal(card)
	if err != nil {
		return err
	}
	_, err = g.Db.ExecContext(ctx, 
		`UPDATE cards 
		SET 
			info = ?
		WHERE card_id = ?)`,
			info, card["card_id"])
	return err
}

func (g *Game) DeleteCard(ctx context.Context, card map[string]interface{}) error {
	_, err := g.Db.ExecContext(ctx, 
		`DELETE FROM cards WHERE card_id = ?`,
			card["card_id"])
	return err
}

func (g *Game) GetCards(ctx context.Context) ([]map[string]interface{}, error) {
	rows, err := g.Db.QueryContext(ctx, `SELECT card_id, info FROM cards`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var result []map[string]interface{} = make([]map[string]interface{}, 0)
	for rows.Next() {
		var row map[string]interface{} = make(map[string]interface{}, 0);
		var card_id string;
		var info string;
		err = rows.Scan(&card_id, &info) 
		if err != nil {
			return nil, err
		}
		row["card_id"] = card_id
		err = json.Unmarshal([]byte(info), &row)
		if err != nil {
			return nil, err
		}
		result = append(result, row)
	}
	return result, nil
}

func (g *Game) HandleEvent(ctx context.Context, client *websocket.Conn, event map[string]interface{}) {
	logrus.Printf("Handle event %v", event)
	value, ok := g.clients.Load(client)
	if !ok {
		logrus.Warn("Event without client")
		return
	}
	
	info := value.(ClientInfo)
	event["source"] = info.Id
	logrus.Debugf("received event: %v", info.RemoteAddr, event)

	switch event["event-type"] {
	case "change_name":
		info.Name = event["new_name"].(string)
		g.clients.Store(client, info)
	case "mouse-move":
		g.Broadcast(event, &info.Id)
	case "get-cards":
		result, err := g.GetCards(ctx)
		if err != nil {
			logrus.Info(err)
			return
		}
		var event map[string]interface{} = make(map[string]interface{}, 0)
		event["event-type"] = "get-cards"
		event["payload"] = result
		err = wsjson.Write(ctx, client, event)
		if err != nil {
			log.Default().Printf("error while sending to %v: %v", info.RemoteAddr, err)
		}
	case "new-card":
		err := g.NewCard(ctx, event["payload"].(map[string]interface{}))
		if err != nil {	
			logrus.Info(err)
			return
		}
		g.Broadcast(event, nil)
	case "update-card":
		err := g.UpdateCard(ctx, event["payload"].(map[string]interface{}))
		if err != nil {	
			logrus.Info(err)
			return
		}
		g.Broadcast(event, nil)
	case "delete-card":
		err := g.DeleteCard(ctx, event["payload"].(map[string]interface{}))
		if err != nil {	
			logrus.Info(err)
			return
		}
		g.Broadcast(event, nil)
	}
}

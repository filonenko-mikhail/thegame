package main

import (
	"context"
	"database/sql"
	"net/http"
	"sync"
	"thegame/graph"
	"thegame/graph/generated"
	"thegame/graph/model"
	"thegame/state"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/playground"
	"github.com/go-chi/chi"
	"github.com/sirupsen/logrus"
	"nhooyr.io/websocket"
	"nhooyr.io/websocket/wsjson"

	"github.com/rs/cors"

	"github.com/spf13/cobra"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/sqlite"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

var game *state.Game

func serveWs(w http.ResponseWriter, r *http.Request) {
	c, err := websocket.Accept(w, r, &websocket.AcceptOptions{
		InsecureSkipVerify: true,
		OriginPatterns: []string{"*"},})
	if err != nil {
		logrus.Warn(err)
		return
	}
	defer c.Close(websocket.StatusInternalError, "The End")

	ctx := context.Background()

	game.Add(c, r.RemoteAddr, r.FormValue("client-id"))
	for {
		var v interface{}
		err = wsjson.Read(ctx, c, &v)
		if err != nil {
			logrus.Warn(err)
			break
		}
		logrus.Print(v)
		var request = v.(map[string]interface{})
		game.HandleEvent(ctx, c, request)
	}
	game.Remove(c)

	c.Close(websocket.StatusNormalClosure, "")
}

func serve(cmd *cobra.Command, args []string) error {
	logrus.Print("Opening database...")
	db, err := sql.Open("sqlite", "./onlinedata.sqlite")
	if err != nil {
		return err
	}
	defer func() {
		if err := db.Close(); err != nil {
			logrus.Print(err)
		}
	}()
	logrus.Print("Database opened")

	logrus.Print("Applying migrations...")
	driver, err := sqlite.WithInstance(db, &sqlite.Config{})
	if err != nil {
		return err
	}

	m, err := migrate.NewWithDatabaseInstance(
		"file://./migrations",
		"game", driver)
	if err != nil {
		return err
	}
	err = m.Up()
	if err != nil && err != migrate.ErrNoChange{
		return err
	}
	logrus.Print("Migrations applied")

	game = state.Get()
	game.Db = db;

	router := chi.NewRouter()
	router.Use(cors.New(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowCredentials: true,
		Debug:            false,
	}).Handler)

	resolver := graph.Resolver{
		Db: db,
		Dice: 1,
		Card: sync.Map{}}
	srv := handler.NewDefaultServer(generated.NewExecutableSchema(generated.Config{Resolvers: &resolver}))
			
	rows, err := db.QueryContext(context.Background(), `SELECT card_id, body, x, y, color FROM cards`)
	if err != nil {
		logrus.Info(err)
		return err
	}
	defer rows.Close()

	var (
		cardId string;
		body string;
		x float64;
		y float64;
		color sql.NullInt32;
	)
	for rows.Next() {
		err := rows.Scan(&cardId, &body, &x, &y, &color)
		if err != nil {
			logrus.Info(err)
			break
		}
		item := model.Card{
			ID: cardId,
			Text: body,
			X: x,
			Y: y,
		}
		if color.Valid {
			val := int(color.Int32)
			item.Color = &val
		}
		resolver.Card.Store(cardId, &item)
	}


	router.Handle("/playground", playground.Handler("GraphQL playground", "/query"))
	router.Handle("/query", srv)
	router.HandleFunc("/ws", serveWs)

	fs := http.FileServer(http.Dir("myapp/build/web/"))
	router.Handle("/*", fs);

	httpAddr, err := cmd.Flags().GetString("http-addr")
	if err != nil {
		return err
	}
	logrus.Printf("Listening tranformations http://%s", httpAddr)
	return http.ListenAndServe(httpAddr, router)
}  

func main() {
	defer func() {
        if r := recover(); r != nil {
            logrus.Print(r)
        }
    }()
	var rootCmd = &cobra.Command{
		Use:   "",
		Short: "",
		Long: ``,
		RunE: serve, 
	}
	rootCmd.Flags().String("http-addr", "127.0.0.1:8080", "HTTP listen interface")
	if err := rootCmd.Execute(); err != nil {
		logrus.Print(err)
	}
}

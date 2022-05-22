package main

import (
	"context"
	"database/sql"
	"net/http"
	"sync"
	"thegame/graph"
	"thegame/graph/generated"
	"thegame/graph/model"
	"time"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/handler/transport"
	"github.com/99designs/gqlgen/graphql/playground"
	"github.com/go-chi/chi"
	"github.com/gorilla/websocket"
	"github.com/rs/cors"
	"github.com/sirupsen/logrus"

	"github.com/spf13/cobra"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/sqlite"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

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

	router := chi.NewRouter()
	router.Use(cors.New(cors.Options{
		AllowedOrigins:   []string{"*", "http://localhost"},
		AllowCredentials: true,
		AllowedMethods: []string{"GET", "PATCH",
			"POST", 
			"CONNECT",
			"DELETE",
			"UPDATE",
			"PUT",
			"OPTIONS"},
		Debug:            false,
	}).Handler)

	resolver := graph.Resolver{
		Db: db,
		Dice: 1,
		Card: sync.Map{},
		Intuition: true,

		ChatMessages: []*model.Update{},
    	ChatObservers: map[string]chan []*model.Update{},
	}
	srv := handler.New(
		generated.NewExecutableSchema(generated.
			Config{Resolvers: &resolver}))

	srv.AddTransport(&transport.Websocket{
		Upgrader: websocket.Upgrader{
			CheckOrigin: func(r *http.Request) bool {
				return true
			},
			ReadBufferSize:  1024,
			WriteBufferSize: 1024,
		},
		KeepAlivePingInterval: 15 * time.Second,
	})
	srv.AddTransport(transport.Options{})
	srv.AddTransport(transport.GET{})
	srv.AddTransport(transport.POST{})
	srv.AddTransport(transport.MultipartForm{})

	rows, err := db.QueryContext(context.Background(), 
	`SELECT card_id, body, x, y, color, flipable, flip, fliptext, prio,
		sizex, sizey
	FROM cards`)
	if err != nil {
		logrus.Info(err)
		return err
	}
	defer rows.Close()

	for rows.Next() {
		item := model.Card{}

		err := rows.Scan(&item.ID, &item.Text, &item.X, &item.Y, &item.Color,
			&item.Flipable, &item.Flip, &item.Fliptext, &item.Prio,
			&item.Sizex, &item.Sizey)
		if err != nil {
			logrus.Info(err)
			break
		}
		resolver.Card.Store(item.ID, &item)
	}

	router.Handle("/playground", playground.Handler("GraphQL playground", "/query"))
	router.Handle("/query", srv)

	fs := http.FileServer(http.Dir("."))
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

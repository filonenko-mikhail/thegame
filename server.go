package main

import (
	"context"
	"database/sql"
	"log"
	"net/http"
	"runtime"
	"sync"
	"thegame/graph"
	"thegame/graph/generated"
	"thegame/graph/model"
	"time"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/handler/extension"
	"github.com/99designs/gqlgen/graphql/handler/transport"
	"github.com/99designs/gqlgen/graphql/playground"
	"github.com/doug-martin/goqu"
	"github.com/go-chi/chi"
	"github.com/gorilla/websocket"
	"github.com/sirupsen/logrus"

	"github.com/spf13/cobra"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/sqlite"
	_ "github.com/golang-migrate/migrate/v4/source/file"

	_ "net/http/pprof"
)


var requestCount = 0
func logRequest(handler http.HandlerFunc) http.HandlerFunc {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		requestCount = requestCount + 1
		logrus.Infof("%d -> %s %s %s %s\n", requestCount, r.URL.Scheme, r.RemoteAddr, r.Method, r.URL)
		handler.ServeHTTP(w, r)
		logrus.Infof("%d <- %s %s %s %s\n", requestCount, r.URL.Scheme, r.RemoteAddr, r.Method, r.URL)
	})
}

func cors(h http.HandlerFunc) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Access-Control-Allow-Origin", "*")
        w.Header().Set("Access-Control-Allow-Methods", "*")
        w.Header().Set("Access-Control-Allow-Headers", "*")
        h(w, r)
    }
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

	router := chi.NewRouter()

	resolver := graph.Resolver{
		Db: db,
		Dice: 1,

		PushMutex: sync.Mutex{},
		Card: sync.Map{},
		Intuition: true,
    	DiceObservers: sync.Map{},
		CardObservers: sync.Map{},
		ChipObservers: sync.Map{},
		IntuitionObservers: sync.Map{},
		PingObservers: sync.Map{},

		CardEventMutex: sync.Mutex{},
		CardEvents: []*model.CardEvent{},
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
	srv.Use(extension.Introspection{})

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

	ds := goqu.From("content")
	ds = ds.Select("content_id", "content_type", "title", "content")

	exec, params, err := ds.ToSql()
	if err != nil {
		logrus.Info(err)
		return err
	}

	rows, err = db.QueryContext(context.Background(), exec, params...)
	if err != nil {
		logrus.Info(err)
		return err
	}
	defer rows.Close()

	for rows.Next() {
		item := model.Content{}

		err := rows.Scan(&item.ID, &item.Type, &item.Title, &item.Description)
		if err != nil {
			logrus.Info(err)
			break
		}
		resolver.Content.Store(item.ID, &item)
	}

	router.Handle("/playground", playground.Handler("GraphQL playground", "/query"))

	handler := cors(srv.ServeHTTP)
	logging, _ := cmd.Flags().GetBool("logging")
	if logging {
		handler = logRequest(handler)
	}
	router.HandleFunc("/query", handler)

	fs := http.FileServer(http.Dir("."))
	router.Handle("/*", fs);

	httpAddr, err := cmd.Flags().GetString("http-addr")
	if err != nil {
		return err
	}

    ticker := time.NewTicker(5 * time.Second)
    ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

    go graph.PingLoop(ctx, ticker, &resolver)

	logrus.Printf("Listening tranformations http://%s", httpAddr)
	return http.ListenAndServe(httpAddr, router)
}  

func main() {
	defer func() {
        if r := recover(); r != nil {
            logrus.Print(r)
        }
    }()

	runtime.SetBlockProfileRate(1)
	go func() {
		log.Println(http.ListenAndServe("0.0.0.0:6060", nil))
	}()
	
	var rootCmd = &cobra.Command{
		Use:   "",
		Short: "",
		Long: ``,
		RunE: serve, 
	}
	rootCmd.Flags().String("http-addr", "127.0.0.1:8080", "HTTP listen interface")

	rootCmd.Flags().Bool("logging", false, "Enable logging http graphql")
	if err := rootCmd.Execute(); err != nil {
		logrus.Print(err)
	}
}

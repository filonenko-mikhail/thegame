package main

import (
	"context"
	"database/sql"
	"net/http"
	"thegame/state"

	"github.com/sirupsen/logrus"
	"nhooyr.io/websocket"
	"nhooyr.io/websocket/wsjson"

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

	mux := http.NewServeMux()

	mux.HandleFunc("/ws", serveWs)

	httpAddr, err := cmd.Flags().GetString("http-addr")
	if err != nil {
		return err
	}
	logrus.Printf("Listening tranformations http://%s", httpAddr)
	return http.ListenAndServe(httpAddr, mux)
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

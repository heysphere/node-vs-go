package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"
)

var PORT string = os.Getenv("BATTLE_PORT")

func writeJson(w http.ResponseWriter, data interface{}) {
	json, err := json.Marshal(data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write(json)
}

func middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Add("Content-Type", "application/json")
		next.ServeHTTP(w, r)
	})
}

func getNow(w http.ResponseWriter, r *http.Request) {
	writeJson(w, map[string]interface{}{
		"now": time.Now().Unix(),
	})
}

func getNow5msDelay(w http.ResponseWriter, r *http.Request) {
	time.Sleep(5 * time.Millisecond)
	writeJson(w, map[string]interface{}{
		"now": time.Now().Unix(),
	})
}

// our main function
func main() {
	router := mux.NewRouter()
	router.Use(middleware)
	router.HandleFunc("/now", getNow).Methods("GET")
	router.HandleFunc("/now-5ms-delay", getNow5msDelay).Methods("GET")

	log.Printf("[Go] :: listening on %s and ready 👌", PORT)
	http.ListenAndServe(fmt.Sprintf(":%s", PORT), router)
}

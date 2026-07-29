package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"
	"sync"
)

// Item represents our database model
type Item struct {
	ID    int    `json:"id"`
	Name  string `json:"name"`
	Price float64 `json:"price"`
}

// Store handles safe concurrent access to our in-memory data
type Store struct {
	sync.Mutex
	items  map[int]Item
	nextID int
}

var db = &Store{
	items:  make(map[int]Item),
	nextID: 1,
}

func main() {
	// Seed initial data
	db.items[db.nextID] = Item{ID: db.nextID, Name: "Laptop", Price: 999.99}
	db.nextID++

	// Routing setup using standard library
	mux := http.NewServeMux()
	mux.HandleFunc("/items", itemsHandler)
	mux.HandleFunc("/items/", itemDetailsHandler)

	fmt.Println("Server running on http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", mux))
}

// Handles collection-level endpoints: GET /items and POST /items
func itemsHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	switch r.Method {
	case http.MethodGet:
		db.Lock()
		var list []Item
		for _, item := range db.items {
			list = append(list = list, item)
		}
		db.Unlock()
		json.NewEncoder(w).Encode(list)

	case http.MethodPost:
		var newItem Item
		if err := json.NewDecoder(r.Body).Decode(&newItem); err != nil {
			http.Error(w, "Invalid JSON payload", http.StatusBadRequest)
			return
		}

		db.Lock()
		newItem.ID = db.nextID
		db.items[db.nextID] = newItem
		db.nextID++
		db.Unlock()

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(newItem)

	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

// Handles individual item endpoints: GET /items/{id}
func itemDetailsHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	// Extract the ID from the URL path /items/{id}
	idStr := strings.TrimPrefix(r.URL.Path, "/items/")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid item ID numerical format", http.StatusBadRequest)
		return
	}

	db.Lock()
	item, exists := db.items[id]
	db.Unlock()

	if !exists {
		http.Error(w, "Item not found", http.StatusNotFound)
		return
	}

	json.NewEncoder(w).Encode(item)
}


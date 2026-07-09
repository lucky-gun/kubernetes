package main

import (
	"fmt"
	"net/http"
	"strings"
)

func main() {

	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/profile", profileHandler)
	http.HandleFunc("/admin", adminHandler)
	http.HandleFunc("/read", readHandler)

	fmt.Println("server started :8080")
	http.ListenAndServe(":8080", nil)
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "public page")
}

func profileHandler(w http.ResponseWriter, r *http.Request) {

	user := r.Header.Get("X-Forwarded-User")

	if user == "" {
		http.Error(w, "unauthorized", 401)
		return
	}

	fmt.Fprintf(w, "hello %s", user)
}

func adminHandler(w http.ResponseWriter, r *http.Request) {

	groups := r.Header.Get("X-Forwarded-Groups")

	if !strings.Contains(groups, "admin") {
		http.Error(w, "forbidden", 403)
		return
	}

	fmt.Fprintf(w, "admin page")
}

func readHandler(w http.ResponseWriter, r *http.Request) {

	groups := r.Header.Get("X-Forwarded-Groups")

	if strings.Contains(groups, "readonly") ||
		strings.Contains(groups, "admin") {

		fmt.Fprintf(w, "readonly page")
		return
	}

	http.Error(w, "forbidden", 403)
}

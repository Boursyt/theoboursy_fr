package main

import (
	"embed"
	"io/fs"
	"log"
	"net/http"
	"os"
	"strings"
)

// Site content is copied next to this file at build time (see Dockerfile),
// so the same server binary serves any of the static sites.
//
//go:embed index.html 404.html legal.html assets
var content embed.FS

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	page404, err := content.ReadFile("404.html")
	if err != nil {
		log.Fatalf("read 404.html: %v", err)
	}

	fileServer := http.FileServer(http.FS(content))

	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		name := strings.TrimPrefix(r.URL.Path, "/")
		if name == "" {
			name = "index.html"
		}

		// Unknown path -> serve the custom 404 page.
		if _, err := fs.Stat(content, name); err != nil {
			w.Header().Set("Content-Type", "text/html; charset=utf-8")
			w.WriteHeader(http.StatusNotFound)
			_, _ = w.Write(page404)
			return
		}

		fileServer.ServeHTTP(w, r)
	})

	log.Printf("serving on :%s", port)
	if err := http.ListenAndServe(":"+port, mux); err != nil {
		log.Fatal(err)
	}
}

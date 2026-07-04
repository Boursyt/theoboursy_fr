# Shared static server. Build context = repo root.
# Pick the site to serve at build time:
#   docker build --build-arg SITE=www       -t theoboursy-www .
#   docker build --build-arg SITE=img2ascii -t theoboursy-ascii .

# --- build: inject the chosen site next to the server, embed it, compile static ---
FROM golang:1.22-alpine AS build
ARG SITE
WORKDIR /src
COPY server/go.mod server/main.go ./
# Shared assets (common stylesheet + favicon) come first, then the site's own
# files (index.html, 404.html, and any site-specific assets like an image) are
# layered on top — a site can add or override a shared file by name.
COPY assets ./assets
COPY ${SITE}/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /server .

# --- runtime: single binary on scratch, ~0 cold start ---
FROM scratch
COPY --from=build /server /server
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/server"]
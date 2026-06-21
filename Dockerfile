# Shared static server. Build context = repo root.
# Pick the site to serve at build time:
#   docker build --build-arg SITE=www       -t theoboursy-www .
#   docker build --build-arg SITE=img2ascii -t theoboursy-ascii .

# --- build: inject the chosen site next to the server, embed it, compile static ---
FROM golang:1.22-alpine AS build
ARG SITE
WORKDIR /src
COPY server/go.mod server/main.go ./
COPY ${SITE}/index.html ${SITE}/404.html ./
COPY ${SITE}/assets ./assets
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /server .

# --- runtime: single binary on scratch, ~0 cold start ---
FROM scratch
COPY --from=build /server /server
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/server"]
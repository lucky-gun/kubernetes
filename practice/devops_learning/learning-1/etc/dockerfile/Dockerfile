FROM golang:1.24 AS builder

WORKDIR .

COPY . .

RUN go build -o server app.go

FROM debian:stable-slim

COPY --from=builder /app/server /server

EXPOSE 8080

CMD ["/server"]

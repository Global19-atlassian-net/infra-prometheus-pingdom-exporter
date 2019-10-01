ARG GOVERSION=1.12
FROM golang:${GOVERSION} AS build

COPY . /build/go/src/github.com/giantswarm/prometheus-pingdom-exporter
WORKDIR /build/go/src/github.com/giantswarm/prometheus-pingdom-exporter

ARG VERSION=0.1.1
ARG COMMIT
ARG GOOS=linux
ARG GOARCH=amd64
ENV GOPATH=/build/go

RUN go get && go build -a \
	-tags netgo \
	-ldflags \
	"-X github.com/giantswarm/prometheus-pingdom-exporter/cmd.version=${VERSION} \
	-X github.com/giantswarm/prometheus-pingdom-exporter/cmd.goVersion=${GOVERSION} \
	-X github.com/giantswarm/prometheus-pingdom-exporter/cmd.gitCommit=${COMMIT} \
	-X github.com/giantswarm/prometheus-pingdom-exporter/cmd.osArch=${GOOS}/${GOARCH} \
	-w" \
	-o prometheus-pingdom-exporter


FROM alpine:3.8
MAINTAINER Joseph Salisbury <joseph@giantswarm.io>

COPY --from=build /build/go/src/github.com/giantswarm/prometheus-pingdom-exporter/prometheus-pingdom-exporter /prometheus-pingdom-exporter

RUN apk update && apk add ca-certificates

EXPOSE 8000

ENTRYPOINT ["/prometheus-pingdom-exporter"]

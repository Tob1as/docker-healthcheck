# docker build --no-cache --progress=plain -t tobi312/tools:healthcheck -f Dockerfile .
ARG GO_VERSION=1.23.4
FROM golang:${GO_VERSION}-alpine AS builder

SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]

ENV GOPATH=/go
ENV CGO_ENABLED=0

WORKDIR /go/src/healthcheck

# copy files to workdir
COPY . .

#RUN \
#    #set -eux ; \
#    ls -lah ; \
#    rm go.mod go.sum ; \
#    go mod init github.com/Tob1as/docker-healthcheck ; \
#    go mod tidy

RUN \
    #set -eux ; \
    #go mod download ; \
    go build -o ${GOPATH}/bin/healthcheck . ; \
    ${GOPATH}/bin/healthcheck --help


# hadolint ignore=DL3006,DL3007
FROM scratch AS production

ARG VCS_REF
ARG BUILD_DATE
ARG VERSION=$VCS_REF

LABEL org.opencontainers.image.title="Healthcheck" \
      org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
      #org.opencontainers.image.vendor="" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.description="Simple Healthcheck for Container Images with Webserver written in GO!" \
      org.opencontainers.image.documentation="https://github.com/Tob1as/docker-healthcheck" \
      org.opencontainers.image.base.name="scratch" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.url="https://hub.docker.com/r/tobi312/tools" \
      org.opencontainers.image.source="https://github.com/Tob1as/docker-healthcheck"

# HEALTHCHECK Settings
# use full URL:
#ENV HEALTHCHECK_URL="http://localhost:8080/"
# or use one or more of:
#ENV HEALTHCHECK_PROTOCOL="http" \
#    HEALTHCHECK_HOST="localhost" \
#    HEALTHCHECK_PORT="8080" \
#    HEALTHCHECK_PATH="/"
# SSL verify
#ENV HEALTHCHECK_SKIP_TLS_VERIFY="false"  # use false/true or 0/1

COPY --from=builder /go/bin/healthcheck /usr/local/bin/healthcheck

# user: nobody
USER 65534

ENTRYPOINT ["healthcheck"]
#CMD ["--help"]

# healthcheck without shell: https://stackoverflow.com/a/77075724  (check with: docker inspect --format='{{json .State.Health}}' <container-id>)
#HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["/usr/local/bin/healthcheck"]
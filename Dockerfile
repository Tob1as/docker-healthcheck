# docker build --no-cache --progress=plain -t tobi312/tools:healthcheck -f Dockerfile .

# hadolint ignore=DL3006
FROM golang:latest AS builder

ENV CGO_ENABLED=0

WORKDIR /go/app/

COPY main.go /go/app/

RUN \
    set -eux ; \
    go mod init healthcheck ; \
    go mod tidy ; \
    go build -o healthcheck . ; \
    echo "Build done !"



# hadolint ignore=DL3006
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

COPY --from=builder /go/app/healthcheck /usr/local/bin/healthcheck

ENTRYPOINT ["healthcheck"]
#CMD ["--help"]

# healthcheck without shell: https://stackoverflow.com/a/77075724  (check with: docker inspect --format='{{json .State.Health}}' <container-id>)
#HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["/usr/local/bin/healthcheck"]
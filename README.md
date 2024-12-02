# docker-healthcheck
Simple Healthcheck for Container Images with Webserver written in GO!


### Example usage

... to use in your Dockerfile.

```dockerfile
#FROM alpine:latest
FROM scratch

# HEALTHCHECK Settings
# use full URL:
ENV HEALTHCHECK_URL="http://localhost:8080/"
# or use one or more of:
#ENV HEALTHCHECK_PROTOCOL="http" \
#    HEALTHCHECK_HOST="localhost" \
#    HEALTHCHECK_PORT="8080" \
#    HEALTHCHECK_PATH="/"
# SSL verify
#ENV HEALTHCHECK_SKIP_TLS_VERIFY="false"  # use false/true or 0/1

# copy your (webserver-)app
COPY --from=builder --chown=1000:100 /go/app/myapp /usr/local/bin/myapp

# copy HEALTHCHECK
COPY --from=docker.io/tobi312/tools:healthcheck --chown=1000:100 /usr/local/bin/healthcheck /usr/local/bin/healthcheck

USER 1000

EXPOSE 8080/tcp
ENTRYPOINT ["myapp"]
#CMD [""]

HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["/usr/local/bin/healthcheck"]
```

for more examples see Dockerfiles in [https://github.com/Tob1as/docker-build-example](https://github.com/Tob1as/docker-build-example).  


When your container is running check (for logs) with:
```sh
docker inspect --format='{{json .State.Health}}' <container-id>
# or
docker inspect --format='{{json .State.Health}}' <container-id> | jq
```

### This Image on
* [DockerHub](https://hub.docker.com/r/tobi312/tools)
* [GitHub](https://github.com/Tob1as/docker-healthcheck)
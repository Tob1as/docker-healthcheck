# docker-healthcheck
Simple Healthcheck for Container Images with Webserver written in GO!

### Why Use This Healthcheck Tool?

This healthcheck tool provides a lightweight and secure alternative to using traditional tools like curl or wget for monitoring containerized web servers. By being a standalone Go binary, it reduces the need for additional Linux packages, minimizing the attack surface and potential vulnerabilities (CVE) in the container. Unlike other utilities, it avoids the risk of executing unwanted external downloads within the container, ensuring a more controlled and predictable runtime environment.

### Example usage

... to use in your Dockerfile.  

More examples also in: [https://github.com/Tob1as/docker-build-example](https://github.com/Tob1as/docker-build-example)   

#### Example 1

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

#### Example 2

```dockerfile
FROM nginx:latest

# HEALTHCHECK
ENV HEALTHCHECK_PORT="80"
COPY --from=docker.io/tobi312/tools:healthcheck /usr/local/bin/healthcheck /usr/local/bin/healthcheck
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["healthcheck"]
```

### Healthcheck Logs

When your container is running check (for logs) with:
```sh
docker inspect --format='{{json .State.Health}}' <container-id>
# or (requirements packages: jq)
docker inspect --format='{{json .State.Health}}' <container-id> | jq
```

### This Image on
* [DockerHub](https://hub.docker.com/r/tobi312/tools)
* [GitHub](https://github.com/Tob1as/docker-healthcheck)
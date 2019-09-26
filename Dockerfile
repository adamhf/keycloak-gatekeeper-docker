FROM alpine:3.10 as certs
RUN apk --no-cache add ca-certificates=20190108-r0 && rm -f /var/cache/apk/*

FROM golang:1.13-alpine AS builder
RUN mkdir /builder
WORKDIR /builder/keycloak-gatekeeper
RUN apk add --no-cache \
    git=2.22.0-r0 \
    make=4.2.1-r2 \
    && rm -f /var/cache/apk/* \
    && git clone https://github.com/keycloak/keycloak-gatekeeper.git /builder/keycloak-gatekeeper\
    && make static

FROM scratch
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /builder/keycloak-gatekeeper/bin/keycloak-gatekeeper /keycloak-gatekeeper
ENTRYPOINT [ "/keycloak-gatekeeper" ]
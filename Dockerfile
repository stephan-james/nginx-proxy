FROM nginx:alpine

LABEL name="nginx-proxy"
LABEL url="https://github.com/stephan-james/nginx-proxy"
LABEL maintainer="https://github.com/stephan-james"

RUN apk update; \
    apk upgrade; \
    apk add bash; \
    apk add openssl; \
    openssl req \
        -x509 \
        -out /etc/ssl/certs/certificate.crt \
        -keyout /etc/ssl/private/certificate.key \
        -newkey rsa:2048 \
        -nodes \
        -days 36500 \
        -sha256 \
        -subj "/CN=localhost" \
        -extensions EXT \
        -config <(printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")

COPY startup.sh /startup.sh
RUN chmod aug+x /startup.sh

CMD ["/startup.sh"]

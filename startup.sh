#!/usr/bin/env bash

USE_SSL=${USE_SSL:-false}
USE_FORWARD=${USE_FORWARD:-false}
SERVER_NAME=${SERVER_NAME:-servername.default}

log() {
  echo "$(date -Iseconds) [INFO] $1"
}

write() {
  echo "$1" >> /etc/nginx/conf.d/default.conf
}

httpServer() {
  write "
    listen 80 default_server;
    server_name              $SERVER_NAME;
    server_name_in_redirect  off;
    access_log               /var/log/nginx/access.log;
    error_log                /var/log/nginx/error.log debug;
  "
}

httpsServer() {
 write "
   listen 443 ssl;
   ssl                  on;
   ssl_certificate      /etc/ssl/certs/certificate.crt;
   ssl_certificate_key  /etc/ssl/private/certificate.key;
 "
}

forward() {
  write "
    proxy_set_header X-Real-IP        \$remote_addr;
    proxy_set_header Host             \$host;
    proxy_set_header X-Forwarded-For  \$proxy_add_x_forwarded_for;
  "
}

location() {
  from=$1
  to=$2
  log "Mapping: $from --> $to"

  write "
    location $from {
      add_header 'X-NGINX-Proxy'                 '1.0.0' always;
      add_header 'Access-Control-Allow-Origin'   '*' always;
      add_header 'Access-Control-Max-Age'        '3600' always;
      add_header 'Access-Control-Allow-Methods'  'GET, POST, PUT, DELETE, OPTIONS' always;
      add_header 'Access-Control-Allow-Headers'  '*' always;
      if (\$request_method = OPTIONS ) {
          return 200;
      }
  "

  if $USE_FORWARD ; then
      forward
  fi

  write "
      proxy_pass $to;
      proxy_pass_request_headers on;
    }
  "
}

locations() {
  IFS=" " read -r -a mappings <<< "$MAPPINGS"
  i=0
  while ((i < ${#mappings[@]})); do
      from=${mappings[i++]}
      to=${mappings[i++]}
      location "$from" "$to"
  done
}

createConfigurationFile() {
  log "USE_SSL     = $USE_SSL"
  log "USE_FORWARD = $USE_FORWARD"
  log "SERVER_NAME = $SERVER_NAME"

  write "server {"
  httpServer
  if $USE_SSL ; then
      httpsServer
  fi
  locations
  write "}"
}

runNginx() {
  nginx -g "daemon off;"
}

main() {
  createConfigurationFile
  runNginx
}

main

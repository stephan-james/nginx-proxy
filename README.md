# nginx-proxy

### Docker image for using nginx as (CORS) proxy.

The image can be found on dockerhub: https://hub.docker.com/repository/docker/heidebergen/nginx-proxy.

Use the following environment variables to customize the container according to your needs:

| Name             | Description                                                                                                                                                                                                                                                                             | Default value       |
|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| `MAPPINGS`       | One to multiple mappings from a relative `path` to a `target` url (concatenated by spaces), e.g. if you want to map http://127.0.0.1/my/new/path/ to http://www.catsanddogs.cad/unlimited/ use `/my/new/path/ http://www.catsanddogs.cad/unlimited/`. Ending slashes are required.      |                     |
| `USE_SSL`        | If you want to use ssl set it to `true`. The image is using a predefined self signed certificate. To overwrite this certificate with your own certificate map the private key to __/etc/ssl/private/certificate.key__ and the certificate itself to __/etc/ssl/certs/certificate.crt__. | `false`               | 
| `USE_FORWARD`    | If you want to use X-Forwarding headers (i.e. X-Real-IP, Host and X-Forwarded-For) set it to `true`.                                                                                                                                                                                    | `false`               |
| `SERVER_NAME`    | Name of the server mginx should use.                                                                                                                                                                                                                                                    | `servername.default` |

## Example

Run a container with the following arguments:

```
docker run \
    -p 8080:80 \
    -p 8443:443 \
    -e MAPPINGS=/api/cats/ http://cats-server.tld/deeper/ /api/dogs/ https://dogs-server/ \
    -e SERVER_NAME=my.server.tld \
    -e USE_FORWARD=true \
    -e USE_SSL=true \
    heidebergen/nginx-proxy
```

You should see an output that looks something like this:

```
2022-11-26T15:52:06+00:00 [INFO] USE_SSL     = true
2022-11-26T15:52:06+00:00 [INFO] USE_FORWARD = false
2022-11-26T15:52:06+00:00 [INFO] SERVER_NAME = my.server.tld
2022-11-26T15:52:06+00:00 [INFO] Mapping: /api/cats/ --> http://cats-server.tld/deeper/
2022-11-26T15:52:06+00:00 [INFO] Mapping: /api/dogs/ --> https://dogs-server/
...
```

Now you can access the given target urls indirectly by your local nginx server:

- http://127.0.0.1:8080/api/cats/...
- https://127.0.0.1:8443/api/dogs/...

Inspect the returned headers and you'll find the follwing:

```
:
Access-Control-Allow-Origin: *
Access-Control-Max-Age: 3600
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: *
:
```
Now the browser should stop complaining about CORS errors. :-)

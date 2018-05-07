#!/bin/sh

docker build -t tenant_api .
docker rm -f tenant_api
docker run -it -p 8989:80 --name tenant_api tenant_api

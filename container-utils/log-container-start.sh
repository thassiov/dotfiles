#!/bin/bash

docker run --rm --detach \
--name logs-server \
--hostname logs \
-v /var/run/docker.sock:/var/run/docker.sock \
-p 8080:8080 \
amir20/dozzle

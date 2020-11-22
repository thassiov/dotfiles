#!/bin/bash

docker run --detach --rm \
--name dns-server \
--hostname dns \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /etc/resolv.conf:/etc/resolv.conf \
defreitas/dns-proxy-server

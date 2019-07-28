#!/bin/bash

FROM_DIR=$(dirname "$(readlink -f "$BASH_SOURCE")")
TO_DIR=`pwd`;

copydockerfiles () {
    echo "Copying files..."
    `cp $FROM_DIR/Dockerfile $TO_DIR/Dockerfile`
    `cp $FROM_DIR/docker-compose.yml $TO_DIR/docker-compose.yml`
    echo "Files copied!"
}

copydockerfiles

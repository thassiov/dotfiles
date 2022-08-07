#!/bin/bash
DIRECTORY=/tmp/apps-source-storage

inotifywait -m $DIRECTORY  -e create -e moved_to -e delete |
    while read dir action file; do
        echo "The file '$file' appeared in directory '$dir' via '$action'"
        if [ $action != 'DELETE' ]; then
          sha1sum $DIRECTORY/$file
        fi
    done

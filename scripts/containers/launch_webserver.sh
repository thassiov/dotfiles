#!/bin/bash

docker run -dit -p 8080:80 -v "$PWD":/usr/local/apache2/htdocs/ httpd 
echo 'running at localhost:8080'

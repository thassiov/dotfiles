#!/bin/bash

dnsServer="dns-server"
logsServer="logs-server"

function followLink() {
  readlink -e $1
}

function getDirname() {
  dirname $1
}

here=$(getDirname $(followLink $0 ) )

function startSupportContainers() {
  echo "Starting dns and logs servers"
  docker-compose -f $here/docker-compose.yml up --detach --build
  echo "dns and logs servers started"
  echo "You can access container logs by going to http://logs:8080"
}

function stopSupportContainers() {
  echo "Stopping dns and logs servers"
  docker-compose -f $here/docker-compose.yml stop
  echo "dns and logs servers stopped"
}

function displayHelpMessage() {
  cat <<- _EOF_
  Support containers (dns server and log server)

  usage:
  --start   Starts support containers
  --stop    Stops support containers
_EOF_
}

if [[ $1 == "--start" ]]; then
  startSupportContainers
elif [[ $1 == "--stop" ]]; then
  stopSupportContainers
else
  displayHelpMessage
fi

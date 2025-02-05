#!/bin/sh

#remove all containers:
docker rm -f $(docker ps -aq)

#remove unused images:
docker rmi -f $(docker images --no-trunc | grep '<none>' | awk '{ print $3 }')

#remove unused volumes:
docker volume rm $(docker volume ls -qf dangling=true)

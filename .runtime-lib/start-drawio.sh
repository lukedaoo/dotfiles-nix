#!/bin/bash
IMAGE_NAME="jgraph/drawio"  
CONTAINER_NAME="drawio"  
PORT_MAPPING=5001:8080

start-docker-app.sh $IMAGE_NAME $CONTAINER_NAME $PORT_MAPPING

#!/bin/bash
IMAGE_NAME="excalidraw/excalidraw"  
CONTAINER_NAME="excalidraw"  
PORT_MAPPING=5000:80

start-docker-app.sh $IMAGE_NAME $CONTAINER_NAME $PORT_MAPPING

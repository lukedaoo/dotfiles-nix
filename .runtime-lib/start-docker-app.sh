#!/bin/bash
IMAGE_NAME=$1
CONTAINER_NAME=$2
PORT_MAPPING=$3

# Check if Docker is running
if ! systemctl is-active --quiet docker; then
    echo "Docker is not running. Attempting to start it..."
    sudo systemctl start docker
    if systemctl is-active --quiet docker; then
        echo "Docker has been successfully started."
    else
        echo "Failed to start Docker. Please check the service manually."
        exit 1
    fi
fi


# Check if the image is pulled
if ! docker images | grep -q "$IMAGE_NAME"; then
    echo "Docker image '$IMAGE_NAME' is not available. Pulling the image..."
    if docker pull "$IMAGE_NAME"; then
        echo "Image '$IMAGE_NAME' successfully pulled."
    else
        echo "Failed to pull image '$IMAGE_NAME'. Please check your network or image name."
        exit 1
    fi
fi

# Check if the container is already running
if docker ps --filter "name=$CONTAINER_NAME" --format "{{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
    echo "Container '$CONTAINER_NAME' is already running."
else
    echo "Running a new container with the image '$IMAGE_NAME'..."
    # Run the container, with or without port mapping
    if [ -n "$PORT_MAPPING" ]; then
        if docker run --rm -dit --name "$CONTAINER_NAME" -p "$PORT_MAPPING" "$IMAGE_NAME" >/dev/null; then
            echo "Container '$CONTAINER_NAME' started successfully with port mapping: $PORT_MAPPING."
        else
            echo "Failed to start container '$CONTAINER_NAME' with port mapping."
            exit 1
        fi
    else
        if docker run --rm -dit --name "$CONTAINER_NAME" "$IMAGE_NAME" >/dev/null; then
            echo "Container '$CONTAINER_NAME' started successfully without port mapping."
        else
            echo "Failed to start container '$CONTAINER_NAME' without port mapping."
            exit 1
        fi
    fi
fi


#!/bin/bash

dockerfilePath=".devcontainer/Dockerfile"
imageName="python-flask-application"
Port="8443"
# Check if the Docker image already exists
imageExists=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "$imageName" && echo true || echo false)

if [ "$imageExists" == true ]; then
    echo "Docker image '$imageName' found."
else
    echo "Docker image '$imageName' not found. Building Docker image..."
    docker build -t "$imageName" -f "$dockerfilePath" .
fi

containerName="python-flask-code-server"
containerVolume="$(pwd):$(pwd)"

# Check if the container is already running
containerStatus=$(docker ps -a --filter "name=$containerName" --format "{{.Status}}")
if [[ $containerStatus == *"Up"* ]]; then
    echo "Container '$containerName' is already running."
else
    # Start the container if it's not running
    containerExists=$(docker ps -a --filter "name=$containerName" --format "{{.Names}}")
    if [[ $containerExists == *"$containerName"* ]]; then
        docker start "$containerName"
        echo "Container '$containerName' started."
    else
        # Create and start the container with the mounted volume
        docker run --name "$containerName" -d -v "$(pwd):/config/workspace"  -p "$($Port):8443" -e PUID=1000 -e GUID=1000 -e SUDO_PASSWORD=abc "$imageName"
        echo "Container '$containerName' created and started with volume mount."
    fi

fi

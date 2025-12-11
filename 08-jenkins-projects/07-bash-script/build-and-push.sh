#!/bin/bash
set -e

IMAGE_NAME=${1:-"app"}
TAG=${2:-"latest"}
DOCKERFILE=${3:-"Dockerfile"}
REGISTRY=${DOCKER_REGISTRY:-""}

if [ -n "$REGISTRY" ]; then
    FULL_IMAGE="$REGISTRY/$IMAGE_NAME:$TAG"
else
    FULL_IMAGE="$IMAGE_NAME:$TAG"
fi

echo "Building image: $FULL_IMAGE"
docker build -t "$FULL_IMAGE" -f "$DOCKERFILE" .

if command -v trivy &> /dev/null; then
    echo "Scanning image for vulnerabilities..."
    trivy image --exit-code 1 --severity HIGH,CRITICAL "$FULL_IMAGE" || echo "Vulnerabilities found but continuing..."
fi

echo "Pushing image to registry..."
docker push "$FULL_IMAGE"

if [ "$TAG" != "latest" ]; then
    if [ -n "$REGISTRY" ]; then
        LATEST_IMAGE="$REGISTRY/$IMAGE_NAME:latest"
    else
        LATEST_IMAGE="$IMAGE_NAME:latest"
    fi
    docker tag "$FULL_IMAGE" "$LATEST_IMAGE"
    docker push "$LATEST_IMAGE"
fi

echo "Build and push completed: $FULL_IMAGE"
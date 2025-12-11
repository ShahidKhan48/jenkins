#!/bin/bash

# Build and Push Docker Images Script
# Usage: ./build-and-push-images.sh <image-name> <tag> <dockerfile-path>

set -e

# Variables
IMAGE_NAME=${1:-"myapp"}
TAG=${2:-"latest"}
DOCKERFILE_PATH=${3:-"Dockerfile"}
REGISTRY=${DOCKER_REGISTRY:-""}
NAMESPACE=${DOCKER_NAMESPACE:-""}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate inputs
if [ ! -f "$DOCKERFILE_PATH" ]; then
    log_error "Dockerfile not found at: $DOCKERFILE_PATH"
    exit 1
fi

# Build image
if [ -n "$REGISTRY" ] && [ -n "$NAMESPACE" ]; then
    FULL_IMAGE="$REGISTRY/$NAMESPACE/$IMAGE_NAME:$TAG"
else
    FULL_IMAGE="$IMAGE_NAME:$TAG"
fi

log_info "Building Docker image: $FULL_IMAGE"
docker build -t "$FULL_IMAGE" -f "$DOCKERFILE_PATH" .

# Tag as latest if not already
if [ "$TAG" != "latest" ]; then
    log_info "Tagging as latest"
    if [ -n "$REGISTRY" ] && [ -n "$NAMESPACE" ]; then
        LATEST_IMAGE="$REGISTRY/$NAMESPACE/$IMAGE_NAME:latest"
    else
        LATEST_IMAGE="$IMAGE_NAME:latest"
    fi
    docker tag "$FULL_IMAGE" "$LATEST_IMAGE"
fi

# Security scan (if trivy is available)
if command -v trivy &> /dev/null; then
    log_info "Running security scan"
    trivy image --exit-code 1 --severity HIGH,CRITICAL "$FULL_IMAGE" || {
        log_warn "Security vulnerabilities found, but continuing..."
    }
fi

# Push image
log_info "Pushing image to registry"
docker push "$FULL_IMAGE"

if [ "$TAG" != "latest" ]; then
    docker push "$LATEST_IMAGE"
fi

# Cleanup local images (optional)
if [ "${CLEANUP_LOCAL:-false}" = "true" ]; then
    log_info "Cleaning up local images"
    docker rmi "$FULL_IMAGE" || true
    if [ "$TAG" != "latest" ]; then
        docker rmi "$LATEST_IMAGE" || true
    fi
fi

log_info "Build and push completed successfully!"
echo "Image: $FULL_IMAGE"
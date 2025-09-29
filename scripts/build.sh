#!/bin/bash
# Master build script for jon-babylon Docker image

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
IMAGE_NAME="jon-babylon"
REGISTRY="ghcr.io/lpportorino"
VERSION=$(date +%Y.%m.%d)

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    PLATFORM="linux/amd64"
    DOCKERFILE="docker/Dockerfile"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    PLATFORM="linux/arm64"
    DOCKERFILE="docker/Dockerfile"
else
    echo -e "${RED}Unsupported architecture: $ARCH${NC}"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Jon-Babylon Docker Build Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Image: $IMAGE_NAME"
echo "Version: $VERSION"
echo "Platform: $PLATFORM"
echo "Dockerfile: $DOCKERFILE"
echo ""

# Parse arguments
BUILD_PUSH=false
BUILD_MULTIARCH=false
BUILD_LOCAL=false
NO_CACHE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --push)
            BUILD_PUSH=true
            shift
            ;;
        --multiarch)
            BUILD_MULTIARCH=true
            shift
            ;;
        --local)
            BUILD_LOCAL=true
            shift
            ;;
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --local       Build for local architecture only"
            echo "  --multiarch   Build for multiple architectures (requires buildx)"
            echo "  --push        Push to registry after build"
            echo "  --no-cache    Build without using cache"
            echo "  --help        Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Build command construction
BUILD_CMD="docker"
BUILD_ARGS=""

if [ "$NO_CACHE" = true ]; then
    BUILD_ARGS="$BUILD_ARGS --no-cache"
fi

# Function to build image
build_image() {
    local platform=$1
    local tag=$2

    echo -e "${YELLOW}Building for $platform...${NC}"

    if [ "$BUILD_MULTIARCH" = true ]; then
        docker buildx build \
            --platform $platform \
            --tag $tag \
            $BUILD_ARGS \
            --file $DOCKERFILE \
            .
    else
        docker build \
            --tag $tag \
            $BUILD_ARGS \
            --file $DOCKERFILE \
            .
    fi
}

# Main build process
if [ "$BUILD_MULTIARCH" = true ]; then
    echo -e "${YELLOW}Setting up Docker buildx...${NC}"

    # Check if buildx is available
    if ! docker buildx version &> /dev/null; then
        echo -e "${RED}Docker buildx not found. Please install buildx plugin.${NC}"
        exit 1
    fi

    # Create or use existing builder
    BUILDER_NAME="jon-babylon-builder"
    if ! docker buildx ls | grep -q $BUILDER_NAME; then
        docker buildx create --name $BUILDER_NAME --use
    else
        docker buildx use $BUILDER_NAME
    fi

    # Build for multiple platforms
    PLATFORMS="linux/amd64,linux/arm64"
    TAGS="--tag $REGISTRY/$IMAGE_NAME:$VERSION --tag $REGISTRY/$IMAGE_NAME:latest"

    if [ "$BUILD_PUSH" = true ]; then
        echo -e "${YELLOW}Building and pushing multi-architecture image...${NC}"
        docker buildx build \
            --platform $PLATFORMS \
            $TAGS \
            $BUILD_ARGS \
            --file $DOCKERFILE \
            --push \
            .
    else
        echo -e "${YELLOW}Building multi-architecture image (local only)...${NC}"
        docker buildx build \
            --platform $PLATFORMS \
            $TAGS \
            $BUILD_ARGS \
            --file $DOCKERFILE \
            --load \
            .
    fi
else
    # Single architecture build
    TAG="$IMAGE_NAME:$VERSION"

    echo -e "${YELLOW}Building image...${NC}"
    build_image $PLATFORM $TAG

    # Tag as latest
    docker tag $TAG $IMAGE_NAME:latest

    if [ "$BUILD_PUSH" = true ]; then
        echo -e "${YELLOW}Pushing to registry...${NC}"
        docker tag $TAG $REGISTRY/$TAG
        docker tag $IMAGE_NAME:latest $REGISTRY/$IMAGE_NAME:latest
        docker push $REGISTRY/$TAG
        docker push $REGISTRY/$IMAGE_NAME:latest
    fi
fi

echo ""
echo -e "${GREEN}✓ Build completed successfully!${NC}"
echo ""

# Show image details
echo -e "${BLUE}Image Details:${NC}"
docker images | grep $IMAGE_NAME | head -n 2

echo ""
echo -e "${BLUE}To run the image:${NC}"
echo "  docker run -it --rm -v \$(pwd):/workspace $IMAGE_NAME:latest"

echo ""
echo -e "${BLUE}To test the image:${NC}"
echo "  ./scripts/test.sh"
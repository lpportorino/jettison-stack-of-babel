#!/bin/bash
# Generic stage testing script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get stage number and name from arguments
STAGE_NUM="${1:-00}"
STAGE_NAME="${2:-base}"
IMAGE_NAME="jon-babylon:${STAGE_NUM}-${STAGE_NAME}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Testing Stage ${STAGE_NUM}: ${STAGE_NAME}${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if image exists
if ! docker image inspect "$IMAGE_NAME" &> /dev/null; then
    echo -e "${RED}✗ Image $IMAGE_NAME not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Image exists${NC}"

# Get image size
IMAGE_SIZE=$(docker image inspect "$IMAGE_NAME" --format='{{.Size}}' | numfmt --to=iec-i --suffix=B)
echo "Image size: $IMAGE_SIZE"

# Run stage-specific tests based on stage number
case "$STAGE_NUM" in
    00)
        echo "Testing base system..."
        docker run --rm "$IMAGE_NAME" bash -c "locale | grep en_US.UTF-8"
        docker run --rm "$IMAGE_NAME" bash -c "id developer"
        ;;
    01)
        echo "Testing build essentials..."
        docker run --rm "$IMAGE_NAME" gcc --version
        docker run --rm "$IMAGE_NAME" make --version
        ;;
    02)
        echo "Testing Java..."
        docker run --rm "$IMAGE_NAME" java -version
        docker run --rm "$IMAGE_NAME" javac -version
        ;;
    03)
        echo "Testing Kotlin..."
        docker run --rm "$IMAGE_NAME" kotlin -version
        ;;
    04)
        echo "Testing Clojure..."
        docker run --rm "$IMAGE_NAME" clojure --version
        docker run --rm "$IMAGE_NAME" lein version
        ;;
    05)
        echo "Testing Python..."
        docker run --rm "$IMAGE_NAME" python3 --version
        docker run --rm "$IMAGE_NAME" pip3 --version
        docker run --rm "$IMAGE_NAME" python3 -m nuitka --version
        ;;
    06)
        echo "Testing Clang..."
        docker run --rm "$IMAGE_NAME" clang --version
        docker run --rm "$IMAGE_NAME" clang++ --version
        ;;
    07)
        echo "Testing Rust..."
        docker run --rm "$IMAGE_NAME" rustc --version
        docker run --rm "$IMAGE_NAME" cargo --version
        ;;
    08)
        echo "Testing Node.js..."
        docker run --rm "$IMAGE_NAME" node --version
        docker run --rm "$IMAGE_NAME" npm --version
        ;;
    09)
        echo "Testing Build Tools..."
        docker run --rm "$IMAGE_NAME" mvn --version
        docker run --rm "$IMAGE_NAME" gradle --version
        ;;
    10)
        echo "Testing Web Tools..."
        docker run --rm "$IMAGE_NAME" tsc --version
        docker run --rm "$IMAGE_NAME" bun --version
        docker run --rm "$IMAGE_NAME" esbuild --version
        docker run --rm "$IMAGE_NAME" prettier --version
        docker run --rm "$IMAGE_NAME" eslint --version
        ;;
    11)
        echo "Running comprehensive tests..."
        docker run --rm "$IMAGE_NAME" /scripts/check_versions.sh
        ;;
    *)
        echo -e "${YELLOW}No specific tests defined for stage $STAGE_NUM${NC}"
        ;;
esac

echo ""
echo -e "${GREEN}✓ Stage $STAGE_NUM ($STAGE_NAME) tests passed!${NC}"
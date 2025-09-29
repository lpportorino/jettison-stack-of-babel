#!/bin/bash
# Universal Jon-Babylon Build Script
# Works on both PC (AMD64) and NVIDIA Orin (ARM64)
# Automatically detects architecture and builds appropriately

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="jon-babylon"
REGISTRY="ghcr.io/lpportorino"
VERSION=$(date +%Y.%m.%d)
GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "no-git")

# Function to print colored output
print_msg() {
    local color=$1
    local msg=$2
    echo -e "${color}${msg}${NC}"
}

# Function to detect architecture
detect_arch() {
    local arch=$(uname -m)
    case $arch in
        x86_64|amd64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            print_msg "$RED" "Unknown architecture: $arch"
            exit 1
            ;;
    esac
}

# Function to check prerequisites
check_prerequisites() {
    print_msg "$BLUE" "Checking prerequisites..."

    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_msg "$RED" "Docker is not installed!"
        exit 1
    fi
    print_msg "$GREEN" "✓ Docker: $(docker --version)"

    # Check Docker Buildx
    if docker buildx version &> /dev/null; then
        BUILDX_AVAILABLE=true
        print_msg "$GREEN" "✓ Docker Buildx: $(docker buildx version | head -1)"
    else
        BUILDX_AVAILABLE=false
        print_msg "$YELLOW" "⚠ Docker Buildx not available, using regular build"
    fi

    # Check Git
    if command -v git &> /dev/null; then
        print_msg "$GREEN" "✓ Git: $(git --version)"
    else
        print_msg "$YELLOW" "⚠ Git not found, version tagging disabled"
    fi
}

# Function to setup buildx builder
setup_buildx() {
    if [ "$BUILDX_AVAILABLE" = true ]; then
        print_msg "$BLUE" "Setting up buildx builder..."

        # Check if builder exists
        if ! docker buildx ls | grep -q "jon-babylon-builder"; then
            docker buildx create --name jon-babylon-builder --driver docker-container --use
            print_msg "$GREEN" "✓ Created buildx builder: jon-babylon-builder"
        else
            docker buildx use jon-babylon-builder
            print_msg "$GREEN" "✓ Using existing builder: jon-babylon-builder"
        fi

        # Bootstrap the builder
        docker buildx inspect --bootstrap > /dev/null 2>&1
    fi
}

# Function to build for current architecture
build_image() {
    local arch=$1
    local dockerfile=""
    local platform=""
    local build_args=""

    # Select Dockerfile and platform based on architecture
    case $arch in
        amd64)
            dockerfile="Dockerfile.x86_64"
            platform="linux/amd64"
            print_msg "$YELLOW" "Building for AMD64 (Testing/Development)"
            ;;
        arm64)
            dockerfile="Dockerfile.arm64"
            platform="linux/arm64"
            build_args="--build-arg MARCH=armv8.2-a --build-arg MTUNE=cortex-a78"
            print_msg "$GREEN" "Building for ARM64 (NVIDIA Orin Optimized)"
            print_msg "$CYAN" "Optimization: -march=armv8.2-a -mtune=cortex-a78"
            ;;
    esac

    # Check if Dockerfile exists
    if [ ! -f "$dockerfile" ]; then
        print_msg "$YELLOW" "Warning: $dockerfile not found, using default Dockerfile.x86_64"
        dockerfile="Dockerfile.x86_64"
    fi

    local tag="${IMAGE_NAME}:latest"
    local tag_arch="${IMAGE_NAME}:latest-${arch}"
    local tag_version="${IMAGE_NAME}:${VERSION}-${arch}"

    print_msg "$BLUE" "Building image..."
    print_msg "$CYAN" "  Dockerfile: $dockerfile"
    print_msg "$CYAN" "  Platform: $platform"
    print_msg "$CYAN" "  Tags: $tag, $tag_arch, $tag_version"

    # Build command
    if [ "$BUILDX_AVAILABLE" = true ]; then
        # Use buildx for better performance and features
        docker buildx build \
            --platform "$platform" \
            --file "$dockerfile" \
            --tag "$tag" \
            --tag "$tag_arch" \
            --tag "$tag_version" \
            --cache-from "type=local,src=/tmp/buildx-cache-$arch" \
            --cache-to "type=local,dest=/tmp/buildx-cache-$arch,mode=max" \
            --load \
            $build_args \
            .
    else
        # Fallback to regular docker build
        docker build \
            --file "$dockerfile" \
            --tag "$tag" \
            --tag "$tag_arch" \
            --tag "$tag_version" \
            $build_args \
            .
    fi

    if [ $? -eq 0 ]; then
        print_msg "$GREEN" "✓ Build successful!"
    else
        print_msg "$RED" "✗ Build failed!"
        exit 1
    fi
}

# Function to run basic tests
run_tests() {
    local arch=$1
    local tag="${IMAGE_NAME}:latest-${arch}"

    print_msg "$BLUE" "\nRunning basic tests..."

    # Test 1: Check if image exists
    if docker images | grep -q "$IMAGE_NAME.*latest-${arch}"; then
        print_msg "$GREEN" "✓ Image created successfully"
    else
        print_msg "$RED" "✗ Image not found"
        exit 1
    fi

    # Test 2: Run version check
    print_msg "$CYAN" "Testing version check script..."
    if docker run --rm "$tag" /scripts/check_versions.sh > /dev/null 2>&1; then
        print_msg "$GREEN" "✓ Version check passed"
    else
        print_msg "$YELLOW" "⚠ Version check script not found or failed"
    fi

    # Test 3: Run a simple command
    print_msg "$CYAN" "Testing basic commands..."
    docker run --rm "$tag" bash -c "echo 'Container works!' && uname -a"

    # Test 4: Check Python
    print_msg "$CYAN" "Testing Python..."
    docker run --rm "$tag" python3 --version || print_msg "$YELLOW" "⚠ Python test failed"

    # Test 5: Check Java
    print_msg "$CYAN" "Testing Java..."
    docker run --rm "$tag" java --version || print_msg "$YELLOW" "⚠ Java test failed"

    print_msg "$GREEN" "\n✓ Basic tests completed"
}

# Function to show usage
usage() {
    cat << EOF
Jon-Babylon Universal Build Script

Usage: $0 [OPTIONS]

Options:
    --no-cache       Build without cache
    --test-only      Only run tests on existing image
    --push           Push to registry after build
    --quick          Quick build (skip tests)
    --help           Show this help message

Environment Variables:
    IMAGE_NAME       Override image name (default: jon-babylon)
    REGISTRY         Override registry (default: ghcr.io/lpportorino)

Examples:
    $0                    # Build for current architecture
    $0 --no-cache         # Clean build
    $0 --push             # Build and push to registry
    $0 --quick            # Quick build without tests

EOF
}

# Main execution
main() {
    # Parse arguments
    NO_CACHE=false
    TEST_ONLY=false
    PUSH=false
    QUICK=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-cache)
                NO_CACHE=true
                shift
                ;;
            --test-only)
                TEST_ONLY=true
                shift
                ;;
            --push)
                PUSH=true
                shift
                ;;
            --quick)
                QUICK=true
                shift
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                print_msg "$RED" "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Header
    print_msg "$BLUE" "========================================="
    print_msg "$BLUE" "   Jon-Babylon Universal Build Script"
    print_msg "$BLUE" "========================================="

    # Detect architecture
    ARCH=$(detect_arch)
    print_msg "$GREEN" "Detected architecture: $ARCH"

    # Check prerequisites
    check_prerequisites

    if [ "$TEST_ONLY" = false ]; then
        # Setup buildx if available
        if [ "$BUILDX_AVAILABLE" = true ]; then
            setup_buildx
        fi

        # Add no-cache flag if requested
        if [ "$NO_CACHE" = true ]; then
            print_msg "$YELLOW" "Building without cache..."
            if [ "$BUILDX_AVAILABLE" = true ]; then
                build_args="$build_args --no-cache"
            else
                build_args="$build_args --no-cache"
            fi
        fi

        # Build the image
        build_image "$ARCH"
    fi

    # Run tests unless quick mode
    if [ "$QUICK" = false ]; then
        run_tests "$ARCH"
    fi

    # Push if requested
    if [ "$PUSH" = true ]; then
        print_msg "$BLUE" "\nPushing to registry..."
        local tag="${IMAGE_NAME}:latest-${ARCH}"

        # Login check
        if ! docker pull "${REGISTRY}/${IMAGE_NAME}:latest" > /dev/null 2>&1; then
            print_msg "$YELLOW" "Please login first: docker login $REGISTRY"
            exit 1
        fi

        # Tag and push
        docker tag "$tag" "${REGISTRY}/${tag}"
        docker push "${REGISTRY}/${tag}"
        print_msg "$GREEN" "✓ Pushed to ${REGISTRY}/${tag}"
    fi

    # Summary
    print_msg "$BLUE" "\n========================================="
    print_msg "$GREEN" "Build Complete!"
    print_msg "$CYAN" "Image: ${IMAGE_NAME}:latest-${ARCH}"
    print_msg "$CYAN" "Size: $(docker images --format "table {{.Size}}" ${IMAGE_NAME}:latest-${ARCH} | tail -1)"

    # Usage instructions
    print_msg "$BLUE" "\nTo use the image:"
    print_msg "$CYAN" "  docker run -it --rm ${IMAGE_NAME}:latest-${ARCH} bash"
    print_msg "$CYAN" "  docker run -v \$(pwd):/workspace ${IMAGE_NAME}:latest-${ARCH} <command>"

    print_msg "$BLUE" "========================================="
}

# Run main function
main "$@"
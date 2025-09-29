#!/bin/bash
# Enhanced Jon-Babylon Build Script with Comprehensive Logging
# Creates detailed log files for each build stage and test
# Works on both AMD64 and ARM64 architectures

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
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Log directory setup
LOG_DIR="build-logs/${TIMESTAMP}"
mkdir -p "$LOG_DIR"

# Main log file
MAIN_LOG="${LOG_DIR}/build-main.log"

# Function to print colored output and log
print_msg() {
    local color=$1
    local msg=$2
    echo -e "${color}${msg}${NC}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${msg}" >> "$MAIN_LOG"
}

# Function to log command output
log_cmd() {
    local stage=$1
    local log_file="${LOG_DIR}/${stage}.log"
    shift
    echo "=== Running: $@ ===" | tee -a "$log_file"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$log_file"
    echo "---" | tee -a "$log_file"
    "$@" 2>&1 | tee -a "$log_file"
    local exit_code=${PIPESTATUS[0]}
    echo "---" | tee -a "$log_file"
    echo "Exit code: $exit_code" | tee -a "$log_file"
    echo "" | tee -a "$log_file"
    return $exit_code
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
    if command -v docker >/dev/null 2>&1; then
        local docker_version=$(docker --version | awk '{print $3}' | sed 's/,//')
        print_msg "$GREEN" "✓ Docker: $(docker --version)"
        echo "Docker version: $docker_version" >> "${LOG_DIR}/prerequisites.log"
    else
        print_msg "$RED" "✗ Docker not found"
        exit 1
    fi

    # Check Docker Buildx
    if docker buildx version >/dev/null 2>&1; then
        BUILDX_AVAILABLE=true
        print_msg "$GREEN" "✓ Docker Buildx: $(docker buildx version)"
        docker buildx version >> "${LOG_DIR}/prerequisites.log"
    else
        BUILDX_AVAILABLE=false
        print_msg "$YELLOW" "⚠ Docker Buildx not found (using regular build)"
    fi

    # Check Git
    if command -v git >/dev/null 2>&1; then
        print_msg "$GREEN" "✓ Git: $(git --version)"
        git --version >> "${LOG_DIR}/prerequisites.log"
    else
        print_msg "$YELLOW" "⚠ Git not found"
    fi

    # Check disk space
    local available_space=$(df -h . | tail -1 | awk '{print $4}')
    print_msg "$CYAN" "Available disk space: $available_space"
    echo "Disk space: $available_space" >> "${LOG_DIR}/prerequisites.log"
}

# Function to setup buildx builder
setup_buildx() {
    local builder_name="${IMAGE_NAME}-builder"
    print_msg "$BLUE" "Setting up buildx builder..."

    # Check if builder exists
    if docker buildx ls | grep -q "$builder_name"; then
        print_msg "$GREEN" "✓ Using existing builder: $builder_name"
        log_cmd "buildx-info" docker buildx inspect "$builder_name"
    else
        print_msg "$CYAN" "Creating new builder: $builder_name"
        log_cmd "buildx-create" docker buildx create \
            --name "$builder_name" \
            --driver docker-container \
            --use
    fi

    # Use the builder
    docker buildx use "$builder_name"
}

# Function to build the image
build_image() {
    local arch=$1
    local dockerfile=""
    local platform=""
    local optimization=""

    print_msg "$BLUE" "\nBuilding image..."

    # Select Dockerfile based on architecture
    if [ "$arch" = "arm64" ]; then
        dockerfile="Dockerfile.arm64"
        platform="linux/arm64"
        optimization="--build-arg OPTFLAGS=-O3"
        print_msg "$GREEN" "Building for ARM64"
    else
        dockerfile="Dockerfile.x86_64"
        platform="linux/amd64"
        print_msg "$YELLOW" "Building for AMD64"
    fi

    # Check if Dockerfile exists
    if [ ! -f "$dockerfile" ]; then
        print_msg "$RED" "Error: $dockerfile not found"
        exit 1
    fi

    # Build tags
    local tags=""
    tags="$tags -t ${IMAGE_NAME}:latest"
    tags="$tags -t ${IMAGE_NAME}:latest-${arch}"
    tags="$tags -t ${IMAGE_NAME}:${VERSION}-${arch}"

    print_msg "$CYAN" "  Dockerfile: $dockerfile"
    print_msg "$CYAN" "  Platform: $platform"
    print_msg "$CYAN" "  Tags: ${IMAGE_NAME}:latest, ${IMAGE_NAME}:latest-${arch}, ${IMAGE_NAME}:${VERSION}-${arch}"

    # Build command
    if [ "$BUILDX_AVAILABLE" = true ]; then
        print_msg "$CYAN" "Using buildx for build..."
        log_cmd "docker-build" docker buildx build \
            --platform "$platform" \
            --load \
            $optimization \
            $build_args \
            $tags \
            -f "$dockerfile" \
            --progress=plain \
            .
    else
        print_msg "$CYAN" "Using regular docker build..."
        log_cmd "docker-build" docker build \
            $build_args \
            $tags \
            -f "$dockerfile" \
            .
    fi

    print_msg "$GREEN" "✓ Build completed successfully"
}

# Enhanced test function with individual test logging
run_tests() {
    local arch=$1
    local tag="${IMAGE_NAME}:latest-${arch}"
    local test_log="${LOG_DIR}/tests"
    mkdir -p "$test_log"

    print_msg "$BLUE" "\n========================================="
    print_msg "$BLUE" "Running Comprehensive Tests"
    print_msg "$BLUE" "========================================="

    # Test 1: Image verification
    print_msg "$CYAN" "\n[1/10] Verifying image creation..."
    if docker images | grep -q "$IMAGE_NAME.*latest-${arch}"; then
        print_msg "$GREEN" "✓ Image created successfully"
        docker images | grep "$IMAGE_NAME" > "${test_log}/01-image-verification.log"
    else
        print_msg "$RED" "✗ Image not found"
        exit 1
    fi

    # Test 2: Container startup
    print_msg "$CYAN" "\n[2/10] Testing container startup..."
    if log_cmd "02-container-startup" docker run --rm "$tag" echo "Container started successfully"; then
        print_msg "$GREEN" "✓ Container starts correctly"
    else
        print_msg "$RED" "✗ Container failed to start"
        exit 1
    fi

    # Test 3: System information
    print_msg "$CYAN" "\n[3/10] Gathering system information..."
    log_cmd "03-system-info" docker run --rm "$tag" bash -c "uname -a && cat /etc/os-release"

    # Test 4: Java toolchain
    print_msg "$CYAN" "\n[4/10] Testing Java toolchain..."
    log_cmd "04-java-test" docker run --rm "$tag" bash -c "
        echo '=== Java Version ===' && java --version &&
        echo '=== Maven Version ===' && mvn --version &&
        echo '=== Gradle Version ===' && gradle --version &&
        echo '=== Kotlin Version ===' && kotlin -version
    " && print_msg "$GREEN" "✓ Java toolchain working" || print_msg "$RED" "✗ Java toolchain failed"

    # Test 5: Python toolchain
    print_msg "$CYAN" "\n[5/10] Testing Python toolchain..."
    log_cmd "05-python-test" docker run --rm "$tag" bash -c "
        echo '=== Python Version ===' && python3 --version &&
        echo '=== Pip Version ===' && pip3 --version &&
        echo '=== Testing Nuitka ===' && python3 -m nuitka --version &&
        echo '=== Python Linters ===' &&
        which flake8 && which black && which mypy && which ruff
    " && print_msg "$GREEN" "✓ Python toolchain working" || print_msg "$RED" "✗ Python toolchain failed"

    # Test 6: Rust toolchain
    print_msg "$CYAN" "\n[6/10] Testing Rust toolchain..."
    log_cmd "06-rust-test" docker run --rm "$tag" bash -c "
        echo '=== Rust Version ===' && rustc --version &&
        echo '=== Cargo Version ===' && cargo --version &&
        echo '=== Clippy Version ===' && cargo clippy --version &&
        echo '=== Rustfmt Version ===' && cargo fmt --version
    " && print_msg "$GREEN" "✓ Rust toolchain working" || print_msg "$RED" "✗ Rust toolchain failed"

    # Test 7: Node.js/JavaScript toolchain
    print_msg "$CYAN" "\n[7/10] Testing Node.js/JavaScript toolchain..."
    log_cmd "07-nodejs-test" docker run --rm "$tag" bash -c "
        echo '=== Node Version ===' && node --version &&
        echo '=== NPM Version ===' && npm --version &&
        echo '=== TypeScript Version ===' && tsc --version &&
        echo '=== ESLint Version ===' && eslint --version &&
        echo '=== Prettier Version ===' && prettier --version &&
        echo '=== Bun Version ===' && bun --version
    " && print_msg "$GREEN" "✓ Node.js toolchain working" || print_msg "$RED" "✗ Node.js toolchain failed"

    # Test 8: C/C++ toolchain
    print_msg "$CYAN" "\n[8/10] Testing C/C++ toolchain..."
    log_cmd "08-cpp-test" docker run --rm "$tag" bash -c "
        echo '=== Clang Version ===' && clang --version &&
        echo '=== Clang++ Version ===' && clang++ --version &&
        echo '=== Clang-format Version ===' && clang-format --version &&
        echo '=== CMake Version ===' && cmake --version
    " && print_msg "$GREEN" "✓ C/C++ toolchain working" || print_msg "$RED" "✗ C/C++ toolchain failed"

    # Test 9: Run actual test projects
    print_msg "$CYAN" "\n[9/10] Running test projects..."
    if [ -f "./run_all_tests.sh" ]; then
        print_msg "$CYAN" "Found test runner script, executing in container..."
        log_cmd "09-test-projects" docker run --rm \
            -v "$(pwd)/tests:/tests:ro" \
            "$tag" \
            bash -c "cd /tests && ./run_test.sh" \
            && print_msg "$GREEN" "✓ Test projects passed" \
            || print_msg "$YELLOW" "⚠ Some test projects failed (check logs)"
    else
        print_msg "$YELLOW" "⚠ Test runner script not found"
    fi

    # Test 10: Version check script
    print_msg "$CYAN" "\n[10/10] Running version check script..."
    if log_cmd "10-version-check" docker run --rm "$tag" /scripts/check_versions.sh 2>/dev/null; then
        print_msg "$GREEN" "✓ Version check passed"
    else
        print_msg "$YELLOW" "⚠ Version check script not found or failed"
    fi

    print_msg "$BLUE" "\n========================================="
    print_msg "$GREEN" "All Tests Completed!"
    print_msg "$CYAN" "Test logs saved in: ${test_log}/"
    print_msg "$BLUE" "========================================="
}

# Function to generate test report
generate_test_report() {
    local report="${LOG_DIR}/test-report.md"

    print_msg "$BLUE" "\nGenerating test report..."

    cat > "$report" << EOF
# Jon-Babylon Build Test Report

**Date**: $(date)
**Architecture**: $ARCH
**Image**: ${IMAGE_NAME}:latest-${ARCH}
**Build Duration**: ${BUILD_DURATION} seconds

## Test Results Summary

| Test | Status | Log File |
|------|--------|----------|
EOF

    # Parse test logs and add to report
    for log in "${LOG_DIR}"/tests/*.log; do
        if [ -f "$log" ]; then
            local test_name=$(basename "$log" .log)
            local status="✅ Passed"
            if grep -q "Exit code: [1-9]" "$log" 2>/dev/null; then
                status="❌ Failed"
            fi
            echo "| $test_name | $status | [View](tests/$(basename $log)) |" >> "$report"
        fi
    done

    cat >> "$report" << EOF

## Build Configuration
- Dockerfile: $DOCKERFILE
- Platform: $PLATFORM
- Build Args: $build_args

## Disk Usage
\`\`\`
$(docker images | grep "$IMAGE_NAME")
\`\`\`

## Next Steps
1. Review failed tests in the log files
2. Fix any issues identified
3. Re-run build with \`./build-local-enhanced.sh\`

---
*Generated by build-local-enhanced.sh*
EOF

    print_msg "$GREEN" "✓ Test report generated: $report"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Enhanced Jon-Babylon Docker image builder with comprehensive logging.
Creates detailed log files for each build stage and test.

Options:
    --no-cache       Build without cache
    --test-only      Only run tests on existing image
    --push           Push to registry after build
    --report-only    Generate report from existing logs
    --help           Show this help message

Environment Variables:
    IMAGE_NAME       Override image name (default: jon-babylon)

Logs are saved in: build-logs/TIMESTAMP/

Examples:
    $0                    # Build for current architecture with tests
    $0 --no-cache         # Clean build with no cache
    $0 --push             # Build, test, and push to registry
    $0 --test-only        # Run tests on existing image

EOF
}

# Parse arguments
NO_CACHE=false
TEST_ONLY=false
PUSH=false
REPORT_ONLY=false

while [ "$#" -gt 0 ]; do
    case "$1" in
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
        --report-only)
            REPORT_ONLY=true
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            print_msg "$RED" "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_msg "$BLUE" "========================================="
    print_msg "$BLUE" "   Jon-Babylon Enhanced Build Script"
    print_msg "$BLUE" "========================================="
    print_msg "$CYAN" "Log directory: $LOG_DIR"

    # Detect architecture
    ARCH=$(detect_arch)
    print_msg "$GREEN" "Detected architecture: $ARCH"

    # Set architecture-specific variables
    if [ "$ARCH" = "arm64" ]; then
        DOCKERFILE="Dockerfile.arm64"
        PLATFORM="linux/arm64"
    else
        DOCKERFILE="Dockerfile.x86_64"
        PLATFORM="linux/amd64"
    fi

    # Report only mode
    if [ "$REPORT_ONLY" = true ]; then
        generate_test_report
        exit 0
    fi

    # Check prerequisites
    check_prerequisites

    # Test only mode
    if [ "$TEST_ONLY" = true ]; then
        print_msg "$BLUE" "Running tests on existing image..."
        run_tests "$ARCH"
        generate_test_report
        exit 0
    fi

    # Build mode
    build_args=""

    # Record build start time
    BUILD_START=$(date +%s)

    # Setup buildx if available
    if [ "$BUILDX_AVAILABLE" = true ]; then
        setup_buildx
    fi

    # Add no-cache flag if requested
    if [ "$NO_CACHE" = true ]; then
        print_msg "$YELLOW" "Building without cache..."
        build_args="$build_args --no-cache"
    fi

    # Build the image
    build_image "$ARCH"

    # Calculate build duration
    BUILD_END=$(date +%s)
    BUILD_DURATION=$((BUILD_END - BUILD_START))

    # Always run comprehensive tests
    run_tests "$ARCH"

    # Generate test report
    generate_test_report

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
        log_cmd "docker-push" docker tag "$tag" "${REGISTRY}/${tag}"
        log_cmd "docker-push" docker push "${REGISTRY}/${tag}"
        print_msg "$GREEN" "✓ Pushed to ${REGISTRY}/${tag}"
    fi

    # Summary
    print_msg "$BLUE" "\n========================================="
    print_msg "$GREEN" "Build Complete!"
    print_msg "$CYAN" "Image: ${IMAGE_NAME}:latest-${ARCH}"
    print_msg "$CYAN" "Size: $(docker images --format "table {{.Size}}" ${IMAGE_NAME}:latest-${ARCH} | tail -1)"
    print_msg "$CYAN" "Build Duration: ${BUILD_DURATION} seconds"
    print_msg "$CYAN" "Logs saved in: $LOG_DIR"

    # Usage instructions
    print_msg "$BLUE" "\nTo use the image:"
    print_msg "$CYAN" "  docker run -it --rm ${IMAGE_NAME}:latest-${ARCH} bash"
    print_msg "$CYAN" "  docker run -v \$(pwd):/workspace ${IMAGE_NAME}:latest-${ARCH} <command>"

    print_msg "$BLUE" "\nTo view logs:"
    print_msg "$CYAN" "  ls -la $LOG_DIR/"
    print_msg "$CYAN" "  cat $LOG_DIR/test-report.md"
}

# Run main function
main
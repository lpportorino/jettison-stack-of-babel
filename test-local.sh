#!/bin/bash
# Local Container Build and Test Script
# This script builds each container locally and runs comprehensive test suites
# Logs are saved with timestamps for debugging

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Base directory (script location)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Container prefix for local builds
PREFIX="local-test"

# Create logs directory with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_DIR="$SCRIPT_DIR/test-logs/$TIMESTAMP"
mkdir -p "$LOG_DIR"

# Function to print colored output
print_status() {
    echo -e "${BLUE}===> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Function to build a container
build_container() {
    local name=$1
    local dockerfile=$2
    local build_args=$3
    local log_file="$LOG_DIR/build-$name.log"

    print_status "Building $name container..."
    print_info "Log: $log_file"

    if docker build -t "$PREFIX-$name:latest" \
        -f "$dockerfile" \
        $build_args \
        . > "$log_file" 2>&1; then
        print_success "$name container built successfully"
        echo "Build completed at $(date)" >> "$log_file"
        return 0
    else
        print_error "Failed to build $name container"
        echo "Build failed at $(date)" >> "$log_file"
        echo "Last 50 lines of build log:"
        tail -50 "$log_file"
        return 1
    fi
}

# Function to run container tests
run_container_tests() {
    local container=$1
    local test_dir=$2

    print_status "Testing $container container..."

    # Check if test directory exists
    if [ ! -d "$test_dir" ]; then
        print_warning "No test directory found for $container at $test_dir"
        echo "No test directory found" > "$LOG_DIR/test-$container-notfound.log"
        return 0
    fi

    # Track test results for this container
    local container_passed=true

    # Find all test subdirectories
    for test_subdir in "$test_dir"/*; do
        if [ -d "$test_subdir" ]; then
            local test_name=$(basename "$test_subdir")
            local log_file="$LOG_DIR/test-$container-$test_name.log"

            print_status "Running $test_name tests for $container..."
            print_info "Log: $log_file"

            # Check if run_test.sh exists
            if [ -f "$test_subdir/run_test.sh" ]; then
                # Log test start
                echo "Test started at $(date)" > "$log_file"
                echo "Container: $PREFIX-$container:latest" >> "$log_file"
                echo "Test directory: $test_subdir" >> "$log_file"
                echo "========================================" >> "$log_file"

                # Run the test in the container with the test directory mounted
                if docker run --rm \
                    -v "$SCRIPT_DIR/$test_subdir:/workspace" \
                    -w /workspace \
                    "$PREFIX-$container:latest" \
                    bash -c "chmod +x run_test.sh && ./run_test.sh" >> "$log_file" 2>&1; then
                    print_success "$test_name tests passed"
                    echo "========================================" >> "$log_file"
                    echo "Test passed at $(date)" >> "$log_file"
                else
                    print_error "$test_name tests failed"
                    echo "========================================" >> "$log_file"
                    echo "Test failed at $(date)" >> "$log_file"
                    echo "Last 50 lines of test output:"
                    tail -50 "$log_file"
                    container_passed=false
                fi
            else
                print_warning "No run_test.sh found in $test_subdir"
                echo "No run_test.sh found" > "$log_file"
            fi
        fi
    done

    if [ "$container_passed" = true ]; then
        return 0
    else
        return 1
    fi
}

# Main execution
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Container Build and Test Script${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
print_info "Logs will be saved to: $LOG_DIR"
echo ""

# Write summary header
SUMMARY_FILE="$LOG_DIR/summary.txt"
echo "Test Run Summary - $TIMESTAMP" > "$SUMMARY_FILE"
echo "================================" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

# Track overall status
FAILED_CONTAINERS=""
PASSED_CONTAINERS=""

# 1. Build base container
print_status "Stage 1: Building base container"
if build_container "base" "dockerfiles/base/Dockerfile" ""; then
    # Run base container tests (version check)
    print_status "Running base container version check..."
    VERSION_LOG="$LOG_DIR/test-base-versions.log"
    if docker run --rm "$PREFIX-base:latest" check_versions.sh > "$VERSION_LOG" 2>&1; then
        print_success "Base container ready"
        cat "$VERSION_LOG"  # Show version info
        PASSED_CONTAINERS="$PASSED_CONTAINERS base"
        echo "✓ base - PASSED" >> "$SUMMARY_FILE"
    else
        print_error "Base container version check failed"
        FAILED_CONTAINERS="$FAILED_CONTAINERS base"
        echo "✗ base - FAILED (version check)" >> "$SUMMARY_FILE"
    fi
else
    FAILED_CONTAINERS="$FAILED_CONTAINERS base"
    echo "✗ base - FAILED (build)" >> "$SUMMARY_FILE"
    print_error "Cannot continue without base container"
    exit 1
fi

echo ""

# 2. Build containers that depend on base
print_status "Stage 2: Building containers that depend on base"

# Array of containers to build
declare -a CONTAINERS=("jvm" "clang" "rust" "go" "web")

for container in "${CONTAINERS[@]}"; do
    echo ""
    if build_container "$container" "dockerfiles/$container/Dockerfile" "--build-arg BASE_IMAGE=$PREFIX-base:latest"; then
        if run_container_tests "$container" "dockerfiles/$container/tests"; then
            PASSED_CONTAINERS="$PASSED_CONTAINERS $container"
            echo "✓ $container - PASSED" >> "$SUMMARY_FILE"
        else
            FAILED_CONTAINERS="$FAILED_CONTAINERS $container"
            echo "✗ $container - FAILED (tests)" >> "$SUMMARY_FILE"
        fi
    else
        FAILED_CONTAINERS="$FAILED_CONTAINERS $container"
        echo "✗ $container - FAILED (build)" >> "$SUMMARY_FILE"
    fi
done

echo ""

# 3. Build Python container (depends on clang)
print_status "Stage 3: Building Python container (depends on clang)"
if [[ ! "$FAILED_CONTAINERS" == *"clang"* ]]; then
    if build_container "python" "dockerfiles/python/Dockerfile" "--build-arg CLANG_IMAGE=$PREFIX-clang:latest"; then
        if run_container_tests "python" "dockerfiles/python/tests"; then
            PASSED_CONTAINERS="$PASSED_CONTAINERS python"
            echo "✓ python - PASSED" >> "$SUMMARY_FILE"
        else
            FAILED_CONTAINERS="$FAILED_CONTAINERS python"
            echo "✗ python - FAILED (tests)" >> "$SUMMARY_FILE"
        fi
    else
        FAILED_CONTAINERS="$FAILED_CONTAINERS python"
        echo "✗ python - FAILED (build)" >> "$SUMMARY_FILE"
    fi
else
    print_warning "Skipping Python container (Clang container failed)"
    echo "⚠ python - SKIPPED (clang dependency failed)" >> "$SUMMARY_FILE"
fi

# Final summary
echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}================================${NC}"

# Count results
PASSED_COUNT=$(echo $PASSED_CONTAINERS | wc -w)
FAILED_COUNT=$(echo $FAILED_CONTAINERS | wc -w)

if [ -n "$PASSED_CONTAINERS" ]; then
    echo -e "${GREEN}Passed containers ($PASSED_COUNT):${NC}$PASSED_CONTAINERS"
fi

if [ -n "$FAILED_CONTAINERS" ]; then
    echo -e "${RED}Failed containers ($FAILED_COUNT):${NC}$FAILED_CONTAINERS"
fi

# Write final summary
echo "" >> "$SUMMARY_FILE"
echo "Final Results:" >> "$SUMMARY_FILE"
echo "Passed: $PASSED_COUNT containers" >> "$SUMMARY_FILE"
echo "Failed: $FAILED_COUNT containers" >> "$SUMMARY_FILE"

# Show log location
echo ""
print_info "All logs saved to: $LOG_DIR"
print_info "Summary available at: $SUMMARY_FILE"

# Provide helpful commands
echo ""
echo "Useful commands:"
echo "  View summary: cat $SUMMARY_FILE"
echo "  View all logs: ls -la $LOG_DIR/"
echo "  View specific log: cat $LOG_DIR/<logname>.log"

if [ -n "$FAILED_CONTAINERS" ]; then
    echo ""
    echo "To debug failed containers:"
    for container in $FAILED_CONTAINERS; do
        echo "  $container:"
        echo "    Build log: $LOG_DIR/build-$container.log"
        echo "    Test logs: $LOG_DIR/test-$container-*.log"
        echo "    Run shell: docker run -it --rm $PREFIX-$container:latest bash"
    done
fi

echo ""
echo "To use the containers:"
for container in base jvm clang python rust go web; do
    if [[ "$PASSED_CONTAINERS" == *"$container"* ]]; then
        echo "  docker run -it --rm $PREFIX-$container:latest"
    fi
done

echo ""
echo "To clean up local test images:"
echo "  docker rmi \$(docker images -q '$PREFIX-*')"

# Exit with error if any containers failed
if [ -n "$FAILED_CONTAINERS" ]; then
    exit 1
else
    print_success "All containers built and tested successfully!"
    exit 0
fi
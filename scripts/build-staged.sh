#!/bin/bash
# Staged Build Orchestrator for Jon-Babylon
# Builds each stage incrementally with testing between stages

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
REGISTRY="${REGISTRY:-ghcr.io/lpportorino}"
IMAGE_BASE="${IMAGE_BASE:-jon-babylon}"
VERSION="${VERSION:-$(date +%Y.%m.%d)}"
DOCKER_DIR="$(dirname "$0")/../docker"
STAGES_DIR="$DOCKER_DIR/stages"
TESTS_DIR="$DOCKER_DIR/tests"

# Build options
NO_CACHE=false
PUSH_INTERMEDIATE=false
STOP_ON_FAILURE=true
PARALLEL_TEST=false
START_STAGE=0
END_STAGE=11

# Stage definitions
declare -A STAGES=(
    [00]="base:Base system with Ubuntu 22.04"
    [01]="build-essentials:Build tools and libraries"
    [02]="java:OpenJDK 21 LTS"
    [03]="kotlin:Kotlin via SDKMAN"
    [04]="clojure:Clojure and Leiningen"
    [05]="python:Python via pyenv + Nuitka"
    [06]="clang:LLVM/Clang 21"
    [07]="rust:Rust via rustup"
    [08]="nodejs:Node.js 22 LTS"
    [09]="build-tools:Maven and Gradle"
    [10]="web-tools:TypeScript, esbuild, Bun, etc."
    [11]="final:Final assembled image"
)

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        --push-intermediate)
            PUSH_INTERMEDIATE=true
            shift
            ;;
        --continue-on-failure)
            STOP_ON_FAILURE=false
            shift
            ;;
        --parallel-test)
            PARALLEL_TEST=true
            shift
            ;;
        --start-stage)
            START_STAGE="$2"
            shift 2
            ;;
        --end-stage)
            END_STAGE="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --no-cache             Build without cache"
            echo "  --push-intermediate    Push intermediate images to registry"
            echo "  --continue-on-failure  Continue building even if a stage fails"
            echo "  --parallel-test        Run tests in parallel (experimental)"
            echo "  --start-stage NUM      Start from stage NUM (default: 0)"
            echo "  --end-stage NUM        End at stage NUM (default: 11)"
            echo "  --help                 Show this help message"
            echo ""
            echo "Available stages:"
            for stage_num in $(seq -w 0 11); do
                IFS=':' read -r stage_name stage_desc <<< "${STAGES[$stage_num]}"
                echo "  $stage_num - $stage_name: $stage_desc"
            done
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Function to build a stage
build_stage() {
    local stage_num="$1"
    local stage_info="${STAGES[$stage_num]}"
    IFS=':' read -r stage_name stage_desc <<< "$stage_info"

    local dockerfile="$STAGES_DIR/${stage_num}-${stage_name}.Dockerfile"
    local image_tag="${IMAGE_BASE}:${stage_num}-${stage_name}"

    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  Stage $stage_num: $stage_name${NC}"
    echo -e "${CYAN}  $stage_desc${NC}"
    echo -e "${CYAN}========================================${NC}"

    # Determine base image for this stage
    local base_image=""
    if [ "$stage_num" == "00" ]; then
        base_image="ubuntu:22.04"
    else
        # Get previous stage
        local prev_num=$(printf "%02d" $((10#$stage_num - 1)))
        local prev_info="${STAGES[$prev_num]}"
        IFS=':' read -r prev_name prev_desc <<< "$prev_info"
        base_image="${IMAGE_BASE}:${prev_num}-${prev_name}"
    fi

    echo "Building from: $base_image"
    echo "Target image: $image_tag"

    # Build the stage
    local build_args=""
    if [ "$NO_CACHE" = true ]; then
        build_args="--no-cache"
    fi

    echo -e "${YELLOW}Building stage $stage_num...${NC}"

    if docker build \
        $build_args \
        --build-arg BASE_IMAGE="$base_image" \
        -t "$image_tag" \
        -f "$dockerfile" \
        .; then
        echo -e "${GREEN}✓ Stage $stage_num built successfully${NC}"

        # Push intermediate image if requested
        if [ "$PUSH_INTERMEDIATE" = true ] && [ "$stage_num" != "11" ]; then
            echo -e "${YELLOW}Pushing intermediate image...${NC}"
            docker tag "$image_tag" "$REGISTRY/$image_tag"
            docker push "$REGISTRY/$image_tag"
        fi

        return 0
    else
        echo -e "${RED}✗ Stage $stage_num build failed${NC}"
        return 1
    fi
}

# Function to test a stage
test_stage() {
    local stage_num="$1"
    local stage_info="${STAGES[$stage_num]}"
    IFS=':' read -r stage_name stage_desc <<< "$stage_info"

    echo -e "${YELLOW}Testing stage $stage_num...${NC}"

    if bash "$TESTS_DIR/test-stage.sh" "$stage_num" "$stage_name"; then
        echo -e "${GREEN}✓ Stage $stage_num tests passed${NC}"
        return 0
    else
        echo -e "${RED}✗ Stage $stage_num tests failed${NC}"
        return 1
    fi
}

# Main build process
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Jon-Babylon Staged Build System${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Configuration:"
echo "  Registry: $REGISTRY"
echo "  Base name: $IMAGE_BASE"
echo "  Version: $VERSION"
echo "  No cache: $NO_CACHE"
echo "  Push intermediate: $PUSH_INTERMEDIATE"
echo "  Stage range: $START_STAGE to $END_STAGE"
echo ""

# Track build status
STAGES_BUILT=0
STAGES_FAILED=0
TESTS_PASSED=0
TESTS_FAILED=0
BUILD_START_TIME=$(date +%s)

# Build each stage
for stage_num in $(seq -w "$START_STAGE" "$END_STAGE"); do
    STAGE_START_TIME=$(date +%s)

    # Build the stage
    if build_stage "$stage_num"; then
        ((STAGES_BUILT++))

        # Test the stage
        if test_stage "$stage_num"; then
            ((TESTS_PASSED++))
        else
            ((TESTS_FAILED++))
            if [ "$STOP_ON_FAILURE" = true ]; then
                echo -e "${RED}Stopping build due to test failure${NC}"
                break
            fi
        fi
    else
        ((STAGES_FAILED++))
        if [ "$STOP_ON_FAILURE" = true ]; then
            echo -e "${RED}Stopping build due to build failure${NC}"
            break
        fi
    fi

    STAGE_END_TIME=$(date +%s)
    STAGE_DURATION=$((STAGE_END_TIME - STAGE_START_TIME))
    echo "Stage $stage_num completed in ${STAGE_DURATION}s"
done

BUILD_END_TIME=$(date +%s)
BUILD_DURATION=$((BUILD_END_TIME - BUILD_START_TIME))

# Final tagging if all stages built
if [ "$STAGES_FAILED" -eq 0 ] && [ "$END_STAGE" -eq 11 ]; then
    echo ""
    echo -e "${YELLOW}Creating final tags...${NC}"

    # Tag final stage as latest and version
    docker tag "${IMAGE_BASE}:11-final" "${IMAGE_BASE}:latest"
    docker tag "${IMAGE_BASE}:11-final" "${IMAGE_BASE}:${VERSION}"

    if [ "$PUSH_INTERMEDIATE" = true ]; then
        docker tag "${IMAGE_BASE}:latest" "$REGISTRY/${IMAGE_BASE}:latest"
        docker tag "${IMAGE_BASE}:${VERSION}" "$REGISTRY/${IMAGE_BASE}:${VERSION}"

        echo -e "${YELLOW}Pushing final images...${NC}"
        docker push "$REGISTRY/${IMAGE_BASE}:latest"
        docker push "$REGISTRY/${IMAGE_BASE}:${VERSION}"
    fi
fi

# Summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Build Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Stages built:  ${GREEN}$STAGES_BUILT${NC}"
echo -e "Stages failed: ${RED}$STAGES_FAILED${NC}"
echo -e "Tests passed:  ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed:  ${RED}$TESTS_FAILED${NC}"
echo -e "Total time:    ${BUILD_DURATION}s"

if [ "$STAGES_FAILED" -eq 0 ] && [ "$TESTS_FAILED" -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Build completed successfully!${NC}"
    echo ""
    echo "Final image: ${IMAGE_BASE}:latest"
    echo ""
    echo "To run the final image:"
    echo "  docker run -it --rm -v \$(pwd):/workspace ${IMAGE_BASE}:latest"
    exit 0
else
    echo ""
    echo -e "${RED}✗ Build completed with errors${NC}"
    exit 1
fi
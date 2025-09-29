# Jon-Babylon Docker Image Makefile
# Targets: Ubuntu 22.04 ARM64 and AMD64

# Image configuration
IMAGE_NAME := jon-babylon
REGISTRY := ghcr.io/lpportorino
VERSION := $(shell date +%Y.%m.%d)
GIT_SHA := $(shell git rev-parse --short HEAD 2>/dev/null || echo "no-git")

# Architecture detection
ARCH := $(shell uname -m)
ifeq ($(ARCH),aarch64)
    PLATFORM := linux/arm64
    DOCKERFILE := Dockerfile.arm64
    TAG_SUFFIX := arm64
else ifeq ($(ARCH),arm64)
    PLATFORM := linux/arm64
    DOCKERFILE := Dockerfile.arm64
    TAG_SUFFIX := arm64
else
    PLATFORM := linux/amd64
    DOCKERFILE := Dockerfile.x86_64
    TAG_SUFFIX := amd64
endif

# ARM64 optimization flags
ARM64_FLAGS := --build-arg OPTFLAGS="-O3"

# Build configuration
DOCKER_BUILD := docker build
DOCKER_BUILDX := docker buildx build
BUILDX_FLAGS := --platform $(PLATFORM)

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

.PHONY: all help build build-arm64 build-amd64 build-multi test push clean

# Default target
all: build

# Help target
help:
	@echo "$(BLUE)Jon-Babylon Docker Image Builder$(NC)"
	@echo "$(GREEN)Supported Targets: ARM64 and AMD64$(NC)"
	@echo ""
	@echo "Available targets:"
	@echo "  $(YELLOW)make build$(NC)        - Build for current architecture ($(ARCH))"
	@echo "  $(YELLOW)make build-arm64$(NC)  - Build for ARM64"
	@echo "  $(YELLOW)make build-amd64$(NC)  - Build for AMD64 (testing only)"
	@echo "  $(YELLOW)make build-multi$(NC)  - Build for both architectures"
	@echo "  $(YELLOW)make test$(NC)         - Run comprehensive test suite"
	@echo "  $(YELLOW)make push$(NC)         - Push images to registry"
	@echo "  $(YELLOW)make clean$(NC)        - Clean up Docker resources"
	@echo ""
	@echo "Environment:"
	@echo "  Current arch: $(ARCH)"
	@echo "  Platform: $(PLATFORM)"
	@echo "  Dockerfile: $(DOCKERFILE)"

# Build for current architecture
build:
	@echo "$(BLUE)Building $(IMAGE_NAME) for $(PLATFORM)...$(NC)"
	@if [ "$(ARCH)" = "aarch64" ] || [ "$(ARCH)" = "arm64" ]; then \
		echo "$(GREEN)Building for ARM64...$(NC)"; \
		$(DOCKER_BUILD) $(ARM64_FLAGS) \
			-f $(DOCKERFILE) \
			-t $(IMAGE_NAME):latest \
			-t $(IMAGE_NAME):$(VERSION) \
			-t $(IMAGE_NAME):$(GIT_SHA) \
			.; \
	else \
		echo "$(YELLOW)Building AMD64 variant (testing only)...$(NC)"; \
		$(DOCKER_BUILD) \
			-f $(DOCKERFILE) \
			-t $(IMAGE_NAME):latest \
			-t $(IMAGE_NAME):$(VERSION) \
			-t $(IMAGE_NAME):$(GIT_SHA) \
			.; \
	fi

# Build specifically for ARM64
build-arm64: check-buildx
	@echo "$(GREEN)Building for ARM64...$(NC)"
	$(DOCKER_BUILDX) \
		--platform linux/arm64 \
		$(ARM64_FLAGS) \
		-f Dockerfile.arm64 \
		-t $(REGISTRY)/$(IMAGE_NAME):latest-arm64 \
		-t $(REGISTRY)/$(IMAGE_NAME):$(VERSION)-arm64 \
		-t $(REGISTRY)/$(IMAGE_NAME):$(GIT_SHA)-arm64 \
		--load \
		.

# Build for AMD64 (testing/development only)
build-amd64: check-buildx
	@echo "$(YELLOW)Building AMD64 variant (for testing only)...$(NC)"
	$(DOCKER_BUILDX) \
		--platform linux/amd64 \
		-f Dockerfile.x86_64 \
		-t $(REGISTRY)/$(IMAGE_NAME):latest-amd64 \
		-t $(REGISTRY)/$(IMAGE_NAME):$(VERSION)-amd64 \
		-t $(REGISTRY)/$(IMAGE_NAME):$(GIT_SHA)-amd64 \
		--load \
		.

# Build for both architectures
build-multi: check-buildx
	@echo "$(BLUE)Building multi-architecture images...$(NC)"
	@echo "$(GREEN)ARM64$(NC)"
	@echo "$(YELLOW)AMD64$(NC)"
	$(DOCKER_BUILDX) \
		--platform linux/arm64,linux/amd64 \
		-f docker/Dockerfile \
		-t $(REGISTRY)/$(IMAGE_NAME):latest \
		-t $(REGISTRY)/$(IMAGE_NAME):$(VERSION) \
		-t $(REGISTRY)/$(IMAGE_NAME):$(GIT_SHA) \
		--push \
		.

# Check if buildx is available
check-buildx:
	@if ! docker buildx version > /dev/null 2>&1; then \
		echo "$(RED)Docker buildx not found. Installing...$(NC)"; \
		docker buildx create --name jon-babylon-builder --use; \
	fi

# Run test suite
test: build
	@echo "$(BLUE)Running comprehensive test suite...$(NC)"
	@echo "Testing on $(PLATFORM)"
	@./run_all_tests.sh
	@echo "$(GREEN)All tests passed!$(NC)"

# Test ARM64 specific optimizations
test-arm64:
	@echo "$(BLUE)Testing ARM64 optimizations...$(NC)"
	@docker run --rm $(IMAGE_NAME):latest-arm64 \
		bash -c "echo 'Checking CPU features...'; \
		         cat /proc/cpuinfo | grep Features | head -1; \
		         echo 'Testing compiler optimizations...'; \
		         gcc -O3 -E -v - </dev/null 2>&1 | grep O3"

# Push images to registry
push: check-auth
	@echo "$(BLUE)Pushing images to $(REGISTRY)...$(NC)"
	@if [ "$(ARCH)" = "aarch64" ] || [ "$(ARCH)" = "arm64" ]; then \
		echo "$(GREEN)Pushing ARM64 image...$(NC)"; \
		docker push $(REGISTRY)/$(IMAGE_NAME):latest-arm64; \
		docker push $(REGISTRY)/$(IMAGE_NAME):$(VERSION)-arm64; \
		docker push $(REGISTRY)/$(IMAGE_NAME):$(GIT_SHA)-arm64; \
	else \
		echo "$(YELLOW)Pushing AMD64 image...$(NC)"; \
		docker push $(REGISTRY)/$(IMAGE_NAME):latest-amd64; \
		docker push $(REGISTRY)/$(IMAGE_NAME):$(VERSION)-amd64; \
		docker push $(REGISTRY)/$(IMAGE_NAME):$(GIT_SHA)-amd64; \
	fi

# Push multi-arch manifest
push-multi: check-auth
	@echo "$(BLUE)Pushing multi-arch manifest...$(NC)"
	docker manifest create $(REGISTRY)/$(IMAGE_NAME):latest \
		$(REGISTRY)/$(IMAGE_NAME):latest-arm64 \
		$(REGISTRY)/$(IMAGE_NAME):latest-amd64
	docker manifest push $(REGISTRY)/$(IMAGE_NAME):latest

# Check registry authentication
check-auth:
	@if ! docker pull $(REGISTRY)/$(IMAGE_NAME):latest > /dev/null 2>&1; then \
		echo "$(YELLOW)Please login to registry: docker login $(REGISTRY)$(NC)"; \
		exit 1; \
	fi

# Clean up Docker resources
clean:
	@echo "$(BLUE)Cleaning up Docker resources...$(NC)"
	@docker rmi $(IMAGE_NAME):latest 2>/dev/null || true
	@docker rmi $(IMAGE_NAME):$(VERSION) 2>/dev/null || true
	@docker rmi $(IMAGE_NAME):$(GIT_SHA) 2>/dev/null || true
	@docker system prune -f
	@echo "$(GREEN)Cleanup complete!$(NC)"

# Development helpers
shell:
	@echo "$(BLUE)Starting interactive shell in container...$(NC)"
	@docker run -it --rm \
		-v $(PWD):/workspace \
		-w /workspace \
		$(IMAGE_NAME):latest \
		/bin/bash

# Show image information
info:
	@echo "$(BLUE)Image Information:$(NC)"
	@docker images | grep $(IMAGE_NAME) || echo "No images found"
	@echo ""
	@echo "$(BLUE)Image Size:$(NC)"
	@docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep $(IMAGE_NAME) || echo "No images found"

# Build with script
build-script:
	@echo "$(BLUE)Running build script...$(NC)"
	@./build-local.sh

# Version check
versions:
	@echo "$(BLUE)Checking tool versions in image...$(NC)"
	@docker run --rm $(IMAGE_NAME):latest /scripts/check_versions.sh

# Architecture info
arch-info:
	@echo "$(GREEN)Architecture Information:$(NC)"
	@echo ""
	@echo "Supported Architectures:"
	@echo "  - ARM64 (aarch64)"
	@echo "  - AMD64 (x86_64)"
	@echo ""
	@echo "Build Optimization:"
	@echo "  - Compiler: -O3"

.DEFAULT_GOAL := help
# Troubleshooting Guide

This guide helps resolve common issues when building or using the Jon-Babylon Docker image.

## 🚨 Common Issues

### 1. Build Failures

#### Issue: "Docker buildx not found"
**Solution:**
```bash
# Install buildx plugin
docker buildx version

# If not available, the build script will fall back to regular docker build
# Or use the Makefile instead:
make build
```

#### Issue: "No space left on device"
**Solution:**
```bash
# Clean up Docker resources
docker system prune -a --volumes

# Check available space (need ~10GB free)
df -h /

# Remove old images
docker images | grep jon-babylon | awk '{print $3}' | xargs docker rmi
```

#### Issue: Build takes too long (>1 hour)
**Solution:**
```bash
# Use quick build mode
./build-local.sh --quick

# Or build specific stages only
docker build --target base -f docker/stages/00-base.Dockerfile -t jon-babylon:base .

# Use cache effectively
./build-local.sh  # Subsequent builds use cache
```

#### Issue: Network timeout during package downloads
**Solution:**
```bash
# Retry with increased timeout
export DOCKER_BUILDKIT_PROGRESS=plain
./build-local.sh --no-cache

# Or use different mirrors in Dockerfile
# Edit Dockerfile.x86_64 or Dockerfile.arm64 to add mirror
RUN sed -i 's/archive.ubuntu.com/mirror.example.com/g' /etc/apt/sources.list
```

### 2. Architecture Issues

#### Issue: "Unknown architecture" error
**Solution:**
```bash
# Check your architecture
uname -m

# For Apple Silicon Macs (M1/M2), use:
docker build --platform linux/arm64 -f Dockerfile.arm64 -t jon-babylon:arm64 .

# Force specific architecture
DOCKER_DEFAULT_PLATFORM=linux/amd64 ./build-local.sh
```

#### Issue: ARM64 optimizations on non-Orin hardware
**Solution:**
```bash
# Build without Orin-specific optimizations
docker build -f Dockerfile.arm64 \
  --build-arg MARCH=armv8-a \
  --build-arg MTUNE=generic \
  -t jon-babylon:arm64-generic .
```

### 3. Runtime Issues

#### Issue: "Permission denied" when accessing mounted volumes
**Solution:**
```bash
# Run with user permissions
docker run --user $(id -u):$(id -g) \
  -v $(pwd):/workspace \
  jon-babylon:latest bash

# Or fix permissions inside container
docker run -v $(pwd):/workspace jon-babylon:latest \
  bash -c "sudo chown -R developer:developer /workspace"
```

#### Issue: Tools not found in PATH
**Solution:**
```bash
# Check PATH inside container
docker run jon-babylon:latest bash -c 'echo $PATH'

# Source environment files
docker run jon-babylon:latest bash -c '
  source /etc/profile
  source ~/.bashrc
  YOUR_COMMAND
'
```

#### Issue: Python/Node packages not found
**Solution:**
```bash
# Python: Check virtual environment
docker run jon-babylon:latest bash -c '
  python3 -m venv /tmp/venv
  source /tmp/venv/bin/activate
  pip install YOUR_PACKAGE
'

# Node: Check npm prefix
docker run jon-babylon:latest bash -c '
  npm config get prefix
  npm install -g YOUR_PACKAGE
'
```

### 4. Testing Issues

#### Issue: Tests fail but tools work
**Solution:**
```bash
# Run specific test
./tests/python/run_test.sh

# Debug test script
bash -x ./tests/java/run_test.sh

# Run test inside container
docker run -v $(pwd)/tests:/tests jon-babylon:latest \
  bash -c "cd /tests/rust && ./run_test.sh"
```

#### Issue: Nuitka compilation fails
**Solution:**
```bash
# Check Python version
docker run jon-babylon:latest python3 --version

# Install missing dependencies
docker run jon-babylon:latest bash -c '
  sudo apt-get update
  sudo apt-get install -y python3-dev patchelf ccache
  python3 -m nuitka --version
'
```

### 5. CI/CD Issues

#### Issue: GitHub Actions failing
**Solution:**
```yaml
# Check runner architecture in workflow
runs-on: ubuntu-22.04      # For AMD64
runs-on: ubuntu-22.04-arm  # For ARM64

# Enable debug logging
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

#### Issue: Can't push to registry
**Solution:**
```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Check permissions in repository settings
# Settings → Actions → General → Workflow permissions
# Enable "Read and write permissions"
```

### 6. Performance Issues

#### Issue: Slow builds on ARM64
**Solution:**
```bash
# Use native ARM64 hardware when possible
# Or use QEMU with multi-core
docker buildx create --use \
  --driver docker-container \
  --driver-opt cpus=4

# Reduce optimization level for faster builds
docker build --build-arg OPTFLAGS="-O2" -f Dockerfile.arm64 .
```

#### Issue: High memory usage
**Solution:**
```bash
# Limit memory usage
docker build --memory=4g --memory-swap=4g -f Dockerfile.x86_64 .

# Or configure in daemon.json
cat > /etc/docker/daemon.json << EOF
{
  "default-ulimits": {
    "memlock": {
      "Hard": 4294967296,
      "Soft": 4294967296
    }
  }
}
EOF
```

## 🔍 Debugging Techniques

### 1. Verbose Build Output
```bash
# Show detailed build progress
docker buildx build --progress=plain -f Dockerfile.x86_64 .

# Export build logs
./build-local.sh 2>&1 | tee build.log
```

### 2. Interactive Debugging
```bash
# Start container in debug mode
docker run -it --rm --entrypoint /bin/bash jon-babylon:latest

# Debug specific stage
docker run -it --rm jon-babylon:02-java /bin/bash
```

### 3. Layer Inspection
```bash
# Check image layers
docker history jon-babylon:latest

# Inspect specific layer
docker inspect jon-babylon:latest | jq '.[0].RootFS.Layers'

# Check image size breakdown
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep jon-babylon
```

### 4. Build Cache Analysis
```bash
# Check cache usage
docker buildx du

# Clear specific cache
docker buildx prune --filter type=exec.cachemount

# Monitor cache during build
watch -n 1 'docker buildx du --verbose'
```

## 🛠️ Advanced Solutions

### Custom Build Configuration

Create a custom build configuration:
```bash
cat > custom-build.env << EOF
# Architecture settings
export DOCKER_DEFAULT_PLATFORM=linux/arm64
export BUILDX_NO_DEFAULT_LOAD=1

# Optimization flags
export MARCH=armv8.2-a
export MTUNE=cortex-a78
export OPTFLAGS="-O3 -march=armv8.2-a -mtune=cortex-a78"

# Build behavior
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
EOF

source custom-build.env
./build-local.sh
```

### Partial Builds

Build only what you need:
```bash
# Just Python tools
docker build --target 05-python \
  -f docker/stages/05-python.Dockerfile \
  -t jon-babylon:python-only .

# Just web tools
docker build --target 10-web-tools \
  -f docker/stages/10-web-tools.Dockerfile \
  -t jon-babylon:web-only .
```

### Recovery from Failed Builds

```bash
# Save progress
docker commit $(docker ps -lq) jon-babylon:recovery

# Continue from saved point
docker build --cache-from jon-babylon:recovery \
  -f Dockerfile.x86_64 \
  -t jon-babylon:latest .
```

## 📞 Getting Help

If these solutions don't resolve your issue:

1. **Check existing issues**: [GitHub Issues](https://github.com/lpportorino/jettison-stack-of-babel/issues)
2. **Open new issue** with:
   - Your architecture (`uname -m`)
   - Docker version (`docker --version`)
   - Build command used
   - Error messages (full output)
   - Contents of `docker info`
3. **Join discussions**: [GitHub Discussions](https://github.com/lpportorino/jettison-stack-of-babel/discussions)

## 🔗 Related Documentation

- [README.md](README.md) - General usage
- [CONTRIBUTING.md](CONTRIBUTING.md) - Development guide
- [TODO.md](TODO.md) - Project roadmap
- [docker/BUILD-GUIDE.md](docker/BUILD-GUIDE.md) - Build system details
- [docker/STAGES.md](docker/STAGES.md) - Stage architecture

## 💡 Prevention Tips

1. **Keep Docker updated**: Version 20.10+ with buildx
2. **Monitor disk space**: Keep 10GB+ free
3. **Use cache wisely**: Don't use `--no-cache` unless necessary
4. **Test incrementally**: Use `--quick` mode first
5. **Check prerequisites**: Run `./build-local.sh --help`
6. **Follow architecture guidelines**: ARM64 for production, AMD64 for testing

---

**Last Updated**: September 2025
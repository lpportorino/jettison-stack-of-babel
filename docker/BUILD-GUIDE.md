# Jon-Babylon Build Guide

## Quick Start

### Simple Full Build
```bash
# Build everything with the staged system
./scripts/build-staged.sh

# Or use the original monolithic Dockerfile
docker build -f docker/Dockerfile -t jon-babylon .
```

## Staged Build System

We have 12 sequential stages that build on each other:

```
00-base → 01-build-essentials → 02-java → 03-kotlin → 04-clojure →
05-python → 06-clang → 07-rust → 08-nodejs → 09-build-tools →
10-web-tools → 11-final
```

### Benefits
- **Test after each stage** - Fail fast if something breaks
- **Rebuild from any stage** - Don't start from scratch
- **Clear error messages** - Know exactly what failed
- **Good caching** - Only rebuild what changed

### Usage

```bash
# Full build with testing
./scripts/build-staged.sh

# Rebuild from Python stage onward (if earlier stages are OK)
./scripts/build-staged.sh --start-stage 05

# Build without cache (fresh build)
./scripts/build-staged.sh --no-cache

# Continue even if a test fails
./scripts/build-staged.sh --continue-on-failure
```

## When to Use What

### Use Staged Build When:
- Developing and testing tool installations
- Debugging build failures
- Updating specific tools
- You want detailed progress feedback

### Use Monolithic Build When:
- You just want the final image quickly
- You're confident everything works
- Building for production release

## Testing

Each stage has its own test:

```bash
# Test a specific stage
./docker/tests/test-stage.sh 05 python

# Test the final image
docker run --rm jon-babylon:latest /scripts/check_versions.sh

# Run web stack tests
docker run --rm -v $(pwd)/tests/web:/workspace jon-babylon:latest \
  bash -c "cd /workspace && ./run_test.sh"
```

## Common Tasks

### Update a Single Tool
```bash
# 1. Edit the installation script
vim tools/python/install/install.sh

# 2. Rebuild from that stage
./scripts/build-staged.sh --start-stage 05

# 3. Test it
./docker/tests/test-stage.sh 05 python
```

### Add a New Tool
```bash
# 1. Create installation script
mkdir -p tools/newtool/install
vim tools/newtool/install/install.sh

# 2. Add to appropriate stage Dockerfile
vim docker/stages/10-web-tools.Dockerfile

# 3. Rebuild and test
./scripts/build-staged.sh --start-stage 10
```

### Debug a Failed Build
```bash
# 1. Check which stage failed
./scripts/build-staged.sh

# 2. Run that stage interactively
docker run -it jon-babylon:04-clojure /bin/bash

# 3. Test commands manually
clojure --version
```

## Image Management

```bash
# List all jon-babylon images
docker images | grep jon-babylon

# Remove intermediate stages (keep final only)
docker images | grep jon-babylon | grep -v "latest\|final" | \
  awk '{print $3}' | xargs docker rmi

# Check image size
docker images jon-babylon:latest
```

## Tips

1. **Always run tests** - Don't skip the test phase
2. **Use caching** - Builds are much faster with cache
3. **Start from failure point** - Use `--start-stage` after fixing issues
4. **Keep it simple** - The sequential build works great

## Build Times

- **Full build**: ~25 minutes
- **Incremental** (with cache): ~3-5 minutes
- **Single stage rebuild**: ~1-2 minutes

## Troubleshooting

### Build Fails
```bash
# Check the error message for the stage number
# Rebuild with more verbose output
docker build --progress=plain -f docker/stages/05-python.Dockerfile .
```

### Tests Fail
```bash
# Run the test manually to see full output
docker run --rm jon-babylon:05-python python3 --version
```

### Out of Space
```bash
# Clean up Docker
docker system prune -a
```

## Final Notes

The staged sequential build is reliable and maintainable. It's not the fastest possible approach, but it's the most practical for a complex polyglot image like jon-babylon.
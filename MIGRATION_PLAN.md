# Container Split Migration Plan

## Overview
Split the monolithic jon-babylon container into focused, smaller containers for better maintainability, faster builds, and parallel CI/CD.

## Container Architecture

### 1. Base Container (jon-babylon-base)
- Ubuntu 22.04 base
- Common system tools (git, curl, wget, sudo, etc.)
- Developer user setup
- Shared by all other containers

### 2. JVM Container (jon-babylon-jvm)
**Platforms:** linux/amd64, linux/arm64
**From:** jon-babylon-base
**Tools:**
- [ ] Java 25 LTS (via SDKMAN)
- [ ] Kotlin 2.2.20 (via SDKMAN)
- [ ] Clojure 1.12.3
- [ ] Maven 3.9.11 (via SDKMAN)
- [ ] Gradle 9.1.0 (via SDKMAN)
- [ ] Leiningen 2.12.0 (via SDKMAN)
- [ ] clj-kondo
**Tests:**
- [ ] Java Maven build
- [ ] Java Gradle build
- [ ] Kotlin Gradle build
- [ ] Clojure deps.edn
- [ ] Leiningen project

### 3. Clang Container (jon-babylon-clang)
**Platforms:** linux/amd64, linux/arm64
**From:** jon-babylon-base
**Tools:**
- [ ] LLVM/Clang 21
- [ ] clang
- [ ] clang++
- [ ] clang-format
- [ ] clang-tidy
- [ ] CMake
- [ ] Make
- [ ] Build essentials
**Tests:**
- [ ] C compilation
- [ ] C++ compilation
- [ ] clang-format check
- [ ] clang-tidy analysis

### 4. Python Container (jon-babylon-python)
**Platforms:** linux/amd64, linux/arm64
**From:** jon-babylon-clang (needs clang for Nuitka)
**Tools:**
- [ ] Python 3.13.7 (via pyenv)
- [ ] Python 3.12.8 (via pyenv)
- [ ] pip/setuptools/wheel
- [ ] Nuitka 2.7.16
- [ ] flake8
- [ ] black
- [ ] mypy
- [ ] ruff
- [ ] pytest
**Tests:**
- [ ] Python script execution
- [ ] Nuitka compilation
- [ ] Linting (flake8, ruff)
- [ ] Type checking (mypy)
- [ ] Testing framework (pytest)

### 5. Rust Container (jon-babylon-rust)
**Platforms:** linux/amd64, linux/arm64
**From:** jon-babylon-base
**Tools:**
- [ ] Rust stable (via rustup)
- [ ] Cargo
- [ ] rustfmt
- [ ] clippy
- [ ] cargo-audit
- [ ] cargo-outdated
- [ ] sccache (optional)
**Tests:**
- [ ] Cargo build (debug & release)
- [ ] Cargo test
- [ ] Clippy analysis
- [ ] rustfmt check

### 6. Go Container (jon-babylon-go)
**Platforms:** linux/amd64, linux/arm64
**From:** jon-babylon-base
**Tools:**
- [ ] Go 1.25.1
- [ ] golangci-lint
- [ ] go-task
- [ ] air (hot reload)
**Tests:**
- [ ] Go build
- [ ] Go test
- [ ] Go fmt check
- [ ] golangci-lint check

### 7. Web Container (jon-babylon-web)
**Platforms:** linux/amd64, linux/arm64
**From:** jon-babylon-base
**Tools:**
- [ ] Node.js 22.20.0
- [ ] npm (latest)
- [ ] yarn (via corepack)
- [ ] pnpm (via corepack)
- [ ] Bun 1.1.45
- [ ] TypeScript 5.9.2
- [ ] esbuild
- [ ] Vite
- [ ] Prettier
- [ ] ESLint
- [ ] @lit/localize
- [ ] tsx (TypeScript executor)
**Tests:**
- [ ] Node.js script execution
- [ ] TypeScript compilation
- [ ] npm install & build
- [ ] yarn install & build
- [ ] pnpm install & build
- [ ] Bun runtime test
- [ ] esbuild bundling
- [ ] ESLint check
- [ ] Prettier format check

## Implementation Steps

### Phase 1: Setup Infrastructure
- [ ] Create new directory structure
  - [ ] dockerfiles/base/
  - [ ] dockerfiles/jvm/
  - [ ] dockerfiles/clang/
  - [ ] dockerfiles/python/
  - [ ] dockerfiles/rust/
  - [ ] dockerfiles/go/
  - [ ] dockerfiles/web/
- [ ] Move relevant install scripts to each directory
- [ ] Create docker-compose.yml for local testing
- [ ] Update .github/workflows/ for parallel builds

### Phase 2: Base Container
- [ ] Create Dockerfile.base
- [ ] Setup common dependencies
- [ ] Create developer user
- [ ] Test base image build

### Phase 3: Independent Containers (Parallel)
Can be built in parallel:
- [ ] JVM container
- [ ] Clang container
- [ ] Rust container
- [ ] Go container
- [ ] Web container

### Phase 4: Dependent Container
After Clang is ready:
- [ ] Python container (depends on Clang)

### Phase 5: Testing
- [ ] Create test suite for each container
- [ ] Run tests locally
- [ ] Verify all tools are present and working

### Phase 6: CI/CD Update
- [ ] Update GitHub Actions workflow
- [ ] Setup parallel builds
- [ ] Configure container registry pushes
- [ ] Add matrix strategy for all containers

### Phase 7: Documentation
- [ ] Update README with new container structure
- [ ] Document how to use each container
- [ ] Create examples for each use case
- [ ] Migration guide from monolithic to split containers

## Benefits
1. **Parallel Builds**: Most containers can build simultaneously
2. **Smaller Images**: Each image only contains what it needs
3. **Faster CI/CD**: Parallel testing and deployment
4. **Better Caching**: Changes to one toolchain don't invalidate others
5. **Modularity**: Use only the containers you need
6. **Easier Maintenance**: Focused, single-purpose containers

## Migration Checklist
- [ ] All tools accounted for in new containers
- [ ] All tests migrated and passing
- [ ] GitHub Actions updated and working
- [ ] Documentation updated
- [ ] Old monolithic Dockerfiles archived
- [ ] Container registry cleaned up

## Container Naming Convention
```
ghcr.io/lpportorino/jon-babylon-<type>:<version>-<arch>
```
Examples:
- `ghcr.io/lpportorino/jon-babylon-jvm:latest-amd64`
- `ghcr.io/lpportorino/jon-babylon-python:1.0.0-arm64`
- `ghcr.io/lpportorino/jon-babylon-web:latest-amd64`

## Test Coverage Matrix

| Container | AMD64 | ARM64 | Tests Required |
|-----------|-------|-------|----------------|
| Base      | ✓     | ✓     | Basic shell    |
| JVM       | ✓     | ✓     | Java, Kotlin, Clojure |
| Clang     | ✓     | ✓     | C, C++ compilation |
| Python    | ✓     | ✓     | Python, Nuitka |
| Rust      | ✓     | ✓     | Cargo build/test |
| Go        | ✓     | ✓     | Go build/test |
| Web       | ✓     | ✓     | Node, TS, Bun |

## Notes
- Keep install scripts modular and reusable
- Use multi-stage builds where beneficial
- Leverage BuildKit cache mounts
- Consider using docker-bake.hcl for complex builds
- Tag containers with both version and latest
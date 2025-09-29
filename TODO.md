# Jettison Stack of Babel - Development TODO

## Overview
Build a universal polyglot Docker image (`jon-babylon`) containing all language toolchains for Jettison project development. The image will be automatically built for ARM64 via GitHub Actions and published to GitHub Container Registry.

## Tools to Include

### Languages & Compilers
- [ ] **OpenJDK 21 LTS** (via Ubuntu repos - stable for production)
- [ ] **Kotlin** (latest via snap in Docker)
- [ ] **Clojure** (latest via official script)
- [ ] **Python 3.12+** (via pyenv for version management)
- [ ] **Nuitka** (Python compiler via pip)
- [ ] **Node.js 22 LTS** (via NodeSource repository)
- [ ] **TypeScript** (via npm)
- [ ] **Bun** (latest via official script)
- [ ] **LLVM/Clang 21** (via LLVM APT repository)

### Build Tools
- [ ] **Leiningen** (for Clojure projects)
- [ ] **Maven** (for Java/Kotlin)
- [ ] **Gradle** (for Java/Kotlin)
- [ ] **npm/yarn/pnpm** (for JavaScript)
- [ ] **esbuild** (for fast JS/TS bundling)

### Web Stack Tools
- [ ] **@lit/localize** (for i18n)
- [ ] **Prettier** (code formatting)
- [ ] **ESLint** (JavaScript linting)

## Phase 1: Local Development & Testing (x86_64)

### 1.1 Repository Setup
- [ ] Create initial repository structure
  - [ ] `Dockerfile.x86_64` for local testing
  - [ ] `Dockerfile.arm64` for production
  - [ ] `scripts/` directory for build scripts
  - [ ] `tests/` directory for validation tests
  - [ ] `.github/workflows/` for CI/CD

### 1.2 Version Detection Scripts
- [ ] Create `scripts/check_versions.sh`
  - [ ] Detect installed versions of all tools
  - [ ] Compare against expected minimum versions
  - [ ] Output JSON report for CI validation

### 1.3 Test Projects
- [ ] Create minimal test project for each language
  - [ ] `tests/java/` - Simple Java 21 project
  - [ ] `tests/kotlin/` - Kotlin console app
  - [ ] `tests/clojure/` - Basic Clojure project with deps.edn
  - [ ] `tests/python/` - Python project to compile with Nuitka
  - [ ] `tests/typescript/` - TypeScript project with esbuild
  - [ ] `tests/web/` - Web project with Lit localization

### 1.4 Local Docker Build (x86_64)
- [ ] Write `Dockerfile.x86_64` with:
  - [ ] Base: `ubuntu:22.04`
  - [ ] Add all APT repositories (LLVM, NodeSource)
  - [ ] Install system dependencies
  - [ ] Install language toolchains
  - [ ] Configure pyenv with Python 3.12
  - [ ] Install global npm packages
  - [ ] Set up environment variables

### 1.5 Local Testing Framework
- [ ] Create `scripts/test_local.sh`
  - [ ] Build x86_64 image
  - [ ] Run version checks
  - [ ] Build all test projects
  - [ ] Validate outputs
  - [ ] Generate test report

## Phase 2: ARM64 Production Build

### 2.1 ARM64 Dockerfile
- [ ] Adapt `Dockerfile.x86_64` → `Dockerfile.arm64`
  - [ ] Verify all tools support ARM64
  - [ ] Adjust download URLs for ARM64 binaries
  - [ ] Test snap packages work in Docker on ARM64

### 2.2 Multi-stage Build Optimization
- [ ] Implement multi-stage Dockerfile
  - [ ] Stage 1: Build dependencies
  - [ ] Stage 2: Runtime tools only
  - [ ] Minimize final image size

### 2.3 Build Script
- [ ] Create `scripts/build.sh`
  - [ ] Detect architecture
  - [ ] Select appropriate Dockerfile
  - [ ] Tag with version and architecture
  - [ ] Generate SBOM (Software Bill of Materials)

## Phase 3: GitHub Actions CI/CD

### 3.1 GitHub Actions Workflow Setup
- [ ] Create `.github/workflows/build-and-push.yml`
  - [ ] Trigger on push to main
  - [ ] Use `ubuntu-22.04-arm` runner for ARM64
  - [ ] Set up Docker Buildx for multi-arch
  - [ ] Configure GITHUB_TOKEN for package registry

### 3.2 Build Pipeline
- [ ] Check out code
- [ ] Set up QEMU for ARM64 emulation (fallback)
- [ ] Set up Docker Buildx
- [ ] Log in to GitHub Container Registry
- [ ] Build ARM64 image
- [ ] Run version validation tests
- [ ] Build test projects in container
- [ ] Push to ghcr.io only if all tests pass

### 3.3 Version Tagging Strategy
- [ ] Tag images with:
  - [ ] `latest` for most recent build
  - [ ] `YYYY.MM.DD` for date-based versions
  - [ ] `YYYY.MM.DD-<short-sha>` for specific commits
  - [ ] Architecture suffix: `-arm64` or `-amd64`

### 3.4 Automated Testing
- [ ] Create `.github/workflows/test.yml`
  - [ ] Run on PR creation/update
  - [ ] Build image without pushing
  - [ ] Execute full test suite
  - [ ] Post test results as PR comment

## Phase 4: Documentation & Integration

### 4.1 Documentation
- [ ] Write comprehensive `README.md`
  - [ ] Installation instructions
  - [ ] Available tools and versions
  - [ ] Usage examples
  - [ ] Build instructions
  - [ ] Troubleshooting guide

### 4.2 Usage Scripts
- [ ] Create `scripts/run.sh` wrapper
  - [ ] Auto-pull latest image
  - [ ] Mount current directory
  - [ ] Set up proper user permissions
  - [ ] Forward environment variables

### 4.3 Integration with Jettison
- [ ] Update Jettison build scripts to use jon-babylon
- [ ] Remove redundant tool installations from host
- [ ] Update developer documentation

## Phase 5: Monitoring & Maintenance

### 5.1 Dependency Updates
- [ ] Set up Dependabot for:
  - [ ] Base image updates
  - [ ] GitHub Actions updates
  - [ ] Security patches

### 5.2 Version Monitoring
- [ ] Create scheduled workflow to check for new tool versions
- [ ] Auto-create PRs for tool updates
- [ ] Maintain compatibility matrix

### 5.3 Security Scanning
- [ ] Enable GitHub security scanning
- [ ] Run Trivy/Grype on built images
- [ ] Generate and publish security reports

## Installation Methods Summary

### Via APT Repositories
- **Clang/LLVM 21**: LLVM official APT repository
- **OpenJDK 21**: Ubuntu universe repository
- **Node.js 22**: NodeSource repository

### Via Official Scripts
- **Clojure**: Official installer script
- **Bun**: Official installation script
- **pyenv**: Git clone method

### Via Package Managers
- **Kotlin**: Snap package (in Docker)
- **Nuitka**: pip install
- **TypeScript, ESLint, Prettier**: npm install -g

### Via Binary Downloads
- **Maven**: Official Apache binary
- **Gradle**: Official Gradle binary

## Expected Versions (2025)
- OpenJDK: 21.0.x LTS
- Kotlin: 2.1.x
- Clojure: 1.12.x
- Python: 3.12.x / 3.13.x
- Node.js: 22.x.x LTS
- TypeScript: 5.x.x
- Clang/LLVM: 21.x.x
- Nuitka: 2.x.x

## Success Criteria
- [ ] All tools install successfully on both x86_64 and ARM64
- [ ] Test projects build without errors
- [ ] Image size < 3GB
- [ ] Build time < 30 minutes on GitHub Actions
- [ ] All version checks pass
- [ ] Image pulls and runs on target Jettison hardware

## Notes
- Prioritize official repositories and package managers over building from source
- Use LTS versions where available for stability
- Ensure all tools work correctly on ARM64 architecture
- Keep image layers optimized for caching
- Document any architecture-specific workarounds
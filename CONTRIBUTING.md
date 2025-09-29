# Contributing to Jettison Stack of Babel

Thank you for your interest in contributing to the Jon-Babylon Docker image! This polyglot development environment is crucial for the Jettison project, and we welcome contributions that improve its functionality, performance, or documentation.

## 🎯 Primary Target Platform

Please note that our **primary target is NVIDIA AGX Orin (ARM64)**. All optimizations and features should prioritize this platform while maintaining compatibility with AMD64 for development/testing.

## 📋 Before You Begin

1. Check the [TODO.md](TODO.md) for planned features and current progress
2. Review existing [issues](https://github.com/lpportorino/jettison-stack-of-babel/issues)
3. Read the [README.md](README.md) for architecture and build information
4. Ensure your contribution aligns with the project goals

## 🔧 Development Setup

### Prerequisites

- Docker 20.10+ with buildx support
- Git
- 10GB+ free disk space
- For ARM64 testing: Access to NVIDIA Orin or ARM64 hardware

### Local Development

1. Fork and clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/jettison-stack-of-babel.git
cd jettison-stack-of-babel
```

2. Build locally using the universal script:
```bash
./build-local.sh --quick  # Quick build for testing
```

3. Run tests:
```bash
./run_all_tests.sh
```

## 🏗️ Architecture Guidelines

### Adding New Tools

When adding a new tool or language:

1. **Create installation script**:
```bash
# Create directory structure
mkdir -p tools/newtool/install
mkdir -p tools/newtool/test

# Create installation script
cat > tools/newtool/install/install.sh << 'EOF'
#!/bin/bash
set -e
echo "=== Installing NewTool ==="
# Installation commands here
EOF
chmod +x tools/newtool/install/install.sh
```

2. **Add to appropriate Docker stage**:
   - Identify the correct stage (01-11) in `docker/stages/`
   - Add installation commands to the Dockerfile
   - Consider ARM64 optimizations for NVIDIA Orin

3. **Create tests**:
```bash
# Create test directory
mkdir -p tests/newtool
cat > tests/newtool/run_test.sh << 'EOF'
#!/bin/bash
set -e
echo "=== Testing NewTool ==="
newtool --version
# Add comprehensive tests
EOF
chmod +x tests/newtool/run_test.sh
```

4. **Update documentation**:
   - Add tool to README.md tools list
   - Update TODO.md if completing a planned feature
   - Document any special configurations

### ARM64 Optimizations

For NVIDIA Orin optimizations:

```dockerfile
# Use these flags for compilation
ENV CFLAGS="-O3 -march=armv8.2-a -mtune=cortex-a78"
ENV CXXFLAGS="-O3 -march=armv8.2-a -mtune=cortex-a78"
ENV RUSTFLAGS="-C target-cpu=cortex-a78 -C opt-level=3"
```

## 📝 Contribution Process

### 1. Small Changes (Documentation, Typos)

- Create a pull request directly with your changes
- Ensure markdown files are properly formatted
- Update the "Last Updated" date in TODO.md if applicable

### 2. Bug Fixes

- Open an issue describing the bug
- Create a pull request referencing the issue
- Include test cases that verify the fix
- Test on both ARM64 and AMD64 if possible

### 3. New Features

- Open an issue for discussion first
- Create a detailed implementation plan
- Submit a pull request with:
  - Implementation
  - Tests
  - Documentation updates
  - TODO.md updates

### 4. Tool Updates

- Test the new version thoroughly
- Check for breaking changes
- Update version in documentation
- Ensure all tests pass

## 🧪 Testing Requirements

All contributions must:

1. **Pass existing tests**:
```bash
./run_all_tests.sh
```

2. **Include new tests** for new features:
```bash
./tests/YOUR_TOOL/run_test.sh
```

3. **Build successfully**:
```bash
./build-local.sh --quick
```

4. **Work on mounted volumes**:
```bash
docker run -v $(pwd):/workspace jon-babylon:latest YOUR_COMMAND
```

## 📊 Code Standards

### Shell Scripts

- Use `#!/bin/bash` shebang
- Include `set -e` for error handling
- Add descriptive echo statements
- Use consistent indentation (2 spaces)
- Include error messages and exit codes

### Dockerfiles

- Follow multi-stage best practices
- Minimize layer count
- Clean package caches
- Use `--no-install-recommends` for apt
- Document each stage's purpose

### Documentation

- Use clear, concise language
- Include code examples
- Update relevant sections
- Maintain consistent formatting
- Add table of contents for long documents

## 🔄 Pull Request Process

1. **Create a descriptive PR title**:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation
   - `chore:` for maintenance

2. **Include in PR description**:
   - What changes were made
   - Why they were necessary
   - How they were tested
   - Any breaking changes

3. **Checklist**:
   - [ ] Tests pass
   - [ ] Documentation updated
   - [ ] Works on ARM64 (if applicable)
   - [ ] Works on AMD64
   - [ ] No security vulnerabilities introduced

4. **Review process**:
   - PR will be reviewed within 48 hours
   - Address feedback promptly
   - Maintain a respectful discussion

## 🚀 Release Process

Releases follow semantic versioning:

- **Major**: Breaking changes
- **Minor**: New features
- **Patch**: Bug fixes

Tagged releases trigger automatic builds and pushes to GitHub Container Registry.

## 🆘 Getting Help

- Open an [issue](https://github.com/lpportorino/jettison-stack-of-babel/issues) for bugs
- Use [discussions](https://github.com/lpportorino/jettison-stack-of-babel/discussions) for questions
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Review the [TODO.md](TODO.md) for project roadmap

## 📜 Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive criticism
- Respect differing opinions
- Report unacceptable behavior to maintainers

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project.

## 🙏 Recognition

Contributors will be recognized in:
- GitHub contributors list
- Release notes for significant contributions
- Special mentions for major features

Thank you for contributing to Jon-Babylon! 🗼
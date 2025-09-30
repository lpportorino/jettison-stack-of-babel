#!/bin/bash
# LLVM/Clang 21 Installation Script
# Official LLVM APT repository

set -e

echo "=== Installing LLVM/Clang 21 ==="

# Detect architecture and Ubuntu version
ARCH=$(uname -m)
UBUNTU_VERSION=$(lsb_release -cs)
LLVM_VERSION=21

echo "Architecture: $ARCH"
echo "Ubuntu Version: $UBUNTU_VERSION"

# Install prerequisites
apt-get update
apt-get install -y wget software-properties-common gnupg

# Add LLVM APT repository
wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
add-apt-repository "deb http://apt.llvm.org/$UBUNTU_VERSION/ llvm-toolchain-$UBUNTU_VERSION-$LLVM_VERSION main"
apt-get update

# Install LLVM/Clang packages
apt-get install -y \
    clang-$LLVM_VERSION \
    clang-tools-$LLVM_VERSION \
    clang-format-$LLVM_VERSION \
    clang-tidy-$LLVM_VERSION \
    clangd-$LLVM_VERSION \
    lldb-$LLVM_VERSION \
    lld-$LLVM_VERSION \
    llvm-$LLVM_VERSION-dev \
    llvm-$LLVM_VERSION-tools \
    llvm-$LLVM_VERSION-runtime \
    libclang-$LLVM_VERSION-dev \
    libclang-common-$LLVM_VERSION-dev \
    libclang-cpp$LLVM_VERSION-dev \
    libclang1-$LLVM_VERSION \
    libc++-$LLVM_VERSION-dev \
    libc++abi-$LLVM_VERSION-dev \
    libclang-rt-$LLVM_VERSION-dev \
    libomp-$LLVM_VERSION-dev

# Set up alternatives
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-$LLVM_VERSION 100
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-$LLVM_VERSION 100
update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-$LLVM_VERSION 100
update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-$LLVM_VERSION 100
update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-$LLVM_VERSION 100
update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-$LLVM_VERSION 100
update-alternatives --install /usr/bin/lld lld /usr/bin/lld-$LLVM_VERSION 100

echo "✓ LLVM/Clang $LLVM_VERSION installed successfully"
clang --version
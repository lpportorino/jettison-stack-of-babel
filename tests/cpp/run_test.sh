#!/bin/bash
set -e

echo "=== Testing C++ compilation and tools ==="

# Test Clang++ version
echo "Clang++ version:"
clang++ --version

# Compile the test program
echo ""
echo "Compiling C++ test program..."
clang++ -std=c++20 -o test test.cpp

# Run the test program
echo "Running C++ test program..."
./test

# Test clang-format
echo ""
echo "Testing clang-format..."
clang-format --version

# Check formatting (dry-run)
echo "Checking C++ code formatting..."
clang-format --dry-run --Werror test.cpp || echo "Format check completed (may have formatting differences)"

# Test clang-tidy
echo ""
echo "Testing clang-tidy..."
clang-tidy --version

# Run clang-tidy analysis with C++20
echo "Running clang-tidy static analysis..."
clang-tidy test.cpp -- -std=c++20 -I/usr/include/c++/11 || echo "clang-tidy analysis completed (may have warnings)"

# Test compilation with optimization flags
echo ""
echo "Testing optimized compilation..."
clang++ -std=c++20 -O3 -Wall -Wextra -o test_opt test.cpp
./test_opt

# Test with libc++
echo ""
echo "Testing with libc++ (if available)..."
if clang++ -stdlib=libc++ -std=c++20 -o test_libcxx test.cpp 2>/dev/null; then
    ./test_libcxx
    echo "✓ libc++ test passed"
else
    echo "libc++ not available or compilation failed, skipping"
fi

# Test C++20 features
echo ""
echo "Testing C++20 features..."
cat > test_cpp20.cpp << 'EOF'
#include <iostream>
#include <concepts>
#include <ranges>
#include <vector>

template<typename T>
concept Numeric = std::is_arithmetic_v<T>;

template<Numeric T>
T add(T a, T b) {
    return a + b;
}

int main() {
    std::vector<int> vec{1, 2, 3, 4, 5};

    // C++20 ranges
    auto result = vec | std::views::filter([](int n) { return n % 2 == 0; })
                      | std::views::transform([](int n) { return n * n; });

    std::cout << "C++20 features work!" << std::endl;
    return 0;
}
EOF

clang++ -std=c++20 -o test_cpp20 test_cpp20.cpp
./test_cpp20

# Clean up
rm -f test test_opt test_libcxx test_cpp20 test_cpp20.cpp

echo ""
echo "✓ C++ tests completed!"
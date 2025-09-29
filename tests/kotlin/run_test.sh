#!/bin/bash
# Kotlin Test Runner

set -e

# Ensure we're in the right directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo "=== Testing Kotlin Installation ==="

# Test Kotlin version
echo "Kotlin version:"
kotlin -version
kotlinc -version

# Compile with kotlinc
echo ""
echo "Compiling Kotlin with kotlinc..."
kotlinc src/main/kotlin/Main.kt -include-runtime -d kotlin-test.jar

echo "Running compiled Kotlin JAR..."
java -jar kotlin-test.jar

# Test ktlint linter
echo ""
echo "Testing ktlint linter..."
ktlint --version
ktlint src/**/*.kt || echo "ktlint check completed (may have style warnings)"

# Test ktlint formatting (dry run)
echo ""
echo "Testing ktlint formatter (dry run)..."
ktlint --format src/**/*.kt --dry-run || true

# Test detekt static analysis
echo ""
echo "Testing detekt static analyzer..."
detekt --version

# Create minimal detekt config if needed
if [ ! -f detekt.yml ]; then
    cat > detekt.yml << 'EOF'
build:
  maxIssues: 50
complexity:
  active: true
  ComplexMethod:
    threshold: 15
style:
  active: true
  MagicNumber:
    active: false
EOF
fi

# Run detekt analysis
detekt --input src --config detekt.yml --report html:detekt-report.html || echo "detekt analysis completed"

# Test with Gradle
echo ""
echo "Building with Gradle..."
gradle build

echo "Running with Gradle..."
gradle run

# Test Kotlin scripting
echo ""
echo "Testing Kotlin scripting (.kts)..."
cat > test.kts << 'EOF'
println("Kotlin scripting works!")
val numbers = listOf(1, 2, 3, 4, 5)
val doubled = numbers.map { it * 2 }
println("Doubled numbers: $doubled")
EOF
kotlin test.kts
rm -f test.kts

# Clean up
rm -f kotlin-test.jar detekt-report.html

echo ""
echo "✓ Kotlin tests completed successfully!"
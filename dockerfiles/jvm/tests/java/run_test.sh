#!/bin/bash
# Java Test Runner - Comprehensive Testing
# Tests: Java, Maven, Gradle, build tools, and code quality

set -e

# Ensure we're in the right directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo "=== Testing Java Installation ==="
echo "================================="
echo "→ Working directory: $(pwd)"
echo "→ Files present: $(ls -la)"
echo ""

# Test Java version
echo "→ Java version:"
java -version
javac -version

# Test Maven
echo ""
echo "=== Testing Maven Build System ==="
echo "→ Maven version:"
mvn --version

echo ""
echo "→ Cleaning previous builds..."
mvn clean

echo "→ Compiling Java code..."
mvn compile

echo "→ Running tests..."
mvn test

echo "→ Packaging application..."
mvn package

echo "→ Running Java application with Maven..."
java -jar target/jon-babylon-java-test-1.0.0.jar

# Test dependency management
echo ""
echo "→ Testing Maven dependency resolution..."
mvn dependency:tree | head -20

# Test Gradle
echo ""
echo "=== Testing Gradle Build System ==="
echo "→ Gradle version:"
gradle --version

echo ""
echo "→ Cleaning previous builds..."
gradle clean

echo "→ Building with Gradle..."
gradle build

echo "→ Running tests with Gradle..."
gradle test

echo "→ Running Java application with Gradle..."
java -jar build/libs/jon-babylon-java-test-1.0.0.jar

# Test Gradle dependency management
echo ""
echo "→ Testing Gradle dependency resolution..."
gradle dependencies --configuration compileClasspath | head -20

# Test JAR tools
echo ""
echo "=== Testing JAR Tools ==="
echo "→ Listing JAR contents:"
jar tf target/jon-babylon-java-test-1.0.0.jar | head -10

echo "→ Extracting and verifying manifest:"
jar xf target/jon-babylon-java-test-1.0.0.jar META-INF/MANIFEST.MF
cat META-INF/MANIFEST.MF
rm -rf META-INF

echo ""
echo "✅ Java tests completed successfully!"
echo "======================================"
echo "Tested: javac, java, Maven, Gradle, JAR tools"
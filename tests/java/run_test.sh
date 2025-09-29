#!/bin/bash
# Java Test Runner

set -e

echo "=== Testing Java Installation ==="

# Test Java version
echo "Java version:"
java -version

# Test Maven
echo ""
echo "Testing Maven build..."
mvn clean compile package

echo ""
echo "Running Java application with Maven..."
java -jar target/jon-babylon-java-test-1.0.0.jar

# Test Gradle
echo ""
echo "Testing Gradle build..."
gradle clean build

echo ""
echo "Running Java application with Gradle..."
java -jar build/libs/jon-babylon-java-test-1.0.0.jar

echo ""
echo "✓ Java tests completed successfully!"
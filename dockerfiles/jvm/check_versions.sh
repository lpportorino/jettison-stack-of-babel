#!/bin/bash
# JVM container version check
set -e

echo "=== JVM Container Version Check ==="
echo ""
echo "Java: $(java --version 2>&1 | head -n1)"
echo "Kotlin: $(kotlin -version 2>&1)"
echo "Clojure: $(clojure --version)"
echo "Maven: $(mvn --version | head -n1)"
echo "Gradle: $(gradle --version 2>&1 | grep "Gradle" | head -n1)"
echo "Leiningen: $(lein version)"
echo "clj-kondo: $(clj-kondo --version)"
echo ""
echo "JAVA_HOME: $JAVA_HOME"
echo "MAVEN_HOME: $MAVEN_HOME"
echo "GRADLE_HOME: $GRADLE_HOME"
echo "SDKMAN_DIR: $SDKMAN_DIR"
echo ""
echo "✓ JVM container ready"
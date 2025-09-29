#!/bin/bash
# Clojure Test Runner

set -e

echo "=== Testing Clojure Installation ==="

# Test Clojure version
echo "Clojure version:"
clojure --version

# Run the main program with deps.edn
echo ""
echo "Running Clojure program (deps.edn)..."
clojure -M:run

# Test Leiningen
echo ""
echo "Testing Leiningen..."
lein version

# Test Leiningen project if it exists
if [ -f project.clj ]; then
    echo "Running Leiningen project..."
    lein deps
    lein run
fi

# Run linting with clj-kondo
echo ""
echo "Testing clj-kondo linting..."
clj-kondo --version
clojure -M:lint || clj-kondo --lint src --config '{:output {:format :compact}}' || true

# Run formatting check with cljfmt
echo ""
echo "Testing cljfmt formatting..."
clojure -M:format check || echo "Note: Format check may fail on first run"

# Test Babashka
echo ""
echo "Testing Babashka..."
bb --version
echo '(println "Hello from Babashka!")' | bb

# Test antq for dependency checking
echo ""
echo "Testing antq (dependency checker)..."
clojure -M:outdated --skip=pom || echo "Note: antq check completed"

# Test REPL
echo ""
echo "Testing REPL (evaluating expression)..."
echo '(println (str "REPL works! 2 + 2 = " (+ 2 2)))' | clojure -

echo ""
echo "✓ Clojure tests completed successfully!"
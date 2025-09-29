package com.jettison.test;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.IntStream;

public class Main {
    public static void main(String[] args) {
        System.out.println("=== Jon-Babylon Java Test ===");
        System.out.println("Java Version: " + System.getProperty("java.version"));
        System.out.println("Java Vendor: " + System.getProperty("java.vendor"));
        System.out.println("Java Home: " + System.getProperty("java.home"));

        // Test Java 21 features
        testPatternMatching();
        testVirtualThreads();
        testRecordPatterns();

        System.out.println("✓ All Java tests passed!");
    }

    // Test pattern matching for switch (Java 21)
    static void testPatternMatching() {
        Object value = 42;
        String result = switch (value) {
            case Integer i when i > 0 -> "Positive integer: " + i;
            case Integer i -> "Non-positive integer: " + i;
            case String s -> "String: " + s;
            case null -> "Null value";
            default -> "Unknown type";
        };
        System.out.println("Pattern matching result: " + result);
    }

    // Test virtual threads (Java 21)
    static void testVirtualThreads() {
        try {
            var result = Thread.startVirtualThread(() -> {
                System.out.println("Running in virtual thread: " + Thread.currentThread());
            });
            result.join();
            System.out.println("✓ Virtual threads work!");
        } catch (InterruptedException e) {
            System.err.println("Virtual thread test failed: " + e.getMessage());
        }
    }

    // Test record patterns (Java 21)
    record Point(int x, int y) {}
    record Rectangle(Point topLeft, Point bottomRight) {}

    static void testRecordPatterns() {
        Rectangle rect = new Rectangle(new Point(0, 0), new Point(10, 10));

        // Record pattern matching
        if (rect instanceof Rectangle(Point(var x1, var y1), Point(var x2, var y2))) {
            System.out.println(String.format("Rectangle from (%d,%d) to (%d,%d)", x1, y1, x2, y2));
        }
    }
}
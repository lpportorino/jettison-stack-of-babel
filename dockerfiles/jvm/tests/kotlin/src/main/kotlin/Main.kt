package com.jettison.test

import kotlinx.coroutines.*
import kotlin.time.Duration.Companion.seconds

fun main() = runBlocking {
    println("=== Jon-Babylon Kotlin Test ===")
    println("Kotlin Version: ${KotlinVersion.CURRENT}")

    // Test Kotlin features
    testDataClasses()
    testCoroutines()
    testExtensionFunctions()
    testNullSafety()
    testFunctionalProgramming()

    println("✓ All Kotlin tests passed!")
}

// Data classes
data class Person(val name: String, val age: Int)
data class Result<T>(val success: Boolean, val data: T?, val error: String?)

fun testDataClasses() {
    val person1 = Person("Alice", 30)
    val person2 = person1.copy(age = 31)

    println("Original person: $person1")
    println("Modified person: $person2")

    // Pattern matching with when
    val message = when {
        person2.age > 30 -> "Person is older than 30"
        person2.age == 30 -> "Person is exactly 30"
        else -> "Person is younger than 30"
    }
    println(message)
}

// Coroutines
suspend fun testCoroutines() = coroutineScope {
    println("Testing coroutines...")

    val deferred1 = async {
        delay(100)
        "Result 1"
    }

    val deferred2 = async {
        delay(200)
        "Result 2"
    }

    val results = listOf(deferred1, deferred2).awaitAll()
    println("Coroutine results: $results")
}

// Extension functions
fun String.isPalindrome(): Boolean {
    return this == this.reversed()
}

fun List<Int>.sumOfSquares(): Int {
    return this.map { it * it }.sum()
}

fun testExtensionFunctions() {
    println("Testing extension functions...")

    val palindrome = "radar"
    println("'$palindrome' is palindrome: ${palindrome.isPalindrome()}")

    val numbers = listOf(1, 2, 3, 4, 5)
    println("Sum of squares of $numbers: ${numbers.sumOfSquares()}")
}

// Null safety
fun testNullSafety() {
    println("Testing null safety...")

    val nullableString: String? = null
    val length = nullableString?.length ?: 0
    println("Length of null string: $length")

    val nonNullString = nullableString ?: "default"
    println("Non-null string: $nonNullString")

    // Safe call chain
    val result = nullableString
        ?.uppercase()
        ?.replace("A", "B")
        ?.length ?: -1

    println("Result of safe call chain: $result")
}

// Functional programming
fun testFunctionalProgramming() {
    println("Testing functional programming...")

    val numbers = (1..10).toList()

    // Filter, map, reduce
    val result = numbers
        .filter { it % 2 == 0 }
        .map { it * it }
        .reduce { acc, i -> acc + i }

    println("Sum of squares of even numbers 1-10: $result")

    // Higher-order functions
    val operation: (Int, Int) -> Int = { a, b -> a + b }
    println("Operation result: ${performOperation(5, 3, operation)}")

    // Sequences (lazy evaluation)
    val sequence = generateSequence(1) { it + 1 }
        .filter { it % 2 == 0 }
        .map { it * 2 }
        .take(5)
        .toList()

    println("Sequence result: $sequence")
}

fun performOperation(a: Int, b: Int, op: (Int, Int) -> Int): Int = op(a, b)
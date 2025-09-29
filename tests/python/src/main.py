#!/usr/bin/env python3
"""Jon-Babylon Python Test Suite"""

import sys
import asyncio
import json
import typing
from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any, TypeVar, Generic
from pathlib import Path
import multiprocessing as mp
from functools import lru_cache, reduce
import operator

# Test Python 3.12+ features
@dataclass
class Person:
    """Test dataclass with type hints"""
    name: str
    age: int
    hobbies: List[str] = field(default_factory=list)
    metadata: Optional[Dict[str, Any]] = None

    def greet(self) -> str:
        return f"Hello, I'm {self.name}, {self.age} years old"


# Generic types
T = TypeVar('T')

class Stack(Generic[T]):
    """Generic stack implementation"""
    def __init__(self) -> None:
        self._items: List[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> Optional[T]:
        return self._items.pop() if self._items else None

    def __repr__(self) -> str:
        return f"Stack({self._items})"


# Pattern matching (Python 3.10+)
def test_pattern_matching():
    """Test structural pattern matching"""
    print("Testing pattern matching...")

    def process_value(value):
        match value:
            case int(x) if x > 0:
                return f"Positive integer: {x}"
            case int(x) if x < 0:
                return f"Negative integer: {x}"
            case 0:
                return "Zero"
            case str(s):
                return f"String: {s}"
            case [x, y, *rest]:
                return f"List with at least 2 elements: {x}, {y}, rest: {rest}"
            case {"name": name, "age": age}:
                return f"Person dict: {name}, {age} years old"
            case _:
                return "Unknown pattern"

    test_cases = [42, -5, 0, "hello", [1, 2, 3, 4], {"name": "Alice", "age": 30}]
    for case in test_cases:
        print(f"  {case} -> {process_value(case)}")


# Async/await
async def fetch_data(id: int) -> Dict[str, Any]:
    """Simulate async data fetching"""
    await asyncio.sleep(0.1)
    return {"id": id, "data": f"Result {id}"}


async def test_async():
    """Test async/await functionality"""
    print("\nTesting async/await...")

    # Gather multiple async tasks
    tasks = [fetch_data(i) for i in range(5)]
    results = await asyncio.gather(*tasks)

    for result in results:
        print(f"  Fetched: {result}")


# Decorators and functional programming
@lru_cache(maxsize=128)
def fibonacci(n: int) -> int:
    """Cached Fibonacci calculation"""
    if n < 2:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)


def test_functional():
    """Test functional programming features"""
    print("\nTesting functional programming...")

    # Map, filter, reduce
    numbers = range(1, 11)
    squares = list(map(lambda x: x**2, numbers))
    evens = list(filter(lambda x: x % 2 == 0, squares))
    sum_evens = reduce(operator.add, evens)

    print(f"  Squares: {squares}")
    print(f"  Even squares: {evens}")
    print(f"  Sum of even squares: {sum_evens}")

    # List comprehensions
    result = [x**2 for x in range(10) if x % 2 == 0]
    print(f"  List comprehension: {result}")

    # Generator expression
    gen = (x**2 for x in range(10) if x % 2 == 0)
    print(f"  Generator sum: {sum(gen)}")

    # Fibonacci with cache
    fib_10 = fibonacci(10)
    print(f"  Fibonacci(10): {fib_10}")


# Context managers
class FileManager:
    """Custom context manager"""
    def __init__(self, filename: str, mode: str):
        self.filename = filename
        self.mode = mode
        self.file = None

    def __enter__(self):
        print(f"  Opening {self.filename}")
        self.file = open(self.filename, self.mode)
        return self.file

    def __exit__(self, exc_type, exc_val, exc_tb):
        print(f"  Closing {self.filename}")
        if self.file:
            self.file.close()


def test_context_manager():
    """Test context managers"""
    print("\nTesting context managers...")

    # Write and read with custom context manager
    test_file = Path("/tmp/test.txt")

    with FileManager(str(test_file), "w") as f:
        f.write("Hello from context manager!")

    if test_file.exists():
        with FileManager(str(test_file), "r") as f:
            content = f.read()
            print(f"  File content: {content}")
        test_file.unlink()


# Multiprocessing
def worker(num: int) -> int:
    """Worker function for multiprocessing"""
    return num ** 2


def test_multiprocessing():
    """Test multiprocessing"""
    print("\nTesting multiprocessing...")

    with mp.Pool(processes=4) as pool:
        numbers = list(range(10))
        results = pool.map(worker, numbers)
        print(f"  Multiprocessing results: {results}")


# Type annotations with Protocol (Python 3.8+)
from typing import Protocol

class Drawable(Protocol):
    """Protocol for drawable objects"""
    def draw(self) -> str:
        ...

class Circle:
    def __init__(self, radius: float):
        self.radius = radius

    def draw(self) -> str:
        return f"Circle with radius {self.radius}"

class Rectangle:
    def __init__(self, width: float, height: float):
        self.width = width
        self.height = height

    def draw(self) -> str:
        return f"Rectangle {self.width}x{self.height}"


def render(shape: Drawable) -> None:
    """Render any drawable shape"""
    print(f"  Drawing: {shape.draw()}")


def test_protocols():
    """Test Protocol typing"""
    print("\nTesting Protocols...")

    circle = Circle(5)
    rectangle = Rectangle(10, 20)

    render(circle)
    render(rectangle)


# Walrus operator (Python 3.8+)
def test_walrus_operator():
    """Test walrus operator"""
    print("\nTesting walrus operator...")

    # In while loop
    data = [1, 2, 3, 4, 5]
    while (n := len(data)) > 0:
        print(f"  List has {n} items")
        data.pop()
        if n == 3:
            break

    # In list comprehension
    results = [y for x in range(10) if (y := x**2) > 25]
    print(f"  Filtered squares > 25: {results}")


def main():
    """Main test runner"""
    print("=== Jon-Babylon Python Test ===")
    print(f"Python Version: {sys.version}")
    print(f"Python Path: {sys.executable}")

    test_pattern_matching()

    # Run async tests
    asyncio.run(test_async())

    test_functional()
    test_context_manager()
    test_multiprocessing()
    test_protocols()
    test_walrus_operator()

    # Test dataclasses
    print("\nTesting dataclasses...")
    person = Person("Alice", 30, ["reading", "hiking"])
    print(f"  {person.greet()}")
    print(f"  Hobbies: {person.hobbies}")

    # Test generics
    print("\nTesting generics...")
    stack: Stack[int] = Stack()
    stack.push(1)
    stack.push(2)
    stack.push(3)
    print(f"  Stack: {stack}")
    print(f"  Popped: {stack.pop()}")
    print(f"  Stack after pop: {stack}")

    print("\n✓ All Python tests passed!")


if __name__ == "__main__":
    main()
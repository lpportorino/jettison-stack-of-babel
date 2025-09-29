#include <iostream>
#include <vector>
#include <memory>
#include <algorithm>

class Shape {
public:
    virtual double area() const = 0;
    virtual ~Shape() = default;
};

class Circle : public Shape {
    double radius;
public:
    Circle(double r) : radius(r) {}
    double area() const override { return 3.14159 * radius * radius; }
};

int main() {
    std::cout << "=== Jon-Babylon C++ Test ===" << std::endl;

    // Test modern C++
    auto vec = std::vector<int>{1, 2, 3, 4, 5};
    std::ranges::transform(vec, vec.begin(), [](int x) { return x * x; });

    std::cout << "Squares: ";
    for(const auto& v : vec) {
        std::cout << v << " ";
    }
    std::cout << std::endl;

    // Test smart pointers
    auto circle = std::make_unique<Circle>(5.0);
    std::cout << "Circle area: " << circle->area() << std::endl;

    std::cout << "✓ C++ tests passed!" << std::endl;
    return 0;
}
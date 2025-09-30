// Jon-Babylon Rust Library Tests

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_basic_math() {
        assert_eq!(2 + 2, 4);
        assert_eq!(10 * 10, 100);
    }

    #[test]
    fn test_string_operations() {
        let hello = String::from("Hello");
        let world = String::from("World");
        let combined = format!("{} {}", hello, world);
        assert_eq!(combined, "Hello World");
    }

    #[test]
    fn test_vector_operations() {
        let mut vec = vec![1, 2, 3];
        vec.push(4);
        assert_eq!(vec.len(), 4);
        assert_eq!(vec[3], 4);
    }

    #[test]
    fn test_option_handling() {
        let some_value: Option<i32> = Some(42);
        let none_value: Option<i32> = None;

        assert!(some_value.is_some());
        assert!(none_value.is_none());
        assert_eq!(some_value.unwrap(), 42);
    }

    #[test]
    fn test_result_handling() {
        fn divide(a: f64, b: f64) -> Result<f64, String> {
            if b == 0.0 {
                Err(String::from("Division by zero"))
            } else {
                Ok(a / b)
            }
        }

        assert!(divide(10.0, 2.0).is_ok());
        assert!(divide(10.0, 0.0).is_err());
        assert_eq!(divide(10.0, 2.0).unwrap(), 5.0);
    }

    #[test]
    fn test_iterator_operations() {
        let numbers = vec![1, 2, 3, 4, 5];
        let sum: i32 = numbers.iter().sum();
        let doubled: Vec<i32> = numbers.iter().map(|x| x * 2).collect();

        assert_eq!(sum, 15);
        assert_eq!(doubled, vec![2, 4, 6, 8, 10]);
    }

    #[test]
    #[should_panic(expected = "assertion failed")]
    fn test_panic_handling() {
        assert!(false, "assertion failed");
    }
}
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use tokio::time::{sleep, Duration};

#[derive(Debug, Serialize, Deserialize)]
struct Person {
    name: String,
    age: u32,
}

async fn async_test() {
    println!("Async test running...");
    sleep(Duration::from_millis(100)).await;
    println!("Async test complete!");
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    println!("=== Jon-Babylon Rust Test ===");
    // Get Rust version at runtime
    let rust_version = std::process::Command::new("rustc")
        .arg("--version")
        .output()
        .expect("Failed to get rustc version");
    println!("Rust version: {}", String::from_utf8_lossy(&rust_version.stdout).trim());

    // Test async
    async_test().await;

    // Test serde
    let person = Person {
        name: "Alice".to_string(),
        age: 30,
    };
    let json = serde_json::to_string(&person)?;
    println!("JSON: {}", json);

    // Test collections
    let mut map = HashMap::new();
    map.insert("test", 42);
    println!("HashMap: {:?}", map);

    println!("✓ All Rust tests passed!");
    Ok(())
}
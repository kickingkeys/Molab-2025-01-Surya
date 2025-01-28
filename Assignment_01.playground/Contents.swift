/*
My Planning:
1. Make simple square and triangle patterns
2. Need:
   - Basic loops
   - Print statements
   - Simple functions
3. Watch for:
   - Line spacing
   - Pattern alignment
*/

import Foundation

// Makes a square of stars
func makeSquare(size: Int) {
    // Loop for each row
    for _ in 0..<size {
        // Create one row of stars
        print(String(repeating: "* ", count: size))
    }
}

// Makes a triangle of stars
func makeTriangle(size: Int) {
    // Loop for each row
    for i in 0..<size {
        // Print stars with increasing count
        print(String(repeating: "*", count: i + 1))
    }
}

// Test patterns
print("Square:")
makeSquare(size: 3)

print("\nTriangle:")
makeTriangle(size: 3)

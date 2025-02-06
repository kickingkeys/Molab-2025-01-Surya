/*
THINKING PROCESS:
1. I need a grid-like pattern using different geometric shapes
2. Each position in the grid should have a different shape in a repeating pattern
3. Use nested loops - outer loop for rows, inner loop for columns
4. Pattern should change both horizontally and vertically
5. I need to handle different sizes of grids
*/

import Foundation

// Function that takes a size parameter and returns a string containing the pattern
func generatePattern(size: Int) -> String {
    // Initialize empty string to store my complete pattern
    var pattern = ""
    
    // Array of Unicode geometric shapes I'll use in my pattern
    // ▢: empty square
    // ▣: filled square
    // ▤: square with horizontal line
    // ▥: square with vertical line
    // ▦: square with grid
    let shapes = ["▢", "▣", "▤", "▥", "▦"]
    
    // Outer loop: handles each row (0 to size-1)
    for row in 0..<size {
        // Inner loop: handles each column in current row (0 to size-1)
        for col in 0..<size {
            // Calculate which shape to use based on position
            // (row + col) % shapes.count creates a diagonal pattern
            // % operator ensures I stay within array bounds
            let shapeIndex = (row + col) % shapes.count
            
            // Add the selected shape to my pattern string
            pattern += shapes[shapeIndex]
        }
        // After each row is complete, add newline character
        pattern += "\n"
    }
    
    // Return completed pattern
    return pattern
}

// Test the pattern generator with different sizes
print("Small pattern (5x5):")
print(generatePattern(size: 5))

print("\nMedium pattern (8x8):")
print(generatePattern(size: 8))

print("\nLarge pattern (10x10):")
print(generatePattern(size: 10))

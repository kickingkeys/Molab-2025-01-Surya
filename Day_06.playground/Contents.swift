import UIKit
//
////var greeting = "Hello, playground"
//
//// ** for loop to repeat work **
//
//// BASIC FOR LOOP WITH ARRAYS
//// -------------------------------------
//let fruits = ["Apple", "Orange", "Banana"]
//
//for fruit in fruits {
//    print(fruit)         // Prints each fruit
//}
//
//
//// LOOPS WITH RANGES
//// -------------------------------------
//// Using ... (through)
//for i in 1...5 {        // Includes 5
//    print(i)            // Prints 1,2,3,4,5
//}
//
//// Using ..< (up to)
//for i in 1..<5 {        // Excludes 5
//    print(i)            // Prints 1,2,3,4
//}
//
//
//// NESTED LOOPS
//// -------------------------------------
//for i in 1...3 {
//    for j in 1...3 {
//        print("\(i) x \(j) = \(i * j)")
//    }
//}
//
//
//// IGNORING LOOP VARIABLE
//// -------------------------------------
//// When you don't need the counter
//for _ in 1...3 {
//    print("Hello")      // Prints 3 times
//}
//
//
//// PRACTICAL EXAMPLES
//// -------------------------------------
//// Times table
//for i in 1...12 {
//    print("5 x \(i) = \(5 * i)")
//}
//
//// Building strings
//var message = "Swift"
//for _ in 1...3 {
//    message += "!"
//}
//print(message)          // Prints: Swift!!!
//
//
//// KEY POINTS
//// -------------------------------------
//// 1. for in loops through arrays, ranges
//// 2. ... includes final number
//// 3. ..< excludes final number
//// 4. Use _ when loop variable not needed
//// 5. Nested loops possible with different variables (i,j)





// ** While Loop **

// BASIC WHILE LOOP
// -------------------------------------
//var count = 3
//while count > 0 {
//    print(count)
//    count -= 1
//}
//// Prints: 3, 2, 1
//
//
//// RANDOM NUMBERS WITH WHILE
//// -------------------------------------
//// Random integer
//let randomInt = Int.random(in: 1...10)    // Random 1-10
//
//// Random decimal
//let randomDouble = Double.random(in: 0...1)    // Random 0-1
//
//
//// PRACTICAL EXAMPLE: DICE GAME
//// -------------------------------------
//var roll = 0
//while roll != 6 {
//    roll = Int.random(in: 1...6)
//    print("Rolled: \(roll)")
//}
//print("Got a six!")
//
//
//// COUNTDOWN EXAMPLE
//// -------------------------------------
//var countdown = 5
//while countdown > 0 {
//    print("\(countdown)...")
//    countdown -= 1
//}
//print("Go!")
//
//
//// KEY POINTS
//// -------------------------------------
//// 1. While loops run until condition is false
//// 2. Good for unknown number of iterations
//// 3. Must modify condition in loop to avoid infinite loops
//// 4. Use for random number scenarios
//// 5. Common with user input and game logic
//
//// WARNING: Always ensure the condition can become false
//// Bad example - infinite loop:
//// while true {
////     print("Forever!")
//// }




// ** How to skip loop items with break and continue **

// CONTINUE - SKIPS CURRENT ITERATION
// -------------------------------------
//let files = ["doc.txt", "pic.jpg", "note.txt"]
//
//for file in files {
//    if file.hasSuffix(".txt") {
//        continue        // Skip text files
//    }
//    print("Processing: \(file)")
//}
//
//
//// BREAK - EXITS LOOP COMPLETELY
//// -------------------------------------
//var sum = 0
//for num in 1...100 {
//    sum += num
//    if sum > 500 {
//        break          // Exit when sum exceeds 500
//    }
//}
//
//
//// PRACTICAL EXAMPLES
//// -------------------------------------
//// Finding specific items
//let numbers = [1, 2, 3, 4, 5, 6, 7, 8]
//var evenNumbers = [Int]()
//
//for num in numbers {
//    if num.isMultiple(of: 2) == false {
//        continue    // Skip odd numbers
//    }
//    evenNumbers.append(num)
//}
//
//// Finding first match
//let ages = [18, 25, 30, 16, 22]
//for age in ages {
//    if age < 18 {
//        print("Found minor: \(age)")
//        break       // Stop after finding first minor
//    }
//}
//
//
//// COMMON USE CASES
//// -------------------------------------
//// continue:
//// - Skip unwanted items
//// - Filter out invalid data
//// - Jump to next iteration
//
//// break:
//// - Exit early when condition met
//// - Stop after finding first match
//// - Limit number of iterations

import UIKit


// ** Functions  **

// BASIC FUNCTION
// -------------------------------------
//func sayHello() {
//    print("Hello!")
//}
//// Call it:
//sayHello()
//
//
//// FUNCTION WITH PARAMETERS
//// -------------------------------------
//func greet(name: String) {
//    print("Hello, \(name)!")
//}
//// Call it:
//greet(name: "Taylor")
//
//
//// MULTIPLE PARAMETERS
//// -------------------------------------
//func printTimesTables(number: Int, end: Int) {
//    for i in 1...end {
//        print("\(i) x \(number) = \(i * number)")
//    }
//}
//// Call it:
//printTimesTables(number: 5, end: 10)
//
//
//// PARAMETER ORDER MATTERS
//// -------------------------------------
//func showDetails(name: String, age: Int) {
//    print("\(name) is \(age) years old")
//}
//// Must use in same order:
//showDetails(name: "John", age: 25)
//// Wrong order won't work:
//// showDetails(age: 25, name: "John")
//
//
//// PRACTICAL EXAMPLES
//// -------------------------------------
//// Welcome message function
//func showWelcome() {
//    print("Welcome to the app!")
//    print("Version 1.0")
//}
//
//// Calculate area function
//func calculateArea(width: Int, height: Int) {
//    let area = width * height
//    print("Area is \(area)")
//}

// KEY POINTS
// -------------------------------------
// 1. Functions make code reusable
// 2. Parameters let functions be flexible
// 3. Parameter names required when calling
// 4. Parameters must be in correct order
// 5. Data inside function is temporary






// ** How to return values from functions // Tuples  **

// RETURNING VALUES FROM FUNCTIONS
// -------------------------------------
// Single value return
//func checkAge(age: Int) -> Bool {
//    return age >= 18
//}
//
//// TUPLES BASICS
//// -------------------------------------
//// Named tuple
//func getUser() -> (name: String, age: Int) {
//    (name: "John", age: 25)    // Return values match type
//}
//
//// Using named tuple
//let user = getUser()
//print(user.name)      // Access by name
//print(user.age)


// UNNAMED TUPLES
// -------------------------------------
//func getCoordinates() -> (Double, Double) {
//    (51.50722, -0.1275)
//}
//
//let location = getCoordinates()
//print(location.0)     // Access by index
//print(location.1)
//
//
//// DECOMPOSING TUPLES
//// -------------------------------------
//// Get all values
//let (name, age) = getUser()
//print(name)    // Use individual constants
//
//// Ignore parts with _
//let (justName, _) = getUser()
//print(justName)    // Only use name
//
//
//// PRACTICAL EXAMPLES
//// -------------------------------------
//// HTTP Status
//func getStatus() -> (code: Int, message: String) {
//    (200, "OK")
//}
//
//// Time components
//func getTime() -> (hours: Int, minutes: Int) {
//    (14, 30)
//}

// Comparison with alternatives
// Array - loses type safety:
// func getUserArray() -> [Any] {
//     ["John", 25]    // Could be anything
// }

// Dictionary - needs default values:
// func getUserDict() -> [String: Any] {
//     ["name": "John", "age": 25]
// }


// KEY POINTS
// -------------------------------------
// 1. Fixed size and types
// 2. Can name elements
// 3. Access by name or index
// 4. Can decompose into variables
// 5. Safer than arrays/dictionaries





// ** How to customize parameter label **


// BASIC USAGE
// -------------------------------------
// Define functions with named parameters for clarity
//func rollDice(sides: Int, count: Int) -> [Int] {
//   var rolls = [Int]()
//   for _ in 1...count {
//       rolls.append(Int.random(in: 1...sides))
//   }
//   return rolls
//}
//
//// PARAMETER NAMING PATTERNS
//// -------------------------------------
//// 1. Default named parameters
//func hireEmployee(name: String) { }
//
//// 2. Unnamed parameters with _
//func isUppercase(_ string: String) -> Bool {
//   string == string.uppercased()
//}
//
//// 3. External/Internal parameter names
//func printTimesTables(for number: Int) {
//   for i in 1...12 {
//       print("\(i) x \(number) is \(i * number)")
//   }
//}
//
//// PRACTICAL EXAMPLES
//// -------------------------------------
//// Named parameters
//let diceRoll = rollDice(sides: 6, count: 4)
//
//// Unnamed parameter
//let result = isUppercase("HELLO")
//
//// External/Internal names
//printTimesTables(for: 5)

// KEY POINTS
// -------------------------------------
// 1. Swift uses parameter names to distinguish between functions
// 2. Use _ to omit external parameter name
// 3. Can specify different external/internal parameter names
// 4. Parameter names make function calls self-documenting
// 5. External names improve readability at call site





// * How to provide default values for parameters *



// DEFAULT PARAMETERS
// -------------------------------------
// Allow optional customization with default values
//func printTimesTables(for number: Int, end: Int = 12) {
//    for i in 1...end {
//        print("\(i) x \(number) is \(i * number)")
//    }
//}
//
//// USAGE PATTERNS
//// -------------------------------------
//// With explicit end value
//printTimesTables(for: 5, end: 20)
//
//// Using default end value
//printTimesTables(for: 8)
//
//// Array example with default parameter
//characters.removeAll() // Uses default keepingCapacity: false
//characters.removeAll(keepingCapacity: true) // Override default

// KEY POINTS
// -------------------------------------
// 1. Default values make functions flexible but simple to use
// 2. Only specify non-default values when needed
// 3. Common pattern for performance optimizations
// 4. Parameters with defaults must come last in function definition
// 5. Helps avoid multiple function variations for common cases






// ** How to handle errors in functions **

// ERROR HANDLING BASICS
// -------------------------------------
// Define possible errors using enum
//enum PasswordError: Error {
//   case short, obvious
//}
//
//// Function that can throw errors
//func checkPassword(_ password: String) throws -> String {
//   if password.count < 5 { throw PasswordError.short }
//   if password == "12345" { throw PasswordError.obvious }
//   
//   return password.count < 8 ? "OK" :
//          password.count < 10 ? "Good" : "Excellent"
//}
//
//// HANDLING PATTERNS
//// -------------------------------------
//// Basic error handling
//do {
//   let result = try checkPassword("12345")
//   print("Rating: \(result)")
//} catch {
//   print("Error occurred")
//}
//
//// Specific error handling
//do {
//   let result = try checkPassword("short")
//} catch PasswordError.short {
//   print("Password too short")
//} catch PasswordError.obvious {
//   print("Password too obvious")
//} catch {
//   print("Unknown error")
//}

// KEY POINTS
// -------------------------------------
// 1. Mark throwing functions with 'throws'
// 2. Use 'try' to call throwing functions
// 3. Handle errors in do-catch blocks
// 4. Can catch specific error cases
// 5. Access error details via error.localizedDescription
// 6. Use try! only when certain no error will occur

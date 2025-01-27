import UIKit

// var greeting = "Hello, playground"


// ** Type Annotations **


// BASICS: TWO WAYS TO DECLARE VARIABLES
// -------------------------------------

// 1. Type Inference: Swift guesses the type
// Think of it like Swift saying "I see you put text here, so this must be a String"
let name = "Lasso"         // Swift sees text, knows it's String
var score = 0             // Swift sees whole number, knows it's Int


// 2. Type Annotation: You explicitly tell Swift the type
// Like saying "This MUST be a String" or "This MUST be an Int"
let name: String = "Lasso"    // You're telling Swift it's a String
var score: Int = 0            // You're telling Swift it's an Int

// Why use type annotation? When you want a specific type:
var price: Double = 0         // Forces it to be decimal (0.0) instead of whole number


// COMMON TYPES IN SWIFT - THINK OF THEM LIKE CONTAINERS
// --------------------------------------------------

// String: Container for text
let message: String = "Hello"    // Like a box that only holds text

// Int: Container for whole numbers
let age: Int = 25               // Like a box that only holds whole numbers

// Double: Container for decimal numbers
let height: Double = 1.85       // Like a box that holds numbers with decimals

// Bool: Container for true/false
let isHappy: Bool = true        // Like a light switch - only on or off


// COLLECTION TYPES - THINK OF THEM LIKE ORGANIZING TOOLS
// --------------------------------------------------

// Array: Like a numbered list
// Everything inside must be the same type
var fruits: [String] = ["Apple", "Orange"]    // List of text items
var numbers = [Int]()                         // Empty list ready for numbers

// Dictionary: Like a phonebook (name → number)
// Must specify both types (key and value)
var scores: [String: Int] = ["Tom": 100]      // Names map to scores

// Set: Like a bag of unique items
// Automatically removes duplicates
var colors: Set<String> = Set(["Red", "Blue"]) // No duplicates allowed


// SPECIAL CASE: DECLARING NOW, SETTING VALUE LATER
// --------------------------------------------------

// Sometimes you need to declare a variable but set its value later
// Must tell Swift the type since there's no initial value to guess from
let username: String           // "I'll tell you the username later"
// Some code here...
username = "@sam"             // "Here's the username I promised"

// This is useful when the value depends on some conditions
// or complex logic that happens later in your code

// REMEMBER: Swift is strict about types
// You can't put text in a number container or vice versa
// let wrong: Int = "Five"    // This crashes - can't put text in number box

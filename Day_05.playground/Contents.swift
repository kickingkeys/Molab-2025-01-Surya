import UIKit

//var greeting = "Hello, playground"

// ** How to check a condition is true or false **

// BASIC IF STATEMENT STRUCTURE
//// -------------------------------------
//if someCondition {
//    // Code here runs if condition is true
//}
//
//// COMPARING NUMBERS
//// -------------------------------------
//let score = 85
//
//// > means "greater than"
//if score > 80 {
//    print("Great job!")    // Prints because 85 > 80
//}
//
//// Common comparison operators:
//let value = 18
//if value > 20 { }     // Greater than
//if value < 20 { }     // Less than
//if value >= 18 { }    // Greater than or equal to
//if value <= 18 { }    // Less than or equal to
//
//
//// COMPARING STRINGS
//// -------------------------------------
//let name1 = "Anna"
//let name2 = "Bob"
//
//// Strings can be compared alphabetically
//if name1 < name2 {
//    print("\(name1) comes before \(name2)")    // Anna comes before Bob
//}
//
//
//// WORKING WITH ARRAYS
//// -------------------------------------
//var numbers = [1, 2, 3]
//numbers.append(4)
//
//// Check array size and remove items
//if numbers.count > 3 {
//    numbers.remove(at: 0)    // Removes first item if too many
//}
//
//
//// CHECKING FOR EQUALITY
//// -------------------------------------
//let name = "Taylor"
//
//if name == "Anonymous" { }     // Equal to
//if name != "Anonymous" { }     // Not equal to
//
//
//// CHECKING FOR EMPTY VALUES
//// -------------------------------------
//var username = ""
//
//// Three ways to check for empty string:
//if username == "" { }                // Works but not efficient
//if username.count == 0 { }          // Also works but slow
//if username.isEmpty { }             // Best way! Fast and clear
//
//// MULTIPLE CONDITIONS IN CODE BLOCK
//// -------------------------------------
//if score > 80 {
//    print("Great score!")
//    print("You passed!")
//    print("Time to celebrate!")
//    // Can have as many lines as needed
//}
//
//
//
//// USING IF-ELSE
//// -------------------------------------
//let age = 16
//
//// Instead of checking twice:
//if age >= 18 {
//    print("Can vote")
//}
//if age < 18 {
//    print("Cannot vote")
//}
//
//// Better way - using else:
//if age >= 18 {
//    print("Can vote")
//} else {
//    print("Cannot vote")    // Runs if age < 18
//}
//
//
//// USING ELSE-IF
//// -------------------------------------
//let temperature = 25
//
//// Multiple conditions in order:
//if temperature < 0 {
//    print("Freezing!")
//} else if temperature < 15 {
//    print("Cold")
//} else if temperature < 25 {
//    print("Warm")
//} else {
//    print("Hot!")          // Runs if none above are true
//}
//
//
//// COMBINING CONDITIONS
//// -------------------------------------
//// Using && (AND)
//// Both conditions must be true
//if temperature > 20 && temperature < 30 {
//    print("Perfect weather!")
//}
//
//// Using || (OR)
//// At least one condition must be true
//let hasPermission = true
//if age >= 18 || hasPermission {
//    print("Can play game")
//}
//
//
//// PRACTICAL EXAMPLE WITH ENUMS
//// -------------------------------------
//enum Transport {
//    case car, bike, walk, bus
//}
//
//let todayTransport = Transport.car
//
//if todayTransport == .car || todayTransport == .bus {
//    print("Using motor vehicle")
//} else if todayTransport == .bike {
//    print("Using bicycle")
//} else {
//    print("Walking")
// }

// KEY POINTS:
// 1. else runs if no other condition is true
// 2. && means both sides must be true
// 3. || means one side must be true
// 4. You can have many else-if but only one else
// 5. Conditions are checked in order from top to bottom




// ** How to use switch statements to check multiple conditions **

////// SWITCH BASICS
//// -------------------------------------
//enum Weather {
//    case sun, rain, wind, snow
//}
//
//let forecast = Weather.sun
//
//// Instead of multiple if-else:
//switch forecast {
//case .sun:
//    print("Nice day")
//case .rain:
//    print("Bring umbrella")
//case .wind:
//    print("Windy day")
//case .snow:
//    print("Snow day")
//}
//
//// SWITCH WITH DEFAULT
//// -------------------------------------
//let place = "Gotham"
//
//switch place {
//case "Gotham":
//    print("Batman's city")
//case "Metropolis":
//    print("Superman's city")
//default:                    // Catches all other cases
//    print("Unknown city")
//}
//
//// FALLTHROUGH
//// -------------------------------------
//let level = 3
//
//switch level {
//case 3:
//    print("Gold")
//    fallthrough           // Continues to next case
//case 2:
//    print("Silver")
//    fallthrough
//case 1:
//    print("Bronze")
//}
//// Prints: Gold, Silver, Bronze
//
//// KEY POINTS
//// 1. Switch must handle all cases
//// 2. Can't check same case twice
//// 3. Default catches unmatched cases
//// 4. Fallthrough continues to next case
//// 5. Cases checked in order, top to bottom
//
//


// ** ternary conditional operator **

// TERNARY OPERATOR BASICS
// -------------------------------------
// Format: condition ? valueIfTrue : valueIfFalse

// Instead of if/else:
//if age >= 18 {
//    print("Adult")
//} else {
//    print("Child")
//}
//
//// Using ternary:
//let status = age >= 18 ? "Adult" : "Child"
//
//
//// PRACTICAL EXAMPLES
//// -------------------------------------
//// Time check
//let hour = 23
//let timeOfDay = hour < 12 ? "Morning" : "Afternoon"
//
//// Array check
//let names = ["John", "Sara"]
//let description = names.isEmpty ? "No people" : "\(names.count) people"
//
//// Enum check
//enum Theme {
//    case light, dark
//}
//let theme = Theme.dark
//let background = theme == .dark ? "black" : "white"
//
//
//// WHEN TO USE
//// -------------------------------------
//// 1. Single-line conditions
//// 2. SwiftUI view conditions
//// 3. When you need to assign based on condition
//
//// Example in function
//func getBackground(for theme: Theme) -> String {
//    theme == .dark ? "black" : "white"
//}
//
//
//// TIPS
//// -------------------------------------
//// Remember WTF pattern:
//// What (condition)
//// True (value if true)
//// False (value if false)
//
//// Examples:
//let score = 85
//let result = score >= 70 ? "Pass" : "Fail"
////          ^ What      ^ True   ^ False

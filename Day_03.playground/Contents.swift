//import UIKit
//
//// ** Arrays **
//
//// examples of creating arrays:
//
////var beatles = ["John", "Paul", "George", "Ringo"]
////let numbers = [4, 8, 15, 16, 23, 42]
////var temperatures = [25.3, 28.2, 26.4]
////
////
////// like Js swift also indexes from -
////
//////Swift actually counts an item’s index from zero rather than one – beatles[0] is the first element, and beatles[1] is the second, for example.
////
////// So, we could read some values out from our arrays like this:
////
////print(beatles[0])
////print(numbers[1])
////print(temperatures[2])
////
////
//////If your array is variable, you can modify it after creating it. For example, you can use append() to add new items:
////
////beatles.append("Adrian")
////// And there’s nothing stopping you from adding items more than once:
////
////beatles.append("Allen")
////beatles.append("Adrian")
////beatles.append("Novall")
////beatles.append("Vivian")
////
////// can also add numbers to string but Swift won’t let you mix these two different types together,
////
//////when you want to start with an empty array and add items to it one by one. This is done with very precise syntax:
////
////var scores = Array<Int>()
////scores.append(100)
////scores.append(80)
////scores.append(85)
////print(scores[1])
////
////// We’ve covered the last four lines already, but that first line shows how we have a specialized array type – this isn’t just any array, it’s an array that holds integers. This is what allows Swift to know for sure that beatles[0] must always be a string, and also what stops us from adding integers to a string array.
////
////// The open and closing parentheses after Array<Int> are there because it’s possible to customize the way the array is created if you need to. For example, you might want to fill the array with lots of temporary data before adding the real stuff later on.
////
////// You can make other kinds of array by specializing it in different ways, like this:
////
//////You can make other kinds of array by specializing it in different ways, like this:
////
////var albums = Array<String>()
////albums.append("Folklore")
////albums.append("Fearless")
////albums.append("Red")
////
////// we’ve said that must always contain strings, so we can’t try to put an integer in there.
////
////
////// Array<String>, you can instead write [String]. So, this kind of code is exactly the same as before:
////
//////var albums = [String]()
//////albums.append("Folklore")
//////albums.append("Fearless")
//////albums.append("Red")
////
//////you can use .count to read how many items are in an array, just like you did with strings:
////
////print(albums.count)
////
////// Second, you can remove items from an array by using either remove(at:) to remove one item at a specific index, or removeAll() to remove everything:
////
////// you can check whether an array contains a particular item by using contains(), like this:
////
////
//////let bondMovies = ["Casino Royale", "Spectre", "No Time To Die"]
//////print(bondMovies.contains("Frozen"))
////
//////you can sort an array using sorted(), like this:
////
//////let cities = ["London", "Tokyo", "Rome", "Budapest"]
////// print(cities.sorted())
////
//////You can reverse an array by calling reversed() on it:
////
////let presidents = ["Bush", "Obama", "Trump", "Biden"]
////let reversedPresidents = presidents.reversed()
////print(reversedPresidents)
//
//
//
//
//
//
//// ** How to store and find data in dictionaries **
//
////Arrays are a great choice when items should be stored in the order you add them, or when you might have duplicate items in there, but very often accessing data by its position in the array can be annoying or even dangerous.
//
////For example, here’s an array containing an employee’s details:
//
////var employee = ["Taylor Swift", "Singer", "Nashville"]
////
//////I’ve told you that the data is about an employee, so you might be able to guess what various parts do:
////
////print("Name: \(employee[0])")
////print("Job title: \(employee[1])")
////print("Location: \(employee[2])")
////
////
////// Dictionaries don’t store items according to their position like arrays do, but instead let us decide where items should be stored.
////
////// For example, we could rewrite our previous example to be more explicit about what each item is:
////
////let employee2 = ["name": "Taylor Swift", "job": "Singer", "location": "Nashville"]
////
////// If we split that up into individual lines you’ll get a better idea of what the code does:
////
////let employee2 = [
////    "name": "Taylor Swift",
////    "job": "Singer",
////    "location": "Nashville"
////]
//
//// we could track which students have graduated from school using strings for names and Booleans for their graduation status:
//
//let hasGraduated = [
//    "Eric": false,
//    "Maeve": true,
//    "Otis": false,
//]
//// Or we could track years when Olympics took place along with their locations:
//
//let olympics = [
//    2012: "London",
//    2016: "Rio de Janeiro",
//    2021: "Tokyo"
//]
//
//print(olympics[2012, default: "Unknown"])
//// You can also create an empty dictionary using whatever explicit types you want to store, then set keys one by one:
//
//var heights = [String: Int]()
//heights["Yao Ming"] = 229
//heights["Shaquille O'Neal"] = 216
//heights["LeBron James"] = 206
//// Notice how we need to write [String: Int] now, to mean a dictionary with strings for its keys and integers for its values.
//
//// Because each dictionary item must exist at one specific key, dictionaries don’t allow duplicate keys to exist. Instead, if you set a value for a key that already exists, Swift will overwrite whatever was the previous value.
//
////For example, if you were chatting with a friend about superheroes and supervillains, you might store them in a dictionary like this:
//
//var archEnemies = [String: String]()
//archEnemies["Batman"] = "The Joker"
//archEnemies["Superman"] = "Lex Luthor"
//// If your friend disagrees that The Joker is Batman’s arch-enemy, you can just rewrite that value by using the same key:
//
//archEnemies["Batman"] = "Penguin"
//
//// Finally, just like arrays and the other data types we’ve seen so far, dictionaries come with some useful functionality that you’ll want to use in the future – count and removeAll() both exists for dictionaries, and work just like they do for arrays.
//
//
//
//
//
//
//
//// ** How to use sets for fast data lookup **
//
////two ways of collecting data in Swift: arrays and dictionaries. There is a third very common way to group data, called a set – they are similar to arrays, except you can’t add duplicate items, and they don’t store their items in a particular order.
//// Creating a set works much like creating an array: tell Swift what kind of data it will store, then go ahead and add things. There are two important differences, though,
//
//// how you would make a set of actor names:
//
////let people = Set(["Denzel Washington", "Tom Cruise", "Nicolas Cage", "Samuel L Jackson"])
//
////  creates an array first, then puts that array into the set? That’s intentional, and it’s the standard way of creating a set from fixed data. Remember, the set will automatically remove any duplicate values, and it won’t remember the exact order that was used in the array.
//
////print(people)
//
//// The second important difference when adding items to a set is visible when you add items individually. Here’s the code:
//
////var people = Set<String>()
////people.insert("Denzel Washington")
////people.insert("Tom Cruise")
////people.insert("Nicolas Cage")
////people.insert("Samuel L Jackson")
//
//// Notice how we’re using insert()? When we had an array of strings, we added items by calling append(), but that name doesn’t make sense here – we aren’t adding an item to the end of the set, because the set will store the items in whatever order it wants.
//
//
//// Sets vs Arrays - The Basics:
//
//
//Arrays are like an ordered list where you can add items using append() to put them at the end
//Sets are different - they're like a bag where the order doesn't matter, so we use insert() instead
//Sets automatically prevent duplicates (they won't store the same thing twice)
//
//
//Why Sets are Sometimes Better:
//Think of it like two different ways to store a list of names:
//
//Array (like a sign-in sheet):
//
//Names are kept in exact order people wrote them
//You can have duplicates
//To find a name, you have to read through the whole list from start to finish
//
//Set (like a phone book):
//
//Order isn't important
//Each name can only appear once
//Finding a name is super fast because it's organized efficiently
//
//The example about Michael Keaton is perfect: When he tried to join the actors' guild, they already had a Michael Douglas, so he had to change his name. A set would automatically prevent having two Michael Douglas entries.
//The big advantage is speed: If you're checking if a name exists...
//
//In an array of 1000 movies: Might need to check all 1000 entries one by one
//In a set of 1000 movies (or even a million): Almost instant response
//
//Think of it like trying to find a book:
//
//Array = Looking through every book on a shelf one by one
//Set = Using a library's organized system to go right to the correct spot
//
//You'll use arrays most of the time, but sets are perfect when you need:
//
//No duplicates allowed
//Super fast lookups
//Don't care about keeping things in a specific order




// ** enums (enumaration) **

//set of named values we can create and use in our code


// PROBLEM: Using Strings for Fixed Options
// -------------------------------------

// BAD: Using strings is error-prone
var selected = "Monday"
selected = "Tuesday"
selected = "January"     // Bug: Accidentally used month instead of day
selected = "Friday "     // Bug: Extra space makes it different from "Friday"


// SOLUTION: Using Enums
// -------------------------------------

// Define an enum with specific cases
// Each case represents one possible value
enum Weekday {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
}

// BENEFITS:
// 1. Type safety - can only use defined cases
// 2. No typos possible
// 3. Swift suggests available options
// 4. More memory efficient than strings
var day = Weekday.monday
day = .tuesday    // Swift knows it's Weekday type, so .tuesday is enough
day = .friday     // Can't accidentally use "Friday " with space


// SIMPLIFIED SYNTAX
// -------------------------------------

// Instead of writing 'case' multiple times,
// you can combine them with commas
enum WeekdaySimple {
    case monday, tuesday, wednesday, thursday, friday
}

// MEMORY EFFICIENCY
// -------------------------------------
// Behind the scenes, Swift stores enums as simple integers
// monday might be 0, tuesday might be 1, etc.
// More efficient than storing strings like "monday", "tuesday"

// USAGE EXAMPLES
// -------------------------------------
let meetingDay = Weekday.monday
let deliveryDay: Weekday = .friday    // Type annotation shows it's a Weekday

// Swift prevents invalid values
// This would not compile:
// day = .saturday    // Error: .saturday is not a member of Weekday

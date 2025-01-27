import UIKit




// ** Boolean **

// Making a Boolean is just like making the other data types, except you should assign an initial value of either true or false, like this:

//let goodDogs = true
//let gameOver = false
//
//// You can also assign a Boolean’s initial value from some other code, as long as ultimately it’s either true or false:
//
//let isMultiple = 120.isMultiple(of: 3)

//Unlike the other types of data, Booleans don’t have arithmetic operators such as + and - – after all, what would true + true equal? However, Booleans do have one special operator, !, which means “not”. This flips a Boolean’s value from true to false, or false to true.

// if you call toggle() on a Boolean it will flip a true value to false, and a false value to true. see below
//
//var gameOver = false
//print(gameOver)
//
//gameOver.toggle()
//print(gameOver)







// ** joining Strings together **

// combine strings together: joining them using +, and a special technique called string interpolation that can place variables of any type directly inside strings.


//using +


//let firstPart = "Hello, "
//let secondPart = "world!"
//let greeting = firstPart + secondPart
//
//// can do this many times if you need to:
//
//let people = "Haters"
//let action = "hate"
//let lyric = people + " gonna " + action
//print(lyric)


// using + to join two strings, but when we used Int and Double it added numbers together? This is called operator overloading – the ability for one operator such as + to mean different things depending on how it’s used. For strings, it also applies to +=, which adds one string directly to another.

//string interpolation

// with string interpolation: you write a backslash inside your string, then place the name of a variable or constant inside parentheses.

// For example, we could create one string constant and one integer constant, then combine them into a new string:

//let name = "Taylor"
//let age = 26
//let message = "Hello, my name is \(name) and I'm \(age) years old."
//print(message)


// String interpolation is much more efficient than using + to join strings one by one, but there’s another important benefit too: you can pull in integers, decimals, and more with no extra work.

// using + lets us add strings to strings, integers to integers, and decimals to decimals, but doesn’t let us add integers to strings.

// 1st attempt

//let celsius = 25.0
//
//var symbol = "°F"
//let Farenheit = ((celsius * 9/5) + 32) +  \(symbol)

// Second attempt

//let celsius = 25.0
//var symbol = "°F"
//let fahrenheit = "\((celsius * 9/5) + 32)\(symbol)"


 

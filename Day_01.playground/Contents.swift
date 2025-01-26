// Var is Variable
// Charecter = Const, use for numbers


import UIKit

//** Variables and Cosntants **

//var greeting = "Hello, playground"
//
//var name = "Ted"
//name = "Rebecca"
//name = "John"
//
//
//let charecter = "Daphne"
//
//var playerName = "Roy"
//print(playerName)
//
//playerName = "Dani"
//print(playerName)
//
//
//let managerName = "Micheal Scott"
//let dogBreed = "Labrador Retriever"
//let meaningOfLife = "how many toads must a man walk down?"





// ** Strings **
//let actor = "Denzel Washington"
//let filename = "paris.jpg"
//let result = "  you win  "
//
// let quote = " Then he tapped a sign saying \"Belive\" andwalked away."
//
//// use \"  \" to isnert quotes inside strings
//
//
//let movie = """
//a day in 
//the life of 
//an apple engineer 
//"""
//// for multiline strings you can use the three quote marks
//
//let nameLength = (actor.count)
//print(nameLength)
//
//print(result.uppercased())
//
//print(movie.hasPrefix("a day"))
//print(filename.hasSuffix(".jpg"))





// **Integers **
//
//let score = 50
//let reallyBig = 100_000_000
//// so 100_00_00 is like 100,000.00 but in code
//// can also do this -  let reallyBig = 1_00__00___00____00
//// swift doesnt care
//
//// artheetic opreations
////  + for addition, - for subtraction, * for multiplication, and / for division.
//
//let lowerScore = score - 2
//let higherScore = score + 10
//let doubledScore = score * 2
//let squaredScore = score * score
//let halvedScore = score / 2
//print(score)
//
//
//// increasing a counter
//
//var counter = 10
//counter = counter + 5
//
//// or
//
//counter += 5
//print(counter)
//
//// can do the same with other arthemtic fucntions
//
//counter *= 2
//print(counter)
//counter -= 10
//print(counter)
//counter /= 2
//print(counter)
//
//// can call isMultiple(of:) on an integer to find out whether it’s a multiple of another integer.
//
//let number = 120
//print(number.isMultiple(of: 3))





// ** Decimal Numebrs **

// numbers such as 3.1, 5.56, or 3.141592654, are what Swift calls floating-point numbers.
//let number = 0.1 + 0.2
//print(number)

//when you create a floating-point number, Swift considers it to be a Double. That’s short for “double-precision floating-point number”,

//Second, Swift considers decimals to be a wholly different type of data to integers, which means you can’t mix them together.

// so this kind of code will produce an error:

//let a = 1
//let b = 2.0
////let c = a + b
//
////you need to tell Swift explicitly that it should either treat the Double inside b as an Int:
//let c = a + Int(b)
//
//// or Or treat the Int inside a as a Double:
//
////let c = Double(a) + b
//
//// Combined with type safety, this means that once Swift has decided what data type a constant or variable holds, it must always hold that same data type. That means this code is fine:
//
//var name = "Nicolas Cage"
//name = "John Travolta"

// But this kind of code is not:

//var name = "Nicolas Cage"
//name = 57


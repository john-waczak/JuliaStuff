# Types 

Julia's type system enables *multiple-dispatch* on function argument types - this is what makes it fast when combined with the JIT (just in time compiler**. 

## Mental model for types 
- **Abstract Types**: Define sets of related types at the highest level (can't be used for variables)
- **Concrete Types**: Define data structures with concrete implementations (can be used for variables)

## Derived Types
User defined data types use the `struct` keyword, or, `mutable struct` if you want to be able to change the values of your data type post-construction. 


## Parametric Types
*Type parameters* make it possible to define types whose field types may vary. Each parametric type `Point{T}` is a subtype of the parent `Point`


## Design Patterns
The *Julian* approach to program design is to build your code around the type system. This usually involves defining some type of type hierarchy using both abstract *and* concrete types.

We then use functions to define the behaviors of each type

In *most* cases it's fine to omit types. The usual motivation is because we want to 
- improve readability 
- catch errors 
- take advantage of **multiple-dispatch**


Summary: 
- Functions that describe the *what* can have multiple **methods** that describe the *how*
- Multiple dispatch is when Julia describes the *most specialized* method based on the types of the input arguments 
- Best practice is to constrain argument types to the widest possible level and only introduce constraints where you know other types will fail.


## Type Stability
Type stability is the ability of the Julia compiler to infer all the possible argument and return types of a function. Unfortunately, it is possible to write **type-unstable** code


## Just in time compilation 
Here's it works (broadly speaking): 
1. You write Julia code 
2. Code is compiled Just-in-time to LLVM intermediate representation 
3. LLVM compiler converts to machine code with sophisticated optimizations 

Summary 
- `@code_typed` shows the types that the compile inferred from our code 
- `@code_warntype` shows type warnings and can be used to detect type-instability
- `@code_llvm` and `@code_native` can be used to see the size of the resulting low level code (the fewer lines, the better!)


## Metaprogramming
A *macro* like a function that accepts expressions as arguments, manipulates them, and then returns a new expression. 


# Developing In Julia


## Modules
We use modules to encapsulate code. Modules have their own global scope separate from other modules (including `Main`).

## Revise
With revise loaded, we no longer need to restart Julia after changing definitions within a module.

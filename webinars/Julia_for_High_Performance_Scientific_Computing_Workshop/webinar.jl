# Types


### Abstract vs Concrete
typeof(1)  # Int64
typeof(1.0) # Float64
typeof(1.0 + 2.0im)  # returns Complex64


supertypes(Float64)  # (Float64, AbstractFloat, Real, Number, Any)
subtypes(Real)  #  AbstractFloat ,AbstractIrrational ,Integer, Rational

# define a new datatype
struct Point2D
    x
    y
end

p = Point2D(1.1, 2.2) # construct

p.x # access elements


# parametric types
struct Point{T}
    x::T
    y::T
end

p1 = Point(1,2)
p2 = Point(1.0, 2.0)

# Point{T} <: Point

###   Type hierarchies

# abstract types
abstract type AbstractAnimal end
abstract type AbstractDog <: AbstractAnimal end
abstract type AbstractCat <: AbstractAnimal end

# concrete sub-types
struct Dog <: AbstractDog
    name::String
    friendly::Bool
end

struct Cat <: AbstractCat
    name::String
    huntsmice::Bool
end

# define function `AbstractAnimal`. This forces each subtype to have the needed field(s)
get_name(A::AbstractAnimal) = A.name

function get_mouse_hunting_ability(A::AbstractCat)
    return A.huntsmice ? "$(A.name) hunts mice" : "$(A.name) leaves mice alone"
end

billy = Cat("Billy", true)

get_name(billy)
get_mouse_hunting_ability(billy)



function sumsquare(x, y)
    return x^2 + y^2
end


sumsquare(1.0, 1.0)
sumsquare(2, 3)
sumsquare(1+2im, 3-4im)

sumsquare(p1, p2)  # doesn't work since ^,+ aren't defined for `Point`

sumsquare(p::Point, q::Point) = Point(p.x^2 + q.x^2, p.y^2 + q.y^2)
sumsquare(p1, p2) # now it works

cp1 = Point(1+1im, 2+2im)
cp2 = Point(3+3im, 4+4im)
sumsquare(cp1, cp2)

# list all of the methods:
methods(sumsquare)


## Type instability
function relu_unstable(x)
    if x < 0
        return 0
    else
        return x
    end
end

# the return type depends on the input type!
relu_unstable(1) # returns Int
relu_unstable(1.0) # returns Float
relu_unstable(-1.0) # return Int when supplied Float


# solution, use the zero() function
function relu_stable(x)
    if x < 0
        return zero(x)
    else
        return x
    end
end

relu_stable(1.0)
relu_stable(-1.0)


A = [1 2 3 4]
# other convenience functions are
eltype(A)  # to get the type of array elements

B =similar(A) # create an uninitialized mutable array with given element type


# see the various stages of processed code:

# LLVM lowered form:
@code_lowered sumsquare(1,2)
@code_lowered sumsquare(1.0, 2.0)
@code_lowered sumsquare(p1,p2)

# LLVM intermediate representation:
@code_llvm sumsquare(1,2)
@code_llvm sumsquare(1.0, 2.0)
@code_llvm sumsquare(p1,p2)

# native assembly instructions:
@code_native sumsquare(1,2)
@code_native sumsquare(1.0, 2.0)
@code_native sumsquare(p1,p2)


# type inferred lowered form (IR):
@code_typed sumsquare(1,2)
@code_typed sumsquare(1.0, 2.0)
@code_typed sumsquare(p1,p2)

# lowered and type-inferred ASTs (abstract syntax tree)
@code_warntype sumsquare(1,2)
@code_warntype sumsquare(1.0, 2.0)
@code_warntype sumsquare(p1,p2)


## Metaprogramming
Meta.parse("x + y") |> dump  # see the abstract syntax tree for this expression

# create an expression and evaluate it
ex = :(x + y)
x = y = 2
eval(ex)  # ret 4


# define macro to repeat an expression N times
macro dotimes(n, body)
    quote
        for i ∈ 1:$(esc(n))
            $(esc(body))
        end
    end
end

@dotimes 5 println("Hello!")

x = 2
@dotimes 4 x = x^2

# see what the macro actually does
@macroexpand @dotimes 4 x -= 13



# investigate the type instability
@code_warntype relu_unstable(2.0)

@macroexpand @assert 1 == 1
@macroexpand @fastmath 1+1
@macroexpand @show x
@macroexpand @time sum([1/i for i ∈ 1:20])

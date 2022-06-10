# A Brief Feel for the Dream
using LinearAlgebra
using CUDA


struct DemoMatrix{T, V<:AbstractVector{T}} <: AbstractMatrix{T}
    v::V
end

Base.size(A::DemoMatrix) = length(A.v), length(A.v)
Base.getindex(A::DemoMatrix, i, j) = A.v[i]*(i==j) + A.v[i]*A.v[j]

A = DemoMatrix([1, 10, 100])


# see the storage difference between the two
dump(A)
dump(Matrix(A))

# our very own (largest) eigensolver for new matrix type
f(A::DemoMatrix) = λ -> 1 + mapreduce((v) -> v^2 / (v - λ), + , A.v)
f′(A::DemoMatrix) = λ -> mapreduce((v) -> v^2 / (v - λ)^2, + , A.v)

function LinearAlgebra.eigmax(A::DemoMatrix; tol=eps(2.0), debug=false)
    x0 = maximum(A.v) + maximum(A.v)^2
    δ = f(A)(x0)/f′(A)(x0)
    println("x = $x0, δ = $δ")
    while abs(δ) > x0 * tol
        x0 -= δ
        δ = f(A)(x0)/f′(A)(x0)
        println("x = $x0, δ = $δ")
    end
    x0
end


# compare the two
eigmax(A)
eigmax(Matrix(A))



# let's try an matrix that would be WAY to big normally
N = 4_000_000
v = rand(N)*0.1
A = DemoMatrix(v)

# put it on the gpu!
gpuA = DemoMatrix(CuArray(v))

@time eigmax(A)
@time eigmax(A)

@time eigmax(gpuA) # it just works!
@time eigmax(gpuA) # it just works!


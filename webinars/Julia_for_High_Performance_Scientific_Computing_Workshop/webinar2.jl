include("Point.jl")
using .Points

p1 = Point(0.0, 1.0)
p2 = Point(1.0, 2.0)
p3 = sumsquare(p1, p2)

# list all exported names
names(Points)

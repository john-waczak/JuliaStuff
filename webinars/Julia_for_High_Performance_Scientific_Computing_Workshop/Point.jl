module Points

export Point, sumsquare

struct Point{T}
    x::T
    y::T
end


function sumsquare(p1::Point, p2::Point)
    return Point(p1.x^2 + p2.x^2, p1.y^2 + p2.y^2)
end



end

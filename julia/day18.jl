using DataStructures

test_input = """
2,2,2
1,2,2
3,2,2
2,1,2
2,3,2
2,2,1
2,2,3
2,2,4
2,2,6
1,2,5
3,2,5
2,1,5
2,3,5
"""

input = read("inputs/input_day18.txt", String)

input = map(filter(l -> length(l) > 0, split(input, '\n'))) do line
    x, y, z = parse.(Int, split(line, ','))
    x, y, z
end

function neighbors(p::Tuple{Int,Int,Int})
    x, y, z = p
    [
        (x-1, y, z),
        (x+1, y, z),
        (x, y-1, z),
        (x, y+1, z),
        (x, y, z-1),
        (x, y, z+1),
    ]
end

points = Vector{Tuple{Int,Int,Int}}(input)

# Part 1 
map(points |> collect) do p
    n = sum(map(p -> p in points, neighbors(p)))
    6 - n
end |> sum

import Base: maximum, minimum

maximum(points::Vector{Tuple{Int,Int,Int}}, dim::Int) = maximum(map(p -> p[dim], points |> collect))
minimum(points::Vector{Tuple{Int,Int,Int}}, dim::Int) = minimum(map(p -> p[dim], points |> collect))

max_x = maximum(points, 1)
max_y = maximum(points, 2)
max_z = maximum(points, 3)
min_x = minimum(points, 1)
min_y = minimum(points, 2)
min_z = minimum(points, 3)

function is_free(p::Tuple{Int,Int,Int}) 
    x, y, z = p
    return x < min_x || x > max_x || y < min_y || y > max_y || z < min_z || z > max_z
end

function detect_trap(p, points)
    queue = neighbors(p)
    filter!(p -> p ∉ points, queue)
    if length(queue) == 0
        return true
    end
    
    visited = Vector{Tuple{Int,Int,Int}}()

    while length(queue) > 0
        p = popfirst!(queue)

        if p in visited
            continue
        end

        push!(visited, p)

        if is_free(p)
            return false
        end

        for n in neighbors(p)
            if n ∉ points
                push!(queue, n)
            end
        end
    end
    
    return true
end

map(points) do p
    n = 0
    for neight in neighbors(p)
        if neight in points
            continue
        end
        if detect_trap(neight, points)
            continue
        end
        n += 1
    end
        
    n
end |> sum
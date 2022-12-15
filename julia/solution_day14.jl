inputs = """
498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
"""

inputs = read("inputs/input_day14.txt", String)

# split into lines
inputs = split(inputs, "\n")

# remove empty lines
inputs = filter(x -> length(x) > 0, inputs)

inputs = map(inputs) do input
    input = map(split(input, " -> ")) do x
        x = split(x, ",")
        x = parse.(Int, x)
    end
end

function max_x_y(input)
    max_y = maximum(getindex.(input, 1))
    max_x = maximum(getindex.(input, 2))
    return [max_y, max_x]
end

function min_x_y(input)
    min_y = minimum(getindex.(input, 1))
    min_x = minimum(getindex.(input, 2))
    return [min_y, min_x]
end

min_y, min_x = min_x_y(min_x_y.(inputs))

max_y, max_x = max_x_y(max_x_y.(inputs))

# include start coord
min_y = min(min_y, 500)
min_x = min(min_x, 0)

max_x = max_x + 2

min_y  = 500 - max_x
max_y = 500 + max_x

field = fill(false, max_y - min_y + 1, max_x - min_x + 1)

field[:, end] .= true

function coord_to_index(y, x)
    return CartesianIndex(y - min_y + 1, x - min_x + 1)
end

for input in inputs
    (i, s) = iterate(input)
    start = coord_to_index(i...)
    next = iterate(input, s)
    while next !== nothing
        (i, s) = next
        stop = coord_to_index(i...)

        x_start = min(start[1], stop[1])
        x_stop = max(start[1], stop[1])
        y_start = min(start[2], stop[2])
        y_stop = max(start[2], stop[2])

        field[start:stop] .= true

        start = stop

        next = iterate(input, s)
    end
end

i = 0
while (true)    
        start_pos = coord_to_index(500, 0)
        pos = start_pos
        fixed = false
        while (!fixed)
            if !field[pos+CartesianIndex(0, 1)]
                pos = pos + CartesianIndex(0, 1)
            elseif !field[pos+CartesianIndex(-1, 1)]
                pos = pos + CartesianIndex(-1, 1)
            elseif !field[pos+CartesianIndex(1, 1)]
                pos = pos + CartesianIndex(1, 1)
            else
                fixed = true
            end
        end
        if pos == start_pos
            break
        end
        field[pos] = true
        i += 1
end

transpose(field)
i+1
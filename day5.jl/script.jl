# First Part

input = read("day5.jl/input.txt", String)

header, movements = split(input, "\n\n")
header = split(header, "\n")
movements = split(movements, "\n")

# throw index line away
header = header[1:end-1]

# throw last empty line away
movements = movements[1:end-1]

function build_stacks()
    stacks  = [Vector{Char}() for _ in 1:9]
    for i ∈ reverse(eachindex(header))
        for (j, k) in enumerate(2:4:34)
            @show elem = header[i][k]
            if elem != ' '
                push!(stacks[j], elem)
            end
        end
    end
    stacks
end


function move(movement_line, stacks)
    values = parse.(Int64, split(movement_line, " ")[2:2:end])

    numb, from_stack, to_stack = values
    
    for _ in 1:numb
        elem = pop!(stacks[from_stack])
        push!(stacks[to_stack], elem)
    end
end

stacks = build_stacks()

for movement in movements
    move(movement, stacks)
end

result = String([s[end] for s in stacks])

@info "In part one: the result is $result"

# Second Part

function move2(movement_line, stacks)
    values = parse.(Int64, split(movement_line, " ")[2:2:end])

    numb, from_stack, to_stack = values

    helper_stack = Vector{Char}()
    
    for _ in 1:numb
        push!(helper_stack, pop!(stacks[from_stack]))
    end

    for _ in 1:numb
        push!(stacks[to_stack], pop!(helper_stack))
    end
end

stacks = build_stacks()

for movement in movements
    move2(movement, stacks)
end

result = String([s[end] for s in stacks])

@info "In part two: the result is $result"
input = """R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
"""

movements = split(input, "\n")

movements = readlines("inputs/input_day09.txt")

N_PARTS = 10

snake = zeros(2, N_PARTS)

function distance(a, b)
    return max(abs(a[1] - b[1]), abs(a[2] - b[2]))
end

function tail_movement(head, tail)
    if distance(head, tail) >= 2
        return [sign(head[1] - tail[1]), sign(head[2] - tail[2])]
    end
    return [0, 0]
end

function move!(snake, direction)
    if direction == "U"
        snake[1, 1] += 1
    elseif direction == "D"
        snake[1, 1] -= 1
    elseif direction == "L"
        snake[2, 1] -= 1
    elseif direction == "R"
        snake[2, 1] += 1
    end
    for i in 2:N_PARTS
        snake[:, i] += tail_movement(snake[:, i - 1], snake[:, i])
    end
end

all_tail_positions = Set{Tuple{Int, Int}}()

for movement in movements
    if length(movement) < 3
        continue
    end
    direction, steps_str = split(movement, " ")
    steps = parse(Int, steps_str)
    for i in 1:steps
        move!(snake, direction)
        push!(all_tail_positions, (snake[end - 1], snake[end]))
    end
end

length(all_tail_positions)
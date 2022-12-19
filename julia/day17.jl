"""
  ....  
  ....   
  ....  
->####

  ....
  .#..
  ###.
->.#..

  ....  
  ..#.
  ..#.
->###.

  #...
  #...
  #...
->#...
  
  ....  
  ....
  ##..
->##..
"""

mutable struct Rock
    x::Int
    y::Int
    const points::Vector{Tuple{Int, Int}}
end

function Rock(x::Int, y::Int, type::Symbol)
    Rock(x, y, Val(type))
end

function Rock(x::Int, y::Int, ::Val{:horizontal})
    Rock(x, y, [(0, 0), (1, 0), (2, 0), (3, 0)])
end

function Rock(x::Int, y::Int, ::Val{:cross})
    Rock(x, y, [(2, 1), (1, 0), (1, 1), (1, 2), (0, 1)])
end

function Rock(x::Int, y::Int, ::Val{:edge})
    Rock(x, y, [(2, 2), (2, 1), (2, 0), (1, 0), (0, 0)])
end

function Rock(x::Int, y::Int, ::Val{:vertical})
    Rock(x, y, [(0, 3), (0, 2), (0, 1), (0, 0)])
end

function Rock(x::Int, y::Int, ::Val{:box})
    Rock(x, y, [(0, 1), (1, 1), (1, 0), (0, 0)])
end

function collison(edge_x::Int, edge_y::Int, points::Vector{Tuple{Int, Int}}, field::Matrix{Bool})

    for (x, y) in points
        x += edge_x
        y += edge_y
        x < 1 && return true
        x > size(field, 2) && return true

        field[y, x] && return true
    end
    return false
end

function move(rock::Rock, field::Matrix{Bool}; Δx=0, Δy=0)
    if collison(rock.x + Δx, rock.y + Δy, rock.points, field)
        return false
    else
        rock.x += Δx
        rock.y += Δy
        return true
    end
end

function move(rock::Rock, field::Matrix{Bool}, ::Val{:left})
    return move(rock, field, Δx=-1)
end

function move(rock::Rock, field::Matrix{Bool}, ::Val{:right})
    return move(rock, field, Δx=+1)
end

function move(rock::Rock, field::Matrix{Bool}, ::Val{:up})
    return move(rock, field, Δy=+1)
end

function move(rock::Rock, field::Matrix{Bool}, ::Val{:down})
    return move(rock, field, Δy=-1)
end

function move(rock::Rock, field::Matrix{Bool}, c::Char)
    if c == '>'
        move(rock, field, Val(:right))
    elseif c == '<'
        move(rock, field, Val(:left))
    else
        throw(ArgumentError("Invalid direction"))
    end
end

function add_rock(rock::Rock, field::Matrix)
    for (x, y) in rock.points
        field[rock.y + y, rock.x + x] = true
    end
end

function calc_highest(rock::Rock)
    return rock.y + rock.points[1][2]
end

function travel(rock_id, direction_id, highest, field, rock_order, directions)
    rock_symbol = rock_order[rock_id%5+1]
    rock = Rock(3, highest + 4, rock_symbol)
    not_fixed = true
    while not_fixed
        print(rock, field, 1:20)
        direction_id = direction_id % length(directions) + 1
        move(rock, field, directions[direction_id])
        print(rock, field, 1:20)
        if !move(rock, field, Val(:down))
            not_fixed = false
            add_rock(rock, field)
            highest = calc_highest(rock)
        end
    end
    return (rock_id + 1, direction_id, highest)
end

function Base.print(rock::Rock, field::Matrix{Bool}, c::UnitRange{Int})

    rock_points = [(rock.y + y, rock.x + x) for (x, y) in rock.points]

    for i in reverse(c)
        print('|')
        for j in 1:7
            if field[i, j]
                print('#')
            elseif (i, j) in rock_points
                print('@')
            else
                print('.')
            end
        end
        println('|')
    end
end

function Base.print(field::Matrix{Bool}, c::UnitRange{Int})

    for i in reverse(c)
        print('|')
        for j in 1:7
            if field[i, j]
                print('#')
            else
                print('.')
            end
        end
        println('|')
    end
end

function find_closing_distance(field::Matrix, highest::Int)
    i = 0
    res = field[highest, :]
    while !all(res)
        i += 1
        next = field[highest-i, :]
        res = res .|| next
    end
    return i
end

rock_order = [:horizontal, :cross, :edge, :vertical, :box]


inputs = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"
# inputs = read("inputs/input_day17.txt", String)

directions = collect(inputs)
directions = filter(x -> x != '\n', directions)

rock_number = 0
direction_id = 0
highest = 1

empty_field = fill(false, 16384, 7)

empty_field[1, :] .= true

field = copy(empty_field)

real_highest = BigInt(0)

i = 0
(rock_number, direction_id, highest) = travel(rock_number, direction_id, highest, field, rock_order, directions)
print(field, 1:20)
@show highest
(rock_number, direction_id, highest) = travel(rock_number, direction_id, highest, field, rock_order, directions)
print(field, 1:20)
@show highest
(rock_number, direction_id, highest) = travel(rock_number, direction_id, highest, field, rock_order, directions)
print(field, 1:20)
@show highest
(rock_number, direction_id, highest) = travel(rock_number, direction_id, highest, field, rock_order, directions)
print(field, 1:20)
@show highest
(rock_number, direction_id, highest) = travel(rock_number, direction_id, highest, field, rock_order, directions)
print(field, 1:20)
@show highest

for i in 0:(1_000_000_000_000 - 1)

    (rock_number, direction_id, highest) = travel(rock_number, direction_id, highest, field, rock_order, directions)
    closing_distance = find_closing_distance(field, highest)
    i += 1
    highest - closing_distance

    if (highest > 2^13) && (highest - closing_distance > 1)
        real_highest += highest
        window = field[highest-closing_distance:highest, :]
        field = copy(empty_field)
        field[2:closing_distance+2, :] = window
        highest = 1
        highest = calc_highest(field, highest)
        real_highest -= highest
    end

    if i % 1_000_000 == 0
        @show i
    end
end

1_000_000_000_000

highest = calc_highest(field, highest)
real_highest + highest - 1

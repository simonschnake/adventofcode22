using DataStructures

Rock = Matrix{Int}

function create_rock(sym::Symbol)::Rock
    if sym == :horizontal
        """
        ....  
        ####
        """
        return [0 0; 0 1; 0 2; 0 3]
    elseif sym == :cross
        """
        .#..
        ###.
        .#..
        """
        return [1 0; 1 1; 1 2; 0 1; 2 1]
    elseif sym == :edge
        """
        ..#.
        ..#.
        ###.
        """
        return [0 0; 0 1; 0 2; 1 2; 2 2]
    elseif sym == :vertical
        """
        #...
        #...
        #...
        #...
        """
        return [0 0; 1 0; 2 0; 3 0]
    elseif sym == :box
        """
        ....
        ##..
        ##..
        """
        return [0 0; 0 1; 1 0; 1 1]
    else
        error("Unknown symbol: $sym")
    end
end

function next_rock(rock::Symbol)
    Dict(
        :horizontal => :cross,
        :cross => :edge,
        :edge => :vertical,
        :vertical => :box,
        :box => :horizontal,
    )[rock]
end

function collison(y::Int, x::Int, points::SortedSet{Tuple{Int,Int}})
    x < 1 && return true
    x > 7 && return true
    (y, x) in points && return true
    return false
end

function collison(Δy::Int, Δx::Int, rock::Rock, points::SortedSet{Tuple{Int,Int}})
    for (y, x) in eachrow(rock)
        if collison(y + Δy, x + Δx, points)
            return true
        end
    end
    return false
end

function move(rock::Rock, points::SortedSet{Tuple{Int,Int}}; Δx::Int=0, Δy::Int=0)
    if collison(Δy, Δx, rock, points)
        return false
    else
        rock .+= [Δy Δx]
        return true
    end
end

function move(rock::Rock, points::SortedSet{Tuple{Int,Int}}, ::Val{:left})
    return move(rock, points, Δx=-1)
end

function move(rock::Rock, points::SortedSet{Tuple{Int,Int}}, ::Val{:right})
    return move(rock, points, Δx=+1)
end

function move(rock::Rock, points::SortedSet{Tuple{Int,Int}}, ::Val{:up})
    return move(rock, points, Δy=+1)
end

function move(rock::Rock, points::SortedSet{Tuple{Int,Int}}, ::Val{:down})
    return move(rock, points, Δy=-1)
end

function move(rock::Rock, points::SortedSet{Tuple{Int,Int}}, c::Char)
    if c == '>'
        move(rock, points, Val(:right))
    elseif c == '<'
        move(rock, points, Val(:left))
    else
        error("Unknown direction: $c")
    end
end

function add_rock(rock::Rock, points::SortedSet{Tuple{Int,Int}})
    for (y, x) in eachrow(rock)
        push!(points, (y, x))
    end
end

height(points::SortedSet{Tuple{Int,Int}}) = maximum(points)[1]

function trim(points::SortedSet{Tuple{Int,Int}})
    all_pos = fill(false, 7)
    last_y = 1
    for p in points
        (y, x) = p
        all_pos[x] = true
        if all(all_pos)
            last_y = y
            break
        end
    end

    if last_y == minimum(points)[1]
        return points
    end

    new_points = empty(points)

    for (y, x) in points
        y < last_y && break
        push!(new_points, (y - last_y + 1, x))
    end
    return new_points
end

function print_rock(rock::Rock, points::SortedSet{Tuple{Int,Int}})
    for y in reverse(1:(height(points)+7))
        print("|")
        for x in 1:7
            if (y, x) in points
                print("#")
            elseif [y, x] in eachrow(rock)
                print("@")
            else
                print(".")
            end
        end
        println("|")
    end
end

function print_rock(points::SortedSet{Tuple{Int,Int}})
    for y in reverse(1:(height(points)+1))
        print("|")
        for x in 1:7
            if (y, x) in points
                print("#")
            else
                print(".")
            end
        end
        println("|")
    end
end

mutable struct RockState
    points::SortedSet{Tuple{Int,Int}}
    next_rock::Symbol
    jet_id::Int
end

import Base: ==, copy

function ==(a::RockState, b::RockState)
    return (a.jet_id == b.jet_id) && (a.next_rock == b.next_rock) && (a.points == b.points)
end

function copy(state::RockState)
    return RockState(copy(state.points), state.next_rock, state.jet_id)
end

function RockState(; points::SortedSet{Tuple{Int,Int}}=SortedSet{Tuple{Int,Int}}(Base.Order.Reverse), next_rock::Symbol=:horizontal, jet_id::Int=1)
    isempty(points) && [push!(points, (0, x)) for x in 1:7] # add base
    return RockState(points, next_rock, jet_id)
end

function travel(state::RockState, input::String)
    rock = create_rock(state.next_rock) .+ [(height(state.points) + 4) 3]
    while true
        move(rock, state.points, input[state.jet_id])
        state.jet_id = state.jet_id % length(input) + 1
        if !move(rock, state.points, Val(:down))
            break
        end
    end
    add_rock(rock, state.points)
    h = height(state.points)
    state.points = trim(state.points)
    h = h - height(state.points)
    state.next_rock = next_rock(state.next_rock)
    return state, h
end

test_input = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"
input = read("inputs/input_day17.txt", String)
input = filter(c -> c != '\n', input)

x₀ = RockState()


# Main phase of algorithm: finding a repetition x_i = x_2i.
# The hare moves twice as quickly as the tortoise and
# the distance between them increases by 1 at each step.
# Eventually they will both be inside the cycle and then,
# at some point, the distance between them will be
# divisible by the period λ.
tortoise, _ = travel(copy(x₀), input) # f(x0) is the element/node next to x0.
hare, _ = travel(copy(x₀), input)     # f(f(x0)) is the element/node two nodes away.
hare, _ = travel(hare, input)         

while tortoise != hare
    tortoise, _ = travel(tortoise, input)
    hare, _ = travel(hare, input)
    hare, _ = travel(hare, input)
end

# At this point the tortoise position, ν, which is also equal
# to the distance between hare and tortoise, is divisible by
# the period λ. So hare moving in circle one step at a time, 
# and tortoise (reset to x0) moving towards the circle, will 
# intersect at the beginning of the circle. Because the 
# distance between them is constant at 2ν, a multiple of λ,
# they will agree as soon as the tortoise reaches index μ.

# Find the position μ of first repetition.    
μ = 0
tortoise = copy(x₀)
while tortoise != hare
    tortoise, _ = travel(tortoise, input)
    hare, _ = travel(hare, input) # Hare and tortoise move at same speed
    μ += 1
end

# Find the length of the shortest cycle starting from x_μ
# The hare moves one step at a time while tortoise is still.
# lam is incremented until λ is found.
λ = 1
hare, _ = travel(copy(tortoise), input)
while tortoise != hare
    hare, _ = travel(hare, input)
    λ += 1
end

println("μ = $μ, λ = $λ")

x, h = travel(copy(x₀), input)

for i in 2:μ
    x, Δh = travel(x, input)
    h += Δh
end

println("Part 1: $h")

h_μ = h

h = 0

for i in 1:λ
    x, Δh = travel(x, input)
    h += Δh
end

h_λ = h

n = (2022 - μ) ÷ λ
rest = (2022 - μ) % λ

n = (1_000_000_000_000 - μ) ÷ λ
rest = (1_000_000_000_000 - μ) % λ

h = 0

for i in 1:rest
    x, Δh = travel(x, input)
    h += Δh
end

h_rest = h + height(x.points)

println("Part 2: $(h_μ + n * h_λ + h_rest)")
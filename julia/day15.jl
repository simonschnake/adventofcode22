inputs = """
Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3
"""

inputs = read("inputs/inputs_day15.txt", String)

# split into lines
inputs = split(inputs, "\n")

# remove empty lines
inputs = filter(x -> length(x) > 0, inputs)

inputs = map(inputs) do input
    map(eachmatch(r"-?\d+", input)) do input
        parse(Int, input.match)
    end
end

function manhatten_distance(x::CartesianIndex, y::CartesianIndex)
    sum(abs.(x.I .- y.I))
end

function manhatten_distance(x::Vector, y::Vector)
    sum(abs.(x .- y))
end

target_y = 2000000

function get_confirmed(inputs, target_y)
    confirmed = []
    confirmed_beacon = []
    for input in inputs
        sensor = input[1:2]
        beacon = input[3:4]

        if beacon[2] == target_y
            push!(confirmed_beacon, beacon[1])
        end

        b_s_dst = manhatten_distance(sensor, beacon)

        dy = abs(sensor[2] - target_y)
        if dy <= b_s_dst
            dx = b_s_dst - dy
            push!(confirmed, (sensor[1]-dx:sensor[1]+dx))
        end
    end
    confirmed, confirmed_beacon
end

using BenchmarkTools

@benchmark confirmed, confirmed_beacon = get_confirmed(inputs, target_y)

confirmed = Set(vcat(confirmed...))

@show result_part_1 = length(setdiff(confirmed, Set(confirmed_beacon)))

r = 4000000

@benchmark get_confirmed(inputs, 11)

confirmed, _ = get_confirmed(inputs, 11)

function is_complete(confirmed, end_val)
    sort!(confirmed, by = x -> x.start)
    next = iterate(confirmed)
    c, s = next
    start = max(c.start, 0)
    stop = max(c.stop, 0)
    if start > 0
        return false
    end
    while next !== nothing
        if stop >= end_val
            return true
        end

        next = iterate(confirmed, s)
        c, s = next
        next_start, next_stop = c.start, c.stop
        next_start = max(next_start, 0)
        if (next_start - 1) <= stop
            stop = max(stop, next_stop)
        else
            println("not complete current stop: x is $(stop+1)")
            return false
        end
    end

    return false
end

a = Set{UnitRange{Int64}}()

push!(a, 1:6)

push!(a, 2:6)
@benchmark is_complete(confirmed, 1_000_000)


for y in 1:4_000_000
    confirmed, _ = get_confirmed(inputs, y)
    if !is_complete(confirmed, r)
        @show y
        break
    end
end

confirmed, _ = get_confirmed(inputs, 3204261)


Set(vcat(collect.(confirmed)...)) ∩ Set(0:4_000_000)

sort!(confirmed, by = x -> x.start)
    
next = iterate(confirmed)
c, s = next
start = max(c.start, 0)
stop = max(c.stop, 0)

next = iterate(confirmed, s)
c, s = next
        
next_start, next_stop = c.start, c.stop
next_start = max(next_start, 0)

stop
next_start

if (next_start - 1) <= (stop + 1)
    stop = max(stop, next_stop)
else
    return false
end

@show result_part2 = 3156345 * 4000000 + 3204261
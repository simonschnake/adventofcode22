inputs = """
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
"""
 
inputs = read("inputs/input_day16.txt", String)

# split into lines
inputs = split(inputs, "\n")

# remove empty lines
inputs = filter(x -> length(x) > 0, inputs)

struct Valve
    name::String
    flow_rate::Int
    tunnels::Vector{String}
end

regex = r"Valve (\w+) has flow rate=(\d+); tunnel(s?) lead(s?) to valve(s?) (\w+)(, )?(\w+)?(, )?(\w+)?(, )?(\w+)?(, )?(\w+)?(, )?(\w+)?(, )?(\w+)?"

inputs = map(inputs) do input
    matches = match(regex, input).captures

    name = String(matches[1])
    flow_rate = parse(Int, matches[2])
    tunnels = filter(x -> !isnothing(x) && x != ", ", matches[6:end])
    
    Valve(name, flow_rate, tunnels)
end

valves = Dict(zip(map(x -> x.name, inputs), inputs))

# compute all distances for each valve

function dijkstra(start_valve::Valve)
    distances = Dict([name => Inf for name in keys(valves)])
    distances[start_valve.name] = 0
    
    visited = Set{String}()

    queue = [start_valve]

    while !isempty(queue)
        queue = sort(queue, by=x -> distances[x.name])
        current = popfirst!(queue)

        push!(visited, current.name)

        # update distances
        for tunnel in current.tunnels
            neighbor = valves[tunnel]
            distances[neighbor.name] = min(distances[neighbor.name], distances[current.name] + 1)

            # add neighbors to queue
            if !(in(tunnel, visited) || in(neighbor, queue))
                push!(queue, neighbor)
            end
        end
    end

    distances
end

distances = Dict([key => dijkstra(val) for (key, val) in valves]...)
flow_rate = Dict([key => val.flow_rate for (key, val) in valves]...)

MAX_STEPS = 30

total_pressure_released(flow_rate, step) = flow_rate * (MAX_STEPS - step)

function generate_path(valve, other_valves, path, steps, result)

    push!(all_paths, path => result)

    other_valves = filter(other_valves) do x
        x != valve
    end

    for next_valve in other_valves
        new_path = path * " -> " * next_valve
        new_steps = steps + distances[valve][next_valve] + 1
        if new_steps > MAX_STEPS
            continue
        end
        new_result = result + total_pressure_released(flow_rate[next_valve], new_steps)

        generate_path(next_valve, other_valves, new_path, new_steps, new_result)      
    end 
end

all_valves = keys(valves) |> collect

filter!(all_valves) do x
    flow_rate[x] > 0
end

all_paths = Dict()
generate_path("AA", all_valves, "AA", 0, 0)

all_paths

maximum(all_paths) do x
    x[2]
end


# part 2

MAX_STEPS = 26

function generate_path(my_valve, elephant_valve, other_valves, path, my_steps, elephant_steps, result)

    push!(all_paths, path => result)

    other_valves = filter(other_valves) do x
        x != my_valve && x != elephant_valve
    end

    for my_next_valve in other_valves
        my_new_path = path * " -> (" * my_next_valve
        my_new_steps = my_steps + distances[my_valve][my_next_valve] + 1
        if my_new_steps > MAX_STEPS
            continue
        end

        my_new_result = result + total_pressure_released(flow_rate[my_next_valve], my_new_steps)

        my_other_valves = filter(other_valves) do x
            x != my_next_valve
        end

        for elephant_next_valve in my_other_valves
            elephant_new_path = my_new_path * "|" * elephant_next_valve * ")"
            elephant_new_steps = elephant_steps + distances[elephant_valve][elephant_next_valve] + 1
            if elephant_new_steps > MAX_STEPS
                continue
            end

            elephant_new_result = my_new_result + total_pressure_released(flow_rate[elephant_next_valve], elephant_new_steps)

            generate_path(my_next_valve, elephant_next_valve, my_other_valves, elephant_new_path, my_new_steps, elephant_new_steps, elephant_new_result)      
        end
    end 
end

all_valves = keys(valves) |> collect

filter!(all_valves) do x
    flow_rate[x] > 0
end

all_paths = Dict()
generate_path("AA", "AA", all_valves, "(AA|AA)", 0, 0, 0)

all_paths

@show maximum(all_paths) do x
    x[2]
end

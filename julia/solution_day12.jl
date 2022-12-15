input = """
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
"""

input = read("inputs/input_day12.txt", String)


n_col = findfirst(isequal('\n'), input) - 1
input = filter(!isequal('\n'), input)
n_row = length(input) ÷ n_col

indices = CartesianIndices((n_col, n_row))
start_coord = indices[findfirst(isequal('S'), input)]
end_node = indices[findfirst(isequal('E'), input)]


heights = Array{Int,2}(undef, n_col, n_row)

for (i, c) in enumerate(input)
    if c == 'S'
        heights[i] = 1
    elseif c == 'E'
        heights[i] = 'z' - 'a' + 1
    else
        heights[i] = c - 'a' + 1
    end
end

function neighbors(coord)
    results = coord - CartesianIndex.(1, 0), coord + CartesianIndex.(1, 0),
    coord - CartesianIndex.(0, 1), coord + CartesianIndex.(0, 1)
    global indices
    filter(x -> x in indices, results)
end

function connection(coord1, coord2)
    global heights
    (heights[coord2] - heights[coord1]) <= 1
end

function not_visited_neightbor_nodes(coord, visited)
    coords = neighbors(coord)    
    global heights
    coords = filter(x -> connection(coord, x), coords)
    coords = filter(x -> !visited[x], coords)

    coords
end


function dijkstra(start_coord)
    visited = fill(false, n_col, n_row)
    distance = fill(Inf, n_col, n_row)
    distance[start_coord] = 0

    queue = [start_coord]
    while !isempty(queue)
        queue = sort(queue, by=x -> distance[x])
        current = popfirst!(queue)
        if current == end_node
            break
        end
        visited[current] = true
        for neighbor in not_visited_neightbor_nodes(current, visited)
            distance[neighbor] = min(distance[neighbor], distance[current] + 1)
            if !in(neighbor, queue)
                push!(queue, neighbor)
            end
        end
    end

    distance[end_node]
end

dijkstra(start_coord)

other_starts = indices[findall(isequal('a'), input)]

minimum(dijkstra.(other_starts))
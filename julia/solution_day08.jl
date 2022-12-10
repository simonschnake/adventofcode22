# read input char by char

lines = readlines("inputs/input_day08.txt")

#=
lines = "30373
25512
65332
33549
35390"

lines = split(lines, "\n")
=#

# parse one line into a vector of Ints
function parse_line(line)
    return [parse(Int, c) for c in line]
end

tree_matrix = hcat([parse_line(line) for line in lines]...)

function is_visible(a::Int, b::Vector{Int})::Bool
    if length(b) == 0
        return true
    end
    return a > maximum(b)
end

function get_all_four_sides(ci::CartesianIndex{2}, tree_matrix::Array{Int, 2})
    val = tree_matrix[ci]
    right_side = tree_matrix[ci[1], ci[2]+1:end]
    left_side = tree_matrix[ci[1], ci[2]-1:-1:begin]
    upper_side = tree_matrix[ci[1]+1:end, ci[2]]
    lower_side = tree_matrix[ci[1]-1:-1:begin, ci[2]]
    return val, right_side, left_side, upper_side, lower_side
end

function check_tree_visible(tree_matrix::Matrix{Int64}, ci::CartesianIndex{2})
    val, right_side, left_side, upper_side, lower_side = get_all_four_sides(ci, tree_matrix)
    if is_visible(val, right_side) || is_visible(val, left_side) || is_visible(val, upper_side) || is_visible(val, lower_side)
        return true
    end
    return false
end

function count_trees(tree_matrix::Matrix{Int64})
    count = 0
    for ci in CartesianIndices(tree_matrix)
        if check_tree_visible(tree_matrix, ci)
            count += 1
        end
    end
    return count
end

count_trees(tree_matrix)

# Part 2

function viewing_distance(a::Int, b::Vector{Int})::Int
    if length(b) == 0
        return 0
    end
    count = 0
    for i in b
        count += 1
        if i >= a
            return count
        end
    end
    return count
end

function viewing_score(tree_matrix::Matrix{Int64}, ci::CartesianIndex{2})
    val, right_side, left_side, upper_side, lower_side = get_all_four_sides(ci, tree_matrix)
    return viewing_distance(val, right_side) * viewing_distance(val, left_side) * viewing_distance(val, upper_side) * viewing_distance(val, lower_side)
end

viewing_score(tree_matrix, CartesianIndex(3, 2))

function get_best_viewing_score(tree_matrix::Matrix{Int64})
    best_score = 0
    for ci in CartesianIndices(tree_matrix)
        score = viewing_score(tree_matrix, ci)
        if score > best_score
            best_score = score
        end
    end
    return best_score
end

get_best_viewing_score(tree_matrix)
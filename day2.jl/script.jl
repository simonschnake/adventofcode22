input = readlines("day2.jl/input.txt")

points = Dict(
    :rock => 1,
    :paper => 2,
    :scissors => 3,
    :lost => 0,
    :draw => 3,
    :win => 6,
)


outcome(opponent::Symbol, mine::Symbol) = outcome(Val(opponent), Val(mine))

outcome(::Val{:rock}, ::Val{:rock}) = :draw
outcome(::Val{:rock}, ::Val{:paper}) = :win
outcome(::Val{:rock}, ::Val{:scissors}) = :lost

outcome(::Val{:paper}, ::Val{:paper}) = :draw
outcome(::Val{:paper}, ::Val{:scissors}) = :win
outcome(::Val{:paper}, ::Val{:rock}) = :lost

outcome(::Val{:scissors}, ::Val{:scissors}) = :draw
outcome(::Val{:scissors}, ::Val{:rock}) = :win
outcome(::Val{:scissors}, ::Val{:paper}) = :lost

function total_points(opponent::Symbol, mine::Symbol)
    match_result = outcome(opponent, mine)
    points[match_result] + points[mine]
end

letter_to_symbol = Dict(
    'A' => :rock,
    'B' => :paper,
    'C' => :scissors,
    'X' => :rock,
    'Y' => :paper,
    'Z' => :scissors
)

function line_to_symbols(line::String)
    opponent = letter_to_symbol[line[1]]
    mine = letter_to_symbol[line[3]]
    opponent, mine
end

total_points_per_line(line::String) = total_points(line_to_symbols(line)...)


# result for first part
println("Result first part: ", sum(total_points_per_line.(input)))


######################################
# second part

get_hand_for_outcome(opponent::Symbol, outcome::Symbol) = get_hand_for_outcome(Val(opponent), Val(outcome))

get_hand_for_outcome(::Val{:rock}, ::Val{:draw}) = :rock
get_hand_for_outcome(::Val{:rock}, ::Val{:win}) = :paper
get_hand_for_outcome(::Val{:rock}, ::Val{:lost}) = :scissors
get_hand_for_outcome(::Val{:paper}, ::Val{:draw}) = :paper
get_hand_for_outcome(::Val{:paper}, ::Val{:win}) = :scissors
get_hand_for_outcome(::Val{:paper}, ::Val{:lost}) = :rock
get_hand_for_outcome(::Val{:scissors}, ::Val{:draw}) = :scissors
get_hand_for_outcome(::Val{:scissors}, ::Val{:win}) = :rock
get_hand_for_outcome(::Val{:scissors}, ::Val{:lost}) = :paper

letter_to_symbol = Dict(
    'A' => :rock,
    'B' => :paper,
    'C' => :scissors,
    'X' => :lost,
    'Y' => :draw,
    'Z' => :win
)

function total_points2(opponent::Symbol, outcome::Symbol)
    mine = get_hand_for_outcome(opponent, outcome)
    points[outcome] + points[mine]
end

total_points_per_line2(line::String) = total_points2(line_to_symbols(line)...)


# result for second part
println("Result second part: ", sum(total_points_per_line2.(input)))

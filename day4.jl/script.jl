# First Part

input = readlines("day4.jl/input.txt")

one_contains_the_other(a, b) = (a ⊆ b) || (b ⊆ a)

string_to_range(s) = eval(Meta.parse(replace(s, "-"=>":")))

function result_per_line(line::String, fun::Function)
    a, b = split(line, ",")
    a = string_to_range(a)
    b = string_to_range(b)

    fun(a,b)
end

result = sum((x -> result_per_line(x, one_contains_the_other)).(input))

@info "In part one: the result is $result"

# Second Part

overlap(a, b) = !isempty(collect(a) ∩ collect(b))

result = sum((x -> result_per_line(x, overlap)).(input))

@info "In part two: the result is $result"


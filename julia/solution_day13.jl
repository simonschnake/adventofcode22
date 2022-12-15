inputs = """
[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
"""

inputs = read("inputs/input_day13.txt", String)

# split into lines
inputs = split(inputs, "\n")

# remove empty lines
inputs = filter(x -> length(x) > 0, inputs)

inputs = @. eval(Meta.parse(inputs))

inputs = reshape(inputs, 2, :)

lt(l::Int, r::Int) = l < r
lt(l::Vector, r::Int) = lt(l, [r])
lt(l::Int, r::Vector) = lt([l], r)
lt(l::Vector, r::Vector) = begin
    !isempty(r) &&                  # if r is empty, l is not less than r -> wrong order
    (isempty(l) ||                  # if l is empty, l is less than r -> right order
    lt(l[1], r[1]) ||               # if l[1] < r[1], l is less than r -> right order
    (!lt(r[1], l[1])                # if l[1] == r[1], check the rest
    && lt(l[2:end], r[2:end])))     # check the rest
end

global sum_i = 0

for (i, c) in enumerate(eachcol(inputs))
    left, right = c
    if lt(left, right) == true
        println("Input $i is in right order")
        global sum_i += i
    end
end

println("Sum of indexess of inputs in right order: $sum_i")

# Second part
inputs = reshape(inputs, :)

push!(inputs, [[2]])
push!(inputs, [[6]])

sort!(inputs, lt=lt)

a = findfirst(x -> x == [[2]], inputs)
b = findfirst(x -> x == [[6]], inputs)

a * b
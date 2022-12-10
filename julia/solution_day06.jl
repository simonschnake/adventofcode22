# First Part

input = read("day6.jl/input.txt", String)

uniqe_4_characters(pos) = (length(unique(input[pos:pos+3])) == 4)

result = findfirst(uniqe_4_characters, 1:length(input)-4) + 3

@info "In part one: the result is $result"

# Second Part
uniqe_14_characters(pos) = (length(unique(input[pos:pos+13])) == 14)
result = findfirst(uniqe_14_characters, 1:length(input)-14) + 13

@info "In part two: the result is $result"


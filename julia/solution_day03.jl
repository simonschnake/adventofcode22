# First Part

input = readlines("test.txt")

function priority(x::Char)
    """
    To help prioritize item rearrangement, every item type can be converted to a priority:

    Lowercase item types a through z have priorities 1 through 26.
    Uppercase item types A through Z have priorities 27 through 52.
    """
    if isuppercase(x)
        return x - 'A' + 27
    else
        return x - 'a' + 1
    end
end

priority(x::Vector{Char}) = sum(priority.(x))

function split_half(s::String)
    """
    Split string in half.
    """
    half = length(s) ÷ 2
    s[1:half], s[half+1:end]
end

function priority(x::String)
    a, b = split_half(x)
    chars = a ∩ b
    priority(chars)
end

@show priority.(input)
total_priorities = sum(priority.(input))

@info "Result of first part: the total priorities are $total_priorities"

# Second Part

# arange elves togehter
input = reshape(input, 3, :)

priorities = map(eachcol(input)) do x
    common_chars = intersect(x...)
    priority(common_chars[1])
end

total_priorities = sum(priorities)

@info "Result of second part: the total priorities are $total_priorities"



length(input[1])

input[1][01:12]
input[1][13:24]

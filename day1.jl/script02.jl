input = readlines("day1.jl/input.txt")

function elves_summed_calories(input)
    cur_calories = 0
    summed_calories = Int64[]

    for i in input
        if i == ""
            push!(summed_calories, cur_calories)
            cur_calories = 0
        else
            cur_calories += parse(Int64, i)
        end
    end

    summed_calories
end

calories = elves_summed_calories(input)

sort!(calories, rev=true)

total_calories = sum(calories[1:3])
max_calories = calories[1]

println("max calories carried by a elve are $max_calories") 
println("total calories of top three elves are $total_calories")
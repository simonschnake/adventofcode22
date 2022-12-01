input = readlines("day1_1/input.txt")

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

sort!(calories)

total_calories = sum(calories[end-2:end])
max_calories = calories[end]

println("max calories carried by a elve are $max_calories") 
println("total calories of top three elves are $total_calories")
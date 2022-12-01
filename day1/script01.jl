input = readlines("day1_1/input.txt")

function find_max(input)
    max_calories = 0
    cur_calories = 0

    for i in input
        if i == ""
            max_calories = max(cur_calories, max_calories)
            cur_calories = 0
        else
            cur_calories += parse(Int64, i)
        end
    end

    max_calories
end

max_calories = find_max(input)

println("max calories are $max_calories")
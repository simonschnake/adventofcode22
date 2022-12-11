inputs = """Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1"""

inputs = read("inputs/input_day11.txt", String)

inputs = split(inputs, "\n\n")

mutable struct Monkey
    items::Vector{BigInt}
    n_inspections::Int
    const op::String
    const val::Int
    const test_val::Int
    const if_true::Int
    const if_false::Int
end

function Monkey(input)
    lines = split(input, "\n")
    items = parse.(Int, split(lines[2][19:end], ", "))
    if (endswith(lines[3], "new = old * old"))
        op = "**"
        val = 0
    else
        op = split(lines[3], " ")[end-1]
        val = parse(Int, split(lines[3], " ")[end])
    end
    test_val = parse(Int, split(lines[4], " ")[end])
    if_true = parse(Int, split(lines[5], " ")[end])
    if_false = parse(Int, split(lines[6], " ")[end])
    return Monkey(items, 0, op, val, test_val, if_true, if_false)
end

monkeys = Monkey.(inputs)


function do_op(m::Monkey, item::BigInt)
    if m.op == "*"
        return item * m.val
    elseif m.op == "+"
        return item + m.val
    elseif m.op == "**"
        return item * item
    else
        error("unknown op")
    end
end

function do_test(m::Monkey, item::BigInt)
    return item % m.test_val == 0
end

function increase_inspections(m::Monkey)
    m.n_inspections += 1
end


function one_round()
    for m in monkeys
        while length(m.items) > 0
            item = popfirst!(m.items)
            item = do_op(m, item)
            increase_inspections(m)
            item = item % prod(getproperty.(monkeys, :test_val))
            if do_test(m, item)
                push!(monkeys[m.if_true+1].items, item)
            else
                push!(monkeys[m.if_false+1].items, item)
            end
        end
    end
end

monkeys = Monkey.(inputs)
[one_round() for _ in 1:10_000]

print(getproperty.(monkeys, :n_inspections))

prod(sort(getproperty.(monkeys, :n_inspections), rev=true)[1:2])


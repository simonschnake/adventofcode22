lines = readlines("inputs/input_day10.txt")

disp = fill('.', 40, 6)

n_reg = 1
n_cyc = 0
sum_of_strengths = 0


function do_after_cyc()
    # get globals
    global n_reg
    global n_cyc
    global sum_of_strengths
    global disp

    # first part
    if (n_cyc >= 20 == 0 && (n_cyc - 20) % 40 == 0)
        println("cycle: $n_cyc \t register: $n_reg")
        sum_of_strengths += n_reg * n_cyc
    end

    # second part

    row = (n_cyc - 1) ÷ 40 + 1
    col = (n_cyc - 1) % 40 + 1

    if ((col - 1) >= n_reg - 1 && (col - 1) <= n_reg + 1)
        disp[col, row] = '#';
    end
end

for line in lines
    if length(line) == 0
        continue
    end

    if startswith(line, "noop")
        global n_cyc += 1
        do_after_cyc()
    else
        _, val = split(line, " ")
        val = parse(Int, val)
        n_cyc += 1
        do_after_cyc()
        n_cyc += 1
        do_after_cyc()
        n_reg += val
    end
end

for i in 1:6
    println(String(disp[:, i]))
end
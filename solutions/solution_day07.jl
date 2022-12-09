using Revise
includet("solutions_day07_util.jl")

input = readlines("inputs/input_day07_test1.txt")

ROOT = File("/");

# ls are not needed
input = filter(x -> x != "\$ ls", input)
# remove all "\$ " from the beginning of the lines
input = map(x -> replace(x, r"^\$ " => ""), input)

cur_dir = ROOT
for line in input
    if startswith(line, "cd")
        if line == "cd .."
            cur_dir = cur_dir.parent
        elseif line == "cd /"
            cur_dir = ROOT
        else
            dir_name = String(split(line, " ")[2])
            cur_dir = File(cur_dir, dir_name)
        end
    elseif startswith(line, "dir")
        dir_name = String(split(line, " ")[2])
        File(cur_dir, dir_name)
    else
        size = parse(Int, split(line, " ")[1])
        file_name = String(split(line, " ")[2])
        File(cur_dir, file_name, size)
    end
end

function print_tree(file::File, indent::Int)
    println("  "^indent, file, " size: ", file.size)
    for child in file.children
        print_tree(child, indent+1)
    end
end

print_tree(ROOT, 0)

sizes = Int[]

function add_sizes(file::File)
    push!(sizes, file.size)
    for child in file.children
        if length(child.children) > 0
            add_sizes(child)
        end
    end
end

add_sizes(ROOT)
sizes
sizes
sum(sizes[sizes .< 100_000])

avail = (70_000_000 - ROOT.size)
needed = 30_000_000 - avail

minimum(sizes[sizes .>= needed])
test_input = """
1
2
-3
3
-2
0
4
"""

input = read("inputs/input_day20.txt", String)

test_input = parse.(Int, filter(!isempty, split(test_input, '\n')))
input = parse.(Int, filter(!isempty, split(input, '\n')))

mutable struct Node
    value::Int
    prev::Union{Node,Nothing}
    next::Union{Node,Nothing}
end

function Node(value::Int)
    Node(value, nothing, nothing)
end

function Node(values::Vector{Int})
    nodes = Node.(values)
    for i in eachindex(nodes)
        nodes[i].prev = nodes[mod1(i - 1, length(nodes))]
        nodes[i].next = nodes[mod1(i + 1, length(nodes))]
    end
    return nodes
end

function next(node::Node)
    return node.next
end

function prev(node::Node)
    return node.prev
end

import Base: getindex, setindex!, length, iterate, eltype, show, print

function show(io::IO, node::Node)
    print(io, "[(", node.value, "|", node.moved, "), ")
    next_node = next(node)
    while next_node != prev(node) && next_node !== nothing
        print(io, "(", next_node.value, "|", next_node.moved, "), ")
        next_node = next(next_node)
    end
    print(io, "(", next_node.value, "|", next_node.moved, ")]")
end

function print(node::Node)
    show(stdout, node)
end

function getindex(node::Node, i::Int)
    res = node
    if i < 0
        res = prev(node)
    end
    while i < 0
        res = prev(res)
        i += 1
    end

    while i > 0
        res = next(res)
        i -= 1
    end
    return res
end

function move!(node::Node; length::Int)
    val = node.value % (length - 1)

    if val == 0
        return true, next(node)
    end

    old_prev = prev(node)
    old_next = next(node)
    new_prev = getindex(node, val)
    new_next = next(new_prev)


    old_prev.next = node.next
    old_next.prev = node.prev

    node.prev = new_prev
    node.next = new_next
    new_prev.next = node
    new_next.prev = node

    return true, old_next
end

function length(node::Node)
    n = 1
    next_node = next(node)
    while next_node != node
        n += 1
        next_node = next(next_node)
    end
    return n
end

function move!(nodes::Vector{Node})
    l = length(nodes)
    for node in nodes
        move!(node, length=l)
    end
end

import Base: findfirst

function findfirst(node::Node, val)
    while node.value != val && node.next != node
        node = next(node)
    end
    return node
end

function multiply_by!(nodes::Vector{Node}, n::Int)
    for node in nodes
        node.value *= n
    end
end

nodes = Node(input);
move!(nodes)
node = findfirst(nodes[1], 0);
res = node[1000].value + node[2000].value + node[3000].value

nodes = Node(input);
multiply_by!(nodes, 811589153)

for _ in 1:10
    move!(nodes)
end

node = findfirst(nodes[1], 0);
res = node[1000].value + node[2000].value + node[3000].value

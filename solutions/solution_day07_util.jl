mutable struct File
    name::String
    size::Int
    children::Vector{File}
    parent::File
    File(name, size) = begin
        file = new()
        file.name = name
        file.size = size
        file.children = File[]
        file
    end
end

File(name::String) = File(name, 0)

function File(parent_dir::File, name::String)
    if (c = child(parent_dir, name)) !== nothing
        return c
    end
    dir = File(name)
    dir.parent = parent_dir
    push!(parent_dir.children, dir)
    dir
end

function File(parent_dir::File, name::String, size::Int)
    if (c = child(parent_dir, name)) !== nothing
        return c
    end
    file = File(name, size)
    file.parent = parent_dir
    push!(parent_dir.children, file)
    pd = parent_dir
    while pd.name != "/"
        pd.size += size
        pd = pd.parent
    end
    pd.size += size
    file
end

function child(file::File, name::String)
    for child in file.children
        if child.name == name
            return child
        end
    end
    return nothing
end

Base.show(io::IO, file::File) = print(io, "$(file.name) ($(file.size))")



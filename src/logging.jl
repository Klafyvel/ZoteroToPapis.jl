LIST_MARKERS = ["⋅", "∘", "-"]
function format_list_item(io, item, indent = 0)
    sp = " " * "  "^indent
    marker = LIST_MARKERS[indent + 1]
    write(io, sp)
    write(io, marker)
    write(io, " ")
    for (i, line) in enumerate(split(item, "\n"))
        if i > 1
            write(io, sp)
            write(io, "  ")
        end
        write(io, line)
        write(io, "\n")
    end
end

function format_structured_list(io, list, indent = 0)
    for item in list
        if item isa Vector
            format_structured_list(io, item, indent + 1)
        else
            format_list_item(io, item, indent)
        end
    end
end

function format_structured_list(list)
    io = IOBuffer()
    format_structured_list(io, list)
    String(take!(io))
end

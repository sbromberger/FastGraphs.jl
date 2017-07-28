# The format of simplegraph files is as follows:
# a one line header: <num_vertices>, <num_edges>, {"d" | "u"}, <name>
#   - num_vertices is an integer
#   - num_edges is an integer
#   - "d" for directed graph, "u" for undirected. Note that this
#       option does not perform any additional edge construction; it's
#       merely used to return the correct type of graph.
#   - name is a string
# header followed by a list of (comma-delimited) edges - src,dst.
# Multiple graphs may be present in one file.


struct LGFormat <: AbstractGraphFormat end


function _lg_read_one_graph(f::IO, n_v::Integer, n_e::Integer, directed::Bool)
    if directed
        g = DiGraph(n_v)
    else
        g = Graph(n_v)
    end
    for i = 1:n_e
        line = chomp(readline(f))
        if length(line) > 0
            src_s, dst_s = split(line, r"\s*,\s*")
            src = parse(Int, src_s)
            dst = parse(Int, dst_s)
            add_edge!(g, src, dst)
        end
    end
    return g
end

function _lg_skip_one_graph(f::IO, n_e::Integer)
    for _ in 1:n_e
        readline(f)
    end
end

"""
    loadlg_mult(io)

Return a dictionary of (name=>graph) loaded from IO stream `io`.
"""
function loadlg_mult(io::IO)
    graphs = Dict{String,AbstractGraph}()
    while !eof(io)
        line = strip(chomp(readline(io)))
        if startswith(line, "#") || line == ""
            next
        else
            nvstr, nestr, dirundir, graphname = split(line, r"s*,s*", limit=4)
            n_v = parse(Int, nvstr)
            n_e = parse(Int, nestr)
            dirundir = strip(dirundir)
            graphname = strip(graphname)
            directed = !(dirundir == "u")

            g = _lg_read_one_graph(io, n_v, n_e, directed)
            graphs[graphname] = g
        end
    end
    return graphs
end

function loadlg(io::IO, gname::String)
    while !eof(io)
        line = strip(chomp(readline(io)))
        (startswith(line, "#") || line == "") && continue
        nvstr, nestr, dirundir, graphname = split(line, r"s*,s*", limit=4)
        n_v = parse(Int, nvstr)
        n_e = parse(Int, nestr)
        graphname = strip(graphname)
        if gname == graphname
            dirundir = strip(dirundir)
            directed = !(dirundir == "u")
            return _lg_read_one_graph(io, n_v, n_e, directed)
        else
            _lg_skip_one_graph(io, n_e)
        end
    end
    error("Graph $gname not found")
end

"""
    savelg(io, g, gname)

Write a graph `g` with name `gname` in a proprietary format
to the IO stream designated by `io`. Return 1 (number of graphs written).
"""
function savelg(io::IO, g::AbstractGraph, gname::String)
    # write header line
    dir = is_directed(g) ? "d" : "u"
    line = join([nv(g), ne(g), dir, gname], ",")
    write(io, "$line\n")
    # write edges
    for e in edges(g)
        write(io, "$(src(e)),$(dst(e))\n")
    end
    return 1
end

"""
    savelg_mult(io, graphs)

Write a dictionary of (name=>graph) to an IO stream `io`,
with default `GZip` compression. Return number of graphs written.
"""
function savelg_mult(io::IO, graphs::Dict)
    ng = 0
    for (gname, g) in graphs
        ng += savelg(io, g, gname)
    end
    return ng
end


loadgraph(io::IO, gname::String, ::LGFormat) = loadlg(io, gname)
loadgraphs(io::IO, ::LGFormat) = loadlg_mult(io)
savegraph(io::IO, g::AbstractGraph, gname::String, ::LGFormat) = savelg(io, g, gname)
savegraph(io::IO, g::AbstractGraph, ::LGFormat) = savelg(io, g, "graph")
savegraph(io::IO, d::Dict, ::LGFormat) = savelg_mult(io, d)

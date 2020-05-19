"""
    complement(g)

Return the [graph complement](https://en.wikipedia.org/wiki/Complement_graph)
of a graph.

### Implementation Notes
Preserves the `eltype` of the input graph.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> foreach(println, edges(complement(g)))
Edge 1 => 3
Edge 1 => 4
Edge 1 => 5
Edge 2 => 1
Edge 2 => 4
Edge 2 => 5
Edge 3 => 2
Edge 3 => 5
Edge 4 => 1
Edge 4 => 2
Edge 4 => 3
Edge 5 => 1
Edge 5 => 2
Edge 5 => 3
```
"""
function complement end
@traitfn function complement(g::AG::(!IsDirected)) where {AG<:AbstractGraph}
    gnv = nv(g)
    h = AG(gnv)
    for i in vertices(g)
        for j = (i + 1):gnv
            if !has_edge(g, i, j)
                add_edge!(h, i, j)
            end
        end
    end
    return h
end

@traitfn function complement(g::AG::IsDirected) where {AG<:AbstractGraph}
    gnv = nv(g)
    h = AG(gnv)
    for i in vertices(g), j in vertices(g)
        if i != j && !has_edge(g, i, j)
            add_edge!(h, i, j)
        end
    end
    return h
end

"""
    reverse(g)

Return a directed graph where all edges are reversed from the
original directed graph.

### Implementation Notes
Preserves the eltype of the input graph.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> foreach(println, edges(reverse(g)))
Edge 1 => 3
Edge 2 => 1
Edge 3 => 2
Edge 4 => 3
Edge 4 => 5
Edge 5 => 4
```
"""
function reverse(g::AG) where {AG<:AbstractGraph}
    r = AG(nv(g))
    for e in edges(g)
        add_edge!(r, reverse(e))
    end
    return r
end

"""
    blockdiag(g, h)

Return a graph with ``|V(g)| + |V(h)|`` vertices and ``|E(g)| + |E(h)|``
edges where the vertices and edges from graph `h` are appended to graph `g`.

### Implementation Notes
Preserves the eltype of the input graph. Will error if the
number of vertices in the generated graph exceeds the `eltype`.
Unless overridden, this function does not preserve any metadata from `h`
(if the graph supports it).

# Examples
```jldoctest
julia> g1 = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> g2 = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> blockdiag(g1, g2)
{8, 9} directed simple Int64 graph

julia> foreach(println, edges(blockdiag(g1, g2)))
Edge 1 => 2
Edge 2 => 3
Edge 3 => 1
Edge 3 => 4
Edge 4 => 5
Edge 5 => 4
Edge 6 => 7
Edge 7 => 8
Edge 8 => 6
```
"""
function blockdiag(g::AG, h::AG) where {AG<:AbstractGraph}
    gnv = nv(g)
    r = AG(gnv + nv(h))
    for e in edges(g)
        add_edge!(r, e)
    end
    for e in edges(h)
        add_edge!(r, gnv + src(e), gnv + dst(e))
    end
    return r
end

"""
    intersect(g, h)

Return a graph with edges that are only in both graph `g` and graph `h`.

### Implementation Notes
This function may produce a graph with 0-degree vertices.
Preserves the eltype of the input graph.
Unless overriden, edge metadata, if present and supported, is only preserved
for the graph with the smaller number of edges.

# Examples
```jldoctest
julia> g1 = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> g2 = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> foreach(println, edges(intersect(g1, g2)))
Edge 1 => 2
Edge 2 => 3
Edge 3 => 1
```
"""
function intersect(g::AG, h::AG) where {AG<:AbstractGraph}
    gnv = nv(g)
    hnv = nv(h)

    smaller, larger = ne(g) < ne(h) ? (g, h) : (h, g)

    r = AG(min(gnv, hnv))
    for e in edges(smaller)
        if has_edge(larger, e)
            add_edge!(r, e)
        end
    end
    return r
end

"""
    difference(g, h)

Return a graph with edges in graph `g` that are not in graph `h`.

### Implementation Notes
Note that this function may produce a graph with 0-degree vertices.
Preserves the `eltype` of the input graph.

# Examples
```jldoctest
julia> g1 = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> g2 = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> foreach(println, edges(difference(g1, g2)))
Edge 3 => 4
Edge 4 => 5
Edge 5 => 4
```
"""
function difference(g::AG, h::AG) where {AG<:AbstractGraph}
    gnv = nv(g)
    hnv = nv(h)

    r = AG(gnv)
    for e in edges(g)
        if !has_edge(h, e)
            add_edge!(r, e)
        end
    end
    return r
end

"""
    symmetric_difference(g, h)

Return a graph based on `g` with edges from graph `g` that do not exist in graph `h`,
and vice versa.

### Implementation Notes
Note that this function may produce a graph with 0-degree vertices.
Preserves the eltype of the input graph. Will error if the
number of vertices in the generated graph exceeds the eltype.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(3); h = SimpleGraph(3);

julia> add_edge!(g, 1, 2);

julia> add_edge!(h, 1, 3);

julia> add_edge!(h, 2, 3);

julia> f = symmetric_difference(g, h);

julia> collect(edges(f))
3-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 3
 Edge 2 => 3
```
"""
function symmetric_difference(g::AG, h::AG) where {AG<:AbstractGraph}
    nvg, nvh = nv(g), nv(h)
    limit, larger = nvg < nvh ? (nvg, nvh) : (nvh, nvg)
    r = AG(larger)
    for e in edges(g)
        has_edge(h, e) && continue
        add_edge!(r, e)
    end
    for e in edges(h)
        (has_edge(r, e) || has_edge(g, e)) && continue
        add_edge!(r, e)
    end
    return r
end

"""
    join(g, h)

Return a graph that combines graphs `g` and `h` using `blockdiag` and then
adds all the edges between the vertices in `g` and those in `h`.

### Implementation Notes
Preserves the eltype of the input graph. Will error if the number of vertices
in the generated graph exceeds the eltype.
Unless overridden, this function does not preserve any metadata from `h`
(if the graph supports it).

# Examples
```jldoctest
julia> using LightGraphs

julia> g = join(star_graph(3), path_graph(2))
{5, 9} undirected simple Int64 graph

julia> collect(edges(g))
9-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 3
 Edge 1 => 4
 Edge 1 => 5
 Edge 2 => 4
 Edge 2 => 5
 Edge 3 => 4
 Edge 3 => 5
 Edge 4 => 5
```
"""
function join(g::AG, h::AG) where {AG<:AbstractGraph}
    r = blockdiag(g, h)
    for i in vertices(g)
        for j = (nv(g) + 1):(nv(g) + nv(h))
            add_edge!(r, i, j)
        end
    end
    return r
end


"""
    crosspath(len::Integer, g::Graph)

Return a [SimpleGraph](@ref) that duplicates `g` `len` times and connects each vertex
with its copies in a path.

### Implementation Notes
Preserves the eltype of the input graph. Will error if the number of vertices
in the generated graph exceeds the eltype.
Unless overridden, this function does not preserve any metadata
(if the graph supports it).

# Examples
```jldoctest
julia> using LightGraphs

julia> g = crosspath(3, path_graph(3))
{9, 12} undirected simple Int64 graph

julia> collect(edges(g))
12-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 4
 Edge 2 => 3
 Edge 2 => 5
 Edge 3 => 6
 Edge 4 => 5
 Edge 4 => 7
 Edge 5 => 6
 Edge 5 => 8
 Edge 6 => 9
 Edge 7 => 8
 Edge 8 => 9
```
"""
function crosspath end

@traitfn function crosspath(len::Integer, g::AG::(!IsDirected)) where {T, AG <: AbstractGraph{T}}
    h = AG(len)
    for i = 1:len-1
        add_edge!(h, i, i+1)
    end
    return cartesian_product(h, g)
end

"""
    union(g, h)

Return a graph that combines graphs `g` and `h` by taking the set union
of all vertices and edges.

### Implementation Notes
Preserves the eltype of the input graph. Will error if the
number of vertices in the generated graph exceeds the eltype.
Where edges exist in both graphs, the edges from the larger graph
are kept.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(3); h = SimpleGraph(5);

julia> add_edge!(g, 1, 2);

julia> add_edge!(g, 1, 3);

julia> add_edge!(h, 3, 4);

julia> add_edge!(h, 3, 5);

julia> add_edge!(h, 4, 5);

julia> f = union(g, h);

julia> collect(edges(f))
5-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 3
 Edge 3 => 4
 Edge 3 => 5
 Edge 4 => 5
```
"""
function union(g::AG, h::AG) where {AG<:AbstractGraph}
    smaller, larger = nv(g) < nv(h) ? (g, h) : (h, g)
    r = copy(larger)
    for e in edges(smaller)
        if !has_edge(r, e)
            add_edge!(r, e)
        end
    end
    return r
end

# The following operators allow one to use a LightGraphs.Graph as a matrix in eigensolvers for spectral ranking and partitioning.
# """Provides multiplication of a graph `g` by a vector `v` such that spectral
# graph functions in [GraphMatrices.jl](https://github.com/jpfairbanks/GraphMatrices.jl) can utilize LightGraphs natively.
# """
@traitfn function *(g::AG::(!IsDirected), v::Vector{T}) where{AG<:AbstractGraph, T<:Real}
    length(v) == nv(g) || throw(ArgumentError("Vector size must equal number of vertices"))
    y = zeros(T, nv(g))
    for e in edges(g)
        i = src(e)
        j = dst(e)
        y[i] += v[j]
        y[j] += v[i]
    end
    return y
end

@traitfn function *(g::AG::IsDirected, v::Vector{T}) where {AG<:AbstractGraph, T<:Real}
    length(v) == nv(g) || throw(ArgumentError("Vector size must equal number of vertices"))
    y = zeros(T, nv(g))
    for e in edges(g)
        i = src(e)
        j = dst(e)
        y[i] += v[j]
    end
    return y
end

"""
    sum(g)
    sum(g, dim)

Return a vector of indegree (`dim`=`1`) or outdegree (`dim`=`2`) values for graph `g`.
If `dim` is unspecified, return the number of edges in `g`.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> sum(g, 2)
5-element Array{Int64,1}:
 1
 1
 2
 1
 1

julia> sum(g, 1)
5-element Array{Int64,1}:
 1
 1
 1
 2
 1

julia> sum(g)
6
```
"""
sum(g::AbstractGraph) = ne(g)
function sum(g::AbstractGraph, dim::Int)
    dim == 1 && return indegree(g, vertices(g))
    dim == 2 && return outdegree(g, vertices(g))
    throw(ArgumentError("dimension must be <= 2"))
end

"""
    size(g)
    size(g, dim)

Return the number of vertices in `g` as a tuple or as a scalar if `dim`=`1` or `dim`=`2`.
For any other values of `dim`, return `1`.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = cycle_graph(4);

julia> size(g)
(4, 4)

julia> size(g, 1)
4

julia> size(g, 2)
4

julia> size(g, 3)
1
```
"""
size(g::AbstractGraph) = (nv(g), nv(g))
size(g::AbstractGraph, dim::Int) = (dim == 1 || dim == 2) ? nv(g) : 1


"""
    sparse(g)

Return the default adjacency matrix of `g`.
"""
sparse(g::AbstractGraph) = adjacency_matrix(g)

length(g::AbstractGraph) = widen(nv(g)) * widen(nv(g))
ndims(g::AbstractGraph) = 2
@traitfn issymmetric(g::::IsDirected) = false
@traitfn issymmetric(g::::(!IsDirected)) = true

"""
    cartesian_product(g, h)

Return the [cartesian product](https://en.wikipedia.org/wiki/Cartesian_product_of_graphs)
of `g` and `h`.

### Implementation Notes
Preserves the eltype of the input graph. Will error if the number of vertices
in the generated graph exceeds the eltype.
Unless overridden, this function does not preserve any metadata
(if the graph supports it).

# Examples
```jldoctest
julia> using LightGraphs

julia> g = cartesian_product(star_graph(3), path_graph(3))
{9, 12} undirected simple Int64 graph

julia> collect(edges(g))
12-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 4
 Edge 1 => 7
 Edge 2 => 3
 Edge 2 => 5
 Edge 2 => 8
 Edge 3 => 6
 Edge 3 => 9
 Edge 4 => 5
 Edge 5 => 6
 Edge 7 => 8
 Edge 8 => 9
```
"""
function cartesian_product(g::G, h::G) where G <: AbstractGraph
    z = G(nv(g) * nv(h))
    id(i, j) = (i - 1) * nv(h) + j
    for e in edges(g)
        i1, i2 = Tuple(e)
        for j = 1:nv(h)
            add_edge!(z, id(i1, j), id(i2, j))
        end
    end

    for e in edges(h)
        j1, j2 = Tuple(e)
        for i in vertices(g)
            add_edge!(z, id(i, j1), id(i, j2))
        end
    end
    return z
end

"""
    tensor_product(g, h)

Return the [tensor product](https://en.wikipedia.org/wiki/Tensor_product_of_graphs)
of `g` and `h`.

### Implementation Notes
Preserves the eltype of the input graph. Will error if the number of vertices
in the generated graph exceeds the eltype.
Unless overridden, this function does not preserve any metadata
(if the graph supports it).

# Examples
```jldoctest
julia> using LightGraphs

julia> g = tensor_product(star_graph(3), path_graph(3))
{9, 8} undirected simple Int64 graph

julia> collect(edges(g))
8-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 5
 Edge 1 => 8
 Edge 2 => 4
 Edge 2 => 6
 Edge 2 => 7
 Edge 2 => 9
 Edge 3 => 5
 Edge 3 => 8
```
"""
function tensor_product(g::G, h::G) where G <: AbstractGraph
    z = G(nv(g) * nv(h))
    id(i, j) = (i - 1) * nv(h) + j
    undirected = !is_directed(g)
    for e1 in edges(g)
        i1, i2 = Tuple(e1)
        for e2 in edges(h)
            j1, j2 = Tuple(e2)
            add_edge!(z, id(i1, j1), id(i2, j2))
            if undirected
                add_edge!(z, id(i1, j2), id(i2, j1))
            end
        end
    end
    return z
end


## subgraphs ###

"""
    induced_subgraph(g, vlist)
    induced_subgraph(g, elist)

Return the subgraph of `g` induced by the vertices in  `vlist` or edges in `elist`
along with a vector mapping the new vertices to the old ones
(the  vertex `i` in the subgraph corresponds to the vertex `vmap[i]` in `g`.)

The returned graph has `length(vlist)` vertices, with the new vertex `i`
corresponding to the vertex of the original graph in the `i`-th position
of `vlist`.

### Implementation Notes
Unless overridden, this function does not preserve any metadata
(if the graph supports it).

### Examples
```jldoctest
julia> g = complete_graph(10)

julia> sg, vmap = induced_subgraph(g, 5:8)

julia> @assert g[5:8] == sg

julia> @assert nv(sg) == 4

julia> @assert ne(sg) == 6

julia> @assert vm[4] == 8

julia> sg, vmap = induced_subgraph(g, [2,8,3,4])

julia> @assert sg == g[[2,8,3,4]]

julia> elist = [Edge(1,2), Edge(3,4), Edge(4,8)]

julia> sg, vmap = induced_subgraph(g, elist)

julia> @assert sg == g[elist]
```
"""
function induced_subgraph(g::AG, vlist::AbstractVector{U}) where {AG<:AbstractGraph, U<:Integer}
    allunique(vlist) || throw(ArgumentError("Vertices in subgraph list must be unique"))
    h = AG(length(vlist))
    newvid = Dict{U,U}()
    vmap = Vector{U}(undef, length(vlist))
    for (i, v) in enumerate(vlist)
        newvid[v] = U(i)
        vmap[i] = v
    end

    vset = Set(vlist)
    for s in vlist
        for d in outneighbors(g, s)
            # println("s = $s, d = $d")
            if d in vset
                add_edge!(h, newvid[s], newvid[d])
            end
        end
    end
    return h, vmap
end


function induced_subgraph(g::AG, elist::AbstractVector{U}) where {T, U<:AbstractEdge, AG<:AbstractGraph{T}}
    h = zero(g)
    newvid = Dict{T,T}()
    vmap = Vector{T}()

    for e in elist
        u, v = Tuple(e)
        for i in (u, v)
            if !haskey(newvid, i)
                add_vertex!(h)
                newvid[i] = nv(h)
                push!(vmap, i)
            end
        end
        add_edge!(h, newvid[u], newvid[v])
    end
    return h, vmap
end


"""
    g[iter]

Return the subgraph induced by `iter`.
Equivalent to [`induced_subgraph`](@ref)`(g, iter)[1]`.

### Implementation Notes
Unless overridden, this function does not preserve any metadata
(if the graph supports it).
"""
getindex(g::AbstractGraph, iter) = induced_subgraph(g, iter)[1]


"""
    egonet(g, v, d)
    egonet(g, v, d, distmx)

Return the subgraph of `g` induced by the neighbors of `v` up to distance
`d`, using weights (optionally) provided by `distmx`.
This is equivalent to [`induced_subgraph`](@ref)`(g, neighborhood(g, v, d, dir=dir))[1].`

### Optional Arguments
- `dir=:out`: if `g` is directed, this argument specifies the edge direction
with respect to `v` (i.e. `:in` or `:out`).

### Implementation Notes
Unless overridden, this function does not preserve any metadata
(if the graph supports it).
"""
egonet(g::AbstractGraph{T}, v::Integer, d::Integer, distmx::AbstractMatrix{U}; dir=:out) where {T<:Integer, U<:Real} =
    g[neighborhood(g, v, d, distmx, dir=dir)]

egonet(g::AbstractGraph{T}, v::Integer, d::Integer; dir=:out) where {T<:Integer} = g[neighborhood(g, v, d, dir=dir)]


"""
    compute_shifts(n::Int, x::AbstractArray)

Determine how many elements of `x` are less than `i` for all `i` in `1:n`.
"""
function compute_shifts(n::Integer, x::AbstractArray)
    tmp = zeros(eltype(x), n)
    tmp[x] .= 1
    return cumsum!(tmp, tmp)
end

"""
    merge_vertices(g::AbstractGraph, vs)

Create a new graph where all vertices in `vs` have been aliased to the same vertex `minimum(vs)`.

### Implementation Notes
Unless overridden, this function does not preserve any metadata
(if the graph supports it).

# Examples
```jldoctest
julia> using LightGraphs

julia> g = path_graph(5);

julia> collect(edges(g))
4-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 2 => 3
 Edge 3 => 4
 Edge 4 => 5

julia> h = merge_vertices(g, [2, 3]);

julia> collect(edges(h))
3-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 2 => 3
 Edge 3 => 4
```
"""
function merge_vertices end
@traitfn function merge_vertices(g::AG::(!IsDirected), vs) where {AG<:AbstractGraph}
    labels = collect(vertices(g))
    # Use lowest value as new vertex id.
    svs = sort(unique(vs))
    nvnew = nv(g) - length(svs) + 1
    nvnew <= nv(g) || return g
    (v0, vm) = (first(svs), last(svs))
    v0 > 0 || throw(ArgumentError("invalid vertex ID: $v0 in list of vertices to be merged"))
    vm <= nv(g) || throw(ArgumentError("vertex $vm not found in graph")) # TODO 0.7: change to DomainError?
    labels[svs] .= v0
    shifts = compute_shifts(nv(g), svs[2:end])
    for v in vertices(g)
        if labels[v] != v0
            labels[v] -= shifts[v]
        end
    end

    #if v in svs then labels[v] == v0 else labels[v] == v
    newg = AG(nvnew)
    for e in edges(g)
        u, w = src(e), dst(e)
        if labels[u] != labels[w] #not a new self loop
            add_edge!(newg, labels[u], labels[w])
        end
    end
    return newg
end

@traitfn function merge_vertices(g::AG::IsDirected, vs::Vector{U})  where {T, U<:Integer, AG<:AbstractGraph{T}}
    newg = copy(g)
    uvs = sort(unique(vs), rev=true)
    v0 = AG(vs[end])
    @inbounds for v in vs[1:end-1]
        @inbounds for u in inneighbors(newg, v)
            if !insorted(u, vs, rev=true)
                add_edge!(newg, u, v0)
            end
        end
        @inbounds for u in outneighbors(newg, v)
            if !insorted(u, vs, rev=true)
                add_edge!(newg, v0, u)
            end
        end
        rem_vertex!(newg, v)
    end
    return newg
end

"""
    merge_vertices!(g, vs)

Combine vertices specified in `vs` into single vertex whose
index will be the lowest value in `vs`. All edges connected to vertices in `vs`
connect to the new merged vertex.

Return a vector with new vertex values are indexed by the original vertex indices.

### Implementation Notes
Unless overridden, this function does not preserve any metadata
(if the graph supports it).

# Examples
```jldoctest
julia> using LightGraphs

julia> g = path_graph(5);

julia> collect(edges(g))
4-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 2 => 3
 Edge 3 => 4
 Edge 4 => 5

julia> merge_vertices!(g, [2, 3])
5-element Array{Int64,1}:
 1
 2
 2
 3
 4

julia> collect(edges(g))
3-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 2 => 3
 Edge 3 => 4
```
"""
function merge_vertices! end
@traitfn function merge_vertices!(g::AG::(!IsDirected), vs::Vector{U})  where {T, U<:Integer, AG<:AbstractGraph{T}}
    unique!(vs)
    sort!(vs, rev=true)
    v0 = T(vs[end])
    @inbounds for v in vs[1:end-1]
        @inbounds for u in neighbors(g, v)
            if !insorted(u, vs, rev=true)
                add_edge!(g, u, v0)
            end
        end
        rem_vertex!(g, v)
    end
    v0
end

@traitfn function merge_vertices!(g::AG::IsDirected, vs::Vector{U})  where {T, U<:Integer, AG<:AbstractGraph{T}}
    unique!(vs)
    sort!(vs, rev=true)
    v0 = T(vs[end])
    @inbounds for v in vs[1:end-1]
        @inbounds for u in inneighbors(g, v)
            if !insorted(u, vs, rev=true)
                add_edge!(g, u, v0)
            end
        end
        @inbounds for u in outneighbors(g, v)
            if !insorted(u, vs, rev=true)
                add_edge!(g, v0, u)
            end
        end
        rem_vertex!(g, v)
    end
    v0
end

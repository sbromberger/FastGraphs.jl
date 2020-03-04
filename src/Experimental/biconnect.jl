using LightGraphs
using LightGraphs.Experimental.Traversals
using LightGraphs: AbstractGraph, AbstractEdge
using SimpleTraits
"""
    Biconnections

A state type for depth-first search that finds the biconnected components.
"""
mutable struct Biconnections{E <: AbstractEdge} <: Traversals.AbstractTraversalState
    low::Vector{Int}
    depth::Vector{Int}
    children::Vector{Int}
    stack::Vector{E}
    biconnected_comps::Vector{Vector{E}}
    id::Int
    vcolor::Vector{UInt8}
    verts :: Vector{UInt8}
    w::UInt8
end

@traitfn function Biconnections(g::::(!IsDirected))
    n = nv(g)
    E = Edge{eltype(g)}
    return Biconnections(zeros(Int, n), zeros(Int, n), zeros(Int, n), Vector{E}(), Vector{Vector{E}}(), 0, zeros(UInt8, nv(g)), Vector{UInt8}(), UInt8(0))
end

@inline function previsitfn!(state::Biconnections{T}, u) where T
    children[u] = 0
    state.id += 1
    state.depth[u] = state.id
    state.low[u] = state.depth[u]
    return true
end
@inline function visitfn!(state::Biconnections{T}, v, w) where T
    if state.depth[w] == 0
        E = type(w)
        children[v] += 1
        push!(state.stack, E(min(v, w), max(v, w)))
        state.low[v] = min(state.low[v], state.low[w])

        #Checking the root, and then the non-roots if they are articulation points
        if (u == v && children[v] > 1) || (u != v && state.low[w] >= state.depth[v])
            e = E(0, 0)  #Invalid Edge, used for comparison only
            st = Vector{E}()
            while e != E(min(v, w), max(v, w))
                e = pop!(state.stack)
                push!(st, e)
            end
            push!(state.biconnected_comps, st)
        end

    elseif w != u && state.low[v] > state.depth[w]
        push!(state.stack, E(min(v, w), max(v, w)))
        state.low[v] = state.depth[w]
    end
end
@inline function newvisitfn!(s::Biconnections{T}, u, v) where T
    s.w = v
    return true
end
@inline function postvisitfn!(s::Biconnections{T}, u) where T
    if s.w != 0
        s.vcolor[s.w] = one(T)
    else
        s.vcolor[u] = T(2)
    end
    return true
end

"""
    visit!(g, state, u, v)

Perform a DFS visit storing the depth and low-points of each vertex.
"""
function visit!(g::AbstractGraph, state::Biconnections{E}, u::Integer, v::Integer) where {E}
    # E === Edge{eltype(g)}

    children = 0
    state.id += 1
    state.depth[v] = state.id
    state.low[v] = state.depth[v]

    for w in outneighbors(g, v)
        if state.depth[w] == 0
            children += 1
            push!(state.stack, E(min(v, w), max(v, w)))
            visit!(g, state, v, w)
            state.low[v] = min(state.low[v], state.low[w])

            #Checking the root, and then the non-roots if they are articulation points
            if (u == v && children > 1) || (u != v && state.low[w] >= state.depth[v])
                e = E(0, 0)  #Invalid Edge, used for comparison only
                st = Vector{E}()
                while e != E(min(v, w), max(v, w))
                    e = pop!(state.stack)
                    push!(st, e)
                end
                push!(state.biconnected_comps, st)
            end

        elseif w != u && state.low[v] > state.depth[w]
            push!(state.stack, E(min(v, w), max(v, w)))
            state.low[v] = state.depth[w]
        end
    end
end

"""
    biconnected_components2(g) -> Vector{Vector{Edge{eltype(g)}}}

Compute the [biconnected components](https://en.wikipedia.org/wiki/Biconnected_component)
of an undirected graph `g`and return a vector of vectors containing each
biconnected component.

Performance:
Time complexity is ``\\mathcal{O}(|V|)``.

# Examples
```jldoctest
julia> using LightGraphs

julia> biconnected_components2(star_graph(5))
4-element Array{Array{LightGraphs.SimpleGraphs.SimpleEdge,1},1}:
 [Edge 1 => 3]
 [Edge 1 => 4]
 [Edge 1 => 5]
 [Edge 1 => 2]

julia> biconnected_components2(cycle_graph(5))
1-element Array{Array{LightGraphs.SimpleGraphs.SimpleEdge,1},1}:
 [Edge 1 => 5, Edge 4 => 5, Edge 3 => 4, Edge 2 => 3, Edge 1 => 2]
```
"""
function biconnected_components2 end
@traitfn function biconnected_components2(g::::(!IsDirected))
    state = Biconnections(g)
    # TODO [1] isn't friendly
    traverse_graph!(g, [1], DFS(), state)
    return state.biconnected_comps
end

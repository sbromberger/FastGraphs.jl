"""
    struct ThreadedBellmanFord <: SSSPAlgorithm

The structure used to configure and specify that [`shortest_paths`](@ref)
should use a threaded version of the [Bellman-Ford algorithm](http://en.wikipedia.org/wiki/Bellman–Ford_algorithm).
No fields are specified or required.

### Implementation Notes
`BellmanFord` supports the following shortest-path functionality:
- negative distance matrices / weights
- (optional) multiple sources
- all destinations
"""
struct ThreadedBellmanFord <: SSSPAlgorithm end

function shortest_paths(g::AbstractGraph{U}, sources::AbstractVector{<:Integer}, distmx::AbstractMatrix{T}, ::ThreadedBellmanFord) where {T<:Real, U<:Integer}
    nvg = nv(g)
    active = Set{U}()
    sizehint!(active, nv(g))
    for s in sources
        union!(active, outneighbors(g, s))
    end
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    dists[sources] .= 0

    for i in one(U):nvg
        _loop_body!(g, distmx, dists, parents, active)

        isempty(active) && break
    end

    isempty(active) || throw(NegativeCycleError())
    return BellmanFordResult(parents, dists)
end

shortest_paths(g::AbstractGraph, s::Integer, distmx::AbstractMatrix, alg::ThreadedBellmanFord) =
    shortest_paths(g, [s], distmx, alg)

#Helper function used due to performance bug in @threads.
function _loop_body!(
    g::AbstractGraph{U},
    distmx::AbstractMatrix{T},
    dists::Vector{T},
    parents::Vector{U},
    active::Set{U}
    ) where T<:Real where U<:Integer


    prev_dists = deepcopy(dists)

    tmp_active = collect(active)
    @threads for v in tmp_active
        prev_dist_vertex = prev_dists[v]
        for u in inneighbors(g, v)
                relax_dist = (prev_dists[u] == typemax(T) ? typemax(T) : prev_dists[u] + distmx[u,v])
                if prev_dist_vertex > relax_dist
                    prev_dist_vertex = relax_dist
                    parents[v] = u
                end
        end
        dists[v] = prev_dist_vertex
    end

    empty!(active)
    for v in vertices(g)
        if dists[v] < prev_dists[v]
            union!(active, outneighbors(g, v))
        end
    end
end

function has_negative_edge_cycle(
    g::AbstractGraph{U},
    distmx::AbstractMatrix{T}
    ) where T<:Real where U<:Integer
    try
        shortest_paths(g, vertices(g), distmx, ThreadedBellmanFord())
    catch e
        isa(e, NegativeCycleError) && return true
    end
    return false
end


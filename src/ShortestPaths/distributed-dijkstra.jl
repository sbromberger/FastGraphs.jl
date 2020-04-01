"""
    struct DistributedDijkstra <: ShortestPathAlgorithm end

A struct representing a parallel implementation of the Dijkstra shortest-paths algorithm. Optional
fields for this structure incldue

- `neighborfn::Function` (default: [`outneighbors`](@ref) - specify the neighbor function to use during the
   graph traversal.
"""
struct DistributedDijkstra{F<:Function} <: ShortestPathAlgorithm
    neighborfn::F
end

DistributedDijkstra(;neighborfn=outneighbors) = DistributedDijkstra(neighborfn)

"""
    struct DistributedDijkstraResult{T, U}

A [`ShortestPathResult`](@ref) designed for parallel Dijkstra shortest paths calculation.
"""
struct DistributedDijkstraResult{T <: Real,U <: Integer} <: ShortestPathResult
    dists::Matrix{T}
    parents::Matrix{U}
    pathcounts::Matrix{U}
end

# """
#     Parallel.dijkstra_shortest_paths(g, sources=vertices(g), distmx=weights(g))
#
# Compute the shortest paths between all pairs of vertices in graph `g` by running
# [`dijkstra_shortest_paths`] for every vertex and using an optional list of source vertex `sources` and
# an optional distance matrix `distmx`. Return a [`Parallel.MultipleDijkstraState`](@ref) with relevant
# traversal information.
# """
function shortest_paths(g::AbstractGraph{U},
    sources::AbstractVector, distmx::AbstractMatrix{T}, alg::DistributedDijkstra) where {T<:Real, U}

    n_v = nv(g)
    r_v = length(sources)

    # TODO: remove `Int` once julialang/#23029 / #23032 are resolved
    dists      = SharedMatrix{T}(Int(r_v), Int(n_v))
    parents    = SharedMatrix{U}(Int(r_v), Int(n_v))
    pathcounts = SharedMatrix{U}(Int(r_v), Int(n_v))

    @sync @distributed for i in 1:r_v
        state = shortest_paths(g, sources[i], distmx, ShortestPaths.Dijkstra(neighborfn=alg.neighborfn))
        dists[i, :] = state.dists
        parents[i, :] = state.parents
        pathcounts[i, :] = state.pathcounts
    end

    return DistributedDijkstraResult(sdata(dists), sdata(parents), sdata(pathcounts))
end

shortest_paths(g::AbstractGraph, s::Integer, distmx::AbstractMatrix, alg::DistributedDijkstra) = shortest_paths(g, [s], distmx, alg)
shortest_paths(g::AbstractGraph, distmx::AbstractMatrix, alg::DistributedDijkstra) = shortest_paths(g, vertices(g), distmx, alg)
shortest_paths(g::AbstractGraph, alg::DistributedDijkstra) = shortest_paths(g, vertices(g), weights(g), alg)

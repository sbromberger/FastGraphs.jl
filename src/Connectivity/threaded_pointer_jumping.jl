"""
    struct ThreadedPointerJumping <: WeakConnectivityAlgorithm

A struct representing a [`WeakConnectivityAlgorithm`](@ref)
based on parallel opportunistic pointer jumping

### References
- Connected-Components algorithms for Mesh-Connected Parallel Computers
Goddard, Kumar and Prins.
http://cse.unl.edu/~goddard/Papers/Journals/dimacs.pdf
"""
struct ThreadedPointerJumping <: WeakConnectivityAlgorithm end

function connected_components(g::AbstractGraph{T}, alg::ThreadedPointerJumping) where T <: Integer
    nvg = nv(g)
    P = collect(vertices(g))    # parent array
    @threads for u in vertices(g)
        if degree(g, u) != 0
            P[u] = min(u, first(outneighbors(g, u)))
        end
    end
    partitions = greedy_contiguous_partition(degree(g), nthreads())
    oldP = Vector{T}(undef, nvg)
    while oldP != P
        # opportunistic pointer jumping
        @threads for u_set in partitions
            for u in u_set
                oldP[u] = P[u]
                for v in outneighbors(g, u)
                    P[u] = P[min(P[u], P[v])]
                end
            end
        end
        # tree hanging
        @threads for u in vertices(g)
            v = oldP[u]
            if P[u] < P[v]
                P[v] = P[u]
            end
        end
        # normal pointer jumping
        @threads for u in vertices(g)
            P[u] = P[P[u]]
        end
    end
    return components(P)[1]
end

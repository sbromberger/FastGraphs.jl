"""
    modularity(g, c)

Computes Newman's modularity `Q`
for graph `g` given the partitioning `c`.
"""
function modularity(g::Graph, c)
    n = nv(g)
    m = 2*ne(g)
    m == 0 && return 0.0
    nc = maximum(c)
    a = zeros(Int, nc)
    Q = 0.0
    for u in vertices(g)
        for v in neighbors(g,u)
            if u <= v
                c1 = c[u]
                c2 = c[v]
                if c1 == c2
                    Q += 2/m
                end
                a[c1] += 1
                a[c2] += 1
            end
        end
    end
    @inbounds for i=1:nc
        Q -= a[i]*a[i]/m/m
    end
    return Q
end

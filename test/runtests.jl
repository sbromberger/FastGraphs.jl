using LightGraphs
using LightGraphs.SimpleGraphs
using Test
using SparseArrays
using LinearAlgebra
using DelimitedFiles
using Base64
using Random

const testdir = dirname(@__FILE__)


testgraphs(g) = [g, Graph{UInt8}(g), Graph{Int16}(g)]
testdigraphs(g) = [g, DiGraph{UInt8}(g), DiGraph{Int16}(g)]

# some operations will create a large graph from two smaller graphs. We
# might error out on very small eltypes.
testlargegraphs(g) = [g, Graph{UInt16}(g), Graph{Int32}(g)]
testlargedigraphs(g) = [g, DiGraph{UInt16}(g), DiGraph{Int32}(g)]

tests = [
    "simplegraphs/runtests",
    "linalg/runtests",
    "interface",
    "core",
    "operators",
    "degeneracy",
    "distance",
    "digraph/transitivity",
    "digraph/cycles/hadwick-james",
    "digraph/cycles/johnson",
    "digraph/cycles/karp",
    "dominatingset/degree_dom_set",
    "dominatingset/random_minimal_dom_set",
    "edit_distance",
    "connectivity",
    "persistence/persistence",
    "shortestpaths/astar",
    "shortestpaths/bellman-ford",
    "shortestpaths/dijkstra",
    "shortestpaths/johnson",
    "shortestpaths/floyd-warshall",
    "shortestpaths/yen",
    "independentset/degree_ind_set",
    "independentset/random_maximal_ind_set",
    "matching/augment_matching",
    "matching/random_maximal_matching",
    "traversals/bfs",
    "traversals/parallel_bfs",
    "traversals/bipartition",
    "traversals/greedy_color",
    "traversals/dfs",
    "traversals/maxadjvisit",
    "traversals/randomwalks",
    "traversals/diffusion",
    "community/cliques",
    "community/core-periphery",
    "community/label_propagation",
    "community/modularity",
    "community/clustering",
    "community/clique_percolation",
    "centrality/betweenness",
    "centrality/closeness",
    "centrality/degree",
    "centrality/katz",
    "centrality/pagerank",
    "centrality/eigenvector",
    "centrality/stress",
    "centrality/radiality",
    "utils",
    "spanningtrees/kruskal",
    "spanningtrees/prim",
    "biconnectivity/articulation",
    "biconnectivity/pairwise_connectivity",
    "biconnectivity/biconnect",
    "graphcut/normalized_cut",
    "vertexcover/degree_vertex_cover",
    "vertexcover/random_vertex_cover"
]
tests = [
    "traversals/greedy_color",
    "biconnectivity/pairwise_connectivity",
    "dominatingset/degree_dom_set",
    "dominatingset/random_minimal_dom_set",
    "independentset/degree_ind_set",
    "independentset/random_maximal_ind_set",
    "matching/augment_matching",
    "matching/random_maximal_matching",
    "vertexcover/degree_vertex_cover",
    "vertexcover/random_vertex_cover"
]

@testset "LightGraphs" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end

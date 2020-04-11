@testset "Parallel.BFS" begin


    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)

    @testset "$g" for g in testdigraphs(g5)
        @test @inferred(Parallel.gdistances(g, 1))  == LightGraphs.ShortestPaths.distances(shortest_paths(g, 1))
        @test @inferred(Parallel.gdistances(g, [1, 3]))  == LightGraphs.ShortestPaths.distances(shortest_paths(g, [1, 3]))
    end

    g6 = smallgraph(:house)

    @testset "$g" for g in testgraphs(g6)
        @test @inferred(Parallel.gdistances(g, 2))  == LightGraphs.ShortestPaths.distances(shortest_paths(g, 2))
        @test @inferred(Parallel.gdistances(g, [1, 2])) == LightGraphs.ShortestPaths.distances(shortest_paths(g, [1, 2]))
    end

end

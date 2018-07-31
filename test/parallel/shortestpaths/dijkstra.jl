@testset "Parallel.Dijkstra" begin
    info("Testing Parallel.Dijkstra")
    g4 = PathDiGraph(5)
    d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
    d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
    #Testing multisource On undirected Graph
    g3 = PathGraph(5)
    d = [0 1 2 3 4; 1 0 1 0 1; 2 1 0 11 12; 3 0 11 0 5; 4 1 19 5 0]

    for g in testgraphs(g3)
        z  = @inferred(floyd_warshall_shortest_paths(g, d))
        zp = @inferred(Parallel.dijkstra_shortest_paths(g, collect(1:5), d))
        @test all(isapprox(z.dists, zp.dists))

        for i in 1:5
            state = Parallel.dijkstra_shortest_paths(g, [i]);
            for j in 1:5
                if z.parents[i, j] != 0
                    @test z.parents[i, j] in state.predecessors[j]
                else
                    @test length(state.predecessors[j]) == 0
                    @test state.parents[j] == 0
                end
            end
        end

        z  = @inferred(floyd_warshall_shortest_paths(g))
        zp = @inferred(parallel_multisource_dijkstra_shortest_paths(g))
        @test all(isapprox(z.dists, zp.dists))

        for i in 1:5
            state = Parallel.dijkstra_shortest_paths(g, [i]);
            for j in 1:5
                if z.parents[i, j] != 0
                    @test z.parents[i, j] in state.predecessors[j]
                else
                    @test length(state.predecessors[j]) == 0
                end
            end
        end

        z  = @inferred(floyd_warshall_shortest_paths(g))
        zp = @inferred(Parallel.dijkstra_shortest_paths(g, [1, 2]))
        @test all(isapprox(z.dists[1:2, :], zp.dists))

        for i in 1:2
            state = Parallel.dijkstra_shortest_paths(g, [i]);
            for j in 1:5
                if z.parents[i, j] != 0
                    @test z.parents[i, j] in state.predecessors[j]
                else
                    @test length(state.predecessors[j]) == 0
                end
            end
        end
    end


    #Testing multisource On directed Graph
    g3 = PathDiGraph(5)
    d = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])

    for g in testdigraphs(g3)
        z  = @inferred(floyd_warshall_shortest_paths(g, d))
        zp = @inferred(parallel_multisource_dijkstra_shortest_paths(g, collect(1:5), d))
        @test all(isapprox(z.dists, zp.dists))

        for i in 1:5
            state = dijkstra_shortest_paths(g, i; allpaths=true);
            for j in 1:5
                if z.parents[i, j] != 0
                    @test z.parents[i, j] in state.predecessors[j]
                else
                    @test length(state.predecessors[j]) == 0
                end
            end
        end

        z  = @inferred(floyd_warshall_shortest_paths(g))
        zp = @inferred(parallel_multisource_dijkstra_shortest_paths(g))
        @test all(isapprox(z.dists, zp.dists))

        for i in 1:5
            state = dijkstra_shortest_paths(g, i; allpaths=true);
            for j in 1:5
                if z.parents[i, j] != 0
                    @test z.parents[i, j] in state.predecessors[j]
                else
                    @test length(state.predecessors[j]) == 0
                end
            end
        end

        z  = @inferred(floyd_warshall_shortest_paths(g))
        zp = @inferred(parallel_multisource_dijkstra_shortest_paths(g, [1, 2]))
        @test all(isapprox(z.dists[1:2, :], zp.dists))

        for i in 1:2
            state = dijkstra_shortest_paths(g, i;allpaths=true);
            for j in 1:5
                if z.parents[i, j] != 0
                    @test z.parents[i, j] in state.predecessors[j]
                else
                    @test length(state.predecessors[j]) == 0
                end
            end
        end
    end
end

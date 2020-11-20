@testset "ShortestPaths.BidirAStar" begin
p5 = SGGEN.Path(5)
g3 = SimpleGraph(p5)
g4 = SimpleDiGraph(p5)

d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
@testset "$g" for g in testgraphs(g3), dg in testdigraphs(g4)
    y = @inferred(ShortestPaths.shortest_paths(g, 1, 4, d1, ShortestPaths.BidirAStar()))
    @test y == @inferred(ShortestPaths.shortest_paths(dg, 1, 4, d1, ShortestPaths.BidirAStar()))
    @test y == @inferred(ShortestPaths.shortest_paths(g, 1, 4, d2, ShortestPaths.BidirAStar()))
    @test ShortestPaths.paths(y) == [y.path]
    @test_throws ArgumentError ShortestPaths.paths(y, 2)
    @test ShortestPaths.distances(y) == [[y.dist]]
    @test_throws ArgumentError ShortestPaths.distances(y, 2)
    @test_throws LightGraphs.NotImplementedError ShortestPaths.parents(y)

    z = @inferred(ShortestPaths.shortest_paths(dg, 4, 1, ShortestPaths.BidirAStar()))
    @test isempty(z.path)
    @test isempty(ShortestPaths.paths(z)[1])
    @test ShortestPaths.distances(z)[1] == [typemax(Int)]
end

# test for #1258

g = SimpleGraph(SGGEN.Complete(4))
w = float([1 1 1 4; 1 1 1 1; 1 1 1 1; 4 1 1 1])
@test length(first(ShortestPaths.paths(ShortestPaths.shortest_paths(g, 1, 4, w, ShortestPaths.BidirAStar())))) == 3
end

##################################################################
#
#   Maximal cliques of undirected graph
#   Derived from Graphs.jl: https://github.com/julialang/Graphs.jl
#
##################################################################

@testset "Cliques" begin
    function setofsets(array_of_arrays)
        Set(map(Set, array_of_arrays))
    end

    function test_cliques(graph, expected)
        # Make test results insensitive to ordering
        setofsets(@inferred(maximal_cliques(graph))) == setofsets(expected)
    end

    @testset "simple maximal clique cases" begin
        gx = SimpleGraph(3)
        add_edge!(gx, 1, 2)
        @testset "$g simple single maximal clique" for g in testgraphs(gx)
            @test test_cliques(g, Array[[1, 2], [3]])
        end
        add_edge!(gx, 2, 3)
        @testset "$g" for g in testgraphs(gx)
            @test test_cliques(g, Array[[1, 2], [2, 3]])
        end
    end
    @testset "pivotdonenbrs defined" begin
        h = SimpleGraph(6)
        add_edge!(h, 1, 2)
        add_edge!(h, 1, 3)
        add_edge!(h, 1, 4)
        add_edge!(h, 2, 5)
        add_edge!(h, 2, 6)
        add_edge!(h, 3, 4)
        add_edge!(h, 3, 6)
        add_edge!(h, 5, 6)

        @testset "$g" for g in testgraphs(h)
            @test !isempty(@inferred(maximal_cliques(g)))
        end
    end

    # test for extra cliques bug
    @testset "does not find extra cliques" begin
        h = SimpleGraph(7)
        add_edge!(h, 1, 3)
        add_edge!(h, 2, 6)
        add_edge!(h, 3, 5)
        add_edge!(h, 3, 6)
        add_edge!(h, 4, 5)
        add_edge!(h, 4, 7)
        add_edge!(h, 5, 7)
        @testset "$g" for g in testgraphs(h)
            @test test_cliques(h, Array[[7, 4, 5], [2, 6], [3, 5], [3, 6], [3, 1]])
        end
    end
end

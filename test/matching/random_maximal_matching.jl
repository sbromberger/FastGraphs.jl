@testset "Random Maximal Matching" begin
  
    g3 = StarGraph(5)
    for g in testgraphs(g3)
        m = @inferred(random_maximal_matching(g, 2))
        @test (size(m)[1] == 1 && (m[1].dst == 1 || m[1].src == 1))

        m = @inferred(random_maximal_matching(g, 2, parallel=true))
        @test (size(m)[1] == 1 && (m[1].dst == 1 || m[1].src == 1))
    end
    
    g4 = CompleteGraph(5)
    for g in testgraphs(g4)
        m = @inferred(random_maximal_matching(g, 2))
        @test size(m)[1] == 2 #All except one vertex 

        m = @inferred(random_maximal_matching(g, 2, parallel=true))
        @test size(m)[1] == 2 
    end

    g5 = PathGraph(4)
    for g in testgraphs(g5)
        m = @inferred(random_maximal_matching(g, 2))
        @test (m == [Edge(1, 2), Edge(3, 4)] || m == [Edge(3, 4), Edge(1, 2)] || m == [Edge(2, 3)])

        m = @inferred(random_maximal_matching(g, 2, parallel=true))
        @test (m == [Edge(1, 2), Edge(3, 4)] || m == [Edge(3, 4), Edge(1, 2)] || m == [Edge(2, 3)])
    end
end

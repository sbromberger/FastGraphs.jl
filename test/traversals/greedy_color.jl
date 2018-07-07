@testset "Greedy Coloring" begin
  
    g3 = StarGraph(10)

    for g in testgraphs(g3)
        for op_exchange in (true, false), op_sort in (true, false), op_parallel in (false, true)
            C = @inferred(greedy_color(g, exchange=op_exchange, reps=5, sort_degree=op_sort, parallel=op_parallel))
            @test C.num_colors == 2
        end
    end
    
    g4 = PathGraph(20)
    for g in testgraphs(g4)
        for op_exchange in (true, false), op_sort in (true, false), op_parallel in (false, true)
            C = @inferred(greedy_color(g, exchange=op_exchange, reps=5, sort_degree=op_sort, parallel=op_parallel))
        
            @test C.num_colors <= maximum(degree(g))+1 #Propert of greedy coloring
            correct = true
            for e in edges(g) #Condition for valid coloring
                C.colors[src(e)] == C.colors[dst(e)] && (correct = false)
            end

            @test correct
        end
    end
    
    g5 = CompleteGraph(20)
    for g in testgraphs(g5)
        for op_exchange in (true, false), op_sort in (true, false), op_parallel in (false, true)
            C = @inferred(greedy_color(g, exchange=op_exchange, reps=5, sort_degree=op_sort, parallel=op_parallel))
        
            @test C.num_colors <= maximum(degree(g))+1
            correct = true
            for e in edges(g) #Condition for valid coloring
                C.colors[src(e)] == C.colors[dst(e)] && (correct = false)
            end

            @test correct
        end
    end

end


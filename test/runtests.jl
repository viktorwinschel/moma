using Test
using Moma

@testset "Moma.jl Tests" begin
    @testset "Categories" begin
        # Test Object creation
        obj1 = Moma.Categories.Object(:A, "data1")
        obj2 = Moma.Categories.Object(:B, "data2")
        @test obj1.id == :A
        @test obj1.data == "data1"

        # Test Morphism creation and composition
        m1 = Moma.Categories.Morphism(obj1, obj2, x -> uppercase(x), :m1)
        @test m1.source == obj1
        @test m1.target == obj2

        # Test identity morphism
        id_morph = Moma.Categories.identity(obj1)
        @test id_morph.source == obj1
        @test id_morph.target == obj1

        # Test Category creation
        cat = Moma.Categories.Category([obj1, obj2], [m1], :TestCat)
        @test length(cat.objects) == 2
        @test length(cat.morphisms) == 1

        # Test Pattern creation
        pattern = Moma.Categories.create_pattern(cat, [obj1, obj2], [m1])
        @test length(pattern.objects) == 2
        @test length(pattern.morphisms) == 1
        @test pattern.category == cat
    end

    @testset "Traffic Network Example" begin
        # Test network creation
        network = Moma.TrafficNetwork.create_traffic_network()
        @test length(network.objects) == 6  # 3 junctions + 3 roads
        @test length(network.morphisms) == 6  # 6 connections

        # Test traffic flow analysis
        analysis = Moma.TrafficNetwork.analyze_traffic_flow(network)
        @test haskey(analysis, "path_length")
        @test haskey(analysis, "total_flow")
        @test haskey(analysis, "bottleneck")

        # Test specific road segment
        road1 = filter(o -> o.id == :R1, network.objects)[1]
        @test road1.data.length == 1.0
        @test road1.data.capacity == 1000
        @test road1.data.current_flow == 500

        # Test specific junction
        junction2 = filter(o -> o.id == :J2, network.objects)[1]
        @test junction2.data.capacity == 150
        @test junction2.data.current_load == 75

        # Test morphism connections
        j1_to_r1 = filter(m -> m.id == :m1, network.morphisms)[1]
        @test j1_to_r1.source.id == :J1
        @test j1_to_r1.target.id == :R1
    end
end
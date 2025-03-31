using Test
using Moma.Categories

@testset "Documentation Examples" begin
    # Object examples
    @testset "Object Examples" begin
        # String data example
        obj = Object(:A, "data")
        @test obj.id == :A
        @test obj.data == "data"

        # Numeric data example
        num_obj = Object(:B, 42)
        @test num_obj.id == :B
        @test num_obj.data == 42

        # Custom type example
        struct Point
            x::Float64
            y::Float64
        end
        point_obj = Object(:P, Point(0.0, 1.0))
        @test point_obj.id == :P
        @test point_obj.data.x == 0.0
        @test point_obj.data.y == 1.0
    end

    # Morphism examples
    @testset "Morphism Examples" begin
        # String morphism example
        A = Object(:A, "hello")
        B = Object(:B, "HELLO")
        f = Morphism(A, B, uppercase, :f)
        @test f.map(A.data) == B.data

        # Numeric morphism example
        X = Object(:X, 1)
        Y = Object(:Y, 2)
        g = Morphism(X, Y, x -> x + 1, :g)
        @test g.map(X.data) == Y.data
    end

    # Identity morphism examples
    @testset "Identity Examples" begin
        A = Object(:A, "data")
        id_A = Categories.identity(A)
        @test id_A.map(A.data) == A.data
        @test id_A.source == A
        @test id_A.target == A
    end

    # Composition examples
    @testset "Composition Examples" begin
        # String composition example
        A = Object(:A, "hello")
        B = Object(:B, "HELLO")
        C = Object(:C, "HELLO!")
        f = Morphism(A, B, uppercase, :f)
        g = Morphism(B, C, s -> s * "!", :g)

        h = Categories.compose(f, g)
        @test h.map("hello") == "HELLO!"

        # Test error case
        k = Morphism(C, A, lowercase, :k)
        @test_throws ErrorException Categories.compose(f, k)
    end

    # Category examples
    @testset "Category Examples" begin
        # Create objects
        A = Object(:A, "A")
        B = Object(:B, "B")
        C = Object(:C, "C")

        # Create morphisms
        f = Morphism(A, B, x -> x, :f)
        g = Morphism(B, C, x -> x, :g)
        h = Categories.compose(f, g)

        # Create category
        cat = Category([A, B, C], [f, g, h], :ExampleCategory)
        @test length(cat.objects) == 3
        @test length(cat.morphisms) == 3
        @test cat.id == :ExampleCategory
    end

    # Pattern examples
    @testset "Pattern Examples" begin
        # Create category
        A = Object(:A, "A")
        B = Object(:B, "B")
        C = Object(:C, "C")
        f = Morphism(A, B, x -> x, :f)
        g = Morphism(B, C, x -> x, :g)
        cat = Category([A, B, C], [f, g], :ExampleCategory)

        # Create pattern
        pat = Categories.create_pattern(cat, [A, B], [f])
        @test length(pat.objects) == 2
        @test length(pat.morphisms) == 1
        @test pat.category == cat
    end

    # Colimit examples
    @testset "Colimit Examples" begin
        # Create category
        A = Object(:A, "A")
        B = Object(:B, "B")
        C = Object(:C, "C")
        f = Morphism(A, B, x -> x, :f)
        g = Morphism(B, C, x -> x, :g)
        cat = Category([A, B, C], [f, g], :ExampleCategory)

        # Create pattern
        pat = Categories.create_pattern(cat, [A, B], [f])

        # Find colimit
        colimit_obj, bindings = Categories.find_colimit(pat)
        @test colimit_obj !== nothing
        @test haskey(bindings, A)
        @test haskey(bindings, B)
    end
end
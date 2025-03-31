using Test
using Moma

@testset "Moma.jl Tests" begin
    @testset "Categories" begin
        # Test Object creation
        obj1 = Moma.Categories.Object(:A, "data1")
        obj2 = Moma.Categories.Object(:B, "data2")
        obj3 = Moma.Categories.Object(:C, "data3")
        @test obj1.id == :A
        @test obj1.data == "data1"

        # Test Morphism creation and composition
        m1 = Moma.Categories.Morphism(obj1, obj2, x -> uppercase(x), :m1)
        m2 = Moma.Categories.Morphism(obj2, obj3, x -> x * "!", :m2)
        @test m1.source == obj1
        @test m1.target == obj2

        # Test composition
        m3 = Moma.Categories.compose(m1, m2)
        @test m3.source == obj1
        @test m3.target == obj3
        @test m3.map("test") == "TEST!"

        # Test composition error
        m4 = Moma.Categories.Morphism(obj3, obj1, x -> x, :m4)
        @test_throws ErrorException Moma.Categories.compose(m1, m4)

        # Test identity morphism
        id_morph = Moma.Categories.identity(obj1)
        @test id_morph.source == obj1
        @test id_morph.target == obj1
        @test id_morph.map("test") == "test"

        # Test Category creation and membership
        cat = Moma.Categories.Category([obj1, obj2, obj3], [m1, m2, m3], :TestCat)
        @test length(cat.objects) == 3
        @test length(cat.morphisms) == 3
        @test Moma.Categories.is_morphism_in_category(m1, cat) == true
        @test Moma.Categories.is_morphism_in_category(m4, cat) == false

        # Test Pattern creation and validation
        pattern = Moma.Categories.create_pattern(cat, [obj1, obj2], [m1])
        @test length(pattern.objects) == 2
        @test length(pattern.morphisms) == 1
        @test pattern.category == cat

        # Test pattern creation with invalid objects/morphisms
        @test_throws ErrorException Moma.Categories.create_pattern(cat, [obj1, Moma.Categories.Object(:X, "invalid")], [m1])
        @test_throws ErrorException Moma.Categories.create_pattern(cat, [obj1, obj2], [m4])

        # Test binding checks
        bindings = Dict(
            obj1 => Moma.Categories.Morphism(obj1, obj2, x -> uppercase(x), :bind1),
            obj2 => Moma.Categories.identity(obj2)
        )
        @test Moma.Categories.check_binding(obj2, bindings, pattern) == true

        # Test incomplete bindings
        incomplete_bindings = Dict(obj1 => id_morph)
        @test Moma.Categories.check_binding(obj2, incomplete_bindings, pattern) == false

        # Test colimit construction
        @testset "Colimits" begin
            # Create simple objects and morphisms
            a = Moma.Categories.Object(:A, 1)
            b = Moma.Categories.Object(:B, 2)
            f = Moma.Categories.Morphism(a, b, x -> x + 1, :f)

            # Create category and pattern
            cat = Moma.Categories.Category([a, b], [f], :ColimitTest)
            pat = Moma.Categories.create_pattern(cat, [a, b], [f])

            # Find colimit
            colimit_obj, bindings = Moma.Categories.find_colimit(pat)

            # Test colimit properties
            @test colimit_obj.data == [1, 2]  # Combined data
            @test haskey(bindings, a)
            @test haskey(bindings, b)
            @test bindings[a].target == colimit_obj
            @test bindings[b].target == colimit_obj
            @test Moma.Categories.check_binding(colimit_obj, bindings, pat)

            # Test colimit universal property
            # The diagram should commute
            @test bindings[a].map(a.data) == [1, 2]
            @test bindings[b].map(b.data) == [1, 2]
        end
    end

    # Include documentation examples tests
    include("examples_test.jl")
end
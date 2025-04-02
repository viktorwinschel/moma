using Test
using Moma
using Moma.Categories
using Moma.StateSpace
#: TimeSeriesMemory, extend!, get_data, get_times, get_links,
#   create_ar_model, create_var_model, create_nonlinear_var_model,
#  create_stochastic_nonlinear_var_model, simulate_dynamics

# Test Categories Examples
@testset "Categories Examples" begin
    # Test Object creation
    obj1 = Object(:A, "data1")
    obj2 = Object(:B, "data2")
    obj3 = Object(:C, "data3")
    @test obj1.id == :A && obj1.data == "data1"
    @test obj2.id == :B && obj2.data == "data2"
    @test obj3.id == :C && obj3.data == "data3"

    # Test Morphism creation and composition
    m1 = Morphism(obj1, obj2, x -> uppercase(x), :m1)
    m2 = Morphism(obj2, obj3, x -> x * "!", :m2)
    @test m1.source == obj1 && m1.target == obj2
    @test m2.source == obj2 && m2.target == obj3
    @test m1.id == :m1
    @test m2.id == :m2
    @test m1.map("test") == "TEST"
    @test m2.map("test") == "test!"

    # Test composition
    m3 = compose(m1, m2)
    @test m3.source == obj1 &&
          m3.target == obj3 &&
          m3.map("test") == "TEST!"
    @test m3.id == :m1_m2

    # Test identity morphism
    id_morph = identity_morphism(obj1)
    @test id_morph.source == obj1 &&
          id_morph.target == obj1 &&
          id_morph.map("test") == "test"
    @test id_morph.id == :id_A

    # Test Category creation and membership
    cat = Category([obj1, obj2, obj3], [m1, m2, m3], :TestCat)
    @test length(cat.objects) == 3 &&
          length(cat.morphisms) == 3 &&
          is_morphism_in_category(m1, cat)
    @test cat.id == :TestCat
    @test obj1 in cat.objects
    @test obj2 in cat.objects
    @test obj3 in cat.objects
    @test m1 in cat.morphisms
    @test m2 in cat.morphisms
    @test m3 in cat.morphisms

    # Test Pattern creation and validation
    pattern = create_pattern(cat, [obj1, obj2], [m1])
    @test length(pattern.objects) == 2 &&
          length(pattern.morphisms) == 1 &&
          pattern.category == cat
    @test obj1 in pattern.objects
    @test obj2 in pattern.objects
    @test m1 in pattern.morphisms

    # Test binding checks
    bindings = Dict(
        obj1 => Morphism(obj1, obj2, x -> uppercase(x), :bind1),
        obj2 => identity_morphism(obj2)
    )
    @test check_binding(obj2, bindings, pattern)
    @test haskey(bindings, obj1)
    @test haskey(bindings, obj2)
    @test bindings[obj1].id == :bind1
    @test bindings[obj2].id == :id_B
end

# Test Geometry Examples
@testset "Geometry Examples" begin
    # Define custom data types
    struct Point
        x::Float64
        y::Float64
    end

    struct Line
        start::Point
        ends::Point
    end

    # Create objects with custom data
    p1 = Object(:P1, Point(0.0, 0.0))
    p2 = Object(:P2, Point(1.0, 1.0))
    l1 = Object(:L1, Line(Point(0.0, 0.0), Point(1.0, 1.0)))

    # Test geometric object creation
    @test p1.data.x == 0.0
    @test p1.data.y == 0.0
    @test p2.data.x == 1.0
    @test p2.data.y == 1.0
    @test l1.data.start.x == 0.0
    @test l1.data.start.y == 0.0
    @test l1.data.ends.x == 1.0
    @test l1.data.ends.y == 1.0
    @test p1.id == :P1
    @test p2.id == :P2
    @test l1.id == :L1

    # Create morphisms between custom objects
    f = Morphism(p1, l1, p -> Line(p, Point(p.x + 1.0, p.y + 1.0)), :f)

    # Test morphism application
    result = f.map(p1.data)
    @test result.start.x == 0.0
    @test result.start.y == 0.0
    @test result.ends.x == 1.0
    @test result.ends.y == 1.0
    @test f.id == :f
    @test f.source == p1
    @test f.target == l1

    # Create a category of geometric objects
    geom_cat = Category([p1, p2, l1], [f], :Geometry)
    @test length(geom_cat.objects) == 3
    @test length(geom_cat.morphisms) == 1
    @test geom_cat.id == :Geometry
    @test p1 in geom_cat.objects
    @test p2 in geom_cat.objects
    @test l1 in geom_cat.objects
    @test f in geom_cat.morphisms

    # Create patterns
    geom_pattern = create_pattern(geom_cat, [p1, l1], [f])
    @test length(geom_pattern.objects) == 2
    @test length(geom_pattern.morphisms) == 1
    @test geom_pattern.category == geom_cat
    @test p1 in geom_pattern.objects
    @test l1 in geom_pattern.objects
    @test f in geom_pattern.morphisms
end

# Test Error Handling Examples
@testset "Error Handling Examples" begin
    # Create some basic objects and morphisms for testing
    A = Object(:A, 1)
    B = Object(:B, 2)
    C = Object(:C, 3)
    valid_f = Morphism(A, B, x -> x + 1, :valid_f)
    valid_g = Morphism(B, C, x -> x * 2, :valid_g)
    cat = Category([A, B, C], [valid_f, valid_g], :TestCat)

    # Test object properties
    @test A.id == :A && A.data == 1
    @test B.id == :B && B.data == 2
    @test C.id == :C && C.data == 3

    # Test morphism properties
    @test valid_f.source == A && valid_f.target == B
    @test valid_g.source == B && valid_g.target == C
    @test valid_f.id == :valid_f && valid_g.id == :valid_g
    @test valid_f.map(1) == 2
    @test valid_g.map(2) == 4

    # Test category properties
    @test cat.id == :TestCat
    @test length(cat.objects) == 3
    @test length(cat.morphisms) == 2
    @test A in cat.objects && B in cat.objects && C in cat.objects
    @test valid_f in cat.morphisms && valid_g in cat.morphisms

    # Test valid composition works
    composed = compose(valid_f, valid_g)
    @test composed.source == A
    @test composed.target == C
    @test composed.map(1) == 4
    @test composed.id == :valid_f_valid_g

    # Test identity morphism
    id_A = identity_morphism(A)
    @test id_A.id == Symbol("id_", A.id)

    # Test incompatible morphism composition
    f = Morphism(A, B, x -> x, :f)
    g = Morphism(C, A, x -> x, :g)
    @test_throws ErrorException("Morphisms are not composable") compose(f, g)

    # Test invalid pattern creation
    X = Object(:X, 0)  # Object not in category
    @test_throws ErrorException("Objects must belong to the category") create_pattern(cat, [X], Morphism[])

    # Test valid pattern creation
    valid_pattern = create_pattern(cat, [A, B], [valid_f])
    @test valid_pattern.category == cat
    @test length(valid_pattern.objects) == 2
    @test length(valid_pattern.morphisms) == 1
    @test A in valid_pattern.objects && B in valid_pattern.objects
    @test valid_f in valid_pattern.morphisms
    @test valid_pattern.id == Symbol("pattern_TestCat")

    # Test invalid colimit binding
    bad_obj = Object(:bad, 0)
    empty_bindings = Dict{Object{Int64},Morphism{Int64,Int64}}()
    @test_throws ErrorException("Missing bindings") check_binding(bad_obj, empty_bindings, valid_pattern)

    # Test morphism category membership
    @test is_morphism_in_category(valid_f, cat)
    @test is_morphism_in_category(valid_g, cat)
    @test !is_morphism_in_category(Morphism(A, C, x -> x * 3, :h), cat)
end

# Test State Space Models Examples
@testset "State Space Models Examples" begin
    # Memory creation and extension
    t₁ = Object(:t1, 1.0)
    s₁ = Object(:s1, [1.0])
    memory = TimeSeriesMemory(t₁, s₁)
    @test length(memory.times) == 1
    @test length(memory.states) == 1
    @test length(memory.links) == 0

    # Test memory extension and data access functions
    t₂ = Object(:t2, 2.0)
    s₂ = Object(:s2, [2.0])
    link = Morphism(s₁, s₂, x -> 2.0 * x, :link)
    extend!(memory, t₂, s₂, link)
    @test length(memory.times) == 2
    @test length(memory.states) == 2
    @test length(memory.links) == 1

    # Test data access functions
    data = get_data(memory)
    times = get_times(memory)
    links = get_links(memory)
    @test length(data) == 2
    @test length(times) == 2
    @test length(links) == 1
    @test all(x -> x isa Vector{Float64}, data)
    @test all(x -> x isa Float64, times)
    @test all(x -> x isa Morphism, links)
    @test data[1] == [1.0]
    @test data[2] == [2.0]
    @test times[1] == 1.0
    @test times[2] == 2.0

    # AR(1) model
    t₁, s₁, time_step, evolution = create_ar_model([0.5])
    @test s₁.data == [0.5]
    @test time_step.map(1.0) == 2.0
    @test evolution.map([0.5]) == [0.35]

    # VAR(1) model
    A = [0.5 0.2; 0.1 0.6]
    t₁, s₁, time_step, evolution = create_var_model([1.0, 2.0], A)
    @test s₁.data == [1.0, 2.0]
    @test all(evolution.map([1.0, 2.0]) .== A * [1.0, 2.0])

    # Nonlinear VAR model
    t₁, s₁, time_step, evolution = create_nonlinear_var_model([1.0, 0.5], A)
    @test s₁.data == [1.0, 0.5]
    @test evolution.map isa Function

    # Stochastic nonlinear VAR model
    t₁, s₁, time_step, evolution = create_stochastic_nonlinear_var_model([1.0, 0.5], A)
    @test s₁.data == [1.0, 0.5]
    @test evolution.map isa Function

    # Simulate dynamics
    t₁, s₁, time_step, evolution = create_ar_model([0.5])
    memory = simulate_dynamics(t₁, s₁, time_step, evolution, 5)
    @test length(memory.times) == 5
    @test length(memory.states) == 5
    @test length(memory.links) == 4

    # Data collection
    data = get_data(memory)
    times = get_times(memory)
    @test length(data) == 5
    @test length(times) == 5
    @test all(x -> x isa Vector{Float64}, data)
    @test all(x -> x isa Float64, times)
end

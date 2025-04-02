using Moma

# Declare global variables
global incompatible_caught = false
global invalid_pattern_caught = false
global invalid_binding_caught = false

# Create some basic objects and morphisms for testing
A = Object(:A, 1)
B = Object(:B, 2)
C = Object(:C, 3)
valid_f = Morphism(A, B, x -> x + 1, :valid_f)
valid_g = Morphism(B, C, x -> x * 2, :valid_g)
cat = Category([A, B, C], [valid_f, valid_g], :TestCat)

# Test object properties
@assert A.id == :A && A.data == 1
@assert B.id == :B && B.data == 2
@assert C.id == :C && C.data == 3

# Test morphism properties
@assert valid_f.source == A && valid_f.target == B
@assert valid_g.source == B && valid_g.target == C
@assert valid_f.id == :valid_f && valid_g.id == :valid_g
@assert valid_f.map(1) == 2  # Test function mapping
@assert valid_g.map(2) == 4  # Test function mapping

# Test category properties
@assert cat.id == :TestCat
@assert length(cat.objects) == 3
@assert length(cat.morphisms) == 2
@assert A in cat.objects && B in cat.objects && C in cat.objects
@assert valid_f in cat.morphisms && valid_g in cat.morphisms

# Test valid composition works
composed = compose(valid_f, valid_g)
@assert composed.source == A
@assert composed.target == C
@assert composed.map(1) == 4  # (1 + 1) * 2
@assert composed.id == :valid_f_valid_g

# Test identity morphism
id_A = identity_morphism(A)
@assert id_A.id == A.id  # Identity morphism name

# Test incompatible morphism composition
f = Morphism(A, B, x -> x, :f)
g = Morphism(C, A, x -> x, :g)
try
    compose(f, g)
catch e
    global incompatible_caught = true
    @assert e isa ErrorException
    @assert e.msg == "Morphisms are not composable"
end
@assert incompatible_caught

# Test invalid pattern creation
try
    X = Object(:X, 0)  # Object not in category
    create_pattern(cat, [X], Morphism[])
catch e
    global invalid_pattern_caught = true
    @assert e isa ErrorException
    @assert occursin("Objects must belong to the category", e.msg)
end
@assert invalid_pattern_caught

# Test valid pattern creation
valid_pattern = create_pattern(cat, [A, B], [valid_f])
@assert valid_pattern.category == cat
@assert length(valid_pattern.objects) == 2
@assert length(valid_pattern.morphisms) == 1
@assert A in valid_pattern.objects && B in valid_pattern.objects
@assert valid_f in valid_pattern.morphisms
@assert valid_pattern.id == Symbol("pattern_TestCat")

# Test invalid colimit binding
try
    # Create a valid pattern first
    bad_obj = Object(:bad, 0)
    empty_bindings = Dict{Object{Int64},Morphism{Int64,Int64}}()
    check_binding(bad_obj, empty_bindings, valid_pattern)
catch e
    global invalid_binding_caught = true
    @assert e isa ErrorException
    @assert occursin("Missing bindings", e.msg)
end
@assert invalid_binding_caught

# Test morphism category membership
@assert is_morphism_in_category(valid_f, cat)
@assert is_morphism_in_category(valid_g, cat)
@assert !is_morphism_in_category(Morphism(A, C, x -> x * 3, :h), cat)  # Non-member morphism
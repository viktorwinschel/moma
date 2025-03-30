using Moma
using Moma.Categories

# Create objects with different types of data
A = Object(:A, "object A")  # String data
B = Object(:B, 42)         # Integer data
C = Object(:C, 3.14)      # Float data

# Create morphisms with explicit functions
f_str = Morphism(A, B, x -> string(length(x)), :f_str)  # Renamed from f to f_str
g_float = Morphism(B, C, x -> float(x), :g_float)

# Compose morphisms when they are compatible
h = compose(Morphism(A, B, x -> length(x), :h),
    Morphism(B, C, x -> float(x), :i))

# this results in 11
h.map("testa10,m12")

# Create a category with objects and morphisms
objects = [A, B, C]
morphisms = [f_str, g_float, h]
cat = Category(objects, morphisms, :ExampleCategory)

# Check if morphisms belong to the category
@assert is_morphism_in_category(f_str, cat)
@assert !is_morphism_in_category(Morphism(A, C, x -> 0, :k), cat)

# Identity morphisms are always valid
id_A = Moma.Categories.identity(A)
@assert id_A.source == A
@assert id_A.target == A
@assert id_A.map("test") == "test"

# Create a simple pattern (diagram)
pattern_objects = [A, B]
pattern_morphisms = [f_str]
pattern = create_pattern(cat, pattern_objects, pattern_morphisms)

# Create a candidate colimit object
colimit = Object(:colimit, ["object A", "OBJECT A"])  # Combines data from A and B

# Create binding morphisms
bindings = Dict(
    A => Morphism(A, colimit, x -> [x, string(length(x))], :bind_A),
    B => Morphism(B, colimit, x -> ["object A", string(x)], :bind_B)
)

# Check if it forms a colimit
is_colimit = check_binding(colimit, bindings, pattern)

# Alternatively, find a colimit automatically
colimit_obj, auto_bindings = find_colimit(pattern)
@assert check_binding(colimit_obj, auto_bindings, pattern)

# Define custom data types
struct Point
    x::Float64
    y::Float64
end

struct Line
    starts::Point
    ends::Point
end

# Create objects with custom data
p1 = Object(:P1, Point(0.0, 0.0))
p2 = Object(:P2, Point(1.0, 1.0))
l1 = Object(:L1, Line(Point(0.0, 0.0), Point(1.0, 1.0)))

# Create morphisms between custom objects
f_geom = Morphism(p1, l1, p -> Line(p, Point(p.x + 1.0, p.y + 1.0)), :f_geom)  # Renamed from f to f_geom

# Create a category of geometric objects
geom_cat = Category([p1, p2, l1], [f_geom], :Geometry)

# Create and verify patterns
geom_pattern = create_pattern(geom_cat, [p1, l1], [f_geom])

# Create two categories
cat1 = Category([A, B], [f_str], :Cat1)  # Use f_str here
cat2 = Category([C], Vector{Morphism}([]), :Cat2)

# Create mappings for a functor
obj_map = Dict(A => C, B => C)
morph_map = Dict(f_str => Morphism(C, C, identity, :id_C))  # Create a proper identity morphism

# Create a functor between categories
F = Functor(cat1, cat2, obj_map, morph_map, :F)

# Create a natural transformation
components = Dict(
    A => Morphism(obj_map[A], obj_map[A], identity, :eta_A),
    B => Morphism(obj_map[B], obj_map[B], identity, :eta_B)
)
eta = NaturalTransformation(F, F, components, :eta)

# Attempting to compose incompatible morphisms
f_morph = Morphism(A, B, x -> x, :f_morph)
g_morph = Morphism(C, A, x -> x, :g_morph)
try
    compose(f_morph, g_morph)  # This will throw an error
catch e
    println("Error: ", e)  # "Morphisms are not composable"
end

# Attempting to create invalid patterns
try
    create_pattern(cat, [Object(:X, 0)], [])  # Object not in category
catch e
    println("Error: ", e)  # "Objects must belong to the category"
end

# Attempting to find invalid colimits
invalid_pattern = create_pattern(cat, [A, B], Vector{Morphism}([]))
colimit_obj, bindings = find_colimit(invalid_pattern)
try
    check_binding(Object(:bad, 0), Dict(), invalid_pattern)
catch e
    println("Error: ", e)  # Missing bindings
end

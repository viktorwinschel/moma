# Examples

This section provides examples of using the basic categorical constructions implemented in the `Categories` module.

## Basic Categorical Constructions

### Creating Objects and Morphisms

```julia
using Moma.Categories

# Create objects with different types of data
A = Object(:A, "object A")  # String data
B = Object(:B, 42)         # Integer data
C = Object(:C, 3.14)      # Float data

# Create morphisms with explicit functions
f = Morphism(A, Object(:B, "OBJECT A"), uppercase, :f)
g = Morphism(B, C, x -> float(x), :g)

# Compose morphisms when they are compatible
h = compose(Morphism(A, B, x -> length(x), :h),
           Morphism(B, C, x -> float(x), :i))
```

### Working with Categories

```julia
# Create a category with objects and morphisms
objects = [A, B, C]
morphisms = [f, g, h]
cat = Category(objects, morphisms, :ExampleCategory)

# Check if morphisms belong to the category
@assert is_morphism_in_category(f, cat)
@assert !is_morphism_in_category(Morphism(A, C, x -> 0, :k), cat)

# Identity morphisms are always valid
id_A = identity(A)
@assert id_A.source == id_A.target == A
@assert id_A.map("test") == "test"
```

### Patterns and Colimits

```julia
# Create a simple pattern (diagram)
pattern_objects = [A, B]
pattern_morphisms = [f]
pattern = create_pattern(cat, pattern_objects, pattern_morphisms)

# Create a candidate colimit object
colimit = Object(:colimit, ["object A", 42])  # Combines data from A and B

# Create binding morphisms
bindings = Dict(
    A => Morphism(A, colimit, x -> [x, 42], :bind_A),
    B => Morphism(B, colimit, x -> ["object A", x], :bind_B)
)

# Check if it forms a colimit
is_colimit = check_binding(colimit, bindings, pattern)

# Alternatively, find a colimit automatically
colimit_obj, auto_bindings = find_colimit(pattern)
@assert check_binding(colimit_obj, auto_bindings, pattern)
```

## Advanced Usage

### Creating Custom Categories

```julia
# Define custom data types
struct Point
    x::Float64
    y::Float64
end

struct Line
    start::Point
    end::Point
end

# Create objects with custom data
p1 = Object(:P1, Point(0.0, 0.0))
p2 = Object(:P2, Point(1.0, 1.0))
l1 = Object(:L1, Line(Point(0.0, 0.0), Point(1.0, 1.0)))

# Create morphisms between custom objects
f = Morphism(p1, l1, p -> Line(p, Point(p.x + 1.0, p.y + 1.0)), :f)

# Create a category of geometric objects
geom_cat = Category([p1, p2, l1], [f], :Geometry)

# Create and verify patterns
geom_pattern = create_pattern(geom_cat, [p1, l1], [f])
```

### Working with Multiple Categories

```julia
# Create two categories
cat1 = Category([A, B], [f], :Cat1)
cat2 = Category([C], [], :Cat2)

# Create mappings for a functor
obj_map = Dict(A => C, B => C)
morph_map = Dict(f => identity(C))

# Create a functor between categories
F = Functor(cat1, cat2, obj_map, morph_map, :F)

# Create a natural transformation
components = Dict(
    A => Morphism(obj_map[A], obj_map[A], identity, :eta_A),
    B => Morphism(obj_map[B], obj_map[B], identity, :eta_B)
)
eta = NaturalTransformation(F, F, components, :eta)
```

## Error Handling Examples

```julia
# Attempting to compose incompatible morphisms
f = Morphism(A, B, x -> x, :f)
g = Morphism(C, A, x -> x, :g)
try
    compose(f, g)  # This will throw an error
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
invalid_pattern = create_pattern(cat, [A, B], [])
colimit_obj, bindings = find_colimit(invalid_pattern)
try
    check_binding(Object(:bad, 0), Dict(), invalid_pattern)
catch e
    println("Error: ", e)  # Missing bindings
end
```
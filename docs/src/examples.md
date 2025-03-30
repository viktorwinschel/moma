# Examples

This section provides examples of using the basic categorical constructions implemented in the `Categories` module.

## Basic Categorical Constructions

### Creating Objects and Morphisms

```julia
using Moma.Categories

# Create objects
A = Object(:A, "object A")
B = Object(:B, "object B")
C = Object(:C, "object C")

# Create morphisms
f = Morphism(A, B, x -> x, :f)
g = Morphism(B, C, x -> x, :g)

# Compose morphisms
h = compose(f, g)
```

### Working with Categories

```julia
# Create a category
objects = [A, B, C]
morphisms = [f, g, h]
C = Category(objects, morphisms, :ExampleCategory)

# Check if a morphism is in the category
is_morphism_in_category(f, C)  # true
is_morphism_in_category(Morphism(A, C, x -> x, :k), C)  # false
```

### Patterns and Colimits

```julia
# Create a pattern
pattern_objects = [A, B]
pattern_morphisms = [f]
P = create_pattern(C, pattern_objects, pattern_morphisms)

# Create bindings for colimit analysis
bindings = Dict()
for obj in pattern_objects
    bindings[obj] = identity(obj)
end

# Check if the pattern forms a colimit
is_colimit = check_binding(B, bindings, P)
```

### Functors and Natural Transformations

```julia
# Create another category
D = Object(:D, "object D")
E = Object(:E, "object E")
k = Morphism(D, E, x -> x, :k)
D = Category([D, E], [k], :TargetCategory)

# Create object and morphism maps for the functor
object_map = Dict(A => D, B => E)
morphism_map = Dict(f => k)

# Create a functor
F = Functor(C, D, object_map, morphism_map, :ExampleFunctor)

# Create a natural transformation
η = NaturalTransformation(F, F, Dict(A => identity(A), B => identity(B)), :eta)
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
GeomCategory = Category([p1, p2, l1], [f], :Geometry)
```

### Working with Multiple Categories

```julia
# Create a functor between categories
object_map = Dict(p1 => A, p2 => B, l1 => C)
morphism_map = Dict(f => g)

G = Functor(GeomCategory, C, object_map, morphism_map, :GeometryToExample)

# Compose functors
H = compose(F, G)
```
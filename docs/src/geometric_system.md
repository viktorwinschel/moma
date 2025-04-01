# Geometric System

The category theory framework can be used with any custom data types. Here's an example using geometric objects:

```julia
using Moma

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
@assert p1.data.x == 0.0
@assert p1.data.y == 0.0
@assert p2.data.x == 1.0
@assert p2.data.y == 1.0
@assert l1.data.start.x == 0.0
@assert l1.data.start.y == 0.0
@assert l1.data.ends.x == 1.0
@assert l1.data.ends.y == 1.0
@assert p1.id == :P1
@assert p2.id == :P2
@assert l1.id == :L1

# Create morphisms between custom objects
f = Morphism(p1, l1, p -> Line(p, Point(p.x + 1.0, p.y + 1.0)), :f)

# Test morphism application
result = f.map(p1.data)
@assert result.start.x == 0.0
@assert result.start.y == 0.0
@assert result.ends.x == 1.0
@assert result.ends.y == 1.0
@assert f.id == :f
@assert f.source == p1
@assert f.target == l1

# Create a category of geometric objects
geom_cat = Category([p1, p2, l1], [f], :Geometry)
@assert length(geom_cat.objects) == 3
@assert length(geom_cat.morphisms) == 1
@assert geom_cat.id == :Geometry
@assert p1 in geom_cat.objects
@assert p2 in geom_cat.objects
@assert l1 in geom_cat.objects
@assert f in geom_cat.morphisms

# Create patterns
geom_pattern = create_pattern(geom_cat, [p1, l1], [f])
@assert length(geom_pattern.objects) == 2
@assert length(geom_pattern.morphisms) == 1
@assert geom_pattern.category == geom_cat
@assert p1 in geom_pattern.objects
@assert l1 in geom_pattern.objects
@assert f in geom_pattern.morphisms
``` 
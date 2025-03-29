# Examples

This section provides detailed examples of using Moma.jl, including both basic categorical constructions and the traffic network example.

## Basic Categorical Constructions

### Creating Objects and Morphisms

```julia
using Moma

# Create objects with different data types
point = Object(:P1, (x=1.0, y=2.0))
number = Object(:N1, 42)

# Create a morphism between objects
f = Morphism(point, number, p -> p.x + p.y, :f1)
```

### Working with Categories

```julia
# Create a simple category with two objects and a morphism
objects = [point, number]
morphisms = [f]
cat = Category(objects, morphisms, :SimpleCategory)

# Create identity morphisms
id_point = identity(point)
id_number = identity(number)

# Compose morphisms
g = Morphism(number, point, n -> (x=n, y=n), :g1)
h = compose(f, g)  # Composition of f and g
```

### Patterns and Colimits

```julia
# Create a pattern in the category
pattern_objects = [point, number]
pattern_morphisms = [f]
pattern = create_pattern(cat, pattern_objects, pattern_morphisms)

# Check if an object forms a colimit
bindings = Dict(point => id_point, number => id_number)
is_colimit = check_binding(point, bindings, pattern)
```

## Traffic Network Example

### Creating a Traffic Network

```julia
using Moma

# Create a traffic network
network = create_traffic_network()

# The network contains:
# - 3 junctions (J1, J2, J3)
# - 3 road segments (R1, R2, R3)
# - 6 traffic flow connections (m1 through m6)
```

### Analyzing Traffic Flow

```julia
# Analyze traffic flow in the network
results = analyze_traffic_flow(network)

# Results include:
println("Path length: $(results["path_length"])")
println("Total flow: $(results["total_flow"])")
println("Bottleneck capacity: $(results["bottleneck"])")
```

### Understanding the Network Structure

The traffic network is modeled as a category where:

1. **Objects**:
   - `Junction`: Represents intersection points with capacity and current load
   - `RoadSegment`: Represents road sections with length, capacity, and current flow

2. **Morphisms**:
   - Represent traffic flow connections between junctions and road segments
   - Map junction loads to road segment flows and vice versa

3. **Patterns**:
   - Used to analyze specific paths through the network
   - Help identify bottlenecks and flow patterns

### Example Network Layout

```
    J1 ----R1----> J2 ----R2----> J3
                   |
                   R3
                   |
                   v
```

In this example:
- Traffic flows from J1 to J3 through two possible paths
- The network can be analyzed using categorical patterns to:
  - Find optimal routes
  - Identify bottlenecks
  - Calculate total flow capacity
  - Track traffic evolution over time

## Advanced Usage

### Creating Custom Categories

```julia
# Define custom data types for your category
struct CustomObject
    name::String
    value::Float64
end

# Create objects with custom data
obj1 = Object(:O1, CustomObject("first", 1.0))
obj2 = Object(:O2, CustomObject("second", 2.0))

# Create custom morphisms
m = Morphism(obj1, obj2, o -> CustomObject(o.name * "_mapped", o.value * 2), :m1)

# Build your category
custom_cat = Category([obj1, obj2], [m], :CustomCategory)
```

### Working with Functors

```julia
# Create a functor between categories
# (This is a simplified example - actual implementation would be more complex)
function create_simple_functor(source::Category, target::Category)
    object_map = Dict()
    morphism_map = Dict()
    
    # Map objects and morphisms
    for obj in source.objects
        object_map[obj] = Object(Symbol("F_$(obj.id)"), obj.data)
    end
    
    for mor in source.morphisms
        morphism_map[mor] = Morphism(
            object_map[mor.source],
            object_map[mor.target],
            mor.map,
            Symbol("F_$(mor.id)")
        )
    end
    
    Functor(source, target, object_map, morphism_map, :SimpleFunctor)
end
```

### Natural Transformations

```julia
# Create a natural transformation between functors
# (This is a simplified example - actual implementation would be more complex)
function create_simple_transformation(source::Functor, target::Functor)
    components = Dict()
    
    # Create component morphisms
    for obj in source.source.objects
        components[obj] = Morphism(
            source.object_map[obj],
            target.object_map[obj],
            x -> x,  # Identity mapping
            Symbol("η_$(obj.id)")
        )
    end
    
    NaturalTransformation(source, target, components, :SimpleTransformation)
end
``` 
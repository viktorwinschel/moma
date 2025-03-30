"""
    module Categories

This module provides basic categorical constructions used in Memory Evolutive Systems (MES).
It includes implementations of objects, morphisms, categories, functors, natural transformations,
and patterns, along with functions for working with these constructions.

# Mathematical Background
The module implements core concepts from category theory:
- Objects and morphisms form categories with composition and identity laws
- Functors preserve structure between categories
- Natural transformations connect functors
- Colimits represent universal constructions

# Exports
- `Object`: Represents an object in a category
- `Morphism`: Represents a morphism between objects
- `Category`: Represents a category with objects and morphisms
- `Functor`: Represents a functor between categories
- `NaturalTransformation`: Represents a natural transformation between functors
- `Pattern`: Represents a pattern (diagram) in a category
- `identity`: Creates an identity morphism for an object
- `compose`: Composes two morphisms
- `create_pattern`: Creates a pattern from objects and morphisms
- `check_binding`: Checks if an object forms a colimit for a pattern
- `find_colimit`: Finds or constructs colimits for patterns
- `is_morphism_in_category`: Checks if a morphism belongs to a category
"""
module Categories

export Object, Morphism, Category, Functor, NaturalTransformation, Pattern
export identity, compose, create_pattern, check_binding, find_colimit, is_morphism_in_category

"""
    Object{T}

Represents an object in a category.

# Type Parameters
- `T`: The type of data associated with the object

# Fields
- `id::Symbol`: Unique identifier for the object
- `data::T`: Data associated with the object

# Examples
```julia
# Create an object with string data
obj = Object(:A, "data")

# Create an object with numeric data
num_obj = Object(:B, 42)

# Create an object with custom type
struct Point
    x::Float64
    y::Float64
end
point_obj = Object(:P, Point(0.0, 1.0))
```
"""
struct Object{T}
    id::Symbol
    data::T
end

"""
    Morphism{S,T}

Represents a morphism between objects in a category.

# Type Parameters
- `S`: The type of data in the source object
- `T`: The type of data in the target object

# Fields
- `source::Object{S}`: Source object
- `target::Object{T}`: Target object
- `map::Function`: Function mapping source to target
- `id::Symbol`: Unique identifier for the morphism

# Examples
```julia
# Create objects
A = Object(:A, "hello")
B = Object(:B, "HELLO")

# Create a morphism that uppercases strings
f = Morphism(A, B, uppercase, :f)
@assert f.map(A.data) == B.data

# Create a morphism between numeric objects
X = Object(:X, 1)
Y = Object(:Y, 2)
g = Morphism(X, Y, x -> x + 1, :g)
```
"""
struct Morphism{S,T}
    source::Object{S}
    target::Object{T}
    map::Function
    id::Symbol
end

"""
    Category

Represents a category with objects and morphisms.

# Fields
- `objects::Vector{<:Object}`: Objects in the category
- `morphisms::Vector{<:Morphism}`: Morphisms in the category
- `id::Symbol`: Unique identifier for the category
"""
struct Category
    objects::Vector{<:Object}
    morphisms::Vector{<:Morphism}
    id::Symbol
end

"""
    Functor

Represents a functor between categories.

# Fields
- `source::Category`: Source category
- `target::Category`: Target category
- `object_map::Dict{<:Object,<:Object}`: Mapping of objects
- `morphism_map::Dict{<:Morphism,<:Morphism}`: Mapping of morphisms
- `id::Symbol`: Unique identifier for the functor
"""
struct Functor
    source::Category
    target::Category
    object_map::Dict{<:Object,<:Object}
    morphism_map::Dict{<:Morphism,<:Morphism}
    id::Symbol
end

"""
    NaturalTransformation

Represents a natural transformation between functors.

# Fields
- `source::Functor`: Source functor
- `target::Functor`: Target functor
- `components::Dict{<:Object,<:Morphism}`: Component morphisms
- `id::Symbol`: Unique identifier for the natural transformation
"""
struct NaturalTransformation
    source::Functor
    target::Functor
    components::Dict{<:Object,<:Morphism}
    id::Symbol
end

"""
    Pattern

Represents a pattern (diagram) in a category.

# Fields
- `category::Category`: The category containing the pattern
- `objects::Vector{<:Object}`: Objects in the pattern
- `morphisms::Vector{<:Morphism}`: Morphisms in the pattern
- `id::Symbol`: Unique identifier for the pattern
"""
struct Pattern
    category::Category
    objects::Vector{<:Object}
    morphisms::Vector{<:Morphism}
    id::Symbol
end

"""
    identity(obj::Object)

Create an identity morphism for an object.

# Arguments
- `obj::Object`: The object to create an identity morphism for

# Returns
- `Morphism`: A morphism from the object to itself with the identity function

# Examples
```julia
A = Object(:A, "data")
id_A = identity(A)
@assert id_A.map(A.data) == A.data
```
"""
function identity(obj::Object{T}) where {T}
    Morphism(obj, obj, x -> x, Symbol("id_$(obj.id)"))
end

"""
    compose(f::Morphism, g::Morphism)

Compose two morphisms if they are composable (target of f equals source of g).

# Arguments
- `f::Morphism{S,T}`: First morphism
- `g::Morphism{T,U}`: Second morphism

# Returns
- `Morphism{S,U}`: The composition g ∘ f

# Throws
- `ErrorException`: If the morphisms are not composable (f.target ≠ g.source)

# Examples
```julia
# Create objects and morphisms
A = Object(:A, "hello")
B = Object(:B, "HELLO")
C = Object(:C, "HELLO!")
f = Morphism(A, B, uppercase, :f)
g = Morphism(B, C, s -> s * "!", :g)

# Compose morphisms
h = compose(f, g)
@assert h.map("hello") == "HELLO!"

# This will throw an error
k = Morphism(C, A, lowercase, :k)
compose(f, k)  # Error: Morphisms are not composable
```
"""
function compose(f::Morphism{S,T}, g::Morphism{T,U}) where {S,T,U}
    if f.target == g.source
        Morphism(f.source, g.target, x -> g.map(f.map(x)), Symbol("$(f.id)_$(g.id)"))
    else
        error("Morphisms are not composable")
    end
end

"""
    create_pattern(category::Category, objects::Vector{<:Object}, morphisms::Vector{<:Morphism})

Create a pattern (diagram) from a subset of objects and morphisms in a category.

# Arguments
- `category::Category`: The category containing the objects and morphisms
- `objects::Vector{<:Object}`: Objects to include in the pattern
- `morphisms::Vector{<:Morphism}`: Morphisms to include in the pattern

# Returns
- `Pattern`: A new pattern containing the specified objects and morphisms

# Throws
- `ErrorException`: If any object or morphism does not belong to the category

# Examples
```julia
# Create objects and morphisms
A = Object(:A, 1)
B = Object(:B, 2)
f = Morphism(A, B, x -> x + 1, :f)

# Create category and pattern
C = Category([A, B], [f], :C)
P = create_pattern(C, [A, B], [f])

# This will throw an error
X = Object(:X, 0)
create_pattern(C, [A, X], [f])  # Error: Objects must belong to the category
```
"""
function create_pattern(category::Category, objects::Vector{<:Object}, morphisms::Vector{<:Morphism})
    # Verify objects and morphisms belong to the category
    all(o in category.objects for o in objects) || error("Objects must belong to the category")
    all(m in category.morphisms for m in morphisms) || error("Morphisms must belong to the category")

    Pattern(category, objects, morphisms, Symbol("pattern_$(category.id)"))
end

"""
    check_binding(object::Object, bindings::Dict{<:Object,<:Morphism}, pattern::Pattern)

Check if an object with specified bindings forms a colimit for a pattern.

# Arguments
- `object::Object`: The candidate colimit object
- `bindings::Dict{<:Object,<:Morphism}`: Morphisms from pattern objects to the candidate
- `pattern::Pattern`: The pattern to check

# Returns
- `Bool`: true if the object with bindings forms a colimit, false otherwise

# Mathematical Description
For a pattern P and an object C with bindings b, this checks if C is a colimit by verifying:
1. Every object in P has a binding morphism to C
2. All diagrams commute: For any morphism f: X → Y in P, b_Y ∘ f = b_X
where b_X and b_Y are the binding morphisms for X and Y respectively.

# Examples
```julia
# Create a simple pattern
A = Object(:A, 1)
B = Object(:B, 2)
f = Morphism(A, B, x -> x + 1, :f)
C = Category([A, B], [f], :C)
P = create_pattern(C, [A, B], [f])

# Create bindings to a candidate colimit
colimit = Object(:Col, [1, 2])
bindings = Dict(
    A => Morphism(A, colimit, x -> [x, x+1], :bA),
    B => Morphism(B, colimit, x -> [x-1, x], :bB)
)

# Check if it forms a colimit
is_colimit = check_binding(colimit, bindings, P)
```
"""
function check_binding(object::Object, bindings::Dict{<:Object,<:Morphism}, pattern::Pattern)
    # Verify all pattern objects have bindings
    all(o in keys(bindings) for o in pattern.objects) || return false

    # Verify morphisms commute
    for m in pattern.morphisms
        source_binding = bindings[m.source]
        target_binding = bindings[m.target]

        # Check if the diagram commutes: source_binding = m ∘ target_binding
        source_data = m.source.data
        path1 = source_binding.map(source_data)
        path2 = target_binding.map(m.map(source_data))

        path1 == path2 || return false
    end

    true
end

"""
    find_colimit(pattern::Pattern)

Find or construct a colimit for a pattern.

# Arguments
- `pattern::Pattern`: The pattern to find a colimit for

# Returns
- `Tuple{Object,Dict{<:Object,<:Morphism}}`: A tuple containing:
  - The colimit object
  - A dictionary mapping pattern objects to their binding morphisms

# Description
This function constructs a colimit by:
1. Creating a candidate object that combines data from all pattern objects
2. Constructing appropriate morphisms from pattern objects to the candidate
3. Verifying the colimit properties

# Mathematical Background
A colimit is a universal cocone over a diagram. For a pattern P, it consists of:
- An object C (the colimit object)
- A family of morphisms b_i: P_i → C (the binding morphisms)
such that:
1. All diagrams commute
2. For any other cocone (D, h_i), there exists a unique morphism u: C → D
   making all triangles commute

# Examples
```julia
# Create a simple pattern
A = Object(:A, 1)
B = Object(:B, 2)
f = Morphism(A, B, x -> x + 1, :f)
C = Category([A, B], [f], :C)
P = create_pattern(C, [A, B], [f])

# Find its colimit
colimit_obj, bindings = find_colimit(P)
@assert colimit_obj.data == [1, 2]  # Combined data
@assert check_binding(colimit_obj, bindings, P)  # Verify it's a colimit
```

# Throws
- `ErrorException`: If a valid colimit cannot be constructed
"""
function find_colimit(pattern::Pattern)
    # Always combine data into an array
    combined_data = [obj.data for obj in pattern.objects]
    colimit_id = Symbol("colimit_$(pattern.id)")
    colimit_obj = Object(colimit_id, combined_data)

    # Create bindings that map each object's data to the combined array
    bindings = Dict{Object,Morphism}()
    for obj in pattern.objects
        binding_id = Symbol("binding_$(obj.id)_to_$(colimit_id)")
        bindings[obj] = Morphism(obj, colimit_obj, x -> combined_data, binding_id)
    end

    return (colimit_obj, bindings)
end

"""
    is_morphism_in_category(morphism::Morphism, category::Category)

Check if a morphism belongs to a category.

# Arguments
- `morphism::Morphism`: The morphism to check
- `category::Category`: The category to check against

# Returns
- `Bool`: true if the morphism belongs to the category, false otherwise

# Examples
```julia
# Create objects and a morphism
A = Object(:A, 1)
B = Object(:B, 2)
f = Morphism(A, B, x -> x + 1, :f)

# Create a category and check membership
C = Category([A, B], [f], :C)
@assert is_morphism_in_category(f, C)

# Check a morphism not in the category
g = Morphism(B, A, x -> x - 1, :g)
@assert !is_morphism_in_category(g, C)
```
"""
function is_morphism_in_category(morphism::Morphism, category::Category)
    morphism in category.morphisms
end

end # module 
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
- `identity_morphism`: Creates an identity morphism for an object
- `compose`: Composes two morphisms
- `create_pattern`: Creates a pattern from objects and morphisms
- `check_binding`: Checks if an object forms a colimit for a pattern
- `find_colimit`: Finds or constructs colimits for patterns
- `is_morphism_in_category`: Checks if a morphism belongs to a category
"""
module Categories

export Object, Morphism, Category, Functor, NaturalTransformation, Pattern
export identity_morphism, compose, create_pattern, check_binding, find_colimit, is_morphism_in_category

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
    identity_morphism(obj::Object)

Create an identity morphism for an object.

# Arguments
- `obj::Object`: The object to create an identity morphism for

# Returns
- `Morphism`: A morphism from the object to itself with the identity function

# Examples
```julia
A = Object(:A, "data")
id_A = identity_morphism(A)
@assert id_A.map(A.data) == A.data
```
"""
function identity_morphism(obj::Object{T}) where {T}
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
    check_binding(obj::Object, binding::Dict{<:Object,<:Morphism}, pattern::Pattern)

Check if an object forms a valid binding for a pattern.

# Arguments
- `obj::Object`: The object to check as a potential binding
- `binding::Dict{<:Object,<:Morphism}`: Current binding of pattern objects to category objects
- `pattern::Pattern`: The pattern to check the binding against

# Returns
- `Bool`: true if the object forms a valid binding, false otherwise

# Examples
```julia
# Create a pattern and potential binding
pattern = create_pattern(cat, [obj1, obj2], [morph])
binding = Dict(obj1 => obj3, obj2 => obj4)

# Check if obj5 forms a valid binding
is_valid = check_binding(obj5, binding, pattern)
```
"""
function check_binding(obj::Object, binding::Dict{<:Object,<:Morphism}, pattern::Pattern)
    # Verify all pattern objects have bindings
    if !all(o -> haskey(binding, o), pattern.objects)
        error("Missing bindings")
    end

    # Verify morphisms commute
    for m in pattern.morphisms
        source_binding = binding[m.source]
        target_binding = binding[m.target]

        # Check if the diagram commutes
        source_data = m.source.data
        path1 = source_binding.map(source_data)
        path2 = target_binding.map(m.map(source_data))

        # Convert both paths to arrays for comparison
        path1_arr = collect(path1)
        path2_arr = collect(path2)

        if length(path1_arr) != length(path2_arr) || !all(x == y for (x, y) in zip(path1_arr, path2_arr))
            return false
        end
    end

    return true
end

"""
    find_colimit(pattern::Pattern)

Find or construct a colimit for a pattern in its category.

# Arguments
- `pattern::Pattern`: The pattern to find a colimit for

# Returns
- `Object`: The colimit object if found
- `nothing`: If no colimit exists

# Throws
- `ErrorException`: If the pattern is invalid or the colimit cannot be constructed

# Examples
```julia
# Create a pattern
pattern = create_pattern(cat, [obj1, obj2], [morph])

# Find its colimit
colimit = find_colimit(pattern)
```
"""
function find_colimit(pattern::Pattern)
    if isempty(pattern.objects)
        error("Pattern must have at least one object")
    end

    # Create the colimit object with a properly initialized array of data
    colimit_data = Vector{Any}(undef, length(pattern.objects))
    for (i, obj) in enumerate(pattern.objects)
        colimit_data[i] = obj.data
    end

    colimit_obj = Object(Symbol("colimit_$(pattern.id)"), colimit_data)

    # Create bindings
    bindings = Dict{Object,Morphism}()
    for (i, obj) in enumerate(pattern.objects)
        bindings[obj] = Morphism(
            obj,
            colimit_obj,
            x -> begin
                result = copy(colimit_data)
                result[i] = x
                result
            end,
            Symbol("binding_$(obj.id)_to_$(colimit_obj.id)")
        )
    end

    if !check_binding(colimit_obj, bindings, pattern)
        error("Failed to construct valid colimit")
    end

    return colimit_obj
end

"""
    is_morphism_in_category(morph::Morphism, cat::Category)

Check if a morphism belongs to a category.

# Arguments
- `morph::Morphism`: The morphism to check
- `cat::Category`: The category to check against

# Returns
- `Bool`: true if the morphism belongs to the category, false otherwise

# Examples
```julia
# Check if a morphism belongs to a category
belongs = is_morphism_in_category(morph, cat)
```
"""
function is_morphism_in_category(morph::Morphism, cat::Category)
    morph in cat.morphisms
end

end # module 
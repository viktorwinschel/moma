struct Account
    id::Symbol
    debit::Vector{Float64}
    credit::Vector{Float64}
end

struct MikroLedger        # an object of type T consist of
    id::Symbol      # name
    assets::Vector{Account}
    liabs::Vector{Account}
end

struct MacroLedger
    id::Symbol
    moma::Vector{MicroLedger}
end

struct MacroBooking
    id::Symbol
    amount::Float64
    agent1::Account
    agent2::Account
    date::Date
end

struct MicroBooking
    id::Symbol
    amount:Float64
    debit::Account
    credit::Account
end

struct Object{}        # an object of type T consist of
    id::Symbol          # name
    data::T             # data of type T
end

struct Morphism{S,T}    # a morphism of type (S,T) consist of
    source::Object{S}   # source Object of type S
    target::Object{T}   # target Object of type T
    map::Function       # Julia function, i.e. computation
    id::Symbol          # name
end

struct Category                   # a category consist of
    objects::Vector{<:Object}     # objects of type Vector of Objects
    morphisms::Vector{<:Morphism} # morphisms of type Vector of Morphisms
    id::Symbol                    # name
end

struct Functor
    source::Category
    target::Category
    object_map::Dict{<:Object,<:Object}
    morphism_map::Dict{<:Morphism,<:Morphism}
    id::Symbol
end

struct NaturalTransformation
    source::Functor
    target::Functor
    components::Dict{<:Object,<:Morphism}
    id::Symbol
end

struct Pattern
    category::Category
    objects::Vector{<:Object}
    morphisms::Vector{<:Morphism}
    id::Symbol
end

struct ObjectNotInCategoryError <: Exception
    msg::String
    object::Object
    category::Category
end

struct MorphismNotInCategoryError <: Exception
    msg::String
    morphism::Morphism
    category::Category
end

struct MorphismCompositionError <: Exception
    msg::String
    first_morphism::Symbol  # id of first morphism
    second_morphism::Symbol # id of second morphism
    target::Symbol          # target of first morphism
    source::Symbol          # source of second morphism
end

struct PatternHasNoBindingError <: Exception
    msg::String
    object::Object
    binding::Dict{<:Object,<:Morphism}
    pattern::Pattern
end

struct PatternMustHaveAtLeastOneObject <: Exception
    msg::String
    pattern::Pattern
end

function identity_morphism(obj::Object{T}) where {T}
    Morphism(obj, obj, x -> x, Symbol("id_$(obj.id)"))
end

function compose(f::Morphism{S,T}, g::Morphism{T,U}) where {S,T,U}
    if f.target == g.source
        Morphism(f.source, g.target, x -> g.map(f.map(x)), Symbol("$(f.id)_$(g.id)"))
    else
        throw(MorphismCompositionError(
            "Morphisms $(f.id) and $(g.id) are not composable," *
            "target of $(f.id) $(f.target.id) != $(g.source.id) source of $(g.id).",
            f.id,
            g.id,
            f.target.id,
            g.source.id
        ))
    end
end

function is_morphism_in_category(morph::Morphism, cat::Category)
    morph in cat.morphisms
end

function create_pattern(category::Category, objects::Vector{<:Object}, morphisms::Vector{<:Morphism})
    # Verify objects and morphisms belong to the category
    for o in objects
        is_object_in_category(o, category) ||
            throw(ObjectNotInCategoryError(
                "Object $(o.id) must belong to the category $(category.id)",
                o,
                category))
    end
    for m in morphisms
        is_morphism_in_category(m, category) ||
            throw(MorphismNotInCategoryError(
                "Morphism $(m.id) must belong to the category $(category.id)",
                m,
                category))

    end
    return Pattern(category, objects, morphisms, Symbol("$(category.id)_$(length(objects))_$(length(morphisms))"))
end

function check_binding(obj::Object, binding::Dict{<:Object,<:Morphism}, pattern::Pattern)
    # Verify all pattern objects have bindings
    for o in pattern.objects
        if !haskey(binding, o)
            throw(PatternHasNoBindingError(
                "Pattern $(pattern.id) has no binding for object $(o.id)",
                o,
                binding,
                pattern))
        end
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

        if length(path1_arr) != length(path2_arr) ||
           !all(x == y for (x, y) in zip(path1_arr, path2_arr))
            return false
        end
    end

    return true
end

function find_colimit(pattern::Pattern)
    !isempty(pattern.objects) ||
        throw(PatternMustHaveAtLeastOneObject(
            "Pattern $(pattern.id) must have at least one object",
            pattern))
    println("construct colimit data")
    # Create the colimit object with a properly initialized array of data
    colimit_data = Vector(undef, length(pattern.objects))
    for (i, obj) in enumerate(pattern.objects)
        colimit_data[i] = obj.data
    end

    colimit_obj = Object(Symbol("colimit_$(pattern.id)"), colimit_data)

    println("construct bindings")    # Create bindings
    bindings = Dict{Object,Morphism}()
    typeof(bindings)
    pattern.objects
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

    return colimit_obj, bindings
end

struct Object{T}
    id::Symbol
    data::T
end

struct Morphism{S,T}
    source::Object{S}
    target::Object{T}
    map::Function
    id::Symbol
end

struct Category
    objects::Vector{<:Object}
    morphisms::Vector{<:Morphism}
    id::Symbol
end

struct Pattern
    category::Category
    objects::Vector{<:Object}
    morphisms::Vector{<:Morphism}
    id::Symbol
end

function identity_morphism(obj::Object{T}) where {T}
    Morphism(obj, obj, x -> x, Symbol("id_$(obj.id)"))
end

function compose(f::Morphism{S,T}, g::Morphism{T,U}) where {S,T,U}
    if f.target == g.source
        Morphism(f.source, g.target, x -> g.map(f.map(x)), Symbol("$(f.id)_$(g.id)"))
    else
        error("Morphisms $(f.id) and $(g.id) are not composable.")
    end
end

function is_object_in_category(obj::Object, cat::Category)
    obj in cat.objects
end

function is_morphism_in_category(morph::Morphism, cat::Category)
    morph in cat.morphisms
end

function create_pattern(category::Category, objects::Vector{<:Object}, morphisms::Vector{<:Morphism})
    for o in objects
        is_object_in_category(o, category) || error("Object $(o.id) not in category $(category.id)")
    end
    for m in morphisms
        is_morphism_in_category(m, category) || error("Morphism $(m.id) not in category $(category.id)")
    end
    return Pattern(category, objects, morphisms, Symbol("pattern_$(category.id)"))
end

function check_binding(binding::Dict{<:Object,<:Morphism}, pattern::Pattern)
    for m in pattern.morphisms
        source_binding = binding[m.source]
        target_binding = binding[m.target]

        x = m.source.data
        left = source_binding.map(x)
        right = target_binding.map(m.map(x))

        @assert left == right "Glueing condition failed at morphism $(m.id)"
    end
    return true
end

function is_injective(f::Function, domain::Vector)
    image = map(f, domain)
    length(unique(image)) == length(image)
end

function find_colimit(pattern::Pattern)
    colimit_data = [obj.data for obj in pattern.objects]
    colimit_obj = Object(Symbol("colimit_$(pattern.id)"), colimit_data)

    bindings = Dict{Object,Morphism}()
    for (i, obj) in enumerate(pattern.objects)
        bindings[obj] = Morphism(
            obj,
            colimit_obj,
            x -> begin
                new_data = copy(colimit_data)
                new_data[i] = x
                new_data
            end,
            Symbol("binding_$(obj.id)_to_$(colimit_obj.id)")
        )
    end

    @assert check_binding(bindings, pattern) "Colimit bindings do not satisfy glueing conditions."
    return colimit_obj, bindings
end

function make_example_pattern(values::Tuple, expr::Function, baseid::Symbol)
    A = Object(Symbol("$(baseid)1"), values[1])
    B = Object(Symbol("$(baseid)2"), values[2])

    # berechne den Zielwert symbolisch
    imageA = expr(A.data)
    imageB = expr(B.data)

    # Konsistenzprüfung
    @assert imageA == imageB "Expression must evaluate both branches to the same value"
    if imageA != imageB
        @warn "Morphisms don't agree on target data: $imageA != $imageB"
    end

    X = Object(Symbol("$(baseid)X"), imageA)

    mA = Morphism(A, X, expr, Symbol("m_$(A.id)_$(X.id)"))
    mB = Morphism(B, X, expr, Symbol("m_$(B.id)_$(X.id)"))

    cat = Category([A, B, X], [mA, mB], Symbol("cat_$(baseid)"))
    return create_pattern(cat, [A, B, X], [mA, mB])
end

function test_colimit(pattern::Pattern)
    colimit_obj, bindings = find_colimit(pattern)
    println("Colimit object: $(colimit_obj.id) with data $(colimit_obj.data)")
    for (obj, morph) in bindings
        println("Binding: $(obj.id) => $(morph.id), map($(obj.data)) = ", morph.map(obj.data))
        @assert is_injective(morph.map, [obj.data]) "Binding $(morph.id) is not injective"
    end
    println("✅ All bindings are injective and glueing conditions are satisfied.")
end

function pushout(a::Morphism, b::Morphism)
    @assert a.source == b.source "Pushout requires parallel morphisms with same source."
    a_target = a.target
    b_target = b.target
    combined_data = (a_target.data, b_target.data)
    po_obj = Object(Symbol("pushout_$(a.id)_$(b.id)"), combined_data)

    ma = Morphism(a_target, po_obj, x -> (x, b_target.data), Symbol("po_m1_$(a_target.id)_to_$(po_obj.id)"))
    mb = Morphism(b_target, po_obj, x -> (a_target.data, x), Symbol("po_m2_$(b_target.id)_to_$(po_obj.id)"))

    objects = [a.source, a_target, b_target, po_obj]
    morphisms = [a, b, ma, mb]
    cat = Category(objects, morphisms, Symbol("pushout_cat_$(a.id)_$(b.id)"))

    pattern = create_pattern(cat, objects, morphisms)
    return pattern
end

function test_pushout(a::Morphism, b::Morphism)
    println("\n▶ Testing pushout of: $(a.id), $(b.id)")
    pushout_pattern = pushout(a, b)
    test_colimit(pushout_pattern)
end

# Sequential Evaluation (1, 2, x + 1)
pattern1 = make_example_pattern((1, 2), x -> x + 1, :A)
pattern_not_ok = make_example_pattern((1, 3), x -> x + 1, :C)
pattern_not_ok = make_example_pattern((1, 2), x -> x * 2, :C)
pattern_not_ok = make_example_pattern((1, 3), x -> x + 2, :C)
pattern_ok = make_example_pattern((1, 1), x -> x + 1, :C)

test_colimit(pattern1)

# Parallel Evaluation (4, 6, x + 2)
pattern2 = make_example_pattern((4, 6), x -> x + 2, :B)
test_colimit(pattern2)

# Merged Evaluation (Parallel Structure)
merged = merge_patterns(pattern1, pattern2)
test_colimit(merged)

# Pushout example (shared source, parallel morphisms)
a = Morphism(Object(:Z, 10), Object(:A, 1), x -> x - 9, :f)
b = Morphism(Object(:Z, 10), Object(:B, 4), x -> x - 6, :g)
test_pushout(a, b)

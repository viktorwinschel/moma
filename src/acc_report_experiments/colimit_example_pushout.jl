using Base: @kwdef

@kwdef struct ExprObj{T}
    id::Symbol
    data::T
end

# Konstruktion der Beispielkategorie
function make_example_pattern(values::Tuple, expr::Function, baseid::Symbol)
    x = :x  # symbolische Variable
    A = Object(Symbol("$(baseid)1"), values[1])
    B = Object(Symbol("$(baseid)2"), values[2])
    X = Object(Symbol("$(baseid)X"), expr)

    mA = Morphism(A, X, x -> expr, Symbol("m_$(A.id)_$(X.id)"))
    mB = Morphism(B, X, x -> expr, Symbol("m_$(B.id)_$(X.id)"))

    cat = Category([A, B, X], [mA, mB], Symbol("C_$(baseid)"))
    pattern = create_pattern(cat, [A, B, X], [mA, mB])
    return pattern
end

function test_colimit_glueing(pattern::Pattern)
    colimit_obj, bindings = find_colimit(pattern)

    println("\n📌 Colimit object: $(colimit_obj.id), data: $(colimit_obj.data)")
    println("📎 Bindings:")
    for (o, morph) in bindings
        println("  $(o.id) ↦ $(morph.id), value: ", morph.map(o.data))
    end

    # Glueing Test: Überprüfe, ob die Bindungen wirklich gleichwertige Pfade definieren
    for m in pattern.morphisms
        source = m.source
        target = m.target
        val = source.data
        left = bindings[source].map(val)
        right = bindings[target].map(m.map(val))

        @assert left == right "Glueing condition failed for morphism $(m.id)"
    end

    println("✅ Glueing condition holds.")
    return colimit_obj, bindings
end

# Pattern 1: 1,2,x+1
pattern1 = make_example_pattern((1, 2), x -> x + 1, :A)
colim1, _ = test_colimit_glueing(pattern1)

# Pattern 2: 4,6,x+2
pattern2 = make_example_pattern((4, 6), x -> x + 2, :B)
colim2, _ = test_colimit_glueing(pattern2)


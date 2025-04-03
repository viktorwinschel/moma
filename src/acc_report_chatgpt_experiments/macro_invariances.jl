using Dates
using Graphs
using GraphPlot

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

#############
# Data Structures (from user)
#############

struct Account
    id::Symbol
    debit::Vector{Float64}
    credit::Vector{Float64}
end

function Account(id::Symbol)
    Account(id, Float64[], Float64[])
end

function balance(acc::Account)
    sum(acc.debit) - sum(acc.credit)
end

function post!(acc::Account, side::Symbol, amount::Float64)
    if side == :debit
        push!(acc.debit, amount)
    elseif side == :credit
        push!(acc.credit, amount)
    else
        error("Unknown side: $side")
    end
end

struct MicroLedger
    id::Symbol
    assets::Vector{Account}
    liabs::Vector{Account}
end

function microledger_balance(ml::MicroLedger)
    asset_sum = sum(balance(a) for a in ml.assets)
    liab_sum = sum(balance(l) for l in ml.liabs)
    return asset_sum - liab_sum
end

function micro_pattern(ml::MicroLedger)
    objs = [Object(a.id, a) for a in ml.assets] ∪ [Object(l.id, l) for l in ml.liabs]
    morphs = Morphism[]
    for a in ml.assets, l in ml.liabs
        push!(morphs, Morphism(Object(a.id, a), Object(l.id, l), x -> balance(x), Symbol("m_$(a.id)_$(l.id)")))
    end
    return Pattern(Category(objs, morphs, Symbol("micro_$(ml.id)")), objs, morphs, Symbol("MicroPattern_$(ml.id)"))
end

struct MacroLedger
    id::Symbol
    moma::Vector{MicroLedger}
end

function macroledger_invariant(mac::MacroLedger)
    balances = [microledger_balance(ml) for ml in mac.moma]
    return isapprox(sum(balances), 0.0)
end

function macro_pattern(mac::MacroLedger)
    subpatterns = [micro_pattern(ml) for ml in mac.moma]
    all_objs = reduce(vcat, [p.objects for p in subpatterns])
    all_morphs = reduce(vcat, [p.morphisms for p in subpatterns])
    cat = Category(all_objs, all_morphs, Symbol("macro_$(mac.id)"))
    return Pattern(cat, all_objs, all_morphs, Symbol("MacroPattern_$(mac.id)"))
end

function visualize_pattern(p::Pattern)
    g = SimpleDiGraph(length(p.objects))
    node_labels = Dict(i => string(p.objects[i].id) for i in 1:length(p.objects))
    index_map = Dict(o.id => i for (i, o) in enumerate(p.objects))
    for m in p.morphisms
        src = index_map[m.source.id]
        tgt = index_map[m.target.id]
        add_edge!(g, src, tgt)
    end
    Plots.plot(g, nodelabel=values(node_labels))
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
    amount::Float64
    debit::Account
    credit::Account
end

function apply_booking!(b::MicroBooking)
    post!(b.debit, :debit, b.amount)
    post!(b.credit, :credit, b.amount)
end


#############
# Pattern Construction and Colimit Check
#############

function create_pattern(a::Account, b::Account, amount::Float64)
    obj1 = Object(:AccountA, a)
    obj2 = Object(:AccountB, b)

    morph = Morphism(obj1, obj2, acc -> begin
            post!(acc, :credit, amount)  # credit b
            acc
        end, :transfer)

    cat = Category([obj1, obj2], [morph], :Transaction)
    return Pattern(cat, [obj1, obj2], [morph], :TransferPattern)
end

function check_binding(pattern::Pattern, booking::MicroBooking)
    apply_booking!(booking)
    bal_debit = balance(booking.debit)
    bal_credit = balance(booking.credit)
    return isapprox(bal_debit, -bal_credit)
end

function check_colimit(booking::MicroBooking)
    net_debit = sum(booking.debit.debit)
    net_credit = sum(booking.credit.credit)
    return isapprox(net_debit, net_credit)
end

#############
# Example usage and test
#############

a = Account(:A)
b = Account(:B)
booking = MicroBooking(:b1, 100.0, a, b)

ml_a = MicroLedger(:ML_A, [a], [])
ml_b = MicroLedger(:ML_B, [], [b])
mac = MacroLedger(:MAC, [ml_a, ml_b])

println("--- Initial balances ---")
println("A: ", balance(a))
println("B: ", balance(b))
println("Macro Invariant (before): ", macroledger_invariant(mac))

pattern = create_pattern(a, b, 100.0)
println("\n--- Check binding ---")
println("Binding OK? ", check_binding(pattern, booking))

println("\n--- After booking ---")
println("A: ", balance(a))
println("B: ", balance(b))
println("Macro Invariant (after): ", macroledger_invariant(mac))

println("\n--- Check colimit ---")
println("Colimit OK? ", check_colimit(booking))

println("\n--- Check micro and macro patterns ---")
mp = micro_pattern(ml_a)
println("MicroPattern ML_A: ", mp.id)
visualize_pattern(mp)
mp2 = micro_pattern(ml_b)
println("MicroPattern ML_B: ", mp2.id)
visualize_pattern(mp2)
mp_total = macro_pattern(mac)
println("MacroPattern: ", mp_total.id)
visualize_pattern(mp_total)

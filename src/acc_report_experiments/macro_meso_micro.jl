using Dates
using Graphs
using GraphPlot

#############
# Micro-Level: Agenten mit doppelter Buchhaltung
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

#############
# Meso-Level: Interaktionen als Morphismen zwischen Agenten
#############

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

struct MesoBookingCategory
    objects::Vector{MicroLedger}
    morphisms::Vector{MicroBooking}
    id::Symbol
end

function pattern_from_meso(meso::MesoBookingCategory)
    objs = [Object(ml.id, ml) for ml in meso.objects]
    morphs = [
        Morphism(Object(b.debit.id, b.debit), Object(b.credit.id, b.credit),
            x -> balance(x), b.id)
        for b in meso.morphisms
    ]
    return Pattern(Category(objs, morphs, Symbol("meso_" * String(meso.id))), objs, morphs, Symbol("Pattern_" * String(meso.id)))
end

#############
# Makro-Level: Colimit und Invarianzprüfung
#############

struct MacroLedger
    id::Symbol
    moma::Vector{MicroLedger}
end

function macroledger_invariant(mac::MacroLedger)
    balances = [microledger_balance(ml) for ml in mac.moma]
    return isapprox(sum(balances), 0.0)
end

function macro_colimit_ok(meso::MesoBookingCategory)
    ledgers = meso.objects
    total = sum(microledger_balance(ml) for ml in ledgers)
    return isapprox(total, 0.0)
end

#############
# Kategorientheoretische Grundstrukturen
#############

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

struct Functor
    source::Category
    target::Category
    object_map::Dict{Symbol,Symbol}
    morphism_map::Dict{Symbol,Symbol}
    id::Symbol
end

struct NaturalTransformation
    source::Functor
    target::Functor
    components::Dict{Symbol,Morphism}
    id::Symbol
end

function macro_consistency_transformation(source_f::Functor, target_f::Functor, meso::MesoBookingCategory)
    comps = Dict{Symbol,Morphism}()
    for ml in meso.objects
        obj = Object(ml.id, ml)
        morph = Morphism(obj, obj, x -> microledger_balance(x), Symbol("μ_" * String(ml.id)))
        comps[ml.id] = morph
    end
    return NaturalTransformation(source_f, target_f, comps, :MacroInvariance)
end

#############
# Beispiel und Test
#############

function example_meso()
    a = Account(:A)
    b = Account(:B)
    booking = MicroBooking(:b1, 100.0, a, b)

    ml_a = MicroLedger(:ML_A, [a], [])
    ml_b = MicroLedger(:ML_B, [], [b])
    meso = MesoBookingCategory([ml_a, ml_b], [booking], :TestMeso)

    println("--- Mikro Bilanzen vor Buchung ---")
    println("A: ", balance(a))
    println("B: ", balance(b))

    apply_booking!(booking)

    println("--- Mikro Bilanzen nach Buchung ---")
    println("A: ", balance(a))
    println("B: ", balance(b))

    println("--- Makroinvarianz ---")
    println("Makro Colimit OK? ", macro_colimit_ok(meso))

    println("--- Meso Pattern ---")
    pat = pattern_from_meso(meso)
    println("Pattern ID: ", pat.id)

    println("--- Natürliche Transformation für Makroinvarianz ---")
    f_id = Functor(Category([], [], :empty), Category([], [], :empty), Dict(), Dict(), :F_id)
    nat = macro_consistency_transformation(f_id, f_id, meso)
    for (k, v) in nat.components
        println("", k, " → ", v.id)
    end
end

example_meso()

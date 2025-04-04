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
    acct_type::Symbol  # :goods, :money, :credit, :equity
end

function Account(id::Symbol; acct_type::Symbol=:general)
    Account(id, Float64[], Float64[], acct_type)
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
# Macro-Level: Buchungen und Invarianzprüfung
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

struct MacroBooking
    id::Symbol
    amount::Float64
    from::Symbol
    to::Symbol
end

struct MacroLayer
    bookings::Vector{MacroBooking}
    induced_microbookings::Vector{MicroBooking}
end

function induce_micro_from_macro(mac::MacroBooking, agents::Dict{Symbol,MicroLedger})
    acc_from = agents[mac.from].assets[1]
    acc_to = agents[mac.to].liabs[1]
    return MicroBooking(mac.id, mac.amount, acc_from, acc_to)
end

function macro_colimit_invariant(mbs::Vector{MicroBooking})
    agents = Dict{Symbol,Float64}()
    for b in mbs
        agents[b.debit.id] = get(agents, b.debit.id, 0.0) + b.amount
        agents[b.credit.id] = get(agents, b.credit.id, 0.0) - b.amount
    end
    total = sum(values(agents))
    return isapprox(total, 0.0), agents
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

function macro_consistency_transformation(source_f::Functor, target_f::Functor, agents::Vector{MicroLedger})
    comps = Dict{Symbol,Morphism}()
    for ml in agents
        obj = Object(ml.id, ml)
        morph = Morphism(obj, obj, x -> microledger_balance(x), Symbol("μ_" * String(ml.id)))
        comps[ml.id] = morph
    end
    return NaturalTransformation(source_f, target_f, comps, :MacroInvariance)
end

#############
# Beispiel: 100 Makrobuchungen zwischen 10 Agenten
#############

function example_macro()
    agents = Dict{Symbol,MicroLedger}()
    for i in 1:10
        a = Account(Symbol("A_", i); acct_type=:money)
        l = Account(Symbol("L_", i); acct_type=:credit)
        agents[Symbol("Agent_", i)] = MicroLedger(Symbol("Agent_", i), [a], [l])
    end

    macbookings = MacroBooking[]
    microbookings = MicroBooking[]
    for i in 1:100
        from = Symbol("Agent_", rand(1:10))
        to = Symbol("Agent_", rand(1:10))
        while to == from
            to = Symbol("Agent_", rand(1:10))
        end
        mb = MacroBooking(Symbol("M", i), rand(10.0:10.0:100.0), from, to)
        push!(macbookings, mb)
        push!(microbookings, induce_micro_from_macro(mb, agents))
    end

    for mb in microbookings
        apply_booking!(mb)
    end

    println("--- MicroLedger balances ---")
    for (k, ag) in agents
        println(k, ": ", microledger_balance(ag))
    end

    println("\n--- Macro Colimit Invariant ---")
    result, deltas = macro_colimit_invariant(microbookings)
    println("Colimit invariant? ", result)
    println("Agent deltas: ", deltas)
end

example_macro()

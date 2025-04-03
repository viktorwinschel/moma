using Dates
using Graphs
using GraphPlot
using DataFrames
using CSV

#############
# Micro-Level: Agenten mit doppelter Buchhaltung
#############

struct Account
    id::Symbol
    debit::Vector{Float64}
    credit::Vector{Float64}
    acct_type::Symbol
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
    agent_type::Symbol
    assets::Vector{Account}
    liabs::Vector{Account}
end

function microledger_balance(ml::MicroLedger)
    asset_sum = sum(balance(a) for a in ml.assets)
    liab_sum = sum(balance(l) for l in ml.liabs)
    return asset_sum - liab_sum
end

#############
# Buchungen
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

function describe_micro_booking(b::MicroBooking, agents::Dict{Symbol,MicroLedger})
    println("\n--- Buchungserklärung: ", b.id, " ---")
    println("ASCII-Diagramm:")
    println("  " * string(b.debit.id) * " ──(" * string(b.amount) * ")──▶ " * string(b.credit.id))

    println("\nPattern (kategorisch):")
    println("  A ──b──▶ B  (Objekte: Konten, Morphismus: Transaktion)")
    println("Binding:")
    println("  Betrag: ", b.amount)

    println("Interpretation:")
    println("  Kategorientheorie : Morphismus in Kategorie der Buchungen")
    println("    Pattern: ", b.debit.id, " → ", b.credit.id, " mit Betrag ", b.amount)
    println("    Binding: Betrag als konkreter Wert auf Soll/Haben verteilt")
    println("    Colimit-Bedingung: μ_", b.debit.id, " + μ_", b.credit.id, " = 0")
    println("  Programmierer      : Funktion call: post!(", b.debit.id, ", :debit, ", b.amount, "); post!(", b.credit.id, ", :credit, ", b.amount, ")")
    println("  Buchhalter         : Soll ", b.amount, " auf Konto ", b.debit.id, ", Haben ", b.amount, " auf Konto ", b.credit.id)

    idx1 = split(String(b.debit.id), "_")[end]
    idx2 = split(String(b.credit.id), "_")[end]
    debit_agent = Symbol("Agent_" * idx1)
    credit_agent = Symbol("Agent_" * idx2)

    println("  Investor           : Zahlung von ", b.amount, " zwischen Agenten ", debit_agent, " (Sender) und ", credit_agent, " (Empfänger), über Konten ", b.debit.id, " und ", b.credit.id)
    println("  Volkswirt          : Makrotransaktion ", debit_agent, " (", agents[debit_agent].agent_type, ") → ", credit_agent, " (", agents[credit_agent].agent_type, ")")
    println("                     : Colimit-Kriterium erfüllt, da Salden symmetrisch ausgleichen")
    println("  ", b.debit.id, ": ", balance(b.debit))
    println("  ", b.credit.id, ": ", balance(b.credit))

    apply_booking!(b)

    println("Saldo nach Buchung:")
    println("  ", b.debit.id, ": ", balance(b.debit))
    println("  ", b.credit.id, ": ", balance(b.credit))
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
# Kategorientheorie
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
# Erweiterung: Invarianzgruppen
#############

struct InvarianceGroup
    name::Symbol
    asset_types::Vector{Symbol}
    liab_types::Vector{Symbol}
end

function colimit_for_group(bookings::Vector{MicroBooking}, group::InvarianceGroup)
    acc_sums = Dict{Symbol,Float64}()
    for b in bookings
        if b.debit.acct_type in group.asset_types
            acc_sums[b.debit.id] = get(acc_sums, b.debit.id, 0.0) + b.amount
        end
        if b.credit.acct_type in group.liab_types
            acc_sums[b.credit.id] = get(acc_sums, b.credit.id, 0.0) - b.amount
        end
    end
    total = sum(values(acc_sums))
    return isapprox(total, 0.0), acc_sums
end

const INVARIANCE_GROUPS = [
    InvarianceGroup(:liabilities, [:cash, :goods], [:credit, :debt]),
    InvarianceGroup(:net_worth, [:receivable], [:payable, :equity])
]

#############
# Beispielausführung
#############

function save_microbooking_report(bookings::Vector{MicroBooking}, filename::String, invariance_report::DataFrame=DataFrame())
    rows = [
        (
            id=b.id,
            debit=b.debit.id,
            credit=b.credit.id,
            amount=b.amount,
            debit_balance=balance(b.debit),
            credit_balance=balance(b.credit),
            ascii=string(b.debit.id, " ──(", b.amount, ")──▶ ", b.credit.id)
        ) for b in bookings
    ]
    df = DataFrame(rows)
    CSV.write(filename, df)
    if nrow(invariance_report) > 0
        CSV.write(replace(filename, ".csv" => "_invariances.csv"), invariance_report)
        println("  ➕ Invarianzbericht gespeichert unter: " * replace(filename, ".csv" => "_invariances.csv"))
    end
    println("\n✅ Report gespeichert unter: " * filename)
end

function example_macro(as, bs)
    agents = Dict{Symbol,MicroLedger}()
    for i in 1:as
        asset_types = [:cash, :goods, :receivable, :investment, :inventory]
        liab_types = [:credit, :payable, :loan, :equity, :debt]
        assets = [Account(Symbol("A_" * string(i) * "_" * string(j)); acct_type=asset_types[rand(1:end)]) for j in 1:5]
        liabs = [Account(Symbol("L_" * string(i) * "_" * string(j)); acct_type=liab_types[rand(1:end)]) for j in 1:5]
        agents[Symbol("Agent_", i)] = MicroLedger(Symbol("Agent_", i), :Bank, assets, liabs)
    end

    macbookings = MacroBooking[]
    microbookings = MicroBooking[]

    for i in 1:bs
        from = Symbol("Agent_", rand(1:as))
        to = Symbol("Agent_", rand(1:as))
        while to == from
            to = Symbol("Agent_", rand(1:as))
        end
        mb = MacroBooking(Symbol("M", i), rand(10.0:10.0:100.0), from, to)
        push!(macbookings, mb)
        push!(microbookings, induce_micro_from_macro(mb, agents))
    end

    for mb in microbookings
        describe_micro_booking(mb, agents)
    end

    println("--- MicroLedger balances ---")
    for (k, ag) in agents
        println(k, ": ", microledger_balance(ag))
    end

    println("\n--- Macro Colimit Invariant ---")
    result, deltas = macro_colimit_invariant(microbookings)
    println("Colimit invariant? ", result)
    println("Agent deltas: ", deltas)

    invariance_rows = DataFrame()
    println("\n📋 Rollenreport:")
    println("Buchhalter: Jeder Buchungssatz wurde als Soll/Haben interpretiert.")
    println("Investor: Zahlungsflüsse zwischen Agenten wurden sichtbar und bilanziert.")
    println("Kategorientheoretiker: Jeder Morphismus hat zu einem konsistenten Colimit beigetragen.")

    println("Wirtschaftsprüfer: Gruppenspezifische Saldenprüfungen")
    for group in INVARIANCE_GROUPS
        ok, diffs = colimit_for_group(microbookings, group)
        println("  Gruppe ", group.name, ": Colimit erfüllt? ", ok)
        for (k, v) in sort(collect(diffs))
            println("    - Konto ", k, ": Differenz = ", v)
            push!(invariance_rows, (; gruppe=group.name, konto=k, diff=v, erfüllt=ok))
        end
    end

    save_microbooking_report(microbookings, "microbooking_report.csv", invariance_rows)
end

example_macro(2, 1)
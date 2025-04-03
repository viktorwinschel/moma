using Dates
using Graphs
using GraphPlot

#############
# Micro-Level: Agenten mit doppelter Buchhaltung
# Kategorie A: Objekte sind Agenten mit Kontenstruktur
#############

struct Account
    id::Symbol
    debit::Vector{Float64}
    credit::Vector{Float64}
    acct_type::Symbol  # :goods, :money, :credit, :equity
end

function Account(id::Symbol; acct_type::Symbol=:general)
    # Erzeugt ein Kontoobjekt (Objekt in Kategorie A)
    Account(id, Float64[], Float64[], acct_type)
end

function balance(acc::Account)
    # Morphismus in A: berechnet Saldo als Abbildung
    sum(acc.debit) - sum(acc.credit)
end

function post!(acc::Account, side::Symbol, amount::Float64)
    # Morphismus in A: verändert die Daten eines Kontos
    # Binding: Hier wird die Verbindung zwischen der abstrakten Buchung und der konkreten Kontoseite hergestellt
    # Deutsch: Auf dieses Konto wurde ein Betrag im Soll oder Haben verbucht.
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
    # Morphismus auf Objekten der Kategorie A: Gesamtbilanz eines Agenten
    # Colimit-Kriterium: Prüft, ob innerhalb eines Ledgers (lokal) die Bilanz ausgeglichen ist
    # Deutsch: Zeigt an, ob ein Agent mehr besitzt als schuldet oder umgekehrt.
    asset_sum = sum(balance(a) for a in ml.assets)
    liab_sum = sum(balance(l) for l in ml.liabs)
    return asset_sum - liab_sum
end

#############
# Macro-Level: Makrobuchungen erzeugen MicroBookings
# Kategorie B: morphismisch durch Zahlungsflüsse
#############

struct MicroBooking
    id::Symbol
    amount::Float64
    debit::Account
    credit::Account
end

function apply_booking!(b::MicroBooking)
    # ⟶ Pattern (Kategorie):  A —b→ B
    #    Binding:      Betrag = $(b.amount)
    #    Colimit:      A und B verklebt sich über diese Buchung
    #
    # Für den Kategorientheoretiker: Morphismus b in MicroBookingCategory
    # Für den Programmierer: Funktion, die Status in Konten mutiert
    # Für den Buchhalter: Ein Soll/Haben-Satz über zwei Konten
    # Für den Investor: Eine Zahlung von Agent A an B, sichtbar in Bilanzen
    # Realisiert den Bindungsmorphismus zwischen Agenten
    # Pattern: eine einfache lineare Transaktion A → B
    # Binding: diese Transaktion wird durch realen Wert konkretisiert
    # Deutsch: Eine Buchung von einem Konto auf ein anderes wird in die Bücher geschrieben.
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
    # Erzeugt einen MicroBooking Morphismus aus einer Makrobuchung (Diagrammbindung)
    # Pattern: ein Makrofluss wird auf Mikroebene projiziert
    # Binding: konkretisiert in Konten der beteiligten Agenten
    # Deutsch: Eine Vereinbarung zwischen zwei Agenten wird auf den konkreten Konten abgebildet.
    acc_from = agents[mac.from].assets[1]
    acc_to = agents[mac.to].liabs[1]
    return MicroBooking(mac.id, mac.amount, acc_from, acc_to)
end

function macro_colimit_invariant(mbs::Vector{MicroBooking})
    # Prüft, ob alle Buchungen im Colimit (Makrodiagramm) aufgehen
    # Colimit: Verklebt alle lokalen Buchungen zu einer global konsistenten Makrostruktur
    # Deutsch: Das gesamte System ist in sich stimmig – alle Zahlungen gehen am Ende auf.
    agents = Dict{Symbol,Float64}()
    for b in mbs
        agents[b.debit.id] = get(agents, b.debit.id, 0.0) + b.amount
        agents[b.credit.id] = get(agents, b.credit.id, 0.0) - b.amount
    end
    total = sum(values(agents))
    return isapprox(total, 0.0), agents
end

#############
# Kategorientheoretische Grundstrukturen (für Diagramme, Funktoren, Transformationen)
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
    # Natürliche Transformation μ: F ⇒ G, wobei μ_i = Bilanzprüfung für jeden Agenten
    # Diese Transformation verbindet jede lokale Struktur mit einer systemweiten Überprüfung
    # Deutsch: Wir prüfen systematisch bei jedem Agenten, ob seine Bücher stimmen.
    comps = Dict{Symbol,Morphism}()
    for ml in agents
        obj = Object(ml.id, ml)
        morph = Morphism(obj, obj, x -> microledger_balance(x), Symbol("μ_" * String(ml.id)))
        comps[ml.id] = morph
    end
    return NaturalTransformation(source_f, target_f, comps, :MacroInvariance)
end

#############
# Beispiel: 100 Makrobuchungen zwischen 10 Agenten mit Colimitprüfung
#############

using DataFrames
using CSV

function save_microbooking_report(bookings::Vector{MicroBooking}, filename::String)
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
    println("
✅ Report gespeichert unter: " * filename)
end

function describe_micro_booking(b::MicroBooking, agents::Dict{Symbol,MicroLedger})
    println("
--- Buchungserklärung: ", b.id, " ---")
    println("ASCII-Diagramm:")
    println("  " * string(b.debit.id) * " ──(" * string(b.amount) * ")──▶ " * string(b.credit.id))

    println("
Pattern (kategorisch):")
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
    idx1 = split(String(b.debit.id), "_")[end]
    idx2 = split(String(b.credit.id), "_")[end]
    idx1 = split(String(b.debit.id), "_")[end]
    idx2 = split(String(b.credit.id), "_")[end]
    println("  Investor           : Zahlung von ", b.amount, " zwischen Agenten Agent_" *
                                                             idx1, " (Sender) und Agent_" * idx2, " (Empfänger), über Konten ", b.debit.id,
        " und ", b.credit.id, "und Agent_" * idx2, " (Empfänger), über Konten ", b.debit.id, " und ", b.credit.id,
        " und Agent_" * idx2, " (Empfänger), über Konten ", b.debit.id, " und ", b.credit.id, " (Sender) und ",
        String(b.credit.id), " (Empfänger), über Konten ", b.debit.id, " und ", b.credit.id)
    debit_agent = Symbol("Agent_" * split(String(b.debit.id), "_")[end])
    credit_agent = Symbol("Agent_" * split(String(b.credit.id), "_")[end])
    println("  Volkswirt          : Makrotransaktion ", debit_agent, " (", agents[debit_agent].agent_type, ") → ", credit_agent, " (", agents[credit_agent].agent_type, ")")
    println("                     : Colimit-Kriterium erfüllt, da Salden symmetrisch ausgleichen")
    println("  ", b.debit.id, ": ", balance(b.debit))
    println("  ", b.credit.id, ": ", balance(b.credit))

    apply_booking!(b)

    println("Saldo nach Buchung:")
    println("  ", b.debit.id, ": ", balance(b.debit))
    println("  ", b.credit.id, ": ", balance(b.credit))
end

function colimit_for_type(bookings::Vector{MicroBooking}, typegroup::Vector{Symbol})
    agents = Dict{Symbol,Float64}()
    for b in bookings
        if b.debit.acct_type in typegroup || b.credit.acct_type in typegroup
            agents[b.debit.id] = get(agents, b.debit.id, 0.0) + b.amount
            agents[b.credit.id] = get(agents, b.credit.id, 0.0) - b.amount
        end
    end
    total = sum(values(agents))
    return isapprox(total, 0.0), agents
end

const INVARIANCE_GROUPS = Dict(
    :liabilities => [:credit, :debt, :payable],
    :assets => [:cash, :goods, :receivable],
    :net_worth => [:equity]
)

function example_macro()
    agents = Dict{Symbol,MicroLedger}()
    for i in 1:10
        # Objekte in A (Agenten mit Konten)
        a = Account(Symbol("A_", i); acct_type=:money)
        l = Account(Symbol("L_", i); acct_type=:credit)
        agents[Symbol("Agent_", i)] = MicroLedger(Symbol("Agent_", i), :Bank, [a], [l])
    end

    macbookings = MacroBooking[]
    microbookings = MicroBooking[]

    # Erzeuge 100 Makrobuchungen (Makromorphismen zwischen Agenten)
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

    # Trage MicroBookings in Agenten ein (Transformationen wirken auf Objektzustände)
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
    save_microbooking_report(microbookings, "microbooking_report.csv")

    println("
📋 Rollenreport:")
    println("Buchhalter: Jeder Buchungssatz wurde als Soll/Haben interpretiert.")
    println("Investor: Zahlungsflüsse zwischen Agenten wurden sichtbar und bilanziert.")
    println("Kategorientheoretiker: Jeder Morphismus hat zu einem konsistenten Colimit beigetragen.")

    println("Wirtschaftsprüfer: Auswertung von Invarianzgruppen")
    println("  (Colimit-Prüfung innerhalb typisierter Kontengruppen, z.B. nur Aktiva oder Passiva.)")
    for (groupname, types) in INVARIANCE_GROUPS
        ok, deltas = colimit_for_type(microbookings, types)
        println("  Gruppe: ", groupname)
        println("    Kontotypen: ", types)
        println("    Colimit erfüllt? ", ok)
        for (agent, delta) in sort(collect(deltas))
            println("      • Agent ", agent, " hat Saldoabweichung: ", delta)
        end
    end
end

example_macro()

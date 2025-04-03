# --- Category Core ---

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

# --- Double Entry Accounting Structures ---

struct MicroBooking
    debit_account::Int
    credit_account::Int
    amount::Float64
end

struct MacroBooking
    booking1::MicroBooking
    booking2::MicroBooking
    id::Symbol
end

struct MicroLedger
    data::Matrix{Float64}  # rows = bookings, cols = accounts
    account_names::Vector{Symbol}
end

# Colimit structure for T-Accounts per booking: we treat each ledger row as a morphism to the colimit total
function compute_colimit_per_account(ledger::MicroLedger)
    n_accounts = size(ledger.data, 2)
    colimit_accounts = zeros(Float64, n_accounts)
    for j in 1:n_accounts
        acc_values = ledger.data[:, j]
        colimit_accounts[j] = sum(acc_values)
    end
    return colimit_accounts
end

# Evaluate micro booking to ledger row
function apply_micro_booking!(ledger::Matrix{Float64}, row::Int, booking::MicroBooking)
    amt = booking.amount
    ledger[row, booking.debit_account] += amt
    ledger[row, booking.credit_account] -= amt
end

function evaluate_macro_bookings(bookings::Vector{MacroBooking}, num_accounts::Int)
    num_rows = length(bookings)
    ledger1 = zeros(Float64, num_rows, num_accounts)
    ledger2 = zeros(Float64, num_rows, num_accounts)
    macro_matrix = zeros(Float64, num_rows, 1)

    for (i, b) in enumerate(bookings)
        macro_matrix[i, 1] = b.booking1.amount
        apply_micro_booking!(ledger1, i, b.booking1)
        apply_micro_booking!(ledger2, i, b.booking2)
    end

    return macro_matrix,
    MicroLedger(ledger1, [Symbol("acc_$(i)") for i in 1:num_accounts]),
    MicroLedger(ledger2, [Symbol("acc_$(i)") for i in 1:num_accounts])
end

function check_micro_colimit(ledger::MicroLedger, asset_cols::Vector{Int}, liab_cols::Vector{Int})
    A = sum(ledger.data[:, asset_cols], dims=2)
    L = sum(ledger.data[:, liab_cols], dims=2)
    residual = A .- L
    return all(abs.(residual) .< 1e-8), residual
end

function pattern_from_macro(booking::MacroBooking, id::Symbol)
    a1 = Object(:agent1, booking.booking1)
    a2 = Object(:agent2, booking.booking2)
    merged = Object(:macro, booking.booking1.amount)

    f = Morphism(a1, merged, x -> x.amount, :f1)
    g = Morphism(a2, merged, x -> x.amount, :f2)

    cat = Category([a1, a2, merged], [f, g], Symbol("cat_$(id)"))
    pat = Pattern(cat, [a1, a2, merged], [f, g], Symbol("pattern_$(id)"))
    return pat
end

function check_macro_colimit(bookings::Vector{MacroBooking})
    for (i, b) in enumerate(bookings)
        pat = pattern_from_macro(b, Symbol("B_$(i)"))
        a1_val = b.booking1.amount
        a2_val = b.booking2.amount
        @assert a1_val == a2_val "Macro booking $(b.id) violates glueing colimit condition."
    end
    println("✅ All macro bookings satisfy glueing conditions (colimit match).")
end

# --- Example Run ---

bookings = [
    MacroBooking(MicroBooking(1, 2, 100.0), MicroBooking(4, 3, 100.0), :b1),
    MacroBooking(MicroBooking(1, 3, 200.0), MicroBooking(4, 2, 200.0), :b2),
    MacroBooking(MicroBooking(2, 1, 150.0), MicroBooking(3, 4, 150.0), :b3)
]

macro_matrix, ledger1, ledger2 = evaluate_macro_bookings(bookings, 4)

println("\nMacro Matrix:")
println(macro_matrix)

println("\nLedger 1:")
println(ledger1.data)

println("\nLedger 2:")
println(ledger2.data)

println("\nCheck Micro Colimits:")
valid1, _ = check_micro_colimit(ledger1, [1], [2, 3, 4])
valid2, _ = check_micro_colimit(ledger2, [3, 4], [1, 2])
println("Agent 1: ", valid1)
println("Agent 2: ", valid2)

println("\nCheck Macro Colimit Glueings:")
check_macro_colimit(bookings)

println("\nT-Account Colimits:")
colim1 = compute_colimit_per_account(ledger1)
colim2 = compute_colimit_per_account(ledger2)
println("Colimit Ledger 1: ", colim1)
println("Colimit Ledger 2: ", colim2)

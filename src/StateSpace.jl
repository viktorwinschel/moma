module StateSpace

using Moma.Categories: Object, Morphism
using LinearAlgebra
using Plots

export TimeSeriesMemory, extend!, get_data, get_times, get_links
export collect_timeseries, plot_timeseries
export create_ar_model, create_var_model, create_nonlinear_var_model, create_stochastic_nonlinear_var_model
export simulate_dynamics

# Add precompile directive
Base.precompile(Memory{Vector{Float64}}, (Object{Float64}, Object{Vector{Float64}}))

"""
    TimeSeriesMemory{T}

A type for storing time series data in a Memory Evolutive Systems (MES) style.

# Fields
- `times::Vector{Object{Float64}}`: Time objects representing the temporal dimension
- `states::Vector{Object{T}}`: State objects representing the system's evolution
- `links::Vector{Morphism}`: Links between consecutive states (morphisms)

# Constructors
```julia
TimeSeriesMemory{T}(initial_time::Object{Float64}, initial_state::Object{T}) where {T}
TimeSeriesMemory(initial_time::Object{Float64}, initial_state::Object{T}) where {T}
```
"""
struct TimeSeriesMemory{T}
    times::Vector{Object{Float64}}
    states::Vector{Object{T}}
    links::Vector{Morphism}

    function TimeSeriesMemory{T}(initial_time::Object{Float64}, initial_state::Object{T}) where {T}
        new{T}([initial_time], [initial_state], Morphism[])
    end
end

TimeSeriesMemory(initial_time::Object{Float64}, initial_state::Object{T}) where {T} = TimeSeriesMemory{T}(initial_time, initial_state)

"""
    extend!(memory::TimeSeriesMemory{T}, new_time::Object{Float64}, new_state::Object{T}, link::Morphism)

Extend the memory with a new time point, state, and link between states.

# Arguments
- `memory::TimeSeriesMemory{T}`: The memory to extend
- `new_time::Object{Float64}`: New time point
- `new_state::Object{T}`: New state
- `link::Morphism`: Link between the previous and new state
"""
function extend!(memory::TimeSeriesMemory{T}, new_time::Object{Float64}, new_state::Object{T}, link::Morphism) where {T}
    push!(memory.times, new_time)
    push!(memory.states, new_state)
    push!(memory.links, link)
end

"""
    get_data(memory::TimeSeriesMemory{T})

Extract the state data from memory as a vector of values.

# Arguments
- `memory::TimeSeriesMemory{T}`: The memory to extract data from

# Returns
- Vector of state values
"""
function get_data(memory::TimeSeriesMemory{T}) where {T}
    return [state.data for state in memory.states]
end

"""
    get_times(memory::TimeSeriesMemory{T})

Extract the time points from memory as a vector of values.

# Arguments
- `memory::TimeSeriesMemory{T}`: The memory to extract times from

# Returns
- Vector of time values
"""
function get_times(memory::TimeSeriesMemory{T}) where {T}
    return [t.data for t in memory.times]
end

"""
    get_links(memory::TimeSeriesMemory{T})

Get the links (morphisms) between consecutive states.

# Arguments
- `memory::TimeSeriesMemory{T}`: The memory to extract links from

# Returns
- Vector of morphisms
"""
function get_links(memory::TimeSeriesMemory{T}) where {T}
    return memory.links
end

"""
    collect_timeseries(memory::TimeSeriesMemory{T})

Collect the time series data from memory.

# Arguments
- `memory::TimeSeriesMemory{T}`: The memory to collect data from

# Returns
- Tuple of (times, states) where times is a vector of Float64 and states is a vector of T
"""
function collect_timeseries(memory::TimeSeriesMemory{T}) where {T}
    return (get_times(memory), get_data(memory))
end

"""
    plot_timeseries(memory::TimeSeriesMemory{T}, title::String="Time Series")

Create a plot of the time series data.

# Arguments
- `memory::TimeSeriesMemory{T}`: The memory to plot
- `title::String`: Title for the plot

# Returns
- Plots.Plot object
"""
function plot_timeseries(memory::TimeSeriesMemory{T}, title::String="Time Series") where {T}
    times, data = collect_timeseries(memory)

    # Handle both scalar and vector states
    if data[1] isa Vector
        n_vars = length(data[1])
        p = plot(title=title, xlabel="Time", ylabel="Value")
        for i in 1:n_vars
            plot!(p, times, [d[i] for d in data], label="Variable $i")
        end
    else
        p = plot(times, data, title=title, xlabel="Time", ylabel="Value")
    end

    return p
end

"""
    create_ar_model(initial_state::Vector{Float64})

Create an AR(1) model.

# Arguments
- `initial_state::Vector{Float64}`: Initial state vector

# Returns
- Tuple of (initial_time, initial_state, time_step, evolution)
"""
function create_ar_model(initial_state::Vector{Float64})
    t₁ = Object(:t1, 1.0)
    s₁ = Object(:s1, initial_state)

    time_step = Morphism(t₁, Object(:t2, 2.0), t -> t + 1.0, :time_step)
    evolution = Morphism(s₁, Object(:s2, [0.0]), x -> [0.7 * x[1]], :evolution)

    return t₁, s₁, time_step, evolution
end

"""
    create_var_model(initial_state::Vector{Float64}, A::Matrix{Float64})

Create a VAR(1) model.

# Arguments
- `initial_state::Vector{Float64}`: Initial state vector
- `A::Matrix{Float64}`: Transition matrix

# Returns
- Tuple of (initial_time, initial_state, time_step, evolution)
"""
function create_var_model(initial_state::Vector{Float64}, A::Matrix{Float64})
    t₁ = Object(:t1, 1.0)
    s₁ = Object(:s1, initial_state)

    time_step = Morphism(t₁, Object(:t2, 2.0), t -> t + 1.0, :time_step)
    evolution = Morphism(s₁, Object(:s2, similar(initial_state)), x -> A * x, :evolution)

    return t₁, s₁, time_step, evolution
end

"""
    create_nonlinear_var_model(initial_state::Vector{Float64}, A::Matrix{Float64})

Create a nonlinear VAR model.

# Arguments
- `initial_state::Vector{Float64}`: Initial state vector
- `A::Matrix{Float64}`: Transition matrix

# Returns
- Tuple of (initial_time, initial_state, time_step, evolution)
"""
function create_nonlinear_var_model(initial_state::Vector{Float64}, A::Matrix{Float64})
    t₁ = Object(:t1, 1.0)
    s₁ = Object(:s1, initial_state)

    time_step = Morphism(t₁, Object(:t2, 2.0), t -> t + 1.0, :time_step)
    evolution = Morphism(s₁, Object(:s2, similar(initial_state)), x -> A * x + 0.1 * sin.(x), :evolution)

    return t₁, s₁, time_step, evolution
end

"""
    create_stochastic_nonlinear_var_model(initial_state::Vector{Float64}, A::Matrix{Float64})

Create a stochastic nonlinear VAR model.

# Arguments
- `initial_state::Vector{Float64}`: Initial state vector
- `A::Matrix{Float64}`: Transition matrix

# Returns
- Tuple of (initial_time, initial_state, time_step, evolution)
"""
function create_stochastic_nonlinear_var_model(initial_state::Vector{Float64}, A::Matrix{Float64})
    t₁ = Object(:t1, 1.0)
    s₁ = Object(:s1, initial_state)

    time_step = Morphism(t₁, Object(:t2, 2.0), t -> t + 1.0, :time_step)
    evolution = Morphism(s₁, Object(:s2, similar(initial_state)), x -> A * x + 0.1 * sin.(x) + 0.1 * randn(length(x)), :evolution)

    return t₁, s₁, time_step, evolution
end

"""
    simulate_dynamics(t₁::Object{Float64}, s₁::Object{T}, time_step::Morphism, evolution::Morphism, n_steps::Int)

Simulate the dynamics of a system.

# Arguments
- `t₁::Object{Float64}`: Initial time
- `s₁::Object{T}`: Initial state
- `time_step::Morphism`: Time step morphism
- `evolution::Morphism`: Evolution morphism
- `n_steps::Int`: Number of steps to simulate

# Returns
- TimeSeriesMemory{T} containing the simulation results
"""
function simulate_dynamics(t₁::Object{Float64}, s₁::Object{T}, time_step::Morphism, evolution::Morphism, n_steps::Int) where {T}
    memory = TimeSeriesMemory{T}(t₁, s₁)

    current_time = t₁
    current_state = s₁

    for _ in 1:(n_steps-1)
        new_time = Object(:t, time_step.map(current_time.data))
        new_state = Object(:s, evolution.map(current_state.data))
        link = Morphism(current_state, new_state, x -> evolution.map(x), :link)

        extend!(memory, new_time, new_state, link)

        current_time = new_time
        current_state = new_state
    end

    return memory
end

end # module 
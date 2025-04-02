"""
    module StateSpace

This module provides implementations of state space models using Memory Evolutive Systems (MES) concepts.
It includes:

- Time series memory management
- State space model implementations (AR, VAR, nonlinear VAR)
- Simulation and visualization tools
- Data collection and analysis utilities

# Mathematical Background
The module implements state space models using categorical tools:
- Time series as sequences of objects and morphisms
- State transitions as morphisms between objects
- Memory as a structured collection of states and transitions
- Visualization of system dynamics

# Exports
- `TimeSeriesMemory`: Type for storing time series data
- `extend!`: Extend memory with new time point and state
- `get_data`, `get_times`, `get_links`: Access memory components
- `collect_timeseries`, `plot_timeseries`: Data collection and visualization
- `create_ar_model`, `create_var_model`: Model creation functions
- `simulate_dynamics`: System simulation
"""
module StateSpace

using ..Categories: Object, Morphism
using LinearAlgebra
using Plots

export TimeSeriesMemory, extend!, get_data, get_times, get_links
export collect_timeseries, plot_timeseries
export create_ar_model, create_var_model, create_nonlinear_var_model, create_stochastic_nonlinear_var_model
export simulate_dynamics

"""
    TimeSeriesMemory{T}

A type for storing time series data in a Memory Evolutive Systems (MES) style.

# Type Parameters
- `T`: The type of data stored in each state (e.g., Float64, Vector{Float64})

# Fields
- `times::Vector{Object{Float64}}`: Time objects representing the temporal dimension
- `states::Vector{Object{T}}`: State objects representing the system's evolution
- `links::Vector{Morphism{T,T}}`: Links between consecutive states (morphisms)

# Constructors
```julia
# Create memory with scalar states
t₁ = Object(:t1, 1.0)
s₁ = Object(:s1, 1.0)
memory = TimeSeriesMemory(t₁, s₁)

# Create memory with vector states
t₁ = Object(:t1, 1.0)
s₁ = Object(:s1, [1.0, 2.0])
memory = TimeSeriesMemory(t₁, s₁)
```
"""
struct TimeSeriesMemory{T}
    times::Vector{Object{Float64}}
    states::Vector{Object{T}}
    links::Vector{Morphism{T,T}}

    function TimeSeriesMemory{T}(initial_time::Object{Float64}, initial_state::Object{T}) where {T}
        new{T}([initial_time], [initial_state], Morphism{T,T}[])
    end
end

TimeSeriesMemory(initial_time::Object{Float64}, initial_state::Object{T}) where {T} = TimeSeriesMemory{T}(initial_time, initial_state)

"""
    extend!(memory::TimeSeriesMemory{T}, new_time::Object{Float64}, new_state::Object{T}, link::Morphism{T,T})

Extend the memory with a new time point, state, and link between states.

# Arguments
- `memory::TimeSeriesMemory{T}`: The memory to extend
- `new_time::Object{Float64}`: New time point
- `new_state::Object{T}`: New state
- `link::Morphism{T,T}`: Link between the previous and new state

# Examples
```julia
# Create initial memory
t₁ = Object(:t1, 1.0)
s₁ = Object(:s1, 1.0)
memory = TimeSeriesMemory(t₁, s₁)

# Extend with new state
t₂ = Object(:t2, 2.0)
s₂ = Object(:s2, 2.0)
link = Morphism(s₁, s₂, x -> x + 1, :link)
extend!(memory, t₂, s₂, link)
```
"""
function extend!(memory::TimeSeriesMemory{T}, new_time::Object{Float64}, new_state::Object{T}, link::Morphism{T,T}) where {T}
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
- `Vector{T}`: Vector of state values

# Examples
```julia
# Get data from scalar state memory
data = get_data(memory)  # Returns Vector{Float64}

# Get data from vector state memory
data = get_data(memory)  # Returns Vector{Vector{Float64}}
```
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
- `Vector{Float64}`: Vector of time values

# Examples
```julia
times = get_times(memory)  # Returns Vector{Float64}
```
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
- `Vector{Morphism{T,T}}`: Vector of morphisms representing state transitions

# Examples
```julia
links = get_links(memory)  # Returns Vector{Morphism{T,T}}
```
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
- `Tuple{Vector{Float64},Vector{T}}`: Tuple containing (times, states)

# Examples
```julia
times, states = collect_timeseries(memory)
```
"""
function collect_timeseries(memory::TimeSeriesMemory{T}) where {T}
    return (get_times(memory), get_data(memory))
end

"""
    plot_timeseries(memory::TimeSeriesMemory{T}, title::String="Time Series")

Create a plot of the time series data.

# Arguments
- `memory::TimeSeriesMemory{T}`: The memory to plot
- `title::String`: Title for the plot (default: "Time Series")

# Returns
- `Plots.Plot`: Plot object showing the time series

# Examples
```julia
# Plot scalar time series
p = plot_timeseries(memory, "Scalar Time Series")

# Plot vector time series (multiple variables)
p = plot_timeseries(memory, "Vector Time Series")
```
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

Create an AR(1) model with the form: xₜ₊₁ = 0.7xₜ + εₜ

# Arguments
- `initial_state::Vector{Float64}`: Initial state vector

# Returns
- `Tuple{Object{Float64},Object{Vector{Float64}},Morphism,Morphism}`: Tuple containing:
  - Initial time object
  - Initial state object
  - Time step morphism
  - Evolution morphism

# Examples
```julia
# Create AR(1) model
initial_state = [1.0]
t₁, s₁, time_step, evolution = create_ar_model(initial_state)

# Simulate the model
memory = simulate_dynamics(t₁, s₁, time_step, evolution, 100)
```
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

Create a VAR(1) model with the form: xₜ₊₁ = Axₜ + εₜ

# Arguments
- `initial_state::Vector{Float64}`: Initial state vector
- `A::Matrix{Float64}`: Transition matrix

# Returns
- `Tuple{Object{Float64},Object{Vector{Float64}},Morphism,Morphism}`: Tuple containing:
  - Initial time object
  - Initial state object
  - Time step morphism
  - Evolution morphism

# Examples
```julia
# Create VAR(1) model
initial_state = [1.0, 2.0]
A = [0.7 0.2; 0.1 0.8]
t₁, s₁, time_step, evolution = create_var_model(initial_state, A)

# Simulate the model
memory = simulate_dynamics(t₁, s₁, time_step, evolution, 100)
```
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

Create a nonlinear VAR model with the form: xₜ₊₁ = Axₜ + 0.1sin(xₜ) + εₜ

# Arguments
- `initial_state::Vector{Float64}`: Initial state vector
- `A::Matrix{Float64}`: Transition matrix

# Returns
- `Tuple{Object{Float64},Object{Vector{Float64}},Morphism,Morphism}`: Tuple containing:
  - Initial time object
  - Initial state object
  - Time step morphism
  - Evolution morphism

# Examples
```julia
# Create nonlinear VAR model
initial_state = [1.0, 2.0]
A = [0.7 0.2; 0.1 0.8]
t₁, s₁, time_step, evolution = create_nonlinear_var_model(initial_state, A)

# Simulate the model
memory = simulate_dynamics(t₁, s₁, time_step, evolution, 100)
```
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

Create a stochastic nonlinear VAR model with the form: xₜ₊₁ = Axₜ + 0.1sin(xₜ) + 0.1εₜ

# Arguments
- `initial_state::Vector{Float64}`: Initial state vector
- `A::Matrix{Float64}`: Transition matrix

# Returns
- `Tuple{Object{Float64},Object{Vector{Float64}},Morphism,Morphism}`: Tuple containing:
  - Initial time object
  - Initial state object
  - Time step morphism
  - Evolution morphism

# Examples
```julia
# Create stochastic nonlinear VAR model
initial_state = [1.0, 2.0]
A = [0.7 0.2; 0.1 0.8]
t₁, s₁, time_step, evolution = create_stochastic_nonlinear_var_model(initial_state, A)

# Simulate the model
memory = simulate_dynamics(t₁, s₁, time_step, evolution, 100)
```
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

Simulate the dynamics of a system for a specified number of steps.

# Arguments
- `t₁::Object{Float64}`: Initial time
- `s₁::Object{T}`: Initial state
- `time_step::Morphism`: Time step morphism
- `evolution::Morphism`: Evolution morphism
- `n_steps::Int`: Number of steps to simulate

# Returns
- `TimeSeriesMemory{T}`: Memory containing the simulation results

# Examples
```julia
# Simulate AR(1) model
t₁, s₁, time_step, evolution = create_ar_model([1.0])
memory = simulate_dynamics(t₁, s₁, time_step, evolution, 100)

# Plot results
plot_timeseries(memory, "AR(1) Simulation")
```
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
using Moma
using Plots

# Memory creation and extension
t₁ = Object(:t1, 1.0)
s₁ = Object(:s1, [1.0])  # State as vector
memory = TimeSeriesMemory(t₁, s₁)  # Use general constructor
@assert length(memory.times) == 1
@assert length(memory.states) == 1
@assert length(memory.links) == 0

# Test memory extension and data access functions
t₂ = Object(:t2, 2.0)
s₂ = Object(:s2, [2.0])
link = Morphism(s₁, s₂, x -> 2.0 * x, :link)  # Create a link between states with a mapping function
extend!(memory, t₂, s₂, link)
@assert length(memory.times) == 2
@assert length(memory.states) == 2
@assert length(memory.links) == 1

# Test data access functions
data = get_data(memory)
times = get_times(memory)
links = get_links(memory)
@assert length(data) == 2
@assert length(times) == 2
@assert length(links) == 1
@assert all(x -> x isa Vector{Float64}, data)
@assert all(x -> x isa Float64, times)
@assert all(x -> x isa Morphism, links)
@assert data[1] == [1.0]
@assert data[2] == [2.0]
@assert times[1] == 1.0
@assert times[2] == 2.0

# AR(1) model
t₁, s₁, time_step, evolution = create_ar_model([0.5])
@assert s₁.data == [0.5]
@assert time_step.map(1.0) == 2.0
@assert evolution.map([0.5]) == [0.35]

# VAR(1) model
A = [0.5 0.2; 0.1 0.6]
t₁, s₁, time_step, evolution = create_var_model([1.0, 2.0], A)
@assert s₁.data == [1.0, 2.0]
@assert all(evolution.map([1.0, 2.0]) .== A * [1.0, 2.0])

# Nonlinear VAR model
t₁, s₁, time_step, evolution = create_nonlinear_var_model([1.0, 0.5], A)
@assert s₁.data == [1.0, 0.5]
@assert evolution.map isa Function

# Stochastic nonlinear VAR model
t₁, s₁, time_step, evolution = create_stochastic_nonlinear_var_model([1.0, 0.5], A)
@assert s₁.data == [1.0, 0.5]
@assert evolution.map isa Function

# Simulate dynamics
t₁, s₁, time_step, evolution = create_ar_model([0.5])
memory = simulate_dynamics(t₁, s₁, time_step, evolution, 5)
@assert length(memory.times) == 5
@assert length(memory.states) == 5
@assert length(memory.links) == 4

# Data collection
data = get_data(memory)
times = get_times(memory)
@assert length(data) == 5
@assert length(times) == 5
@assert all(x -> x isa Vector{Float64}, data)
@assert all(x -> x isa Float64, times)

# Create and simulate various models for visualization
t₁, s₁, time_step, evolution = create_ar_model([0.5])
ar1_memory = simulate_dynamics(t₁, s₁, time_step, evolution, 100)

t₁, s₁, time_step, evolution = create_var_model([1.0, 2.0], A)
var1_memory = simulate_dynamics(t₁, s₁, time_step, evolution, 100)

t₁, s₁, time_step, evolution = create_nonlinear_var_model([1.0, 0.5], A)
nonlinear_memory = simulate_dynamics(t₁, s₁, time_step, evolution, 100)

t₁, s₁, time_step, evolution = create_stochastic_nonlinear_var_model([1.0, 0.5], A)
stochastic_memory = simulate_dynamics(t₁, s₁, time_step, evolution, 100)

# Create plots
p1 = plot_timeseries(ar1_memory, "Deterministic Linear AR(1)")
p2 = plot_timeseries(var1_memory, "Deterministic Linear VAR(1)")
p3 = plot_timeseries(nonlinear_memory, "Deterministic Nonlinear VAR")
p4 = plot_timeseries(stochastic_memory, "Stochastic Nonlinear VAR")

# Create comparison plot
comparison_plot = plot(p1, p2, p3, p4, layout=(2, 2), size=(1000, 1000))
savefig(comparison_plot, "test/statespace_models_dynamics_comparison.png")

println("\nAll examples completed successfully!")


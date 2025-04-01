module Moma

using LinearAlgebra
using Plots

# Include and use Categories module
include("Categories.jl")
using .Categories

# Re-export Categories symbols
export Object, Morphism, Category, Functor, NaturalTransformation, Pattern,
    identity, compose, create_pattern, check_binding, find_colimit, is_morphism_in_category

# Include and use StateSpace module
include("StateSpace.jl")
using .StateSpace

# Export StateSpace symbols
export TimeSeriesMemory, extend!, get_data, get_times, get_links,
    collect_timeseries, plot_timeseries,
    create_ar_model, create_var_model, create_nonlinear_var_model,
    create_stochastic_nonlinear_var_model, simulate_dynamics

end # module 
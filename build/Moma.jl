module Moma

using LinearAlgebra
using Plots

# Include Categories module
include("Categories.jl")

# Include StateSpace module
include("StateSpace.jl")

# Re-export from Categories
using .Categories: Object, Morphism, Category, Functor, NaturalTransformation, Pattern,
    identity, compose, create_pattern, check_binding, find_colimit, is_morphism_in_category
export Object, Morphism, Category, Functor, NaturalTransformation, Pattern,
    identity, compose, create_pattern, check_binding, find_colimit, is_morphism_in_category

# Re-export from StateSpace
using .StateSpace: TimeSeriesMemory, extend!, get_data, get_times, get_links,
    collect_timeseries, plot_timeseries,
    create_ar_model, create_var_model, create_nonlinear_var_model,
    create_stochastic_nonlinear_var_model, simulate_dynamics
export TimeSeriesMemory, extend!, get_data, get_times, get_links,
    collect_timeseries, plot_timeseries,
    create_ar_model, create_var_model, create_nonlinear_var_model,
    create_stochastic_nonlinear_var_model, simulate_dynamics

end # module 
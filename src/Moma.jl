module Moma

# Export types and functions
export Object, Morphism, Category, Functor, NaturalTransformation, Pattern
export identity, compose, create_pattern, check_binding, find_colimit
export create_traffic_network, analyze_traffic_flow

# Include submodules
include("Categories.jl")
include("examples/TrafficNetwork.jl")

end # module 
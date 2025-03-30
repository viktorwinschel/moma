module Moma

# Export types and functions
export Object, Morphism, Category, Functor, NaturalTransformation, Pattern
export identity, compose, create_pattern, check_binding, find_colimit

# Include submodules
include("Categories.jl")

end # module 
module Moma

using LinearAlgebra
using Plots

# Include Categories module
include("Categories.jl")

# Include StateSpace module
include("StateSpace.jl")

# Import and re-export all public symbols from submodules
using .Categories
using .StateSpace

end # module 
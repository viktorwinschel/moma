using Pkg

# Activate the docs environment
Pkg.activate("docs")

# Add Documenter if not already present
if !("Documenter" in keys(Pkg.project().dependencies))
    Pkg.add("Documenter")
end

# Instantiate the environment
Pkg.instantiate()

# Build the documentation
include("docs/make.jl")

println("Documentation has been built successfully!")
println("You can find the documentation at: docs/build/index.html")
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

# Run git commands
run(`git add .`)
run(`git commit -m "Update documentation and package"`)
run(`git push origin main`)

println("Documentation has been built and changes have been pushed to remote!")
println("You can find the documentation at: docs/build/index.html")
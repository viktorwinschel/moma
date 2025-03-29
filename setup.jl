using Pkg

# Activate the project in the current directory
Pkg.activate(".")

# Add Documenter as a dependency
Pkg.add("Documenter")

# Instantiate the project
Pkg.instantiate()

println("Setup complete! You can now use 'using Moma' in your Julia REPL.")
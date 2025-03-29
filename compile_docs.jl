using Pkg

# Get the root directory of the project
root_dir = @__DIR__

# Change to the docs directory
cd(joinpath(root_dir, "docs"))

# Activate the docs environment
Pkg.activate(".")

# Add the local Moma package
Pkg.develop(path=root_dir)

# Install dependencies
Pkg.instantiate()

# Build the documentation
using Documenter
using Moma

makedocs(
    sitename="Moma.jl",
    format=Documenter.HTML(),
    modules=[Moma],
    source=joinpath(@__DIR__, "docs", "src"),
    build=joinpath(@__DIR__, "docs", "build"),
    pages=[
        "Home" => "index.md",
        "Examples" => "examples.md",
        "Papers" => [
            "Overview" => "papers.md",
            "MES07: Memory Evolutive Systems" => "mes07.md",
            "MES25: Human-Machine Interactions" => "mes25.md",
            "MOMA25: Monetary Macro Accounting" => "moma25.md"
        ],
        "API" => "api.md"
    ]
)

println("Documentation has been built successfully!")
println("You can find the documentation at: docs/build/index.html")
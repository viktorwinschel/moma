using Pkg

# Activate and setup the docs environment
Pkg.activate(@__DIR__)
Pkg.develop(PackageSpec(path=dirname(@__DIR__)))
Pkg.instantiate()

using Documenter
using Moma

makedocs(
    sitename="MoMa",
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", nothing) == "true",
        canonical="https://viktorwinschel.github.io/moma",
        assets=["assets/favicon.ico"]
    ),
    modules=[Moma],
    pages=[
        "Home" => "index.md",
        "Examples" => "examples.md",
        "Papers" => "papers.md",
        "API" => "api.md"
    ],
    doctest=true,
    clean=true
)


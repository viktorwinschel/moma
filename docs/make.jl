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
        "Category Theory" => "category_theory.md",
        "Papers" => "papers.md",
        "API" => "api.md"
    ],
    doctest=true,
    clean=true,
    remotes=nothing  # Force clean build
)

deploydocs(
    repo="github.com/viktorwinschel/moma.git",
    devbranch="main",
    push_preview=true,
    target="build",
    versions=nothing,  # Don't create version selector
    forcepush=true    # Force push to overwrite gh-pages
)


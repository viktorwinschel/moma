using Pkg

# Activate and setup the docs environment
Pkg.activate(@__DIR__)
Pkg.develop(PackageSpec(path=dirname(@__DIR__)))
Pkg.instantiate()

using Documenter
using Moma

makedocs(
    sitename="Moma.jl",
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", nothing) == "true",
        canonical="https://viktorwinschel.github.io/moma"
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

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo="github.com/viktorwinschel/moma.git",
    devbranch="main",
    push_preview=true,
    forcepush=true,
    deploy_config=Documenter.GitHubActions()
)


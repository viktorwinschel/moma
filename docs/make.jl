using Pkg

# Activate and setup the docs environment
Pkg.activate(@__DIR__)
Pkg.develop(PackageSpec(path=dirname(@__DIR__)))
Pkg.instantiate()

using Documenter
using Moma

DocMeta.setdocmeta!(Moma, :DocTestSetup, :(using Moma); recursive=true)

makedocs(
    sitename="MoMa",
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://viktorwinschel.github.io/moma",
        assets=["assets/favicon.ico"],
        edit_link="main"
    ),
    modules=[Moma],
    pages=[
        "Home" => "index.md",
        "Categories" => "categories.md",
        "Examples" => "examples.md",
        "State Space Models" => "state_space_models.md",
        "Papers" => "papers.md",
        "API" => "api.md"
    ],
    doctest=true,
    clean=true,
    checkdocs=:exports
)

deploydocs(
    repo="github.com/viktorwinschel/moma.git",
    devbranch="main",
    push_preview=true,
    versions=nothing,
    forcepush=true
)


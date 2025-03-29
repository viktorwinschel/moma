using Documenter
using Moma

makedocs(
    sitename="Moma",
    format=Documenter.HTML(),
    modules=[Moma],
    pages=[
        "Home" => "index.md",
        "API" => "api.md",
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo="github.com/viktorwinschel/moma.git",
    devbranch="main",
    push_preview=true,
)
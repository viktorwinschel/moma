using Documenter
using Moma

makedocs(
    sitename="MoMa",
    format=Documenter.HTML(
        prettyurls=false
    ),
    modules=[Moma],
    pages=[
        "Home" => "index.md",
        "Papers" => [
            "Overview" => "papers.md",
            "MES07: Memory Evolutive Systems" => "mes07.md",
            "MES25: Human-Machine Interactions" => "mes25.md",
            "MOMA25: Monetary Macro Accounting" => "moma25.md"
        ],
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
    forcepush=true,
)
using ZoteroToPapis
using Documenter

DocMeta.setdocmeta!(ZoteroToPapis, :DocTestSetup, :(using ZoteroToPapis); recursive=true)

makedocs(;
    modules=[ZoteroToPapis],
    authors="Hugo Levy-Falk <hugo@klafyvel.me> and contributors",
    sitename="ZoteroToPapis.jl",
    format=Documenter.HTML(;
        canonical="https://klafyvel.github.io/ZoteroToPapis.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/klafyvel/ZoteroToPapis.jl",
    devbranch="main",
)

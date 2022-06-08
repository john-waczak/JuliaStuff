using JuliaStuff
using Documenter

DocMeta.setdocmeta!(JuliaStuff, :DocTestSetup, :(using JuliaStuff); recursive=true)

makedocs(;
    modules=[JuliaStuff],
    authors="John Waczak",
    repo="https://github.com/john-waczak/JuliaStuff.jl/blob/{commit}{path}#{line}",
    sitename="JuliaStuff.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://john-waczak.github.io/JuliaStuff.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/john-waczak/JuliaStuff.jl",
    devbranch="main",
)

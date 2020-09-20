using Documenter
using StructMapping

makedocs(
    sitename = "StructMapping.jl",
    format = Documenter.HTML(),
    pages = [
        "Home" => "index.md",
        "Functions" => "functions.md",
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(repo = "github.com/matsueushi/StructMapping.jl")

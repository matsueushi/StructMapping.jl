using Documenter
using StructMapping

makedocs(
    sitename = "StructMapping",
    format = Documenter.HTML(),
    modules = [StructMapping]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#

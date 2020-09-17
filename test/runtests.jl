using Test, Documenter, StructMapping
DocMeta.setdocmeta!(StructMapping, :DocTestSetup, :(using StructMapping); recursive=true)
doctest(StructMapping)

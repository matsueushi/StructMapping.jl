using Test, Documenter, Parameters, StructMapping

@testset "doctest" begin
    DocMeta.setdocmeta!(StructMapping, :DocTestSetup, :(using StructMapping); recursive=true)
    doctest(StructMapping)
end

@with_kw struct A
    a::Float64
    b::String
end

@with_kw struct B
    a::A
    b::Int64
end

@testset "simple" begin
    dict_a = Dict("b"=>"b", "a"=>1.0)
    dict_b = Dict("a"=>dict_a, "b"=>4)

    StructMapping._structmap(::Type{B}, d::AbstractDict) = StructMapping._structmap(B, d, StructMapping._findmap(B))

    @test structmap(A, dict_a) == A(1.0, "b")
    @test structmap(B, dict_b) == B(A(1.0, "b"), 4)
end

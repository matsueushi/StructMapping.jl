using Test, Documenter, Parameters, StructMapping


@with_kw struct A
    a::Float64
    b::String
end

dict_a = Dict("a"=>1.0, "b"=>"b")

@testset "basic" begin
    @test convertdict(A, dict_a) == A(1.0, "b")
end

@dictmap @with_kw struct B
    a::A
    b::Int64 = 0
end

dict_b = Dict("a"=>dict_a, "b"=>4)

@testset "nested" begin
    @test convertdict(B, dict_b) == B(A(1.0, "b"), 4)
end

@dictmap @with_kw struct C
    a::Vector{A}
end

dict_a2 = Dict("a"=>2.0, "b"=>"b2")
dict_c = Dict("a"=>[dict_a, dict_a2])

@testset "vector" begin
    @test convertdict(C, dict_c).a == [A(1.0, "b"), A(2.0, "b2")]
end

@testset "doctest" begin
    DocMeta.setdocmeta!(StructMapping, :DocTestSetup, :(using StructMapping); recursive=true)
    doctest(StructMapping)
end

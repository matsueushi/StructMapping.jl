using Test, Documenter, Parameters, StructMapping

@with_kw struct A
    a::Float64
    b::String
end

dict_a = Dict("a"=>1.0, "b"=>"b")

@testset "basic" begin
    @test convertdict(A, dict_a) == A(1.0, "b")
end

@with_kw struct A2
    a::Float64
    b::Vector{String}
end

dict_a2 = Dict("a"=>1.0, "b"=>["b"])

@testset "basic2" begin
    a2 = convertdict(A2, dict_a2)
    @test a2.a == 1.0
    @test a2.b == ["b"]
end

@dictmap @with_kw struct B
    a::A
    b::Int64 = 0
end

dict_b = Dict("a"=>dict_a, "b"=>4)

@testset "nested" begin
    @test convertdict(B, dict_b) == B(A(1.0, "b"), 4)
end

dict_b2 = Dict("a"=>dict_a)

@testset "default" begin
    @test convertdict(B, dict_b2) == B(A(1.0, "b"), 0)
end

@dictmap @with_kw struct C
    a::Vector{A}
end

dict_a2 = Dict("a"=>2.0, "b"=>"b2")
dict_c = Dict("a"=>[dict_a, dict_a2])

@testset "vector" begin
    @test convertdict(C, dict_c).a == [A(1.0, "b"), A(2.0, "b2")]
end

@dictmap @with_kw struct D
    a::Union{A, Nothing} = nothing
end

@testset "union" begin
    @test convertdict(D, Dict()) == D()
    @test convertdict(D, dict_b2) == D(A(1.0, "b"))
end

@dictmap @with_kw struct E
    a::Union{Vector{A}, Nothing} = nothing
end

@testset "union_vector" begin
    @test convertdict(E, Dict()) == E()
    @test convertdict(E, dict_c).a == [A(1.0, "b"), A(2.0, "b2")]
end

@dictmap @with_kw struct F
    b::B
    d::D
end

@testset "deeply_nested" begin
    f = convertdict(F, Dict("b"=>dict_b, "d"=>dict_b2))
    @test f.b == B(A(1.0, "b"), 4)
    @test f.d == D(A(1.0, "b"))
end

@dictmap @with_kw struct G
    a::A
    g::Dict{String, Int64}
end

dict_g = Dict("a"=>dict_a, "g"=>Dict("g1"=>0, "g2"=>1))

@testset "dict" begin
    g = convertdict(G, dict_g)
    @test g.a == A(1.0, "b")
    @test g.g == Dict("g1"=>0, "g2"=>1)
end

@testset "doctest" begin
    DocMeta.setdocmeta!(StructMapping, :DocTestSetup, :(using StructMapping); recursive=true)
    doctest(StructMapping)
end

using Test, Documenter, Parameters, StructMapping

@with_kw struct A
    a::Float64
    b::String
end

dict_a = Dict("a" => 1.0, "b" => "b")

@testset "basic" begin
    @test convertdict(A, dict_a) == A(1.0, "b")
end

@with_kw struct A2
    a::Float64
    b::Vector{String}
end

dict_a2 = Dict("a" => 1.0, "b" => ["b"])

@testset "basic2" begin
    a2 = convertdict(A2, dict_a2)
    @test a2.a == 1.0
    @test a2.b == ["b"]
end

@with_kw struct B
    a::A
    b::Int64 = 0
end

dict_b = Dict("a" => dict_a, "b" => 4)

@testset "nested" begin
    @test convertdict(B, dict_b) == B(A(1.0, "b"), 4)
end

dict_b2 = Dict("a" => dict_a)

@testset "default" begin
    @test convertdict(B, dict_b2) == B(A(1.0, "b"), 0)
end

@with_kw struct C
    a::Vector{A}
end

dict_a2 = Dict("a" => 2.0, "b" => "b2")
dict_c = Dict("a" => [dict_a, dict_a2])

@testset "vector" begin
    @test convertdict(C, dict_c).a == [A(1.0, "b"), A(2.0, "b2")]
end

@with_kw struct D
    a::Union{A,Nothing} = nothing
end

@testset "union" begin
    @test convertdict(D, Dict()) == D()
    @test convertdict(D, dict_b2) == D(A(1.0, "b"))
end

@with_kw struct E
    a::Union{Vector{A},Nothing} = nothing
end

@testset "union_vector" begin
    @test convertdict(E, Dict()) == E()
    @test convertdict(E, dict_c).a == [A(1.0, "b"), A(2.0, "b2")]
end

@with_kw struct F
    b::B
    d::D
end

@testset "deeply_nested" begin
    f = convertdict(F, Dict("b" => dict_b, "d" => dict_b2))
    @test f.b == B(A(1.0, "b"), 4)
    @test f.d == D(A(1.0, "b"))
end

@with_kw struct G
    a::A
    g::Dict{String,Int64}
end

dict_g = Dict("a" => dict_a, "g" => Dict("g1" => 0, "g2" => 1))

@testset "dict" begin
    g = convertdict(G, dict_g)
    @test g.a == A(1.0, "b")
    @test g.g == Dict("g1" => 0, "g2" => 1)
end

# Support custom vector.
@with_kw struct MyVec1{T} <: AbstractVector{T}
    inner::AbstractVector{T}
end
Base.size(myvec::MyVec1) = Base.size(myvec.inner)
Base.getindex(myvec::MyVec1, i::Int) = Base.getindex(myvec.inner, i::Int)
Base.setindex!(myvec::MyVec1, value, i::Int) = Base.setindex!(myvec.inner, value, i::Int)

# If there is more than one field,
# must define an internal constructor that accepts one parameter.
@with_kw struct MyVec2{T} <: AbstractVector{T}
    inner::AbstractVector{T}
    ignore::String
    MyVec2{T}(inner, ignore) where {T} = new(inner, ignore)
    MyVec2{T}(inner) where {T} = new(inner, "ignore")
end
Base.size(myvec::MyVec2) = Base.size(myvec.inner)
Base.getindex(myvec::MyVec2, i::Int) = Base.getindex(myvec.inner, i::Int)
Base.setindex!(myvec::MyVec2, value, i::Int) = Base.setindex!(myvec.inner, value, i::Int)

# Examples in Julia documents.
struct SquaresVector <: AbstractArray{Int,1}
    count::Int
end
Base.size(S::SquaresVector) = (S.count,)
Base.IndexStyle(::Type{<:SquaresVector}) = IndexLinear()
Base.getindex(S::SquaresVector, i::Int) = i * i

# Nested struct
@with_kw struct H
    a::MyVec1{Float64}
    b::MyVec2{Int}
    c::SquaresVector
end

@testset "custom_vector" begin
    dict_h = Dict("a" => [1, 2, 3], "b" => [9, 8, 7], "c" => 4)
    h = convertdict(H, dict_h)
    v1 = MyVec1{Float64}([1, 2, 3])
    v2 = MyVec2{Int}([9, 8, 7])
    v3 = SquaresVector(4)
    @test h.a == v1
    @test typeof(h.a) == typeof(v1)
    @test h.b == v2
    @test typeof(h.b) == typeof(v2)
    @test Vector(h.c) == [1, 4, 9, 16]
    @test typeof(h.c) == typeof(v3)
end

@testset "doctest" begin
    DocMeta.setdocmeta!(StructMapping, :DocTestSetup, :(using StructMapping);
                        recursive=true)
    doctest(StructMapping)
end

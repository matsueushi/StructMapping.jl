# StructMapping.jl

This package allows to map a nested `Dict` to struct.
```julia
julia> using Parameters, StructMapping

julia> @with_kw struct A
           a::Float64
           b::String
       end

julia> @dictmap @with_kw struct B
           a::A
           b::Int64
       end

julia> j = Dict("a"=>Dict("a"=>1.0, "b"=>"hello"), "b"=>2)
Dict{String,Any} with 2 entries:
  "b" => 2
  "a" => Dict{String,Any}("b"=>"hello","a"=>1.0)

julia> b = convertdict(B, j)
B
  a: A
  b: Int64 2

julia> b.a
A
  a: Float64 1.0
  b: String "hello"
```

## Working with JSON
```julia
julia> using JSON

julia> s = "{\"b\":2,\"a\":{\"b\":\"hello\",\"a\":1.0}}"
"{\"b\":2,\"a\":{\"b\":\"hello\",\"a\":1.0}}"

julia> println(s)
{"b":2,"a":{"b":"hello","a":1.0}}

julia> j = JSON.parse(s)
Dict{String,Any} with 2 entries:
  "b" => 2
  "a" => Dict{String,Any}("b"=>"hello","a"=>1.0)

julia> convertdict(B, j)
B
  a: A
  b: Int64 2
```

## Vector, default values
```julia
julia> @dictmap @with_kw struct C
           a::Vector{A}
           b::Union{A, Nothing} = nothing
           c::Int64 = 5
       end

julia> j2 = Dict("a"=>[Dict("a"=>1.0, "b"=>"hello"), Dict("a"=>2.0, "b"=>"world")])
Dict{String,Array{Dict{String,Any},1}} with 1 entry:
  "a" => Dict{String,Any}[Dict("b"=>"hello","a"=>1.0), Dict("b"=>"world","a"=>2.0)]

julia> c = convertdict(C, j2)
C
  a: Array{A}((2,))
  b: Nothing nothing
  c: Int64 5

julia> c.a
2-element Array{A,1}:
 A(1.0, "hello")
 A(2.0, "world")

julia> j3 = Dict("a"=>[Dict("a"=>1.0, "b"=>"hello")], "b"=>Dict("b"=>"world","a"=>2.0))
Dict{String,Any} with 2 entries:
  "b" => Dict{String,Any}("b"=>"world","a"=>2.0)
  "a" => Dict{String,Any}[Dict("b"=>"hello","a"=>1.0)]

julia> c2 = convertdict(C, j3)
C
  a: Array{A}((1,))
  b: A
  c: Int64 5

julia> c2.a
1-element Array{A,1}:
 A(1.0, "hello")

julia> c2.b
A
  a: Float64 2.0
  b: String "world"
```

## Deeply nested dictionary
```julia
julia> @dictmap @with_kw struct D
           b::B
           s::String
       end

julia> j5 = Dict("s"=>"hi", "b"=>Dict("a"=>Dict("a"=>1.0, "b"=>"hello"), "b"=>2))
Dict{String,Any} with 2 entries:
  "b" => Dict{String,Any}("b"=>2,"a"=>Dict{String,Any}("b"=>"hello","a"=>1.0))
  "s" => "hi"

julia> d = convertdict(D, j5)
D
  b: B
  s: String "hi"

julia> d.b
B
  a: A
  b: Int64 2

julia> d.b.a
A
  a: Float64 1.0
  b: String "hello"
```

## Related packages
* [mauro3/Parameters.jl](https://github.com/mauro3/Parameters.jl)
* [JuliaIO/JSON.jl](https://github.com/JuliaIO/JSON.jl)

# StructMapping.jl

[![][docs-dev-img]][docs-dev-url] [![][travis-img]][travis-url]

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

## Documentation
* [dev][docs-dev-url]

## Related packages
* [mauro3/Parameters.jl](https://github.com/mauro3/Parameters.jl)
* [JuliaIO/JSON.jl](https://github.com/JuliaIO/JSON.jl)

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://matsueushi.github.io/StructMapping.jl/dev

[travis-img]: https://travis-ci.com/matsueushi/StructMapping.jl.svg?branch=master
[travis-url]: https://travis-ci.com/matsueushi/StructMapping.jl

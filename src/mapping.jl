_keytosymbol(x) = x
_keytosymbol(v::AbstractVector) = keytosymbol.(v)
_keytosymbol(d::AbstractDict) = Dict(Symbol(k) => _keytosymbol(v) for (k, v) in pairs(d))

"""
    keytosymbol(x)

Convert type of keys of the given dictionary to `Symbol` recursively.

# Examples
```jldoctest
julia> keytosymbol(Dict("a"=>1, "b"=>1))
Dict{Symbol,Int64} with 2 entries:
  :a => 1
  :b => 1

julia> keytosymbol(Dict("a"=>1, "b"=>Dict("c"=>2, "d"=>3)))
Dict{Symbol,Any} with 2 entries:
  :a => 1
  :b => Dict(:d=>3,:c=>2)

julia> keytosymbol(Dict("a"=>1, "b"=>[Dict("c"=>2), Dict("d"=>3)]))
Dict{Symbol,Any} with 2 entries:
  :a => 1
  :b => [Dict(:c=>2), Dict(:d=>3)]
```
"""
keytosymbol(d::AbstractDict) = _keytosymbol(d)

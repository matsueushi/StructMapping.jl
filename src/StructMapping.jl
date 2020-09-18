module StructMapping
using Parameters

export keytosymbol, structmap

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


_squeeze_type(::Type{T}) where T = T
_squeeze_type(::Type{Vector{T}}) where T = T
_squeeze_type(::Type{Union{T, Nothing}}) where T = T



function _findmap(T::Type)
    mapdict = Dict()
    for name in fieldnames(T)
        sym = _squeeze_type(fieldtype(T, name))
        if !isdefined(Base, Symbol(sym))
            mapdict[name] = sym
        end
    end
    return mapdict
end

_structmap(T::Type, d::AbstractDict) = T(;d...)
_structmap(T::Type, v::AbstractVector) = _structmap.(T, v)
function _structmap(T::Type, d::AbstractDict, m::AbstractDict)
    for (k, v) in pairs(m)
        d[k] = _structmap(v, d[k])
    end
    return T(;d...)
end

structmap(T::Type, d::AbstractDict) = _structmap(T, keytosymbol(d))

end # module

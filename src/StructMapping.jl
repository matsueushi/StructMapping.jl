module StructMapping
using Parameters
using MacroTools: @capture, postwalk

export keytosymbol, convertdict, @dictmap

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

## Helper functions for `convertdict`
_convertdict(T::Type, d::AbstractDict) = T(;d...)
_convertdict(T::Type, v::AbstractVector) = _convertdict.(T, v)
function _convertdict(T::Type, d::AbstractDict, m::AbstractDict)
    dargs = Dict{Symbol, Any}(d)
    for (k, v) in pairs(m)
        dargs[k] = _convertdict(v, d[k])
    end
    return T(;dargs...)
end

"""
    convertdict(T::Type, d::AbstractDict)
"""
convertdict(T::Type, d::AbstractDict) = _convertdict(T, keytosymbol(d))

## Helper function for `@dictmap`
_squeeze_type(::Type{T}) where T = T
_squeeze_type(::Type{Vector{T}}) where T = T
_squeeze_type(::Type{Union{T, Nothing}}) where T = T

function _findmap(T::Type, mod::Module)
    defined_symbols = names(mod; all=true)
    mapping = Dict()
    for name in fieldnames(T)
        sym = _squeeze_type(fieldtype(T, name))
        if Symbol(sym) in defined_symbols
            mapping[name] = sym
        end
    end
    return mapping
end

"""
    @dictmap
"""

macro dictmap(ex)
    structsymbol = nothing
    postwalk(ex) do x
        @capture(x, struct T_ fields__ end) || return x
        structsymbol = T
    end
    T = :($__module__.$structsymbol)
    q = quote
        $ex
        function StructMapping._convertdict(::Type{$T}, d::AbstractDict)
            mapping = StructMapping._findmap($T, $__module__)
            StructMapping._convertdict($T, keytosymbol(d), mapping)
        end
    end
    esc(q)
end

end # module
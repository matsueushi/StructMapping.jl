module StructMapping
using MacroTools: @capture, postwalk

export convertdict, @dictmap

## Helper functions for `convertdict`
_keytosymbol(d::AbstractDict) = Dict(Symbol(k) => v for (k, v) in pairs(d))

_convertdict(T::Type, d::AbstractDict) = T(;_keytosymbol(d)...)
_convertdict(T::Type, v::AbstractVector) = _convertdict.(T, v)

function _convertdictwithmap(T::Type, d::AbstractDict, m::AbstractDict)
    dargs = Dict(
        k=>haskey(m, k) ? _convertdict(m[k], v) : v 
        for (k, v) in pairs(_keytosymbol(d))
    )
    return T(;dargs...)
end

"""
    convertdict(T::Type, d::AbstractDict)

Convert the given dictionary to a object of `T`. `T` must be decorated with `@dictmap` (and `@with_kw` or `@with_kw_noshow` of Parameters.jl).
"""
convertdict(T::Type, d::AbstractDict) = _convertdict(T, d)

## Helper function for `@dictmap`
_squeezetype(::Type{T}) where T = T
_squeezetype(::Type{Vector{T}}) where T = T
_squeezetype(::Type{Union{T, Nothing}}) where T = _squeezetype(T)

function _findmap(T::Type, mod::Module)
    defined_symbols = names(mod; all=true)
    mapping = Dict()
    for name in fieldnames(T)
        sym = _squeezetype(fieldtype(T, name))
        if Symbol(sym) in defined_symbols
            mapping[name] = sym
        end
    end
    return mapping
end

"""
    @dictmap(ex)

Macro which allows to use the `convertdict` function for a struct decorated with
`@with_kw` or `@with_kw_noshow` of Parameters.jl.
"""

macro dictmap(ex)
    structsymbol = nothing
    postwalk(ex) do x
        @capture(x, struct T_ __ end) || return x
        structsymbol = T
    end
    T = :($__module__.$structsymbol)
    q = quote
        $ex
        function StructMapping._convertdict(::Type{$T}, d::AbstractDict)
            mapping = StructMapping._findmap($T, $__module__)
            StructMapping._convertdictwithmap($T, d, mapping)
        end
    end
    esc(q)
end

end # module

module StructMapping
using MacroTools: @capture, postwalk

export convertdict, @dictmap

## Helper functions
_keytosymbol(d::AbstractDict) = Dict(Symbol(k) => v for (k, v) in pairs(d))

_squeezetype(::Type{T}) where T = T
_squeezetype(::Type{T}) where T <: AbstractVector = eltype(T)
_squeezetype(::Type{Union{T, Nothing}}) where T = _squeezetype(T)

_convertdict(::Type, x) = x
_convertdict(T::Type, d::AbstractDict) = T(;_keytosymbol(d)...)
_convertdict(::Type{T}, d::AbstractDict) where T <: AbstractDict = d
_convertdict(T::Type, v::AbstractVector) = _convertdict.(T, v)

function _convertdictwithmap(T::Type, d::AbstractDict)
    dargs = Dict(
        k => _convertdict(_squeezetype(fieldtype(T, k)), v)
        for (k, v) in pairs(_keytosymbol(d))
    )
    return T(;dargs...)
end

"""
    convertdict(T::Type, d::AbstractDict)

Convert the given dictionary to a object of `T`.
`T` must be decorated with `@dictmap` (and `@with_kw` or `@with_kw_noshow` of Parameters.jl).
"""
convertdict(T::Type, d::AbstractDict) = _convertdict(T, d)

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
        StructMapping._convertdict(::Type{$T}, d::AbstractDict) = StructMapping._convertdictwithmap($T, d)
    end
    esc(q)
end

end # module

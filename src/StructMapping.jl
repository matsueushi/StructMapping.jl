module StructMapping
using MacroTools: @capture, postwalk

export convertdict

## Helper functions
_keytosymbol(d::AbstractDict) = Dict(Symbol(k) => v for (k, v) in pairs(d))

_squeezetype(::Type{T}) where T = T
_squeezetype(::Type{T}) where T <: AbstractVector = eltype(T)
_squeezetype(::Type{Union{T, Nothing}}) where T = _squeezetype(T)

_convertdict(::Type, x) = x
_convertdict(::Type{T}, d::AbstractDict) where T <: AbstractDict = d
_convertdict(T::Type, v::AbstractVector) = _convertdict.(T, v)

function _convertdict(T::Type, d::AbstractDict)
    dargs = Dict(
        k => _convertdict(_squeezetype(fieldtype(T, k)), v)
        for (k, v) in pairs(_keytosymbol(d))
    )
    return T(;dargs...)
end

"""
    convertdict(T::Type, d::AbstractDict)

Convert the given dictionary to a object of `T`.
`T` must be decorated with `@with_kw` or `@with_kw_noshow` of Parameters.jl.
"""
convertdict(T::Type, d::AbstractDict) = _convertdict(T, d)

end # module

module StructMapping

export convertdict

## Helper functions
_keytosymbol(d::AbstractDict) = Dict(Symbol(k) => v for (k, v) in pairs(d))

_convertdict(::Type, x) = x
_convertdict(::Type{Union{T, Nothing}}, x) where T = _convertdict(T, x)
_convertdict(::Type{Union{T, Nothing}}, d::AbstractDict) where T = _convertdict(T, d)
_convertdict(::Type{T}, v::AbstractVector) where T <: AbstractVector = _convertdict.(eltype(T), v)
_convertdict(::Type{T}, d::AbstractDict) where T <: AbstractDict = d

function _convertdict(T::Type, d::AbstractDict)
    dargs = Dict(
        k => _convertdict(fieldtype(T, k), v)
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

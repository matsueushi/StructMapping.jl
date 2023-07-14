module StructMapping

export convertdict

## Helper functions
_convertdict(::Type{T}, x) where {T} = T(x)
_convertdict(::Type{Union{T,Nothing}}, x) where {T} = _convertdict(T, x)
_convertdict(::Type{Union{T,Nothing}}, d::AbstractDict) where {T} = _convertdict(T, d)
_convertdict(::Type{Union{T,Nothing}}, ::Nothing) where {T} = nothing
function _convertdict(::Type{T}, v::AbstractVector) where {T<:AbstractVector}
    return T(_convertdict.(eltype(T), v))
end
_convertdict(::Type{T}, d::AbstractDict) where {T<:AbstractDict} = d

function _convertdict(T::Type, d::AbstractDict)
    kwargs = Dict{Symbol,Any}()
    for (k, v) in pairs(d)
        symk = Symbol(k)
        kwargs[symk] = _convertdict(fieldtype(T, symk), v)
    end
    return T(; kwargs...)
end

"""
    convertdict(T::Type, d::AbstractDict)

Convert the given dictionary to a object of `T`.
`T` must be decorated with `@with_kw` or `@with_kw_noshow` of Parameters.jl.
"""
convertdict(T::Type, d::AbstractDict) = _convertdict(T, d)

end # module

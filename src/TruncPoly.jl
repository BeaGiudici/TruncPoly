module TruncPoly

struct Series{T,N}
	c::NTuple{N,T}
end
export Series

import Base.zero
zero(::Type{Series{T,N}}) where {T,N} = Series{T,N}(ntuple(i -> zero(T), N))

import Base.one
one(::Type{Series{T,N}}) where {T,N} = Series{T,N}(ntuple(i -> i==1 ? one(T) : zero(T), N))

include("TPMath.jl")
export Base.:+, Base.:*

end # module

module TruncPoly

"""
	Series{T,N}

	Series of degree N with coefficients of type T
"""
struct Series{T,N}
	c::NTuple{N,T}
end
export Series

include("TPMath.jl")

end # module

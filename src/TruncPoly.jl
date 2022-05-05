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
include("TPFunctions.jl")

# Let's teach Julia how to evaluate a series at a point
function (s::Series{T,N})(x) where {T,N}
    
	v = s.c[N]*x + s.c[N-1]
	for k in N-2:-1:1
			v = v*x + s.c[k]
	end

	return v
end 

end # module

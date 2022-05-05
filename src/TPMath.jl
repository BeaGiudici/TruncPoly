import Base.:+
function Base.:+(s1::Series{T,N}, s2::Series{T,N}) where {T,N}
	return Series2(ntuple(i -> s1.c[i]+s2.c[i], N))
end

import Base.:*
function Base.:*(s1::Series{T,N}, s2::Series{T,N}) where {T,N}
	@inline function mul(i)
		c = s1.c[1] * s2.c[i]

		@inbounds for k in 2:i
			c = c + s1.c[k] * s2.c[i-k+1]
		end
		return c
	end

	return Series2(ntuple(mul, N))
end
import Base.exp, Base.log, Base.sin, Base.cos, Base.abs

function log(s::Series{T,N}) where {T,N}
	tmp = Series{T,N}(ntuple(i -> i==1 ? zero(T) : -s.c[i]/s.c[1], N))
end
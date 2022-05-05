import Base.zero
"""
Redefinition of the zero as a Series
"""
zero(::Type{Series{T,N}}) where {T,N} = Series{T,N}(ntuple(i -> zero(T), N))

import Base.one
"""
Redefinition of the zero as a Series
"""
one(::Type{Series{T,N}}) where {T,N} = Series{T,N}(ntuple(i -> i==1 ? one(T) : zero(T), N))

import Base.:+
"""
Redefinition of the sum:
- As a unary function
- Sum of two Series
- Sum of a Series and a Number (two series)
"""
Base.:+(s::Series{T,N}) where {T,N} = s
Base.:+(s1::Series{T,N}, s2::Series{T,N}) where {T,N} = Series(ntuple(i -> s1.c[i] + s2.c[i], N))
Base.:+(s::Series{T,N}, x::Float64) where {T,N} = Series(ntuple(i -> i==1 ? s.c[1] + x : s.c[i], N))
Base.:+(x::Number, s::Series{T,N}) where {T,N} = Series(ntuple(i -> i==1 ? s.c[1] + x : s.c[i], N))

import Base.:-
"""
Redefinition of the subtraction:
- As a unary function
- Subtraction of two Series
- Subtraction of a Series and a Number
- Subtraction of a Number and a Series
"""
Base.:-(s::Series{T,N}) where {T,N} = Series(ntuple(i-> -s.c[i], N))
Base.:-(s1::Series{T,N}, s2::Series{T,N}) where {T,N} = Series(ntuple(i -> s1.c[i] - s2.c[i], N))
Base.:-(s::Series{T,N}, x::Number) where {T,N} = Series(ntuple(i -> i==1 ? s.c[1] - x : s.c[i], N))
Base.:-(x::Number, s::Series{T,N}) where {T,N} = Series(ntuple(i -> i==1 ? x - s.c[1] : -s.c[i], N))

import Base.:*
"""
Redefinition of the multiplication:
- Product of two Series
- Product between a Series and a Number (two ways)
"""
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
Base.:*(s::Series{T,N}, x::Number) where {T,N} = Series(ntuple(i -> s.c[i]*x, N))
Base.:*(x::Number, s::Series{T,N}) where {T,N} = Series(ntuple(i -> s.c[i]*x, N))

import Base.:/
"""
Redefinition of the division:
- Division between two Series
- Division of the division of the Series by a Number
"""
function Base.:/(s1::Series{T,N}, s2::Series{T,N}) where {T,N}
   @inline function div(i)
    if i == 1
      return s1.c[1]/s2.c[1]
    else
      c = s1.c[i]
      @inbounds for k in 2:i
        c = c - s2.c[k]*div(i-k+1)
      end
        c = c/s2.c[1]
    end
    return c
	end    
    
  return Series(ntuple(div, N))
end

Base.:/(s1::Series{T,N}, s2::Number)      where {T,N} = Series{T,N}(ntuple(i -> s1.c[i]/s2, N))
@generated function Base.:/(b::Number,a::Series{T,N}) where {T,N} 
    vars = Vector{Expr}(undef, N)
    expr = Expr(:call,:(/),:(b),:(a.c[1]))
    vars[1] = :($(Symbol("c_1")) = $expr)
    for i in 2:N
	ex = Expr(
	    :call,
	    :+,
	    [:( a.c[$i-$k+1] * $(Symbol("c_$(k)")) ) for k in 1:i-1]...
	        )
        
        ex2 = Expr(:call, :-, ex)
        ex3 = Expr(:call, :/, ex2, :(a.c[1]))

	vars[i] = :($(Symbol("c_$(i)")) = $ex3)
    end

    t = Expr(:tuple,  [Symbol("c_$(i)") for i = 1:N]...)
    pack = :(Series{T, N}($t))


    return Expr(
	:block,
	vars...,
	:(return $pack)
    )
end

import Base.:^
function Base.:^(s::Series{T,N}, n::Int) where {T,N}
    sp = s
    np = n
    r = Series(ntuple(i -> i == 1 ? one(T) : zero(T), N))
    while true
        if mod(np, 2) == 1
            r = r*sp
        end

        np = div(np, 2)
        if np == 0
            break
        end
        sp = sp*sp
    end
    return r
end
using NiLang

function fib(n)
    if n > 2
        fib(n-1) + fib(n-2)
    else
        one(n)
    end
end

@i function rfib(out, n::T) where T
    @anc n1 = zero(T)
    @anc n2 = zero(T)
    n1 ⊕ n
    n1 ⊖ 1.0
    n2 ⊕ n
    n2 ⊖ 2.0
    if (value(n) <= 2, ~)
        out ⊕ 1.0
    else
        rfib(out, n1)
        rfib(out, n2)
    end
    n1 ⊖ n
    n1 ⊕ 1.0
    n2 ⊖ n
    n2 ⊕ 2.0
end

rfib(0.0, 10.0)
fib(10.0)

using NiLang.AD
GVar{T,T2}(x::T) where {T, T2} = GVar(x, zero(T2))
rfib'(Loss(0.0), 10.0)

"""find the minimum n that fib(n) > 100"""
function fib100()
    n = 0.0
    while fib(n) < 100
        n += 1.0
    end
    return n
end
fib100()

@i function rfib100(n)
    @safe @assert n == 0
    while (fib(n) < 100, n != 0)
        n ⊕ 1.0
    end
end
rfib100(0.0)

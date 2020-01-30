using NiLang

@i function rfib(out!, n::T) where T
    @anc n1 = zero(T)
    @anc n2 = zero(T)
    @routine init begin
        n1 += identity(n)
        n1 -= identity(1)
        n2 += identity(n)
        n2 -= identity(2)
    end
    if (value(n) <= 2, ~)
        out! += identity(1)
    else
        rfib(out!, n1)
        rfib(out!, n2)
    end
    ~@routine init
end

@i function rfibn(n!, z)
    @safe @assert n! == 0
    @anc out = 0
    rfib(out, n!)
    while (out < z, n! != 0)
        ~rfib(out, n!)
        n! += identity(1)
        rfib(out, n!)
    end
    ~rfib(out, n!)
end

rfib(0, 10)

rfibn(0, 100)

# irreversible approach
function fib(n)
    if n > 2
        fib(n-1) + fib(n-2)
    else
        one(n)
    end
end

using Test
@test fib(10) == rfib(0, 10)[1]

function fibn(z)
    n = 0
    while fib(n) < z
        n += 1
    end
    return n
end
fibn(100)

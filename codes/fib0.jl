using NiLang

@i function rfib(out!, n::T) where T
    @zeros T n1 n2
    @routine begin
        n1 += n - 1
        n2 += n - 2
    end
    if n <= 2
        out! += 1
    else
        rfib(out!, n1)
        rfib(out!, n2)
    end
    ~@routine
end

@i function rfib2(out!, n)
    @invcheckoff if n >= 1
        counter ← 0
        counter += n
        while (counter > 1, counter!=n)
            rfib2(out!, counter-1)
            counter -= 2
        end
        counter -= n % 2
        counter → 0
    end
    out! += 1
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

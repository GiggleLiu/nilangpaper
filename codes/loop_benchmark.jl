using InvertibleVM.InvSimulator

@newreg i
@newvar x = 0.0
@newvar one = 1.0
prog = @invloop i=1:1:1000000 begin
    add!(x, one)
end

function binv()
    play!(prog)
    grad(x)[] = 1.0
    play!(prog')
end

using BenchmarkTools

@benchmark binv()

################ Zygote
using Zygote

function f(x, one, n::Int)
    for i=1:n
        x += one
    end
    return x
end

@benchmark gradient(f, 0.0, 1.0, 1000000)

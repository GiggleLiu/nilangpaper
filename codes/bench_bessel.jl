include("bessel.jl")
using BenchmarkTools, NiLang.AD
NiLang.invcheckon(false)

y!, x = Q20f43(0.0), Q20f43(3.0)
out = ibessel(y!, 2, x)
out = GVar.(out)
@instr grad(tget(out,1)) += identity(1)
@benchmark ($(~ibessel))($out...)

@benchmark ibessel(y!, 2, x)
@benchmark bessel(2, x)

using Zygote
@benchmark Zygote.gradient(x->bessel(2, x), x)

using ForwardDiff
@benchmark bessel(2, $(ForwardDiff.Dual(x)))

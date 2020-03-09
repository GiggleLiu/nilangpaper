include("bessel.jl")
using BenchmarkTools, NiLang.AD

display(@benchmark ibesselj(0.0, 2, 1.0))
display(@benchmark besselj(2, 1.0))

display(@benchmark NiLang.AD.gradient(Val(1), ibesselj, (0.0, 2, 1.0)))

using ReverseDiff
display(@benchmark ReverseDiff.gradient($(x->besselj(2, x[1])), $([1.0])))

using Zygote
display(@benchmark Zygote.gradient($(x->besselj(2, x)), 1.0))

using ForwardDiff
display(@benchmark besselj(2, ForwardDiff.Dual(1.0, 1.0)))

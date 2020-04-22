include("bessel.jl")
using BenchmarkTools, NiLang.AD

suite = BenchmarkGroup()
suite["NiLang"] = @benchmarkable ibesselj(0.0, 2, 1.0)

suite["Julia"] = @benchmarkable besselj(2, 1.0)

suite["NiLang.AD"] = @benchmarkable NiLang.AD.gradient(Val(1), ibesselj, (0.0, 2, 1.0))

using ReverseDiff
suite["ReverseDiff"] = @benchmarkable ReverseDiff.gradient($(x->besselj(2, x[1])), $([1.0]))

using Zygote
suite["Zygote"] = @benchmarkable Zygote.gradient($(x->besselj(2, x)), 1.0)

using ForwardDiff
suite["ForwardDiff"] = @benchmarkable besselj(2, ForwardDiff.Dual(1.0, 1.0))

tune!(suite)
res = run(suite)

function analyze_res(res)
    times = zeros(length(res))
    for (k, term) in enumerate(["Julia", "NiLang", "ForwardDiff", "NiLang.AD", "ReverseDiff", "Zygote"])
        times[k] = minimum(res[term].times)
    end
    return times
end

times = analyze_res(res)
using DelimitedFiles
writedlm(joinpath(dirname(dirname(@__FILE__)), "data", "bench_bessel.dat"), times)

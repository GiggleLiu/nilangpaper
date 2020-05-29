using Zygote
using ReverseDiff
using ForwardDiff
using BenchmarkTools

include("bessel.jl")

suite = BenchmarkGroup()
suite["NiLang"] = @benchmarkable ibesselj(0.0, 2, 1.0)
suite["Julia"] = @benchmarkable besselj(2, 1.0)
suite["NiLang.AD"] = @benchmarkable NiLang.AD.gradient(Val(1), ibesselj, (0.0, 2, 1.0))
suite["ReverseDiff"] = @benchmarkable ReverseDiff.gradient!(ctape, $(([1.0],))) setup=(ctape = ReverseDiff.compile(ReverseDiff.GradientTape(x->besselj(2, x[1]), ([1.0],))))
suite["Zygote"] = @benchmarkable Zygote.gradient($(x->besselj(2, x)), 1.0)
suite["ForwardDiff"] = @benchmarkable besselj(2, ForwardDiff.Dual(1.0, 1.0))
suite["Manual"] = @benchmarkable Grad(run_manual)(Val(1), 0.0, 2, 1.0)

tune!(suite)
res = run(suite)

function analyze_res(res)
    times = zeros(length(res))
    for (k, term) in enumerate(["Julia", "NiLang", "ForwardDiff", "NiLang.AD", "ReverseDiff", "Zygote", "Manual"])
        times[k] = minimum(res[term].times)
    end
    return times
end

times = analyze_res(res)
using DelimitedFiles
fname = joinpath(dirname(dirname(@__FILE__)), "data", "bench_bessel.dat")
println("Writing benchmark results to file: $fname.")
writedlm(fname, times)

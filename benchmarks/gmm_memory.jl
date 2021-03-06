using BenchmarkTools
using NiGaussianMixture
using ForwardDiff
using NiLang.AD

include("argparse.jl")
#datafolder = parse()["adbench-folder"]
datafolder = "/home/leo/jcode/ADBench"

function load(d, k)
    #dir_in = joinpath(dirname(dirname(@__FILE__)), "data", "gmm")
    #dir_in = joinpath(homedir(), "jcode", "ADBench", "data", "gmm")
    dir_in = joinpath(datafolder, "data", "gmm")
    dir_out = @__DIR__
    fn = joinpath("10k", "gmm_d$(d)_K$k")

    fn_in = joinpath(dir_in, fn)
    fn_out = joinpath(dir_out, fn)
    println("loading data: $(fn_in).txt")
    NiGaussianMixture.read_gmm_instance(string(fn_in,".txt"), false)
end

function get_fdobjective(x, wishart, d, k)
    function wrapper_gmm_objective(packed)
        alphas,means,icf = NiGaussianMixture.unpack(d,k,packed)
        gmm_objective(alphas,means,icf,x,wishart)
    end
end

suite = BenchmarkGroup()
cases = ["Julia", "NiLang", "NiLang-AD"]
for case in cases
    suite[case] = BenchmarkGroup()
end

for d = [2, 10, 20, 32, 64, 128], K = [5, 10, 25, 50, 100, 200]
    args = (d, K)
    alphas, means, icf, x, wishart = load(args...)
    params = NiGaussianMixture.pack(alphas,means,icf)
    println(d, " ", K, ", nparams = $(length(params))")
end

arglist = [(2, 5), (10, 5), (2, 200), (10, 50), (64, 5), (64, 10), (64, 25), (64, 200)]
for args in arglist
    alphas, means, icf, x, wishart = load(args...)
    params = NiGaussianMixture.pack(alphas,means,icf)
    println("nparams = $(length(params))")

    suite["Julia"][args] = @benchmarkable gmm_objective($alphas,$means,$icf,$x,$wishart)
    suite["NiLang"][args] = @benchmarkable gmm_objective(0.0, $alphas,$means,$icf,$x,$wishart)
    suite["NiLang-AD"][args] = @benchmarkable Grad(gmm_objective)(Val(1), 0.0, $alphas,$means,$icf,$x,$wishart)
end

tune!(suite)
res = run(suite)

function analyze_res(res)
    mems = zeros(length(arglist), length(cases)+1)
    for (k, term) in enumerate(cases)
        for (i,args) in enumerate(arglist)
	    if haskey(res[term], args)
            	mems[i,k] = res[term][args].memory
            end
        end
    end
    for (i,args) in enumerate(arglist)
        mems[i,length(cases)+1] = sum(sizeof, load(args...))
    end
    return mems
end

mems = analyze_res(res)
using DelimitedFiles
fname = joinpath(@__DIR__, "data", "bench_gmm_memory.dat")
println("Writing benchmark results to file: $fname.")
writedlm(fname, mems)

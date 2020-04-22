using BenchmarkTools
using NiGaussianMixture
using ForwardDiff

function load(d, k)
    #dir_in = joinpath(dirname(dirname(@__FILE__)), "data", "gmm")
    dir_in = joinpath(homedir(), "jcode/ADBench", "data", "gmm")
    dir_out = dirname(@__FILE__)
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
cases = ["Julia", "NiLang", "ForwardDiff", "NiLang-AD"]
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

    if length(params) < 5000
        fobj = get_fdobjective(x, wishart, size(x, 1), size(alphas, 2))
        suite["ForwardDiff"][args] = @benchmarkable ForwardDiff.gradient($fobj, $(params))
    end

    suite["NiLang-AD"][args] = @benchmarkable gmm_objective'(Val(1), 0.0, $alphas,$means,$icf,$x,$wishart)
end

tune!(suite)
res = run(suite)

function analyze_res(res)
    times = zeros(length(arglist), length(cases))
    for (k, term) in enumerate(cases)
        for (i,args) in enumerate(arglist)
	    if haskey(res[term], args)
            	times[i,k] = minimum(res[term][args].times)
            end
        end
    end
    return times
end

times = analyze_res(res)
using DelimitedFiles
writedlm(joinpath(dirname(@__FILE__), "data", "bench_gmm.dat"), times)

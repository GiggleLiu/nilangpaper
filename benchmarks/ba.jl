using BenchmarkTools
using NiBundleAdjustment
using NiBundleAdjustment: vec2cam, vec2scam, compute_reproj_err
using StaticArrays

include("argparse.jl")
datafolder = parse()["adbench-folder"]

function load(b, n, m, p)
    #dir_in = joinpath(dirname(dirname(@__FILE__)), "data", "ba")
    #dir_in = joinpath(homedir(), "jcode", "ADBench", "data", "ba")
    dir_in = joinpath(datafolder, "data", "ba")
    fn = "ba$(b)_n$(n)_m$(m)_p$(p)"
    fn_in = joinpath(dir_in, fn)
    println("loading data: $(fn_in).txt")
    NiBundleAdjustment.read_ba_instance(string(fn_in,".txt"))
end

suite = BenchmarkGroup()
cases = ["Julia", "NiLang", "ForwardDiff", "NiLang-AD"]
for case in cases
    suite[case] = BenchmarkGroup()
end

arglist = [(1,49,7776,31843), (4,372,47423,204472), (7,93,61203,287451), (10,1197,126327,563734), (13,245,198739,1091386), (16,1544,942409,4750193), (19,4585,1324582,9125125)]
for args in arglist
    cams, X, w, obs, feats = load(args...)
    CAMS = [vec2cam(cams[:,i]) for i = 1:size(cams,2)]
    SCAMS = [vec2scam(cams[:,i]) for i = 1:size(cams,2)]
    XX = [P3(X[:,i]...) for i=1:size(X,2)]
    FEATS = [P2(feats[:,1]...) for i=1:size(feats, 2)]
    suite["Julia"][args] = @benchmarkable NiBundleAdjustment.ba_objective($SCAMS, $X, $w, $obs, $feats)
    reproj_err! = zeros(P2{Float64}, size(feats, 2))
    w_err! = zero(w)
    reproj_err_cache! = zeros(P2{Float64}, size(feats, 2))
    suite["NiLang"][args] = @benchmarkable NiBundleAdjustment.ba_objective!($reproj_err!, $w_err!,
                $reproj_err_cache!, $CAMS, $XX, $w, $obs, $FEATS)
    suite["ForwardDiff"][args] = @benchmarkable compute_ba_J(Val(:ForwardDiff), $cams, $X, $w, $obs, $feats)
    suite["NiLang-AD"][args] = @benchmarkable compute_ba_J(Val(:NiLang), $CAMS, $XX, $w, $obs, $FEATS)
end

tune!(suite)
res = run(suite)

function analyze_res(res)
    times = zeros(length(arglist), length(cases))
    for (k, term) in enumerate(cases)
        for (i,args) in enumerate(arglist)
            times[i,k] = minimum(res[term][args].times)
        end
    end
    return times
end

times = analyze_res(res)
using DelimitedFiles
fname = joinpath(@__DIR__, "data", "bench_ba.dat")
println("Writing benchmark results to file: $fname.")
writedlm(fname, times)

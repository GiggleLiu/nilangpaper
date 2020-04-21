using BenchmarkTools
using NiBundleAdjustment
using NiBundleAdjustment: vec2cam, vec2scam, compute_reproj_err
using StaticArrays

function load(b, n, m, p)
    dir_in = joinpath(dirname(dirname(@__FILE__)), "data", "ba")
    fn = "ba$(b)_n$(n)_m$(m)_p$(p)"
    fn_in = joinpath(dir_in, fn)
    NiBundleAdjustment.read_ba_instance(string(fn_in,".txt"))
end

suite = BenchmarkGroup()
cases = ["Julia", "NiLang", "ForwardDiff", "NiLang-AD"]
for case in cases
    suite[case] = BenchmarkGroup()
end

arglist = [(4,372,47423,204472)]
for args in arglist
    cams, X, w, obs, feats = load(args...)
    CAMS = [vec2cam(cams[:,i]) for i = 1:size(cams,2)]
    XX = [P3(X[:,i]...) for i=1:size(X,2)]
    FEATS = [P2(feats[:,1]...) for i=1:size(feats, 2)]
    suite["Julia"][args] = @benchmarkable compute_reproj_err($(vec2scam(cams[:,1])), $(X[:,1]), $(w[1]), $(feats[:,1]))
    suite["NiLang"][args] = @benchmarkable compute_reproj_err($(P2(0.0, 0.0)), $(P2(0.0, 0.0)),
        $(CAMS[1]), $(XX[1]), $(w[1]), $(FEATS[1]))
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
writedlm(joinpath(dirname(@__FILE__), "bench_ba.dat"), times)

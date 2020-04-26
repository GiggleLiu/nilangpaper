using DelimitedFiles
using Printf

bares() = readdlm("data/bench_ba.dat")'./1e9
gmmres() = readdlm("data/bench_gmm.dat")'./1e9
geres() = readdlm("data/bench_graphembedding.dat")'./1e9
function tapenade_gmmres()
    arglist = [(2, 5), (10, 5), (2, 200), (10, 50), (64, 5), (64, 10), (64, 25), (64, 200)]
    res = zeros(Float64, 2, arglist |> length)
    for (i,(d, k)) in enumerate(arglist)
        dir_in = joinpath(@__DIR__, "Tapenade/gmm/10k/Tapenade")
        fn = "gmm_d$(d)_K$(k)_times_Tapenade.txt"
        fn_in = joinpath(dir_in, fn)
        res[:,i] = readdlm(fn_in)
    end
    res
end

function tapenade_bares()
    arglist = [(1,49,7776,31843), (4,372,47423,204472), (7,93,61203,287451), (10,1197,126327,563734), (13,245,198739,1091386), (16,1544,942409,4750193), (19,4585,1324582,9125125)]
    res = zeros(Float64, 2, arglist |> length)
    for (i,(b,n,m,p)) in enumerate(arglist)
        dir_in = joinpath(@__DIR__, "Tapenade/ba/Tapenade")
        fn = "ba$(b)_n$(n)_m$(m)_p$(p)_times_Tapenade.txt"
        fn_in = joinpath(dir_in, fn)
        res[:,i] = readdlm(fn_in)
    end
    res
end

function showres(res)
    for i=1:size(res,1) for j=1:size(res, 2)
        @printf "%.3e  " res[i,j] end
        println()
    end
end

function latexres(res)
    for i=1:size(res,1) for j=1:size(res, 2)
        token = j==size(res, 2) ? "\\\\" : "&"
        @printf "%.3e  %s " res[i,j] token end
        println()
    end
end

function formatres(res)
    map(x->(@sprintf "%.3e  " x), res)
end

using DelimitedFiles
using Printf

bares() = readdlm("bench_ba.dat")
gmmres() = readdlm("bench_gmm.dat")
function tapenade_bares()
    arglist = [(1,49,7776,31843), (4,372,47423,204472), (7,93,61203,287451), (10,1197,126327,563734), (13,245,198739,1091386), (16,1544,942409,4750193), (19,4585,1324582,9125125)]
    for args in arglist
    arglist = [(2, 5), (10, 5), (2, 200), (10, 50), (64, 5), (64, 10), (64, 25), (64, 200)]
    for args in arglist
end

function tapenade_bares()
    arglist = [(1,49,7776,31843), (4,372,47423,204472), (7,93,61203,287451), (10,1197,126327,563734), (13,245,198739,1091386), (16,1544,942409,4750193), (19,4585,1324582,9125125)]
    for args in arglist
    arglist = [(2, 5), (10, 5), (2, 200), (10, 50), (64, 5), (64, 10), (64, 25), (64, 200)]
    for args in arglist
end

function showres(res)
    for i=1:4 for j=1:size(res, 2)
        @printf "%.3e  " res[i,j] end
        println()
    end
end

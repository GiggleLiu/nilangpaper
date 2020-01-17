using NiLang, NiLang.AD
using DelimitedFiles
using BenchmarkTools
using Zygote

@i function prog(x, one, n::Int)
    for i=1:n
        x += identity(one)
    end
end

function f(x, one, n::Int)
    for i=1:n
        x += one
    end
    return x
end

function run()
    nmax = 5
    lst_nilang = zeros(nmax)
    lst_zygote = zeros(nmax)
    for i=1:nmax
        res = @benchmark Zygote.gradient(f, 0.0, 1.0, 1<<i)
        lst_zygote[i] = minimum(res.times)
        res = @benchmark NGrad{1}(prog)(Loss(0.0), 1.0, 1<<i)
        lst_nilang[i] = minimum(res.times)
    end
    writedlm("zygote.dat", lst_zygote)
    writedlm("nilang.dat", lst_nilang)
end

run()

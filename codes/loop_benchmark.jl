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

function run(nmax::Int)
    lst_forward = zeros(nmax)
    lst_nilang = zeros(nmax)
    lst_zygote = zeros(nmax)
    for i=1:nmax
        @show i
        res0 = @benchmark f(0.0, 1.0, 1<<$i) seconds = 1
        lst_forward[i] = minimum(res0.times)
        res1 = @benchmark Zygote.gradient(f, 0.0, 1.0, 1<<$i) seconds=1
        lst_zygote[i] = minimum(res1.times)
        res2 = @benchmark NGrad{1}(prog)(Loss(0.0), 1.0, 1<<$i) seconds=1
        lst_nilang[i] = minimum(res2.times)
    end
    writedlm("forward.dat", lst_forward)
    writedlm("zygote.dat", lst_zygote)
    writedlm("nilang.dat", lst_nilang)
end

run(20)

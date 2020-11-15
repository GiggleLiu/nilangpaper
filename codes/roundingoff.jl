# rounding error experiments

using NiLang
using LinearAlgebra
using Statistics

function e_matmul()
    is = 2:10
    errs = map(is) do i
        n = 1<<i
        A = randn(n, n)
        B = randn(n, n)
        C = zeros(n, n)
        NiLang.i_mul!(C, A, B)
        (~NiLang.i_mul!)(C, A, B)
        #expects = i * eps(Float64) * norm(A, 1) * norm(B, 1)
        #bA = BigFloat.(A)
        #bB = BigFloat.(B)
        #bC = BigFloat.(C)
        #mulerror = norm(bA*bB .- A*B, 1)
        res = sum(abs, C)
        #@show res, expects, mulerror
        res
    end
    return is, errs
end

is, errs = e_matmul()

using Plots
plot(1 .<< is, errs; yscale=:log10, xscale=:log10, label="error")
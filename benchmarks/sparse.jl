using NiLang.AD, NiLang
using SparseArrays
using SparseArrays: getcolptr

@i function imul!(C::StridedVecOrMat, A::AbstractSparseMatrix, B::StridedVector{T}, α::Number, β::Number) where T
    @safe size(A, 2) == size(B, 1) || throw(DimensionMismatch())
    @safe size(A, 1) == size(C, 1) || throw(DimensionMismatch())
    @safe size(B, 2) == size(C, 2) || throw(DimensionMismatch())
    nzv ← nonzeros(A)
    rv ← rowvals(A)
    if (β != 1, ~)
        @safe error("only β = 1 is supported, got β = $(β).")
    end
    # Here, we close the reversibility check inside the loop to increase performance
    @invcheckoff for k = 1:size(C, 2)
        @inbounds for col = 1:size(A, 2)
            αxj ← zero(T)
            αxj += B[col,k] * α
            for j = getcolptr(A)[col]:(getcolptr(A)[col + 1] - 1)
                C[rv[j], k] += nzv[j]*αxj
            end
            αxj -= B[col,k] * α
        end
    end
end

@i function idot(r::T, A::SparseMatrixCSC{T},B::SparseMatrixCSC{T}) where {T}
    m ← size(A, 1)
    n ← size(A, 2)
    @invcheckoff branch_keeper ← zeros(Bool, 2*m)
    @safe size(B) == (m,n) || throw(DimensionMismatch("matrices must have the same dimensions"))
    @invcheckoff @inbounds for j = 1:n
        ia1 ← A.colptr[j]
        ib1 ← B.colptr[j]
        ia2 ← A.colptr[j+1]
        ib2 ← B.colptr[j+1]
        ia ← ia1
        ib ← ib1
        @inbounds for i=1:ia2-ia1+ib2-ib1-1
            ra ← A.rowval[ia]
            rb ← B.rowval[ib]
            if (ra == rb, ~)
                r += A.nzval[ia]' * B.nzval[ib]
            end
            ## b move -> true, a move -> false
            branch_keeper[i] ⊻= ia == ia2-1 || ra > rb
            ra → A.rowval[ia]
            rb → B.rowval[ib]
            if (branch_keeper[i], ~)
                ib += identity(1)
            else
                ia += identity(1)
            end
        end
        ~@inbounds for i=1:ia2-ia1+ib2-ib1-1
            ## b move -> true, a move -> false
            branch_keeper[i] ⊻= ia == ia2-1 || A.rowval[ia] > B.rowval[ib]
            if (branch_keeper[i], ~)
                ib += identity(1)
            else
                ia += identity(1)
            end
        end
    end
    @invcheckoff branch_keeper → zeros(Bool, 2*m)
end

using BenchmarkTools
suite = BenchmarkGroup()
a = sprand(1000, 1000, 0.05);
b = sprand(1000, 1000, 0.05);
suite["Julia-dot"] = @benchmarkable SparseArrays.dot($a, $b)
suite["NiLang-dot"] = @benchmarkable idot(0.0, $a, $b)
suite["NiLang.AD-dot"] = @benchmarkable (~idot)($(GVar(SparseArrays.dot(a, b))), $(GVar(a)), $(GVar(b)))

A = sprand(ComplexF64, 1000, 1000, 0.05);
v = randn(ComplexF64, 1000);
out = zeros(ComplexF64, 1000);
suite["Julia-mul!"] = @benchmarkable SparseArrays.mul!($(copy(out)), $A, $v, 0.5+0im, 1)
suite["NiLang-mul!"] = @benchmarkable imul!($(copy(out)), $A, $v, 0.5+0im, 1)
suite["NiLang.AD-mul!"] = @benchmarkable (~imul!)($(GVar(SparseArrays.mul!((copy(out)), A, v, 0.5+0im, 1))), $(GVar(A)), $(GVar(v)), $(GVar(0.5+0.0im)), 1)

tune!(suite)
res = run(suite)

function analyze_res(res)
    cases = ["Julia-dot", "NiLang-dot", "NiLang.AD-dot", "Julia-mul!", "NiLang-mul!", "NiLang.AD-mul!"]
    times = zeros(length(cases))
    for (k, term) in enumerate(cases)
        times[k] = minimum(res[term].times)
    end
    return times
end

times = analyze_res(res)
using DelimitedFiles
fname = joinpath(@__DIR__, "data", "bench_sparse.dat")
println("Writing benchmark results to file: $fname.")
writedlm(fname, times)

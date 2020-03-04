using NiLang, NiLang.AD
using SparseArrays

# Frobenius dot/inner product: trace(A'B)
@i function dot(r::T, A::SparseMatrixCSC{T},B::SparseMatrixCSC{T}) where {T}
    @routine @invcheckoff begin
        m ← size(A, 1)
        n ← size(A, 2)
        branch_keeper ← zeros(Bool, 2*m)
    end
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
            # b move -> true, a move -> false
            branch_keeper[i] ⊻= ia == ia2-1 || ra > rb
            if (branch_keeper[i], ~)
                ib += identity(1)
            else
                ia += identity(1)
            end
        end

        ~@inbounds for i=1:ia2-ia1+ib2-ib1-1
            # b move -> true, a move -> false
            branch_keeper[i] ⊻= ia == ia2-1 || A.rowval[ia] > B.rowval[ib]
            if (branch_keeper[i], ~)
                ib += identity(1)
            else
                ia += identity(1)
            end
        end
    end
    ~@routine
end

a = sprand(1000, 1000, 0.01)
b = sprand(1000, 1000, 0.01)

using BenchmarkTools
@benchmark dot(0.0, a, b)
@benchmark SparseArrays.dot(a, b)
@benchmark (~dot)(GVar(0.0, 1.0), GVar.(a), GVar.(b))

using NiLang, NiLang.AD

"""matrix multiplication"""
function mm!(out!, A, B)
    M = size(A, 1)
    N = size(B, 2)
    K = size(A, 2)
    @assert K == size(B, 1)
    for j=1:N
        for i=1:M
            for k=1:K
                @inbounds out![i,j] += A[i,k] * B[k,j]
            end
        end
    end
end

"""reversible matrix multiplication"""
@i function imm!(out!, A, B)
    M ← size(A, 1)
    N ← size(B, 2)
    K ← size(A, 2)
    @safe @assert K == size(B, 1)
    for j=1:N
        for i=1:M
            for k=1:K
                @inbounds out![i,j] += A[i,k] * B[k,j]
            end
        end
    end
end

A = randn(100, 200)
B = randn(200, 300)
out! = randn(100, 300)
# 9ms
@benchmark mm!(out!, A, B)

A = randn(100, 200)
B = randn(200, 300)
out! = randn(100, 300)
# 20ms, due to the lack of optimization
@benchmark imm!(out!, A, B)

"""loss function for test."""
@i function loss!(res, out!, A, B)
    imm!(out!, A, B)
    res += identity(out![1, 1])
end

A = randn(100, 200)
B = randn(200, 300)
out! = randn(100, 300)

# 44ms, uncomputing costs 20ms, 24ms for obtaining gradients.
@benchmark loss!'(Loss(0.0), out!, A, B)

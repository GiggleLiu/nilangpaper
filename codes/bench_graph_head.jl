using NiLang, NiLang.AD
import ForwardDiff
using ForwardDiff: Dual
using Random
Random.seed!(2)

# bonds of a petersen graph
const L1 = [(1, 6), (2, 7), (3, 8), (4, 9), (5, 10),
    (1, 2), (2, 3), (3, 4), (4, 5), (1, 5), (6, 8),
    (8, 10), (7, 10), (7, 9), (6, 9)]

# disconnected bonds of a petersen graph
const L2 = [(1, 3), (1, 4), (1, 7), (1, 8), (1, 9),
    (1, 10), (2, 4), (2, 5), (2, 6), (2, 8), (2, 9),
    (2, 10), (3, 5), (3, 6), (3, 7), (3, 9), (3, 10),
    (4, 6), (4, 7), (4, 8), (4, 10), (5, 6), (5, 7),
    (5, 8), (5, 9), (6, 7), (6, 10), (7, 8), (8, 9),
    (9, 10)]

"""the mean value"""
@i function mean(out!, x)
    anc ← zero(out!)
    for i=1:length(x)
        anc += identity(x[i])
    end
    mulint(out!, length(x))
end

"""
    var_and_mean_sq(var!, mean!, sqv)

the variance and mean value from squared values.
"""
@i function var_and_mean_sq(var!, mean!, sqv::AbstractVector{T}) where T
    sqmean ← zero(mean!)
    @inbounds for i=1:length(sqv)
        mean! += sqv[i] ^ 0.5
        var! += identity(sqv[i])
    end
    divint(mean!, length(sqv))
    divint(var!, length(sqv))
    sqmean += mean! ^ 2
    var! -= identity(sqmean)
    sqmean -= mean! ^ 2
    mulint(var!, length(sqv))
    divint(var!, length(sqv)-1)
end

"""
Squared distance of two vertices.
"""
@i @inline function sqdistance(dist!, x1::AbstractVector{T}, x2::AbstractVector) where T
    @invcheckoff @inbounds for i=1:length(x1)
        x1[i] -= identity(x2[i])
        dist! += x1[i] ^ 2
        x1[i] += identity(x2[i])
    end
end

"""The loss of graph embedding problem."""
@i function embedding_loss(out!::T, x) where T
    v1 ← zero(T)
    m1 ← zero(T)
    v2 ← zero(T)
    m2 ← zero(T)
    diff ← zero(T)
    d1 ← zeros(T, length(L1))
    d2 ← zeros(T, length(L2))
    @routine @invcheckoff begin
        for i=1:length(L1)
            @inbounds sqdistance(d1[i], x[:,L1[i][1]],x[:,L1[i][2]])
        end
        for i=1:length(L2)
            @inbounds sqdistance(d2[i], x[:,L2[i][1]],x[:,L2[i][2]])
        end
        var_and_mean_sq(v1, m1, d1)
        var_and_mean_sq(v2, m2, d2)
        m1 -= identity(m2)
        m1 += identity(0.1)
    end
    out! += identity(v1)
    out! += identity(v2)
    if (m1 > 0, ~)
        # to ensure mean(v2) > mean(v1)
        # if mean(v1)+0.1 - mean(v2) > 0, punish it.
        out! += exp(m1)
        out! -= identity(1)
    end
    ~@routine
end

function get_hessian(params0::AbstractArray{T}) where T
    N = length(params0)
    params = Dual.(params0, zero(T))
    hes = zeros(T, N, N)
    for i=1:N
        @inbounds i !== 1 && (params[i-1] = Dual(params0[i-1], zero(T)))
        @inbounds params[i] = Dual(params0[i], one(T))
        res = gradient(Val(1), embedding_loss, (Dual(0.0, 0.0), params))[2]
        hes[:,i] .= vec(ForwardDiff.partials.(res, 1))
    end
    hes
end


################## irreversible ##################
using Statistics, LinearAlgebra
function myvar_and_mean(v)
    mv  = Statistics.mean(v)
    sum((v .- mv).^2)./(length(v)-1), mv
end

function relu(x::T) where T
    x > 0 ? x : zero(T)
end

function loss(x)
    a = [LinearAlgebra.norm(x[:,i]-x[:,j]) for (i, j) in L1]
    b = [LinearAlgebra.norm(x[:,i]-x[:,j]) for (i, j) in L2]
    va, ma = myvar_and_mean(a)
    vb, mb = myvar_and_mean(b)
    va + vb + exp(relu(-mb + ma + 0.1)) - 1
end

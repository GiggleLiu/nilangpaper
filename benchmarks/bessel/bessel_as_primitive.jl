using NiLang, NiLang.AD
using BenchmarkTools

function besselj(ν, z; atol=1e-8)
    k = 0
    s = (z/2)^ν / factorial(ν)
    out = s
    while abs(s) > atol
        k += 1
        s *= (-1) / k / (k+ν) * (z/2)^2
        out += s
    end
    out
end

@i function (_::MinusEq{typeof(besselj)})(out!::GVar{T}, ν, z::GVar) where T
    value(out!) -= besselj(ν, z)
    @routine @invcheckoff begin
        jac ← zero(T)
        jac += besselj(ν-1, value(z))
        jac -= besselj(ν+1, value(z))
        DIVINT(jac, 2)
    end
    grad(z) += jac * grad(out!)
    ~@routine
end

function (_::MinusEq{typeof(besselj)})(out!::GVar{T}, ν, z::GVar) where T
    @instr value(out!) -= besselj(ν, z)
    jac = (besselj(ν-1, value(z)) - besselj(ν+1, value(z)))/2
    @instr grad(z) += jac * grad(out!)
    return out!, ν, z
end

@i function test(out!, ν, z)
    out! += besselj(ν, z)
end

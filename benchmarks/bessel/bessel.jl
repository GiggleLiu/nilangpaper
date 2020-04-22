using NiLang, NiLang.AD

"""
    J(ν, z) := ∑ (−1)^k / Γ(k+1) / Γ(k+ν+1) * (z/2)^(ν+2k)
"""
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

"""
    imul(out!, x, anc!)

Reversible multiplication.
"""
@i @inline function imul(out!, x, anc!)
    anc! += out! * x
    out! -= anc! / x
    SWAP(out!, anc!)
end

@i @inline function imul(out!, x::Int, anc!::Int)
    anc! += out! * x
    out! -= anc! ÷ x
    SWAP(out!, anc!)
end

@i @inline function ifactorial(out!, n::Int)
    out! += identity(1)
    @routine @invcheckoff for i=1:n
        mulint(out!, i)
    end
end

@i function ibesselj(out!, ν, z; atol=1e-8)
    @routine @invcheckoff begin
        k ← 0
        fact_nu ← zero(ν)
        halfz ← zero(z)
        halfz_power_nu ← zero(z)
        halfz_power_2 ← zero(z)
        out_anc ← zero(z)
        anc1 ← zero(z)
        anc2 ← zero(z)
        anc3 ← zero(z)
        anc4 ← zero(z)
        anc5 ← zero(z)

        halfz += z / 2
        halfz_power_nu += halfz ^ ν
        halfz_power_2 += halfz ^ 2
        ifactorial(fact_nu, ν)

        anc1 += halfz_power_nu/fact_nu
        out_anc += identity(anc1)
        while (abs(unwrap(anc1)) > atol && abs(unwrap(anc4)) < atol, k!=0)
            k += identity(1)
            @routine begin
                anc5 += k + ν
                anc2 -= k * anc5
                anc3 += halfz_power_2 / anc2
            end
            imul(anc1, anc3, anc4)
            out_anc += identity(anc1)
            ~@routine
        end
    end
    out! += identity(out_anc)
    ~@routine
end

using ForwardDiff
using ForwardDiff: Dual
using BenchmarkTools


function btest(v, z)
    y, _, x = ibesselj(Dual(0.0, 0.0), 2, Dual(z, 1.0))
    ibesselj(GVar(y, one(y)), 2, GVar(z, zero(y)))
end

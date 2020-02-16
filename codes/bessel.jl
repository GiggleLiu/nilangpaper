using SpecialFunctions
using NiLang

using FixedPointNumbers
const F3232 = Fixed{Int64, 32}

"""
    J(ν, z) := ∑ (−1)^k / Γ(k+1) / Γ(k+ν+1) * (z/2)^(ν+2k)
"""
function bessel(ν, z; atol=1e-10)
    k = 0
    s = (z/2)^ν / gamma(ν+1)
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
@i function imul(out!, x, anc!)
    anc! += out! * x
    out! -= anc! / x
    SWAP(out!, anc!)
end

@i function imul(out!, x::Int, anc!::Int)
    anc! += out! * x
    out! -= anc! ÷ x
    SWAP(out!, anc!)
end

@i function ifactorial(out!, n)
    anc1 ← 1
    anc2 ← 0
    @routine for i=1:n
        imul(anc1, i, anc2)
    end
    out! += identity(anc1)
    ~@routine
end

@i function ibessel(out!, ν, z; atol=1e-8)
    k ← 0
    fact_nu ← 0
    halfz ← zero(z)
    halfz_power_nu ← zero(z)
    halfz_power_2 ← zero(z)
    out_anc ← zero(z)
    anc1 ← zero(z)
    anc2 ← zero(z)
    anc3 ← zero(z)
    anc4 ← zero(z)
    anc5 ← zero(z)

    @routine begin
        halfz += z/2
        halfz_power_nu += halfz ^ ν
        halfz_power_2 += halfz ^ 2
        ifactorial(fact_nu, ν)

        anc1 += halfz_power_nu/fact_nu
        out_anc += identity(anc1)
        while (abs(value(anc1)) > atol && abs(value(anc4)) < atol, k!=0)
            k += identity(1)
            @routine begin
                anc5 += identity(k)
                anc5 += identity(ν)
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

using BenchmarkTools, NiLang.AD
@benchmark ibessel'(Loss(0.0), 2, 3.0)

@benchmark ibessel(0.0, 2, 3.0)
@benchmark bessel(2, 3.0)

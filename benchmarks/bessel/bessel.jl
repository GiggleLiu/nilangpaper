using NiLang, NiLang.AD
using ForwardDiff
using ForwardDiff: Dual
using BenchmarkTools


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

@i function ibesselj(out!::T, ν::Int, z::T; atol=1e-8) where T
    @routine @invcheckoff begin
        @zeros Int fact_nu, k
        @zeros T anc1 anc2 anc3 anc4 anc5 out_anc halfz_power_2 halfz_power_nu halfz

        halfz += z / 2
        halfz_power_nu += halfz ^ ν
        halfz_power_2 += halfz ^ 2
        ifactorial(fact_nu, ν)

        anc1 += halfz_power_nu/fact_nu
        out_anc += anc1
        while (abs(unwrap(anc1)) > atol && abs(unwrap(anc4)) < atol, k!=0)
            k += 1
            @routine begin
                anc5 += k + ν
                anc2 -= k * anc5
                anc3 += halfz_power_2 / anc2
            end
            imul(anc1, anc3, anc4)
            out_anc += anc1
            ~@routine
        end
    end
    out! += 1
    ~@routine
end

@i function ibesselj2(y!::T, ν, z::T; atol=1e-8) where T
	if z == 0
		if v == 0
			out! += 1
		end
	else
		@routine @invcheckoff begin
			k ← 0
			@ones ULogarithmic{T} lz halfz halfz_power_2 s
			@zeros T out_anc
			lz *= convert(z)
			halfz *= lz / 2
			halfz_power_2 *= halfz ^ 2
			## s *= (z/2)^ν/ factorial(ν)
			s *= halfz ^ ν
			for i=1:ν
				s /= i
			end
			out_anc += convert(s)
			while (s.log > -25, k!=0) # upto precision e^-25
				k += 1
				## s *= 1 / k / (k+ν) * (z/2)^2
				s *= halfz_power_2 / (k*(k+ν))
				if k%2 == 0
					out_anc += convert(s)
				else
					out_anc -= convert(s)
				end
			end
		end
		y! += out_anc
		~@routine
	end
end

function btest(v, z)
    y, _, x = ibesselj(Dual(0.0, 0.0), 2, Dual(z, 1.0))
    ibesselj(GVar(y, one(y)), 2, GVar(z, zero(y)))
end


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

@noinline function (_::MinusEq{typeof(besselj)})(out!::GVar{T}, ν::Real, z::GVar{T}) where T
    vout = value(out!) - besselj(ν, value(z))
    jac = (besselj(ν-1, value(z)) - besselj(ν+1, value(z)))/2
    gz = grad(z) + jac * grad(out!)
    return GVar(vout, grad(out!)), ν, GVar(value(z), gz)
end

@i function run_manual(out!, ν, z)
    out! += besselj(ν, z)
end

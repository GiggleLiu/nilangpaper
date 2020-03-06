using NiLang, NiLang.AD
using CuArrays, GPUArrays, KernelAbstractions

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

@i function ifactorial(out!, n::Int)
    out! += identity(1)
    @invcheckoff for i=1:n
        mulint(out!, i)
    end
end

@i function ibesselj(out!, ν::Integer, z; atol=1e-8)
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

@i @kernel function bessel_kernel(out!, v, z)
    @invcheckoff i ← @index(Global)
    ibesselj(out![i], v, z[i])
    @invcheckoff i → @index(Global)
end

@i function befunc(out!, v::Integer, z)
    @invcheckoff res ← bessel_kernel(CUDA(), 256)(out!, v, z; ndrange=length(out!))
    @safe wait(res)
    @invcheckoff res → (~bessel_kernel)(CUDA(), 256)(out!, v, z; ndrange=length(out!))
    # shorthand -
    # @launchkernel CUDA() 256 length(out!) bessel_kernel(out!, v, z)
end

N = 4096
T = Float32
out! = zeros(T,N) |> CuArray
z = ones(T,N) |> CuArray
befunc(out!, 2, z)
out_g = GVar.(out!, CuArray(ones(T, N)))
z_g = GVar.(z)
(~befunc)(out_g, 2, z_g)
using BenchmarkTools
@benchmark CuArrays.@sync (~befunc)($out_g, 2, $z_g)

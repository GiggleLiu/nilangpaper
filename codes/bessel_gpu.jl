using NiLang, NiLang.AD
using CuArrays, CUDAnative, GPUArrays

@i @inline function ⊖(CUDAnative.pow)(out!::GVar{T}, x::GVar, n::GVar) where T
    ⊖(CUDAnative.pow)(value(out!), value(x), value(n))

    # grad x
    @routine @invcheckoff begin
        anc1 ← zero(value(x))
        anc2 ← zero(value(x))
        anc3 ← zero(value(x))
        jac1 ← zero(value(x))
        jac2 ← zero(value(x))

        value(n) -= identity(1)
        anc1 += CUDAnative.pow(value(x), value(n))
        value(n) += identity(1)
        jac1 += anc1 * value(n)

        # get grad of n
        anc2 += log(value(x))
        anc3 += CUDAnative.pow(value(x), value(n))
        jac2 += anc3*anc2
    end
    grad(x) += grad(out!) * jac1
    grad(n) += grad(out!) * jac2
    ~@routine
end

@i @inline function ⊖(CUDAnative.pow)(out!::GVar{T}, x::GVar, n) where T
    ⊖(CUDAnative.pow)(value(out!), value(x), n)
    @routine @invcheckoff begin
        anc1 ← zero(value(x))
        jac ← zero(value(x))

        value(n) -= identity(1)
        anc1 += CUDAnative.pow(value(x), n)
        value(n) += identity(1)
        jac += anc1 * n
    end
    grad(x) += grad(out!) * jac
    ~@routine
end

@i @inline function ⊖(CUDAnative.pow)(out!::GVar{T}, x, n::GVar) where T
    ⊖(CUDAnative.pow)(value(out!), x, value(n))
    # get jac of n
    @routine @invcheckoff begin
        anc1 ← zero(x)
        anc2 ← zero(x)
        jac ← zero(x)

        anc1 += log(x)
        anc2 += CUDAnative.pow(x, value(n))
        jac += anc1*anc2
    end
    grad(n) += grad(out!) * jac
    ~@routine
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

@i function ifactorial(out!, n::Int)
    out! += identity(1)
    @invcheckoff for i=1:n
        MULINT(out!, i)
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
        halfz_power_nu += CUDAnative.pow(halfz, ν)
        halfz_power_2 += CUDAnative.pow(halfz, 2)
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

@i function ibesselj_kernel(out!, ν, z, atol)
    i ← (blockIdx().x-1) * blockDim().x + threadIdx().x
    @inbounds ibesselj(out![i], ν, z[i]; atol=atol)
    @invcheckoff i → (blockIdx().x-1) * blockDim().x + threadIdx().x
end

@i function ibesselj(out!::CuVector, ν, z::CuVector; atol=1e-8)
   XY ← GPUArrays.thread_blocks_heuristic(length(out!))
   @cuda threads=tget(XY,1) blocks=tget(XY,2) ibesselj_kernel(out!, ν, z, atol)
   @invcheckoff XY → GPUArrays.thread_blocks_heuristic(length(out!))
end


#y, x = 0.0, 1.0
#y_out = ibesselj(y, 2, x)[1]
using BenchmarkTools
#@benchmark ibesselj($y, 2, $x)
#@benchmark (~ibesselj)($(GVar(y_out, 1.0)), 2, $(GVar(1.0, 0.0)))

a = CuArray(ones(128))
out! = CuArray(zeros(128))
out! = ibesselj(out!, 2, GVar.(a))[1]
out_g! = GVar.(out!, CuArray(ones(128)))
Inv(ibesselj)(out_g!, 2, GVar.(a))

using NiLang, NiLang.AD

@i function umm!(x!, θ)
    @safe @assert length(θ) == length(x!) * (length(x)-1) / 2
    @anc k = 0
    for j=1:length(x!)
        for i=length(x!)-1:-1:j
            k += identity(1)
            ROT(x![i], x![i+1], θ[k])
        end
    end

    # uncompute k
    @deanc k = length(θ)
end

@i function isum(out!, x::Vector)
    for i=1:length(x)
        out! += identity(x[i])
    end
end

@i function test!(out!, x!::Vector, θ::Vector)
    umm!(x!, θ)
    isum(out!, x!)
end

out, x, θ = Loss(0.0), randn(4), randn(6);
x
@instr test!'(out, x, θ)
x
@instr (~test!')(out, x, θ)
x

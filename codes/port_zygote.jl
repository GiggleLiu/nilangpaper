using Zygote, NiLang, NiLang.AD, BenchmarkTools, LinearAlgebra

x = randn(1000);
@benchmark norm'(x)

@i function r_norm(out::T, out2::T, x::AbstractArray{T}) where T
   for i=1:length(x)
       @inbounds out2 += x[i]^2
   end
   out += sqrt(out2)
end

Zygote.@adjoint function norm(x::AbstractArray{T}) where T
   # compute the forward with regular norm (might be faster)
   out = norm(x)
   # compute the backward with NiLang's norm, element type is GVar
   out, δy -> (grad((~r_norm)(GVar(out, δy), GVar(out^2), GVar(x))[3]),)
end

@benchmark norm'(x)

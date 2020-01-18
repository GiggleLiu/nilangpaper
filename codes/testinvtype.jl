using NiLangCore

struct DVar{T}
    x::T
    g::T
end

@iconstruct function DVar(xx, gg=zero(xx))
    gg += identity(xx)
end

(~DVar)(DVar(0.5)) == 0.5

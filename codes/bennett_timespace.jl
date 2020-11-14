using NiLang

closetoint(x) = isapprox(x-round(x), 0; atol=1e-12)

PROG_COUNTER = Ref(0)   # (2k-1)^n
PEAK_MEM = Ref(0)    # n*(k-1)+2

@i function bennett(f::AbstractVector, state::Dict{Int,T}, k::Int, base, len) where T
    if len == 1
        state[base+1] ← zero(T)
        f[base](state[base+1], state[base])
        @safe PROG_COUNTER[] += 1
        @safe (length(state) > PEAK_MEM[] && (PEAK_MEM[] = length(state)))
    else
        n ← 0
        n += len÷k
        for j=1:k
            bennett(f, state, k, base+n*(j-1), n)
        end
        for j=k-1:-1:1
            ~bennett(f, state, k, base+n*(j-1), n)
        end
        n -= len÷k
        n → 0
    end
end

using Test
k = 4
n = 4
N = k^n
#state = (x = zeros(N+1); x[1]=100; x)
state = Dict(1=>100.0)

f(x) = x+2
instructions = fill(⊕(f), N)
@instr bennett(instructions, state, k, 1, N)
#@test state ≈ (x = zeros(N+1); x[1]=100; x[end]=let y=100; for i=1:N y=f(y) end; y end; x)
@test state[1] ≈ 100
@test length(state) == 2
@test state[N+1] ≈ let y=100; for i=1:N y=f(y) end; y end

@test PEAK_MEM[] == n*(k-1) + 2
@test PROG_COUNTER[] == (2*k-1)^n

@instr ~bennett(instructions, state, k, 1, N)
@test state[1] ≈ 100.0
@test length(state) == 1
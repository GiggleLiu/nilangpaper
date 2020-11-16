using NBodyLeapFrog, NiLang, DoubleFloats, DelimitedFiles

# patch
for OP in [:PlusEq, :Mis]
    function (f::PlusEq{typeof(/)})(x::Double64, y::Double64, z::Double64)
        (x+y/z), y, z
    end
    function (f::MinusEq{typeof(/)})(x::Double64, y::Double64, z::Double64)
        (x-y/z), y, z
    end
end

function convertelems(::Type{T}, b::Body) where T
    Body(
        V3(T(b.r.x), T(b.r.y), T(b.r.z)),
        V3(T(b.v.x), T(b.v.y), T(b.v.z)),
        T(b.m)
    )
end

function simulate(::Type{T1}, f, planets, k::Int) where T1
	nplanets = length(planets)
	n = (1<<k) + 1
	r, v = f(convertelems.(T1, planets); n = n, dt = T1(0.01), G=T1(NBodyLeapFrog.G_year_AU))
	r[:,end]
end

function rsimulate(::Type{T1}, f, planets, k::Int) where T1
	nplanets = length(planets)
	n = (1<<k) + 1
	v1 = zeros(V3{T1}, nplanets)
	r1 = zeros(V3{T1}, nplanets)
	r, v, p = f(r1, v1, convertelems.(T1, planets); n = n, dt = T1(0.01), G=T1(NBodyLeapFrog.G_year_AU))
	r
end

function errors(r, rref)
	sum(NBodyLeapFrog.distance.(r, rref))/length(r)
end

function generate(planets, logns)
	r_Double64 = simulate.(Double64, NBodyLeapFrog.fast_leapfrog, Ref(planets), logns)
    Ts = [Float32, Float64]
    els = zeros(length(logns), 3*length(Ts))
	for (i, T) in enumerate(Ts)
		rt = rsimulate.(T, NBodyLeapFrog.i_leapfrog, Ref(planets), logns)
		rt_reuse = rsimulate.(T, NBodyLeapFrog.i_leapfrog_reuse, Ref(planets), logns)
		irt = simulate.(T, NBodyLeapFrog.fast_leapfrog, Ref(planets), logns)
		els[:,3i-2] = errors.(r_Double64, irt)
		els[:,3i-1] = errors.(r_Double64, rt)
		els[:,3i] = errors.(r_Double64, rt_reuse)
	end
	els
end

planets = Bodies.chunit_day2year.(Bodies.set)
@time els = generate(planets, 2:20)
writedlm(joinpath(@__DIR__, "leapfrog_errors.dat"), els)
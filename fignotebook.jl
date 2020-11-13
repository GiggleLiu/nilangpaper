### A Pluto.jl notebook ###
# v0.12.7

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ aa970ba4-23b7-11eb-3e8d-f5079f5eaa38
using Viznet, Compose, PlutoUI

# ╔═╡ 798a5334-23f5-11eb-327d-37fe1aa7383e
using SpecialFunctions

# ╔═╡ d23d59f6-255b-11eb-16b0-c312f35751ab
using LaTeXStrings

# ╔═╡ 3cd3e2ea-255b-11eb-0719-55f0aee7ba32
using Plots

# ╔═╡ 217ef116-23c0-11eb-2d9a-31f5ea3e5fc9
Compose.set_default_graphic_size(10cm, 10cm)

# ╔═╡ fb579d5c-23e8-11eb-3f5f-d5e628b4d0ff
r = 0.1

# ╔═╡ 24869db0-23e9-11eb-0e7d-cf8a2a9333d9
ucurve = compose(context(), curve((0.0, 0.0), (0.1, -0.3), (0.9, -0.3), (1.0,0.0)), arrow(), linewidth(0.3mm), stroke("black"));

# ╔═╡ 73db6768-23e9-11eb-1626-d749c5d85b98
dcurve = compose(context(), curve((0.0, 0.0), (-0.1, 0.3), (1.1, 0.3), (1.0,0.0)), arrow(), linewidth(0.3mm), stroke("black"));

# ╔═╡ 7819f96c-23e8-11eb-333b-890d927bd5b1
function single(n, k; fsize=14pt)
	tb = textstyle(:default, fontsize(fsize), font("Prociono"));
	nb = nodestyle(:default);
	mb = nodestyle(:default, stroke("black"), fill("white"));
	canvas() do
		for i=1:k
			if i==1 || i==k
				nb >> ((i-0.5)/k, 0.5)
			else
				mb >> ((i-0.5)/k, 0.5)
			end
		end
		for i=1:k-1
			ucurve >> (((i-0.4)/k, 0.5-r), ((i+0.4)/k, 0.5-r))
			tb >> ((i/k, 0.5-4r), "P$n")
		end
		for i=1:k-2
			dcurve >> (((i+0.4)/k, 0.5+r), ((i-0.4)/k, 0.5+r))
			tb >> ((i/k, 0.5+4r), "Q$n")
		end
	end
end

# ╔═╡ 941b1560-23f2-11eb-398d-0314d4cb39e5
function svgstring(c::Context)
	io = IOBuffer()
	SVG(io, Compose.default_graphic_width, Compose.default_graphic_height, true, :none)(c)
	String(take!(io))
end

# ╔═╡ c6f39474-23ef-11eb-3a4d-552d2268f113
function bigarrow(start, stop, args...; width=nothing, head_width=nothing, head_length=nothing)
	h = (stop .- start)
	len = sqrt(h[1]^2 + h[2]^2)
	if width===nothing width = 0.1*len end
	if head_width===nothing head_width = 2*width end
	if head_length===nothing head_length = head_width end
	h = h ./ len
	v = (h[2], h[1])
	s1 = start .- v .* (width/2)
	s2 = start .+ v .* (width/2)
	neck = start .+ h .* (len - head_length)
	s3 = neck .+ v .* (width/2)
	s4 = neck .+ v .* (head_width/2)
	s5=stop
	s6 = neck .- v .* (head_width/2)
	s7 = neck .- v .* (width/2)
	compose(context(), polygon([s1, s2, s3, s4, s5, s6, s7]), args...)
end

# ╔═╡ 923a0ed6-23e8-11eb-165a-93043f71c4eb
function vizfig1()
	compose(context(),
		compose(context(0.2, 0.15, 0.6, 0.3), single(1, 4)),
		compose(context(0.0, 0.5, 1.0, 0.5), single(2, 4)),
		compose(context(), polygon([(1.5/4, 0.75), (2.5/4, 0.75), (0.2+3.5/4*0.6, 0.3), (0.2+0.5/4*0.6, 0.3)]), fill("#AAAAAA"), fillopacity(0.5)),
		compose(context(), polygon([(0.5-1/8, 0.1), (0.5+1/8, 0.1), (0.2+2.5/4*0.6, 0.3), (0.2+1.5/4*0.6, 0.3)]), fill("#AAAAAA"), fillopacity(0.5)),
		compose(context(), text(0.5, 0.07, "..."), fontsize(16pt), font("Prociono")),
		#compose(context(), bigarrow((0.95, 0.3), (0.95, 0.8); width=0.02)),
		#compose(context(), text(0.94, 0.25, "n"), fontsize(20pt), font("Prociono")),
	)
end

# ╔═╡ 3fa11aa6-23f3-11eb-2ca1-0f1560df5c4f
md"$(@bind save1 CheckBox(default=false))
save"

# ╔═╡ 4d32efda-2457-11eb-231e-db1e370cffb9
binomial(n, r) = gamma(n+1)/gamma(n-r+1)/gamma(r+1)

# ╔═╡ 888cd44c-2481-11eb-18da-49298a3ecc06
aline = compose(context(), line([(0.0,0.0), (1.0, 0.0)]), arrow(), linewidth(0.3mm), stroke("black"));

# ╔═╡ 404449a8-2487-11eb-1bea-419ea49785eb
function compute_locs(n, k)
	locs = cumsum([1.0,[binomial(n+i, i) for i=k:-1:1]...])
	N = locs[end]
	locs .= (locs .- 0.5) ./ N
end

# ╔═╡ 5338c4ba-247f-11eb-01dc-63d00ff46c84
function cpsingle(n, k; symn="t", fsize=12pt)
	tb = textstyle(:default, fontsize(fsize), font("Prociono"));
	nb = nodestyle(:default, r=0.025);
	mb = nodestyle(:default, stroke("black"), fill("white"), r=0.025);
	locs = compute_locs(n, k)
	#return (locs .- 0.5) ./ N
	canvas() do
		for i=1:k+1
			(i==k+1 ? mb : nb) >> (locs[i], 0.5)
		end
		for i=1:k
			aline >> ((locs[i]+r/3, 0.5), (locs[i+1]-r/2, 0.5))
			tb >> (((locs[i] + locs[i+1]) / 2, 0.35), "η($symn, $(k-i+1))")
		end
	end
end

# ╔═╡ 5d70b56e-247f-11eb-1657-fd514b3d76de
cpsingle(3, 3)

# ╔═╡ e05a00ac-2484-11eb-2e38-df62e44b89e2
function vizfig2()
	locs1 = compute_locs(3,3)
	locs2 = compute_locs(2,2)
	fig2 = compose(context(0.1, 0.0, 0.8, 1.0),
		compose(context(0.4, 0.15, 0.6, 0.3), cpsingle(2, 2, symn="t-1")),
		compose(context(0.0, 0.5, 1.0, 0.5), cpsingle(3, 3, symn="t")),
		compose(context(), polygon([(locs1[2], 0.75), (locs1[3], 0.75), (0.4+locs2[3]*0.6, 0.3), (0.4+locs2[1]*0.6, 0.3)]), fill("#AAAAAA"), fillopacity(0.5)),
		compose(context(), polygon([(0.5-1/8, 0.1), (0.5+3/9, 0.1), (0.4+locs2[2]*0.6, 0.3), (0.2+1.5/4*0.6, 0.3)]), fill("#AAAAAA"), fillopacity(0.5)),
		compose(context(), text(0.6, 0.07, "..."), fontsize(16pt), font("Prociono")),
	)
end

# ╔═╡ 7238e9a2-2488-11eb-30f7-11d8461ca7e6
function vizfig()
	Compose.set_default_graphic_size(18cm, 8cm)
	compose(context(),
		(context(), text(0.05, 0.1, "(a)"), fontsize(16pt)),
		(context(), text(0.55, 0.1, "(b)"), fontsize(16pt)),
		(context(0.5, 0, 0.5, 1.0), vizfig1()),
		(context(0., 0.05, 0.5, 1.0), vizfig2())
	)
end

# ╔═╡ ad418fdc-2489-11eb-2944-135b6a601508
vizfig()

# ╔═╡ 9e3063aa-23f2-11eb-1aa6-abd1798fb58b
#DownloadButton(svgstring(fig1), "fig1.svg")
if save1
	name = "tradeoff"
	fname = joinpath(@__DIR__, "$name")
	save1 && (vizfig() |> SVG("$fname.svg"))
	run(`rsvg-convert -f pdf -o $fname.pdf $fname.svg`)
end;

# ╔═╡ 00bd1166-2458-11eb-0a35-d191d4755097
@bind d Slider(2:10; default=3)

# ╔═╡ 070125e6-2458-11eb-22ec-a1286f223e7f
@bind t Slider(2:100; default=5)

# ╔═╡ 60c4c1ec-2457-11eb-3192-8be6539f6d43
T = binomial(t+d, d)

# ╔═╡ 52dc1dfe-2458-11eb-2e28-13d14eb2e233
T2 = sum(i->(i*(t-i)*(t-i+1)/2), 1:t-1)

# ╔═╡ 65e53e10-245a-11eb-2150-cf3778bde758
T3 = t^4/24 + t^3/12 - t^2/24

# ╔═╡ 0ae08c16-245c-11eb-1974-5b89a7f3aa22
T3/T2

# ╔═╡ 48d80472-2461-11eb-30eb-53a078e8b473
@bind k Slider(2:0.1:100)

# ╔═╡ 40d9277e-2461-11eb-17e4-79541f03454d
c = (k-1)/log(k)

# ╔═╡ 71862cf0-2461-11eb-026a-251247c6aae6
ϵ = log(2-1/k)/log(k)

# ╔═╡ 2234a36a-2473-11eb-0fe8-b1e1bdf74311
function drawtick(tick, d, t; n=-2, base=0)
	t <-1 && return
	n >=0 && tick >> (((base+0.5)/56, 0.8-0.1*n), ((base+0.5)/56, 0.7-0.1*n))
	for k=1:d
		δ = d-k+1
		#tick >> (((i-0.5)/56, 0.8-0.1*n), ((i-0.5)/56, 0.7-0.1*n))
		drawtick(tick, d-k+1, t-1; n=n+1, base=base)
		base += binomial(δ + t, δ)
	end
end

# ╔═╡ f927a77a-246f-11eb-2f89-45534c64dcaa
function checkpointing()
	Compose.set_default_graphic_size(14cm, 4cm)
	c = nodestyle(:circle, r=0.003)
	tick = bondstyle(:default, linewidth(0.1mm))
	canvas() do
		for i=1:56
			c >> ((i-0.5)/56, 0.8)
		end
		drawtick(tick, 3, 5)
	end
end

# ╔═╡ bcbb19f0-2471-11eb-3b55-7bab89dd150c
checkpointing()

# ╔═╡ 35ba78e0-255c-11eb-0acf-c57462db9a0a
L"x^2"

# ╔═╡ e62025da-255a-11eb-0549-7d965c5b00e5
function vizad()
	compose(context(),
		text(0.2, 0.2, "original program"),
		text(0.2, 0.5, "reversed program"),
		text(0.4, 0.4, L"\frac{\partial[single_input]}{\partial[multiple_output]}")
		)
end

# ╔═╡ Cell order:
# ╠═aa970ba4-23b7-11eb-3e8d-f5079f5eaa38
# ╠═217ef116-23c0-11eb-2d9a-31f5ea3e5fc9
# ╠═fb579d5c-23e8-11eb-3f5f-d5e628b4d0ff
# ╠═24869db0-23e9-11eb-0e7d-cf8a2a9333d9
# ╠═73db6768-23e9-11eb-1626-d749c5d85b98
# ╠═7819f96c-23e8-11eb-333b-890d927bd5b1
# ╠═941b1560-23f2-11eb-398d-0314d4cb39e5
# ╠═c6f39474-23ef-11eb-3a4d-552d2268f113
# ╠═923a0ed6-23e8-11eb-165a-93043f71c4eb
# ╠═7238e9a2-2488-11eb-30f7-11d8461ca7e6
# ╠═ad418fdc-2489-11eb-2944-135b6a601508
# ╟─3fa11aa6-23f3-11eb-2ca1-0f1560df5c4f
# ╠═9e3063aa-23f2-11eb-1aa6-abd1798fb58b
# ╠═798a5334-23f5-11eb-327d-37fe1aa7383e
# ╠═4d32efda-2457-11eb-231e-db1e370cffb9
# ╠═888cd44c-2481-11eb-18da-49298a3ecc06
# ╠═404449a8-2487-11eb-1bea-419ea49785eb
# ╠═5338c4ba-247f-11eb-01dc-63d00ff46c84
# ╠═5d70b56e-247f-11eb-1657-fd514b3d76de
# ╠═e05a00ac-2484-11eb-2e38-df62e44b89e2
# ╠═00bd1166-2458-11eb-0a35-d191d4755097
# ╠═070125e6-2458-11eb-22ec-a1286f223e7f
# ╠═60c4c1ec-2457-11eb-3192-8be6539f6d43
# ╠═52dc1dfe-2458-11eb-2e28-13d14eb2e233
# ╠═65e53e10-245a-11eb-2150-cf3778bde758
# ╠═0ae08c16-245c-11eb-1974-5b89a7f3aa22
# ╠═48d80472-2461-11eb-30eb-53a078e8b473
# ╠═40d9277e-2461-11eb-17e4-79541f03454d
# ╠═71862cf0-2461-11eb-026a-251247c6aae6
# ╠═2234a36a-2473-11eb-0fe8-b1e1bdf74311
# ╠═f927a77a-246f-11eb-2f89-45534c64dcaa
# ╠═bcbb19f0-2471-11eb-3b55-7bab89dd150c
# ╠═d23d59f6-255b-11eb-16b0-c312f35751ab
# ╠═35ba78e0-255c-11eb-0acf-c57462db9a0a
# ╠═e62025da-255a-11eb-0549-7d965c5b00e5
# ╠═3cd3e2ea-255b-11eb-0719-55f0aee7ba32

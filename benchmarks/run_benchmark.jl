using ArgParse

s = ArgParseSettings(description="""Run benchmarks,
e.g.
\$ julia --project run_benchmark.jl --adbench-folder ../ADBench GMM
\$ julia --project run_benchmark.jl --adbench-folder ../ADBench BA
\$ julia --project run_benchmark.jl Bessel
\$ julia --project run_benchmark.jl GE

Here, `GE` is graph embedding, `GMM` is Gaussian mixture model,
    `BA` is bundle adjustment.
""")

@add_arg_table! s begin
    "--adbench-folder"
    "objective"
end

res = parse_args(s)
obj = res["objective"]
if obj == "BA"
    println("Benchmarking Bundle Adjustment...")
    include("ba.jl")
elseif obj == "GMM"
    println("Benchmarking Gaussian Mixture Model...")
    include("gmm.jl")
elseif obj == "GE"
    println("Benchmarking Graph Embedding...")
    include("graphembedding.jl")
elseif obj == "Bessel"
    println("Benchmarking the First Kind Bessel Function...")
    include("bessel/julia_benchmark.jl")
else
    error("unkown objective: $obj, must be one of `GMM`, `BA`, `GE` and `Bessel`.")
end

include("argparse.jl")
obj = parse()["objective"]

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

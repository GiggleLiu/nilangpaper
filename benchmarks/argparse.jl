using ArgParse

function parse()
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
    return parse_args(s)
end

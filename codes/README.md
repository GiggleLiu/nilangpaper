# To Whom want to review the benchmarks

TensorFlow and PyTorch benchmarks are in `loop_benchmark.py`.
Clone this repo, enter this folder and type in a bash
```bash
$ pytest loop_benchmark.py
```
to execute the benchmark. Results are shown in json files in `.benchmarks/` folder.

Zygote and NiLang benchmarks are in `loop_benchmark.jl`.
Type 
```bash
$ julia loop_benchmark.jl
```
to execute the benchmark. Results are shown in `*.dat` files under this folder.

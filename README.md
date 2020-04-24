#  Reversible AD paper

To start
```bash
$ latexmk -pdf invc.tex
```

For benchmarks, type
```bash
$ cd benchmarks
$ julia --project run_benchmark.jl --adbench-folder path/to/ADBench GMM
$ julia --project run_benchmark.jl --adbench-folder path/to/ADBench BA
$ julia --project run_benchmark.jl Bessel
$ julia --project run_benchmark.jl GE
```
Some of the benchmarks requires cloning [ADBench](https://github.com/microsoft/ADBench).

To run the Tapenade benchmark for Bessel function, one should have a gfortran compiler. The benchmark can be execute by typing
```bash
$ cd benchmarks/bessel
$ make
$ ./main.out
```

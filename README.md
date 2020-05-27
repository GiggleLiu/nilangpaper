#  Reversible AD paper

## Compile latex files
```bash
$ latexmk -pdf invc.tex
```

## Run benchmarks

Type

```bash
$ cd benchmarks
$ julia --project run_benchmark.jl --adbench-folder path/to/ADBench GMM
$ julia --project run_benchmark.jl --adbench-folder path/to/ADBench BA
$ julia --project run_benchmark.jl Bessel
$ julia --project run_benchmark.jl GE
```
Benchmarks with `--adbench-folder` option requires cloning [ADBench](https://github.com/microsoft/ADBench).

To run the Tapenade benchmark for Bessel function, one should have a gfortran compiler. The benchmark can be execute by typing
```bash
$ cd benchmarks/bessel
$ make
$ ./main.out
```

## Source codes used in this paper
* [Bundle Adjustment](https://github.com/JuliaReverse/NiBundleAdjustment.jl)
* [Gaussian Mixture Model](https://github.com/JuliaReverse/NiGaussianMixture.jl)
* [Graph embedding](https://github.com/JuliaReverse/NiGraphEmbedding.jl)
* [Sparse Matrix Operations](https://giggleliu.github.io/NiLang.jl/stable/examples/sparse/)
* [Bessel function](https://giggleliu.github.io/NiLang.jl/stable/examples/besselj/)

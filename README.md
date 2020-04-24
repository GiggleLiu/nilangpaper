#  Reversible AD paper

To start
```bash
$ latexmk -pdf invc.tex
```

For benchmarks, type
```bash
cd benchmarks
julia --project run_all_benchmarks
```

To run the Tapenade benchmark for Bessel function, one should have a gfortran compiler. The benchmark can be execute by typing
```bash
$ cd benchmarks/bessel
$ make
$ ./main.out
```

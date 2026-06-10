# Simple Benchmark

| tool     | input size | real | user | sys  | rate        | ratio  | RSS   |
|:--------:|:----------:|:----:|:----:|:----:|:-----------:|:------:|:-----:|
| iwasm    | 16,384 MiB | 2.66 | 0.24 | 1.01 | 6,159 MiB/s |  101%  | 10.4M |
| wc -c    | 16,384 MiB | 2.68 | 0.03 | 1.17 | 6,113 MiB/s | (100%) |  1.6M |
| wasmedge | 16,384 MiB | 2.79 | 0.40 | 1.14 | 5,872 MiB/s |   96%  | 24.3M |
| wazero   | 16,384 MiB | 2.80 | 0.26 | 1.13 | 5,851 MiB/s |   96%  |  7.8M |
| wasmtime | 16,384 MiB | 5.37 | 1.67 | 2.91 | 3,051 MiB/s |   50%  | 15.8M |
| wasmer   | 16,384 MiB | 5.82 | 1.54 | 3.61 | 2,815 MiB/s |   46%  | 20.0M |

- iwasm:    2.4.4
- wasmedge: 0.17.0
- wazero:   v1.12.0
- wasmtime: 45.0.1
- wasmer:   7.1.0

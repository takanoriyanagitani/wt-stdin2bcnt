#!/bin/sh

wsm="./wc2.wasm"
wsm="./opt.wasm"

wmr="./wc2.bin"

bench_w0() {
	dd \
		if=/dev/zero \
		bs=1048576 \
		count=16384 \
		status=progress |
		\time -l wazero run "${wsm}" |
		python3 -c 'import sys; import struct; print(
      struct.Struct("<q").unpack(sys.stdin.buffer.read(8))[0],
    )'
}

bench_wasmtime() {
	dd \
		if=/dev/zero \
		bs=1048576 \
		count=16384 \
		status=progress |
		\time -l wasmtime run "${wsm}" |
		python3 -c 'import sys; import struct; print(
      struct.Struct("<q").unpack(sys.stdin.buffer.read(8))[0],
    )'
}

bench_iwasm() {
	dd \
		if=/dev/zero \
		bs=1048576 \
		count=16384 \
		status=progress |
		\time -l iwasm "${wsm}" |
		python3 -c 'import sys; import struct; print(
      struct.Struct("<q").unpack(sys.stdin.buffer.read(8))[0],
    )'
}

bench_wamrc() {
	dd \
		if=/dev/zero \
		bs=1048576 \
		count=16384 \
		status=progress |
		\time -l iwasm "${wmr}" |
		python3 -c 'import sys; import struct; print(
      struct.Struct("<q").unpack(sys.stdin.buffer.read(8))[0],
    )'
}

bench_wasmer() {
	dd \
		if=/dev/zero \
		bs=1048576 \
		count=16384 \
		status=progress |
		\time -l wasmer run "${wsm}" |
		python3 -c 'import sys; import struct; print(
      struct.Struct("<q").unpack(sys.stdin.buffer.read(8))[0],
    )'
}

bench_wasmedge() {
	dd \
		if=/dev/zero \
		bs=1048576 \
		count=16384 \
		status=progress |
		\time -l wasmedge run "${wsm}" |
		python3 -c 'import sys; import struct; print(
      struct.Struct("<q").unpack(sys.stdin.buffer.read(8))[0],
    )'
}

bench_iwasm

(module

  (import "wasi_snapshot_preview1" "proc_exit" (func $proc_exit (param i32)))

  (import "wasi_snapshot_preview1" "fd_write"
    (func $fd_write (param i32 i32 i32 i32) (result i32)))

  (import "wasi_snapshot_preview1" "fd_read"
    (func $fd_read (param i32 i32 i32 i32) (result i32)))

  (global $STDIN i32 (i32.const 0))
  (global $STDOUT i32 (i32.const 1))
  (global $STDERR i32 (i32.const 2))

  (global $READ_BUF_SIZE i32 (i32.const 32768))

  (global $FD_READ_IOVEC_PTR i32 (i32.const 0x0001_0000))
  (global $FD_READ_IOBUF_PTR i32 (i32.const 0x0002_0000))
  (global $FD_READ_BREAD_PTR i32 (i32.const 0x0003_0000))

  (global $FD_WRIT_IOVEC_PTR i32 (i32.const 0x0004_0000))
  (global $FD_WRIT_IOBUF_PTR i32 (i32.const 0x0005_0000))
  (global $FD_WRIT_BWRIT_PTR i32 (i32.const 0x0006_0000))

  (memory (export "memory") 7)

  (func $read_full_or_eof
    (param $fd i32)
    (param $iovec_ptr i32)
    (param $iobuf_ptr i32)
    (param $bread_ptr i32)
    (param $len i32)

    (result i64 i32)

    (local $read_cnt i32)
    (local $read_tot i32)
    (local $read_nxt i32)

    i32.const 0
    local.tee $read_cnt
    local.set $read_tot

    loop
      ;; compute byte count to read
      local.get $len
      local.get $read_tot
      i32.sub
      local.set $read_nxt

      ;; setup the iovec
      local.get $iovec_ptr
      local.get $iobuf_ptr
      local.get $read_tot
      i32.add
      i32.store
      local.get $iovec_ptr
      local.get $read_nxt
      i32.store offset=4

      local.get $fd
      local.get $iovec_ptr
      i32.const 1 ;; single buffer
      local.get $bread_ptr
      call $fd_read
      i32.const 0
      i32.ne
      if
        i32.const 1
        call $proc_exit
        i64.const -1
        i32.const -1
        return
      end

      local.get $bread_ptr
      i32.load
      local.tee $read_cnt
      local.get $read_tot
      i32.add
      local.tee $read_tot
      local.get $len
      i32.eq
      ;; return if fully read
      if
        i64.const 0
        local.get $len
        return
      end

      local.get $read_cnt
      i32.const 0
      i32.eq
      ;; return on EOF
      if
        i64.const 0
        local.get $read_tot
        return
      end

      br 0
    end

    i64.const -1
    i32.const -1
  )

  (func $read_full_or_eof_default
    (result i64 i32)

    ;; result i64: <0 on error, 0 on success
    ;; result i32: <0 on error, 0 on no more data, >0 on new data

    global.get $STDIN
    global.get $FD_READ_IOVEC_PTR
    global.get $FD_READ_IOBUF_PTR
    global.get $FD_READ_BREAD_PTR
    global.get $READ_BUF_SIZE
    call $read_full_or_eof
  )

  (func $int2stdout
    (param $i i32)

    (param $fd i32)
    (param $pvec i32)
    (param $pbuf i32)
    (param $pwrt i32)

    (result i64)

    ;; setup the iovec
    local.get $pvec
    local.get $pbuf
    i32.store
    local.get $pvec
    i32.const 4 ;; 32-bit integer = 4 bytes
    i32.store offset=4

    ;; save the integer
    local.get $pbuf
    local.get $i
    i32.store

    local.get $fd
    local.get $pvec
    i32.const 1 ;; single buffer
    local.get $pwrt
    call $fd_write
    i32.const 0
    i32.ne
    if
      i32.const 1
      call $proc_exit
      i64.const -1
      return
    end

    local.get $pwrt
    i32.load
    i32.const 4
    i32.ne
    if
      i32.const 1
      call $proc_exit
      i64.const -1
      return
    end

    i64.const 0
  )

  (func $int2stdout_default
    (param $i i32)
    (result i64)

    local.get $i

    global.get $STDOUT
    global.get $FD_WRIT_IOVEC_PTR
    global.get $FD_WRIT_IOBUF_PTR
    global.get $FD_WRIT_BWRIT_PTR

    call $int2stdout
  )

  (func $lng2stdout
    (param $i i64)

    (param $fd i32)
    (param $pvec i32)
    (param $pbuf i32)
    (param $pwrt i32)

    (result i64)

    ;; setup the iovec
    local.get $pvec
    local.get $pbuf
    i32.store
    local.get $pvec
    i32.const 8 ;; 64-bit integer = 8 bytes
    i32.store offset=4

    ;; save the integer
    local.get $pbuf
    local.get $i
    i64.store

    local.get $fd
    local.get $pvec
    i32.const 1 ;; single buffer
    local.get $pwrt
    call $fd_write
    i32.const 0
    i32.ne
    if
      i32.const 1
      call $proc_exit
      i64.const -1
      return
    end

    local.get $pwrt
    i32.load
    i32.const 8
    i32.ne
    if
      i32.const 1
      call $proc_exit
      i64.const -1
      return
    end

    i64.const 0
  )

  (func $lng2stdout_default
    (param $i i64)
    (result i64)

    local.get $i

    global.get $STDOUT
    global.get $FD_WRIT_IOVEC_PTR
    global.get $FD_WRIT_IOBUF_PTR
    global.get $FD_WRIT_BWRIT_PTR

    call $lng2stdout
  )

  (func $stdin2count
    (result i64)

    (local $res i64)
    (local $tot i64)
    (local $cnt i32)

    i64.const 0
    local.set $tot

    loop
      call $read_full_or_eof_default
      local.set $cnt
      local.tee $res
      i64.const 0
      i64.ne
      if
        i32.const 1
        call $proc_exit
        i64.const -1
        return
      end

      local.get $cnt
      i32.const 0
      i32.eq
      ;; return if no more data
      if
        local.get $tot
        return
      end

      ;; continue
      local.get $cnt
      i64.extend_i32_u
      local.get $tot
      i64.add
      local.set $tot

      br 0
    end

    i64.const -1
  )

  (func $main (export "_start")
    call $stdin2count
    call $lng2stdout_default
    i64.const 0
    i64.ne
    if
      i32.const 1
      call $proc_exit
      return
    end
  )

)

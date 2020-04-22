program main
    real*8 :: res, resb, zb
    real*8 :: start, finish
    call cpu_time(start)
    do i=1,10000000
        res = 0
        call besselj(res, 2, 1D0, 1D-8)
    enddo
    call cpu_time(finish)
    print*, "objective", (finish - start)/10000000.0

    call cpu_time(start)
    do i=1,10000000
        res = 0
        resb = 1
        zb = 0
        call besselj(res, 2, 1D0, 1D-8)
        call besselj_b(res, resb, 2, 1D0, zb, 1D-8)
    enddo
    call cpu_time(finish)
    print*, "jacobian", (finish - start)/10000000.0

    call cpu_time(start)
    do i=1,10000000
        res = 0
        resb = 0
        zb = 1
        call besselj_d(res, resb, 2, 1D0, zb, 1D-8)
    enddo
    call cpu_time(finish)
    print*, "jacobian (F)", (finish - start)/10000000.0
endprogram main

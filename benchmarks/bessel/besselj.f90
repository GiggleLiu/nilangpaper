subroutine besselj(res, v, z, atol)
    implicit none
	integer, intent(in) :: v
	real*8, intent(in) :: z, atol
	real*8, intent(out) :: res
	real*8 :: s
	integer :: k, i, factv
    k = 0
    factv = 1
    do i = 2,v
        factv = factv * i
    enddo

    s = (z/2.0)**v / factv
    res = s
    do while(abs(s) > atol)
        k = k + 1
        s = -s / k / (k+v) * ((z/2) ** 2)
        res = res + s
    enddo
endsubroutine besselj

program main
    real*8 :: res
    call besselj(res, 2, 1D0, 1D-8)
    print*,res
endprogram main

program tester
    use types
    use fmodel
    implicit none

    ! Parameters
    integer, PARAMETER :: n = 17
    real(dp), parameter :: x1 = 0.0_dp, x2 = 0.5_dp,  k = 1.0_dp, S =00.0_dp
    real(dp), PARAMETER :: TA = 100.0_dp, TB=500.0_dp
    real(dp) :: T(n)
    real(dp) :: h
    integer :: i
    CHARACTER(len=*), PARAMETER :: fmt_A_F = "(A7,f16.9)"
    CHARACTER(len=*), PARAMETER :: fmt_A_I = "(A7,i16)"
    CHARACTER(len=*), PARAMETER :: fmt_A_A = "(2a16)"
    CHARACTER(len=*), PARAMETER :: fmt_F_F = "(2f16.9)"

    h = (x2 - x1)/(n - 1.0_dp)

    ! Show results
    write(*, fmt_A_F) "x1:", x1
    write(*, fmt_A_F) "x2:", x2
    write(*, fmt_A_F)  "TA:", TA
    write(*, fmt_A_F)  "TB:", TB
    write(*, fmt_A_F)  "S:", S
    write(*, fmt_A_F)  "k:", k
    write(*, fmt_A_I) "n:", n
    write(*, fmt_A_F) "h:", h
    print*, ""

    ! Call function
    call finite_volume_example(x1, x2, TA, TB, S, k, T, n)
    print*, "V1"
    call print_T()

    T = 0.0_dp

    ! Call function
    print*,
    print*, "V2"
    call finite_volume_examplev2(x1, x2, TA, TB, S, k, T, n)
    call print_T()

    contains

    subroutine print_T()
        write(*,fmt_A_A) "L", "T"
        do i=1, n
            write(*,fmt_F_F) x1 + (i-1)*h, T(i)
        enddo
    end subroutine
    
end program
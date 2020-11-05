program tester
    use fmodel, only : finite_volume_example, finite_volume_examplev2
    use types, only : dp
    implicit none

    ! Parameters
    integer, PARAMETER :: n = 7
    real(dp), parameter :: x1 = 0.0_dp, x2 = 0.5_dp,  k = 1.0_dp, S =00.0_dp
    real(dp), PARAMETER :: TA = 100.0_dp, TB=500.0_dp
    real(dp) :: T(n)
    real(dp) :: h
    integer :: i

    ! Show results
    print*, "x1: ", x1
    print*, "x2: ", x2
    print*, "TA: ", TA
    print*, "TB: ", TB
    print*, "S: ", S
    print*, "k: ", k
    print*, "n: ", n

    h = (x2 - x1)/(n - 1.0_dp)

    ! Call function
    call finite_volume_example(x1, x2, TA, TB, S, k, T, n)

    print*, "V1"
    print*, "L", " T"
    do i=1, n
        print*, x1 + (i-1)*h, T(i)
    enddo

    T = 0.0_dp

    ! Call function
    call finite_volume_examplev2(x1, x2, TA, TB, S, k, T, n)

    print*, "V2"
    print*, "L", " T"
    do i=1, n
        print*, x1 + (i-1)*h, T(i)
    enddo

end program
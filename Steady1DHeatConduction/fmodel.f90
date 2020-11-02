subroutine finite_volume_example(x,TA, TB, S, k, T, n)
    implicit none
    integer, intent(in)   :: n
    real(8), intent(inout)  :: x(n)
    real(8), intent(out) :: T(n)
    real(8), intent(in) ::TA, TB, S, k

    real(8) :: P(n), Q(n)
    real(8) :: den
    real(8) ::  a(n), b(n), c(n), d(n)
    integer :: i

    P = 0.d0
    Q = 0.d0

    T(1) = TA
    T(n) = TB
    a = 0.0d0
    d = 0.0d0

    a(1) = 1.0d0
    a(n) = 1.0d0
    c(1) = TA
    c(n) = TB

    b = 1.0d0
    c= 1.0d0

    ! Preenchendo aP, aE e aW - inclui malhas não uniformes
    do i = 2, n-1
        b(i) = x(i) - x(i - 1)
        c(i) = x(i + 1) - x(i)
    end do

    d = (b + c)*S*0.5d0/k
    b = 1.0d0/b
    c = 1.0d0/c
    a = b + c

    ! Looping para P e Q
    do i = 2, n
        den = a(i) - c(i) * P(i - 1)
        P(i) = b(i) / den
        Q(i) = (Q(i - 1) * c(i) + d(i)) / den
    end do

    ! Looping reverso para a temperatura
    do i = n - 2, 1, -1
        T(i) = P(i) * T(i + 1) + Q(i)
    end do

    return
end subroutine
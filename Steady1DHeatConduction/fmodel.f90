module fmodel
    use types
    implicit none
    contains
pure subroutine steady1dheatconduction( x1, x2,TA, TB, S, k, T, n)
    integer, intent(in)   :: n
    real(dp), intent(out) :: T(n)
    real(dp), intent(in) ::TA, TB, S, k, x1, x2

    real(dp) :: P(n), Q(n)
    real(dp) :: inv_den, delta
    real(dp) :: b, d, a
    integer :: i

    delta = (x2 - x1)/(n - 1.0_dp)
    b = 1.0_dp / delta
    a = b + b
    d = S * 0.5_dp * (delta + delta) / k

    ! boundary conditions
    T(1) = TA
    T(n) = TB

    ! P(1) e Q(1)
    P(1) = 0.0_dp
    Q(1) = TA
    ! P(2) e Q(2)
    inv_den = 1.0_dp /(a)
    P(2) = b * inv_den
    Q(2) = (Q(1) * b + d) * inv_den
    ! P(n) e Q(n)
    P(n) = 0.0_dp
    Q(n) = 0.0_dp

    ! Looping para P e Q
    do i = 3, n-1
        inv_den = 1.0_dp /( a - b * P(i - 1))
        P(i) = b * inv_den
        Q(i) = (Q(i - 1) * b + d) * inv_den
    end do

    ! Looping reverso para a temperatura
    do i = n - 1, 2, -1
        T(i) = P(i) * T(i + 1) + Q(i)
    end do

    return
end subroutine

end module

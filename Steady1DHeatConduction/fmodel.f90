module types

implicit none
integer, parameter :: sp = selected_real_kind(6,37) ! single precision
integer, parameter :: dp = selected_real_kind(15,307) ! double precision

real(sp) :: r_sp = 1.0
real(dp) :: r_dp = 1.0_dp

end module


module fmodel
    contains
subroutine finite_volume_example( x1, x2,TA, TB, S, k, T, n)
    use types
    implicit none
    integer, intent(in)   :: n
    real(dp), intent(out) :: T(n)
    real(dp), intent(in) ::TA, TB, S, k, x1, x2

    real(dp) :: P(n), Q(n)
    real(dp) :: inv_den, delta
    real(dp) :: a(n), b(n), d(n)
    integer :: i

    delta = (x2-x1)/float(n-1)
    b = 1.0d0/delta
    a = b + b ! done

    ! boundary conditions
    a(1) = 1.0d0
    a(n) = 1.0d0
    b(1) = 0.0d0
    b(n) = 0.0d0
    T(1) = TA
    T(n) = TB
    Q(1) = TA
    P(1) = 0.0d0

    d = S * 0.5d0 * (delta  + delta) / k
    d(1) = TA
    d(n) = TB

    ! Looping para P e Q
    do i = 2, n
        inv_den = 1.0d0 /( a(i) - b(i) * P(i - 1))
        P(i) = b(i) * inv_den
        Q(i) = (Q(i - 1) * b(i) + d(i)) * inv_den
    end do

    ! Looping reverso para a temperatura
    do i = n - 1, 2, -1
        T(i) = P(i) * T(i + 1) + Q(i)
    end do

    return
end subroutine

end module
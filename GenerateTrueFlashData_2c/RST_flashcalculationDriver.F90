
!!$ Author:
!!$   Yuanqing Wu, Shenzhen University, P.R.China
!!$
!!$ History:
!!$   2022-3-24 by Yuanqing Wu
!!$
!!$ Support:
!!$   wuyuanq@gmail.com

module RST_flashcalculationDriver

    use RST_flashcalculation

contains

    subroutine flashcalculationDriver()

        implicit none

        integer, parameter :: GRIDSIZE_P = 100
        integer, parameter :: GRIDSIZE_Z1 = 100
        real(kind=8), parameter :: PMIN = 1.9D6
        real(kind=8), parameter :: PMAX = 2.1D6
        real(kind=8), parameter :: PSTEP = (PMAX-PMIN)/(GRIDSIZE_P-1)
        real(kind=8), dimension(:), pointer :: z, xW, xN, v
        real(kind=8) :: xiW, xiN, densiW, densiN, Sw, Cf
        logical :: isW, isN, isRea
        integer :: i, j, m, k
        character(len=*), parameter :: FULLGRIDPREFIX = 'trueData/'

        open(unit=120, file=FULLGRIDPREFIX//"P.txt", status='replace')
        open(unit=130, file=FULLGRIDPREFIX//"z1.txt", status='replace')
        open(unit=140, file=FULLGRIDPREFIX//"z2.txt", status='replace')
        open(unit=160, file=FULLGRIDPREFIX//"xW1.txt", status='replace')
        open(unit=170, file=FULLGRIDPREFIX//"xW2.txt", status='replace')
        open(unit=190, file=FULLGRIDPREFIX//"xN1.txt", status='replace')
        open(unit=200, file=FULLGRIDPREFIX//"xN2.txt", status='replace')
        open(unit=220, file=FULLGRIDPREFIX//"xiW.txt", status='replace')
        open(unit=230, file=FULLGRIDPREFIX//"xiN.txt", status='replace')
        open(unit=240, file=FULLGRIDPREFIX//"densiW.txt", status='replace')
        open(unit=250, file=FULLGRIDPREFIX//"densiN.txt", status='replace')
        open(unit=260, file=FULLGRIDPREFIX//"sW.txt", status='replace')
        open(unit=270, file=FULLGRIDPREFIX//"v1.txt", status='replace')
        open(unit=280, file=FULLGRIDPREFIX//"v2.txt", status='replace')
        open(unit=300, file=FULLGRIDPREFIX//"Cf.txt", status='replace')
        open(unit=310, file=FULLGRIDPREFIX//"liquid.txt", status='replace')
        open(unit=320, file=FULLGRIDPREFIX//"gas.txt", status='replace')

        allocate(z(Nc))
        allocate(xW(Nc))
        allocate(xN(Nc))
        allocate(v(Nc))

        k = 1
        do i = 0, GRIDSIZE_P-1
            do j = 0, GRIDSIZE_Z1-1

                print *, i, j

                z(1) = j*1.D0/(GRIDSIZE_Z1-1)
                z(2) = 1.D0 - Z(1)

                call flashcalculation( PMIN+i*PSTEP, z, xW, xN, xiW, xiN, &!
                    densiW, densiN, Sw, v, Cf, isW, isN, isRea )

                write(120, fmt="(f15.3)") PMIN+i*PSTEP
                write(130, fmt="(f15.8)") z(1)
                write(140, fmt="(f15.8)") z(2)
                write(160, fmt="(f15.8)") xW(1)
                write(170, fmt="(f15.8)") xW(2)
                write(190, fmt="(f15.8)") xN(1)
                write(200, fmt="(f15.8)") xN(2)
                write(220, fmt="(f15.3)") xiW
                write(230, fmt="(f15.3)") xiN
                write(240, fmt="(f15.3)") densiW
                write(250, fmt="(f15.3)") densiN
                write(260, fmt="(f15.8)") Sw
                write(270, fmt="(f15.8)") v(1)
                write(280, fmt="(f15.8)") v(2)
                write(300, fmt="(f15.8)") Cf
                if(isW) then
                    write(310, fmt="(i1)") 1
                else
                    write(310, fmt="(i1)") 0
                end if
                if(isN) then
                    write(320, fmt="(i1)") 1
                else
                    write(320, fmt="(i1)") 0
                end if

            end do
        end do

        deallocate(z)
        deallocate(xW)
        deallocate(xN)
        deallocate(v)

        close(120)
        close(130)
        close(140)
        close(160)
        close(170)
        close(190)
        close(200)
        close(220)
        close(230)
        close(240)
        close(250)
        close(260)
        close(270)
        close(280)
        close(300)
        close(310)
        close(320)

    end subroutine flashcalculationDriver

end module RST_flashcalculationDriver

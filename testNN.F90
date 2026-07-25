
!!$ Author:
!!$   Yuanqing Wu, KAUST, Saudi Arabia
!!$
!!$ History:
!!$   2015-2-9 by Yuanqing Wu
!!$
!!$ Support:
!!$   wuyuanq@gmail.com

program testNN

    use RST_flashcalculation_nn
    implicit none

    character(len=60), parameter :: trueDataPath = './GenerateTrueFlashData_2c/trueData/'

    real(kind=8), dimension(:), pointer :: P_input, local_z
    real(kind=8), dimension(:,:), pointer :: z_input, xo, xg
    integer, dimension(:), pointer :: liquid, phase
    real(kind=8) :: dumb
    character :: charm
    integer :: inputSize, gas, ierr, i, j, m

    real(kind=8), dimension(:), pointer :: xo_pre, xg_pre
    real(kind=8) :: xiL, xiG, rhoL, rhoG, sL
    real(kind=8), dimension(:), pointer :: local_v
    real(kind=8) :: local_Cf
    logical :: isW, isN

    character(len=60), dimension(:), pointer :: fxoPretxt, fxgPretxt, fxoErrtxt, fxgErrtxt
    character(len=60) :: fphasePretxt, fphaseErrtxt

    Temp = 260.0
    Nc = NUM_COMPONENTS
    allocate(ct(Nc))
    ct(1) = 190
    ct(2) = 370
    allocate(cp(Nc))
    cp(1) = 4.6*1.D6
    cp(2) = 4.2*1.D6
    allocate(af(Nc))
    af(1) = 0.01
    af(2) = 0.15
    allocate(mw(Nc))
    mw(1) = 0.016
    mw(2) = 0.044
    allocate(cv(Nc))
    cv(1) = 0.0062
    cv(2) = 0.0045
    allocate(psatA(Nc))
    psatA(1) = 6.69561
    psatA(2) = 6.82973
    allocate(psatB(Nc))
    psatB(1) = 405.420
    psatB(2) = 813.2
    allocate(psatC(Nc))
    psatC(1) = 267.777
    psatC(2) = 248
    allocate(delta(Nc,Nc))
    delta(:,:) = 0.0
    delta(1,2) = 0.036
    delta(2,1) = delta(1,2)

    isFirstNN = .true.

    ! read P
    open(unit=10, file=trim(adjustl(trueDataPath))//'P.txt', status='old', &!
        action='read')

    i = 0
    do while(.true.)
        read(10, fmt='(f15.3)', iostat=ierr) dumb
        if(ierr < 0) then
            exit
        else
            i = i + 1
        end if
    end do
    inputSize = i

    rewind(10)
    allocate(P_input(inputSize))
    do i = 1, inputSize
        read(10, fmt='(f15.3)') P_input(i)
    end do

    close(10)

    ! read z
    allocate(z_input(NUM_COMPONENTS, inputSize))
    do m = 1, NUM_COMPONENTS
        write(charm,'(i1)') m
        open(unit=10, file=trim(adjustl(trueDataPath))//'z'//charm//'.txt', &!
            status='old', action='read')

        do i = 1, inputSize
            read(10, fmt='(f15.8)') z_input(m,i)
        end do

        close(10)
    end do

    ! read true xo
    allocate(xo(NUM_COMPONENTS, inputSize))
    do m = 1, NUM_COMPONENTS
        write(charm,'(i1)') m
        open(unit=10, file=trim(adjustl(trueDataPath))//'xW'//charm//'.txt', &!
            status='old', action='read')

        do i = 1, inputSize
            read(10, fmt='(f15.8)') xo(m,i)
        end do

        close(10)
    end do

    ! read true xg
    allocate(xg(NUM_COMPONENTS, inputSize))
    do m = 1, NUM_COMPONENTS
        write(charm,'(i1)') m
        open(unit=10, file=trim(adjustl(trueDataPath))//'xN'//charm//'.txt', &!
            status='old', action='read')

        do i = 1, inputSize
            read(10, fmt='(f15.8)') xg(m,i)
        end do

        close(10)
    end do

    ! read liquid phase
    open(unit=10, file=trim(adjustl(trueDataPath))//'liquid.txt', &!
        status='old', action='read')

    allocate(liquid(inputSize))
    do i = 1, inputSize
        read(10, fmt='(i1)') liquid(i)
    end do

    close(10)

    ! read gas phase and get the phase condition
    open(unit=10, file=trim(adjustl(trueDataPath))//'gas.txt', &!
        status='old', action='read')

    allocate(phase(inputSize))
    do i = 1, inputSize
        read(10, fmt='(i1)') gas
        phase(i) = liquid(i) - gas
    end do

    close(10)

    ! prepare the estimate files
    fphasePretxt = 'phase_pre.txt'
    allocate(fxoPretxt(NUM_COMPONENTS))
    allocate(fxgPretxt(NUM_COMPONENTS))
    do m = 1, NUM_COMPONENTS
        write(charm,'(i1)') m
        fxoPretxt(m) = 'xo'//charm//'_pre.txt'
        fxgPretxt(m) = 'xg'//charm//'_pre.txt'
    end do

    open(unit=110, file=trim(adjustl(fphasePretxt)), status='replace')
    do m = 1, NUM_COMPONENTS
        open(unit=10+m, file=trim(adjustl(fxoPretxt(m))), status='replace')
    end do
    do m = 1, NUM_COMPONENTS
        open(unit=10+NUM_COMPONENTS+m, file=trim(adjustl(fxgPretxt(m))), status='replace')
    end do

    ! prepare the error files
    allocate(fxoErrtxt(NUM_COMPONENTS))
    allocate(fxgErrtxt(NUM_COMPONENTS))
    do m = 1, NUM_COMPONENTS
        write(charm,'(i1)') m
        fxoErrtxt(m) = 'xo'//charm//'_error.txt'
        fxgErrtxt(m) = 'xg'//charm//'_error.txt'
    end do
    fphaseErrtxt = 'phase_error.txt'

    do m = 1, NUM_COMPONENTS
        open(unit=10+NUM_COMPONENTS*2+m, file=trim(adjustl(fxoErrtxt(m))), status='replace')
    end do
    do m = 1, NUM_COMPONENTS
        open(unit=10+NUM_COMPONENTS*3+m, file=trim(adjustl(fxgErrtxt(m))), status='replace')
    end do
    open(unit=NUM_COMPONENTS*4+1, file=trim(adjustl(fphaseErrtxt)), status='replace')

    allocate(local_z(NUM_COMPONENTS))
    allocate(xo_pre(NUM_COMPONENTS))
    allocate(xg_pre(NUM_COMPONENTS))
    allocate(local_v(NUM_COMPONENTS))
   
    do i = 1, inputSize

        do j = 1, NUM_COMPONENTS
            local_z(j) = z_input(j,i)
        end do

        call flashcalculation_nn(P_input(i), local_z, xo_pre, xg_pre, xiL, xiG, rhoL, rhoG, &!
            sL, local_v, local_Cf, isW, isN)

        if(isW.and.isN) then
            write(110, fmt='(i2)', iostat=ierr) 0
            write(NUM_COMPONENTS*4+1, fmt='(i2)') phase(i)
        elseif(.not.isW.and.isN) then
            write(110, fmt='(i2)', iostat=ierr) -1
            write(NUM_COMPONENTS*4+1, fmt='(i2)') phase(i)+1
        else
            write(110, fmt='(i2)', iostat=ierr) 1
            write(NUM_COMPONENTS*4+1, fmt='(i2)') phase(i)-1
        end if

        do m = 1, NUM_COMPONENTS
            write(10+m, fmt='(f15.8)') xo_pre(m)
        end do
        do m = 1, NUM_COMPONENTS
            write(10+NUM_COMPONENTS+m, fmt='(f15.8)') xg_pre(m)
        end do
        do m = 1, NUM_COMPONENTS
            write(10+NUM_COMPONENTS*2+m, fmt='(f15.8)') abs(xo_pre(m)-xo(m,i))
        end do
        do m = 1, NUM_COMPONENTS
            write(10+NUM_COMPONENTS*3+m, fmt='(f15.8)') abs(xg_pre(m)-xg(m,i))
        end do
        
    end do

    close(110)
    do m = 1, NUM_COMPONENTS*4
        close(10+m)
    end do
    close(NUM_COMPONENTS*4+1)

    deallocate(ct)
    deallocate(cp)
    deallocate(af)
    deallocate(mw)
    deallocate(cv)
    deallocate(psatA)
    deallocate(psatB)
    deallocate(psatC)
    deallocate(delta)
    deallocate(P_input)
    deallocate(z_input)
    deallocate(xo)
    deallocate(xg)
    deallocate(liquid)
    deallocate(phase)
    deallocate(fxoPretxt)
    deallocate(fxgPretxt)
    deallocate(fxoErrtxt)
    deallocate(fxgErrtxt)
    deallocate(local_z)
    deallocate(xo_pre)
    deallocate(xg_pre)
    deallocate(local_v)

end program testNN

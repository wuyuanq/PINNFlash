    
!!$ Author:
!!$   Yuanqing Wu, KAUST, Saudi Arabia
!!$
!!$ History:
!!$   2022-9-17 by Yuanqing Wu
!!$
!!$ Support:
!!$   wuyuanq@gmail.com

module RST_getEquResidual
    
    use RST_fugacitycoef
    implicit none

    integer, parameter :: NUM_LAYERS = 6
    integer, parameter :: NUM_NEURONS = 20
    integer, parameter :: NUM_COMPONENTS = 2
    real(kind=8), parameter :: THRESHOLD = 0.1

    character(len=60), parameter :: FWEIGHTTXT = '/Users/yuanqingwu/Research/DeepLearning/weights.txt'

    type wcon
        real(kind=8), pointer :: pw(:,:)
        real(kind=8), pointer :: pb(:)
    end type wcon
    type(wcon) :: weights(NUM_LAYERS+1)

contains

    function relu(x) result(y)

        real(kind=8), intent(in) :: x
        real(kind=8) :: y

        if(x > 0.D0) then
            y = x
        else
            y = 0.D0
        end if

    end function relu

    function sigmoid(x) result(y)

        real(kind=8), intent(in) :: x
        real(kind=8) :: y

        y = 1.D0/(1.D0+exp(-x))

    end function sigmoid

    subroutine retrieveNN()

        integer :: ierr, i, j, k

        open(unit=10, file=trim(adjustl(FWEIGHTTXT)), status='old', action='read', iostat=ierr)
        if(ierr /= 0) then
            print *, 'open file error. ', ierr
            stop
        end if

        do i = 1, NUM_LAYERS+1
            if(i == 1) then
                allocate(weights(i)%pw(NUM_COMPONENTS+2,NUM_NEURONS))
                allocate(weights(i)%pb(NUM_NEURONS))
                do j = 1, NUM_COMPONENTS+2
                    do k = 1, NUM_NEURONS
                        read(10, fmt="(f13.10)") weights(i)%pw(j,k)
                    end do
                end do
                do j = 1, NUM_NEURONS
                    read(10, fmt="(f13.10)") weights(i)%pb(j)
                end do
            elseif(i == NUM_LAYERS-1) then
                allocate(weights(i)%pw(NUM_NEURONS,1))
                allocate(weights(i)%pb(1))
                do j = 1, NUM_NEURONS
                    read(10, fmt="(f13.10)") weights(i)%pw(j,1)
                end do
                read(10, fmt="(f13.10)") weights(i)%pb(1)
            elseif((i==NUM_LAYERS).or.(i==NUM_LAYERS+1)) then
                allocate(weights(i)%pw(NUM_NEURONS,NUM_COMPONENTS))
                allocate(weights(i)%pb(NUM_COMPONENTS))
                do j = 1, NUM_NEURONS
                    do k = 1, NUM_COMPONENTS
                        read(10, fmt="(f13.10)") weights(i)%pw(j,k)
                    end do
                end do
                do j = 1, NUM_COMPONENTS
                    read(10, fmt="(f13.10)") weights(i)%pb(j)
                end do
            else
                allocate(weights(i)%pw(NUM_NEURONS,NUM_NEURONS))
                allocate(weights(i)%pb(NUM_NEURONS))
                do j = 1, NUM_NEURONS
                    do k = 1, NUM_NEURONS
                        read(10, fmt="(f13.10)") weights(i)%pw(j,k)
                    end do
                end do
                do j = 1, NUM_NEURONS
                    read(10, fmt="(f13.10)") weights(i)%pb(j)
                end do
            end if
        end do

        close(10)

    end subroutine retrieveNN

    subroutine NNApproximator(inputLayer, outputLayer)

        real(kind=8), dimension(:), pointer, intent(in) :: inputLayer
        real(kind=8), dimension(:), pointer, intent(in out) :: outputLayer

        real(kind=8), dimension(NUM_LAYERS-2, NUM_NEURONS) :: imedL
        real(kind=8) :: sum
        integer :: i, j, k

        do j = 1, NUM_NEURONS
            sum = 0.D0
            do k = 1, NUM_COMPONENTS+2
                sum = sum + inputLayer(k)*weights(1)%pw(k,j)
            end do
            sum = sum + weights(1)%pb(j)
            imedL(1,j) = relu(sum)
        end do

        do i = 2, NUM_LAYERS-2
            do j = 1, NUM_NEURONS
                sum = 0.D0
                do k = 1, NUM_NEURONS
                    sum = sum + imedL(i-1,k)*weights(i)%pw(k,j)
                end do
                sum = sum + weights(i)%pb(j)
                imedL(i,j) = relu(sum)
            end do
        end do

        sum = 0.D0
        do k = 1, NUM_NEURONS
            sum = sum + imedL(NUM_LAYERS-2,k)*weights(NUM_LAYERS-1)%pw(k,1)
        end do
        sum = sum + weights(NUM_LAYERS-1)%pb(1)
        outputLayer(1) = sigmoid(sum)

        do j = 1, NUM_COMPONENTS
            sum = 0.D0
            do k = 1, NUM_NEURONS
                sum = sum + imedL(NUM_LAYERS-2,k)*weights(NUM_LAYERS)%pw(k,j)
            end do
            sum = sum + weights(NUM_LAYERS)%pb(j)
            outputLayer(j+1) = relu(sum)
        end do

        do j = 1, NUM_COMPONENTS
            sum = 0.D0
            do k = 1, NUM_NEURONS
                sum = sum + imedL(NUM_LAYERS-2,k)*weights(NUM_LAYERS+1)%pw(k,j)
            end do
            sum = sum + weights(NUM_LAYERS+1)%pb(j)
            outputLayer(j+NUM_COMPONENTS+1) = relu(sum)
        end do

        sum = 0.D0
        do j = 1, NUM_COMPONENTS
            if(inputLayer(j+2) > 0) then
                sum = sum + exp(outputLayer(j+1))
            end if
        end do
        do j = 1, NUM_COMPONENTS
            if(inputLayer(j+2) > 0) then
                outputLayer(j+1) = exp(outputLayer(j+1))/sum !softmax
            else
                outputLayer(j+1) = 0.D0
            end if
        end do

        sum = 0.D0
        do j = 1, NUM_COMPONENTS
            if(inputLayer(j+2) > 0) then
                sum = sum + exp(outputLayer(j+NUM_COMPONENTS+1))
            end if
        end do
        do j = 1, NUM_COMPONENTS
            if(inputLayer(j+2) > 0) then
                outputLayer(j+NUM_COMPONENTS+1) = exp(outputLayer(j+NUM_COMPONENTS+1))/sum !softmax
            else
                outputLayer(j+NUM_COMPONENTS+1) = 0.D0
            end if
        end do
    
    end subroutine NNApproximator

    subroutine getFugacityCoef(P, x_o, x_g, phil, phig)

        real(kind=8), intent(in) :: P
        real(kind=8), dimension(:), pointer, intent(in) :: x_o, x_g
        real(kind=8), dimension(:), pointer, intent(in out) :: phil, phig

        real(kind=8) :: ZL, ZG
        real(kind=8), dimension(:), pointer :: am, bm
        real(kind=8) :: al, ag, bl, bg, bigAL, bigAG, bigBL, bigBG
        real(kind=8) :: xiL, xiG, rhoL, rhoG, CfL, CfG
        integer :: i

        allocate(am(NUM_COMPONENTS))
        allocate(bm(NUM_COMPONENTS))

        call fugacitycoef(x_o, x_g, P, ZL, ZG, am, bm, al, ag, bl, bg, bigAL, bigAG, bigBL, &!
            bigBG, xiL, xiG, rhoL, rhoG, CfL, CfG, phil, phig)

        deallocate(am)
        deallocate(bm)

    end subroutine getFugacityCoef

    subroutine getEquResidual(inputLayer, residual)

        real(kind=8), dimension(:), pointer, intent(in) :: inputLayer
        real(kind=8), dimension(:), pointer, intent(in out) :: residual

        real(kind=8), dimension(:), pointer :: outputLayer
        real(kind=8), dimension(:), pointer :: x, x_o, x_g
        real(kind=8), dimension(:), pointer :: phil, phig
        real(kind=8) :: L, P, res2W
        integer :: i

        allocate(outputLayer(NUM_COMPONENTS*2+1))
        allocate(x(NUM_COMPONENTS))
        allocate(x_o(NUM_COMPONENTS))
        allocate(x_g(NUM_COMPONENTS))
        allocate(phil(NUM_COMPONENTS))
        allocate(phig(NUM_COMPONENTS))

        call NNApproximator(inputLayer, outputLayer)
        L = outputLayer(1)
        x_o(1:NUM_COMPONENTS) = outputLayer(2:NUM_COMPONENTS+1)
        x_g(1:NUM_COMPONENTS) = outputLayer(NUM_COMPONENTS+2:NUM_COMPONENTS*2+1)
        P = inputLayer(1)
        x(1:NUM_COMPONENTS) = inputLayer(3:NUM_COMPONENTS+2)

        deallocate(outputLayer)

        do i = 1, NUM_COMPONENTS
            if(x(i) > 0) then
                residual(i) = abs(dlog((x_o(i)*L + x_g(i)*(1.0-L))/x(i)))
            else
                residual(i) = sqrt(x_o(i)**2 + x_g(i)**2)
            end if
        end do

        call getFugacityCoef(P, x_o, x_g, phil, phig)

        if(L > 1.D0-THRESHOLD) then
            res2W = 1.D0 - L
        elseif(L < THRESHOLD) then
            res2W = L
        end if

        do i = 1, NUM_COMPONENTS
            if(x(i) > 0) then
                if(L > 1.D0-THRESHOLD) then
                    residual(i+NUM_COMPONENTS) = &!
                        abs(dlog((x_o(i)*phil(i))/(x_g(i)*phig(i))))*res2W + &!
                        (sqrt((x_o(i)-x(i))**2+x_g(i)**2))*(1.D0-res2W)
                elseif(L < THRESHOLD) then
                    residual(i+NUM_COMPONENTS) = &!
                        abs(dlog((x_o(i)*phil(i))/(x_g(i)*phig(i))))*res2W + &!
                        (sqrt((x_g(i)-x(i))**2+x_o(i)**2))*(1.D0-res2W)
                else
                    residual(i+NUM_COMPONENTS) = abs(dlog((x_o(i)*phil(i))/(x_g(i)*phig(i))))
                end if
            else
                residual(i+NUM_COMPONENTS) = 0.D0
            end if
        end do

        deallocate(x)
        deallocate(x_o)
        deallocate(x_g)
        deallocate(phil)
        deallocate(phig)

    end subroutine getEquResidual

end module RST_getEquResidual

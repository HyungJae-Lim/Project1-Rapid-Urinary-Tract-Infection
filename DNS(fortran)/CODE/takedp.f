c*************** TAKEDP ********************************
      SUBROUTINE TAKEDP(DP)
      INCLUDE 'dctbl.h'
      COMMON/WAVK13/AK1(M1),AK3((m3-1)/2+1)
      COMMON/METPOI/PMJ(M2),PCJ(M2),PPJ(M2)

      COMMON/FFTW/plan_x1_forward,   plan_x1_backward
     >           ,plan_x3_forward_1d,plan_x3_backward_1d

      REAL DP(M1,M2,M3)
      REAL FDP(0:M1,0:M2,M3+1)
      REAL CPJ(M1,M2),CCJ(M1,M2),CMJ(M1,M2)

c     variables for using FFTW
      INTEGER*8 plan_x1_forward,plan_x1_backward
     >         ,plan_x3_forward_1d,plan_x3_backward_1d
      REAL*8 COX1(M1-1)
      COMPLEX*16 COEF(M3-1)
      INTEGER fftw_forward
      PARAMETER (fftw_forward=-1)
      INTEGER fftw_backward
      PARAMETER (fftw_backward=+1)
      INTEGER fftw_redft01
      PARAMETER (fftw_redft01=4)
      INTEGER fftw_redft10
      PARAMETER (fftw_redft10=5)
      INTEGER fftw_estimate
      PARAMETER (fftw_estimate=64)

      IF(NTIME.EQ.NSTART) THEN
        call dfftw_plan_with_nthreads(8)

        call dfftw_plan_dft_1d(plan_x3_forward_1d,n3m,coef,coef
     >                        ,fftw_forward,fftw_estimate)
        call dfftw_plan_dft_1d(plan_x3_backward_1d,n3m,coef,coef
     >                        ,fftw_backward,fftw_estimate)
        call dfftw_plan_r2r_1d(plan_x1_forward,n1m,cox1,cox1
     >                        ,fftw_redft10,fftw_estimate)
        call dfftw_plan_r2r_1d(plan_x1_backward,n1m,cox1,cox1
     >                        ,fftw_redft01,fftw_estimate)
      ENDIF

C     COSINE TRANSFORM OF RDP IN X1 DIRECTION
!$omp parallel do
!$omp& private(
!$omp&  i,j,k
!$omp& ,cox1
!$omp& )
!$omp& default(shared)
      do k = 1 , n3m
       do j = 1 , n2m
        do i = 1 , n1m
          cox1(i) = dp(i,j,k)
        enddo
        call dfftw_execute_r2r(plan_x1_forward,cox1,cox1)
        do i = 1 , n1m
          dp(i,j,k) = cox1(i)
        enddo
       enddo
      enddo

C     FFT OF RDP IN X3 DIRECTION
      n3mh = n3m / 2 + 1
!$omp parallel do
!$omp& private(
!$omp&  i,j,k
!$omp& ,coef
!$omp& ,ki,kr
!$omp& )
!$omp& default(shared)
      do j = 1 , n2m
       do i = 1 , n1m
        do k = 1 , n3m
          coef(k) = cmplx(dp(i,j,k),0.0)      ! MAKE COMPLEX VARIABLE
        enddo
        call dfftw_execute_dft(plan_x3_forward_1d,coef,coef)
!     REDUCE FOURIER COMPONENT N3M->N3MH ; USING F_-K=F*_K
        do k = 1 , n3mh
          kr = 2 * k - 1
          ki = 2 * k
          fdp(i,j,kr) = real (coef(k))        ! REAL COMPONENT
          fdp(i,j,ki) = aimag(coef(k))        ! IMAGINARY COMPONENT
        enddo
       enddo
      enddo

C     SOLVE FDP BY USING TDMA IN X2-DIRECTION
!$omp parallel do
!$omp& private(i,j,k,kr,ki,cmj,ccj,cpj)
!$omp& default(shared)
!     REAL PART CALCULATION
      do k = 1 , n3mh
        kr = 2 * k - 1
        do j = 1 , n2m
          do i = 1 , n1m
            cmj(i,j) = pmj(j)
            ccj(i,j) = pcj(j) - ak1(i) - ak3(k)
            cpj(i,j) = ppj(j)
          enddo
        enddo
        call tdmap(cmj,ccj,cpj,fdp(0,0,kr),n2m,n1m,k)

!     IMAG PART CALCULATION
        ki = 2 * k
        do j = 1 , n2m
          do i = 1 , n1m
            cmj(i,j) = pmj(j)
            ccj(i,j) = pcj(j) - ak1(i) - ak3(k)
            cpj(i,j) = ppj(j)
          enddo
        enddo
        call tdmap(cmj,ccj,cpj,fdp(0,0,ki),n2m,n1m,k)
      enddo

C     INVERSE FFT OF FDP IN X3 DIRECTION
!$omp parallel do
!$omp& private(
!$omp&  i,j,k
!$omp& ,coef
!$omp& ,kr,ki,kk
!$omp& )
!$omp& default(shared)
      do j = 1 , n2m
       do i = 1 , n1m
        do k = 1 , n3mh
          kr = 2 * k - 1
          ki = 2 * k
          coef(k) = cmplx(fdp(i,j,kr),fdp(i,j,ki))
        enddo
        do k = n3mh+1 , n3m
          kk = n3m-k+2
          coef(k) = conjg(coef(kk))
        enddo
        call dfftw_execute_dft(plan_x3_backward_1d,coef,coef)
        do k = 1 , n3m
          dp(i,j,k) = real(coef(k))/real(n3m)
        enddo
       enddo
      enddo

C     INVERSE COSINE TRANSFORM OF CDP IN X1 DIRECTION
!$omp parallel do
!$omp& private(
!$omp&  i,j,k
!$omp& ,cox1
!$omp& )
!$omp& default(shared)
      do k = 1 , n3m
       do j = 1 , n2m
        do i = 1 , n1m
          cox1(i) = dp(i,j,k)
        enddo
        call dfftw_execute_r2r(plan_x1_backward,cox1,cox1)
        do i = 1 , n1m
          dp(i,j,k) = cox1(i)*0.5/real(n1m)
        enddo
       enddo
      enddo

      RETURN
      END


!     *******************************************************
!     START SUBROUTINE TDMAP ********************************
!     *******************************************************
      subroutine tdmap(a,b,c,x,njf,nif,k)
      INCLUDE 'dctbl.h'
      real::
     >  a(m1,m2),b(m1,m2),c(m1,m2)
     > ,x(0:m1,0:m2)
     > ,bet
     > ,gam(m1,m2)
      integer::i,j,njf,nif,k

      if ( k == 1 ) then
       a(1,1) = 0.0
       b(1,1) = 1.0
       c(1,1) = 0.0
       x(1,1) = 0.0
      end if

      j = 1
      do i = 1 , nif
       bet      = 1.0    / b(i,j)
       gam(i,j) = c(i,j) * bet
       x(i,j)   = x(i,j) * bet
      end do

      do j = 2 , njf
      do i = 1 , nif
       bet      = 1.0 / ( b(i,j) - a(i,j) * gam(i,j-1) )
       gam(i,j) = c(i,j) * bet
       x(i,j)   = ( x(i,j) - a(i,j) * x(i,j-1) ) * bet
      end do
      end do

      do j = njf - 1 , 1 , -1
      do i = 1 , nif
       x(i,j) = x(i,j) - x(i,j+1) * gam(i,j)
      end do
      end do

      return
      end subroutine tdmap
!     =======================================================
!     END SUBROUTINE TDMAP ==================================
!     =======================================================

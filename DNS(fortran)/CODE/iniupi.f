
C  ************* INIUPI **********************
C     INIUP in make_ini.f

      SUBROUTINE INIUPI(UHI,P)

      INCLUDE 'dctbl.h'

      REAL UHI(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)
      REAL UM(3,0:M1,0:M2),RDNUM(3)

!      INTEGER*4 SEED,iseed(4)

      INTEGER SEED,iseed(4)

      PI=ACOS(-1.0)

      DO 10 NV=1,3
      DO 10 I=0,N1
      DO 10 J=0,N2
      DO 10 K=1,N3M
10    UHI(I,J,K,NV)=0.0

      THETA=R_theta_in/RE ! modified R_theta_in <- Re_theta_in

      DO 20 I=1,N1

      IF (I.GT.1) then
      THETA=THETA+(1./RAMDA**2)/DX1   ! From Eq.(35)
      ENDIF

      Re_th=RE*theta

      CALL GET_RAMDA(Re_th,RAMDA,I)
 
      CALL GET_UM(UM,RAMDA,I)

20    CONTINUE

c     calculate the V mean

      DO 40 I=1,N1M
      UM(2,I,1)=0.0   !at the wall
      DO 41 J=2,N2M
      UM(2,I,J)=UM(2,I,J-1)+DY(J)*DX1
     >         *(UM(1,I+1,J-1)-UM(1,I,J-1))
41    CONTINUE
      UM(2,I,N2)=UM(2,I,N2M)
40    continue
      DO 42 J=1,N2
      UM(2,0,j)=UM(2,1,j)
42    UM(2,N1,j)=UM(2,N1M,j)

      DO 50 I=0,N1
      DO 50 J=0,N2
50    UM(3,I,J)=0.0

      DO 21 K=1,N3M
      DO 21 J=1,N2M
      UBC3(1,J,K)=UM(1,1,J)
      UBC3(2,J,K)=UM(2,1,J)
      UBC3(3,J,K)=0.0
      UBC4(1,J,K)=um(1,N1,j)
      UBC4(2,J,K)=um(2,N1,j)
21    UBC4(3,J,K)=0.0

      FLOW_IN=0.0
      FLOW_EX=0.0
      DO 22 K=1,N3M
      DO 22 J=1,N2M
      FLOW_IN=FLOW_IN+UBC3(1,J,K)*DY(j)/DX3
22    FLOW_EX=FLOW_EX+UBC4(1,J,K)*DY(j)/DX3

      V_UP=(FLOW_IN-FLOW_EX)/ALZ/ALX

      WRITE(*,*) 'Q_UP=',V_UP*ALX*ALZ
      DO 23 I=1,N1
      DO 23 K=1,N3M
      UBC2(1,I,K)=1.
      UBC2(2,I,K)=V_UP
      UBC2(3,I,K)=0.
      UBC1(1,I,K)=0.0
      UBC1(2,I,K)=0.0
23    UBC1(3,I,K)=0.0

C---  RANDOM FLUCTUATIONS
C     Random Number Generation in MKL
C     Math Kernel Library Manual pp.5-182 ~5-183
C     call dlarnv(idist, iseed, n, x)
C     idist INTEGER.iseed On exit, the seed is updated.
C          =1:uniform(0,1)
C          =2:uniform(-1,1)
C          =3:normal(0,1)
C     iseed INTEGER, Array, DIMENSION(4)
C           On entry, the seed of the random number generator;     
C           the array elements
C           must be between 0 and 4095, and iseed(4) must be odd.
C     n integer. The number of random numbers to be generated.
C     x DOUBLE PRECISION for dlarnv, Array, DIMENSION(n)
C           The generated random numbers.

      ISEED(1) = 1001
      ISEED(2) = 2001
      ISEED(3) = 3001
      ISEED(4) = 4001

      do 30 NV=1,3
      do 30 I=0,N1
      do 30 J=1,N2
      IF (Y(J).LE.10.0) THEN
      WPER=Y(J)/10.0
      ELSE IF (Y(J).LE.15.0) THEN
      WPER=1.-(Y(J)-10.0)/5.0
      ELSE
      WPER=0.0
      ENDIF
      do 31 K=1,N3M
       call DLARNV(2,ISEED,3,RDNUM)
       UHI(I,J,K,NV)=
     >            VPER * WPER * RDNUM(nv)
!     >            VPER*WPER
!     >           *(RAND()-RAND())  !ibm
31    CONTINUE
      VMEAN=0.0
      DO 32 K=1,N3M
32    VMEAN=VMEAN+UHI(I,J,K,NV)/REAL(N3M)
      DO 33 k=1,N3M
33    UHI(I,J,K,NV)=UHI(I,J,K,NV)-VMEAN

30    CONTINUe

      DO 140 NV=1,3
      Do 140 I=0,N1
      DO 140 J=1,N2
      DO 140 K=1,N3M
140   UHI(I,J,K,NV)=UM(NV,I,J)+UHI(I,J,K,NV)

C     IMPOSE ZERO-PRESSURE FLUCTUATIONS
      DO 60 I=1,N1M
      DO 60 J=1,N2M
      DO 60 K=1,N3M
      P(I,J,K)=0.0
   60 CONTINUE

      RETURN
      END


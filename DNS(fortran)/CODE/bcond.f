
c***************** BCOND ***********************     
      SUBROUTINE BCOND(U)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)

      PI=ACOS(-1.)

      IF (ITYPE.EQ.0) THEN
C------ FOR INFLOW GENERATION -----------------------------------------
c     Inlet boundary conditions
      Call Rescaling(U)

!$omp parallel do
      DO 10 K=1,N3M
      DO 10 I=1,N1

c     Lower Wall boundary conditions
      UBC1(1,I,K)=0.0  ! U(I,0,K,1)  Lower WALL : No-slip condition
      UBC1(2,I,K)=0.0  ! U(I,1,K,2) 
      UBC1(3,I,K)=0.0  ! U(I,0,K,3)

c     Upper Wall boundary conditions
      UBC2(1,I,K)=U(I,N2M,K,1)  ! U(I,N2,K,1)
      UBC2(3,I,K)=U(I,N2M,K,3)  ! U(I,N2,K,3)
    ! UBC2(2,I,K) is defined later 
 10   CONTINUE
!$omp end parallel do

      ELSE
C------ FOR MAIN SIMULATION --------------------------------------------
!$omp parallel do

      DO 11 K=1,N3M
      DO 11 I=1,N1


c     Lower Wall boundary conditions
      UBC1(1,I,K)=0.0  ! U(1,I,0,K)  Lower WALL : No-slip condition
      UBC1(2,I,K)=0.0  ! U(2,I,1,K) 
      UBC1(3,I,K)=0.0  ! U(3,I,0,K)

c     Upper Wall boundary conditions
      UBC2(1,I,K)=1.0  ! U(I,N2,K,1)
      UBC2(2,I,K)=U(I,N2M,K,2)  ! U(I,N2,K,2)
      UBC2(3,I,K)=U(I,N2M,K,3)  ! U(I,N2,K,3)

 11   CONTINUE
!$omp end parallel do


c     Inlet boundary conditions
      
      IF (IFORINF.EQ.0) THEN ! INFLOW DATA : UNFORMATTED FORM

      READ (81)((UBC3(1,J,K),J=1,n2m),K=1,N3M) ! U(1,J,K,1) INLET BOUNDARY  ^M
     >          ,((UBC3(2,J,K),J=2,n2m),K=1,N3M) ! U(0,J,K,2) INLET BOUNDARY ^M
     >          ,((UBC3(3,J,K),J=1,n2m),K=1,N3M) ! U(0,J,K,3) INLET BOUNDARY ^M

      ELSE                   ! INFLOW DATA : FORMMATED FORM
      DO 40 K=1,N3M
      J=1
      READ (81,200) UBC3(1,J,K),UBC3(3,J,K)
      DO 40 J=2,N2M
      READ (81,201) UBC3(1,J,K),UBC3(2,J,K),UBC3(3,J,K)
40    CONTINUE 
200   FORMAT(2(E15.7,2x)) 
201   FORMAT(3(E15.7,2x)) 
      ENDIF ! FOR IFORINF

      ENDIF ! FOR ITYPE

C     CONVECTIVE BOUNDARY CONDITION FOR OUTLET IN X1 DIRECTION
      UC=0.0     
!$omp parallel do reduction(+:UC)
      DO 31 K=1,N3M
      DO 31 J=1,N2M
      UC=UC+U(N1,J,K,1)*DY(J)/DX3
31    CONTINUE
      UC=UC/ALZ/ALY            ! BULK VELOCITY
!$omp parallel do
      DO 32 K=1,N3M
      DO 32 J=1,N2M
      UBC4(1,J,K)=U(N1,J,K,1)-DT*DX1*UC*(U(N1,J,K,1)-U(N1M,J,K,1))  ! U(1,N1,J,K)
      UBC4(2,J,K)=U(N1,J,K,2)-DT*DX1*UC*(U(N1,J,K,2)-U(N1M,J,K,2))  ! U(2,N1,J,K)
32    UBC4(3,J,K)=U(N1,J,K,3)-DT*DX1*UC*(U(N1,J,K,3)-U(N1M,J,K,3))  ! U(3,N1,J,K)

C     THE INTERGAL OF MASS FLUX MUST BE ZERO!!!!
      Q_IN=0.
      Q_UP=0.
      Q_DOWN=0.
      Q_EX=0.
!$omp parallel do reduction(+:Q_IN,Q_UP,Q_DOWN,Q_EX)
      DO 35 K=1,N3M
      DO 33 J=1,N2M
      Q_IN=Q_IN+UBC3(1,J,K)*DY(J)/DX3
33    Q_EX=Q_EX+UBC4(1,J,K)*DY(J)/DX3

c     DO 35 K=1,N3M
      DO 35 I=1,N1M
      Q_UP=Q_UP+UBC2(2,I,K)/DX1/DX3
35    Q_DOWN=Q_DOWN+UBC1(2,I,K)/DX1/DX3
     
      Write(*,*) 
      Write(*,100) q_in,q_up,q_ex
      Write(22,99) time,q_in,q_up,q_ex
99    Format(4(e15.7,x))
100   Format('mass flux : Q_IN=',e10.4,x,'Q_UP=',e10.4,x,'Q_EX=',e10.4)

      RATE=(Q_IN+Q_DOWN-Q_UP)/Q_EX
 
!$omp parallel do
      DO 34 K=1,N3M
      DO 34 J=1,N2M
      UBC4(1,J,K)=RATE*UBC4(1,J,K)
      UBC4(2,J,K)=RATE*UBC4(2,J,K)
34    UBC4(3,J,K)=RATE*UBC4(3,J,K)

      RETURN
      END

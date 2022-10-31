
c**************** FORCING *************************
c     by S.H.LEE
      SUBROUTINE FORCING(U,P,F)
      INCLUDE 'dctbl.h'

      Real U(0:M1,0:M2,0:M3,3)
      Real P(M1,M2,M3)
      Real F(M1,M2,M3,3)
      Real UT(0:M1,0:M2,0:M3,3)
      save UT

!      Tfor=100.  ! ADDED at 2004/12/04

      IF (IMFOR.EQ.0) THEN     ! smooth wall
!$omp parallel do
      DO L=1,3
      DO K=1,N3M
      DO J=1,N2M
      DO I=1,N1M
      F(I,J,K,L)=0.0
      ENDDO
      ENDDO
      ENDDO
      ENDDO
!$omp end parallel do
      
      ELSE 

      IF (TIME-6000.LE.Tfor/10) THEN
      Write (*,*) 'F=0'
!$omp parallel do
      DO L=1,3
      DO K=1,N3M
      DO J=1,N2M
      DO I=1,N1M
      F(I,J,K,L)=0.0
      ENDDO
      ENDDO
      ENDDO
      ENDDO
!$omp end parallel do

      ELSE 

      CALL EXPLICITA(U,P,UT)
      CALL EXPLICITB(U,P,UT,F)

c---------------------------------------------
      
      IF (TIME-6000.LE.Tfor) THEN
      Write (*,*) 'F=F*',(TIME-6000)/Tfor
!$omp parallel do
      DO L=1,3
      DO K=1,N3M
      DO J=1,N2M
      DO I=1,N1M
      F(I,J,K,L)=F(I,J,K,L)*(TIME-6000)/Tfor
      ENDDO
      ENDDO
      ENDDO
      ENDDO
!omp end parallel do
      ENDIF ! for TIME.LE.Tfor
 
      ENDIF ! for TIME.LE.Tfor/10
c-------------------------------------------- 
      ENDIF ! for IMFOR
      
      RETURN
      END

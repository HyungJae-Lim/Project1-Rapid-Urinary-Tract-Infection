      

c***************** INITFQ ********************
c     by S.H.LEE
      SUBROUTINE INITFQ(F)
      INCLUDE 'dctbl.h'
     
      REAL F(M1,M2,M3,3)

!$omp parallel do 
      DO 10 K=1,N3M
      DO 10 J=1,N2M
      DO 10 I=1,N1M
      F(I,J,K,1)=0.0
      F(I,J,K,2)=0.0
      F(I,J,K,3)=0.0
!      Q(I,J,K)=0.0
 10   CONTINUE
      RETURN
      END

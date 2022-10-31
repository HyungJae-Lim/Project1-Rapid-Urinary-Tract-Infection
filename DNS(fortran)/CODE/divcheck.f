

c***************** DIVCHECK ***********************    
      SUBROUTINE DIVCHECK(U,DIVMAX) 
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      
      DIVMAX=0.0

!$omp parallel do private(KP,KM,DIV) reduction(max:DIVMAX)
      DO 20 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      DO 20 J=1,N2M
      DO 20 I=1,N1M
 !    modifiend by S.H.LEE
      DIV=ABS((U(I+1,J  ,K ,1)-U(I,J,K,1))*DX1
     >       +(U(I  ,J+1,K ,2)-U(I,J,K,2))/DY(J)
     >       +(U(I  ,J  ,KP,3)-U(I,J,K,3))*DX3-Q(I,J,K)) 
      
!      IF (DIV.GT.DIVMAX) THEN
!      IMAX=I
!      JMAX=J
!      KMAX=K
!      ENDIF
      DIVMAX=AMAX1(DIV,DIVMAX)
  20  CONTINUE
!      WRITE(*,*) IMAX,JMAX,KMAX,DIVMAX 
      RETURN
      END

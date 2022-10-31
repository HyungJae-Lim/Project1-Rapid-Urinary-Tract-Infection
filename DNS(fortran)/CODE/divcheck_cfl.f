

c***************** DIVCHECK ***********************    
      SUBROUTINE DIVCHECK_CFL(U,DIVMAX,CFLM )
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      
      DIVMAX=0.0
      CFLM=0.0

!$omp parallel do private(KP,KM,IP,JP,DIV) reduction(max:DIVMAX,CFLM)
      DO 20 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      DO 20 J=1,N2M
         JP=J+1
      DO 20 I=1,N1M
         IP=I+1
 !    modifiend by S.H.LEE
      DIV= ABS((U(IP,J ,K ,1)-U(I,J,K,1))*DX1
     >        +(U(I ,JP,K ,2)-U(I,J,K,2))/DY(J)
!     >        +(U(I ,J ,KP,3)-U(I,J,K,3))*DX3-Q(I,J,K)) 
     >        +(U(I ,J ,KP,3)-U(I,J,K,3))*DX3) 
      CFLL= ABS(U(I,J,K,1)+U(IP,J ,K ,1))*0.5*DX1
     >     +ABS(U(I,J,K,2)+U(I ,JP,K ,2))*0.5/DY(J)
     >     +ABS(U(I,J,K,3)+U(I ,J ,KP,3))*0.5*DX3
      
!      IF (DIV.GT.DIVMAX) THEN
!      IMAX=I
!      JMAX=J
!      KMAX=K
!      ENDIF
      DIVMAX=AMAX1(DIV,DIVMAX)
      CFLM=AMAX1(CFLM,CFLL)
  20  CONTINUE
!      WRITE(*,*) 'DIVMAX at ',IMAX,JMAX,KMAX,DIVMAX 
      RETURN
      END

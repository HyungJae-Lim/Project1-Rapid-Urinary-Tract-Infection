
c*********************** CFL ***********************
c     This subroutine calculate the maximum local CFL number
c     devided by DT
c     AT THE CELL CENTER
c
      SUBROUTINE CFL(U,CFLM)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      CFLM=0.0
!$omp parallel do private(KP,JP,IP,CFLL) reduction(max:CFLM)
      DO 10 K=1,N3M
         KP=KPA(K)
      DO 10 J=1,N2M
         JP=J+1
      DO 10 I=1,N1M
         IP=I+1
      CFLL= ABS(U(I,J,K,1)+U(IP,J ,K ,1))*0.5*DX1
     >     +ABS(U(I,J,K,2)+U(I ,JP,K ,2))*0.5/DY(J)
     >     +ABS(U(I,J,K,3)+U(I ,J ,KP,3))*0.5*DX3
      CFLM=AMAX1(CFLM,CFLL)
 10   CONTINUE

      RETURN
      END

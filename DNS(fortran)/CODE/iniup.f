
C  ************* INIUP **********************
      SUBROUTINE INIUP(U,P)
      
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL UHI(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)
      REAL DPI(M1,M2,M3)
      REAL RDPI(M1,M2,M3)
      save UHI,DPI,RDPI

      INTEGER*4 SEED
      REAL NXZ
      PI=ACOS(-1.0)     

      write(*,*) 'call INIUPI'

      CALL INIUPI(UHI,P)

      write(*,*) 'iniupi done'
    
      OPEN(31,FILE='OUTPUT/INI_UH.plt',STATUS='UNKNOWN')
      WRITE(31,*) 'VARIABLES=Y,U,V,W'
      I=N1M/2
      K=N3M/2
      DO 11 J=0,N2M
      YY=0.5*(Y(J)+Y(J+1))
      WRITE(31,111) YY,UHI(I,J,K,1),UHI(I,J,K,2),UHI(I,J,K,3)
   11 CONTINUE
      CLOSE(31)
111   FORMAT(4(E12.5),X)

      DIVMAX1=0.0

!$omp parallel do private(KP,KM,DIV) reduction(max:DIVMAX1)
      DO 20 K=1,N3M
      KP=KPA(K)
      KM=KMA(K)
      DO 20 J=1,N2M
      DO 20 I=1,N1M
      DIV=ABS((UHI(I+1,J,K,1)-UHI(I,J,K,1))*DX1
     >       +(UHI(I,J+1,K,2)-UHI(I,J,K,2))/DY(J)
     >       +(UHI(I,J,KP,3)-UHI(I,J,K,3))*DX3)
      DIVMAX1=AMAX1(DIV,DIVMAX1)
  20  CONTINUE

      CALL RHSDPI(DPI,UHI)
      CALL TAKEDPI(DPI)
      CALL UPCALCI(U,P,UHI,DPI)

      DIVMAX2=0.0

!$omp parallel do private(KP,KM,DIV) reduction(max:DIVMAX2)
      DO 30 K=1,N3M
      KP=KPA(K)
      KM=KMA(K)
      DO 30 J=1,N2M
      DO 30 I=1,N1M
      DIV=ABS((U(I+1,J,K,1)-U(I,J,K,1))*DX1
     >       +(U(I,J+1,K,2)-U(I,J,K,2))/DY(J)
     >       +(U(I,J,KP,3)-U(I,J,K,3))*DX3)
      DIVMAX2=AMAX1(DIV,DIVMAX2)
  30  CONTINUE
      
      WRITE(*,*) 'INITIAL FILED DIVMAX1 & 2 =',DIVMAX1,DIVMAX2
      
      OPEN(30,FILE='OUTPUT/INI_XY.plt',STATUS='UNKNOWN')
      WRITE(30,*) 'VARIABLES=X,Y,U,V,W'
      wRITE(30,*) 'ZONE I=',N1,', J=',N2,', F=POINT'
      DO 10 J=0,N2M
      YY=0.5*(Y(J)+Y(J+1))
      DO 10 I=1,N1
      XX=ALX*REAL(I-1)/REAL(N1M)
      WRITE(30,100) XX,YY,U(I,J,N3M,1),U(I,J,N3M,2),U(I,J,N3M,3)
10    CONTINUE
      CLOSE(30)

      OPEN(31,FILE='OUTPUT/INI_U.plt',sTATUS='UNKNOWN')
      WRITE(31,*) 'VARIABLES=Y,U,V,W'
      I=N1M/2
      DO 22 J=0,N2M
      YY=0.5*(Y(J)+Y(J+1))
      WRITE(31,110) YY,U(I,J,N3M,1),U(I,J,N3M,2),U(I,J,N3M,3)
   22 CONTINUE
      CLOSE(31)
100   FORMAT(5(E12.5,X))
110   FORMAT(4(E12.5,X))


!      IF (NWRITE.EQ.1) THEN
!      WRITE(*,*) 'WRITING INITIAL DATA'
!      CALL WRITEUP(U,P)
!      ENDIF      
     
!      DO 10 NV=1,3
!      DO 10 K=1,N3M
!      DO 10 J=0,N2
!      DO 10 I=0,N1
!10    U(I,J,K,NV)=0.0

!C     IMPOSE U VELOCITY
!      DO 20 K=1,N3M
!      DO 20 I=1,N1
!      DO 20 J=1,N2M
!      U(I,J,K,1)=2.0/3.0
!20    CONTINUE

!C     IMPOSE ZERO-PRESSURE FLUCTUATIONS
!      DO 60 K=1,N3M
!      DO 60 J=1,N2M
!      DO 60 I=1,N1M
!      P(I,J,K)=0.0
!   60 CONTINUE

      RETURN
      END

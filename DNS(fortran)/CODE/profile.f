
C*************** PROFILE ***********************
      SUBROUTINE PROFILE(U,P)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)

! ADDED by S.H.LEE   
c  --------------------------------------------
      REAL NZ 
      REAL UZ(3,0:M1,0:M2),PZ(M1,M2)
      REAL WSBM(M1)

      NZ=1./REAL(N3M)
      DO 1 J=1,N2
      DO 1 I=1,N1M
      UZ(1,I,J)=0.0
      UZ(2,I,J)=0.0
      UZ(3,I,J)=0.0
      PZ(I,J)=0.0
ccc   DO 1 I=1,N1M
      UZ(1,I,0)=0.0
      UZ(3,I,0)=0.0
      DO 2 K=1,N3M
      UZ(1,I,J)=UZ(1,I,J)+U(I,J,K,1)
      UZ(2,I,J)=UZ(2,I,J)+U(I,J,K,2)
      UZ(3,I,J)=UZ(3,I,J)+U(I,J,K,3)
      PZ(I,J)=PZ(I,J)+P(I,J,K)
    2 CONTINUE
      UZ(1,I,J)=UZ(1,I,J)*NZ
      UZ(2,I,J)=UZ(2,I,J)*NZ
      UZ(3,I,J)=UZ(3,I,J)*NZ
      PZ(I,J)=PZ(I,J)*NZ
    1 CONTINUE
    
      OPEN (12,FILE='OUTPUT/PROF_U.plt',STATUS='UNKNOWN')
      OPEN (13,FILE='OUTPUT/PROF_V.plt',STATUS='UNKNOWN')
      OPEN (14,FILE='OUTPUT/PROF_W.plt',STATUS='UNKNOWN')
      OPEN (15,FILE='OUTPUT/PROF_P.plt',STATUS='UNKNOWN')
      OPEN (16,FILE='OUTPUT/PROF_Cf.plt',STATUS='UNKNOWN')
      OPEN (17,FILE='OUTPUT/PROF_Cp.plt',STATUS='UNKNOWN')

      X2=0.0
      I1=IPROF1
      I2=IPROF2
      I3=IPROF3
      I4=IPROF4
      I5=IPROF5
      I6=IPROF6

      WRITE(12,400) X2,UZ(1,I1,0),UZ(1,I2,0),UZ(1,I3,0)
     >                ,UZ(1,I4,0),UZ(1,I5,0),UZ(1,I6,0)
      WRITE(14,400) X2,UZ(3,I1,0),UZ(3,I2,0),UZ(3,I3,0)
     >                ,UZ(3,I4,0),UZ(3,I5,0),UZ(3,I6,0)
      DO 3 J=1,N2
      X2=X2+H(J)
      WRITE(12,400) X2,UZ(1,I1,J),UZ(1,I2,J),UZ(1,I3,J)
     >                ,UZ(1,I4,J),UZ(1,I5,J),UZ(1,I6,J)
      WRITE(13,400) Y(J),UZ(2,I1,J),UZ(2,I2,J),UZ(2,I3,J)
     >                  ,UZ(2,I4,J),UZ(2,I5,J),UZ(2,I6,J)
      WRITE(14,400) X2,UZ(3,I1,J),UZ(3,I2,J),UZ(3,I3,J)
     >                ,UZ(3,I4,J),UZ(3,I5,J),UZ(3,I6,J)
      IF (J.NE.N2) THEN
      WRITE(15,400) X2,PZ(I1,J),PZ(I2,J),PZ(I3,J)
     >                ,PZ(I4,J),PZ(I5,J),PZ(I6,J)
      ENDIF
    3 CONTINUE
  400 FORMAT(7(E12.5,2X))
      CLOSE(12)
      CLOSE(13)
      CLOSE(14)
      CLOSE(15)


      CLOSE(17) 
      
!----------------------------------------------------------      
      
      
      
!      OPEN (10,FILE='MONI_U.plt',STATUS='UNKNOWN')
     
!      MONI1=N1M/5*0+1
!      MONI2=N1M/5*1+1
!      MONI3=N1M/5*2+1
!      MONI4=N1M/5*4-1
!      MONI1=IB
!      MONI2=IB+1*IL
!      MONI3=IB+2*IL
!      MONI4=IB+3*IL
      
!      WRITE(10,100) Y(1),U(1,MONI1,0,N3M/2),U(1,MONI2,0,N3M/2)
!     >             ,U(1,MONI3,0,N3M/2),U(1,MONI4,0,N3M/2)
!      DO 10 J=1,N2M
!      X2=0.5*(Y(J)+Y(J+1))
!10    WRITE(10,100) X2,U(1,MONI1,J,N3M/2),U(1,MONI2,J,N3M/2)
!     >             ,U(1,MONI3,J,N3M/2),U(1,MONI4,J,N3M/2)
!      WRITE(10,100) Y(N2),U(1,MONI1,N2,N3M/2),U(1,MONI2,N2,N3M/2)
!     >             ,U(1,MONI3,N2,N3M/2),U(1,MONI4,N2,N3M/2)
!100   FORMAT (5(E12.5,2X))
!      CLOSE(10)
     
!      OPEN (11,FILE='MONI_UC.plt',STATUS='UNKNOWN')
!      DO 20 I=1,N1
!      X1=(REAL(I)-1.)/REAL(N1M)*ALX
!20    WRITE(11,200) X1,U(1,I,N2M/2,N3M/2),P(I,N2M/2,N3M/2) 
!200   FORMAT (3(E12.5,2X))
!      CLOSE(11)

!      OPEN (12,FILE='MONI_P.plt',STATUS='UNKNOWN')
!      DO 30 I=1,N1M
!      X1=(REAL(I)-1.)/REAL(N1M)*ALX
!30    WRITE(12,300) X1,P(I,1,N3M/2),P(I,1,N3M),P(I,N2M,N3M/2),
!     >                 P(I,N2M,N3M) 
!300   FORMAT (5(E12.5,2X))
!      CLOSE(12)
      RETURN
      END

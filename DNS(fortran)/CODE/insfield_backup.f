
C*************** INSFIELD ***********************
      SUBROUTINE INSFIELD(U,P)
      INCLUDE 'dctbl.h'

      CHARACTER*80 FILEW1,FILEW2,FILEW3

      REAL U(0:M1,0:M2,0:M3,3)
      REAL VOR(3,M1,M2,M3)
      REAL UC(M1,M2,M3,3)
      REAL P(M1,M2,M3)
      save UC
      save VOR

      FILEW1='OUTPUT/INS_1.'
      FILEW2='OUTPUT/INS_2.'
      FILEW3='OUTPUT/INS_3.'

      N=INDEX(FILEW1,'.')
      WRITE(UNIT=FILEW1(N+1:),FMT='(BN,I6.6)') NTIME
      WRITE(UNIT=FILEW2(N+1:),FMT='(BN,I6.6)') NTIME
      WRITE(UNIT=FILEW3(N+1:),FMT='(BN,I6.6)') NTIME


      N1_S1=IB-20
      N1_E1=IB+4*IL
      N2_S1=1
      N2_E1=120
 
      N1_S2=IB+23*IL
      N1_E2=IB+27*IL
      N2_S2=1
      N2_E2=140

      N1_S3=IB+43*IL
      N1_E3=IB+47*IL
      N2_S3=1
      N2_E3=160

!$omp  parallel do private(IP,IM,JP,JM,JUM,JUP,KP,KM,U1KP,U1KM,
!$omp& U2KP,U2KM,U2IP,U2IM,U3IP,U3IM,U1JP,U1JC,U1JM,U12,U11,U3JP, 
!$omp& U3JC,U3JM,U32,U31,DV3DX2,DV2DX3,DV3DX1,DV1DX3,DV2DX1,
!$omp& DV1DX2)

C     CALCULATE VORTICITY AT I+1/2,J+1/2,K+1/2
      DO 100 K=1,N3M/2
      KP=KPA(K)
      KM=KMA(K)
      DO 100 J=1,N2_E3
      JP=J+1
      JM=J-1
      JUM=J-JMU(J)
      JUP=JPA(J)-J
      DO 100 I=N1_S1,N1_E3
      IP=I+1
      IM=I-1

      UC(I,J,K,1)=(U(I,J,K,1)+U(IP,J,K,1))*0.5
      UC(I,J,K,2)=(U(I,J,K,2)+U(I,JP,K,2))*0.5
      UC(I,J,K,3)=(U(I,J,K,3)+U(I,J,KP,3))*0.5

      U1KP=0.5*(U(I,J,KP,1)+U(IP,J,KP,1))
      U1KM=0.5*(U(I,J,KM,1)+U(IP,J,KM,1))
      U2KP=0.5*(U(I,J,KP,2)+U(I,JP,KP,2))
      U2KM=0.5*(U(I,J,KM,2)+U(I,JP,KM,2))
      U2IP=0.5*(U(IP,J,K,2)+U(IP,JP,K,2))
      U2IM=0.5*(U(IM,J,K,2)+U(IM,JP,K,2))
      U3IP=0.5*(U(IP,J,K,3)+U(IP,J,KP,3))
      U3IM=0.5*(U(IM,J,K,3)+U(IM,J,KP,3))

      U1JP=0.5*(U(I,JP,K,1)+U(IP,JP,K,1))
      U1JC=0.5*(U(I,J ,K,1)+U(IP,J ,K,1))
      U1JM=0.5*(U(I,JM,K,1)+U(IP,JM,K,1))
      U12=0.5/H(JP)*(DY(JP)*U1JC+DY(J)*U1JP)
      U11=0.5/H(J )*(DY(J)*U1JM+DY(JM)*U1JC)
      U12=U12*JUP+(1-JUP)*U(I,N2,K,1)
      U11=U11*JUM+(1-JUM)*U(I,0 ,K,1)

      U3JP=0.5*(U(I,JP,K,3)+U(I,JP,KP,3))
      U3JC=0.5*(U(I,J ,K,3)+U(I,J ,KP,3))
      U3JM=0.5*(U(I,JM,K,3)+U(I,JM,KP,3))
      U32=0.5/H(JP)*(DY(JP)*U3JC+DY(J)*U3JP)
      U31=0.5/H(J )*(DY(J)*U3JM+DY(JM)*U3JC)
      U32=U32*JUP+(1-JUP)*U(I,N2,K,3)
      U31=U31*JUM+(1-JUM)*U(I,0 ,K,3)

      DV3DX2=(U32-U31)/DY(J)
      DV2DX3=(U2KP-U2KM)*0.5*DX3
      DV3DX1=(U3IP-U3IM)*0.5*DX1
      DV1DX3=(U1KP-U1KM)*0.5*DX3
      DV2DX1=(U2IP-U2IM)*0.5*DX1
      DV1DX2=(U12-U11)/DY(J)

      VOR(1,I,J,K)=DV3DX2-DV2DX3
      VOR(2,I,J,K)=DV1DX3-DV3DX1
      VOR(3,I,J,K)=DV2DX1-DV1DX2
  100 CONTINUE


      OPEN (11,FILE=FILEW1,STATUS='UNKNOWN')
      OPEN (12,FILE=FILEW2,STATUS='UNKNOWN')
      OPEN (13,FILE=FILEW3,STATUS='UNKNOWN')

      WRITE(11,*) 'ZONE I=',N1_E1-N1_S1+1,',J=',N2_E1-N2_S1+1
     >            ,',K=',N3M,', F=POINT'
      WRITE(12,*) 'ZONE I=',N1_E2-N1_S2+1,',J=',N2_E2-N2_S2+1
     >            ,',K=',N3M,', F=POINT'
      WRITE(13,*) 'ZONE I=',N1_E3-N1_S3+1,',J=',N2_E3-N2_S3+1
     >            ,',K=',N3M,', F=POINT'

      DO K=1,N3M/2
      X3=ALZ*REAL(K-0.5)/REAL(N3M)
      DO J=N2_S1,N2_E1
      X2=0.5*(Y(J)+Y(J+1))
      DO I=N1_S1,N1_E1
      X1=ALX*REAL(I-0.5)/REAL(N1M)
      
      WRITE(11,300) X1,X2,X3,(UC(I,J,K,L),L=1,3)
     >             ,P(I,J,K),(VOR(M,I,J,K),M=1,3)
      ENDDO
      ENDDO

      DO J=N2_S2,N2_E2
      X2=0.5*(Y(J)+Y(J+1))
      DO I=N1_S2,N1_E2
      X1=ALX*REAL(I-0.5)/REAL(N1M)
      WRITE(12,300) X1,X2,X3,(UC(I,J,K,L),L=1,3)
     >             ,P(I,J,K),(VOR(M,I,J,K),M=1,3)
      ENDDO
      ENDDO

      DO J=N2_S3,N2_E3
      X2=0.5*(Y(J)+Y(J+1))
      DO I=N1_S3,N1_E3
      X1=ALX*REAL(I-0.5)/REAL(N1M)
      WRITE(13,300) X1,X2,X3,(UC(I,J,K,L),L=1,3)
     >             ,P(I,J,K),(VOR(M,I,J,K),M=1,3)
      ENDDO
      ENDDO

      ENDDO

      CLOSE(11)
      CLOSE(12)
      CLOSE(13)

300   FORMAT(10(E12.5,2X))

      RETURN
      END

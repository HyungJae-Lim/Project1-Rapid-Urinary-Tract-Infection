C*************** AVERAGE **********************
      SUBROUTINE AVERAGE(U,P,NAVG)

      INCLUDE 'dctbl.h'


      REAL U(0:M1,0:M2,0:M3,3),P(M1,M2,M3)
      REAL NZ

      REAL VZ(3),VVZ(6),V3Z(3),P3Z(3)
      REAL V(3)
      REAL VOR(3),VORZ(3),VORQZ(3)

      NVV1(1)=1
      NVV2(1)=1
      NVV1(2)=2
      NVV2(2)=2
      NVV1(3)=3
      NVV2(3)=3
      NVV1(4)=1
      NVV2(4)=2
      NVV1(5)=1
      NVV2(5)=3
      NVV1(6)=2
      NVV2(6)=3

      RNAVG=DBLE(NAVG)
      NZ=1.0/DBLE(N3M)
      NXZ=1.0/DBLE(N1M*N3M)

!$omp  parallel do private(IP,IM,IUM,IUP,JP,JM,JUM,JUP,
!$omp& KP,KM,KPP,VZ,V3Z,VORZ,VORQZ,VVZ,P3Z,
!$omp& PZ,PPZ,P3Z,V,
!$omp& VOR,NV1,NV2,DV3DX2,DV2DX3,DV3DX1,DV1DX3,DV2DX1
!$omp& DV1DX2,U1KP,U1KM,U2KP,U2KM,U2IP,U2IM,U3IP,U3IM,
!$omp& U1JP,U1JC,U1JM,U12,U11,U3JP,U3JC,U3JM,U32,U31)

      DO 1 J=1,N2M
         JP=J+1
         JM=J-1
         JUM=J-JMU(J)
         JUP=JPA(J)-J
      DO 1 I=1,N1M
         IP=I+1
         IM=I-1
         IUM=I-IMV(I)
         IUP=IPA(I)-I

      DO L=1,3
      VZ(L)=0.0
      V3Z(L)=0.0
      VORZ(L)=0.0
      VORQZ(L)=0.0
      ENDDO
      DO L=1,6
      VVZ(L)=0.0
      ENDDO
      PZ=0.0
      PPZ=0.0
      P3Z=0.0

      DO 10 K=1,N3M
      KP=KPA(K)
      KM=KMA(K)
      KPP=KPA(KP) 

C     INSTANTANEOUS VELOCITY AND PRESSURE AT CELL CENTER AND NEIGHBOR

      V(1)=(U(I,J,K,1)+U(IP,J ,K ,1))*0.5
      V(2)=(U(I,J,K,2)+U(I ,JP,K ,2))*0.5
      V(3)=(U(I,J,K,3)+U(I ,J ,KP,3))*0.5

C     INSTANTANEOUS VORTICITY AT CELL CENTER

      U1KP=0.5*(U(I ,J,KP,1)+U(IP,J ,KP,1))
      U1KM=0.5*(U(I ,J,KM,1)+U(IP,J ,KM,1))
      U2KP=0.5*(U(I ,J,KP,2)+U(I ,JP,KP,2))
      U2KM=0.5*(U(I ,J,KM,2)+U(I ,JP,KM,2))
      U2IP=0.5*(U(IP,J,K ,2)+U(IP,JP,K ,2))
      U2IM=0.5*(U(IM,J,K ,2)+U(IM,JP,K ,2))
      U3IP=0.5*(U(IP,J,K ,3)+U(IP,J ,KP,3))
      U3IM=0.5*(U(IM,J,K ,3)+U(IM,J ,KP,3))

      U1JP=0.5*(U(I,JP,K,1)+U(IP,JP,K,1))
      U1JC=0.5*(U(I,J ,K,1)+U(IP,J ,K,1))
      U1JM=0.5*(U(I,JM,K,1)+U(IP,JM,K,1))
      U12=0.5/H(JP)*(DY(JP)*U1JC+DY(J)*U1JP)  ! VORTICITY BUG CORRECT
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

      VOR(1)=DV3DX2-DV2DX3
      VOR(2)=DV1DX3-DV3DX1
      VOR(3)=DV2DX1-DV1DX2

C     AVERAGING U AND P IN SPANWISE DIRECTION

      DO L=1,3
      VZ(L)=VZ(L)+V(L)
      V3Z(L)=V3Z(L)+V(L)**3.0

      VORZ(L)=VORZ(L)+VOR(L)
      VORQZ(L)=VORQZ(L)+VOR(L)**2
      ENDDO
      PZ=PZ+P(I,J,K)
      PPZ=PPZ+P(I,J,K)**2
      P3Z=P3Z+P(I,J,K)**3.0 

C     AVERAGING U_I*U_J IN SPANWISE DIRECTION
      DO L=1,6
      NV1=NVV1(L)
      NV2=NVV2(L)
      VVZ(L)=VVZ(L)+V(NV1)*V(NV2)  
      ENDDO

   10 CONTINUE

c     CALCULATE TIME MEAN FROM SPANWISE MEAN AT THIS TIME STEP

      DO L=1,3
      VM(L,I,J)=(VZ(L)*NZ+(RNAVG-1.)*VM(L,I,J))/RNAVG
      VORM(L,I,J)=(VORZ(L)*NZ+(RNAVG-1.)*VORM(L,I,J))/RNAVG
      VORQM(L,I,J)=(VORQZ(L)*NZ+(RNAVG-1.)*VORQM(L,I,J))/RNAVG
      VVM(L,I,J)=(VVZ(L)*NZ+(RNAVG-1.)*VVM(L,I,J))/RNAVG
      VVM(L+3,I,J)=(VVZ(L+3)*NZ+(RNAVG-1.)*VVM(L+3,I,J))/RNAVG
      V3M(L,I,J)=(V3Z(L)*NZ+(RNAVG-1.)*V3M(L,I,J))/RNAVG
      ENDDO
      PM(I,J)=(PZ*NZ+(RNAVG-1.)*PM(I,J))/RNAVG
      PPM(I,J)=(PPZ*NZ+(RNAVG-1.)*PPM(I,J))/RNAVG
      P3M(I,J)=(P3Z*NZ+(RNAVG-1.)*P3M(I,J))/RNAVG 

    1 CONTINUE

      
      RETURN
      END

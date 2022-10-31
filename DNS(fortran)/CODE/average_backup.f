C*************** AVERAGE **********************
      SUBROUTINE AVERAGE(U,P,NAVG)

      INCLUDE 'dctbl.h'


      REAL U(0:M1,0:M2,0:M3,3),P(M1,M2,M3)
      REAL NZ
!      save VC1,VC2,VC3

      REAL EPS1(6),EPS2(6),EPS3(6)
      REAL T1(6),T2(6)
      REAL VZ(3),VVZ(6),V3Z(3),V4Z(3)
      REAL VP(6)
      REAL GP(3)
      REAL V(3),VIP(3),VIM(3)
      REAL VJP(3),VJM(3),VKP(3),VKM(3)
      REAL VOR(3),VORZ(3),VORQZ(3)

!      REAL VC1(M1,M2,M3)
!      REAL VC2(M1,M2,M3)
!      REAL VC3(M1,M2,M3)

      REAL VVQZ(4)

!!$omp  parallel do private(IP,JP,KP)

!      DO K=1,N3M
!      KP=KPA(K)
!      DO J=1,N2M
!      JP=J+1
!      DO I=1,N1M
!      IP=I+1
!      VC1(I,J,K)=(U(I,J,K,1)+U(IP,J ,K ,1))*0.5
!      VC2(I,J,K)=(U(I,J,K,2)+U(I ,JP,K ,2))*0.5
!      VC3(I,J,K)=(U(I,J,K,3)+U(I ,J ,KP,3))*0.5
!      ENDDO
!      ENDDO
!      ENDDO

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
!$omp& KP,KM,KPP,VZ,V3Z,V4Z,VORZ,VORQZ,VVZ,EPS1,EPS2,EPS3,
!$omp& T1,T2,VP,PZ,PPZ,P3Z,P4Z,V,VIP,VIM,VJP,VJM,VKP,VKM,
!$omp& GP,VOR,NV1,NV2,DV3DX2,DV2DX3,DV3DX1,DV1DX3,DV2DX1
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
      V4Z(L)=0.0
      VORZ(L)=0.0
      VORQZ(L)=0.0
      ENDDO
      DO L=1,6
      VVZ(L)=0.0
      EPS1(L)=0.0 
      EPS2(L)=0.0 
      EPS3(L)=0.0 
      T1(L)=0.0
      T2(L)=0.0
      VP(L)=0.0
      ENDDO
      PZ=0.0
      PPZ=0.0
      P3Z=0.0
      P4Z=0.0

      DO 10 K=1,N3M
      KP=KPA(K)
      KM=KMA(K)
      KPP=KPA(KP) 

C     INSTANTANEOUS VELOCITY AND PRESSURE AT CELL CENTER AND NEIGHBOR

      V(1)=(U(I,J,K,1)+U(IP,J ,K ,1))*0.5
      V(2)=(U(I,J,K,2)+U(I ,JP,K ,2))*0.5
      V(3)=(U(I,J,K,3)+U(I ,J ,KP,3))*0.5

      VIP(1)=(U(IP,J,K,1)+U(IP+1,J ,K ,1))*0.5*IUP
      VIP(2)=(U(IP,J,K,2)+U(IP  ,JP,K ,2))*0.5*IUP
      VIP(3)=(U(IP,J,K,3)+U(IP  ,J ,KP,3))*0.5*IUP

      VIM(1)=(U(IM,J,K,1)+U(I ,J ,K ,1))*0.5*IUM
      VIM(2)=(U(IM,J,K,2)+U(IM,JP,K ,2))*0.5*IUM
      VIM(3)=(U(IM,J,K,3)+U(IM,J ,KP,3))*0.5*IUM

      VJP(1)=(U(I,JP,K,1)+U(IP,JP  ,K ,1))*0.5*JUP
      VJP(2)=(U(I,JP,K,2)+U(I ,JP+1,K ,2))*0.5*JUP
      VJP(3)=(U(I,JP,K,3)+U(I ,JP  ,KP,3))*0.5*JUP

      VJM(1)=(U(I,JM,K,1)+U(IP,JM,K ,1))*0.5*JUM
      VJM(2)=(U(I,JM,K,2)+U(I ,J ,K ,2))*0.5*JUM
      VJM(3)=(U(I,JM,K,3)+U(I ,JM,KP,3))*0.5*JUM

      VKP(1)=(U(I,J,KP,1)+U(IP,J ,KP ,1))*0.5
      VKP(2)=(U(I,J,KP,2)+U(I ,JP,KP ,2))*0.5
      VKP(3)=(U(I,J,KP,3)+U(I ,J ,KPP,3))*0.5  

      VKM(1)=(U(I,J,KM,1)+U(IP,J ,KM,1))*0.5
      VKM(2)=(U(I,J,KM,2)+U(I ,JP,KM,2))*0.5
      VKM(3)=(U(I,J,KM,3)+U(I ,J ,K ,3))*0.5  

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
      VORZ(L)=VORZ(L)+VOR(L)
      VORQZ(L)=VORQZ(L)+VOR(L)**2
      ENDDO
      PZ=PZ+P(I,J,K)
      PPZ=PPZ+P(I,J,K)**2
      

C     AVERAGING U_I*U_J IN SPANWISE DIRECTION
      DO L=1,6

!      NVV1(1)=1
!      NVV2(1)=1
!      NVV1(2)=2
!      NVV2(2)=2
!      NVV1(3)=3
!      NVV2(3)=3
!      NVV1(4)=1
!      NVV2(4)=2
!      NVV1(5)=1
!      NVV2(5)=3
!      NVV1(6)=2
!      NVV2(6)=3

      NV1=NVV1(L)
      NV2=NVV2(L)
      VVZ(L)=VVZ(L)+V(NV1)*V(NV2)  
      ENDDO

      IF (IAVGB.EQ.1) THEN
C     AVERAGING HIGHER ORDER STATISTICS E.G. UU,UUU, ETC.

      DO L=1,3
      V3Z(L)=V3Z(L)+V(L)**3.0
      V4Z(L)=V4Z(L)+V(L)**4.0
      ENDDO
      P3Z=P3Z+P(I,J,K)**3
      P4Z=P4Z+P(I,J,K)**4

!      DO L=1,6
      DO L=1,4
      NV1=NVV1(L)
      NV2=NVV2(L)
      
C     AVERAGING (DU_I/DX_K)(DU_J/DX_K) IN SPANWISE DIRECTION

      EPS1(L)=EPS1(L)
     >  +IUM*IUP*(VIP(NV1)-VIM(NV1))*DX1/2*(VIP(NV2)-VIM(NV2))*DX1/2
     >  +(1-IUM)*(VIP(NV1)-V(NV1))*DX1*(VIP(NV2)-V(NV2))*DX1
     >  +(1-IUP)*(V(NV1)-VIM(NV1))*DX1*(V(NV2)-VIM(NV2))*DX1
      EPS2(L)=EPS2(L)
     >       +(JUM*JUP
     >*(H(J)**2*VJP(NV1)-(H(J)**2-H(JP)**2)*V(NV1)-H(JP)**2*VJM(NV1))
     >  /H(J)/H(JP)/(H(J)+H(JP))
     > +(1-JUM)*(VJP(NV1)-V(NV1))/H(JP)
     > +(1-JUP)*(V(NV1)-VJM(NV1))/H(J))
     > *(JUM*JUP
     >*(H(J)**2*VJP(NV2)-(H(J)**2-H(JP)**2)*V(NV2)-H(JP)**2*VJM(NV2))
     >  /H(J)/H(JP)/(H(J)+H(JP))
     > +(1-JUM)*(VJP(NV2)-V(NV2))/H(JP)
     > +(1-JUP)*(V(NV2)-VJM(NV2))/H(J))
      EPS3(L)=EPS3(L)
     >     +(VKP(NV1)-VKM(NV1))*DX3/2*(VKP(NV2)-VKM(NV2))*DX3/2

C     AVERAGING U_I*U_J*U_K IN SPANWISE DIRECTION

      T1(L)=T1(L)+V(NV1)*V(NV2)*V(1)
      T2(L)=T2(L)+V(NV1)*V(NV2)*V(2)

C     AVERAGING U_I*DP/DX_J+U_J*DP/DX_I IN SPANWISE DIRECTION 

      GP(1)=IUM*IUP*(P(IP,J,K)-P(IM,J,K))*DX1/2 
     >     +(1-IUM)*(P(IP,J,K)-P(I ,J,K))*DX1
     >     +(1-IUP)*(P(I ,J,K)-P(IM,J,K))*DX1
      GP(2)=JUM*JUP
     >     *( H(J)**2*P(I,JP,K)
     >      -(H(J)**2-H(JP)**2)*P(I,J,K)
     >       -H(JP)**2*P(I,JM,K))
     >     /H(J)/H(JP)/(H(J)+H(JP))
     >   +(1-JUM)*(P(I,JP,K)-P(I,J ,K))/H(JP)
     >   +(1-JUP)*(P(I,J ,K)-P(I,JM,K))/H(J)
      GP(3)=(P(I,J,KP)-P(I,J,KM))*DX3/2

      VP(L)=VP(L)+(V(NV1)*GP(NV2)+V(NV2)*GP(NV1))

      ENDDO
      ENDIF ! FOR IAVGB
 
   10 CONTINUE

C     CALCULATE TIME MEAN FROM SPANWISE MEAN AT THIS TIME STEP

      DO L=1,3
      VM(L,I,J)=(VZ(L)*NZ+(RNAVG-1.)*VM(L,I,J))/RNAVG
      VORM(L,I,J)=(VORZ(L)*NZ+(RNAVG-1.)*VORM(L,I,J))/RNAVG
      VORQM(L,I,J)=(VORQZ(L)*NZ+(RNAVG-1.)*VORQM(L,I,J))/RNAVG
      VVM(L,I,J)=(VVZ(L)*NZ+(RNAVG-1.)*VVM(L,I,J))/RNAVG
      VVM(L+3,I,J)=(VVZ(L+3)*NZ+(RNAVG-1.)*VVM(L+3,I,J))/RNAVG
      ENDDO
      PM(I,J)=(PZ*NZ+(RNAVG-1.)*PM(I,J))/RNAVG
      PPM(I,J)=(PPZ*NZ+(RNAVG-1.)*PPM(I,J))/RNAVG
      
      IF (IAVGB.EQ.1) THEN 
      DO L=1,3 
      V3M(L,I,J)=(V3Z(L)*NZ+(RNAVG-1.)*V3M(L,I,J))/RNAVG
      V4M(L,I,J)=(V4Z(L)*NZ+(RNAVG-1.)*V4M(L,I,J))/RNAVG
      ENDDO
      P3M(I,J)=(P3Z*NZ+(RNAVG-1.)*P3M(I,J))/RNAVG
      P4M(I,J)=(P4Z*NZ+(RNAVG-1.)*P4M(I,J))/RNAVG
     
!      DO L=1,6
      DO L=1,4
      DISSP(L,I,J)=((EPS1(L)+EPS2(L)+EPS3(L))*NZ
     >             +(RNAVG-1.)*DISSP(L,I,J))/RNAVG
      TRANS(L,1,I,J)=(T1(L)*NZ+(RNAVG-1.)*TRANS(L,1,I,J))/RNAVG
      TRANS(L,2,I,J)=(T2(L)*NZ+(RNAVG-1.)*TRANS(L,2,I,J))/RNAVG
      PHI(L,I,J)=(VP(L)*NZ+(RNAVG-1.)*PHI(L,I,J))/RNAVG
      ENDDO
     
      ENDIF ! FOR IAVGB

    1 CONTINUE

c---------- AVERAGING CORRELATION ALONG SPANWISE DIRECTION
!      IF (IAVGC.EQ.1) THEN
      
!!$omp  parallel do private(J,JP,I,IP,KP,KL,KPL
!!$omp& ,CORSP1,CORSP2,CORSP3,CORSP4)


C	/SPANWISE/
!      DO 50 L=0,N3M/2

!      DO 50 NJ=1,JCMAX
!      J =JC(NJ)
!      JP=J+1

!      DO 50 NI=1,ICMAX
!      I=I_COR(NI)
!      IP=I+1

!      CORSP1=0.
!      CORSP2=0.
!      CORSP3=0.
!      CORSP4=0.
 
!      DO 70 K=1,N3M
!      KP=KPA(K)
!      KL =K+L
!      KPL=KP+L
!      IF(KL.GT.N3M)  KL =KL-N3M
!      IF(KPL.GT.N3M) KPL=KPL-N3M

!------------------------------------------
!      V1 =(U(I,J,K,1) +U(IP,J,K,1) )*0.5
!      V2 =(U(I,J,K,2) +U(I,JP,K,2) )*0.5
!      V3 =(U(I,J,K,3) +U(I,J,KP,3) )*0.5
!      V1R=(U(I,J,KL,1)+U(IP,J,KL,1))*0.5
!      V2R=(U(I,J,KL,2)+U(I,JP,KL,2))*0.5
!      V3R=(U(I,J,KL,3)+U(I,J,KPL,3))*0.5
!      CORSP1=CORSP1+V1*V1R
!      CORSP2=CORSP2+V2*V2R
!      CORSP3=CORSP3+V3*V3R
!------------------------------------------
!      modiified to below

!      CORSP1=CORSP1+VC1(I,J,K)*VC1(I,J,KL)
!      CORSP2=CORSP2+VC2(I,J,K)*VC2(I,J,KL)
!      CORSP3=CORSP3+VC3(I,J,K)*VC3(I,J,KL)
!      CORSP4=CORSP4+P(I,J,K)*P(I,J,KL)

!   70 CONTINUE	
	
!      CORSPM(1,NI,NJ,L)=(CORSP1*NZ+(RNAVG-1.)*CORSPM(1,NI,NJ,L))/RNAVG
!      CORSPM(2,NI,NJ,L)=(CORSP2*NZ+(RNAVG-1.)*CORSPM(2,NI,NJ,L))/RNAVG
!      CORSPM(3,NI,NJ,L)=(CORSP3*NZ+(RNAVG-1.)*CORSPM(3,NI,NJ,L))/RNAVG
!      CORSPM(4,NI,NJ,L)=(CORSP4*NZ+(RNAVG-1.)*CORSPM(4,NI,NJ,L))/RNAVG
   
!   50 CONTINUE
     
!      ENDIF ! FOR IAVGC 


      
      RETURN
      END

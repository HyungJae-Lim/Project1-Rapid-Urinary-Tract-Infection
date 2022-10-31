
c***************** GETUH3 ***********************     
      SUBROUTINE GETUH3(U,UH,RUH3)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL UH(0:M1,0:M2,0:M3,3)
      REAL RUH3(0:M1,0:M2,0:M3)
      REAL API(M1,M2),ACI(M1,M2),AMI(M1,M2)
      REAL APJ(M1,M2),ACJ(M1,M2),AMJ(M1,M2)
      REAL APK(M1,M3),ACK(M1,M3),AMK(M1,M3)
      EQUIVALENCE(API,APJ)
      EQUIVALENCE(ACI,ACJ)
      EQUIVALENCE(AMI,AMJ)

!$omp parallel do private(KP,KM,JP,JM,IP,IM,FJUM,FJUP,FIUM,FIUP,
!$omp& V1,V2,APJ,ACJ,AMJ,W1,W2,RM31UH,UH1,UH2,VH1,VH2,RM32VH)
      DO 2 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      DO 20 J=1,N2M
         JP=J+1
         JM=J-1
         FJUM=FJMU(J)
         FJUP=FJPA(J)
      DO 20 I=1,N1M
         IP=I+1
         IM=I-1
         FIUM=FIMV(I)
         FIUP=FIPA(I)

      V2=0.5*(U(I,JP,K,2)+U(I,JP,KM,2))
      V1=0.5*(U(I,J ,K,2)+U(I,J ,KM,2))

      APJ(I,J)=FJUP*(
     >      FJUM*(-0.5)*HP(J)/RE
     >     +(1.-FJUM)*(-0.5)/RE*2.0/H(2)/(H(1)+H(2))
     >      +0.5/DY(J)*V2/H(JP)*DY(J)/2.0 
     >      )*DT

      ACJ(I,J)= (FJUM*FJUP*0.5*HC(J)/RE
     >    +(1.-FJUM)*0.5/RE*2.0/H(1)/H(2)
     >    +(1.-FJUP)*0.5/RE*2.0/H(N2M)/H(N2)
     >      +0.5/DY(J)*(FJUP*V2/H(JP)*DY(JP)/2.0
     >                 -FJUM*V1/H(J)*DY(JM)/2.0) )
     >     *DT +1.0
      AMJ(I,J)=FJUM*(
     >      FJUP*(-0.5)*HM(J)/RE
     >     +(1.-FJUP)*(-0.5)/RE*2.0/H(N2M)/(H(N2M)+H(N2))
     >      -0.5/DY(J)*V1/H(J)*DY(J)/2.0 
     >      )*DT


C     M31UH
      W2=0.5*(U(IP,J,K,3)+U(I ,J,K,3))
      W1=0.5*(U(I ,J,K,3)+U(IM,J,K,3))
      UH2=0.5*(UH(IP,J,K,1)+UH(IP,J,KM,1))
      UH1=0.5*(UH(I ,J,K,1)+UH(I ,J,KM,1))
      RM31UH =0.5*DX1*(FIUP*W2*UH2-FIUM*W1*UH1)


C     M32VH
      W2=1.0/H(JP)*(DY(J )/2.*U(I,JP,K,3)+DY(JP)/2.*U(I,J ,K,3))
      W1=1.0/H(J )*(DY(JM)/2.*U(I,J ,K,3)+DY(J )/2.*U(I,JM,K,3))
      VH2=0.5*(UH(I,JP,K,2)+UH(I,JP,KM,2))      
      VH1=0.5*(UH(I,J ,K,2)+UH(I,J ,KM,2))      
      RM32VH=FJUP*0.5/DY(J)*W2*VH2
     >      -FJUM*0.5/DY(J)*W1*VH1

      UH(I,J,K,3)=DT*(RUH3(I,J,K)-RM31UH-RM32VH)

  20  CONTINUE
      CALL TDMAJ(AMJ,ACJ,APJ,UH(0,0,K,3),1,N1M,1,N2M)
  2   CONTINUE

!$omp parallel do private(JP,JM,KP,KM,IP,IM,W1,W2,
!$omp& APK,ACK,AMK)
      DO 3 J=1,N2M
         JP=J+1
         JM=J-1
      DO 30 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      DO 30 I=1,N1M
         IP=I+1
         IM=I-1
 
      W2=0.5*(U(I,J,KP,3)+U(I,J,K ,3))
      W1=0.5*(U(I,J,K ,3)+U(I,J,KM,3))

      APK(I,K)=(
     >      -0.5*DX3Q/RE
     >      +DX3*W2/2.0
     >       )*DT
      ACK(I,K)=1.+(
     >      +DX3Q/RE
     >      +DX3*(W2/2.0-W1/2.0)
     >      )*DT
      AMK(I,K)=(
     >      -0.5*DX3Q/RE
     >      -DX3*W1/2.0
     >       )*DT
  30  CONTINUE
      CALL TDMAK(AMK,ACK,APK,UH(0,0,0,3),1,N1M,J,N3M) 
  3   CONTINUE

!$omp parallel do private(KP,KM,IM,FIUM,FIUP,
!$omp& U1,U2,API,ACI,AMI)
      DO 1 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      DO 10 J=1,N2M
      DO 10 I=1,N1M
         IP=I+1
         IM=I-1
         FIUM=FIMV(I)
         FIUP=FIPA(I)

      U2=0.5*(U(IP,J,K,1)+U(IP,J,KM,1))
      U1=0.5*(U(I ,J,K,1)+U(I ,J,KM,1))

      API(I,J)=FIUP*(
     >         -0.5*DX1Q/RE
     >         +0.5*DX1*U2*0.5
     >       )*DT
      ACI(I,J)=1.+(
     >             +DX1Q/RE
     >             +0.5*DX1*(U2*0.5-U1*0.5)
     >      )*DT
      AMI(I,J)=FIUM*(
     >         -0.5*DX1Q/RE
     >         -0.5*DX1*U1*0.5
     >       )*DT
  10  CONTINUE
      CALL TDMAI(AMI,ACI,API,UH(0,0,K,3),1,N1M,1,N2M)
  1   CONTINUE

C     DVH UPDATE        
!$omp parallel do private(KP,KM,JP,JM,IP,IM,V1,V2,WH1,WH2,RM23WH)
      DO 110 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      DO 110 J=2,N2M
         JP=J+1
         JM=J-1
      DO 110 I=1,N1M
         IP=I+1
         IM=I-1

C     M23WH
      V2=0.5*(U(I,J,KP,2)+U(I,J,K ,2))
      V1=0.5*(U(I,J,K ,2)+U(I,J,KM,2))
      WH2=1.0/H(J)*(DY(J)/2.*UH(I,JM,KP,3)+DY(JM)/2.*UH(I,J,KP,3))
      WH1=1.0/H(J)*(DY(J)/2.*UH(I,JM,K ,3)+DY(JM)/2.*UH(I,J,K ,3))
      RM23WH=0.5*DX3*(V2*WH2-V1*WH1)
      
      UH(I,J,K,2)=UH(I,J,K,2)-DT*RM23WH 
110   CONTINUE

C     DUH UPDATE
!$omp parallel do private(KP,KM,JP,JM,IP,IM,FJUM,FJUP,
!$omp& U1,U2,VH1,VH2,RM12VH,WH1,WH2,RM13WH)
      DO 210 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      DO 210 J=1,N2M
         JP=J+1
         JM=J-1
         FJUM=FJMU(J)
         FJUP=FJPA(J)
      DO 210 I=2,N1M
         IP=I+1
         IM=I-1

C     M12VH
      U2=1.0/H(JP)*(DY(J )/2.*U(I,JP,K,1)+DY(JP)/2.*U(I,J ,K,1))
      U1=1.0/H(J )*(DY(JM)/2.*U(I,J ,K,1)+DY(J )/2.*U(I,JM,K,1))
      VH2=0.5*(UH(I,JP,K,2)+UH(IM,JP,K,2))      
      VH1=0.5*(UH(I,J ,K,2)+UH(IM,J ,K,2))      
      RM12VH=FJUP*0.5/DY(J)*U2*VH2
     >      -FJUM*0.5/DY(J)*U1*VH1
C     M13WH
      U2=0.5*(U(I,J,KP,1)+U(I,J,K ,1))
      U1=0.5*(U(I,J,K ,1)+U(I,J,KM,1))
      WH2=0.5*(UH(IM,J,KP,3)+UH(I,J,KP,3)) 
      WH1=0.5*(UH(IM,J,K ,3)+UH(I,J,K ,3)) 
      RM13WH=0.5*DX3*(U2*WH2-U1*WH1)

      UH(I,J,K,1)=UH(I,J,K,1)-DT*(RM12VH+RM13WH)
      UH(I,J,K,1)=U(I,J,K,1)+UH(I,J,K,1)
210   CONTINUE

C     INTERMEDIATE VELOCITY UPDATE
!$omp parallel do 
      DO K=1,N3M

      DO J=2,N2M
      DO I=1,N1M
      UH(I,J,K,2)=U(I,J,K,2)+UH(I,J,K,2)
      ENDDO
      ENDDO

      DO J=1,N2M
      DO I=1,N1M
      UH(I,J,K,3)=U(I,J,K,3)+UH(I,J,K,3)
      ENDDO
      ENDDO

      ENDDO

      RETURN
      END

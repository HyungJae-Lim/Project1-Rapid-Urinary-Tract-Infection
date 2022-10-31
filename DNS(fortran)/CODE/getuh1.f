

c***************** GETUH1 ***********************     
      SUBROUTINE GETUH1(U,UH,RUH1)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL UH(0:M1,0:M2,0:M3,3)
      REAL RUH1(0:M1,0:M2,0:M3)
      REAL API(M1,M2),ACI(M1,M2),AMI(M1,M2)
      REAL APJ(M1,M2),ACJ(M1,M2),AMJ(M1,M2)
      REAL APK(M1,M3),ACK(M1,M3),AMK(M1,M3)
      EQUIVALENCE(API,APJ)
      EQUIVALENCE(ACI,ACJ)
      EQUIVALENCE(AMI,AMJ)

!$omp parallel do private(JP,JM,IP,IM,FJUM,FJUP,V1,V2,
!$omp& APJ,ACJ,AMJ)
      DO 2 K=1,N3M
      DO 20 J=1,N2M
         JP=J+1
         JM=J-1
         FJUM=FJMU(J)
         FJUP=FJPA(J)
      DO 20 I=2,N1M
         IP=I+1
         IM=I-1

      V2=0.5*(U(I,JP,K,2)+U(IM,JP,K,2))      
      V1=0.5*(U(I,J ,K,2)+U(IM,J ,K,2))      

      APJ(I,J)=FJUP*(
     >           FJUM*(-0.5)*HP(J)/RE
     >         +(1.-FJUM)*(-0.5)/RE*2.0/H(2)/(H(1)+H(2))
     >      +0.5/DY(J)*V2/H(JP)*DY(J)/2.0
     >      )*DT
      ACJ(I,J)= (FJUM*FJUP*0.5*HC(J)/RE
     >        +(1.-FJUM)*0.5/RE*2.0/H(1)/H(2)
     >        +(1-FJUP)*0.5/RE*2.0/H(N2)/H(N2M)
     >        +0.5/DY(J)*(FJUP*V2/H(JP)*DY(JP)/2.0
     >                   -FJUM*V1/H(J )*DY(JM)/2.0)
     >        )*DT
     >       +1.0
      AMJ(I,J)=FJUM*(
     >           FJUP*(-0.5)*HM(J)/RE
     >        +(1.-FJUP)*(-0.5)/RE*2.0/H(N2M)/(H(N2M)+H(N2))
     >      -0.5/DY(J)*V1/H(J)*DY(J)/2.0
     >      )*DT
      UH(I,J,K,1)=RUH1(I,J,K)*DT
  20  CONTINUE

      CALL TDMAJ(AMJ,ACJ,APJ,UH(0,0,K,1),2,N1M,1,N2M)
  2   CONTINUE


!$omp parallel do private(IP,IM,FIUM,FIUP,U1,U2,
!$omp& API,ACI,AMI)
      DO 1 K=1,N3M
      DO 10 J=1,N2M
      DO 10 I=2,N1M
         IP=I+1
         IM=I-1
         FIUM=FIMU(I)
         FIUP=FIPA(I)

      U2=0.5*(U(IP,J,K,1)+U(I ,J,K,1))
      U1=0.5*(U(I ,J,K,1)+U(IM,J,K,1)) 
      API(I,J)= (-0.5*DX1Q/RE
     >         +DX1*U2*0.5)*FIUP
     >       *DT
      ACI(I,J)= 1.0+(
     >      +DX1Q/RE
     >      +DX1*(U2*0.5-U1*0.5)
     >      )*DT

      AMI(I,J)= (-0.5*DX1Q/RE
     >         -DX1*U1*0.5)*FIUM
     >       *DT

      UH(I,J,K,1)=UH(I,J,K,1) 
  10  CONTINUE

      CALL TDMAI(AMI,ACI,API,UH(0,0,K,1),2,N1M,1,N2M)
  1   CONTINUE

!$omp parallel do private(KP,KM,W1,W2,
!$omp& APK,ACK,AMK)
      DO 3 J=1,N2M
      DO 30 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      DO 30 I=2,N1M
         IP=I+1
         IM=I-1

      W2=0.5*(U(IM,J,KP,3)+U(I,J,KP,3))
      W1=0.5*(U(IM,J,K ,3)+U(I,J,K ,3))

      APK(I,K)=(
     >       -0.5*DX3Q/RE
     >       +0.5*DX3*W2*0.5
     >       )*DT
      ACK(I,K)=1.+(
     >       +DX3Q/RE
     >       +0.5*DX3*(W2*0.5-W1*0.5)
     >      )*DT
      AMK(I,K)=(
     >       -0.5*DX3Q/RE
     >       -0.5*DX3*W1*0.5
     >        )*DT
  30  CONTINUE
      CALL TDMAK(AMK,ACK,APK,UH(0,0,0,1),2,N1M,J,N3M)
  3   CONTINUE

      RETURN
      END


c***************** GETUH2 ***********************     
      SUBROUTINE GETUH2(U,UH,RUH2)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL UH(0:M1,0:M2,0:M3,3)
      REAL RUH2(0:M1,0:M2,0:M3)
      REAL API(M1,M2),ACI(M1,M2),AMI(M1,M2)
      REAL APJ(M1,M2),ACJ(M1,M2),AMJ(M1,M2)
      REAL APK(M1,M3),ACK(M1,M3),AMK(M1,M3)
      EQUIVALENCE(API,APJ)
      EQUIVALENCE(ACI,ACJ)
      EQUIVALENCE(AMI,AMJ)


!$omp parallel do private(KP,KM,JP,JM,IP,IM,FJUM,FJUP,FIUM,FIUP,
!$omp& V1,V2,APJ,ACJ,AMJ,UH1,UH2,RM21UH)
      DO 2 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      DO 20 J=2,N2M
         JP=J+1
         JM=J-1
         FJUM=FJMV(J)
         FJUP=FJPA(J)
      DO 20 I=1,N1M
         IP=I+1
         IM=I-1
         FIUM=FIMV(I)
         FIUP=FIPA(I)

      V2=0.5*(U(I,JP,K,2)+U(I,J ,K,2))
      V1=0.5*(U(I,J ,K,2)+U(I,JM,K,2))

      APJ(I,J)=FJUP*(
     >      -0.5*DYP(J)/RE
     >      +1.0/H(J)*V2*0.5
     >      )*DT
      ACJ(I,J)=1.0+(
     >      +0.5*DYC(J)/RE
     >      +1.0/H(J)*(V2*0.5-V1*0.5)
     >      )*DT
      AMJ(I,J)=FJUM*(
     >      -0.5*DYM(J)/RE
     >      -1.0/H(J)*V1*0.5
     >      )*DT

C     M21UH
      V2=0.5*(U(IP,J,K,2)+U(I ,J,K,2))
      V1=0.5*(U(I ,J,K,2)+U(IM,J,K,2))
      UH2=1.0/H(J)*(DY(J)/2.*UH(IP,JM,K,1)+DY(JM)/2.*UH(IP,J,K,1))
      UH1=1.0/H(J)*(DY(J)/2.*UH(I ,JM,K,1)+DY(JM)/2.*UH(I ,J,K,1))
      RM21UH=0.5*DX1*(FIUP*V2*UH2-FIUM*V1*UH1)

      UH(I,J,K,2)=DT*(RUH2(I,J,K)-RM21UH)

  20  CONTINUE
      CALL TDMAJ(AMJ,ACJ,APJ,UH(0,0,K,2),1,N1M,2,N2M)
  2   CONTINUE

!$omp parallel do private(KP,KM,JP,JM,IP,IM,FIUM,FIUP,
!$omp& U1,U2,API,ACI,AMI)
      DO 1 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      DO 10 J=2,N2M
         JP=J+1
         JM=J-1
      DO 10 I=1,N1M
         IP=I+1
         IM=I-1
         FIUM=FIMV(I)
         FIUP=FIPA(I)

      U2=1.0/H(J)*(DY(J)/2.0*U(IP,JM,K,1)+DY(JM)/2.0*U(IP,J,K,1))
      U1=1.0/H(J)*(DY(J)/2.0*U(I ,JM,K,1)+DY(JM)/2.0*U(I ,J,K,1))
      API(I,J)=FIUP*(
     >         -0.5*DX1Q/RE
     >         +0.5*DX1*U2*0.5
     >       )*DT
      ACI(I,J)=1.0+(
     >             +DX1Q/RE
     >             +0.5*DX1*(U2*0.5-U1*0.5)
     >      )*DT
      AMI(I,J)=FIUM*(
     >         -0.5*DX1Q/RE
     >         -0.5*DX1*U1*0.5
     >       )*DT

      UH(I,J,K,2)=UH(I,J,K,2)
  10  CONTINUE
      CALL TDMAI(AMI,ACI,API,UH(0,0,K,2),1,N1M,2,N2M)
  1   CONTINUE

!$omp parallel do private(JP,JM,KP,KM,IP,IM,W1,W2,
!$omp& APK,ACK,AMK)
      DO 3 J=2,N2M
         JP=J+1
         JM=J-1
      DO 30 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      DO 30 I=1,N1M
         IP=I+1
         IM=I-1

      W2=1.0/H(J)*(DY(J)/2.0*U(I,JM,KP,3)+DY(JM)/2.0*U(I,J,KP,3))
      W1=1.0/H(J)*(DY(J)/2.0*U(I,JM,K ,3)+DY(JM)/2.0*U(I,J,K ,3))

      APK(I,K)=(
     >      -0.5*DX3Q/RE
     >      +0.5*DX3*W2/2.0
     >       )*DT
      ACK(I,K)=1.+(
     >      +DX3Q/RE
     >      +0.5*DX3*(W2/2.0-W1/2.0)
     >       )*DT
      AMK(I,K)=(
     >      -0.5*DX3Q/RE
     >      -0.5*DX3*W1/2.0
     >       )*DT
  30  CONTINUE
      CALL TDMAK(AMK,ACK,APK,UH(0,0,0,2),1,N1M,J,N3M)
  3   CONTINUE

      RETURN
      END

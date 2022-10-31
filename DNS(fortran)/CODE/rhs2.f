
c***************** RHS2 ***********************     
      SUBROUTINE RHS2(U,P,F,RUH2)
!      SUBROUTINE RHS2(U,P,RUH2)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)
      Real F(M1,M2,M3)
      REAL RUH2(0:M1,0:M2,0:M3)
      
!$omp  parallel do private(KP,KM,JP,JM,IP,IM,FJUM,FJUP,FIUM,FIUP,
!$omp& VISCOS,PRESSG2,BC_IN,BC_OUT,BC,
!$omp& U1,U2,V1,V2,W1,W2,
!$omp& API,ACI,AMI,APJ,ACJ,AMJ,APK,ACK,AMK,
!$omp& RM22V_N,RM21U_N,RM23W_N,
!$omp& BC1,BC2,BC_DOWN,BC_UP)
      DO 10 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      
      DO 10 J=2,N2M
         JP=J+1
         JM=J-1
         FJUM=FJMV(J)
         FJUP=FJPA(J)

      DO 11 I=1,N1M
         IP=I+1
         IM=I-1
         FIUM=FIMV(I)
         FIUP=FIPA(I)
     
      VISCOS=0.5*DX1Q/RE*(U(IP,J,K ,2)-2. *U(I,J,K,2)+U(IM,J,K ,2))
     >      +0.5*DX3Q/RE*(U(I ,J,KP,2)-2.0*U(I,J,K,2)+U(I ,J,KM,2))
     >      +0.5/RE*(DYP(J)*U(I,JP,K,2)
     >              -DYC(J)*U(I,J ,K,2)
     >              +DYM(J)*U(I,JM,K,2))
      
      PRESSG2=(P(I,J,K)-P(I,JM,K))/H(J) 
      
      BC_DOWN=0.5/RE*DYM(2)*UBC1(2,I,K)          
     >       +1./H(2)*0.5*(U(I,2,K,2)+U(I,1,K,2))*0.5*UBC1(2,I,K)
      BC_UP  =0.5/RE*DYP(N2M)*UBC2(2,I,K)
     >       -1./H(N2M)*0.5*(U(I,N2,K,2)+U(I,N2M,K,2))*0.5*UBC2(2,I,K)
 
      U2=1.0/H(J)*(DY(J)/2.0*U(IP,JM,K,1)+DY(JM)/2.0*U(IP,J,K,1))
      U1=1.0/H(J)*(DY(J)/2.0*U(I ,JM,K,1)+DY(JM)/2.0*U(I ,J,K,1))
      BC2=1.0/H(J)*(DY(J)/2.0*UBC4(1,JM,K)+DY(JM)/2.0*UBC4(1,J,K))
      BC1=1.0/H(J)*(DY(J)/2.0*UBC3(1,JM,K)+DY(JM)/2.0*UBC3(1,J,K))
      V2=0.5*(U(I,J,K,2)+U(IP,J,K,2))
      V1=0.5*(U(I,J,K,2)+U(IM,J,K,2))

      BC_IN =0.5*DX1Q/RE*UBC3(2,J,K)
     >      +0.5*DX1*U1*0.5*UBC3(2,J,K)
     >      +0.5*DX1*V1*BC1
      BC_OUT=0.5*DX1Q/RE*UBC4(2,J,K)
     >      -0.5*DX1*U2*0.5*UBC4(2,J,K)
     >      -0.5*DX1*V2*BC2


      BC=(1.-FJUM)*BC_DOWN
     >  +(1.-FJUP)*BC_UP 
     >  +(1.-FIUM)*BC_IN 
     >  +(1.-FIUP)*BC_OUT 

      RUH2(I,J,K)=1./DT*U(I,J,K,2)
     >           -PRESSG2+VISCOS
     >           +BC
     >           +F(I,J,K)     ! by S.H.LEE
 
 11   CONTINUE
      DO 10 I=1,N1M
         IP=I+1
         IM=I-1
         FIUM=FIMV(I)
         FIUP=FIPA(I)
C     R2=r2-AU^n      

C     M22V^N

      V2=0.5*(U(I,JP,K,2)+U(I,J ,K,2))
      V1=0.5*(U(I,J ,K,2)+U(I,JM,K,2))
      APJ=FJUP*(
     >      -0.5*DYP(J)/RE
     >      +1.0/H(J)*V2*0.5
     >      )
      ACJ=
     >      +0.5*DYC(J)/RE
     >      +1.0/H(J)*(V2*0.5-V1*0.5)
      AMJ=FJUM*(
     >      -0.5*DYM(J)/RE
     >      -1.0/H(J)*V1*0.5
     >      )

      U2=1.0/H(J)*(DY(J)/2.0*U(IP,JM,K,1)+DY(JM)/2.0*U(IP,J,K,1))
      U1=1.0/H(J)*(DY(J)/2.0*U(I ,JM,K,1)+DY(JM)/2.0*U(I ,J,K,1))

      API=FIUP*(
     >         -0.5*DX1Q/RE
     >         +0.5*DX1*U2*0.5
     >       )
      ACI=  DX1Q/RE
     >     +0.5*DX1*(U2*0.5-U1*0.5)
      AMI=FIUM*(
     >         -0.5*DX1Q/RE
     >         -0.5*DX1*U1*0.5
     >       )

      W2=1.0/H(J)*(DY(J)/2.0*U(I,JM,KP,3)+DY(JM)/2.0*U(I,J,KP,3))
      W1=1.0/H(J)*(DY(J)/2.0*U(I,JM,K ,3)+DY(JM)/2.0*U(I,J,K ,3))
      APK=
     >      -0.5*DX3Q/RE
     >      +0.5*DX3*W2/2.0
      ACK=
     >      +DX3Q/RE
     >      +0.5*DX3*(W2/2.0-W1/2.0)
      AMK=
     >      -0.5*DX3Q/RE
     >      -0.5*DX3*W1/2.0
      RM22V_N=APJ*U(I,JP,K,2)
     >       +ACJ*U(I,J ,K,2)
     >       +AMJ*U(I,JM,K,2)
     >       +API*U(IP,J,K,2)
     >       +ACI*U(I ,J,K,2)
     >       +AMI*U(IM,J,K,2)
     >       +APK*U(I,J,KP,2)
     >       +ACK*U(I,J,K ,2)
     >       +AMK*U(I,J,KM,2)
C     M21U^N
      V2=0.5*(U(IP,J,K,2)+U(I ,J,K,2))
      V1=0.5*(U(I ,J,K,2)+U(IM,J,K,2))
      U2=1.0/H(J)*(DY(J)/2.*U(IP,JM,K,1)+DY(JM)/2.*U(IP,J,K,1))
      U1=1.0/H(J)*(DY(J)/2.*U(I ,JM,K,1)+DY(JM)/2.*U(I ,J,K,1))
      RM21U_N=0.5*DX1*(FIUP*V2*U2-FIUM*V1*U1)

C     M23W^N
      V2=0.5*(U(I,J,KP,2)+U(I,J,K ,2))
      V1=0.5*(U(I,J,K ,2)+U(I,J,KM,2))
      W2=1.0/H(J)*(DY(J)/2.*U(I,JM,KP,3)+DY(JM)/2.*U(I,J,KP,3))
      W1=1.0/H(J)*(DY(J)/2.*U(I,JM,K ,3)+DY(JM)/2.*U(I,J,K ,3))
      RM23W_N=0.5*DX3*(V2*W2-V1*W1)

      RUH2(I,J,K)=RUH2(I,J,K)
     >           -1./DT*U(I,J,K,2)
     >           -RM21U_N-RM22V_N-RM23W_N

 10   CONTINUE 

      RETURN
      END

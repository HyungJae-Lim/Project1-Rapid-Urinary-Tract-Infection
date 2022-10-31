      
      
c***************** RHS1 ***********************     
      SUBROUTINE RHS1(U,P,F,RUH1)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)
      REAL F(M1,M2,M3)
      REAL RUH1(0:M1,0:M2,0:M3)

!$omp  parallel do private(IP,IM,JP,JM,KP,KM,FIUM,FIUP,FJUM,FJUP,
!$omp& VISCOS,PRESSG1,BC_DOWN,BC_UP,BC_IN,BC_OUT,BC,
!$omp& U1,U2,V1,V2,W1,W2,
!$omp& API,ACI,AMI,APJ,ACJ,AMJ,APK,ACK,AMK,
!$omp& RM11U_N,RM12V_N,RM13W_N)
      DO 10 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      DO 10 J=1,N2M
         JP=J+1
         JM=J-1
         FJUM=FJMU(J)
         FJUP=FJPA(J)

      DO 11 I=2,N1M
         IP=I+1
         IM=I-1
         FIUM=FIMU(I)
         FIUP=FIPA(I)
     
      VISCOS=0.5*DX1Q/RE*(U(IP,J,K ,1)-2.0*U(I,J,K,1)+U(IM,J,K ,1))
     >      +0.5*DX3Q/RE*(U(I ,J,KP,1)-2.0*U(I,J,K,1)+U(I ,J,KM,1))
     >      +FJUM*FJUP*0.5/RE*(HP(J)*U(I,JP,K,1)
     >                      -HC(J)*U(I,J ,K,1)
     >                      +HM(J)*U(I,JM,K,1))
     >      +(1.-FJUM)*0.5/RE*(2.0/H(2)/(H(1)+H(2))*U(I,2,K,1)
     >                      -2.0/H(1)/H(2)*U(I,1,K,1)
     >                      +2.0/H(1)/(H(1)+H(2))*U(I,0,K,1))
     >      +(1.-FJUP)*0.5/RE*(2.0/H(N2M)/(H(N2)+H(N2M))*U(I,N2M-1,K,1)
     >                      -2.0/H(N2M)/H(N2)*U(I,N2M,K,1)
     >                      +2.0/H(N2)/(H(N2)+H(N2M))*U(I,N2,K,1))

      PRESSG1=DX1*(P(I,J,K)-P(IM,J,K))
      
      BC_DOWN=0.5/RE*2.0/H(1)/(H(1)+H(2))*UBC1(1,I,K)
     >       +0.5/DY(1)*0.5*(U(I,1,K,2)+U(IM,1,K,2))*UBC1(1,I,K)
     >       +0.5/DY(1)*U(I,0,K,1)*0.5*(UBC1(2,I,K)+UBC1(2,IM,K)) 

      BC_UP  =0.5/RE*2.0/H(N2)/(H(N2)+H(N2M))*UBC2(1,I,K)
     >       -0.5/DY(N2M)*0.5*(U(I,N2,K,2)+U(IM,N2,K,2))*UBC2(1,I,K)
     >       -0.5/DY(N2M)*U(I,N2,K,1)*0.5*(UBC2(2,I,K)+UBC2(2,IM,K)) 

      U2=0.5*(U(IP,J,K,1)+U(I ,J,K,1))
      U1=0.5*(U(I ,J,K,1)+U(IM,J,K,1)) 

      BC_IN = DX1*U1*0.5*UBC3(1,J,K)
     >       +0.5/RE*DX1Q*UBC3(1,J,K)
      BC_OUT=-DX1*U2*0.5*UBC4(1,J,K)
     >       +0.5/RE*DX1Q*UBC4(1,J,K)


      BC=(1.-FJUM)*BC_DOWN
     >  +(1.-FJUP)*BC_UP 
     >  +(1.-FIUM)*BC_IN 
     >  +(1.-FIUP)*BC_OUT 

      RUH1(I,J,K)=1./DT*U(I,J,K,1)
     >           -PRESSG1+VISCOS
     >           +BC
     >           +F(I,J,K)       ! by S.H.LEE
 11   CONTINUE
      DO 10 I=2,N1M
         IP=I+1
         IM=I-1
         FIUM=FIMU(I)
         FIUP=FIPA(I)

C     R1=r1-AU^n

C     M11U^N      
      V2=0.5*(U(I,JP,K,2)+U(IM,JP,K,2))      
      V1=0.5*(U(I,J ,K,2)+U(IM,J ,K,2))      
      APJ=FJUP*(
     >      FJUM*(-0.5)*HP(J)/RE
     >     +(1.-FJUM)*(-0.5)/RE*2.0/H(2)/(H(1)+H(2))
     >      +0.5/DY(J)*V2/H(JP)*DY(J)/2.0
     >      )
      ACJ= FJUM*FJUP*0.5*HC(J)/RE
     >    +(1.-FJUM)*0.5/RE*2.0/H(1)/H(2)
     >    +(1.-FJUP)*0.5/RE*2.0/H(N2)/H(N2M)
     >      +0.5/DY(J)*(FJUP*V2/H(JP)*DY(JP)/2.0
     >                 -FJUM*V1/H(J )*DY(JM)/2.0)
      AMJ=FJUM*(
     >      FJUP*(-0.5)*HM(J)/RE
     >     +(1.-FJUP)*(-0.5)/RE*2.0/H(N2M)/(H(N2M)+H(N2))
     >      -0.5/DY(J)*V1/H(J)*DY(J)/2.0
     >      )
      U2=0.5*(U(IP,J,K,1)+U(I ,J,K,1))
      U1=0.5*(U(I ,J,K,1)+U(IM,J,K,1)) 
      API= (-0.5*DX1Q/RE
     >      +DX1*U2*0.5)*FIUP
      ACI=   DX1Q/RE
     >      +DX1*(U2*0.5-U1*0.5)
      AMI= (-0.5*DX1Q/RE
     >      -DX1*U1*0.5)*FIUM
      W2=0.5*(U(IM,J,KP,3)+U(I,J,KP,3))
      W1=0.5*(U(IM,J,K ,3)+U(I,J,K ,3))
      APK=   -0.5*DX3Q/RE
     >       +0.5*DX3*W2*0.5
      ACK=    DX3Q/RE
     >       +0.5*DX3*(W2*0.5-W1*0.5)
      AMK=   -0.5*DX3Q/RE
     >       -0.5*DX3*W1*0.5
      RM11U_N=APJ*U(I,JP,K,1)
     >       +ACJ*U(I,J ,K,1)
     >       +AMJ*U(I,JM,K,1)
     >       +API*U(IP,J,K,1)
     >       +ACI*U(I ,J,K,1)
     >       +AMI*U(IM,J,K,1)
     >       +APK*U(I,J,KP,1)
     >       +ACK*U(I,J,K ,1)
     >       +AMK*U(I,J,KM,1)
C     M12V^N
      U2=1.0/H(JP)*(DY(J )/2.*U(I,JP,K,1)+DY(JP)/2.*U(I,J ,K,1))
      U1=1.0/H(J )*(DY(JM)/2.*U(I,J ,K,1)+DY(J )/2.*U(I,JM,K,1))
      V2=0.5*(U(I,JP,K,2)+U(IM,JP,K,2))      
      V1=0.5*(U(I,J ,K,2)+U(IM,J ,K,2))      
      RM12V_N=FJUP*0.5/DY(J)*U2*V2
     >       -FJUM*0.5/DY(J)*U1*V1
C     M13W^N
      U2=0.5*(U(I,J,KP,1)+U(I,J,K ,1))
      U1=0.5*(U(I,J,K ,1)+U(I,J,KM,1))
      W2=0.5*(U(IM,J,KP,3)+U(I,J,KP,3)) 
      W1=0.5*(U(IM,J,K ,3)+U(I,J,K ,3)) 
      RM13W_N=0.5*DX3*(U2*W2-U1*W1)

      RUH1(I,J,K)=RUH1(I,J,K)
     >           -1./DT*U(I,J,K,1)
     >           -RM11U_N-RM12V_N-RM13W_N

 10   CONTINUE 


      RETURN
      END

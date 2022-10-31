
c***************** RHS3 ***********************     
      SUBROUTINE RHS3(U,P,F,RUH3)
!      SUBROUTINE RHS3(U,P,RUH3)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)
      REAL F(M1,M2,M3)
      REAL RUH3(0:M1,0:M2,0:M3)
      
!$omp  parallel do private(KP,KM,JP,JM,IP,IM,FJUM,FJUP,FIUM,FIUP,
!$omp& VISCOS,PRESSG3,BC_IN,BC_OUT,BC,
!$omp& U1,U2,V1,V2,W1,W2,
!$omp& API,ACI,AMI,APJ,ACJ,AMJ,APK,ACK,AMK,
!$omp& RM32V_N,RM31U_N,RM33W_N,
!$omp& VISCOS1,VISCOS2,BC1,BC2,BC_DOWN,BC_UP)
      DO 10 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      
      DO 10 J=1,N2M
         JP=J+1
         JM=J-1
         FJUM=FJMU(J)
         FJUP=FJPA(J)

      DO 11 I=1,N1M          
         IP=I+1
         IM=I-1
         FIUM=FIMV(I)
         FIUP=FIPA(I)
      
     
      VISCOS=0.5*DX1Q/RE*(U(IP,J,K,3)-2.*U(I,J,K,3)+U(IM,J,K,3))
     >      +0.5*DX3Q/RE*(U(I ,J,KP,3)-2.0*U(I,J,K,3)+U(I ,J,KM,3))
     >      +FJUM*FJUP*0.5/RE*(HP(J)*U(I,JP,K,3)
     >                      -HC(J)*U(I,J ,K,3)
     >                      +HM(J)*U(I,JM,K,3))
     >      +(1.-FJUM)*0.5/RE*(2.0/H(2)/(H(1)+H(2))*U(I,2,K,3)
     >                      -2.0/H(1)/H(2)*U(I,1,K,3)
     >                      +2.0/H(1)/(H(1)+H(2))*U(I,0,K,3))
     >      +(1.-FJUP)*0.5/RE*(2.0/H(N2M)/(H(N2M)+H(N2))*U(I,N2M-1,K,3)
     >                      -2.0/H(N2)/H(N2M)*U(I,N2M,K,3)
     >                      +2.0/H(N2)/(H(N2M)+H(N2))*U(I,N2,K,3))
      
      PRESSG3=DX3*(P(I,J,K)-P(I,J,KM)) 

      BC_DOWN=0.5/RE*2.0/H(1)/(H(1)+H(2))*UBC1(3,I,K)
     >       +0.5/DY(1)*0.5*(U(I,1,KM,2)+U(I,1,K,2))*UBC1(3,I,K)
     >       +0.5/DY(1)*U(I,0,K,3)*0.5*(UBC1(2,I,K)+UBC1(2,I,KM))

      BC_UP  =0.5/RE*2.0/H(N2)/(H(N2M)+H(N2))*UBC2(3,I,K)
     >       -0.5/DY(N2M)*0.5*(U(I,N2,KM,2)+U(I,N2,K,2))*UBC2(3,I,K)
     >       -0.5/DY(N2M)*U(I,N2,K,3)*0.5*(UBC2(2,I,K)+UBC2(2,I,KM))

      U2=0.5*(U(IP,J,K,1)+U(IP,J,KM,1))
      U1=0.5*(U(I ,J,K,1)+U(I ,J,KM,1))
      BC2=0.5*(UBC4(1,J,K)+UBC4(1,J,KM))
      BC1=0.5*(UBC3(1,J,K)+UBC3(1,J,KM))
      W2=0.5*(U(IP,J,K,3)+U(I,J,K,3))
      W1=0.5*(U(IM,J,K,3)+U(I,J,K,3))

      BC_IN =0.5*DX1Q/RE*UBC3(3,J,K)
     >      +0.5*DX1*U1*0.5*UBC3(3,J,K)
     >      +0.5*DX1*W1*BC1
      BC_OUT=0.5*DX1Q/RE*UBC4(3,J,K)
     >      -0.5*DX1*U2*0.5*UBC4(3,J,K)
     >      -0.5*DX1*W2*BC2


      BC=(1.-FJUM)*BC_DOWN
     >  +(1.-FJUP)*BC_UP 
     >  +(1.-FIUM)*BC_IN 
     >  +(1.-FIUP)*BC_OUT 

      RUH3(I,J,K)=1./DT*U(I,J,K,3)
     >           -PRESSG3+VISCOS
     >           +BC
     >           +F(I,J,K)        ! by S.H.LEE
 11   CONTINUE
      DO 10 I=1,N1M          
         IP=I+1
         IM=I-1
         FIUM=FIMV(I)
         FIUP=FIPA(I)
C     R3=r3-AU^n      

C     M33W^N

      V2=0.5*(U(I,JP,K,2)+U(I,JP,KM,2))
      V1=0.5*(U(I,J ,K,2)+U(I,J ,KM,2))
      APJ=FJUP*(
     >      FJUM*(-0.5)*HP(J)/RE
     >     +(1.-FJUM)*(-0.5)/RE*2.0/H(2)/(H(1)+H(2))
     >      +0.5/DY(J)*V2/H(JP)*DY(J)/2.0 
     >      )

      ACJ= FJUM*FJUP*0.5*HC(J)/RE
     >    +(1.-FJUM)*0.5/RE*2.0/H(1)/H(2)
     >    +(1.-FJUP)*0.5/RE*2.0/H(N2)/H(N2M)
     >      +0.5/DY(J)*(FJUP*V2/H(JP)*DY(JP)/2.0
     >                 -FJUM*V1/H(J)*DY(JM)/2.0) 
      AMJ=FJUM*(
     >      FJUP*(-0.5)*HM(J)/RE
     >     +(1.-FJUP)*(-0.5)/RE*2.0/H(N2M)/(H(N2M)+H(N2))
     >      -0.5/DY(J)*V1/H(J)*DY(J)/2.0 
     >      )
      W2=0.5*(U(I,J,KP,3)+U(I,J,K ,3))
      W1=0.5*(U(I,J,K ,3)+U(I,J,KM,3))
      APK=
     >      -0.5*DX3Q/RE
     >      +DX3*W2/2.0
      ACK=
     >      +DX3Q/RE
     >      +DX3*(W2/2.0-W1/2.0)
      AMK=
     >      -0.5*DX3Q/RE
     >      -DX3*W1/2.0
      U2=0.5*(U(IP,J,K,1)+U(IP,J,KM,1))
      U1=0.5*(U(I ,J,K,1)+U(I ,J,KM,1))
      API=FIUP*(
     >         -0.5*DX1Q/RE
     >         +0.5*DX1*U2*0.5
     >       )
      ACI=
     >      +DX1Q/RE
     >      +0.5*DX1*(U2*0.5-U1*0.5)
      AMI=FIUM*(
     >         -0.5*DX1Q/RE
     >         -0.5*DX1*U1*0.5
     >       )

      RM33W_N=APJ*U(I,JP,K,3)
     >       +ACJ*U(I,J ,K,3)
     >       +AMJ*U(I,JM,K,3)
     >       +API*U(IP,J,K,3)
     >       +ACI*U(I ,J,K,3)
     >       +AMI*U(IM,J,K,3)
     >       +APK*U(I,J,KP,3)
     >       +ACK*U(I,J,K ,3)
     >       +AMK*U(I,J,KM,3)
C     M31U^N
      W2=0.5*(U(IP,J,K,3)+U(I ,J,K,3))
      W1=0.5*(U(I ,J,K,3)+U(IM,J,K,3))
      U2=0.5*(U(IP,J,K,1)+U(IP,J,KM,1))
      U1=0.5*(U(I ,J,K,1)+U(I ,J,KM,1))
      RM31U_N=0.5*DX1*(FIUP*W2*U2-FIUM*W1*U1)


C     M32V^N
      W2=1.0/H(JP)*(DY(J )/2.*U(I,JP,K,3)+DY(JP)/2.*U(I,J ,K,3))
      W1=1.0/H(J )*(DY(JM)/2.*U(I,J ,K,3)+DY(J )/2.*U(I,JM,K,3))
      V2=0.5*(U(I,JP,K,2)+U(I,JP,KM,2))      
      V1=0.5*(U(I,J ,K,2)+U(I,J ,KM,2))      
      RM32V_N=FJUP*0.5/DY(J)*W2*V2
     >       -FJUM*0.5/DY(J)*W1*V1

      RUH3(I,J,K)=RUH3(I,J,K)
     >           -1./DT*U(I,J,K,3)
     >           -RM31U_N-RM32V_N-RM33W_N

 10   CONTINUE 


      RETURN
      END

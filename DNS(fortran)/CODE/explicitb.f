c**************** EXPLICITB *************************
c     by S.H.LEE
      SUBROUTINE EXPLICITB(U,P,UT,F)
      INCLUDE 'dctbl.h'

      Real U(0:M1,0:M2,0:M3,3)
      Real P(M1,M2,M3)
      Real F(M1,M2,M3,3)
      Real UT(0:M1,0:M2,0:M3,3)

!$omp parallel do private(IP,IM,JP,JM,KP,KM,FJUM,FJUP,L,
!$omp& UF,VISCOS,PRESSG1,U1,U2,CONVEC1,V1,V2,CONVEC2,W1,W2,CONVEC3,
!$omp& CONVEC,RUT1,PRESSG2,RUT2,PRESSG3,RUT3)
      DO 20 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      DO 20 J=1,N2M
C      DO 20 J=1,JB+2    ! for fast calculation
         JP=J+1
         JM=J-1
         JUM=J-JMU(J)
         JUP=JPA(J)-J
      DO 20 I=1,N1M
C      DO 20 I=IB-2,N1M  ! for fast calculation
         IP=I+1
         IM=I-1

      ! FOR U

      L=1
      IF (NF(L,I,J,K).NE.1) THEN
      F(I,J,K,L)=0.
      ELSE
      UF=AFI(L,I,J,K)*UT(IFU(L,I,J,K),J,K,L)
     >  +AFJ(L,I,J,K)*UT(I,JFU(L,I,J,K),K,L)
     >  +AFK(L,I,J,K)*UT(I,J,KFU(L,I,J,K),L)
     >  +AFD(L,I,J,K)*UT(IFU(L,I,J,K),JFU(L,I,J,K),KFU(L,I,J,K),L)
     >  +AFB(L,I,J,K)*0.  ! AT IMMERSED BOUNDARY NO-SLIP
     
      ! modified 5/18
      VISCOS=DX1Q/RE*(U(IP,J,K,1 )-2.0*U(I,J,K,1)+U(IM,J,K,1 ))
     >      +DX3Q/RE*(U(I ,J,KP,1)-2.0*U(I,J,K,1)+U(I ,J,KM,1))
     >      +JUM*JUP*1./RE*(HP(J)*U(I,JP,K,1)
     >                     -HC(J)*U(I,J ,K,1)
     >                     +HM(J)*U(I,JM,K,1))
     >      +(1-JUM)*1./RE*(2.0/H(2)/(H(1)+H(2))*U(I,2,K,1)
     >                     -2.0/H(1)/H(2)*U(I,1,K,1)
     >                     +2.0/H(1)/(H(1)+H(2))*U(I,0,K,1))
     >      +(1-JUP)*1./RE*(2.0/H(N2M)/(H(N2)+H(N2M))*U(I,N2M-1,K,1)
     >			   -2.0/H(N2M)/H(N2)*U(I,N2M,K,1)
     >	                   +2.0/H(N2)/(H(N2)+H(N2M))*U(I,N2,K,1))
      
      PRESSG1=DX1*(P(I,J,K)-P(IM,J,K))
     
      U2=0.5*(U(IP,J,K,1)+U(I ,J,K,1))
      U1=0.5*(U(I ,J,K,1)+U(IM,J,K,1))
      CONVEC1=DX1*(U2**2-U1**2)
     
      V2=0.5*(U(I,JP,K,2)+U(IM,JP,K,2))
      V1=0.5*(U(I,J ,K,2)+U(IM,J ,K,2))
      U2=1./H(JP)*(0.5*DY(J)*U(I,JP,K,1)+0.5*DY(JP)*U(I,J,K,1))
      U1=1./H(J)*(0.5*DY(JM)*U(I,J,K,1)+0.5*DY(J)*U(I,JM,K,1))
      CONVEC2=1./DY(J)*(V2*U2-V1*U1)

      W2=0.5*(U(IM,J,KP,3)+U(I,J,KP,3))
      W1=0.5*(U(IM,J,K ,3)+U(I,J,K ,3))
      U2=0.5*(U(I ,J,KP,1)+U(I,J,K ,1))
      U1=0.5*(U(I ,J,K ,1)+U(I,J,KM,1))
      CONVEC3=DX3*(W2*U2-W1*U1)

      CONVEC=CONVEC1+CONVEC2+CONVEC3
      RUT1=VISCOS-PRESSG1-CONVEC
      F(I,J,K,L)=(UF-U(I,J,K,L))/DT-RUT1
      ENDIF

      ! FOR V
      
      L=2
      IF (NF(L,I,J,K).NE.1) THEN
      F(I,J,K,L)=0.
      ELSE
      UF=AFI(L,I,J,K)*UT(IFU(L,I,J,K),J,K,L)
     >  +AFJ(L,I,J,K)*UT(I,JFU(L,I,J,K),K,L)
     >  +AFK(L,I,J,K)*UT(I,J,KFU(L,I,J,K),L)
     >  +AFD(L,I,J,K)*UT(IFU(L,I,J,K),JFU(L,I,J,K),KFU(L,I,J,K),L)
     >  +AFB(L,I,J,K)*0.  ! AT IMMERSED BOUNDARY NO-SLIP
      
      VISCOS= 1.*DX1Q/RE*(U(IP,J,K,2)-2.0*U(I,J,K,2)+U(IM,J,K,2))
     >       +1.*DX3Q/RE*(U(I,J,KP,2)-2.0*U(I,J,K,2)+U(I,J,KM,2))
     >       +1./RE*(DYP(J)*U(I,JP,K,2)
     >              -DYC(J)*U(I,J ,K,2)
     >              +DYM(J)*U(I,JM,K,2))

      PRESSG2=(P(I,J,K)-P(I,JM,K))/H(J)
      
      U2=1.0/H(J)*(DY(J)/2.0*U(IP,JM,K,1)+DY(JM)/2.0*U(IP,J,K,1))
      U1=1.0/H(J)*(DY(J)/2.0*U(I ,JM,K,1)+DY(JM)/2.0*U(I ,J,K,1))
      V2=0.5*(U(IP,J,K,2)+U(I ,J,K,2))
      V1=0.5*(U(I ,J,K,2)+U(IM,J,K,2))
      CONVEC1=DX1*(U2*V2-U1*V1)

      V2=0.5*(U(I,JP,K,2)+U(I,J ,K,2))
      V1=0.5*(U(I,J,K,2)+U(I,JM,K,2))
      CONVEC2=1./H(J)*(V2**2-V1**2)
      
      W2=1.0/H(J)*(DY(J)/2.0*U(I,JM,KP,3)+DY(JM)/2.0*U(I,J,KP,3))
      W1=1.0/H(J)*(DY(J)/2.0*U(I,JM,K ,3)+DY(JM)/2.0*U(I,J,K ,3))
      V2=0.5*(U(I,J,K ,2)+U(I,J,KM,2))
      V1=0.5*(U(I,J,KP,2)+U(I,J,K ,2))
      CONVEC3=DX3*(W2*V2-W1*V1)
      
      CONVEC=CONVEC1+CONVEC2+CONVEC3
      RUT2=VISCOS-PRESSG2-CONVEC
      F(I,J,K,L)=(UF-U(I,J,K,L))/DT-RUT2
      ENDIF

      ! FOR W

      L=3
      IF (NF(L,I,J,K).NE.1) THEN
      F(I,J,K,L)=0.
      ELSE
      UF=AFI(L,I,J,K)*UT(IFU(L,I,J,K),J,K,L)
     >  +AFJ(L,I,J,K)*UT(I,JFU(L,I,J,K),K,L)
     >  +AFK(L,I,J,K)*UT(I,J,KFU(L,I,J,K),L)
     >  +AFD(L,I,J,K)*UT(IFU(L,I,J,K),JFU(L,I,J,K),KFU(L,I,J,K),L)
     >  +AFB(L,I,J,K)*0.  ! AT IMMERSED BOUNDARY NO-SLIP
      
      VISCOS=DX1Q/RE*(U(IP,J,K ,3)-2.0*U(I,J,K,3)+U(IM,J,K ,3))
     >      +DX3Q/RE*(U(I ,J,KP,3)-2.0*U(I,J,K,3)+U(I ,J,KM,3))
     >      +JUM*JUP*1./RE*(HP(J)*U(I,JP,K,3)
     >                     -HC(J)*U(I,J ,K,3)
     >                     +HM(J)*U(I,JM,K,3))
     >      +(1-JUM)*1./RE*(2.0/H(2)/(H(1)+H(2))*U(I,2,K,3)
     >                     -2.0/H(1)/H(2)*U(I,1,K,3)
     >                     +2.0/H(1)/(H(1)+H(2))*U(I,0,K,3))
     >      +(1-JUP)*1./RE*(2.0/H(N2M)/(H(N2M)+H(N2))*U(I,N2M-1,K,3)
     >	                   -2.0/H(N2)/H(N2M)*U(I,N2M,K,3)
     >		           +2.0/H(N2)/(H(N2M)+H(N2))*U(I,N2,K,3))

      PRESSG3=DX3*(P(I,J,K)-P(I,J,KM))

      U2=0.5*(U(IP,J,K,1)+U(IP,J,KM,1))
      U1=0.5*(U(I ,J,K,1)+U(I ,J,KM,1))
      W2=0.5*(U(IP,J,K,3)+U(I,J,K ,3))
      W1=0.5*(U(I,J,K ,3)+U(IM,J,K,3))     
      CONVEC1=DX1*(U2*W2-U1*W1)
      
      V2=0.5*(U(I,JP,K,2)+U(I,JP,KM,2))
      V1=0.5*(U(I,J ,K,2)+U(I,J ,KM,2))
      W2=1.0/H(JP)*(DY(J )/2.*U(I,JP,K,3)+DY(JP)/2.*U(I,J ,K,3))
      W1=1.0/H(J )*(DY(JM)/2.*U(I,J ,K,3)+DY(J )/2.*U(I,JM,K,3))
      CONVEC2=1./DY(J)*(V2*W2-V1*W1)
      
      W2=0.5*(U(I,J,KP,3)+U(I,J,K ,3))
      W1=0.5*(U(I,J,K ,3)+U(I,J,KM,3))
      CONVEC3=DX3*(W2**2-W1**2)

      CONVEC=CONVEC1+CONVEC2+CONVEC3
      RUT3=VISCOS-PRESSG3-CONVEC
      F(I,J,K,L)=(UF-U(I,J,K,L))/DT-RUT3
      ENDIF
      
  20  CONTINUE
      RETURN
      END



c***************** TDMAK ***********************    
      SUBROUTINE TDMAK(A,B,C,X,NIS,NIF,J,N)
      INCLUDE 'dctbl.h'
      REAL A(M1,M3),B(M1,M3),C(M1,M3)
      REAL X(0:M1,0:M2,0:M3)
      REAL GAM(M1,M3)
      REAL P(M1,M3),QR(M1,M3)

      DO I=NIS,NIF
      BET=1./B(I,1)
      GAM(I,1)=C(I,1)*BET
      X(I,J,1)=X(I,J,1)*BET
      P(I,1)=C(I,N)
      QR(I,1)=A(I,1)*BET
      ENDDO

      DO K=2,N-2
      DO I=NIS,NIF
      BET=1./(B(I,K)-A(I,K)*GAM(I,K-1))
      GAM(I,K)=C(I,K)*BET
      X(I,J,K)=(X(I,J,K)-A(I,K)*X(I,J,K-1))*BET
      P(I,K)=-P(I,K-1)*GAM(I,K-1)
      QR(I,K)=-A(I,K)*QR(I,K-1)*BET
      ENDDO
      ENDDO

         K=N-1
      DO I=NIS,NIF
      BET=1./(B(I,K)-A(I,K)*GAM(I,K-1))
      X(I,J,K)=(X(I,J,K)-A(I,K)*X(I,J,K-1))*BET
      P(I,K)=A(I,K+1)-P(I,K-1)*GAM(I,K-1)
      QR(I,K)=(C(I,K)-A(I,K)*QR(I,K-1))*BET
      ENDDO
      
      DO K=1,N-1
      DO I=NIS,NIF
      X(I,J,N)=X(I,J,N)-P(I,K)*X(I,J,K)
      B(I,N)=B(I,N)-P(I,K)*QR(I,K)
      ENDDO
      ENDDO
         K=N
      DO I=NIS,NIF
      X(I,J,K)=X(I,J,K)/B(I,K)
      GAM(I,K-1)=0.0
      ENDDO

      DO K=N-1,1,-1
      DO I=NIS,NIF
      X(I,J,K)=X(I,J,K)-GAM(I,K)*X(I,J,K+1)-QR(I,K)*X(I,J,N)
      ENDDO
      ENDDO
      RETURN
      END

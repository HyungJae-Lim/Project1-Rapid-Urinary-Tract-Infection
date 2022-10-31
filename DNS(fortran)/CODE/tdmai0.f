

C*************** TDMA **********************
      SUBROUTINE TDMAJ0(A,B,C,R,X,NJS,NJF,NIS,NIF)
      INCLUDE 'dctbl.h'
      REAL A(0:M1,M2),B(0:M1,M2),C(0:M1,M2),R(0:M1,M2),X(0:M1,M2)
      REAL BET,GAM(0:M1,0:M2)

c
      J=NJS
      DO I=NIS,NIF
      BET=B(I,J)
      GAM(I,J)=C(I,J)/BET
      X(I,J)=R(I,J)/BET
      ENDDO
      DO 10 J=NJS+1,NJF
      DO I=NIS,NIF
      BET=B(I,J)-A(I,J)*GAM(I,J-1)
      GAM(I,J)=C(I,J)/BET
      X(I,J)=(R(I,J)-A(I,J)*X(I,J-1))/BET
      ENDDO
   10 CONTINUE
      DO 20 J=NJF-1,NJS,-1
      DO I=NIS,NIF
      X(I,J)=X(I,J)-GAM(I,J)*X(I,J+1)
      ENDDO
   20 CONTINUE
c
c
      RETURN
      END

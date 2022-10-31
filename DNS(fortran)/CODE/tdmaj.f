

C*************** TDMA **********************
      SUBROUTINE TDMAJ(A,B,C,R,NIS,NIF,NJS,NJF)
      INCLUDE 'dctbl.h'
      REAL A(M1,M2),B(M1,M2),C(M1,M2)
      REAL R(0:M1,0:M2)
      REAL BET,GAM(M1,0:M2)

         J=NJS
      DO I=NIS,NIF
         BET=1./B(I,J)
         GAM(I,J)=C(I,J)*BET
         R(I,J)=R(I,J)*BET
      ENDDO
      DO J=NJS+1,NJF
      DO I=NIS,NIF
         BET=1./(B(I,J)-A(I,J)*GAM(I,J-1))
         GAM(I,J)=C(I,J)*BET
         R(I,J)=(R(I,J)-A(I,J)*R(I,J-1))*BET
      ENDDO
      ENDDO
      DO J=NJF-1,NJS,-1
      DO I=NIS,NIF
         R(I,J)=R(I,J)-GAM(I,J)*R(I,J+1)
      ENDDO
      ENDDO
c
      RETURN
      END




C*************** TDMA **********************
      SUBROUTINE TDMAI(A,B,C,R,NIS,NIF,NJS,NJF)
      INCLUDE 'dctbl.h'
      REAL A(M1,*),B(M1,*),C(M1,*)
      REAL R(0:M1,0:*)
      REAL BET1,GAM1(0:M1)
      REAL BET2,GAM2(0:M1)
C
      DO J=NJS,NJF-1,2
         I=NIS
         BET1=1./B(I,J)
         BET2=1./B(I,J+1)
         GAM1(I)=C(I,J)*BET1
         GAM2(I)=C(I,J+1)*BET2
         R(I,J)=R(I,J)*BET1
         R(I,J+1)=R(I,J+1)*BET2
      DO I=NIS+1,NIF
         BET1=1./(B(I,J)-A(I,J)*GAM1(I-1))
         BET2=1./(B(I,J+1)-A(I,J+1)*GAM2(I-1))
         GAM1(I)=C(I,J)*BET1
         GAM2(I)=C(I,J+1)*BET2
         R(I,J)=(R(I,J)-A(I,J)*R(I-1,J))*BET1
         R(I,J+1)=(R(I,J+1)-A(I,J+1)*R(I-1,J+1))*BET2
      ENDDO
      DO I=NIF-1,NIS,-1
         R(I,J)=R(I,J)-GAM1(I)*R(I+1,J)
         R(I,J+1)=R(I,J+1)-GAM2(I)*R(I+1,J+1)
      ENDDO
      ENDDO
      IF(mod(NJF-NJS+1,2).eq.1) then
         J=NJF
         I=NIS
         BET1=1./B(I,J)
         GAM1(I)=C(I,J)*BET1
         R(I,J)=R(I,J)*BET1
      DO I=NIS+1,NIF
         BET1=1./(B(I,J)-A(I,J)*GAM1(I-1))
         GAM1(I)=C(I,J)*BET1
         R(I,J)=(R(I,J)-A(I,J)*R(I-1,J))*BET1
      ENDDO
      DO I=NIF-1,NIS,-1
         R(I,J)=R(I,J)-GAM1(I)*R(I+1,J)
      ENDDO
      endif
c
      RETURN
      END

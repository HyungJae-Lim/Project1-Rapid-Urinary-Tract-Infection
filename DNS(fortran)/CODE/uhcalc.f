
c***************** UHCALC ***********************     
!      SUBROUTINE UHCALC(U,UH,P,F,TIME)
!      SUBROUTINE UHCALC(U,UH,P,F)
      SUBROUTINE UHCALC(U,UH,P)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)
      REAL F(M1,M2,M3,3)

      REAL UH(0:M1,0:M2,0:M3,3)
      REAL RUH1(0:M1,0:M2,0:M3)
      REAL RUH2(0:M1,0:M2,0:M3)
      REAL RUH3(0:M1,0:M2,0:M3)
      save RUH1,RUH2,RUH3
      save F

      CALL FORCING(U,P,F) ! by S.H.LEE
      
c     CALL RHS(U,P,F(1,1,1,1),RUH1,RUH2,RUH3)
      CALL RHS1(U,P,F(1,1,1,1),RUH1)
!      CALL RHS1(U,P,F,RUH1)
!      CALL RHS1(U,P,RUH1)
      CALL RHS2(U,P,F(1,1,1,2),RUH2)
!      CALL RHS2(U,P,F,RUH2)
!      CALL RHS2(U,P,RUH2)
      CALL RHS3(U,P,F(1,1,1,3),RUH3)
!      CALL RHS3(U,P,F,RUH3)
!      CALL RHS3(U,P,RUH3)
      
      CALL GETUH1(U,UH,RUH1)
      CALL GETUH2(U,UH,RUH2)
      CALL GETUH3(U,UH,RUH3)
      
      RETURN
      END

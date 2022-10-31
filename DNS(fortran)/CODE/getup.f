c***************** GETUP ***********************     
!      SUBROUTINE GETUP(U,P,F,TIME)
      SUBROUTINE GETUP(U,P,F)
!      SUBROUTINE GETUP(U,P)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL UH(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)
      REAL F(M1,M2,M3,3)
      REAL DP(M1,M2,M3)
      save UH,DP
C     INITIALIZE THE INTERMEDIATE VELOCITY AND PRESSURE
!$omp parallel do
      DO K=1,N3M
      DO J=0,N2
      DO I=0,N1
         UH(I,J,K,1)=0.0
         UH(I,J,K,2)=0.0
         UH(I,J,K,3)=0.0
      ENDDO
      ENDDO
      DO J=1,N2M
      DO I=1,N1M
         DP(I,J,K)=0.0
      ENDDO
      ENDDO
      ENDDO

      CALL BCOND(U)

C     CALCULATE THE INTERMEDIATE VELOCITY
!      CALL UHCALC(U,UH,P,F,TIME)
      CALL UHCALC(U,UH,P,F)
!      CALL UHCALC(U,UH,P)

C     CALCULATE DP

      CALL DPCALC(UH,DP)


C     UPDATE THE N+1 TIME STEP VELOCITY AND PRESSURE
      CALL UPCALC(U,P,UH,DP)

      RETURN
      END


c***************** DPCALC ***********************     
      SUBROUTINE DPCALC(UH,DP)
      INCLUDE 'dctbl.h'
      
      REAL UH(0:M1,0:M2,0:M3,3)
      REAL DP(M1,M2,M3)
      REAL RDP(M1,M2,M3)
      SAVE RDP

!      CALL MASSQ(UH) ! by S.H.LEE   (only for smooth wall) 07.7.14
      CALL RHSDP(DP,UH)

      CALL TAKEDP(DP)

      RETURN
      END


c***************** SKIP_INFLOW ***********************     
      SUBROUTINE SKIP_INFLOW(U)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)

      PI=ACOS(-1.)

      WRITE(*,*) 'START INFLOW SKIPPING'
      DO L=1,NSKIPINF

C------ ONLY FOR MAIN SIMULATION --------------------------------------------
c     SKIP THE Inlet boundary conditions from 1 ~ NSTARTINF
      
      IF (IFORINF.EQ.0) THEN ! INFLOW DATA : UNFORMATTED FORM

C      NFINF=81+INT(REAL(NTIME-1)/2500.0) ! INFLOW DATA FROM fort.81 
     
C      READ (NFINF)((UBC3(1,J,K),J=1,N2M),K=1,N3M) ! U(1,J,K,1) INLET BOUNDARY  
C     >          ,((UBC3(2,J,K),J=2,N2M),K=1,N3M) ! U(0,J,K,2) INLET BOUNDARY 
C     >          ,((UBC3(3,J,K),J=1,N2M),K=1,N3M) ! U(0,J,K,3) INLET BOUNDARY 
      READ (81)((UBC3(1,J,K),J=1,N2M),K=1,N3M) ! U(1,J,K,1) INLET BOUNDARY  
     >          ,((UBC3(2,J,K),J=2,N2M),K=1,N3M) ! U(0,J,K,2) INLET BOUNDARY 
     >          ,((UBC3(3,J,K),J=1,N2M),K=1,N3M) ! U(0,J,K,3) INLET BOUNDARY 

      ELSE                   ! INFLOW DATA : FORMMATED FORM
      DO 40 K=1,N3M
      J=1
      READ (81,200) UBC3(1,J,K),UBC3(3,J,K)
      DO 40 J=2,N2M
      READ (81,201) UBC3(1,J,K),UBC3(2,J,K),UBC3(3,J,K)
40    CONTINUE 
200   FORMAT(2(E15.7,2x)) 
201   FORMAT(3(E15.7,2x)) 
      ENDIF ! FOR IFORINF
 
      ENDDO ! FOR L      

      WRITE(*,*) 'INFLOW SKIPPED TO 1 ~',NSKIPINF
 
      RETURN
      END

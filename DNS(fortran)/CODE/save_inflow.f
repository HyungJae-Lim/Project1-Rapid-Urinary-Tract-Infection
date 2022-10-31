
C  ************************  SAVE_INFLOW **********************
C     WRITE INFLOW DATA
      Subroutine SAVE_INFLOW(U,NSAVE)
      INCLUDE 'dctbl.h'

      Real U(0:M1,0:M2,0:M3,3)

c      I_SAVE=36

      IF (IFORINF.EQ.0) THEN      ! INFLOW DATA FORMAT : UNFORMATTED
C      NFINF=81+INT(REAL(NSAVE-1)/NINFLOW) ! INFLOW DATA IS SAVED ON fort.81 ...
C      WRITE(NFINF) ((U(I_SAVE  ,J,K,1),J=1,N2M),K=1,N3M)
C     >            ,((U(I_SAVE-1,J,K,2),J=2,N2M),K=1,N3M)
C     >            ,((U(I_SAVE-1,J,K,3),J=1,N2M),K=1,N3M)
      WRITE(82) ((U(I_SAVE  ,J,K,1),J=1,N2M),K=1,N3M)
     >            ,((U(I_SAVE-1,J,K,2),J=2,N2M),K=1,N3M)
     >            ,((U(I_SAVE-1,J,K,3),J=1,N2M),K=1,N3M)
      
      ELSE                        ! INFLOW DATA FORMAT : FORMATTED
  
      DO 40 K=1,N3M
      J=1
      WRITE (82,200) U(I_SAVE,J,K,1),U(I_SAVE-1,J,K,3)
      DO 40 J=2,N2M
      WRITE (82,201) U(I_SAVE ,J,K,1),U(I_SAVE-1,J,K,2),
     >               U(I_SAVE-1,J,K,3) 
40    CONTINUE
200   FORMAT(2(E15.7,2x))
201   FORMAT(3(E15.7,2x))
      ENDIF ! FOR IFORINF

    
      RETURN
      END


C ************************* INIAVE ***********************
      Subroutine INIAVE(NAVG)
      INCLUDE 'dctbl.h'

!Revised for LMP&HMP TBL 

      IF (IAVG.EQ.1) THEN ! NEW AVERAGING

      DO 10 K=1,N3M
      DO 10 J=1,N2M
      DO 10 I=1,N1M
      DO L=1,3

      VM(L,I,J,K)=0.0

      ENDDO
 10   CONTINUE

      ELSE                ! WHEN IAVG=2:  Continue Averaging 

      IF (IFORAVG.EQ.0) THEN ! UNFORMATTED FORM
      write(*,*) 'Reading initial file of averaged data'
      OPEN(32,FILE=fileavg,FORM='UNFORMATTED',STATUS='OLD')
 
      DO 1 I=1,N1M
      READ(32) TIME,NAVG,II,UTAU
      WRITE(*,100) TIME,NAVG,I,UTAU
 
      DO K=1,N3M
      DO J=1,N2M
      READ(32) (VM(L,I,J,K),L=1,3)
      ENDDO
      ENDDO


   1  CONTINUE
      CLOSE(32) 

 
      ENDIF ! FOR IFORAVG

      ENDIF ! FOR IAVG
 100  FORMAT(E15.7,X,I10,X,I5,E15.7)

      RETURN
      END


c ************** IMMERSED ******************
c       by S.H.Lee

      Subroutine IMMERSED
      INCLUDE 'dctbl.h'

      IF (IMFOR.EQ.0) THEN    ! smooth wall
      DO 11 K=1,N3M
      DO 11 J=1,N2M
      DO 11 I=1,N1M
      NF(1,I,J,K)=0
      NF(2,I,J,K)=0
      NF(3,I,J,K)=0
 11   CONTINUE   

      ELSE                    ! rough wall 
  
      write(*,*) 'call make_ibm'
      CALL MAKE_IBM

      write(*,*) 'make_ibm done' 
      ENDIF ! FOR IMFOR

      Return
      end

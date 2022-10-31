c*************** GET_RAMDA ******************
      SUBROUTINE GET_RAMDA(Re_th,RAMDA,I)

      INCLUDE 'dctbl.h'

      IF (I.EQ.1) THEN
      R1=18.0    !initial guess for ramda
      R2=19.0
      ELSE 
      R1=RAMDA
      R2=RAMDA+0.05
      ENDIF
!      ITRY=0
1     continue
!      ITRY=ITRY+1
      F_1=RE_THETA(R1)
      F_2=RE_THETA(R2)
      ERR=ABS(F_1-F_2)
      IF (ERR.GE.1E-13) THEN
      TEMP=(R1-R2)/(F_1-F_2+1E-20)*(RE_TH-F_1)+R1
      R2=R1
      R1=TEMP
      GOTO 1
      ENDIF
      RAMDA=R1
!      WRITE(*,*) 'ITRY=',ITRY
      RETURN
      END


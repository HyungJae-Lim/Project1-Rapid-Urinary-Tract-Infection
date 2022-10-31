
C*************** OUTPUT  **********************
C      SUBROUTINE OUTPUT(TIME,NAVG)
      SUBROUTINE OUTPUT(NAVG)
      INCLUDE 'dctbl.h'

      CHARACTER*80 FILEW

!      NFAVG=(NAVG-1)/NPRN+1
      NFAVG=NAVG


      IF (IFORAVG.EQ.0) THEN  ! AVERAGE FILE FORMAT : UNFORMATTED

      FILEW=FOUTAVG
      N=INDEX(FILEW,'.')
      WRITE(UNIT=FILEW(N+1:),FMT='(BN,I6.6)') NFAVG
      write(*,*) 'Writing unformatted Averaged data on', FILEW
      OPEN(12,FILE=FILEW,FORM='UNFORMATTED',STATUS='UNKNOWN')


      DO 1 I=1,N1M
      UTAU=SQRT(ABS(VM(1,I,1,N3M/8))/(0.5*Y(2))/RE)
      WRITE(12) TIME,NAVG,I,UTAU

      DO  K=1,N3M
      DO  J=1,N2M
      WRITE(12) (VM(L,I,J,K),L=1,3)!,PM(I,J,K),PPM(I,J,K)
      ENDDO
      ENDDO

   1  CONTINUE
      CLOSE(12)
      
      ENDIF ! FOR IFORAVG

      RETURN
      END

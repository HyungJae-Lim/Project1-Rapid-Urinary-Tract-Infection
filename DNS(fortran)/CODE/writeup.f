

C  ************************  WRITEUP **********************
C     WRITE FLOW FIELD AND BOUNDARY CONDITIONS
C     AND MEAN PRESSURE GRADIENT

!      SUBROUTINE WRITEUP(U,P,IMORE)
      SUBROUTINE WRITEUP(U,P)

      INCLUDE 'dctbl.h'
      CHARACTER*80 FILEW
      REAL U(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)

      FILEW=FILEOUT
      N=INDEX(FILEW,'.')
      WRITE(UNIT=FILEW(N+1:),FMT='(BN,I6.6)') NTIME
     
      IF (IFOROUT.EQ.0) THEN   ! OUTPUT FILE FORMAT : UNFORMATTED
      WRITE(*,*) 'Writing unformatted OUTPUT Data on ',FILEW
      OPEN(40,FILE=FILEW,FORM='UNFORMATTED',STATUS='UNKNOWN')

C      NFILE=40+INT((NTIME-1)/NPRN)+1
C      WRITE(NFILE) (((U(1,I,J,K),U(2,I,J,K),U(3,I,J,K)
C     >               ,K=1,N3M),J=0,N2),I=0,N1)

!      WRITE(40) (((U(I,J,K,1),U(I,J,K,2),U(I,J,K,3)
!     >               ,K=1,N3M),J=0,N2),I=0,N1)
!-------------------------------------------------------
!     Changed because big file
      DO L=1,3
      WRITE(40) (((U(I,J,K,L)
     >           ,I=0,N1),J=0,N2),K=1,N3M) 
      ENDDO
!------------------------------------------------------

!      WRITE(NFILE) (((P(I,J,K),K=1,N3M),J=1,N2M),I=1,N1M)

!      WRITE(40) (((P(I,J,K),K=1,N3M),J=1,N2M),I=1,N1M)
!---------------------------------------------------------
      WRITE(40) (((P(I,J,K),I=1,N1M),J=1,N2M),K=1,N3M)
       

C      IMORE=IMORE+1
C      CLOSE(NFILE)
      CLOSE(40)
 
      ELSE                    ! OUTPUT FILE FORMAT : FORMATTED
      WRITE(*,*) 'Writing formatted OUTPUT Data on ',FILEW
      OPEN(40,FILE=FILEW,STATUS='UNKNOWN')
      DO 10 I=0,N1
      DO 10 J=0,N2
      DO 10 K=1,N3M
      WRITE(40,100) U(I,J,K,1),U(I,J,K,2),U(I,J,K,3) 
   10 CONTINUE
      DO 20 I=1,N1M
      DO 20 J=1,N2M
      DO 20 K=1,N3M
      WRITE(40,200) P(I,J,K) 
   20 CONTINUE
 100  FORMAT(3(e15.7,x))
 200  FORMAT(e15.7)
      CLOSE(40) 

      ENDIF ! FOR IFORIO
      RETURN
      END

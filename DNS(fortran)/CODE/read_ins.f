
C*************** READ_INS ***********************
      SUBROUTINE READ_INS(U,P)
      INCLUDE 'dctbl.h'

      CHARACTER*80 FILEW1U
      CHARACTER*80 FILEW1V
      CHARACTER*80 FILEW1W
      CHARACTER*80 FILEW1P

      REAL U(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)

      FILEW1U='INSTANT/INS_U1.'
      FILEW1V='INSTANT/INS_V1.'
      FILEW1W='INSTANT/INS_W1.'
      FILEW1P='INSTANT/INS_P1.'

      N=INDEX(FILEW1U,'.')
      WRITE(UNIT=FILEW1U(N+1:),FMT='(BN,I6.6)') NTIME-1
      WRITE(UNIT=FILEW1V(N+1:),FMT='(BN,I6.6)') NTIME-1
      WRITE(UNIT=FILEW1W(N+1:),FMT='(BN,I6.6)') NTIME-1
      WRITE(UNIT=FILEW1P(N+1:),FMT='(BN,I6.6)') NTIME-1


      N1_S1=1
      N1_E1=N1M
      N2_S1=1
      N2_E1=N2M
 
      OPEN (111,FILE=FILEW1U,FORM='UNFORMATTED',STATUS='OLD')
      OPEN (121,FILE=FILEW1V,FORM='UNFORMATTED',STATUS='OLD')
      OPEN (131,FILE=FILEW1W,FORM='UNFORMATTED',STATUS='OLD')
      OPEN (141,FILE=FILEW1P,FORM='UNFORMATTED',STATUS='OLD')


      READ(111) (((U(I,J,K,1),I=N1_S1,N1_E1),J=N2_S1,N2_E1),K=1,N3M)
      READ(121) (((U(I,J,K,2),I=N1_S1,N1_E1),J=N2_S1,N2_E1),K=1,N3M)
      READ(131) (((U(I,J,K,3),I=N1_S1,N1_E1),J=N2_S1,N2_E1),K=1,N3M)
      READ(141) (((P(I,J,K),I=N1_S1,N1_E1),J=N2_S1,N2_E1),K=1,N3M)

      CLOSE(111)
      CLOSE(121)
      CLOSE(131)
      CLOSE(141)

      RETURN
      END

c***************** SETUP ***********************     
      SUBROUTINE SETUP

      include 'dctbl.h'
 
      CHARACTER*100 FDUMMY

      OPEN(2,FILE='dctbl.par',STATUS='OLD')
      READ (2,300) DUMMY
      WRITE(*,300) DUMMY
      READ (2,300) DUMMY
      WRITE(*,300) DUMMY
      READ (2,300) DUMMY
      WRITE(*,300) DUMMY
      READ (2,300) DUMMY
      WRITE(*,300) DUMMY
      READ (2,300) DUMMY
      WRITE(*,300) DUMMY
      READ (2,303) filepar
      WRITE(*,303) filepar
      

!      READ (2,300) DUMMY
!      WRITE(*,300) DUMMY
!      CLOSE(2)
 
      OPEN(1,FILE=filepar,STATUS='OLD')
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,301) DUMMY,ITYPE
      WRITE(*,301) DUMMY,ITYPE 
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,301) DUMMY,N1
      WRITE(*,301) DUMMY,N1
      READ (1,301) DUMMY,N2
      WRITE(*,301) DUMMY,N2
      READ (1,301) DUMMY,N3
      WRITE(*,301) DUMMY,N3
      READ (1,302) DUMMY,RE
      WRITE(*,302) DUMMY,RE
      READ (1,302) DUMMY,R_theta_in
      WRITE(*,302) DUMMY,R_theta_in
      READ (1,302) DUMMY,ALX
      WRITE(*,302) DUMMY,ALX
      READ (1,302) DUMMY,ALY
      WRITE(*,302) DUMMY,ALY
      READ (1,302) DUMMY,ALZ
      WRITE(*,302) DUMMY,ALZ
      READ (1,302) DUMMY,DTR
      WRITE(*,302) DUMMY,DTR
      READ (1,302) DUMMY,VPER
      WRITE(*,302) DUMMY,VPER
      READ (1,302) DUMMY,CFLMAX
      WRITE(*,302) DUMMY,CFLMAX
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,301) DUMMY,NSTART
      WRITE(*,301) DUMMY,NSTART
      READ (1,301) DUMMY,NFINAL
      WRITE(*,301) DUMMY,NFINAL
      READ (1,301) DUMMY,NPRN
      WRITE(*,301) DUMMY,NPRN
      READ (1,302) DUMMY,TSTART
      WRITE(*,302) DUMMY,TSTART
      READ (1,301) DUMMY,NINS
      WRITE(*,301) DUMMY,NINS
      READ (1,301) DUMMY,NREPAR
      WRITE(*,301) DUMMY,NREPAR
      READ (1,301) DUMMY,NINFLOW
      WRITE(*,301) DUMMY,NINFLOW
      READ (1,301) DUMMY,NAVGSTP
      WRITE(*,301) DUMMY,NAVGSTP
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,301) DUMMY,IGEN
      WRITE(*,301) DUMMY,IGEN
      READ (1,301) DUMMY,INFSAVE
      WRITE(*,301) DUMMY,INFSAVE
      READ (1,301) DUMMY,I_SAVE
      WRITE(*,301) DUMMY,I_SAVE
      READ (1,301) DUMMY,NFLINF
      WRITE(*,301) DUMMY,NFLINF
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,301) DUMMY,NWRITE
      WRITE(*,301) DUMMY,NWRITE
      READ (1,301) DUMMY,NREAD
      WRITE(*,301) DUMMY,NREAD
      READ (1,301) DUMMY,IREPAR
      WRITE(*,301) DUMMY,IREPAR
      READ (1,301) DUMMY,IDTOPT
      WRITE(*,301) DUMMY,IDTOPT
      READ (1,301) DUMMY,INCODE
      WRITE(*,301) DUMMY,INCODE
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,301) DUMMY,IAVG
      WRITE(*,301) DUMMY,IAVG
      READ (1,301) DUMMY,IAVGB
      WRITE(*,301) DUMMY,IAVGB
      READ (1,301) DUMMY,IAVGC
      WRITE(*,301) DUMMY,IAVGC
      READ (1,301) DUMMY,JCMAX
      WRITE(*,301) DUMMY,JCMAX
      READ (1,301) DUMMY,JC1
      WRITE(*,301) DUMMY,JC1
      READ (1,301) DUMMY,JC2
      READ (1,301) DUMMY,JC2
      WRITE(*,301) DUMMY,JC3
      WRITE(*,301) DUMMY,JC3
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,301) DUMMY,ITHIST
      WRITE(*,301) DUMMY,ITHIST
      READ (1,301) DUMMY,ITHIST1
      WRITE(*,301) DUMMY,ITHIST1
      READ (1,301) DUMMY,ITHIST2
      WRITE(*,301) DUMMY,ITHIST2
      READ (1,301) DUMMY,ITHIST3
      WRITE(*,301) DUMMY,ITHIST3
      READ (1,301) DUMMY,ITHIST4
      WRITE(*,301) DUMMY,ITHIST4
      READ (1,301) DUMMY,ITHIST5
      WRITE(*,301) DUMMY,ITHIST5
      READ (1,301) DUMMY,ITHIST6
      WRITE(*,301) DUMMY,ITHIST6
      READ (1,301) DUMMY,ITHIST7
      WRITE(*,301) DUMMY,ITHIST7
      READ (1,301) DUMMY,ITHIST8
      WRITE(*,301) DUMMY,ITHIST8
      READ (1,301) DUMMY,ITHIST9
      WRITE(*,301) DUMMY,ITHIST9
      READ (1,301) DUMMY,IAVGMON
      WRITE(*,301) DUMMY,IAVGMON
      READ (1,301) DUMMY,JAVGMON
      WRITE(*,301) DUMMY,JAVGMON
      READ (1,301) DUMMY,IPROF
      WRITE(*,301) DUMMY,IPROF
      READ (1,301) DUMMY,IPROF1
      WRITE(*,301) DUMMY,IPROF1
      READ (1,301) DUMMY,IPROF2
      WRITE(*,301) DUMMY,IPROF2
      READ (1,301) DUMMY,IPROF3
      WRITE(*,301) DUMMY,IPROF3
      READ (1,301) DUMMY,IPROF4
      WRITE(*,301) DUMMY,IPROF4
      READ (1,301) DUMMY,IPROF5
      WRITE(*,301) DUMMY,IPROF5
      READ (1,301) DUMMY,IPROF6
      WRITE(*,301) DUMMY,IPROF6
      READ (1,301) DUMMY,INSF
      WRITE(*,301) DUMMY,INSF
      READ (1,301) DUMMY,IWRITEW
      WRITE(*,301) DUMMY,IWRITEW
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,303) fileini
      WRITE(*,303) fileini
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,303) fileout
      WRITE(*,303) fileout
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,303) fileavg
      WRITE(*,303) fileavg
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,303) filebdg
      WRITE(*,303) filebdg
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,303) filecor
      WRITE(*,303) filecor
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,303) foutavg
      WRITE(*,303) foutavg
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,303) foutbdg
      WRITE(*,303) foutbdg
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,303) foutcor
      WRITE(*,303) foutcor
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,303) fresin
      WRITE(*,303) fresin
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,303) fresout
      WRITE(*,303) fresout
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,303) fileinf
      WRITE(*,303) fileinf
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,303) fileins
      WRITE(*,303) fileins
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,303) filegrd
      WRITE(*,303) filegrd
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,303) fileibm
      WRITE(*,303) fileibm
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,301) DUMMY,IFORIN
      WRITE(*,301) DUMMY,IFORIN
      READ (1,301) DUMMY,IFOROUT
      WRITE(*,301) DUMMY,IFOROUT
      READ (1,301) DUMMY,IFORINF
      WRITE(*,301) DUMMY,IFORINF
      READ (1,301) DUMMY,IFORRES
      WRITE(*,301) DUMMY,IFORRES
      READ (1,301) DUMMY,IFORAVG
      WRITE(*,301) DUMMY,IFORAVG
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,302) DUMMY,TFOR
      WRITE(*,302) DUMMY,TFOR
      READ (1,301) DUMMY,IMFOR
      WRITE(*,301) DUMMY,IMFOR
      READ (1,301) DUMMY,IMASS
      WRITE(*,301) DUMMY,IMASS
      READ (1,301) DUMMY,IB
      WRITE(*,301) DUMMY,IB
      READ (1,301) DUMMY,JB
      WRITE(*,301) DUMMY,JB
      READ (1,301) DUMMY,IW
      WRITE(*,301) DUMMY,IW
      READ (1,301) DUMMY,IL
      WRITE(*,301) DUMMY,IL
      READ (1,301) DUMMY,KW
      WRITE(*,301) DUMMY,KW
      READ (1,301) DUMMY,KL
      WRITE(*,301) DUMMY,KL
      READ (1,302) DUMMY,HB
      WRITE(*,302) DUMMY,HB
      READ (1,302) DUMMY,EPSX
      WRITE(*,302) DUMMY,EPSX
      READ (1,302) DUMMY,EPSY
      WRITE(*,302) DUMMY,EPSY

      CLOSE(1)

      CLOSE(2)
      
  300 FORMAT(A65)
  301 FORMAT(A45,I15)
  302 FORMAT(A45,E15.7)
  303 FORMAT(A100)

C------------------------------------
C     PHYSICAL LENGTH
      IF(INCODE.EQ.1) THEN
      PI=ACOS(-1.0)
      ALX=3.*PI
      ALZ=0.289*PI
      ENDIF
C------------------------------------
      c_kapa=0.41
      BB=5.0
      PII=0.5 ! parameter that depends on the pressure gradient

      write(*,*) 'c_kapa BB PII=',c_kapa,BB,PII
      
      N1M=N1-1
      N2M=N2-1
      N3M=N3-1



      RETURN
      END

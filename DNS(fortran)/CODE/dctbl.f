      PROGRAM MAIN

      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)
      REAL F(M1,M2,M3,3)
      save U,P,F
!      save U,P
      CHARACTER*100 FILEW

!      nthds=num_parthds()
!      tt0=rtc()

      tt0 = secnds(0.0)
      nthd = omp_get_max_threads()

      write(*,*) 'OMP Threads # =',nthds

C     PARAMETER FILE READING HISTORY

      CALL SETUP  ! READ PARAMETER FILE

      OPEN(26,FILE='OUTPUT/Para.history',status='unknown'
     >,POSITION='APPEND')
      write(*,*) 'The FIRST Parameter file read from ',FILEPAR
      write(26,200) FILEPAR
200   FORMAT(A100)
      CLOSE(26)

      CALL MESH
      CALL INDICES
      CALL IMMERSED
      CALL INIWAVE

      CALL INITFQ(F) ! by S.H.Lee

      NSAVE=NFLINF                ! by S.H.LEE 
      NAVG=0                
      NTIME=NSTART
!      IMORE=0                ! Index of written file
!      DTR=DT
      DT=DTR
      
      IF(NREAD.EQ.0) THEN
      WRITE (*,*) 'Making initial field : VPER=',VPER
      CALL INIUP(U,P)
      ELSEIF(NREAD.EQ.1) THEN
      CALL READUP(U,P)
      ELSEIF(NREAD.EQ.2) THEN
      CALL READUP2(U,P)   ! N1M/2 -> N1M convert
      ELSEIF(NREAD.EQ.3) THEN
      CALL READUP3(U,P)   ! N3M/2 -> N3M Convert
!      ELSEIF(NREAD.EQ.4) THEN
!      CALL READ_INS(U,P)   ! USE INSTANT FILE TO INIITIAL UP
      ENDIF


      IF(IAVG.GE.1) CALL INIAVE(NAVG)   ! by S.H.Lee
      
      TIME=TSTART

      CALL DIVCHECK_CFL(U,DIVMAX,CFLM)
c     CALL DIVCHECK(U,DIVMAX)
c     CALL CFL(U,CFLM)
      Write(*,*)
      WRITE (*,100) DIVMAX,CFLM*DT


!      DO 10 NTIME=NSTART,NFINAL
!      NTIME=NSTART
      
20    t0=rtc()
      t1=mclock()
     
      IF (IREPAR.EQ.1) THEN
      IF (NTIME.NE.NSTART.AND.MOD(NTIME-1,NREPAR).EQ.0) THEN
      CALL SETUP   ! RE-READING PARAMETER FILE

      OPEN(26,FILE='OUTPUT/Para.history',status='unknown'
     >,POSITION='APPEND')
      write(*,*)  NTIME,'th step : Parameter file re-read from ',FILEPAR
      write(26,201) NTIME,FILEPAR
201   FORMAT (I7,5X,A100)
      CLOSE(26)

      ENDIF ! FOR NTIME
      ENDIF ! FOR IREPAR

      CALL CFL(U,CFLM)
      IF (CFLM*DTR.GE.CFLMAX.AND.IDTOPT.EQ.1) DT=CFLMAX/CFLM
      IF (CFLM*DTR.LE.CFLMAX.OR.IDTOPT.NE.1) DT=DTR

      TIME=TIME+DT

      Write(*,*)
      Write(*,99) 
      WRITE(*,101) NTIME,TIME,DT
      Write(*,99) 
      Write(*,*)

c -------- INFLOW FILE OPEN FOR READING PER NINFLOW STEP-------------
      IF (ITYPE.EQ.1) THEN 
      IF (MOD(NTIME-1,NINFLOW).EQ.0) THEN
      IF (NTIME.NE.NSTART) CLOSE(81)
      FILEW=FILEINF
      N=INDEX(FILEW,'.')
      WRITE(UNIT=FILEW(N+1:),FMT='(BN,I6.6)') NFLINF+NTIME
      write(*,*) 'INFLOW FILE OPENING FOR READING : FILE=',FILEW
      IF (IFORINF.EQ.0) THEN ! INFLOW DATA : UNFORMATTED FORM
      OPEN(81,FILE=FILEW,FORM='UNFORMATTED',STATUS='OLD')
      ELSE                   ! INFLOW DATA : FORMMATED FORM
      OPEN(81,FILE=FILEW,STATUS='OLD')
      ENDIF ! FOR IFORINF
      ENDIF ! FOR MOD(NTIME-1,NINFLOW)
      ENDIF ! FOR ITYPE
c----------------------------------------------------------------

      PI=ACOS(-1.)      

      CALL GETUP(U,P)

      CALL DIVCHECK_CFL(U,DIVMAX,CFLM)
c     CALL DIVCHECK(U,TIME,DIVMAX)
c     CALL CFL(U,CFLM)

c -------- INFLOW FILE OPEN FOR SAVING PER NINFLOW STEP
      IF (ITYPE.EQ.0.AND.INFSAVE.EQ.1) THEN
      NSAVE=NSAVE+1
      IF (MOD(NSAVE-1,NINFLOW).EQ.0) THEN
      IF (NSAVE.NE.NFLINF) CLOSE(82)
      FILEW=FILEINS
      N=INDEX(FILEW,'.')
      WRITE(UNIT=FILEW(N+1:),FMT='(BN,I6.6)') NSAVE
      write(*,*) 'INFLOW FILE OPENING FOR SAVING : FILE=',FILEW
      IF (IFORINF.EQ.0) THEN ! INFLOW SAVE DATA : UNFORMATTED FORM
      OPEN(82,FILE=FILEW,FORM='UNFORMATTED',STATUS='UNKNOWN')
      ELSE                   ! INFLOW SAVE DATA : FORMATTED FORM
      OPEN(82,FILE=FILEW,STATUS='UNKNOWN')
      ENDIF ! FOR IFORINF
      ENDIF ! FOR MOD(NSAVE-1,NINFLOW)
      CALL SAVE_INFLOW(U,NSAVE)
      ENDIF ! FOR ITYPE AND INFSAVE
c-----------------------------------------------------------

      IF (IWRITEW.EQ.1) CALL WRITE_WALL(U,P)  

      WRITE(*,*)
      WRITE (*,100) DIVMAX,CFLM*DT
      WRITE(*,*)

      IF(IAVG.GE.1.AND.MOD(NTIME,NAVGSTP).EQ.0) THEN
      NAVG=NAVG+1
      CALL AVERAGE(U,P,NAVG)
      ENDIF

!      IF (ITHIST.EQ.1) CALL THIST(U,P)  

      IF(MOD(NTIME,NPRN).EQ.0) THEN
      IF(NWRITE.EQ.1) CALL WRITEUP(U,P)
!      IF(IPROF.EQ.1) CALL PROFILE(U,P)
      IF(IAVG.GE.1) Call OUTPUT(NAVG)
      ENDIF

      IF(INSF.EQ.1.AND.MOD(NTIME,NINS).EQ.0) CALL INSFIELD(U,P)

         t0=rtc()-t0
         t1=mclock()-t1
         write(6,*) 'Elapsed time',t0
!         write(6,*) 'CPU     time',t1*1.e-2

      NTIME=NTIME+1
 
      IF (NTIME.GT.NFINAL) GOTO 10
      GOTO 20

 10   CONTINUE
!      tt0=rtc()-tt0
      tt0 = secnds(tt0)
      write(6,*) 'DCTBL running on : ',nthds,' Threads',tt0



99    Format ('==================================================')
100   FORMAT('Maximum divergence=',E12.5,X,'Maximum CFL number=',E12.5)
101   Format( I6,'th step   Time : ',E12.5, ' DT : ',E12.5) 

      STOP
      END

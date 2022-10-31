
C*************** THIST *********************
C      SUBROUTINE THIST(TIME,U,P)
      SUBROUTINE THIST(U,P)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)
 
!     Time history of Cf .... added by S.H.LEE
!-------------------------------------------------
      REAL WSBM(M1)  ! by S.H.LEE
      REAL NZ        ! by S.H.LEE
      
      NZ=1./REAL(N3M)

      OPEN (74,FILE='OUTPUT/THIST_Cf.plt',STATUS='UNKNOWN',
     >POSITION='APPEND')

      I1=ITHIST1
      I2=ITHIST2
      I3=ITHIST3
      I4=ITHIST4
      I5=ITHIST5
      I6=ITHIST6
      I7=ITHIST7
      I8=ITHIST8
      I9=ITHIST9

      WRITE(74,200) TIME,WSBM(I1),WSBM(I2),WSBM(I3)
     >                  ,WSBM(I4),WSBM(I5),WSBM(I6)
     >                  ,WSBM(I7),WSBM(I8),WSBM(I9)
  200 FORMAT(10(E12.5,2X))
      CLOSE(74)
!--------------------------------------------------      

      
      OPEN (70,FILE='OUTPUT/THIST_U.plt',STATUS='UNKNOWN',
     >POSITION='APPEND')
      OPEN (71,FILE='OUTPUT/THIST_V.plt',STATUS='UNKNOWN',
     >POSITION='APPEND')
      OPEN (72,FILE='OUTPUT/THIST_W.plt',STATUS='UNKNOWN',
     >POSITION='APPEND')
      OPEN (73,FILE='OUTPUT/THIST_P.plt',STATUS='UNKNOWN',
     >POSITION='APPEND')
      IF (IAVG.EQ.0) THEN
     
      MONI_X_1=1
      MONI_X_2=N1M/2
      MONI_Y_1=1
      MONI_Y_2=N2M/2
      MONI_Y_3=N2M
      MONI_Y_4=N2
      
      WRITE(70,100) TIME,U(MONI_X_1,MONI_Y_1,N3M/2,1)
     >                  ,U(MONI_X_1,MONI_Y_2,N3M/2,1)
     >                  ,U(MONI_X_1,MONI_Y_3,N3M/2,1)
     >                  ,U(MONI_X_1,MONI_Y_4,N3M/2,1)
     >                  ,U(MONI_X_2,MONI_Y_1,N3M/2,1)
     >                  ,U(MONI_X_2,MONI_Y_2,N3M/2,1)
     >                  ,U(MONI_X_2,MONI_Y_3,N3M/2,1)
     >                  ,U(MONI_X_2,MONI_Y_4,N3M/2,1)

      WRITE(71,100) TIME,U(MONI_X_1,MONI_Y_1+1,N3M/2,2)
     >                  ,U(MONI_X_1,MONI_Y_2,N3M/2,2)
     >                  ,U(MONI_X_1,MONI_Y_3,N3M/2,2)
     >                  ,U(MONI_X_1,MONI_Y_4,N3M/2,2)
     >                  ,U(MONI_X_2,MONI_Y_1+1,N3M/2,2)
     >                  ,U(MONI_X_2,MONI_Y_2,N3M/2,2)
     >                  ,U(MONI_X_2,MONI_Y_3,N3M/2,2)
     >                  ,U(MONI_X_2,MONI_Y_4,N3M/2,2)

      WRITE(72,100) TIME,U(MONI_X_1,MONI_Y_1,N3M/2,3)
     >                  ,U(MONI_X_1,MONI_Y_2,N3M/2,3)
     >                  ,U(MONI_X_1,MONI_Y_3,N3M/2,3)
     >                  ,U(MONI_X_1,MONI_Y_4,N3M/2,3)
     >                  ,U(MONI_X_2,MONI_Y_1,N3M/2,3)
     >                  ,U(MONI_X_2,MONI_Y_2,N3M/2,3)
     >                  ,U(MONI_X_2,MONI_Y_3,N3M/2,3)
     >                  ,U(MONI_X_2,MONI_Y_4,N3M/2,3)


      WRITE(73,100) TIME,P(MONI_X_1,MONI_Y_1,N3M/2)
     >                  ,P(MONI_X_1,MONI_Y_2,N3M/2)
     >                  ,P(MONI_X_1,MONI_Y_3,N3M/2)
     >                  ,P(MONI_X_1,MONI_Y_4,N3M/2)
     >                  ,P(MONI_X_2,MONI_Y_1,N3M/2)
     >                  ,P(MONI_X_2,MONI_Y_2,N3M/2)
     >                  ,P(MONI_X_2,MONI_Y_3,N3M/2)
     >                  ,P(MONI_X_2,MONI_Y_4,N3M/2)

100   FORMAT (9(E12.5,2X))

      ENDIF
  
      IF (IAVG.GE.1.AND.MOD(NTIME,NAVGSTP).EQ.0) THEN

      I=IAVGMON
      J=JAVGMON 

      OPEN (76,FILE='OUTPUT/THIST_MEAN.plt',STATUS='UNKNOWN',
     >POSITION='APPEND')
      OPEN (77,FILE='OUTPUT/THIST_RMS.plt',STATUS='UNKNOWN',
     >POSITION='APPEND')


      WRITE(76,400) TIME,VM(1,I,J),VM(2,I,J),VM(3,I,J),PM(I,J) 
      WRITE(77,401) TIME
     >        ,VVM(1,I,J)-VM(1,I,J)**2
     >        ,VVM(2,I,J)-VM(2,I,J)**2
     >        ,VVM(3,I,J)-VM(3,I,J)**2
     >        ,-1.*VVM(4,I,J)+VM(1,I,J)*VM(2,I,J)
     >        ,PPM(I,J)-PM(I,J)**2
      CLOSE(76)
      CLOSE(77)
      
      IF (IAVGB.EQ.1) THEN
      OPEN (78,FILE='OUTPUT/THIST_HIGH.plt',STATUS='UNKNOWN',
     >POSITION='APPEND')
      WRITE(78,402) TIME
     >        ,V3M(1,I,J),V3M(2,I,J),V3M(3,I,J),P3M(I,J)
     >        ,V4M(1,I,J),V4M(2,I,J),V4M(3,I,J),P4M(I,J)
      ENDIF ! FOR IAVGB
      CLOSE(78)

      ENDIF ! FOR IAVG

400   FORMAT(5(E12.5,2X))
401   FORMAT(6(E12.5,2X))
402   FORMAT(9(E12.5,2X))


      RETURN
      END

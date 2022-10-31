
C  ************************  READUP2 **********************
C     READ FLOW FIELD AND BOUNDARY CONDITIONS
C     AND MEAN PRESSURE GRADIENT
C     CONVERT N1M/2 DATA -> N1M DATA
 
      SUBROUTINE READUP2(U,P)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL UTEMP(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)
      REAL PTEMP(M1,M2,M3)
      SAVE UTEMP,PTEMP

      IF (IFORIN.EQ.0) THEN    ! INPUT FILE FORMAT : UNFORMATTED
      write(*,*) 'Reading unformatted initial data from ',fileini
      OPEN(3,FILE=fileini,FORM='UNFORMATTED',STATUS='OLD')
      N1H=N1M/2+1
      READ(3) (((UTEMP(I,J,K,1),UTEMP(I,J,K,2),
     >           UTEMP(I,J,K,3)
     >            ,K=1,N3M),J=0,N2),I=0,N1H)
      READ(3) (((PTEMP(I,J,K),K=1,N3M),J=1,N2M),I=1,N1H-1)
      CLOSE(3)

      ELSE                     ! INPUT FILE FORMAT : FORMMATED
      write(*,*) 'Reading formatted initial data from ',fileini
      OPEN(3,FILE=fileini,STATUS='OLD')
      DO 10 I=0,N1H
      DO 10 J=0,N2
      DO 10 K=1,N3M
      READ(3,100) UTEMP(I,J,K,1),UTEMP(I,J,K,2),UTEMP(I,J,K,3) 
   10 CONTINUE
      DO 20 I=1,N1H-1
      DO 20 J=1,N2M
      DO 20 K=1,N3M
      READ(3,200) PTEMP(I,J,K) 
   20 CONTINUE
 100  FORMAT(3(e15.7,x))
 200  FORMAT(e15.7)

      write(*,*) 'Reading done'

      ENDIF ! FOR IFORIN 
     
      ! Interpolation to use N1M * 2

      write(*,*) 'Interpolation start'

      DO K=1,N3M
      DO J=0,N2
      I=0
      U(I,J,K,1)=UTEMP(I,J,K,1)
      U(2*I,J,K,2)=0.75*UTEMP(I,J,K,2)+0.25*UTEMP(I+1,J,K,2)
      U(2*I+1,J,K,2)=0.25*UTEMP(I,J,K,2)+0.25*UTEMP(I+1,J,K,2)
      U(2*I,J,K,3)=0.75*UTEMP(I,J,K,3)+0.25*UTEMP(I+1,J,K,3)
      U(2*I+1,J,K,3)=0.25*UTEMP(I,J,K,3)+0.25*UTEMP(I+1,J,K,3)
      DO I=1,N1H-1
      U(2*I-1,J,K,1)=UTEMP(I,J,K,1)
      U(2*I,J,K,1)=0.5*(UTEMP(I,J,K,1)+UTEMP(I+1,J,K,1))
      U(2*I,J,K,3)=0.75*UTEMP(I,J,K,3)+0.25*UTEMP(I+1,J,K,3)
      U(2*I+1,J,K,3)=0.25*UTEMP(I,J,K,3)+0.25*UTEMP(I+1,J,K,3)
      ENDDO 
      I=N1H
      U(N1,J,K,1)=UTEMP(N1H,J,K,1)
      ENDDO
      ENDDO 
      
      DO K=1,N3M
      DO J=1,N2M
      I=1
      P(I,J,K)=PTEMP(I,J,K) 
      DO I=1,N1H-2 
      P(2*I,J,K)=0.75*PTEMP(I,J,K)+0.25*PTEMP(I+1,J,K)
      P(2*I+1,J,K)=0.25*PTEMP(I,J,K)+0.25*PTEMP(I+1,J,K)
      ENDDO
      I=N1H-1
      P(N1M,J,K)=PTEMP(I,J,K) 
      ENDDO
      ENDDO
 
      write(*,*) 'Interploation End'

      IF (NWRITE.EQ.1) THEN
      WRITE(*,*) 'Writing Interpolated Data'
      CALL WRITEUP(U,P)
      ENDIF
 
      RETURN
      END


C  ************************  READUP3 **********************
C     READ FLOW FIELD AND BOUNDARY CONDITIONS
C     AND MEAN PRESSURE GRADIENT
C     CONVERT N3M/2 DATA -> N3M DATA
 
      SUBROUTINE READUP3(U,P)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL UTEMP(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)
      REAL PTEMP(M1,M2,M3)
      SAVE UTEMP,PTEMP

      IF (IFORIN.EQ.0) THEN    ! INPUT FILE FORMAT : UNFORMATTED
      write(*,*) 'Reading unformatted initial data from ',fileini
      OPEN(3,FILE=fileini,FORM='UNFORMATTED',STATUS='OLD')
      N3MH=N3M/2
      READ(3) (((UTEMP(I,J,K,1),UTEMP(I,J,K,2),
     >           UTEMP(I,J,K,3)
     >            ,K=1,N3MH),J=0,N2),I=0,N1)
      READ(3) (((PTEMP(I,J,K),K=1,N3MH),J=1,N2M),I=1,N1M)
      CLOSE(3)

      ELSE                     ! INPUT FILE FORMAT : FORMMATED
      write(*,*) 'Reading formatted initial data from ',fileini
      OPEN(3,FILE=fileini,STATUS='OLD')
      DO 10 I=0,N1
      DO 10 J=0,N2
      DO 10 K=1,N3MH
      READ(3,100) UTEMP(I,J,K,1),UTEMP(I,J,K,2),UTEMP(I,J,K,3) 
   10 CONTINUE
      DO 20 I=1,N1M
      DO 20 J=1,N2M
      DO 20 K=1,N3MH
      READ(3,200) PTEMP(I,J,K) 
   20 CONTINUE
 100  FORMAT(3(e15.7,x))
 200  FORMAT(e15.7)

      write(*,*) 'Reading done'


      ENDIF ! FOR IFORIN 
     
      ! Interpolation to use N1M * 2

      write(*,*) 'Interpolation start'

      DO K=1,N3MH-1
      DO J=0,N2
      DO I=0,N1
      DO L=1,3
      U(I,J,2*K-1,L)=UTEMP(I,J,K,L)
      U(I,J,2*K,L)=0.5*(UTEMP(I,J,K,L)+UTEMP(I,J,K+1,L))
      ENDDO 
      ENDDO
      ENDDO
      ENDDO

      K=N3MH
      DO J=0,N2
      DO I=0,N1
      DO L=1,3
      U(I,J,2*K-1,L)=UTEMP(I,J,K,L)
      U(I,J,2*K,L)=0.5*(UTEMP(I,J,K,L)+UTEMP(I,J,1,L))
      ENDDO 
      ENDDO
      ENDDO
      
      DO K=1,N3MH-1
      DO J=1,N2M
      DO I=1,N1M
      P(I,J,2*K-1)=PTEMP(I,J,K)
      P(I,J,2*K)=0.5*(PTEMP(I,J,K)+PTEMP(I,J,K+1))
      ENDDO
      ENDDO
      ENDDO

      K=N3MH
      DO J=1,N2M
      DO I=1,N1M
      P(I,J,2*K-1)=PTEMP(I,J,K)
      P(I,J,2*K)=0.5*(PTEMP(I,J,K)+PTEMP(I,J,1))
      ENDDO 
      ENDDO
      
 
      write(*,*) 'Interploation End'


      IF (NWRITE.EQ.1) THEN
      WRITE(*,*) 'Writing Interpolated Data'
      CALL WRITEUP(U,P)
      ENDIF
 
      RETURN
      END

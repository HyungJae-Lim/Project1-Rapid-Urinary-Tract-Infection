
C  ************************  READUP **********************
C     READ FLOW FIELD AND BOUNDARY CONDITIONS
C     AND MEAN PRESSURE GRADIENT

      SUBROUTINE READUP(U,P)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)

      IF (IFORIN.EQ.0) THEN    ! INPUT FILE FORMAT : UNFORMATTED
      write(*,*) 'Reading unformatted initial data from ',fileini
      OPEN(3,FILE=fileini,FORM='UNFORMATTED',STATUS='OLD')
!      READ(3) (((U(I,J,K,1),U(I,J,K,2),U(I,J,K,3)
!     >            ,K=1,N3M),J=0,N2),I=0,N1)
!      READ(3) (((P(I,J,K),K=1,N3M),J=1,N2M),I=1,N1M)
!-----------------------------------------------------
!     Changed because big file
!      DO I=0,N1
!      DO J=0,N2
!      DO K=1,N3M
!      READ(3) U(I,J,K,1),U(I,J,K,2),U(I,J,K,3)
!      ENDDO
!      ENDDO
!      ENDDO
!      DO I=1,N1M
!      DO J=1,N2M
!      DO K=1,N3M
!      READ(3) P(I,J,K)
!      ENDDO
!      ENDDO
!      ENDDO
!-------------------------------------------------------
      DO L=1,3
      READ(3) (((U(I,J,K,L)
     >           ,I=0,N1),J=0,N2),K=1,N3M)
      ENDDO
      READ(3) (((P(I,J,K),I=1,N1M),J=1,N2M),K=1,N3M)


      CLOSE(3)
      
      ELSE                     ! INPUT FILE FORMAT : FORMMATED
      write(*,*) 'Reading formatted initial data from ',fileini
      OPEN(3,FILE=fileini,STATUS='OLD')
      DO 10 I=0,N1
      DO 10 J=0,N2
      DO 10 K=1,N3M
      READ(3,100) U(I,J,K,1),U(I,J,K,2),U(I,J,K,3) 
   10 CONTINUE
      DO 20 I=1,N1M
      DO 20 J=1,N2M
      DO 20 K=1,N3M
      READ(3,200) P(I,J,K) 
   20 CONTINUE
 100  FORMAT(3(e15.7,x))
 200  FORMAT(e15.7)
      
      ENDIF ! FOR IFORIN 
      RETURN
      END

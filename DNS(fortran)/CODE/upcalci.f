
c***************** UPCALCI ***********************     
      SUBROUTINE UPCALCI(U,P,UHI,DPI)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)
      REAL UHI(0:M1,0:M2,0:M3,3)
      REAL DPI(M1,M2,M3)
      
C     U1 VELOCITY UPDATE
      
!$omp  parallel do private(KM)
      DO K=1,N3M

         J=0
      DO I=1,N1
         U(I,J,K,1)=UBC1(1,I,K)
      ENDDO
      DO J=1,N2M
         U(1,J,K,1)=UBC3(1,J,K)
      DO I=2,N1M
         U(I,J,K,1)=UHI(I,J,K,1)
     >             -DT*(DPI(I,J,K)-DPI(I-1,J,K))*DX1
      ENDDO
         U(N1,J,K,1)=UBC4(1,J,K)
      ENDDO
         J=N2
      DO I=1,N1
         U(I,N2,K,1)=UBC2(1,I,K)
      ENDDO
       
c     U2 VELOCITY UPDATE

         J=1
         U(0,J,K,2)=UBC3(2,J,K)
      DO I=1,N1
         U(I,J,K,2)=UBC1(2,I,K)
      ENDDO
         U(N1,J,K,2)=UBC4(2,J,K)
      DO J=2,N2M
         U(0,J,K,2)=UBC3(2,J,K)
      DO I=1,N1M
         U(I,J,K,2)=UHI(I,J,K,2)
     >             -DT*(DPI(I,J,K)-DPI(I,J-1,K))/H(J)
      ENDDO
         U(N1,J,K,2)=UBC4(2,J,K)
      ENDDO
         J=N2
      DO I=1,N1
         U(I,J,K,2)=UBC2(2,I,K)
      ENDDO

C     U3 VELOCITY UPDATE

         KM=KMA(K)
         J=0
      DO I=1,N1
         U(I,0,K,3)=UBC1(3,I,K)
      ENDDO
      DO J=1,N2M
         U(0,J,K,3)=UBC3(3,J,K)
      DO I=1,N1M
         U(I,J,K,3)=UHI(I,J,K,3)
     >             -DT*(DPI(I,J,K)-DPI(I,J,KM))*DX3
      ENDDO
         U(N1,J,K,3)=UBC4(3,J,K)
      ENDDO
         J=N2
      DO I=1,N1
         U(I,N2,K,3)=UBC2(3,I,K)
      ENDDO
       
C     PRESSURE UPDATE     
 
      DO J=1,N2M
      DO I=1,N1M
         P(I,J,K)=P(I,J,K)+DPI(I,J,K)
      ENDDO
      ENDDO

      ENDDO
      
      RETURN
      END


c***************** INDICES ***********************     
      SUBROUTINE INDICES

      INCLUDE 'dctbl.h'

      DO 10 I=1,N1M
      IPA(I)=I+1
      IMU(I)=I-1
 10   IMV(I)=I-1
      IPA(N1M)=N1M
      IMU(2)=2
      IMV(1)=1

      DO 20 K=1,N3M
      KPA(K)=K+1
 20   KMA(K)=K-1
      KPA(N3M)=1
      KMA(1)=N3M

      DO 30 J=1,N2M
      JPA(J)=J+1
      JMU(J)=J-1
 30   JMV(J)=J-1
      JPA(N2M)=N2M
      JMU(1)=1
      JMV(2)=2

      DO J=1,N2M
      FJMU(J)=J-JMU(J)
      FJMV(J)=J-JMV(J)
      FJPA(J)=JPA(J)-J
      ENDDO
      DO I=1,N1M
      FIMU(I)=I-IMU(I)
      FIMV(I)=I-IMV(I)
      FIPA(I)=IPA(I)-I
      ENDDO
      
      RETURN
      END

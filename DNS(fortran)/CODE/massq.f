
c**************** MASSQ *************************
c     by S.H.LEE
      SUBROUTINE MASSQ(UH)
      INCLUDE 'dctbl.h'

      Real UH(0:M1,0:M2,0:M3,3)

      IF (IMASS.EQ.0) THEN  ! NOT USING MASS SOURCE
!$omp parallel do 
      DO 20 K=1,N3M
      DO 20 J=1,N2M
      DO 20 I=1,N1M
      Q(I,J,K)=0.
   20 CONTINUE 

      ELSE                  ! USING MASS SOURCE
!$omp parallel do private(KP,JP,IP)
      DO 10 K=1,N3M
      KP=KPA(K)
      DO 10 J=1,N2M
      JP=J+1
      DO 10 I=1,N1M
      IP=I+1

      Q(I,J,K)=QIP(I,J)*UH(IP,J,K,1)+QI(I,J)*UH(I,J,K,1)
     >        +QJP(I,J)*UH(I,JP,K,2)+QJ(I,J)*UH(I,J,K,2)
     >        +QKP(I,J)*UH(I,J,KP,3)+QK(I,J)*UH(I,J,K,3)
  10  CONTINUE
      ENDIF ! FOR IMASS

      RETURN
      END


c***************** RHSDP ***********************     
      SUBROUTINE RHSDP(RDP,UH)
      INCLUDE 'dctbl.h'

      REAL UH(0:M1,0:M2,0:M3,3)
      REAL RDP(M1,M2,M3)
      
!$omp parallel do private(KP,KM,JP,JM,IP,IM,FJUM,FJUP,FIUM,FIUP,
!$omp& DIVUH,CBC)
      DO 10 K=1,N3M
         KP=KPA(K)
         KM=KMA(K)
      
      DO 10 J=1,N2M
         JP=J+1
         JM=J-1
         FJUM=FJMU(J)
         FJUP=FJPA(J)

      DO 10 I=1,N1M
         IP=I+1
         IM=I-1
         FIUM=FIMV(I)
         FIUP=FIPA(I)
      

      DIVUH=(FIUP*UH(IP,J,K,1)-FIUM*UH(I,J,K,1))*DX1
     >     +(FJUP*UH(I,JP,K,2)-FJUM*UH(I,J,K,2))/DY(J)
     >     +(UH(I,J,KP,3)-UH(I,J,K,3))*DX3

      CBC=(1.-FJUM)*UBC1(2,I,K)/DY(J)
     >   -(1.-FJUP)*UBC2(2,I,K)/DY(J)
     >   +(1.-FIUM)*UBC3(1,J,K)*DX1
     >   -(1.-FIUP)*UBC4(1,J,K)*DX1

!      RDP(I,J,K)=(DIVUH-CBC-Q(I,J,K))/DT    ! modified by S.H.LEE
      RDP(I,J,K)=(DIVUH-CBC)/DT    ! modified by S.H.LEE
  10  CONTINUE
      
      RETURN 
      END

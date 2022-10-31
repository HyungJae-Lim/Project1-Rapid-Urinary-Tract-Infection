C*************** AVERAGE **********************
      SUBROUTINE AVERAGE(U,P,NAVG)

      INCLUDE 'dctbl.h'


      REAL U(0:M1,0:M2,0:M3,3),P(M1,M2,M3)
      REAL V(3)
      REAL VOR(3)
      INTEGER PHKL,TM
      RNAVG=DBLE(NAVG)

!$omp  parallel do private(IP,IM,IUM,IUP,JP,JM,JUM,JUP,
!$omp& KP,KM,KPP,V,PHKL,
!$omp& VOR,DV3DX2,DV2DX3,DV3DX1,DV1DX3,DV2DX1
!$omp& DV1DX2,U1KP,U1KM,U2KP,U2KM,U2IP,U2IM,U3IP,U3IM,
!$omp& U1JP,U1JC,U1JM,U12,U11,U3JP,U3JC,U3JM,U32,U31)
       
       
      DO 1  K=1,N3M
        KP=KPA(K)
        KM=KMA(K)
        KPP=KPA(KP)

      DO 1 J=1,N2M
        JP=J+1
        JM=J-1
        JUM=J-JMU(J)
        JUP=JPA(J)-J

      DO 1  I=1,N1M
        IP=I+1
        IM=I-1
        IUM=I-IMV(I)
        IUP=IPA(I)-I
      

C     INSTANTANEOUS VELOCITY AND PRESSURE AT CELL CENTER AND NEIGHBOR
!PHASE AVG added

      
      V(1)=(U(I,J,K,1)+U(IP,J ,K ,1))*0.5       
      V(2)=(U(I,J,K,2)+U(I ,JP,K ,2))*0.5
      V(3)=(U(I,J,K,3)+U(I ,J ,KP,3))*0.5

C     INSTANTANEOUS VORTICITY AT CELL CENTER

      DO L=1,3
      VM(L,I,J,K)=(V(L)+(RNAVG-1.)*VM(L,I,J,K))/RNAVG
      ENDDO

   1  CONTINUE


      
      RETURN
      END

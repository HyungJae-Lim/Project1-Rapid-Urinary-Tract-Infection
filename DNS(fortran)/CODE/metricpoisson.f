

C  ************************ METRICPOISSON  **********************
      SUBROUTINE METRICPOISSON

      INCLUDE 'dctbl.h'
      COMMON/METPOI/PMJ(M2),PCJ(M2),PPJ(M2)

      DO 100 J=1,N2M
      JP=J+1
      JM=J-1
      JUM=J-JMU(J)
      JUP=JPA(J)-J
      PMJ(J)=JUM*JUP*(1.0/DY(J)/H(J))+(1-JUP)*(1.0/DY(N2M)/H(N2M))
      PCJ(J)=JUM*JUP*(-1.0/DY(J)/H(J)-1.0/DY(J)/H(JP))
     >       +(1-JUP)*(-1.0/DY(N2M)/H(N2M))
     >       +(1-JUM)*(-1.0/DY(1)/H(2))
      PPJ(J)=JUM*JUP*(1.0/DY(J)/H(JP))+(1-JUM)*(1.0/DY(1)/H(2))
  100 CONTINUE

      RETURN
      END

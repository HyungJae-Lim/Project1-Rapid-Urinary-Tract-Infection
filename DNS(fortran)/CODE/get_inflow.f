
c*************** Get_inflow ***********************
c      Subroutine Get_inflow(um_rc,um_in,uf_in,delta_in)
      SUBROUTINE GET_INFLOW
      INCLUDE 'dctbl.h'

      REAL U_IN(3,0:M2,0:M3)
c      REAL UM_RC(3,0:M2)
c      REAL UM_IN(3,2,0:M2)
c      REAL UF_IN(3,2,0:M2,0:M3)
c          UF_IN(NV,ND,J ,K )
c                NV : variables
c                ND : nondimensionalized length scale
c                Return mean profile as UF_IN(NV,1,J,K)

      REAL V_INF(M1)
      REAL V_INF_LOCAL(M1)
      REAL X(M1)
      REAL M

      DO 10 NV=1,3
      DO 10 J=1,N2M
      DO 10 K=1,N3M
      U_IN(NV,J,K)=UM_IN(NV,1,J)+UF_IN(NV,1,J,K)
10    CONTINUE

c     To avoid abrupt change of mass flow at inlet
c     Adjusting the mass flow rate at inlet

      FLOW_M=0.0
      DO 15 J=1,N2M
c15    FLOW_M=FLOW_M+UM_IN(1,1,J)*DY(J)
15    FLOW_M=FLOW_M+UMEAN(1,1,J)*DY(J)
      FLOW_IN=0.0
      DO 16 J=1,N2M
      DO 16 K=1,N3M
16    FLOW_IN=FLOW_IN+U_IN(1,J,K)*DY(J)/REAL(N3M)

      RATE=FLOW_IN/FLOW_M

      DO 20 NV=1,3
      DO 20 J=1,N2M
      DO 20 K=1,N3M
20    UBC3(NV,J,K)=U_IN(NV,j,k) 

c     Impose  V at upper boundary
c     Calculate the growth rate of displacement thickness
c     and find v_inf

      DO 31 I=1,N1M
      DELSTA_IP=0.0
      DELSTA_IC=0.0
      Do 30 J=1,N2m
c      IF (I.EQ.1) THEn
c      U_Z=0.0
c      DO K=1,N3M
c      U_Z=U_Z+UBC3(1,J,K)/REAL(N3M)
c      ENDDO
c      DELSTA_IC=DELSTA_IC+(1.-U_Z)*DY(J)
c      ELSE
c      DELSTA_IC=DELSTA_IC+(1.-UMEAN(1,I,J))*DY(J)*RATE
c      ENDIF
      DELSTA_IC=DELSTA_IC+(1.-UMEAN(1,I,J)*RATE)*DY(J)
30    DELSTA_IP=DELSTA_IP+(1.-UMEAN(1,I+1,J)*RATE)*DY(J)
      X(I)=REAL(I-0.5)/REAL(N1M)*ALX
31    V_INF_LOCAL(I)=(DELSTA_IP-DELSTA_IC)*DX1

c     Linear regression of v_inf(i) as m*x(i)+b

      A11=REAL(N1M)  

      A12=0.0
      DO 32 I=1,N1M
32    A12=A12+X(I) 

      R_1=0.0
      DO 33 I=1,N1M
33    R_1=R_1+V_INF_LOCAL(I) 

      A21=A12

      A22=0.0
      DO 34 I=1,N1M
34    A22=A22+X(I)**2

      R_2=0.0
      DO 35 I=1,N1M
35    R_2=R_2+X(I)*V_INF_LOCAL(I) 

      M=(R_1*A21-R_2*A11)/(A21*A12-A22*A11)
      B=(R_1*A22-R_2*A12)/(A22*A11-A12*A21)

      DO 36 I=1,N1m
36    V_INF(I)=M*X(I)+B

      DO 40 I=1,N1M
      DO 40 K=1,N3M
40    UBC2(2,I,K)=V_INF(I)

      WRITE(*,100) UBC2(2,1,1),UBC2(2,N1M,1)
100   FORMAT('V_inf varies from ',E13.7,' to ',E13.7)
      WRITE(*,*)

      RETURN
      END

      Program MAIN

      INCLUDE 'rough.h'

      Call SETUP

      DO 1 J=1,N2M    ! before roughness
      DO 1 I=1,IB-1
      DO 1 L=1,3
      NF(L,I,J)=0
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
   1  continue
      
      IF((epsx.EQ.0.0).AND.(epsy.EQ.0.0)) THEN
	
      DO 10 J=1,N2M
      JP=J+1
      JM=J-1
      DO 10 I=IB,N1M
      IP=IPA(I)
      II=MOD(I-IB,IL)+1  ! I=IB => II=1, I=IB+IL-1 => II=IL 
      
!     FOR U
	
      L=1
      IM=IMU(I)
      ! FOR TOP WALL 

      IF ((II.GE.2).AND.(II.LE.IW).AND.(J.EQ.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=I
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=(epsy*DY(JB)+0.5*DY(JB-1))/(0.5*DY(JB)+0.5*DY(JB-1))

      ! FOR LEFT WALL

      ELSE IF ((II.EQ.1).AND.(J.GE.1).AND.(J.LE.JB-2)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.

      ! FOR RIGHT WALL
      ELSE IF ((II.EQ.IW+1).AND.(J.GE.1).AND.(J.LE.JB-2)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
     
      ! FOR LEFT CORNER
      ELSE IF ((II.EQ.1).AND.(J.EQ.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=0.

      ! FOR RIGHT CORNER
      ELSE IF ((II.EQ.IW+1).AND.(J.EQ.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
      
      ! FOR INNER POINT
      ELSE IF ((II.GE.2).AND.(II.LE.IW).AND.
     >(J.GE.1).AND.(J.LE.JB-2)) THEN
      NF(L,I,J)=2
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
     
      ! FOR OUTER POINT
      ELSE
      NF(L,I,J)=0
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.

      ENDIF

!     FOR V
      
      L=2
      IM=IMV(I)
      ! FOR TOP WALL 

      IF ((II.GE.2).AND.(II.LE.IW-1).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=I
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=0.

      ! FOR LEFT WALL

      ELSE IF ((II.EQ.1).AND.(J.GE.2).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=J
      alpha(L,I,J)=0.5
      beta(L,I,J)=0.

      ! FOR RIGHT WALL
      ELSE IF ((II.EQ.IW).AND.(J.GE.2).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=J
      alpha(L,I,J)=0.5
      beta(L,I,J)=0.
     
      ! FOR LEFT CORNER
      ELSE IF ((II.EQ.1).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=0.

      ! FOR RIGHT CORNER
      ELSE IF ((II.EQ.IW).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
      
      ! FOR INNER POINT
      ELSE IF ((II.GE.2).AND.(II.LE.IW-1).AND.
     >(J.GE.2).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=2
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
     
      ! FOR OUTER POINT
      ELSE
      NF(L,I,J)=0
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.

      ENDIF

!     FOR W
      
      L=3
      IM=IMV(I)
      ! FOR TOP WALL 

      IF ((II.GE.2).AND.(II.LE.IW-1).AND.(J.EQ.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=I
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=(epsy*DY(JB)+0.5*DY(JB-1))/(0.5*DY(JB)+0.5*DY(JB-1))

      ! FOR LEFT WALL

      ELSE IF ((II.EQ.1).AND.(J.GE.1).AND.(J.LE.JB-2)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=J
      alpha(L,I,J)=0.5
      beta(L,I,J)=0.

      ! FOR RIGHT WALL
      ELSE IF ((II.EQ.IW).AND.(J.GE.1).AND.(J.LE.JB-2)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=J
      alpha(L,I,J)=0.5
      beta(L,I,J)=0.
     
      ! FOR LEFT CORNER
      ELSE IF ((II.EQ.1).AND.(J.EQ.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.5
      beta(L,I,J)=(epsy*DY(JB)+0.5*DY(JB-1))/(0.5*DY(JB)+0.5*DY(JB-1))

      ! FOR RIGHT CORNER
      ELSE IF ((II.EQ.IW).AND.(J.EQ.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.5
      beta(L,I,J)=(epsy*DY(JB)+0.5*DY(JB-1))/(0.5*DY(JB)+0.5*DY(JB-1))
      
      ! FOR INNER POINT
      ELSE IF ((II.GE.2).AND.(II.LE.IW-1).AND.
     >(J.GE.1).AND.(J.LE.JB-2)) THEN
      NF(L,I,J)=2
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
     
      ! FOR OUTER POINT
      ELSE
      NF(L,I,J)=0
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.

      ENDIF

      
10    CONTINUE

      ELSE IF ((epsx.EQ.0.5).AND.(epsy.EQ.0.5)) THEN
	      
      DO 20 J=1,N2M
      JP=J+1
      JM=J-1
      DO 20 I=IB,N1M
      IP=IPA(I)
      II=MOD(I-IB,IL)+1  ! I=IB => II=1, I=IB+IL-1 => II=IL 

!     FOR U
	
      L=1
      IM=IMU(I)
      ! FOR TOP WALL 

      IF ((II.GE.3).AND.(II.LE.IW).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=I
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=0.

      ! FOR LEFT WALL

      ELSE IF ((II.EQ.2).AND.(J.GE.1).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=J
      alpha(L,I,J)=0.5
      beta(L,I,J)=0.

      ! FOR RIGHT WALL
      ELSE IF ((II.EQ.IW+1).AND.(J.GE.1).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=J
      alpha(L,I,J)=0.5
      beta(L,I,J)=0.
     
      ! FOR LEFT CORNER
      ELSE IF ((II.EQ.2).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=0.

      ! FOR RIGHT CORNER
      ELSE IF ((II.EQ.IW+1).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
      
      ! FOR INNER POINT
      ELSE IF ((II.GE.3).AND.(II.LE.IW).AND.
     >(J.GE.1).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=2
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
     
      ! FOR OUTER POINT
      ELSE
      NF(L,I,J)=0
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.

	
      ENDIF

!     FOR V
      
      L=2
      IM=IMV(I)
      ! FOR TOP WALL 

      IF ((II.GE.2).AND.(II.LE.IW).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=I
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=0.5

      ! FOR LEFT WALL

      ELSE IF ((II.EQ.1).AND.(J.GE.2).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.

      ! FOR RIGHT WALL
      ELSE IF ((II.EQ.IW+1).AND.(J.GE.2).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
     
      ! FOR LEFT CORNER
      ELSE IF ((II.EQ.1).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=0.

      ! FOR RIGHT CORNER
      ELSE IF ((II.EQ.IW+1).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
      
      ! FOR INNER POINT
      ELSE IF ((II.GE.2).AND.(II.LE.IW).AND.
     >(J.GE.2).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=2
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
     
      ! FOR OUTER POINT
      ELSE
      NF(L,I,J)=0
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
      
      ENDIF
      

!     FOR W
      
      L=3
      IM=IMV(I)
      ! FOR TOP WALL 

      IF ((II.GE.2).AND.(II.LE.IW).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=I
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=0.

      ! FOR LEFT WALL

      ELSE IF ((II.EQ.1).AND.(J.GE.1).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.

      ! FOR RIGHT WALL
      ELSE IF ((II.EQ.IW+1).AND.(J.GE.1).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
     
      ! FOR LEFT CORNER
      ELSE IF ((II.EQ.1).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=0.

      ! FOR RIGHT CORNER
      ELSE IF ((II.EQ.IW+1).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=JP
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
      
      ! FOR INNER POINT
      ELSE IF ((II.GE.2).AND.(II.LE.IW).AND.
     >(J.GE.1).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=2
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
     
      ! FOR OUTER POINT
      ELSE
      NF(L,I,J)=0
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      alpha(L,I,J)=0.
      beta(L,I,J)=0.
      
      
      ENDIF
      
      
20    CONTINUE

      ENDIF

      DO 30 J=1,N2M
      DO 30 I=1,N1M
      DO 30 L=1,3
      
      AFI(L,I,J)=-1.*alpha(L,I,J)/(1.-alpha(L,I,J))
      AFJ(L,I,J)=-1.*beta(L,I,J)/(1.-beta(L,I,J))
      AFD(L,I,J)=-1.*AFI(L,I,J)*AFJ(L,I,J)
      IF ((IFU(L,I,J).NE.I).AND.(JFU(L,I,J).EQ.J)) THEN
      AFB(L,I,J)=1./(1.-alpha(L,I,J))/(1.-beta(L,I,J))
      ELSE IF ((IFU(L,I,J).EQ.I).AND.(JFU(L,I,J).NE.J)) THEN
      AFB(L,I,J)=1./(1.-beta(L,I,J))
      ELSE IF ((IFU(L,I,J).NE.I).AND.(JFU(L,I,J).EQ.J)) THEN
      AFB(L,I,J)=1./(1.-alpha(L,I,J))
      ELSE
      AFB(L,I,J)=0.
      ENDIF

30    CONTINUE
      
      call WRITE_IBM

      STOP
      END

c***************** SETUP ***********************     
      Subroutine SETUP

      INCLUDE 'rough.h'

      OPEN(1,FILE='rough.par',STATUS='OLD')
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,301) DUMMY,N1
      WRITE(*,301) DUMMY,N1
      READ (1,301) DUMMY,N2
      WRITE(*,301) DUMMY,N2
      READ (1,301) DUMMY,N3
      WRITE(*,301) DUMMY,N3
      READ (1,302) DUMMY,RE
      WRITE(*,302) DUMMY,RE
      READ (1,302) DUMMY,R_theta_in
      WRITE(*,302) DUMMY,R_theta_in
      READ (1,302) DUMMY,ALX
      WRITE(*,302) DUMMY,ALX
      READ (1,302) DUMMY,ALY
      WRITE(*,302) DUMMY,ALY
      READ (1,302) DUMMY,ALZ
      WRITE(*,302) DUMMY,ALZ
      READ (1,301) DUMMY,INCODE
      WRITE(*,301) DUMMY,INCODE
      READ (1,301) DUMMY,NTST
      WRITE(*,301) DUMMY,NTST
      READ (1,302) DUMMY,VPER
      WRITE(*,302) DUMMY,VPER
      READ (1,302) DUMMY,DT
      WRITE(*,302) DUMMY,DT
      READ (1,301) DUMMY,IDTOPT
      WRITE(*,301) DUMMY,IDTOPT
      READ (1,301) DUMMY,ICONT
      WRITE(*,301) DUMMY,ICONT
      READ (1,302) DUMMY,CFLMAX
      WRITE(*,302) DUMMY,CFLMAX
      READ (1,301) DUMMY,NWRITE
      WRITE(*,301) DUMMY,NWRITE
      READ (1,301) DUMMY,NREAD
      WRITE(*,301) DUMMY,NREAD
      READ (1,301) DUMMY,IAVG
      WRITE(*,301) DUMMY,IAVG
      READ (1,301) DUMMY,NPRN
      WRITE(*,301) DUMMY,NPRN
      READ (1,301) DUMMY,INSF
      WRITE(*,301) DUMMY,INSF
      READ (1,301) DUMMY,NINS
      WRITE(*,301) DUMMY,NINS
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,303) DUMMY,fileini
      WRITE(*,303) DUMMY,fileini
      READ (1,303) DUMMY,fileavg
      WRITE(*,303) DUMMY,fileavg
      READ (1,303) DUMMY,filegrd
      WRITE(*,303) DUMMY,filegrd
      READ (1,303) DUMMY,fileibm
      WRITE(*,303) DUMMY,fileibm
      READ (1,303) DUMMY,fileout
      WRITE(*,303) DUMMY,fileout
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,300) DUMMY
      WRITE(*,300) DUMMY
      READ (1,301) DUMMY,IB
      WRITE(*,301) DUMMY,IB
      READ (1,301) DUMMY,JB
      WRITE(*,301) DUMMY,JB
      READ (1,301) DUMMY,IW
      WRITE(*,301) DUMMY,IW
      READ (1,301) DUMMY,IL
      WRITE(*,301) DUMMY,IL
      READ (1,302) DUMMY,HB
      WRITE(*,302) DUMMY,HB
      READ (1,302) DUMMY,EPSX
      WRITE(*,302) DUMMY,EPSX
      READ (1,302) DUMMY,EPSY
      WRITE(*,302) DUMMY,EPSY

      
  300 FORMAT(A65)
  301 FORMAT(A45,I15)
  302 FORMAT(A45,E15.7)
  303 FORMAT(A45,A15)

C------------------------------------
C     PHYSICAL LENGTH
      IF(INCODE.EQ.1) THEN
      PI=ACOS(-1.0)
      ALX=PI
      ALZ=0.289*PI
      ENDIF
C------------------------------------
      
      N1M=N1-1
      N2M=N2-1
      N3M=N3-1

      Call MESH
      Call INDICES 

      Return
      End

!***************** MESH ***********************     
      Subroutine MESH
      INCLUDE 'rough.h'

      PI=ACOS(-1.0)

!      CREATE THE UNIFORM GRID IN X2 DIRECTION      
!      ALY=2.0
!      Y(0)=0.0 
!      Do 10 J=1,N2 
!      Y(J)=ALY*DBLE(J-1)/DBLE(N2M) 
! 10   Continue 
      OPEN(2,FILE=filegrd,STATUS='OLD')
      READ(2,*) (Y(J),J=0,N2)
      CLOSE(2)

      VOL=ALX*ALY*ALZ 

      DX1=DBLE(N1M)/ALX
      DX3=DBLE(N3M)/ALZ

      DX1Q=DX1**2.0
      DX3Q=DX3**2.0

      DY(1)=Y(2)
      Do 20 J=2,N2M
      DY(J)=Y(J+1)-Y(J)
      H(J)=0.5*(DY(J)+DY(J-1))
 20   Continue
      H(1)=0.5*DY(1)
      H(N2)=DY(N2M)*0.5

      Return
      End


c***************** INDICES ***********************     
      Subroutine INDICES
      INCLUDE 'rough.h'

      Do 10 IC=1,N1M
      IPA(IC)=IC+1
      IMU(IC)=IC-1
10    IMV(IC)=IC-1
      IPA(N1M)=N1M
      IMU(2)=2
      IMV(1)=1
      
      Do 20 KC=1,N3M
      KPA(KC)=KC+1
 20   KMA(KC)=KC-1
      KPA(N3M)=1
      KMA(1)=N3M

      Do 30 JC=1,N2M
      JPA(JC)=JC+1
      JMU(JC)=JC-1
 30   JMV(JC)=JC-1
      JPA(N2M)=N2M
      JMU(1)=1
      JMV(2)=2
      
      Return
      End


c******************* WRITE IBM *********************************
      Subroutine WRITE_IBM
      INCLUDE 'rough.h'

      OPEN(2,FILE=fileibm,STATUS='unknown')
      OPEN(3,FILE='IBMpoint.plt',STATUS='unknown')
      
     
      write(3,103) N1M,N2M
      DO 10 J=1,N2M
      DO 10 I=1,N1M
      
      DO 20 L=1,3
      write(2,100) NF(L,I,J),IFU(L,I,J),JFU(L,I,J)
      write(2,101) AFI(L,I,J),AFJ(L,I,J),AFD(L,I,J),AFB(L,I,J)
      write(2,102) alpha(L,I,J),beta(L,I,J)
  20  CONTINUE 

      write(3,104) I,J,(NF(L,I,J),L=1,3)
      write(2,105) QIP(I,J),QJP(I,J),QKP(I,J)
      write(2,105) QI(I,J),QJ(I,J),QK(I,J)
  10  CONTINUE

      CLOSE(2)	    
      CLOSE(3)

  100 FORMAT(3I5)
  101 FORMAT(4E15.7)
  102 FORMAT(2E15.7)
  103 FORMAT('Zone i=',I4, 'j=',I4, 'f=point')    
  104 FORMAT(5I5)
  105 FORMAT(3E15.7)
      Return
      end


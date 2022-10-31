C********* MAKE_IBM *********************************88
C MAKE IBM DATA FOR ROUGH WALL
C ONLY FOR SQUARE ROD TYPE AND ROUGHNESS ON BOTTOM WALL
C ONLY FOR EPSX=0 EPSY=0 OR EPSX=0.5 EPSY=0.5
C EPSX=0, EPSY=0 : ROUGHNESS CORNER IS CELL CORNER
C EPSX=0.5, EPSY=0.5 : ROUGHNESS CORNER IS CELL CENTER 
C NF = 0 : NON FORCING REGION & OUTER REGION OF IBM (F=0)
C      1 : FORCING REGION FOR IBM (F!=0)    
C      2 : NON FORCING REGION & INNER REGION OF IBM (F=0)
C IFU, JFU : I,J OF THE NEAREST IMMERSED BOUNDARY POINT 
C            AMONG NEIGHBOR POINTS 
C            IF THERE ARE NO IMMRESED BOUNDARY POINT,
C            IFU=I, JFU=J 
C ALPHA, BETA : COEFFICIENT RELATED WITH DISTANCE 
C               TO THE NEARTEST IMMERSED BOUNDARY POINT
C               IF THERE ARE NO IMMERSED BOUNDARY POINT OR
C               CELL CENTER IS IMMERSE BOUNDARY POINT THEN
C               ALPHA, BETA = 0
C AFI, AFJ, AFD, AFB : COEFFICIENT FOR GET UF 

C UT = u~ , n+1 step velocity obtained by fully explicit method) 
C UF = velocity of forcing point to make immersed boundary condition
C      , obtained by interpolation with UT of neighbor points

C UF=AFI(L,I,J)*UT(IFU(L,I,J),J,K,L)
C   +AFJ(L,I,J)*UT(I,JFU(L,I,J),K,L)
C   +AFD(L,I,J)*UT(IFU(L,I,J),JFU(L,I,J),K,L)
C   +AFB(L,I,J)*0.  ! AT IMMERSED BOUNDARY NO-SLIP

C MASS SOURCE TERM IS NOT ADDED

C                            by S.H.LEE 2003
C                            modified 12/5/2004



      SUBROUTINE MAKE_IBM

      INCLUDE 'dctbl.h'

      DO 1 J=1,N2M    ! before roughness
      DO 1 I=1,IB-1
      DO 1 L=1,3
      NF(L,I,J)=0
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
   1  continue
      
      IF((EPSX.EQ.0.0).AND.(EPSY.EQ.0.0)) THEN
	
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
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=(EPSY*DY(JB)+0.5*DY(JB-1))/(0.5*DY(JB)+0.5*DY(JB-1))

      ! FOR LEFT WALL

      ELSE IF ((II.EQ.1).AND.(J.GE.1).AND.(J.LE.JB-2)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.

      ! FOR RIGHT WALL
      ELSE IF ((II.EQ.IW+1).AND.(J.GE.1).AND.(J.LE.JB-2)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
     
      ! FOR LEFT CORNER
      ELSE IF ((II.EQ.1).AND.(J.EQ.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.

      ! FOR RIGHT CORNER
      ELSE IF ((II.EQ.IW+1).AND.(J.EQ.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
      
      ! FOR INNER POINT
      ELSE IF ((II.GE.2).AND.(II.LE.IW).AND.
     >(J.GE.1).AND.(J.LE.JB-2)) THEN
      NF(L,I,J)=2
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
     
      ! FOR OUTER POINT
      ELSE
      NF(L,I,J)=0
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.

      ENDIF

!     FOR V
      
      L=2
      IM=IMV(I)
      ! FOR TOP WALL 

      IF ((II.GE.2).AND.(II.LE.IW-1).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=I
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.

      ! FOR LEFT WALL

      ELSE IF ((II.EQ.1).AND.(J.GE.2).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.5
      BETA(L,I,J)=0.

      ! FOR RIGHT WALL
      ELSE IF ((II.EQ.IW).AND.(J.GE.2).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.5
      BETA(L,I,J)=0.
     
      ! FOR LEFT CORNER
      ELSE IF ((II.EQ.1).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.

      ! FOR RIGHT CORNER
      ELSE IF ((II.EQ.IW).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
      
      ! FOR INNER POINT
      ELSE IF ((II.GE.2).AND.(II.LE.IW-1).AND.
     >(J.GE.2).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=2
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
     
      ! FOR OUTER POINT
      ELSE
      NF(L,I,J)=0
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.

      ENDIF

!     FOR W
      
      L=3
      IM=IMV(I)
      ! FOR TOP WALL 

      IF ((II.GE.2).AND.(II.LE.IW-1).AND.(J.EQ.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=I
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=(EPSY*DY(JB)+0.5*DY(JB-1))/(0.5*DY(JB)+0.5*DY(JB-1))

      ! FOR LEFT WALL

      ELSE IF ((II.EQ.1).AND.(J.GE.1).AND.(J.LE.JB-2)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.5
      BETA(L,I,J)=0.

      ! FOR RIGHT WALL
      ELSE IF ((II.EQ.IW).AND.(J.GE.1).AND.(J.LE.JB-2)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.5
      BETA(L,I,J)=0.
     
      ! FOR LEFT CORNER
      ELSE IF ((II.EQ.1).AND.(J.EQ.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.5
      BETA(L,I,J)=(EPSY*DY(JB)+0.5*DY(JB-1))/(0.5*DY(JB)+0.5*DY(JB-1))

      ! FOR RIGHT CORNER
      ELSE IF ((II.EQ.IW).AND.(J.EQ.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.5
      BETA(L,I,J)=(EPSY*DY(JB)+0.5*DY(JB-1))/(0.5*DY(JB)+0.5*DY(JB-1))
      
      ! FOR INNER POINT
      ELSE IF ((II.GE.2).AND.(II.LE.IW-1).AND.
     >(J.GE.1).AND.(J.LE.JB-2)) THEN
      NF(L,I,J)=2
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
     
      ! FOR OUTER POINT
      ELSE
      NF(L,I,J)=0
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.

      ENDIF

      
10    CONTINUE

      ELSE IF ((EPSX.EQ.0.5).AND.(EPSY.EQ.0.5)) THEN

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
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.

      ! FOR LEFT WALL

      ELSE IF ((II.EQ.2).AND.(J.GE.1).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.5
      BETA(L,I,J)=0.

      ! FOR RIGHT WALL
      ELSE IF ((II.EQ.IW+1).AND.(J.GE.1).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.5
      BETA(L,I,J)=0.
     
      ! FOR LEFT CORNER
      ELSE IF ((II.EQ.2).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.

      ! FOR RIGHT CORNER
      ELSE IF ((II.EQ.IW+1).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
      
      ! FOR INNER POINT
      ELSE IF ((II.GE.3).AND.(II.LE.IW).AND.
     >(J.GE.1).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=2
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
     
      ! FOR OUTER POINT
      ELSE
      NF(L,I,J)=0
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.

	
      ENDIF

!     FOR V
      
      L=2
      IM=IMV(I)
      ! FOR TOP WALL 

      IF ((II.GE.2).AND.(II.LE.IW).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=I
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.5

      ! FOR LEFT WALL

      ELSE IF ((II.EQ.1).AND.(J.GE.2).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.

      ! FOR RIGHT WALL
      ELSE IF ((II.EQ.IW+1).AND.(J.GE.2).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
     
      ! FOR LEFT CORNER
      ELSE IF ((II.EQ.1).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.

      ! FOR RIGHT CORNER
      ELSE IF ((II.EQ.IW+1).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
      
      ! FOR INNER POINT
      ELSE IF ((II.GE.2).AND.(II.LE.IW).AND.
     >(J.GE.2).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=2
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
     
      ! FOR OUTER POINT
      ELSE
      NF(L,I,J)=0
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
      
      ENDIF
      

!     FOR W
      
      L=3
      IM=IMV(I)
      ! FOR TOP WALL 

      IF ((II.GE.2).AND.(II.LE.IW).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=I
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.

      ! FOR LEFT WALL

      ELSE IF ((II.EQ.1).AND.(J.GE.1).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.

      ! FOR RIGHT WALL
      ELSE IF ((II.EQ.IW+1).AND.(J.GE.1).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
     
      ! FOR LEFT CORNER
      ELSE IF ((II.EQ.1).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IM
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.

      ! FOR RIGHT CORNER
      ELSE IF ((II.EQ.IW+1).AND.(J.EQ.JB)) THEN
      NF(L,I,J)=1
      IFU(L,I,J)=IP
      JFU(L,I,J)=JP
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
      
      ! FOR INNER POINT
      ELSE IF ((II.GE.2).AND.(II.LE.IW).AND.
     >(J.GE.1).AND.(J.LE.JB-1)) THEN
      NF(L,I,J)=2
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
     
      ! FOR OUTER POINT
      ELSE
      NF(L,I,J)=0
      IFU(L,I,J)=I
      JFU(L,I,J)=J
      ALPHA(L,I,J)=0.
      BETA(L,I,J)=0.
      
      ENDIF
     
20    CONTINUE

      ENDIF

      DO 30 J=1,N2M
      DO 30 I=1,N1M
      DO 30 L=1,3
      
      AFI(L,I,J)=-1.*ALPHA(L,I,J)/(1.-ALPHA(L,I,J))
      AFJ(L,I,J)=-1.*BETA(L,I,J)/(1.-BETA(L,I,J))
      AFD(L,I,J)=-1.*AFI(L,I,J)*AFJ(L,I,J)
c      IF ((IFU(L,I,J).NE.I).AND.(JFU(L,I,J).EQ.J)) THEN
      if((ifu(l,i,j).ne.i).and.(jfu(l,i,j).ne.j)) then !!revised J.H.LEE 2009.07.10
      AFB(L,I,J)=1./(1.-ALPHA(L,I,J))/(1.-BETA(L,I,J))
      ELSE IF ((IFU(L,I,J).EQ.I).AND.(JFU(L,I,J).NE.J)) THEN
      AFB(L,I,J)=1./(1.-BETA(L,I,J))
      ELSE IF ((IFU(L,I,J).NE.I).AND.(JFU(L,I,J).EQ.J)) THEN
      AFB(L,I,J)=1./(1.-ALPHA(L,I,J))
      ELSE
      AFB(L,I,J)=0.
      ENDIF

30    CONTINUE
      
      OPEN(3,FILE='OUTPUT/IBMpoint.plt',STATUS='unknown')
      open(4,FILE=fileibm,STATUS='unknown')
      write(3,103) N1M,N2M
      DO J=1,N2M
      DO I=1,N1M
      write(3,104) I,J,(NF(L,I,J),L=1,3)
      DO L=1,3 
      write(4,105) I,J,AFI(L,I,J),AFJ(L,I,J),AFD(L,I,J),AFB(L,I,J)
      ENDDO
      ENDDO
      ENDDO
      CLOSE(3)
      write(*,*) 'Writing done'

  103 FORMAT('Zone i=',I4, 'j=',I4, 'f=point')    
  104 FORMAT(5I5)^
  105 FORMAT(I4,x,I4,x,4(E15.7,X))
      RETURN
      END

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

      DO 1 J=1,N2M    
      DO 1 I=1,N1M
      DO 1 K=1,N3M
      DO 1 L=1,3
      
      NF(L,I,J,K)=0
      IFU(L,I,J,K)=I
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=K
      
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0 
      AFK(L,I,J,K)=0.0
      AFD(L,I,J,K)=0.0
      AFB(L,I,J,K)=0.0
      
   1  continue
      

!ZM = leftest Zgrid of Roughness(equal to KK of 3D)
!IE = Igrid END POINT
!KW = W
!ParaL= SPacing
!DO LOOP for different rods
C=====================================================
      IE=2014

      ParaL=12     ! paramter of L/theta
      write(*,*) ParaL
      NR = 96/ParaL
C=====================================================

      DO NUM=1,NR   !DO LOOP FOR RODS in Spanwise direction  
      ZM=(ParaL*16/2/3)+(NUM-1)*(ParaL*16/3)
      ZM= ZM-KW/2+1
      write(*,*) ZM
C=====================================================
C---------------------U LOOP--------------------------


      L=1

      do k=1,N3M

      KP=KPA(K)
      KM=KMA(K)

      DO J=1,N2M
      JP=J+1
      JM=J-1

      DO I=IB,N1M
      IP=IPA(I)
      IM=IMU(I)

C 1.FRONT FACE

      !.FACE  
      IF((I.EQ.IB+1).AND.(J.GE.1).AND.
     >(J.LE.JB-1).AND.(K.GE.ZM+1).AND.(K.LE.ZM+KW-1)) THEN

      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IM
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=K
      AFI(L,I,J,K)=-1.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0
      
c.2.BACKSIDE FACE


      ! FACE  
      ELSE IF((I.EQ.IE).AND.(J.GE.1).AND.
     >(J.LE.JB-1).AND.(K.GE.ZM+1).AND.(K.LE.ZM+KW-1)) THEN

      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IP
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=K
      AFI(L,I,J,K)=-1.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0
      

c.3.TOP WALL

      ELSE IF((I.GE.IB+3).AND.(I.LE.IE-1).AND.
     >(J.EQ.JB).AND.(K.GE.ZM+1).AND.(K.LE.ZM+KW-1)) THEN
               
      NF(L,I,J,K)=1
      IFU(L,I,J,K)=I
      JFU(L,I,J,K)=JP
      KFU(L,I,J,K)=K
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0
      

              
C. 4.LEFTWALL
      ELSE IF((K.EQ.ZM).AND.(I.GE.IB+1).AND.
     >(I.LE.IE).AND.(J.GE.1).AND.(J.LE.JB-1)) THEN 
      NF(L,I,J,K)=1
      IFU(L,I,J,K)=I
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0
      

c.5.RIGHTWALL

      ELSE IF((K.EQ.ZM+KW).AND.(I.GE.IB+1).AND.
     >(I.LE.IE).AND.(J.GE.1).AND.(J.LE.JB-1)) THEN
      NF(L,I,J,K)=1
      IFU(L,I,J,K)=I
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=KP
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0
      
c.6. CORNER

      !TOP&FRONT
      ELSE IF((I.EQ.IB+1).AND.(J.EQ.JB).AND.
     >(K.GE.ZM+1).AND.(K.LE.ZM+KW-1))THEN

      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IM
      JFU(L,I,J,K)=JP
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0
      

      !TOP&BACKSIDE
      ELSE IF((I.EQ.IE).AND.(J.EQ.JB).AND.
     >(K.GE.ZM+1).AND.(K.LE.ZM+KW-1))THEN

      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IM
      JFU(L,I,J,K)=JP
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0

      !LEFTWALL&UPPER
      ELSE IF((I.GE.IB+1).AND.(I.LE.IE).AND.
     >(K.EQ.ZM).AND.(J.EQ.JB))THEN
      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IM
      JFU(L,I,J,K)=JP
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0


      !RIGHTWALL&UPPER
      ELSE IF((I.GE.IB+1).AND.(I.LE.IE).AND.
     >(K.EQ.ZM+KW).AND.(J.EQ.JB))THEN
      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IM
      JFU(L,I,J,K)=JP
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0
      
      !INNER POINT
      ELSE IF((I.GE.IB+2).AND.(I.LE.IE-1).AND.
     >(J.GE.1).AND.(J.LE.JB-1).AND.(K.GE.ZM+1).AND.(K.LE.ZM+KW-1))THEN
      NF(L,I,J,K)=2
      IFU(L,I,J,K)=I
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=K
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0

      

      ENDIF

      ENDDO
      ENDDO
      ENDDO


C--------V LOOP------------------

      L=2

      DO k=1,n3m
      
      KP=KPA(K)
      KM=KMA(K)

      DO J=1,N2M
      JP=J+1
      JM=J-1

      DO I=IB,N1M
      IP=IPA(I)
      IM=IMV(I)

C 1.FRONT FACE

      !.FACE
      IF((I.EQ.IB).AND.(J.GE.2).AND.
     >(J.LE.JB-1).AND.
     >(K.GE.ZM+1).AND.(K.LE.ZM+KW-1)) THEN

      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IM
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=K
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0

c.2.BACKSIDE FACE


      ! FACE
      ELSE IF((I.EQ.IE).AND.(J.GE.2).AND.
     >(J.LE.JB-1).AND.
     >(K.GE.ZM+1).AND.(K.LE.ZM+KW-1)) THEN

      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IP
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=K
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0


c.3.TOP WALL

      ELSE IF((I.GE.IB+1).AND.(I.LE.IE-1).AND.
     >(J.EQ.JB).AND.(K.GE.ZM+1).AND.(K.LE.ZM+KW-1)) THEN

      NF(L,I,J,K)=1
      IFU(L,I,J,K)=I
      JFU(L,I,J,K)=JP
      KFU(L,I,J,K)=K
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=-1.0
      AFK(L,I,J,K)=0.0



C. 4.LEFTWALL
      ELSE IF((K.EQ.ZM).AND.(I.GE.IB).AND.
     >(I.LE.IE).AND.(J.GE.2).AND.(J.LE.JB-1)) THEN
      NF(L,I,J,K)=1
      IFU(L,I,J,K)=I
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0


c.5.RIGHTWALL


      ELSE IF((K.EQ.ZM+KW).AND.(I.GE.IB).AND.
     >(I.LE.IE).AND.(J.GE.2).AND.(J.LE.JB-1)) THEN
      NF(L,I,J,K)=1
      IFU(L,I,J,K)=I
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0

c.6. CORNER

      !TOP&FRONT
      ELSE IF((I.EQ.IB).AND.(J.EQ.JB).AND.
     >(K.GE.ZM+1).AND.(K.LE.ZM+KW-1))THEN

      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IM
      JFU(L,I,J,K)=JP
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0


      !TOP&BACKSIDE
      ELSE IF((I.EQ.IE).AND.(J.EQ.JB).AND.
     >(K.GE.ZM+1).AND.(K.LE.ZM+KW-1))THEN

      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IM
      JFU(L,I,J,K)=JP
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0

      !LEFTWALL&UPPER
      ELSE IF((I.GE.IB).AND.(I.LE.IE).AND.
     >(K.EQ.ZM).AND.(J.EQ.JB))THEN
      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IM
      JFU(L,I,J,K)=JP
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0


      !RIGHTWALL&UPPER
      ELSE IF((I.GE.IB).AND.(I.LE.IE).AND.
     >(K.EQ.ZM+KW).AND.(J.EQ.JB))THEN
      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IM
      JFU(L,I,J,K)=JP
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0

      !INNER POINT 
      ELSE IF((I.GE.IB+1).AND.(I.LE.IE-1).AND.
     >(J.GE.2).AND.(J.LE.JB-1).AND.(K.GE.ZM+1).AND.(K.LE.ZM+KW-1))THEN
      NF(L,I,J,K)=2
      IFU(L,I,J,K)=I
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=K
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0





      ENDIF

      ENDDO
      ENDDO
      ENDDO

C--------W LOOP------------------

      L=3


      DO k=1,n3m

      KP=KPA(K)
      KM=KMA(K)

      DO J=1,N2M
      JP=J+1
      JM=J-1

      DO I=IB,N1M
      IP=IPA(I)
      IM=IMV(I)    
      
C 1.FRONT FACE

      !.FACE
      IF((I.EQ.IB).AND.(J.GE.1).AND.
     >(J.LE.JB-1).AND.
     >(K.GE.ZM+1).AND.(K.LE.ZM+KW)) THEN

      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IM
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=K
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0

c.2.BACKSIDE FACE


      ! FACE
      ELSE IF((I.EQ.IE).AND.(J.GE.1).AND.
     >(J.LE.JB-1).AND.
     >(K.GE.ZM+1).AND.(K.LE.ZM+KW)) THEN

      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IP
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=K
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0


c.3.TOP WALL

      ELSE IF((I.GE.IB+1).AND.(I.LE.IE-1).AND.
     >(J.EQ.JB).AND.(K.GE.ZM+2).AND.(K.LE.ZM+KW-1)) THEN

      NF(L,I,J,K)=1
      IFU(L,I,J,K)=I
      JFU(L,I,J,K)=JP
      KFU(L,I,J,K)=K
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0



C. 4.LEFTWALL
      ELSE IF((K.EQ.ZM+1).AND.(I.GE.IB+1).AND.
     >(I.LE.IE-1).AND.(J.GE.1).AND.(J.LE.JB-1)) THEN
      NF(L,I,J,K)=1
      IFU(L,I,J,K)=I
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=-1.0


c.5.RIGHTWALL


      ELSE IF((K.EQ.ZM+KW).AND.(I.GE.IB+1).AND.
     >(I.LE.IE-1).AND.(J.GE.1).AND.(J.LE.JB-1)) THEN
      NF(L,I,J,K)=1
      IFU(L,I,J,K)=I
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=KP
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=-1.0

c.6. CORNER

      !TOP&FRONT
      ELSE IF((I.EQ.IB).AND.(J.EQ.JB).AND.
     >(K.GE.ZM+1).AND.(K.LE.ZM+KW))THEN

      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IM
      JFU(L,I,J,K)=JP
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0


      !TOP&BACKSIDE
      ELSE IF((I.EQ.IE).AND.(J.EQ.JB).AND.
     >(K.GE.ZM+1).AND.(K.LE.ZM+KW))THEN

      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IM
      JFU(L,I,J,K)=JP
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0

      !LEFTWALL&UPPER
      ELSE IF((I.GE.IB+1).AND.(I.LE.IE-1).AND.
     >(K.EQ.ZM+1).AND.(J.EQ.JB))THEN
      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IM
      JFU(L,I,J,K)=JP
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0


      !RIGHTWALL&UPPER
      ELSE IF((I.GE.IB+1).AND.(I.LE.IE-1).AND.
     >(K.EQ.ZM+KW).AND.(J.EQ.JB))THEN
      NF(L,I,J,K)=1
      IFU(L,I,J,K)=IM
      JFU(L,I,J,K)=JP
      KFU(L,I,J,K)=KM
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0

      !INNER POINT 
      ELSE IF((I.GE.IB+1).AND.(I.LE.IE-1).AND.
     >(J.GE.1).AND.(J.LE.JB-1).AND.(K.GE.ZM+2).AND.(K.LE.ZM+KW-1))THEN
      NF(L,I,J,K)=2
      IFU(L,I,J,K)=I
      JFU(L,I,J,K)=J
      KFU(L,I,J,K)=K
      AFI(L,I,J,K)=0.0
      AFJ(L,I,J,K)=0.0
      AFK(L,I,J,K)=0.0

      ENDIF

      ENDDO
      ENDDO
      ENDDO


      ENDDO      !DO LOOP FOR RODS in Spanwise direction  

C=====================================================================
      write(*,*) 'Writing done'

  103 FORMAT('Zone i=',I4, 'j=',I4, 'f=point')    
  104 FORMAT(5I5)
  105 FORMAT(I4,x,I4,x,4(E15.7,X))
      RETURN
      END

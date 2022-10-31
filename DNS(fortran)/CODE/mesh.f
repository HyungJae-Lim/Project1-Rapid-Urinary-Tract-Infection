
c***************** MESH ***********************     
      SUBROUTINE MESH
      
      INCLUDE 'dctbl.h'
      
      CHARACTER*100 DUMMY2
      PI=ACOS(-1.0)
   
      OPEN(10,FILE=filegrd,STATUS='OLD')
      DO L=1,10  ! READING DESCRIPTION OF GRID FILE
      READ(10,100) DUMMY2
      ENDDO

      READ(10,*) (Y(J),J=0,N2)
      CLOSE(10)
100   FORMAT(A100)      
      
c     CREATE THE TANGENT HYPERBOLIC GRID IN X2 DIRECTION      
c      CS=0.05  
c      A=tanh(CS*Real(N2M))
c      Y(0)=0.0 
c      DO 10 J=1,N2 
c      Y(J)=ALY*(A-tanh(CS*Real(N2-j)))/A
c 10   CONTINUE 
       
      VOL=ALX*ALY*ALZ 

      DX1=DBLE(N1M)/ALX
      DX3=DBLE(N3M)/ALZ

      DX1Q=DX1**2.0
      DX3Q=DX3**2.0

      DY(1)=Y(2)
      DO 20 J=2,N2M
      DY(J)=Y(J+1)-Y(J)
      H(J)=0.5*(DY(J)+DY(J-1))
 20   CONTINUE
      H(1)=0.5*DY(1)
      H(N2)=DY(N2M)*0.5
      DO 30 J=1,N2M
      HP(J)=2.0/H(J+1)/(H(J)+H(J+1))
      HC(J)=2.0/H(J+1)/H(J)
      HM(J)=2.0/H(J)/(H(J)+H(J+1))
 30   CONTINUE

      DO 40 J=2,N2M
      DYP(J)=2.0/DY(J)/(DY(J-1)+DY(J))
      DYC(J)=2.0/DY(J)/DY(J-1)
      DYM(J)=2.0/DY(J-1)/(DY(J-1)+DY(J))
 40   CONTINUE


      RETURN
      END


C  ************************  WRITE_WALL **********************
C     WRITE WALL SHEAR AND PRESSURE

      SUBROUTINE WRITE_WALL(U,P)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
      REAL P(M1,M2,M3)

!mesh check
c      IF(NTIME.EQ.NSTART+1) THEN
c
c      !2D CONTOUR XY
c
c      write(*,*) dx1
c
c      open(59,file='OUTPUT/mesh_XYplane.plt',status='unknown')
c
c      write(59,*) 'variables=x,y,U'
c      write(59,*) 'zone I=',N1M,',J=',N2M,',f=point'
c
c      do J=1,N2M
c      do i=1,N1M
c      XX = real(i-1)/DX1
c      YY = Y(j)
c
c      write(59,105) XX,YY,U(I,J,120,1)
c
c      enddo
c      enddo
c
c      write(*,*) "mesh check done"      
c
c      close(59)
c      ENDIF

!V CHeck

      !2D CONTOUR YZ
      IF(NTIME.EQ.NSTART+1) THEN
      open(11,file='OUTPUT/mesh_ZYplane.plt',status='unknown')
      write(11,*) 'variables=x,y,u'
      write(11,*)'zone J=',n2m,',K=',n3m,',f=point'

      do K=1,n3m
      do J=1,n2m

        ycc = 0.5*(y(j)+y(j+1))
        zcc = real(k-1)/DX3

      write(11,105) ycc,zcc,U(500,J,K,1)

      enddo
      enddo
      close(11)
      ENDIF


105   format(3(e12.5,2x))

      RETURN
      END

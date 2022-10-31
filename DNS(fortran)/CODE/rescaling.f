
c*************** Rescaling ****************************
C      Subroutine Rescaling(U,TIME)
      Subroutine Rescaling(U)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)

c      Real um_rc(3,0:M2)
c      Real uf_rc(3,0:M2,0:M3)
c      Real um_in(3,2,0:M2)
c      Real uf_in(3,2,0:M2,0:M3)
c      save delta_in,um_in,um_rc,uf_rc,uf_in
c      data delta_in/0./
c      data ((um_rc(i,j),j=0,M2),i=1,3) /M2P13*0./

c     The i index of the recycle station

      IRC=N1M*4/5     ! Rescaling Point
C      IRC=N1M*3/5     ! Rescaling Point

      theta_in=R_theta_in/RE
     
c      Call Get_um_rc(U,um_rc,uf_rc,TIME)
C      Call Get_um_rc(U,TIME)
      Call Get_um_rc(U)

      ut_rc=(um_rc(1,1)/H(1)/RE)**0.5
      
c     Find the boundary layer thickness at the recycle station
c     by using linear interpolation of mean velocity profile

      U_inf=0.99*um_rc(1,N2)
      Do 10 j=2,N2M
      If (um_rc(1,j).ge.U_inf) then
      d1=(Y(j-1)+Y(j))*0.5
      d2=(Y(j)+Y(j+1))*0.5
      u1=um_rc(1,j-1)
      u2=um_rc(1,j)
      delta_rc=(d2-d1)/(u2-u1)*(U_inf-u1)+d1
      Goto 20
      Endif 
10    Continue
20    Continue

c     Calculate the momentum thickness at the recycle station
c     by integrating the mean velocity profile up to delta_rc

      theta_rc=0.0
      Do 30 j=1,n2m    
30    theta_rc=theta_rc+um_rc(1,j)*(1.0-um_rc(1,j))*DY(j)

      ut_in=ut_rc*(theta_rc/theta_in)**(1./2./(5.-1.))

c     For Re=300, ut must be about 0.05    
C      If (ut_in.LE.0.045) Then
C      ut_in=0.045
C      OPEN(24,FILE='OUTPUT/ALERT.TXT',STATUS='UNKNOWN',
C     >POSITION='APPEND')
C      Write(24,300) NTIME
C      CLOSE(24)
C300   Format('Ut_in is adjusted up to 0.045 at ',I8)
C      Endif

      gamma=ut_in/ut_rc
 
c      Call Get_delta_in(um_rc,um_in,delta_in) 
c      Call Get_uf_in(um_rc,uf_rc,uf_in,delta_in)
c      Call Get_inflow(um_rc,um_in,uf_in,delta_in)
      Call Get_delta_in 
      Call Get_uf_in
      Call Get_inflow

      th_in=0.0
      Do 50 j=1,n2m
      U_z=0.0
      Do 51 k=1,N3M
51    U_z=U_z+UBC3(1,j,k)/Real(N3M)
50    th_in=th_in+U_z*(1.0-U_z)*DY(j)

      Write(*,100) ut_in,th_in*RE,delta_in,U(1,N2,N3M,1)
100   Format('At inlet   : U_t=',e12.6,x,'Re_th=',e12.6,x,'d99=',e12.6
     >       ,x,'U_inf=',e12.6)
      Write(*,101) ut_rc,theta_rc*RE,delta_rc,U(IRC,N2,N3M,1)
101   Format('At recycle : U_t=',e12.6,x,'Re_th=',e12.6,x,'d99=',e12.6
     >       ,x,'U_inf=',e12.6)

      OPEN(21,FILE='OUTPUT/Cf.plt',STATUS='UNKNOWN',
     >POSITION='APPEND')
      Write(21,200) time,2.*ut_in**2,delta_in
      CLOSE(21)
200   Format(3(E12.5,X))      

      Return
      End

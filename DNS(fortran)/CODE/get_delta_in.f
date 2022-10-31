
c*************** Get_delta_in ********************************* 
c      Subroutine Get_delta_in(um_rc,um_in,delta_in) 
      Subroutine Get_delta_in 
      INCLUDE 'dctbl.h'

c      Real um_rc(3,0:M2)
c      Real um_in(3,2,0:M2)

c     This is the Newton's method.
      itermax=100
      if (NTIME.EQ.NSTART) delta_in=10. ! at the first step initial guess
      d1=delta_in ! next step using previous result
!      d1=10.

      iter=0 
!      Write(*,*) 'Get the delta at the inlet station.' 
!      Write(*,*) 'Iter    delta_in     Re_theta' 
!      Write(*,*) '----------------------------------' 
      
1     Continue
      iter=iter+1 
      If (iter.ge.itermax) then
      Write(24,244) NTIME
244   Format('Cannot find delta_in for Re_theta=300 at'
     > ,I6,'th step') 
      Goto 2
      Endif  

c      Call Get_um_in(um_rc,um_in,d1)
      Call Get_um_in(d1)
      theta=0.0
      theta=0.0
      Do 12 j=1,n2m 
12    theta=theta+um_in(1,1,j)*(1.0-um_in(1,1,j))*DY(j)
c     do j=1,n2m
c        j=1
c        write(6,*) j,um_in(1,1,j),DY(j)
c     enddo

      f_d1=theta-theta_in

      If (abs(f_d1).ge.1e-5) then        !1

!      Write(*,100) iter,d1,(f_d1+theta_in)*RE
100   Format(I4,2x,2(e12.5,2x)) 

c     To calculate the derivative at d1
c     through central differencing
      del_d=1e-10 
      d_p=d1+del_d
      d_m=d1-del_d

c      Call Get_um_in(um_rc,um_in,d_p)
      Call Get_um_in(d_p)
      theta=0.0
      Do 15 j=1,n2m      
15    theta=theta+um_in(1,1,j)*(1.0-um_in(1,1,j))*DY(j)
      f_d_p=theta-theta_in

c      Call Get_um_in(um_rc,um_in,d_m)
      Call Get_um_in(d_m)
      theta=0.0
      Do 18 j=1,n2m     
18    theta=theta+um_in(1,1,j)*(1.0-um_in(1,1,j))*DY(j)
      f_d_m=theta-theta_in

      d_f_d1=(f_d_p-f_d_m)/(d_p-d_m) ! get derivative at d1 


      If (abs(d_f_d1).le.1e-10) then
       d_f_d1=1e-10
       Write(24,245) NTIME
245    Format('In Newton`s method, denominator is zero at',E13.5)
      Endif

      If (iter.ge.itermax/10) then      ! for faster convergence  
        If (f_d1*temp_f.lt.0.0) then 

        d_aid=(d1-temp_d)/(f_d1-temp_f)*(0.0-f_d1)+d1  ! Secant method

        temp_f=f_d1
        temp_d=d1
        d1=d_aid
        Goto 255
        Endif
      Endif

      temp_f=f_d1
      temp_d=d1

      d1=d1-f_d1/d_f_d1   ! Newton's iteration

255   Continue
      Goto 1
      Endif    !1

2     Continue     

      Write(*,100) iter,d1,(f_d1+theta_in)*RE
      delta_in=d1
      Write(*,*)

      Return
      End  

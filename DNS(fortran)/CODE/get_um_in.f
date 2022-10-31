
c*************** Get_um_in *******************************
c      Subroutine Get_um_in(um_rc,um_in,delta_in)
      Subroutine Get_um_in(d_in)
      INCLUDE 'dctbl.h'

c      Real um_rc(3,0:M2)
c      Real um_in(3,2,0:M2)
c          um_in(NV,ND,J )
c                NV : variables
c                ND : nondimensionalized length scale
c                Return mean profile as um_in(NV,1,J)
c                through this subroutine
     
      gamma=ut_in/ut_rc

c     Calculate the mean velocity profile ; U1

      NV=1

c     jj=1    for consistency of u_t and um_in 
      um_in(1,1,1)=ut_in**2*h(1)*RE    ! Readme
c      Do 1 jj=1,N2M    
      Do 1 jj=2,N2M    
c     length scale : inner variables
      yp_in=RE*ut_in*0.5*(y(jj)+y(jj+1))
      yp_rc_max=RE*ut_rc*0.5*(y(N2M)+y(N2))
c     write(6,*) 'b===>',jj,j_rc 

      If (yp_in.ge.yp_rc_max) then 
      um_in(NV,1,jj)=1.0     
      Goto 111
      Endif

      Do 10 j=1,N2M    
      yp_rc=RE*ut_rc*0.5*(y(j)+y(j+1))
      If (yp_rc.gt.yp_in) then 
      y2=yp_rc
      y1=RE*ut_rc*0.5*(y(j)+y(j-1))
      j_rc=j
      Goto 11
      Endif
10    Continue
11    Continue
c     write(6,*) 'a===>',iter,j_rc ,u1,u2,y1,y2
      u1=um_rc(NV,j_rc-1)
      u2=um_rc(NV,j_rc)
      um_in(NV,1,jj)=((u2-u1)/(y2-y1)*(yp_in-y2)+u2)
     >              *gamma
111   Continue

c     length scale : outer variables
      etha_in=0.5*(y(jj)+y(jj+1))/d_in
      etha_rc_max=0.5*(y(N2M)+y(N2))/delta_rc

      If (etha_in.gt.etha_rc_max) then 
      um_in(NV,2,jj)=1.0       
      Goto 222
      Endif

      Do 20 j=1,N2M    
      etha_rc=0.5*(y(j)+y(j+1))/delta_rc
      If (etha_rc.gt.etha_in) then 
      y2=etha_rc
      y1=0.5*(y(j)+y(j-1))/delta_rc
      j_rc=j
      Goto 21
      Endif
20    Continue
21    Continue

      u1=um_rc(NV,j_rc-1)
      u2=um_rc(NV,j_rc)
      um_in(NV,2,jj)=((u2-u1)/(y2-y1)*(etha_in-y2)+u2)
     >              *gamma+(1.0-gamma)
222   Continue   

c     weighted average with function, W
      W=Weight(etha_in)
      um_in(NV,1,jj)=um_in(NV,1,jj)*(1.-W)+um_in(NV,2,jj)*W
      
1     Continue

c     Calculate the mean velocity profile ; U2

      NV=2
      Do 2 jj=2,N2M   

c     length scale : inner variables

      yp_in=RE*ut_in*y(jj)
      yp_rc_max=RE*ut_rc*y(N2)

      If (yp_in.ge.yp_rc_max) then 
      um_in(NV,1,jj)=um_in(NV,1,jj-1)
      Goto 333
      Endif

      Do 30 j=1,N2    
      yp_rc=RE*ut_rc*y(j)
      If (yp_rc.ge.yp_in) then 
      y2=yp_rc
      y1=RE*ut_rc*y(j-1)
      j_rc=j
      Goto 31
      Endif
30    Continue
31    Continue
      u1=um_rc(NV,j_rc-1)
      u2=um_rc(NV,j_rc)
      um_in(NV,1,jj)=(u2-u1)/(y2-y1)*(yp_in-y2)+u2
333   Continue

c     length scale : outer variables

      etha_in=y(jj)/d_in
      etha_rc_max=y(N2)/delta_rc
      If (etha_in.ge.etha_rc_max) then 
      um_in(NV,2,jj)=um_in(NV,2,jj-1)
      Goto 444
      Endif

      Do 40 j=1,N2    
      etha_rc=y(j)/delta_rc
      If (etha_rc.ge.etha_in) then 
      y2=etha_rc
      y1=y(j-1)/delta_rc
      j_rc=j
      Goto 41
      Endif
40    Continue
41    Continue
      u1=um_rc(NV,j_rc-1)
      u2=um_rc(NV,j_rc)
      um_in(NV,2,jj)=(u2-u1)/(y2-y1)*(etha_in-y2)+u2
444   Continue   

c     weighted average with function, W
      W=Weight(etha_in)
      um_in(NV,1,jj)=um_in(NV,1,jj)*(1.-W)+um_in(NV,2,jj)*W

2     Continue

      NV=3
      DO 3 jj=1,N2M
      um_in(NV,1,jj)=0.
      um_in(NV,2,jj)=0. 
3     CONTINUE
      Return
      End

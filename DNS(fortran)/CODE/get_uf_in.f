
c*************** Get_uf_in ******************************
c      Subroutine Get_uf_in(um_rc,uf_rc,uf_in,delta_in)
      Subroutine Get_uf_in
      INCLUDE 'dctbl.h'

c      Real um_rc(3,0:M2)
c      Real uf_rc(3,0:M2,0:M3)
c      Real uf_in(3,2,0:M2,0:M3)
c          uf_in(NV,ND,J ,K )
c                NV : variables
c                ND : nondimensionalized length scale
c                Return mean profile as uf_in(NV,1,J,K)
c                through this subroutine
    
      gamma=ut_in/ut_rc

c     Calculate the fluctuating components ; U1

      NV=1
      Do 1 k=1,N3M
      Do 1 jj=1,N2M    

c     length scale : inner variables

      yp_in=RE*ut_in*0.5*(y(jj)+y(jj+1))
      yp_rc_max=RE*ut_rc*0.5*(y(N2M)+y(N2))

      If (yp_in.ge.yp_rc_max) then 
      uf_in(NV,1,jj,k)=0.0       
      Goto 111
      Endif

      Do 10 j=1,N2M    
      yp_rc=RE*ut_rc*0.5*(y(j)+y(j+1))
      If (yp_rc.ge.yp_in) then 
      y2=yp_rc
      y1=RE*ut_rc*0.5*(y(j)+y(j-1))
      j_rc=j
      Goto 11
      Endif
10    Continue
11    Continue
      u1=uf_rc(NV,j_rc-1,k)
      u2=uf_rc(NV,j_rc,k)
      uf_in(NV,1,jj,k)=((u2-u1)/(y2-y1)*(yp_in-y2)+u2)
     >                *gamma
111   Continue

c     length scale : outer variables

      etha_in=0.5*(y(jj)+y(jj+1))/delta_in
      etha_rc_max=0.5*(y(N2M)+y(N2))/delta_rc

      If (etha_in.ge.etha_rc_max) then 
      uf_in(NV,2,jj,k)=0.0      
      Goto 222
      Endif

      Do 20 j=1,N2M    
      etha_rc=0.5*(y(j)+y(j+1))/delta_rc
      If (etha_rc.ge.etha_in) then 
      y2=etha_rc
      y1=0.5*(y(j)+y(j-1))/delta_rc
      j_rc=j
      Goto 21
      Endif
20    Continue
21    Continue
      u1=uf_rc(NV,j_rc-1,k)
      u2=uf_rc(NV,j_rc,k)
      uf_in(NV,2,jj,k)=((u2-u1)/(y2-y1)*(etha_in-y2)+u2)
     >                *gamma
222   Continue   

c     weighted average with function, W
      W=Weight(etha_in)
      uf_in(NV,1,jj,k)=uf_in(NV,1,jj,k)*(1.-W)+uf_in(NV,2,jj,k)*W
            
1     Continue
 

c     Calculate the mean velocity profile ; U2
      NV=2

      Do 2 k=1,N3M
      Do 2 jj=2,N2M   

c     length scale : inner variables

      yp_in=RE*ut_in*y(jj)
      yp_rc_max=RE*ut_rc*y(N2)

      If (yp_in.ge.yp_rc_max) then 
      uf_in(NV,1,jj,k)=0.0        
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
      u1=uf_rc(NV,j_rc-1,k)
      u2=uf_rc(NV,j_rc,k)
      uf_in(NV,1,jj,k)=((u2-u1)/(y2-y1)*(yp_in-y2)+u2)
     >                *gamma
333   Continue

c     length scale : outer variables

      etha_in=y(jj)/delta_in
      etha_rc_max=y(N2)/delta_rc
      If (etha_in.ge.etha_rc_max) then 
      uf_in(NV,2,jj,k)=0.0     
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
      u1=uf_rc(NV,j_rc-1,k)
      u2=uf_rc(NV,j_rc,k)
      uf_in(NV,2,jj,k)=((u2-u1)/(y2-y1)*(etha_in-y2)+u2)
     >                *gamma
444   Continue   

c     weighted average with function, W
      W=Weight(etha_in)
      uf_in(NV,1,jj,k)=uf_in(NV,1,jj,k)*(1.-W)+uf_in(NV,2,jj,k)*W
      
2     Continue


c     Calculate the fluctuating components ; U3

      NV=3
      Do 3 k=1,N3M
      Do 3 jj=1,N2M    

c     length scale : inner variables

      yp_in=RE*ut_in*0.5*(y(jj)+y(jj+1))
      yp_rc_max=RE*ut_rc*0.5*(y(N2M)+y(N2))

      If (yp_in.ge.yp_rc_max) then 
      uf_in(NV,1,jj,k)=0.0       
      Goto 555
      Endif

      Do 50 j=1,N2M    
      yp_rc=RE*ut_rc*0.5*(y(j)+y(j+1))
      If (yp_rc.ge.yp_in) then 
      y2=yp_rc
      y1=RE*ut_rc*0.5*(y(j)+y(j-1))
      j_rc=j
      Goto 51
      Endif
50    Continue
51    Continue
      u1=uf_rc(NV,j_rc-1,k)
      u2=uf_rc(NV,j_rc,k)
      uf_in(NV,1,jj,k)=((u2-u1)/(y2-y1)*(yp_in-y2)+u2)
     >                *gamma
555   Continue

c     length scale : outer variables

      etha_in=0.5*(y(jj)+y(jj+1))/delta_in
      etha_rc_max=0.5*(y(N2M)+y(N2))/delta_rc

      If (etha_in.ge.etha_rc_max) then 
      uf_in(NV,2,jj,k)=0.0         
      Goto 666
      Endif

      Do 60 j=1,N2M    
      etha_rc=0.5*(y(j)+y(j+1))/delta_rc
      If (etha_rc.ge.etha_in) then 
      y2=etha_rc
      y1=0.5*(y(j)+y(j-1))/delta_rc
      j_rc=j
      Goto 61
      Endif
60    Continue
61    Continue
      u1=uf_rc(NV,j_rc-1,k)
      u2=uf_rc(NV,j_rc,k)
      uf_in(NV,2,jj,k)=((u2-u1)/(y2-y1)*(etha_in-y2)+u2)
     >                *gamma
666   Continue   

c     weighted average with function, W
      W=Weight(etha_in)
      uf_in(NV,1,jj,k)=uf_in(NV,1,jj,k)*(1.-W)+uf_in(NV,2,jj,k)*W
      
3     Continue

      Return
      End

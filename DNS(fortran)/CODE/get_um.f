c*************** get_um ********************************
      Subroutine GET_UM(um,ramda,IC)


      INCLUDE 'dctbl.h'

      real um(3,0:M1,0:M2)
      CK=0.40
      BB2=5.5
      pi=acos(-1.0)
      alpha2=4.0
      beta2=0.2

      u_t=1.0/ramda

      temp=0.
!      ITRY=0

C!$omp  parallel do private(yp,u1,u2,y1,y2,temp,um_inner,
C!$omp& delta,etha,um_outer,W)
      do 10 j=1,N2M

c     inner profile
      yp=RE/ramda*(y(j)+y(j+1))*0.5
!      u1=0.
      u1=temp
      u2=ramda
100   continue
!      ITRY=ITRY+1
!      y1=Spalding(u1)
!      y2=Spalding(u2)
      y1=u1
     >        +exp(-CK*BB2)*
     >         (exp(CK*u1)
     >         - 1.0
     >         - CK*u1
     >         -(CK*u1)**2/2.0
     >         -(CK*u1)**3/6.0)
      y2=u2
     >        +exp(-CK*BB2)*
     >         (exp(CK*u2)
     >         - 1.0
     >         - CK*u2
     >         -(CK*u2)**2/2.0
     >         -(CK*u2)**3/6.0)

      err=abs(y1-y2)

      if (err.ge.1e-8) then
      temp=(u2-u1)/(y2-y1)*(yp-y1)+u1
      u1=u2
      u2=temp
      goto 100

      endif
      um_inner=temp/ramda

c     outer profile
      delta=ramda*exp(c_kapa*(ramda-BB)-2.*PII)/RE
      etha=(y(j)+y(j+1))*0.5/delta
      yp=RE/ramda*(y(j)+y(j+1))*0.5
      um_outer=(1.0/c_kapa*log(yp)+BB+2.*PII/c_kapa*
     >(sin(pi/2.*etha))**2)/ramda
      if (etha.ge.1.) um_outer=1.0

c     Weighted average the inner and outer profiles
      W=0.5*(1.+tanh(alpha2*(etha-beta2)/((1.-2*beta2)*etha+beta2))
     >       /tanh(alpha2))

      if (etha.ge.1.) W=1.0

      um(1,IC,j)=um_inner*(1.-W)+um_outer*W

10    continue

!      WRITE(*,*) 'ITRY=',ITRY

      return
      end


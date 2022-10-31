c****************** Re_theta(ramda) ***********************
      real function Re_theta(ramda)

      include 'dctbl.h'

      Re_d=ramda*exp(c_kapa*(ramda-BB)-2.*PII)
      Re_theta=((1+PII)/c_kapa/ramda-1./c_kapa**2/ramda**2*
     >        (2.+2.*PII*1.58951+
     >             1.5*PII**2))*Re_d

      end

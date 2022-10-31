

c****************** Weight ***********************************
      Real function Weight(etha)
      
      alpha2=4.0
      b=0.2
      Weight=0.5*(1.0+tanh(alpha2*(etha-b)/((1.-2.*b)*etha+b))
     >           /tanh(alpha2))
      If (etha.ge.1.) Weight=1.0 
      
      Return
      End

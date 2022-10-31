
c****************** Spalding(uplus) ***********************
      real function Spalding(uplus)

      include 'dctbl.h'

      CK=0.40
      BB2=5.5
      Spalding=uplus
     >        +exp(-CK*BB2)*
     >         (exp(CK*uplus)
     >         - 1.0
     >         - CK*uplus
     >         -(CK*uplus)**2/2.0
     >         -(CK*uplus)**3/6.0)


      end

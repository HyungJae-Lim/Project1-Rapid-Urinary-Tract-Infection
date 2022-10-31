
c*************** Get_um_rc ***********************************
c      Subroutine Get_um_rc(U,um_rc,uf_rc,TIME)
C      Subroutine Get_um_rc(U,TIME)
      Subroutine Get_um_rc(U)
      INCLUDE 'dctbl.h'

      REAL U(0:M1,0:M2,0:M3,3)
c      Real um_rc(3,0:M2)
c      Real uf_rc(3,0:M2,0:M3)
      Real temp1(M2),temp2(M2)
      Real temp3(M1,M2)
      REAL UMEANTEMP(3,0:M1,0:M2)

      CHARACTER*80 FILEW
C     For continuous calculation, obtain um_rc and umean from saved files 

      If (NREAD.NE.2.AND.IGEN.eq.1.and.NTIME.eq.NSTART) then

      write(*,*) 'Reading rescaling data from',FRESIN
      IF (IFORRES.EQ.0) THEN    ! RESCALE DATA FORMAT : UNFORMATTED
      Open(10,File=FRESIN,FORM='UNFORMATTED',STATUS='OLD')
      Read(10) ((um_rc(NV,j),j=1,N2),NV=1,3)
      Read(10) ((umean(1,i,j),j=1,n2m),i=1,n1)
      Close(10)
      
      ELSE                      ! RESCALE DATA FORMAT : FORMATTED 
      OPEN(10,FILE=FRESIN,STATUS='OLD')
      DO 10 NV=1,3
      DO 10 J=1,N2
      READ(10,100) um_rc(NV,J)
  10  CONTINUE
      DO 20 I=1,N1
      DO 20 J=1,N2M
      READ(10,100) umean(1,I,J)
  20  CONTINUE
      CLOSE(10)
  100 FORMAT(E15.7)

      ENDIF ! FOR IFORRES

      ELSE IF (NREAD.EQ.2.AND.IGEN.EQ.1.AND.NTIME.EQ.NSTART) THEN
      write(*,*) 'Reading rescaling data from',FRESIN
      WRITE(*,*) 'AND Interpolation to convert N1M/2 -> N1M'
      N1H=N1M/2+1
      
      IF (IFORRES.EQ.0) THEN    ! RESCALE DATA FORMAT : UNFORMATTED
      Open(10,File=FRESIN,FORM='UNFORMATTED',STATUS='OLD')
      Read(10) ((um_rc(NV,j),j=1,N2),NV=1,3)
      Read(10) ((UMEANTEMP(1,i,j),j=1,n2m),i=1,N1H)
      Close(10)
      ELSE
      OPEN(10,FILE=FRESIN,STATUS='OLD')
      DO 110 NV=1,3
      DO 110 J=1,N2
      READ(10,100) um_rc(NV,J)
 110  CONTINUE
      DO 120 I=1,N1H
      DO 120 J=1,N2M
      READ(10,100) UMEANTEMP(1,I,J)
 120  CONTINUE
      CLOSE(10)
      ENDIF ! FOR IFORRES
   
      DO J=1,N2M
      DO I=1,N1H-1
      UMEAN(1,2*I-1,J)=UMEANTEMP(1,I,J)
      UMEAN(1,2*I,J)=0.5*(UMEANTEMP(1,I,J)+UMEANTEMP(1,I+1,J)) 
      ENDDO
      I=N1H
      UMEAN(1,N1,J)=UMEANTEMP(1,I,J)
      ENDDO

      ENDIF ! FOR IGEN

      If (TIME.le.1000.0) then 
      Tavg=100.               ! note the length scale is theta_in
      else If (TIME.ge.1000.0 ) then 
      Tavg=1000.               
      Endif

      IF (IGEN.eq.1) Tavg=1000.
      
      Do j=1,N2
         temp1(j)=0.0
         temp2(j)=0.0
      enddo
      Do k=1,N3M
      Do j=1,N2
         temp1(j)=temp1(j)+u(IRC,j,k,1)/Real(N3M)         
         temp2(j)=temp2(j)+u(IRC,j,k,2)/Real(N3M)         
      enddo
      enddo

      Do k=1,N3M
      Do j=1,N2
         uf_rc(1,j,k)=u(IRC,j,k,1)-temp1(j)
         uf_rc(2,j,k)=u(IRC,j,k,2)-temp2(j)
      enddo
      enddo

      If (NTIME.eq.NSTART.and.IGEN.ne.1) then
      Do j=1,N2
         um_rc(1,j)=temp1(j)
         um_rc(2,j)=temp2(j)
      enddo
      else
      Do j=1,N2
      um_rc(1,j)=DT/Tavg*temp1(j)+(1.-DT/Tavg)*um_rc(1,j) 
      um_rc(2,j)=DT/Tavg*temp2(j)+(1.-DT/Tavg)*um_rc(2,j) 
      enddo
      endif
     

      Do j=1,N2M
      um_rc(3,j)=0.0
      enddo

      Do k=1,N3M
      Do j=1,N2M
      uf_rc(3,j,k)=u(IRC,j,k,3)
      enddo
      enddo

      Do j=1,N2M
      Do i=1,N1
         temp3(i,j)=0.
      enddo
      enddo
      Do k=1,N3M
      Do j=1,N2M
      Do i=1,N1
         temp3(i,j)=temp3(i,j)+u(i,j,k,1)/Real(N3M)         
      enddo
      enddo
      enddo
      If (NTIME.eq.NSTART.and.IGEN.ne.1)then
      Do j=1,N2M
      Do i=1,N1
         umean(1,i,j)=temp3(i,j)
      enddo
      enddo
      else
      Do j=1,N2M
      Do i=1,N1
        umean(1,i,j)=DT/Tavg*temp3(i,j)+(1.-DT/Tavg)*umean(1,i,j) 
      enddo
      enddo
      endif
 
      If(MOD(NTIME,NPRN).EQ.0.AND.NWRITE.EQ.1) then 

      FILEW=FRESOUT
      N=INDEX(FILEW,'.')
      WRITE(UNIT=FILEW(N+1:),FMT='(BN,I6.6)') NTIME

      IF(IFORRES.EQ.0) THEN   ! RESCALE DATA FORMAT : UNFORMATTED
      write(*,*) 'writing rescaling data from',FILEW
      Open(10,File=FILEW,FORM='UNFORMATTED',STATUS='UNKNOWN')
      Write(10) ((um_rc(NV,j),j=1,N2),NV=1,3)
      Write(10) ((umean(1,i,j),j=1,n2m),i=1,n1)
      Close(10)

      ELSE
      write(*,*) 'writing rescaling data from',FILEW
      OPEN(10,FILE=FILEW,STATUS='UNKNOWN')
      DO 30 NV=1,3
      DO 30 J=1,N2
      WRITE(10,100) um_rc(NV,J)
  30  CONTINUE
      DO 40 I=1,N1
      DO 40 J=1,N2M
      WRITE(10,100) umean(1,I,J)
  40  CONTINUE
      CLOSE(10)
      ENDIF ! FOR IFORRES
      Endif ! FOR NTIME

      Return
      End 
c      BLOCK DATA
c      INCLUDE 'tbl_inflow.h'
c      data (((umean(k,i,j),k=1,3),j=0,M2),i=0,M1) /M1M2P13*0./
c      End

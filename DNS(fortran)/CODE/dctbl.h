      PARAMETER (M1=2049,M2=150,M3=513)
      PARAMETER (M3M=M3-1,M3MH=M3M/2,M1M=M1-1)
      PARAMETER (M2P13=3*(M2+1),M1M2P13=3*(M1+1)*(M2+1))
      PARAMETER (MJC=10,MIC=30)


      COMMON/SIMTY/ITYPE
      COMMON/TSTEP/NSTART,NFINAL,DTR,CFLMAX,NTIME,DT,TIME
      COMMON/TSTEP2/NPRN,NINS,NREPAR,TSTART,NINFLOW,NAVGSTP
      COMMON/TSTEP3/NAVGQS,NSKIPINS,NSKIPINF
      COMMON/FINOUT/INCODE,IDTOPT,NWRITE,NREAD,IREPAR
      Common/INFLOW/IGEN,INFSAVE,I_SAVE,NFLINF
      COMMON/AVER/IAVG,IAVGB,IAVGC,IAVGQ 
      COMMON/POST1/ITHIST,ITHIST1,ITHIST2,ITHIST3,ITHIST4
      COMMON/POST2/ITHIST5,ITHIST6,ITHIST7,ITHIST8,ITHIST9
      COMMON/POST3/IPROF,IPROF1,IPROF2,IPROF3,IPROF4
      COMMON/POST4/IPROF5,IPROF6,INSF,IWRITEW,IAVGMON,JAVGMON

      COMMON/DIM/N1,N2,N3,N1M,N2M,N3M
      COMMON/SIZE/ALX,ALY,ALZ,VOL
      COMMON/PARA/RE,R_theta_in
      COMMON/VPERIN/VPER
      
      COMMON/MESH1/DX1,DX1Q,DX3,DX3Q
      COMMON/MESH2/Y(0:M2)
      COMMON/MESH3/DY(0:M2),H(M2),HM(M2),HC(M2),HP(M2)
      COMMON/MESH4/DYM(M2),DYC(M2),DYP(M2)
      COMMON/INDX/IPA(M1),IMU(M1),IMV(M1),KPA(M3),KMA(M3)
      COMMON/INDX2/JPA(M2),JMU(M2),JMV(M2)
      COMMON/FINDX/FIPA(M1),FIMU(M1),FIMV(M1),FKPA(M3),FKMA(M3)
      COMMON/FINDX2/FJPA(M2),FJMU(M2),FJMV(M2)
      COMMON/NVAVE/NVV1(6),NVV2(6)
      
      COMMON/BCON/UBC1(3,M1,M3),UBC2(3,M1,M3)
      COMMON/BCON2/UBC3(3,M2,M3),UBC4(3,M2,M3)

!revised by HyunQ, Averaging Variable

      COMMON/FIRST/VM(3,M1,M2,M3)!,PM(800,M2,M3)
c      COMMON/SECOND/VVM(6,800,M2,M3),PPM(800,M2,M3)
c      COMMON/HIGH/V3M(3,800,M2,M3)
c      COMMON/OMEGA/VORM(3,800,M2,M3),VORQM(3,800,M2,M3)

!by HyunQ

      Common/recycle/IRC,ut_in,ut_rc,delta_rc,delta_in
      Common/recycle2/theta_in,theta_rc
      Common/recycle3/umean(3,0:M1,0:M2)
      Common/recycle4/um_rc(3,0:M2),uf_rc(3,0:M2,0:M3)
      Common/recycle5/um_in(3,2,0:M2),uf_in(3,2,0:M2,0:M3)

      Common/tbl_para/c_kapa,BB,PII

      COMMON/BLOCK/IMFOR,IMASS,IB,JB,IW,IL,KW,KL,HB,EPSX,EPSY,TFOR
      COMMON/IBM/NF(3,M1,M2,M3)
      COMMON/IBM4/IFU(3,M1,M2,M3),JFU(3,M1,M2,M3),KFU(3,M1,M2,M3)
      COMMON/IBM2/ALPHA(3,M1,M2,M3),BETA(3,M1,M2,M3),GAMMA1(3,M1,M2,M3)
      COMMON/IBM3/AFI(3,M1,M2,M3),AFJ(3,M1,M2,M3),AFK(3,M1,M2,M3)
      COMMON/IBM5/AFD(3,M1,M2,M3),AFB(3,M1,M2,M3)
      COMMON/IBMQ1/QIP(M1,M2),QJP(M1,M2),QKP(M1,M2)
      COMMON/IBMQ2/QI(M1,M2),QJ(M1,M2),QK(M1,M2)
!      COMMON/IBMQ3/Q(M1,M2,M3) 
      
      COMMON/FILEFORM/IFORIN,IFOROUT,IFORINF,IFORRES,IFORAVG
      
      COMMON/FILENAME1/fileini,filegrd,fileout,fileibm,filepar
      COMMON/FILENAME2/fileavg,filebdg,filecor,fresin,fresout
      COMMON/FILENAME3/foutavg,foutbdg,foutcor,fileinf,fileins
      COMMON/FILENAME4/fileparc,filequad,foutquad

      CHARACTER*100 fileini,filegrd,fileout,fileibm,filepar
      CHARACTER*100 fileavg,filebdg,filecor,fresin,fresout 
      CHARACTER*100 foutavg,foutbdg,foutcor,fileinf,fileins 
      CHARACTER*100 fileparc,filequad,foutquad
      CHARACTER*65 DUMMY

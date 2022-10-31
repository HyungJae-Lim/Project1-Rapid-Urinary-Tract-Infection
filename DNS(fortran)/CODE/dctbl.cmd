#!/bin/ksh
# @ job_type = parallel 
# @ class = class.32plus 
# @ error = serial.err
# @ output = serial.out
# @ notification = complete
# @ notify_user = jhlee06@kaist.ac.kr
# @ resources = ConsumableCpus(32) ConsumableMemory(256gb)
# @ wall_clock_limit=240:00:00
# @ queue
export XLSMPOPTS="parthds=32:spins=0:yields=0:stack=2000000000"
!rm -rf /gpfs2/g047shj/jaehwa/roughwall/MAIN/transient/
!mkdir /gpfs2/g047shj/jaehwa
!mkdir /gpfs2/g047shj/jaehwa/roughwall
!mkdir /gpfs2/g047shj/jaehwa/roughwall/MAIN
!mkdir /gpfs2/g047shj/jaehwa/roughwall/MAIN/transient
!cp -rf /gpfs1/g047shj/jaehwa/roughwall/MAIN/transient/* /gpfs2/g047shj/jaehwa/roughwall/MAIN/transient/

!cd /gpfs2/g047shj/jaehwa/roughwall/MAIN/transient

time ./dctbl  > Result

!cp -rf /gpfs2/g047shj/jaehwa/roughwall/MAIN/transient/* /gpfs1/g047shj/jaehwa/roughwall/MAIN/transient/
~

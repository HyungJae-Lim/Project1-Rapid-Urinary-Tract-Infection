FC= ifort
FFLAGS= -r8 -i8 -O2 -mcmodel=medium -assume buffered_io -shared_intel \
	-openmp -openmp-report0 -vec-report0		
#FFLAGS= -r8 -i8 -g -fpe0 -traceback -check bounds -mcmodel=medium
#FFLAGS = -warn declarations -warn errors -warn general \
 -warn interfaces -warn uncalled -warn unused -warn usage \
 -r8 -O3 -diag-disable vec
#FFLAGS= -r8 -O3 -mcmodel=medium -assume buffered_io -openmp -shared-intel
LOPTS = -L/opt/intel/mkl/10.2.2.025/lib/em64t/ \
        -lfftw3 -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -liomp5 -lguide -lpthread
#FFTW = -L/usr/local/lib/libfftw3.a

TARGET = dctbl.e

OBJS = setup.o iniup.o readup.o  divcheck_cfl.o \
	cfl.o   getup.o output.o average.o  \
	readup2.o readup3.o iniave.o\
	mesh.o indices.o iniwave.o metricpoisson.o bcond.o uhcalc.o \
	dpcalc.o upcalc.o \
	rescaling.o rhs1.o rhs2.o rhs3.o \
	getuh1.o getuh2.o getuh3.o rhsdp.o takedp.o \
	get_um_rc.o get_um_in.o  get_delta_in.o get_uf_in.o get_inflow2.o \
	weight.o save_inflow.o immersed.o forcing.o initfq.o\
	explicita.o explicitb.o \
	tdmai.o tdmaj.o tdmaj0.o tdmak.o \
	iniupi.o get_ramda.o re_theta.o spalding.o get_um.o \
	rhsdpi.o takedpi.o upcalci.o make_ibm.o skip_inflow.o dctbl.o \
	write_wall.o writeup.o insfield.o 


dctbl   :$(OBJS)
	$(FC) $(FFLAGS) $@.o -o $(TARGET) $(OBJS) $(FFTW) $(LOPTS)
#	$(FC) -pg -shared-intel -o $(TARGET) $(OBJS) $(LOPTS)

clean   :
	rm -f $(OBJS) dctbl 
new     :
	$(MAKE) clean
	$(MAKE)



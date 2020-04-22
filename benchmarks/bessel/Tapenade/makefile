#================================================
# system parameters
F77 = gfortran
F90 = gfortran
CC = cc
CCOPTS = -O3 #-CB -CU -g -trace -W1
FCOPTS = -O2 #-CB -CU -g -trace -W1
LDOPTS = -O3 #-CB -CU -g -trace -W1
LIBS = 
#================================================
# define all obj files
OBJS = besselj_b.o adBuffer.o adStack.o besselj_d.o besselj.o main.o
#================================================
# link all to generate exe file
main.out: $(OBJS)
	$(F90) $(FCOPTS) $(OBJS) $(LIBS) -o main.out 
#================================================
clean:
	rm -f *.o *.mod *.x *.a
#================================================
#generate every obj and module files
besselj_b.o : besselj_b.f90
	$(F90) $(FCOPTS) -c besselj_b.f90
besselj_d.o : besselj_d.f90
	$(F90) $(FCOPTS) -c besselj_d.f90
besselj.o : main.f90
	$(F90) $(FCOPTS) -c besselj.f90
main.o : main.f90
	$(F90) $(FCOPTS) -c main.f90
adBuffer.o : adBuffer.f
	$(F77) $(CCOPTS) -c adBuffer.f
adStack.o : adStack.c
	$(CC) $(CCOPTS) -c adStack.c


# Author:
#   Yuanqing Wu, Shenzhen University, P.R.China
#
# History:
#   2022-3-24 by Yuanqing Wu
#
# Support:
#   wuyuanq@gmail.com

PROG = Generatefullgrid
defaults: ${PROG}

FCC = gfortran
#FCC = mpif90

#FCFLAGS = -O3 -fdefault-real-8 -g
FCFLAGS = -g -O3
#FCFLAGS = -O3 -fbounds-check 
#FCFLAGS = -O3

VPATH = ../../FlashCalculation

FSRCS = RST_globalFlashData.F90 RST_mathlib.F90 RST_PREOS.F90 RST_comprefac.F90 RST_fugacitycoef.F90 \
      RST_stability.F90 RST_pmv.F90 RST_flashcalculation.F90 RST_flashcalculationDriver.F90 example.F90 
      
%.o: %.F90
	$(FCC) -c $(FCFLAGS) $^ -o $@ 

FOBJS = $(FSRCS:.F90=.o)
$(PROG):  $(FOBJS)
	$(FCC) $(FCFLAGS) $(FOBJS) $(LIBS) -o $(PROG)

all: $(PROG)

LIBS = -llapack

.PHONY: clean

clean:
	rm -rf *.mod *.o $(PROG) 

run: ${PROG} 
	./${PROG} 

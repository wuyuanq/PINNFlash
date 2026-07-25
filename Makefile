
# Author:
#   Yuanqing Wu, KAUST, Saudi Arabia
#
# History:
#   2015-2-9 by Yuanqing Wu
#
# Support:
#   wuyuanq@gmail.com

PROG = testNN
defaults: ${PROG}

FCC = gfortran

#FCFLAGS = -O3 -fdefault-real-8 -g
FCFLAGS = -g -O3
#FCFLAGS = -O3 -fbounds-check 
#FCFLAGS = -O3

FLASHFLAGS = -DNN

VPATH = ../FlashCalculation

FSRCS = RST_globalFlashData.F90 RST_mathlib.F90 RST_PREOS.F90 RST_comprefac.F90 \
RST_fugacitycoef.F90 RST_pmv.F90 RST_getEquResidual.F90 RST_flashcalculation_nn.F90 testNN.F90
     
%.o: %.F90
	$(FCC) -c $(FCFLAGS) $(FLASHFLAGS) $^ -o $@ 

FOBJS = $(FSRCS:.F90=.o)

$(PROG): $(FOBJS) 
	$(FCC) $(FCFLAGS) $(FLASHFLAGS) $(FOBJS) $(LIBS) -o $(PROG)

LIBS = -llapack

all: $(PROG)

.PHONY: clean

clean:
	rm -rf *.mod *.o $(PROG)

run: ${PROG} 
	./${PROG}

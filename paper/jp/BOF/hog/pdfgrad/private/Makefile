Linux_i386_ARCH             := glx
Linux_i686_ARCH             := glx
Linux_x86_64_ARCH           := g64
Linux_unknown_ARCH          := glx

UNAME            := $(shell uname -sm)
HNAME            := $(shell hostname)
ARCH             := $($(shell echo "$(UNAME)" | tr \  _)_ARCH)

MEX              := mex
MEX_OPTION       :=-cxx -v -I. -largeArrayDims
BLASOPTION		 :=-lmwblas -lmwlapack

glx_MEX_SUFFIX   := mexglx
g64_MEX_SUFFIX   := mexa64
MEX_SUFFIX       := $($(ARCH)_MEX_SUFFIX)

#MKLROOTLIB		:= $(MKLROOT)/lib/em64t
#MKLROOTLIB		:= $(MKLROOT)/lib/intel64
MKLROOTLIB		:= $(shell ls -d $(MKLROOT)/lib/*)
MKLLIBSILP64	:= -L${MKLROOTLIB} ${MKLROOTLIB}/libmkl_intel_ilp64.a -Wl,--start-group ${MKLROOTLIB}/libmkl_intel_thread.a ${MKLROOTLIB}/libmkl_core.a -Wl,--end-group -L ${MKLROOTLIB} -liomp5 -lpthread -lm
MKLCXXFLAGSILP64:= $(CXXFLAGS) -fexceptions -openmp -fPIC -DMKL_ILP64
MKLLIBS			:= -L${MKLROOTLIB} ${MKLROOTLIB}/libmkl_intel_lp64.a -Wl,--start-group ${MKLROOTLIB}/libmkl_intel_thread.a ${MKLROOTLIB}/libmkl_core.a -Wl,--end-group -L ${MKLROOTLIB} -liomp5 -lpthread -lm
MKLCXXFLAGS		:= $(CXXFLAGS) -fexceptions -openmp -fPIC

DIR := $(shell pwd)
src := ssymv_mex.cpp ssymm_mex.cpp Pxx_mex.cpp

EXE := $(src:.cpp=.$(MEX_SUFFIX))

VER := $(shell which icc | cut -d "/" -f 5 | sed "s/\.//g")
OMP_LIB := $(shell if [ $(VER) -lt 111 ] ; then echo  -lguide; else echo -L ${MKLROOTLIB} -liomp5 -lpthread -lm; fi)
#OMP_LIB := $(shell if [ $(VER) -lt 111 ] ; then echo  -lguide; else echo -liomp5; fi)

all:${EXE}

.SUFFIXES: .$(MEX_SUFFIX) .cpp

.cpp.$(MEX_SUFFIX):
	$(MEX) $(MEX_OPTION) CXXFLAGS='${MKLCXXFLAGSILP64}' $< $(MKLLIBSILP64) -o $@

clean:
	rm -f *.$(MEX_SUFFIX) *.o

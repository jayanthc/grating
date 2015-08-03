#
# Makefile for Grating
#
# Created by Jayanth Chennamangalam
#

# C compiler and flags
# this may need to be changed to g77 in some cases
CC = gcc
# include path for other libraries
CFLAGS_INC_PGPLOT =# define if needed (as -I[...])
CFLAGS_INC_CUFFT =# define if needed (as -I[...])
CFLAGS = -O3 -std=gnu99 -pedantic -Wall $(CFLAGS_INC_PGPLOT) $(CFLAGS_INC_FFTW3)

# NVCC compiler and flags
NVCC = nvcc
NVFLAGS = --ptxas-options=-v --compiler-bindir=/usr/bin/gcc -O3

# NVCC targets
# (Tesla K40m CC: 3.5, GeForce GTX TITAN CC: 3.5, GeForce GTX TITAN X CC: 5.2)
#NVFLAGS +=  \
  -gencode=arch=compute_35,code=sm_35 \
  -gencode=arch=compute_35,code=compute_35

# linker flags
LFLAGS_PGPLOT_DIR =# define if not in $PATH (as -L[...])
LFLAGS_CUFFT_DIR =# define if not in $PATH (as -L[...])
LFLAGS_CUFFT = $(LFLAGS_CUFFT_DIR) -lcufft
# in some cases, linking needs to be done with the X11 library, in which case
# append '-lX11' (and possibly the path to the library) to the line below.
# libgfortran may also be needed in some case, in which case append
# '-lgfortran' (and possibly the path to the library) to the line below
LFLAGS_PGPLOT = $(LFLAGS_PGPLOT_DIR)  -lcpgplot -lpgplot -lpng -lgfortran -lX11
LFLAGS_MATH = -lm

# directories
SRCDIR = src
TOOLSDIR = tools
IDIR = src
BINDIR = bin

# command definitions
DELCMD = rm

all: grating grating_gentestdata tags

grating: $(SRCDIR)/grating.cu $(SRCDIR)/grating.h
	$(NVCC) $(NVFLAGS) $< $(LFLAGS_MATH) $(LFLAGS_CUFFT) $(LFLAGS_PGPLOT) -o $(BINDIR)/$@

# test-data-generation program
grating_gentestdata: $(TOOLSDIR)/grating_gentestdata.c
	$(CC) $(CFLAGS) $< $(LFLAGS_MATH) -o $(BINDIR)/$@

tags: $(SRCDIR)/*.cu $(SRCDIR)/*.h
	ctags --language-force=C $(SRCDIR)/*.cu $(SRCDIR)/*.h

#clean:
#	$(DELCMD) $(IDIR)/yapp_version.o


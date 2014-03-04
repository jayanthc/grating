# Grating 1.0
## README

Grating is a GPU-based polyphase filter bank (PFB) spectrometer. The program reads 8-bit, complex, dual-polarisation, multi-channel interleaved time samples from a file and performs the PFB operation. As a stand-alone program, the use of Grating is limited - it is intended to be a template for the code for online/real-time heterogeneous spectrometers.

Grating is currently not offered as a library, although future versions may have that option.

In addition to the main program, Grating comes with a Python script to generate the PFB pre-filter coefficients. It also comes with a program to generate test data.

System requirements: Linux PC with NVIDIA CUDA-capable GPU and associated driver, CUDA 4.0 or above with the CUFFT library, PGPLOT with C binding, Python with Numpy and Matplotlib

Installation instructions: On a typical Ubuntu-based machine in which CUFFT is installed in the standard location and PGPLOT was installed via APT, running `make` should work. For different operating systems and/or different CUFFT/PGPLOT installation directories the makefile may need to be modified by hand.

Created by Jayanth Chennamangalam, based on work done with the CASPER group at UC Berkeley for the VErsatile GBT Astronomical Spectrometer ([VEGAS](http://www.gb.nrao.edu/vegas/)).

---

###### Notes on notation:

A Hungarian-esque notation is used here. Example:

    #define DEF_NFFT    1024    /* 'DEF_' denotes default values */

    int g_iVar; /* global variable */

    <ret-type> Function(<args>)
    {
        float fVar;
        int iVar;
        double dVar;

        /* CUDA types */
        char4 c4Var;
        float2 f2Var;
        dim3 dimVar;

        /* pointers */
        char *pcVar;
        int *piVar;

        /* arrays */
        float afVarArray[10];

        ...
    }

---

    Usage: grating [options] <data-file>
        -h  --help                          Display this usage information
        -n  --nfft <value>                  Number of points in FFT
        -p  --pfb                           Do PFB
        -a  --nacc <value>                  Number of spectra to add
        -s  --fsamp <value>                 Sampling frequency (used only in plots)

This code reads 8-bit, complex, dual-polarization, n-sub-band data from a user-specified file, loads the entire contents of the file to memory (that restricts the max. file size), and does FFT or PFB on the data, depending on user-specified command-line flags, and accumulates spectra. Data is copied from host memory to device memory in blocks of 32MB. (This code fails for data file size < 32MB.) The number of spectra to accumulate is also user-specified.

Data is two's-complement 8-bit values in the range [-128, 127] (that are actually 8_7 fixed-point values in the range [-1.0, +0.992188]. The samples are interleaved, like so:

    -------------------------------------------------------------
    | Real(X-pol.) | Imag(X-pol.) | Real(Y-pol.) | Imag(Y-pol.) |
    -------------------------------------------------------------

They are read into a CUDA char4 array as follows:

    char4 c4Data;

    c4Data.x = Real(X-pol.)
    c4Data.y = Imag(X-pol.)
    c4Data.z = Real(Y-pol.)
    c4Data.w = Imag(Y-pol.)

There are three compilation flags defined in `grating.h`:

`PLOT`: If set to non-zero value, will use PGPLOT to plot spectra  
`BENCHMARKING`: If set to non-zero value, will calculate and print kernel benchmarks.  
`OUTFILE`: If set to non-zero value, will write spectra to file. The spectra are written in the following format. The length of each block is given in parentheses, in units of samples.

    ---------------------------------------------------
    | PowX (1) | PowY (1) | Re(XY*) (1) | Im(XY*) (1) |
    ---------------------------------------------------
    (Interleaved samples)

The main logic, in pseudo-code, is as follows:

    Initialise stuff, including copying of first 32MB block to device memory
    while(Data-processing-not-done)
    {
        if (PFB-is-on)
        {
            Do pre-filtering on first P * N samples (P = number of taps, N = number of points in FFT)
        }
        else    /* only FFT */
        {
            Copy char4 array to float4 array (CUFFT requires float input)
        }

        Do FFT

        Accumulate spectra
        if (Accumulated-enough-spectra)
        {
            Copy accumulated vector back to host
        }

        if (32MB-data-is-processed)
        {
            Copy next 32MB block of data to device memory
        }
        else
        {
            continue;
        }
    }

BUG: Code doesn't work for data file size < 32MB.

---

`grating_gentestdata.c`:

    Usage: grating_gentestdata [options] <data-file>
        -h  --help                          Display this usage information
        -n  --nsamp <value>                 Number of time samples

Program to generate test data for Grating. The test data is made up of 1-byte signed values in the range -128 to 127 that are interpreted by the Grating to be 8_7 fixed-point values in the range [-1.0, 0.992188]. Grating treats this data as interleaved, complex, dual-polarisation data, with an arbitrary number of sub-bands.

This program has to be manually edited to change input tone frequencies, add sweeping signals, etc.

---

`grating_gencoeff.py`

    Usage: grating_gencoeff.py [options]
        -h  --help                 Display this usage information
        -n  --nfft <value>         Number of points in FFT
        -t  --taps <value>         Number of taps in PFB
        -b  --sub-bands <value>    Number of sub-bands in data
        -d  --data-type <value>    Data type - "float" or "signedchar"
        -p  --no-plot              Do not plot coefficients

Python script to generate pre-filter coefficients for the Grating PFB, given the number of points in the FFT, number of filter taps, number of sub-bands in the data, and whether to output single-precision floating point coefficients or signed chars in the range [-128, 127]. Note that Grating can only accept floating point coefficients.

The number of sub-bands does not actually affect the coefficients themselves, but is included as an optimisation feature - each coefficient repeats this many times, for ease of GPU thread indexing.

The output is a binary file, and the filename has the following format:

    coeff_<data-type>_<taps>_<nfft>_<sub-bands>.dat

#!/usr/bin/ruby

# runmulti.rb
# Test suite for the standalone VEGAS GPU spectrometer implementation
#   Runs the program the given number of times and calculates the mean and
#   standard deviation of the time taken.
#   Usage: runmulti.rb <nRuns> <nFFT> <nSubBands> <nAcc> <pfb-flag>
#
# Created by Jayanth Chennamangalam on 2011.10.05

Bin = "./vegas_gpu_standalone"
FileData = "/export/home/vegas-hpc10/vegas/vegas_1711858_1.00_0010.fits"
FileTemp = "./tmp.out"

nRuns = ARGV[0].to_i
nFFT = ARGV[1]
nSubBands = ARGV[2]
nAcc = ARGV[3]
sQuiet = ARGV[4]

bQuiet = false
if ("-q" == sQuiet)
    bQuiet = true
end

sum = 0.0

if (false == bQuiet)
    print "Commencing #{nRuns} runs of #{Bin}..."
end
print nFFT, ", ", nAcc, ", "
STDOUT.flush
for i in 0...nRuns
  %x[#{Bin} -n #{nFFT} -b #{nSubBands} -a #{nAcc} -p #{FileData} > #{FileTemp}]
  t = %x[tail -1 #{FileTemp} | awk '{print $5}' | sed s/s//]
  sum = sum + t.to_f
end
if (false == bQuiet)
    print "DONE\n"
end

%x[rm -rf #{FileTemp}]

avg = sum / nRuns
if (false == bQuiet)
    print "Average time taken = ", avg, "s\n"
else
    print avg, "\n"
end


#!/usr/bin/ruby

# runmulti_bm_time.rb
# Test suite for the standalone VEGAS GPU spectrometer implementation
#   Runs the program in benchmarking mode the given number of times and
#   calculates the mean and standard deviation of the kernel times (in ms).
#   Usage: runmulti_bm_time.rb <nRuns> <nFFT> <nSubBands> <nAcc>
#
# Created by Jayanth Chennamangalam on 2011.10.05

Bin = "/home/jayanth/vegas/bin_gcc/vegas_gpu_standalone"
FileData = "/export/home/spec-hpc-01/testdata_jayanth/1.6G.dat"
FileTemp = "tmp.out"

nRuns = ARGV[0].to_i
nFFT = ARGV[1]
nSubBands = ARGV[2]
nAcc = ARGV[3]
sum1 = 0.0
sum2 = 0.0
sum3 = 0.0
sum4 = 0.0
sum5 = 0.0

print "Commencing #{nRuns} runs of #{Bin}..."
STDOUT.flush
for i in 0...nRuns
  %x[#{Bin} -n #{nFFT} -b #{nSubBands} -a #{nAcc} -p #{FileData} > #{FileTemp}]
  t1 = %x[tail -7 #{FileTemp} | head -1 | awk '{print $6}' | sed s/ms,//]
  t2 = %x[tail -6 #{FileTemp} | head -1 | awk '{print $6}' | sed s/ms,//]
  t3 = %x[tail -5 #{FileTemp} | head -1 | awk '{print $6}' | sed s/ms,//]
  t4 = %x[tail -4 #{FileTemp} | head -1 | awk '{print $6}' | sed s/ms,//]
  t5 = %x[tail -3 #{FileTemp} | head -1 | awk '{print $6}' | sed s/ms,//]
  sum1 = sum1 + t1.to_f
  sum2 = sum2 + t2.to_f
  sum3 = sum3 + t3.to_f
  sum4 = sum4 + t4.to_f
  sum5 = sum5 + t5.to_f
end
print "DONE\n"

%x[rm -rf #{FileTemp}]

avg = sum1 / nRuns
print "Average time taken for H2D = ", avg, "ms\n"
avg = sum2 / nRuns
print "Average time taken for PFB = ", avg, "ms\n"
avg = sum3 / nRuns
print "Average time taken for FFT = ", avg, "ms\n"
avg = sum4 / nRuns
print "Average time taken for Accumulate = ", avg, "ms\n"
avg = sum5 / nRuns
print "Average time taken for D2H = ", avg, "ms\n"


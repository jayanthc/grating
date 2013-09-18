#!/usr/bin/ruby

# genperfstats.rb
# Test suite for the standalone VEGAS GPU spectrometer implementation
#   Usage: genperfstats.rb
#
# Created by Jayanth Chennamangalam on 2012.07.18

TestScript = "./runmulti.rb"

iRuns = 10
#aiNFFT = (10..17).to_a    # 1024 to 131072
aiNFFT = (10..20).to_a    # 1024 to 1048576
#aiNFFT = (10..12).to_a    # 1024 to 2048
iNumSubBands = 1
aiAccLen = [1, 10, 100, 1000]
#aiAccLen = [100, 1000]
bPFB = true

if (bPFB)
  sPFB = "-p"
else
  sPFB = ""
end

print "Testing..."
STDOUT.flush
for i in 0...aiNFFT.length
  for j in 0...aiAccLen.length
#    fTime[i][j] = Float(%x[#{TestScript} #{iRuns} #{2**aiNFFT[i]} #{iNumSubBands} #{aiAccLen[j]} -q])
    %x[#{TestScript} #{iRuns} #{2**aiNFFT[i]} #{iNumSubBands} #{aiAccLen[j]} -q >> perf.out]
  end
end
print "DONE\n"

#for i in 0...aiNFFT.length
#  for j in 0...aiAccLen.length
#    print "#{fTime[i][j]} "
#  end
#  print "\n"
#end


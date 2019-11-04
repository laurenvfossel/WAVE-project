# WAVE-project

Our final project in Computer Organization was to host a virtual version of the Warm on the Wind. The Warm is
an ARM-like RISC processor, while the Wind is similar to an Intel x86-like processor. Our task was to
load Warm programs into the Wind memory and simulate the the execution of the program by a Warm
processor. As with any successful emulator, the Warm virtual emulator (or Wave) will be a success if it
(1) runs correctly, (2) runs quickly, and (3) uses as little memory as possible.

====================================================================
 PERFORMANCE SUMMARY:
====================================================================
PROGRAM   FOOTPRINT   WAVE      WARM      WAVE/WARM     TEST STATUS

ali       1000        217440    5899      36.86         passed
bfz       996         7924081   264931 2  9.91          passed
gcd       995         13213     341       38.75         passed
lfsr      998         532913    14552     36.62         passed
memory    996         2756      74        37.24         passed
pal2      792         56552     1572      35.97         passed
pc-ccr    995         2571      65        39.55         passed
phase2    995         3351      94        35.65         passed
phoon     1002        64119     1778      36.06         passed
stm       995         1351      37        36.51         passed
-----------------------------------------------------------------------
OVERALL PERFORMANCE ON 10 SUCCESSFUL TESTS: SIZE=976.40 SPEED=36.31

Professor Duane Bailey's comments on this project: "Earning a perfect score in correctness is demonstrably a difficult task and is only really possible when all team members have the best understanding of the problem at hand. Take pride in this work; it is, I think, reflective of great efforts ahead."

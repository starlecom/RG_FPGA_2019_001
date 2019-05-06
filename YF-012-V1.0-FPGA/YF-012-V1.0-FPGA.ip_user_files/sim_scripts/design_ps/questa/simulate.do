onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -pli "D:/Xlinx/Vivado/2015.4/lib/win64.o/libxil_vsim.dll" -lib xil_defaultlib design_ps_opt

do {wave.do}

view wave
view structure
view signals

do {design_ps.udo}

run -all

quit -force

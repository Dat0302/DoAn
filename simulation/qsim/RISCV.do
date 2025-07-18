onerror {quit -f}
vlib work
vlog -work work RISCV.vo
vlog -work work RISCV.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.datapath_debug_vlg_vec_tst
vcd file -direction RISCV.msim.vcd
vcd add -internal datapath_debug_vlg_vec_tst/*
vcd add -internal datapath_debug_vlg_vec_tst/i1/*
add wave /*
run -all

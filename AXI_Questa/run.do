vlib work
vmap work work
vlog {../AXI_Questa/MasterSlaveAxiInterface.sv}
vlog {../AXI_Questa/Master_Axi3Protocol.sv}
vlog {../AXI_Questa/Slave_Axi3Protocol.sv}
vlog {../AXI_Questa/Top_HDL.sv}
vlog {../AXI_Questa/monitor.sv}
vlog {../AXI_Questa/assertions.sv}
vlog {../AXI_Questa/Top_HVL.sv}
vlog {../AXI_Questa/VE.sv}
vlog {../AXI_Questa/driver.sv}
vlog {../AXI_Questa/testcase.sv}
vsim -coverage -novopt top
vsim work.top -autoexclusionsdisable=fsm
add wave -position insertpoint sim:/top/intf/*
run 700000
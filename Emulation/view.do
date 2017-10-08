view wave
dataset open ./veloce.wave/wave1.stw wave1
#wave add -d wave1 top.clock {top.reset} {top.rdata}  {top.bus} 
wave add -d wave1 AXI_design_emulation.clock {AXI_design_emulation.reset} {AXI_design_emulation.AWid} {AXI_design_emulation.AWaddr} {AXI_design_emulation.AWlen}
wave add -d wave1 {AXI_design_emulation.AWsize} {AXI_design_emulation.AWburst} {AXI_design_emulation.WData} {AXI_design_emulation.WStrb} {AXI_design_emulation.WData}
wave add -d wave1 {AXI_design_emulation.AWVALID_tb_s} {AXI_design_emulation.AWBURST_tb_s} {AXI_design_emulation.AWSIZE_tb_s} {AXI_design_emulation.AWLEN_tb_s} 
wave add -d wave1 {AXI_design_emulation.AWADDR_tb_s} {AXI_design_emulation.AWID_tb_s} {AXI_design_emulation.WVALID_tb_s} {AXI_design_emulation.WLAST_tb_s} 
wave add -d wave1 {AXI_design_emulation.WSTRB_tb_s} {AXI_design_emulation.WDATA_tb_s} {AXI_design_emulation.WID_tb_s} {AXI_design_emulation.BREADY_tb_s} 
wave add -d wave1 {AXI_design_emulation.ARID_tb_s} {AXI_design_emulation.ARADDR_tb_s} {AXI_design_emulation.ARLEN_tb_s} {AXI_design_emulation.ARSIZE_tb_s} 
wave add -d wave1 {AXI_design_emulation.ARBURST_tb_s} {AXI_design_emulation.ARVALID_tb_s} {AXI_design_emulation.RREADY_tb_s} {AXI_design_emulation.AWREADY_tb_m} 
wave add -d wave1 {AXI_design_emulation.WREADY_tb_m} {AXI_design_emulation.BID_tb_m} {AXI_design_emulation.BRESP_tb_m} {AXI_design_emulation.BVALID_tb_m} 
wave add -d wave1 {AXI_design_emulation.ARREADY_tb_m} {AXI_design_emulation.RID_tb_m} {AXI_design_emulation.RDATA_tb_m} {AXI_design_emulation.RRESP_tb_m} 
wave add -d wave1 {AXI_design_emulation.RLAST_tb_m} {AXI_design_emulation.RVALID_tb_m} 
echo "wave1.stw loaded and signals added. Open the Wave window to observe outputs."


	
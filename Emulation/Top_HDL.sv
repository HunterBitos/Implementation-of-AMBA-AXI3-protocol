

module AXI_design_emulation(
	input	logic	clock,
	input	logic	reset,

input logic [31:0]  AWaddr,
input logic [3:0]   AWlen,
input logic	[31:0]	WData,
input logic	[3:0]	AWid,
input logic	[3:0]   WStrb,
input logic	[3:0]	ARid,
input logic	[3:0]	ARlen,
input logic	[2:0]	AWsize,
input logic	[1:0]	AWburst,
input logic	[31:0]	ARaddr,
input logic	[2:0]	ARsize,
input logic	[1:0]	ARburst,
//viewing inputs of slave
output logic		AWVALID_tb_s,
output logic	[1:0]	AWBURST_tb_s,
output logic	[2:0]	AWSIZE_tb_s,
output logic	[3:0]	AWLEN_tb_s,
output logic	[31:0]	AWADDR_tb_s,
output logic	[3:0]	AWID_tb_s,
output logic		WVALID_tb_s,
output logic		WLAST_tb_s,
output logic	[3:0]	WSTRB_tb_s,
output logic	[31:0]	WDATA_tb_s,
output logic	[3:0]	WID_tb_s,
output logic		BREADY_tb_s,
output logic	[3:0]	ARID_tb_s,
output logic	[31:0]	ARADDR_tb_s,
output logic	[3:0]	ARLEN_tb_s,
output logic	[2:0]	ARSIZE_tb_s,
output logic	[1:0]	ARBURST_tb_s,
output logic	        ARVALID_tb_s,
output logic		RREADY_tb_s,
//viewing inputs of master .
output logic		AWREADY_tb_m,
output logic		WREADY_tb_m,
output logic	[3:0]	BID_tb_m,
output logic	[1:0]	BRESP_tb_m,
output logic		BVALID_tb_m,
output logic		ARREADY_tb_m,
output logic	[3:0]	RID_tb_m,
output logic	[31:0]	RDATA_tb_m,
output logic	[1:0]	RRESP_tb_m,
output logic		RLAST_tb_m,
output logic		RVALID_tb_m

);

//interface declaration
AXI bus();
logic		    AWREADY;
logic		    AWVALID;
logic	[1:0]	AWBURST;
logic	[2:0]	AWSIZE;
logic	[3:0]	AWLEN;
logic	[31:0]	AWADDR;
logic	[3:0]	AWID;
logic		    WREADY;// write data channel
logic		    WVALID;
logic		    WLAST;
logic	[3:0]	WSTRB;
logic	[31:0]	WDATA;
logic	[3:0]	WID;
logic	[3:0]	BID;// write response channel
logic	[1:0]	BRESP;
logic		    BVALID;
logic		    BREADY;
logic		    ARREADY;// address read channel
logic	[3:0]	ARID;
logic	[31:0]	ARADDR;
logic	[3:0]	ARLEN;
logic	[2:0]	ARSIZE;
logic	[1:0]	ARBURST;
logic		    ARVALID;
logic	[3:0]	RID;// read data channel
logic	[31:0]	RDATA;
logic	[1:0]	RRESP;
logic		    RLAST;
logic		    RVALID;
logic		    RREADY;

AXI_Master_emulation master_inst(
	// GLOBAL SIGNALS
			.clock(clock),
			.reset(reset),
			.masterintf(bus),
			
			
			.AWaddr(AWaddr),
			.AWlen(AWlen),
			.WStrb(WStrb),
			.AWsize(AWsize),
			.AWburst(AWburst),
			.WData(WData),
			.AWid(AWid),

			.ARaddr(ARaddr),
			.ARid(ARid),
			.ARlen(ARlen),
			.ARsize(ARsize),
			.ARburst(ARburst),
            .AWREADY_tb_m(AWREADY_tb_m), 
            .WREADY_tb_m(WREADY_tb_m), 
            .BID_tb_m(BID_tb_m), 
            .BRESP_tb_m(BRESP_tb_m), 
            .BVALID_tb_m(BVALID_tb_m), 
            .ARREADY_tb_m(ARREADY_tb_m), 
            .RID_tb_m(RID_tb_m), 
            .RDATA_tb_m(RDATA_tb_m), 
            .RRESP_tb_m(RRESP_tb_m), 
            .RLAST_tb_m(RLAST_tb_m), 
            .RVALID_tb_m(RVALID_tb_m)


);
			
			
AXI_Slave_emulation slave_inst(.clock(clock),
			.reset(reset),
			.slaveintf(bus),      
            .AWVALID_tb_s(AWVALID_tb_s), 
            .AWBURST_tb_s(AWBURST_tb_s), 
            .AWSIZE_tb_s(AWSIZE_tb_s), 
            .AWLEN_tb_s(AWLEN_tb_s), 
            .AWADDR_tb_s(AWADDR_tb_s), 
            .AWID_tb_s(AWID_tb_s),
            .WVALID_tb_s(WVALID_tb_s), 
            .WLAST_tb_s(WLAST_tb_s), 
            .WSTRB_tb_s(WSTRB_tb_s), 
            .WDATA_tb_s(WDATA_tb_s), 
            .WID_tb_s(WID_tb_s),  
            .BREADY_tb_s(BREADY_tb_s), 
            .ARID_tb_s(ARID_tb_s), 
            .ARADDR_tb_s(ARADDR_tb_s), 
            .ARLEN_tb_s(ARLEN_tb_s), 
            .ARSIZE_tb_s(ARSIZE_tb_s), 
            .ARBURST_tb_s(ARBURST_tb_s), 
            .ARVALID_tb_s(ARVALID_tb_s), 
            .RREADY_tb_s(RREADY_tb_s)
);



endmodule	

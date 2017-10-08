
 interface AXI;
// pragma attribute axi partition_interface_xif

//logic		 resetn;
logic		AWREADY;
logic		AWVALID;
logic	[1:0]	AWBURST;
logic	[2:0]	AWSIZE;
logic	[3:0]	AWLEN;
logic	[31:0]	AWADDR;
logic	[3:0]	AWID;
logic		WREADY;// data write channel
logic		WVALID;
logic		WLAST;
logic	[3:0]	WSTRB;
logic	[31:0]	WDATA;
logic	[3:0]	WID;
logic	[3:0]	BID;//write response channel
logic	[1:0]	BRESP;
logic		BVALID;
logic		BREADY;
logic		ARREADY;// read address channel
logic	[3:0]	ARID;
logic	[31:0]	ARADDR;
logic	[3:0]	ARLEN;
logic	[2:0]	ARSIZE;
logic	[1:0]	ARBURST;
logic		ARVALID;
logic	[3:0]	RID;// read data channel
logic	[31:0]	RDATA;
logic	[1:0]	RRESP;
logic		RLAST;
logic		RVALID;
logic		RREADY;
modport master(
	//input	resetn,
	input	AWREADY,
	output	AWVALID,
	output	AWBURST,
	output	AWSIZE,
	output	AWLEN,
	output	AWADDR,
	output	AWID,
	input	WREADY,// data write channel
	output	WVALID,
	output	WLAST,
	output	WSTRB,
	output	WDATA,
	output	WID,
	input	BID,// write response channel
	input	BRESP,
	input	BVALID,
	output	BREADY,
	input	ARREADY,// read address channel
	output	ARID,
	output	ARADDR,
	output	ARLEN,
	output	ARSIZE,
	output	ARBURST,
	output	ARVALID,
	input	RID,// read data channel
	input	RDATA,
	input	RRESP,
	input	RLAST,
	input	RVALID,
	output	RREADY
);
modport slave(
	//input	resetn,
	output	AWREADY, // write address channel
	input	AWVALID,
	input	AWBURST,
	input	AWSIZE,
	input	AWLEN,
	input	AWADDR,
	input	AWID,
	output	WREADY,// data write channel
	input	WVALID,
	input	WLAST,
	input	WSTRB,
	input	WDATA,
	input	WID,
	output	BID,// write response channel
	output	BRESP,
	output	BVALID,
	input	BREADY,
	output	ARREADY,// read address channel
	input	ARID,
	input	ARADDR,
	input	ARLEN,
	input	ARSIZE,
	input	ARBURST,
	input	ARVALID,
	output	RID,// read data channel
	output	RDATA,
	output	RRESP,
	output	RLAST,
	output	RVALID,
	input	RREADY
);
endinterface

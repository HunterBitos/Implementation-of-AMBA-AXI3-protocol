`include"MasterSlaveAxiInterface.sv"

module assertions(
input	logic	clock,
input	logic	reset,
	
axi intf

);

// *********************Write Data Channel Assertions**********************************************
// WID and AWID shuld match
property AXI_AWID_WID;
@(posedge clock)
		intf.WVALID |=> (intf.WID == intf.AWID);
endproperty
AXI_WVALID_WID_c: assert property (AXI_AWID_WID);


// The control signals  WDATA, WSTRB,WLAST,WID should remain stable
property AXI_WVALID_STABLE;
@(posedge clock)
		(intf.WVALID && !intf.WREADY) |=> ($stable(intf.WDATA) && $stable(intf.WSTRB) && $stable(intf.WID)); 
endproperty
AXI_WVALID_STABLE_c: assert property (AXI_WVALID_STABLE);

// The control signals WSTRB,WLAST,WID should not have any X's or Z's

property AXI_VALIDSIGNALS;
@(posedge clock)
		##1 (intf.WVALID) |=> (!$isunknown(intf.WDATA) && !$isunknown(intf.WSTRB) && !$isunknown(intf.WID)); 
endproperty
AXI_VALIDSIGNALS_c: assert property (AXI_VALIDSIGNALS);

//Check when WREADY goes low after 1 clock cycle
property AXI_WVALID_WREADY;
@(posedge clock)
		(intf.WVALID && !intf.WREADY) |=>  (intf.WVALID &&intf.WREADY) ##1 (!intf.WVALID && !intf.WREADY);
endproperty

AXI_WVALID_WREADY_c: assert property (AXI_WVALID_WREADY);

//**************************** Write Address Channel Assertions*********************************************************

// Data width should be less than 32 bit

property AXI_AWSIZE;
@(posedge clock)
		##1 intf.AWSIZE < 3'b011;
		
endproperty

AXI_AWSIZE_WA: assert property(AXI_AWSIZE);

// AWBURST type cannot be 3

property AXI_AWBURST;
@(posedge clock)
		##1 intf.AWBURST != 2'b11;
endproperty
AXI_AWBURST_WA: assert property(AXI_AWBURST);

// check whether control signals are stable

property AXI_MASTERSIGNAL_STABLE;
@(posedge clock)	
		(intf.AWVALID && !intf.AWREADY)|=> ($stable(intf.AWID) && $stable(intf.AWADDR) && $stable(intf.AWLEN) && $stable(intf.AWSIZE) && $stable(intf.AWBURST)); 
		
endproperty
AXI_MASTERSIGNAL_STABLE_c:assert property(AXI_MASTERSIGNAL_STABLE);

// Check for X's and Z's

property AXI_MASTERSIGNAL_UNDEFINED;
@(posedge clock)
		disable iff (!reset)
		(intf.AWVALID) |-> (!$isunknown(intf.AWID) && !$isunknown(intf.AWADDR) && !$isunknown(intf.AWLEN) && !$isunknown(intf.AWSIZE) && !$isunknown(intf.AWBURST));
endproperty
AXI_MASTERSIGNAL_UNDEFINED_c:assert property(AXI_MASTERSIGNAL_UNDEFINED);

//In case of wrapping burst AWLEN should have value 2, 4, 8, 16

property AXI_WRAPBOUNDARY;
@(posedge clock)
disable iff (!reset)
		(intf.AWBURST == 2'b10) |-> (intf.AWLEN == 4'b0001 || intf.AWLEN == 4'b0011 || intf.AWLEN == 4'b0111 || intf.AWLEN == 4'b1111);
endproperty

AXI_WRAPBOUNDARY_c: assert property(AXI_WRAPBOUNDARY);

// check when AWVALID is asserted, AWVALID goes high and then goes low

property AXI_AWVALID_AWREADY;
@(posedge clock)
	(intf.AWVALID && !intf.AWREADY) |=>  (intf.AWVALID &&intf.AWREADY) ##1 (!intf.AWVALID && !intf.AWREADY);
endproperty

AXI_AWVALID_AWREADY_c: assert property(AXI_AWVALID_AWREADY);


//******************* Assertions for Write Response Channel*****************************************
//Check if BID and AWID matches
property AXI_BVALID_BID;
@(posedge clock)
		intf.BVALID |=> (intf.BID == intf.AWID);
endproperty
AXI_BVALID_BID_a: assert property (AXI_BVALID_BID);

//Check if BRESP IS STABLE AFTER BVALID IS PRESENT
property AXI_BVALID_BRESP;
@(posedge clock)
 		##1 intf.BVALID |=> $stable(intf.BRESP);
endproperty
AXI_BVALID_BRESP_a: assert property (AXI_BVALID_BRESP);

// Check if after BVALID is asserted BREADY becomes 1 after 1 clock cycle
property AXI_BVALID_BREADY;
@(posedge clock)
		(intf.BVALID && !intf.BREADY) |=>  (intf.BVALID &&intf.BREADY) ##1 (!intf.BVALID && !intf.BREADY);
endproperty
AXI_BVALID_BREADY_a: assert property (AXI_BVALID_BREADY);

//Check if slave should initiate response, after WLAST is asserted
property AXI_WLAST_BVALID;
@(posedge clock)
		intf.WLAST |=> intf.BVALID;
endproperty

AXI_WLAST_BVALID_a: assert property (AXI_WLAST_BVALID);


//***************** Read Address Channel Assertions*************************************
// check the control signals are stable
property AXI_ARVALID_STABLE;
@(posedge clock)
		(intf.ARVALID && !intf.ARREADY) |=> ($stable(intf.ARID) && $stable(intf.ARADDR) && $stable(intf.ARLEN) && $stable(intf.ARSIZE) && $stable(intf.ARBURST)); 
endproperty
AXI_ARVALID_STABLE_c: assert property (AXI_ARVALID_STABLE);

// check of ARVALID and ARREADY
property AXI_VALIDSIGNALS_RA;
@(posedge clock)
		(reset)|=> (!$isunknown(intf.ARVALID) && !$isunknown(intf.ARREADY));
endproperty
AXI_VALIDSIGNALS_RA_c: assert property (AXI_VALIDSIGNALS_RA);

// Check if ARREADY and ARVALID after 1 clock cycle.
property AXI_ARVALID_ARREADY;
@(posedge clock)
		(intf.ARVALID && !intf.ARREADY) |=>  (intf.ARVALID &&intf.ARREADY) ##1 (!intf.ARVALID && !intf.ARREADY);
endproperty

AXI_ARVALID_ARREADY_c: assert property (AXI_ARVALID_ARREADY);

//**********************Read Data Channel Assertions******************************************
//Check if RID and ARID is same
property AXI_RVALID_RID;
@(posedge clock)
		intf.RVALID |=> (intf.RID == intf.ARID);
endproperty
AXI_RVALID_RID_c: assert property (AXI_RVALID_RID);

//check if CONTROL SIGNALS ARE STABLE
property AXI_RVALID_STABLE;
@(posedge clock)
		(intf.RVALID && !intf.RREADY) |=> ($stable(intf.RID) && $stable(intf.RDATA) && $stable(intf.RRESP)); 
endproperty
AXI_RVALID_STABLE_c: assert property (AXI_RVALID_STABLE);


// Check if ARREADY becomes low after 1 clock cycle
property AXI_RVALID_RREADY;
@(posedge clock)
		(intf.RVALID && !intf.RREADY) |=>  (intf.RVALID &&intf.RREADY) ##1 (!intf.RVALID && !intf.RREADY);
endproperty

AXI_RVALID_RREADY_c: assert property (AXI_RVALID_RREADY);


endmodule
		
`include "MasterSlaveAxiInterface.sv"


module Top_HDL #(parameter DATAWIDTH, SIZE)
	(
	input	logic	clock,
	input	logic	reset,
	output logic [4095:0][7:0] slave_memory,
	output logic [4095:0][7:0] master_memory,
	axi intf,

	
///////////////////////Inputs to the Master from Testbench	

input logic [DATAWIDTH-1:0] AWaddr,
input logic [(DATAWIDTH/8)-1:0] AWlen,
input logic	[(DATAWIDTH/8)-1:0] WStrb,
input logic	[SIZE-1:0]	AWsize,
input	logic	[SIZE-2:0]	AWburst,
input logic	[DATAWIDTH-1:0]	WData,
input logic	[(DATAWIDTH/8)-1:0]	AWid,

input logic	[DATAWIDTH-1:0]	ARaddr,
input logic	[(DATAWIDTH/8)-1:0]	ARid,
input logic	[(DATAWIDTH/8)-1:0]	ARlen,
input logic	[SIZE-1:0]	ARsize,
input logic	[SIZE-2:0]	ARburst
	
);





///Master<-> Axi3 interconnect instantiating

Master_Axi3Protocol #(.DATAWIDTH(32),.SIZE(3))
master_inst		(	.clock(clock),
	    		.reset(reset),	
			.AMBA(intf),
		
			.read_memory(master_memory),
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
			.ARburst(ARburst)
);

//Slave<->Axi3 interconnect instantiating

Slave_Axi3Protocol slave_inst(.clock(clock),
		     .reset(reset),
		     .AMBAS(intf),
                     .slave_memory(slave_memory)
);


endmodule	
`include"driver.sv"
`include"MasterSlaveAxiInterface.sv"
`include"VE.sv"
`include"assertions.sv"
`include"Top_HDL.sv"

module top(); 
timeunit 1ns;
timeprecision 100ps;

environment env; 
 
logic clock; 
logic reset;
logic [4095:0][7:0] slave_memory;
logic [4095:0][7:0] master_memory;

bit [31:0] AWaddr;
bit [3:0]   AWlen;
bit	[3:0] WStrb;
bit	[2:0]	AWsize;
bit	[1:0]	AWburst;
bit	[31:0]	WData;
bit	[3:0]	AWid;

bit	[31:0]	ARaddr;
bit	[3:0]	ARid;
bit	[3:0]	ARlen;
bit	[2:0]	ARsize;
bit	[1:0]	ARburst;



//Generating Clock
   
initial begin
clock ='1;
forever #5 clock = ~clock;
end			

//////////////Instantiating 
axi intf();
driver drvr= new(intf);
testcase test(intf); 
Top_HDL #(.DATAWIDTH(32),.SIZE(3))
	Top_inst	(.clock(clock),
				 .reset(reset),
				 .slave_memory(slave_memory),
				 .master_memory(master_memory),
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
				 .intf(intf)
				
);

// Binding assertions with Top_HDL
bind Top_HDL assertions  duta(clock,reset,intf);
endmodule

			
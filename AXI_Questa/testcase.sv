`include"driver.sv"
`include"MasterSlaveAxiInterface.sv"
`include"VE.sv"


`timescale 1ns/1ns

program testcase(axi intf); 
   environment env = new(intf); 
	reg [3:0]	rand_awid;
	reg [31:0]	rand_awaddr_valid;
	reg [31:0]	rand_awaddr_invalid;
	reg [31:0]	rand_awaddr_readonly;
	reg [31:0]	rand_wdata;
	reg [31:0]	rand_araddr_valid;
	reg [31:0]	rand_araddr_invalid;
	reg [3:0]	rand_arid;
	
	initial begin
	
	//Calling reset task from the driver.
	env.drvr.reset_enable();
	
	
	//Calling burst alternate write and read task of the driver- with stimulus generating the random values inside the driver
	env.drvr.burst_write_read(rand_awid, rand_awaddr_valid, rand_awaddr_invalid, rand_awaddr_readonly, rand_wdata, rand_araddr_valid, rand_araddr_invalid, rand_arid );
	#10;
	/*
	//Calling Burst Read task of the driver- with stimulus generating the random values inside the driver
	env.drvr.burst_read(rand_awid, rand_awaddr_valid, rand_awaddr_invalid, rand_awaddr_readonly, rand_wdata, rand_araddr_valid, rand_araddr_invalid, rand_arid );
	#10;
	
	//Calling Burst Write for readonly address range -with stimulus generating the random values inside the driver
	env.drvr.burst_write_readonly(rand_awid, rand_awaddr_valid, rand_awaddr_invalid, rand_awaddr_readonly, rand_wdata, rand_araddr_valid, rand_araddr_invalid, rand_arid );
	#10;
	
	//Calling Burst Write Invalid address range -with stimulus generating the random values inside the driver
	env.drvr.burst_write_invalid(rand_awid, rand_awaddr_valid, rand_awaddr_invalid, rand_awaddr_readonly, rand_wdata, rand_araddr_valid, rand_araddr_invalid, rand_arid );
	#10;
	
	//Calling Burst Read from Invalid address range - with stimulus generating the random values inside the driver
	env.drvr.burst_read_invalid(rand_awid, rand_awaddr_valid, rand_awaddr_invalid, rand_awaddr_readonly, rand_wdata, rand_araddr_valid, rand_araddr_invalid, rand_arid );*/
	#10;
	
	$finish;
	end
	
	initial begin
		env.mntr.start();
	end	
	


endprogram 
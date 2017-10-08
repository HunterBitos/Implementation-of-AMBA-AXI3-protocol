`include"driver.sv"
`include"MasterSlaveAxiInterface.sv"

`timescale 1ns/1ns


`ifndef mon
`define mon
class monitor;
   virtual axi intf;   
 
      driver dv;
   function new(virtual axi intf); 
      begin
	 this.intf = intf;
	end
   endfunction 
   
    
   task start();      
      forever
	@(posedge top.clock)
	begin
	   $display("***************************  MONITOR OUTPUT  ********************************************* ");		
	   $display("###Write Data####     : %b",intf.WDATA);	   
	   $display("###Read Data####     : %b",intf.RDATA);
	   $display("***************************************************************************************** ");
	end
      
   endtask
endclass

`endif
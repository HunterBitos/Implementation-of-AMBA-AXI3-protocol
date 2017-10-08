`include"driver.sv"
`include"MasterSlaveAxiInterface.sv"
`include"monitor.sv"




`timescale 1ns/1ns

`ifndef env_sv
`define env_sv
class environment; 
    driver drvr; 
   
   monitor mntr; 
   virtual axi intf; 
   
   function new(virtual axi intf); 
      this.intf = intf;
     
      drvr = new(intf); 
      mntr = new(intf); 
   endfunction 
   
   
   
endclass 
`endif
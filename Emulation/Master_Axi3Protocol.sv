
module AXI_Master_emulation(
input clock, reset,
AXI.master  masterintf,
input logic [31:0]  AWaddr,//sending inputs to master through AXI protocol
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
output logic		    AWREADY_tb_m,//inputs drom slave to master.
output logic		    WREADY_tb_m,
output logic	[3:0]	BID_tb_m,
output logic	[1:0]	BRESP_tb_m,
output logic		    BVALID_tb_m,
output logic		    ARREADY_tb_m,
output logic	[3:0]	RID_tb_m,
output logic	[31:0]	RDATA_tb_m,
output logic	[1:0]	RRESP_tb_m,
output logic		    RLAST_tb_m,
output logic		    RVALID_tb_m);


logic [7:0] read_memory [4096];//instantiating 2D array
//pragma attribute read_memory ram_block 1 //for emulator
assign AWREADY_tb_m = masterintf.AWREADY;//sending inputs from slave to master
assign WREADY_tb_m = masterintf.WREADY;
assign BID_tb_m = masterintf.BID;
assign BRESP_tb_m = masterintf.BRESP;
assign BVALID_tb_m = masterintf.BVALID;
assign ARREADY_tb_m = masterintf.ARREADY;
assign RID_tb_m = masterintf.RID;
assign RDATA_tb_m =  masterintf.RDATA;
assign RRESP_tb_m = masterintf.RRESP;
assign RLAST_tb_m = masterintf.RLAST;
assign RVALID_tb_m = masterintf.RVALID;
//master write address
enum logic [1:0] { 
 MWRITE_IDLE=2'b00,
 MWRITE_START,
 MWRITE_WAIT,
 MWRITE_VALID } MAWRITEState, MAWRITENext_state; 

// master write data
logic [4:0] Count, NextCount;
enum logic [2:0] {MWRITE_INIT=3'b000,
 MWRITE_TRANSFER,
 MWRITE_READY, 
 MDWRITE_VALID,
 MWRITE_ERROR} MWRITEState, MWRITENext_state;

//master write response 
enum logic [1:0] { MASTERB_IDLE=2'b00,
 MASTERB_START,
 MASTERB_READY } MASTERBState, MASTERBNext_state;


//  master read address 
enum logic [2:0] {MREAD_IDLE=3'b000,
 MREAD_WAIT,
 MREAD_READY,
 MREAD_VALID,
 MREAD_EXTRA} ARMREADState,ARMREADNext_state;

// master read data  
logic [31:0] slaveaddress,
 slaveaddress_r,
 slaveaddress_temp,
 ARADDR_r;        
enum logic [1:0] {MREAD_CLEAR=2'b00,
 MREAD_STARTM,
 MREAD_READ,
 MDREAD_VALID } MREADState,MREADNext_state;
integer  wrap_boundary,first_time1, first_time1_next;

//write address channel
always_ff @(posedge clock or negedge reset)	
begin	
	if(!reset)	begin
		MAWRITEState <= MWRITE_IDLE;
	end
	else begin
		MAWRITEState <= MAWRITENext_state;
	end	
end

always_comb	
begin	
	case(MAWRITEState)
      MWRITE_IDLE:begin
                 masterintf.AWVALID = '0;
                 masterintf.AWBURST = '0;
                 masterintf.AWSIZE = '0;
                 masterintf.AWLEN = '0;
                 masterintf.AWADDR = '0;
                 masterintf.AWID = '0;
                 MAWRITENext_state = MWRITE_START;
                end		
                
     MWRITE_START:begin
				 if(AWaddr > 32'h0)  begin
				  masterintf.AWBURST = AWburst;
				  masterintf.AWSIZE = AWsize;
				  masterintf.AWLEN = AWlen;
				  masterintf.AWADDR = AWaddr;
				  masterintf.AWID = AWid;
				  masterintf.AWVALID = 1'b1;
				  MAWRITENext_state = MWRITE_WAIT;	
				 end
				 else
				  MAWRITENext_state = MWRITE_IDLE;
                end
             
	  MWRITE_WAIT:begin	
				 if (masterintf.AWREADY)
				  MAWRITENext_state = MWRITE_VALID;
				 else
				  MAWRITENext_state = MWRITE_WAIT;
				end
	
	 MWRITE_VALID:begin
				 masterintf.AWVALID = '0;
				 if(masterintf.BREADY)
				  MAWRITENext_state = MWRITE_IDLE;			
				 else
				  MAWRITENext_state = MWRITE_VALID;
			    end
	endcase
end



//write data channel master
always_ff @(posedge clock or negedge reset)
begin
	if(!reset)
	 begin
		MWRITEState <= MWRITE_INIT;
		Count <= 4'b0;
	 end
	else
	 begin
		MWRITEState <= MWRITENext_state;
		Count <= NextCount;
	 end
end

always_comb
begin
	case(MWRITEState)
    
		MWRITE_INIT:begin
				 masterintf.WID = '0;
				 masterintf.WDATA = '0;
				 masterintf.WSTRB = '0;
				 masterintf.WLAST = '0;
				 masterintf.WVALID = '0;
				 NextCount = '0;
                    if(masterintf.AWREADY == 1) MWRITENext_state = MWRITE_TRANSFER;	
                    else MWRITENext_state = MWRITE_INIT;
                end

   MWRITE_TRANSFER:begin	
                 if(AWaddr > 32'h5ff && AWaddr <=32'hfff && AWsize <3'b100) 
                    begin
                      masterintf.WID =  masterintf.AWID;
                      masterintf.WVALID = '1;
                      masterintf.WSTRB = WStrb;
                      masterintf.WDATA = WData;	
                      NextCount = Count + 4'b1;
                      MWRITENext_state = MWRITE_READY;
				 end
				 else begin
					  NextCount = Count + 4'b1;
					  MWRITENext_state = MWRITE_ERROR;
				 end
				end

	  MWRITE_READY:begin
				 if(masterintf.WREADY) begin
					  if(NextCount == (AWlen+1))  masterintf.WLAST = 1'b1;
					  else  masterintf.WLAST = 1'b0;
                    
					  MWRITENext_state = MDWRITE_VALID;
				 end			
				 else MWRITENext_state = MWRITE_READY;	
			    end
	
	  MDWRITE_VALID:begin
                 masterintf.WVALID = '0;
                      
				 if(NextCount == AWlen+1) begin
					  MWRITENext_state = MWRITE_INIT;	
					  masterintf.WLAST='0;
				 end
				 else MWRITENext_state = MWRITE_TRANSFER;
				end
	  
      MWRITE_ERROR:begin
				 if(NextCount == (AWlen+1)) begin
					  masterintf.WLAST = 1'b1;
					  MWRITENext_state = MDWRITE_VALID;
				 end
				 else begin
					  masterintf.WLAST = 1'b0;
					  MWRITENext_state = MWRITE_TRANSFER;
				 end
			    end	
	endcase
end


//write response channel master

always_ff @(posedge clock or negedge reset)	begin
	if(!reset)	begin
		MASTERBState <= MASTERB_IDLE;
	end
	else
		MASTERBState <= MASTERBNext_state;
end

always_comb	begin
	
	case(MASTERBState)
	
   MASTERB_IDLE:begin
			 masterintf.BREADY = '0;
			 MASTERBNext_state = MASTERB_START;
			end		
            
  MASTERB_START:begin
			 if(masterintf.BVALID) begin
			  MASTERBNext_state = MASTERB_READY;	
			 end
			end
            
  MASTERB_READY:begin	
			  masterintf.BREADY = 1'b1;
			  MASTERBNext_state = MASTERB_IDLE;
			end
	endcase
end

//read address channel master
always_ff @(posedge clock or negedge reset)
begin
	if (!reset)	begin
		ARMREADState <= MREAD_IDLE;
	end
	else	begin
		ARMREADState <= ARMREADNext_state;
	end
		
end


always_comb
begin 	
    case (ARMREADState)
  MREAD_IDLE:begin
             masterintf.ARID = 0;
             masterintf.ARADDR = 0;
             masterintf.ARLEN = 0;
             masterintf.ARSIZE = 0;
             masterintf.ARBURST = 0;
             masterintf.ARVALID = 0;
            ARMREADNext_state = MREAD_WAIT;
            end
            
  MREAD_WAIT:begin
            if(ARaddr > 32'h0) begin	
             masterintf.ARID = ARid;
             masterintf.ARADDR = ARaddr;
             masterintf.ARLEN = ARlen;
             masterintf.ARSIZE = ARsize;
             masterintf.ARBURST = ARburst;
             masterintf.ARVALID = 1'b1;
            ARMREADNext_state = MREAD_READY;
            end
            else
             ARMREADNext_state = MREAD_IDLE;
            end
            
 MREAD_READY:begin
            if (masterintf.ARREADY)
             ARMREADNext_state = MREAD_VALID;
            else 					
             ARMREADNext_state = MREAD_READY;
            end
            
 MREAD_VALID:begin
             masterintf.ARVALID = '0;
             if(masterintf.RLAST)
              ARMREADNext_state = MREAD_EXTRA;
             else
              ARMREADNext_state = MREAD_VALID;
            end	
            
 MREAD_EXTRA:begin
             ARMREADNext_state = MREAD_IDLE;
            end
        endcase
end



//read data channel master

        
always_ff @(posedge clock or negedge reset)
begin
    if(!reset)
        MREADState       <= MREAD_CLEAR;
    else begin
        MREADState       <= MREADNext_state;
        first_time1 <= first_time1_next;
    end
end
        
       
always_comb
    begin	
        if(masterintf.ARREADY)
            ARADDR_r = ARaddr;
  
        case(MREADState)
  MREAD_CLEAR:begin
                MREADNext_state  =  MREAD_STARTM;
                 masterintf.RREADY = '0;
                first_time1_next = 0;	
                slaveaddress = '0;
                slaveaddress_r='0;
            end
                
   MREAD_STARTM:begin
                if(masterintf.RVALID) begin
                    MREADNext_state = MREAD_READ;                    
                    slaveaddress = slaveaddress_r;
                end
                else
                    MREADNext_state =  MREAD_STARTM;	
            end
        
   MREAD_READ:begin
                MREADNext_state = MDREAD_VALID;
                masterintf.RREADY= '1;        //setting RREADY to 1 to say to slave that master is ready to receive valid data.
                
                case(ARburst)
                  2'b00:begin
                            slaveaddress = ARADDR_r;
                            case (ARsize)
                            3'b000: begin	
                                         read_memory[slaveaddress] =  masterintf.RDATA[7:0]; 
                                    end
                            3'b001: begin	
                                        read_memory[slaveaddress] =  masterintf.RDATA[7:0]; 
                                        read_memory[slaveaddress+1] =  masterintf.RDATA[15:8]; 		
                                    end
                            3'b010: begin	
                                        read_memory[slaveaddress] =  masterintf.RDATA[7:0];
                                        read_memory[slaveaddress+1] =  masterintf.RDATA[15:8];
                                        read_memory[slaveaddress+2] =  masterintf.RDATA[23:16];
                                        read_memory[slaveaddress+3] =  masterintf.RDATA[31:24];
                                    end
                            endcase
                        end
                                
                  2'b01:begin
                            if(first_time1 == 0) begin
                                slaveaddress = ARADDR_r;
                                first_time1_next = 1;
                            end	
                            else	
                                first_time1_next = first_time1;
                                
                            if(masterintf.RLAST == 1)
                                first_time1_next = 0;
                            else 
                                first_time1_next = first_time1;
                            
                            case (ARsize)
                            3'b000: begin	
                                        read_memory[slaveaddress] =  masterintf.RDATA[7:0];
                                    end
                            3'b001: begin	
                                        read_memory[slaveaddress] =  masterintf.RDATA[7:0];
                                        read_memory[slaveaddress+1] =  masterintf.RDATA[15:8];
                                        slaveaddress_r = slaveaddress + 2;	
                                    end
                            3'b010: begin	
                                        read_memory[slaveaddress] =  masterintf.RDATA[7:0];
                                        read_memory[slaveaddress+1] =  masterintf.RDATA[15:8];
                                        read_memory[slaveaddress+2] =  masterintf.RDATA[23:16];
                                        read_memory[slaveaddress+3] =  masterintf.RDATA[31:24];
                                        slaveaddress_r = slaveaddress + 4;
                                    end
                            endcase
                        end
                         2'b10:begin
                            if(first_time1 == 0) begin
                                slaveaddress =  ARADDR_r;
                                first_time1_next = 1;
                            end	
                            else 
                                first_time1_next = first_time1;
                        
                            if(masterintf.RLAST == 1)
                                first_time1_next = 0;
                            else 
                                first_time1_next = first_time1;
                                
                            case(ARlen)
                            4'b0001:begin
                                        case(ARsize)
                                        3'b000: begin
                                                    wrap_boundary = 2 * 1;
                                                end
                                        3'b001: begin
                                                    wrap_boundary = 2 * 2;																		
                                                end	
                                        3'b010: begin
                                                    wrap_boundary = 2 * 4;																		
                                                end
                                        endcase			
                                    end
                                    
                            4'b0011: begin
                                        case(ARsize)
                                        3'b000: begin
                                                    wrap_boundary = 4 * 1;
                                                end
                                        3'b001: begin
                                                    wrap_boundary = 4 * 2;																		
                                                end	
                                        3'b010: begin
                                                    wrap_boundary = 4 * 4;																		
                                                end
                                        endcase			
                                    end
                                    
                            4'b0111:begin
                                        case(ARsize)
                                        3'b000: begin
                                                    wrap_boundary = 8 * 1;  
                                                end
                                        3'b001: begin
                                                    wrap_boundary = 8 * 2;																		
                                                end	
                                        3'b010: begin
                                                    wrap_boundary = 8 * 4;																		
                                                end
                                        endcase			
                                    end	
                            
                            4'b1111: begin
                                        case(ARsize)
                                        3'b000: begin
                                                    wrap_boundary = 16 * 1;   
                                                end
                                        3'b001: begin
                                                    wrap_boundary = 16 * 2;																		
                                                end	
                                        3'b010: begin
                                                    wrap_boundary = 16 * 4;																		
                                                end
                                        endcase			
                                    end
                                endcase	
                                
                                case(ARsize)
                                3'b000: begin	
                                            read_memory[slaveaddress] =  masterintf.RDATA[7:0];
                                            slaveaddress_temp = slaveaddress + 1;
                                            
                                            if(slaveaddress_temp % wrap_boundary == 0)
                                                slaveaddress_r = slaveaddress_temp - wrap_boundary;
                                            else		
                                                slaveaddress_r = slaveaddress_temp;	
                                        end
                                        
                                3'b001: begin	
                                            read_memory[slaveaddress] =  masterintf.RDATA[7:0];
                                            slaveaddress_temp = slaveaddress + 1;
                                            
                                            if(slaveaddress_temp % wrap_boundary == 0)
                                                slaveaddress_r = slaveaddress_temp - wrap_boundary;
                                            else
                                                slaveaddress_r = slaveaddress_temp;
                                                
                                            read_memory[slaveaddress_r] =  masterintf.RDATA[15:8];
                                            slaveaddress_temp = slaveaddress_r + 1;
                                            
                                            if(slaveaddress_temp % wrap_boundary == 0)
                                                slaveaddress_r = slaveaddress_temp - wrap_boundary;
                                            else
                                                slaveaddress_r = slaveaddress_temp;
                                        end
                                        
                                3'b010: begin	
                                            read_memory[slaveaddress] =  masterintf.RDATA[7:0];
                                            slaveaddress_temp = slaveaddress + 1;
                                            
                                            if(slaveaddress_temp % wrap_boundary == 0)
                                                slaveaddress_r = slaveaddress_temp - wrap_boundary;
                                            else
                                                slaveaddress_r = slaveaddress_temp;
                                                
                                            read_memory[slaveaddress_r] =  masterintf.RDATA[15:8];
                                            slaveaddress_temp = slaveaddress_r + 1;
                                            
                                            if(slaveaddress_temp % wrap_boundary == 0)
                                                slaveaddress_r = slaveaddress_temp - wrap_boundary;
                                            else
                                                slaveaddress_r = slaveaddress_temp;
                                                
                                            read_memory[slaveaddress_r] =  masterintf.RDATA[23:16];
                                            slaveaddress_temp = slaveaddress_r + 1;
                                            
                                            if(slaveaddress_temp % wrap_boundary == 0)
                                                slaveaddress_r = slaveaddress_temp - wrap_boundary;
                                            else
                                                slaveaddress_r = slaveaddress_temp;
                                                
                                            read_memory[slaveaddress_r] =  masterintf.RDATA[31:24];
                                            slaveaddress_temp = slaveaddress_r + 1;
                                            
                                            if(slaveaddress_temp % wrap_boundary == 0)
                                                slaveaddress_r = slaveaddress_temp - wrap_boundary;
                                            else
                                                slaveaddress_r = slaveaddress_temp;														
                                        end
                                endcase
                        end
     
                        
                endcase
            end
                
  MDREAD_VALID:begin
                masterintf.RREADY = 1'b0;
                if(masterintf.RLAST) begin
                    //$display("MASTER Mem= %p",read_memory);
                    MREADNext_state = MREAD_CLEAR;
                end
                else
                    MREADNext_state =  MREAD_STARTM;	
            end
        endcase
    end
endmodule
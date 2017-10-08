//////////////////////////////////////////////////////////
//Module for the Axi3 interconnect protocol behaviour with various response signals from Master's channels-
// 1.Write address channel 2.Write Data Channel 3. Write Response channel 4. Read Address channel 5.Read Data Channel
//Implementing the Axi3 protocol while interfacing with Master
//Master<->AXI fsm's 
//
///////////////////////////////////////////////////////////
module Master_Axi3Protocol #(parameter DATAWIDTH, SIZE)
	(
input clock, reset,
axi.Master  AMBA,    //instantiating the Master's Modport from the Interface module 'axi' created in the file 'MasterSlaveAxiInterface.sv'


input logic [DATAWIDTH-1:0]  AWaddr, 			/////////////////////////////////
input logic [(DATAWIDTH/8)-1:0]   AWlen,		//
input logic	[DATAWIDTH-1:0]	WData,				//
input logic	[(DATAWIDTH/8)-1:0]	AWid,			//
input logic	[(DATAWIDTH/8)-1:0]   WStrb,		//
input logic	[(DATAWIDTH/8)-1:0]	ARid,			///////CAMEL CASE LETTERS-  indicating the Axi3 interconnecting signals to from Master 
input logic	[(DATAWIDTH/8)-1:0]	ARlen,			//	
input logic	[SIZE-1:0]	AWsize,					//
input logic	[SIZE-2:0]	AWburst,				//
input logic	[DATAWIDTH-1:0]	ARaddr,				//
input logic	[SIZE-1:0]	ARsize,					//
input logic	[SIZE-2:0]	ARburst,				///////////////////////////////////
output logic	[4095:0] [7:0] read_memory);    //creating a 2D memory array at the axi-> master side for storing the read data recieved by the master from slave .



////////////////////////////////////////////////////////Channels \\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////
//
//Master -Write address channel states
enum logic [1:0] { 
 MWRITE_IDLE=2'b00,
 MWRITE_START,
 MWRITE_WAIT,
 MWRITE_VALID } MAWRITEState, MAWRITENext_state; 

// Master - Write data Channel  states
logic [4:0] Count, NextCount;
enum logic [2:0] {MWRITE_INIT=3'b000,
 MWRITE_TRANSFER,
 MWRITE_READY, 
 MDWRITE_VALID,
 MWRITE_ERROR} MWRITEState, MWRITENext_state;

//Master- Write Response Channel states
enum logic [1:0] { MASTERB_IDLE=2'b00,
 MASTERB_START,
 MASTERB_READY } MASTERBState, MASTERBNext_state;


//Master-Read Address Channel states
enum logic [2:0] {MREAD_IDLE=3'b000,
 MREAD_WAIT,
 MREAD_READY,
 MREAD_VALID,
 MREAD_EXTRA} ARMREADState,ARMREADNext_state;

 
// Master -Read Data Channel States 
logic [31:0] slaveaddress,
 slaveaddress_r,
 slaveaddress_temp,
 ARADDR_r;        
 
 enum logic [1:0] {MREAD_CLEAR=2'b00,
 MREAD_STARTM,
 MREAD_READ,
 MDREAD_VALID } MREADState,MREADNext_state;
integer  wrap_boundary,first_time1, first_time1_next;

/////////////////////////////////////////////////////////////////////////////FSMs Master channels with Axi Protocol implementing\\\\\\\\\\\\\\//////////////////////
///////////Assigning each channel w.r.t Axi interconnect signals(in Camel case) to the Master's  output ports.
///////////////////////////FSM for -  Write Address Channel Master\\\\\\\\\\\\\\\\\\\\\/////////////// 
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
                 AMBA.AWVALID = '0;
                 AMBA.AWBURST = '0;
                 AMBA.AWSIZE = '0;
                 AMBA.AWLEN = '0;
                 AMBA.AWADDR = '0;
                 AMBA.AWID = '0;
                 MAWRITENext_state = MWRITE_START;
                end		
                
     MWRITE_START:begin
				 if(AWaddr > 32'h0)  begin
				  AMBA.AWBURST = AWburst;
				  AMBA.AWSIZE = AWsize;
				  AMBA.AWLEN = AWlen;
				  AMBA.AWADDR = AWaddr;
				  AMBA.AWID = AWid;
				  AMBA.AWVALID = 1'b1;
				  MAWRITENext_state = MWRITE_WAIT;	
				 end
				 else
				  MAWRITENext_state = MWRITE_IDLE;
                end
             
	  MWRITE_WAIT:begin	
				 if (AMBA.AWREADY)
				  MAWRITENext_state = MWRITE_VALID;
				 else
				  MAWRITENext_state = MWRITE_WAIT;
				end
	
	 MWRITE_VALID:begin
				 AMBA.AWVALID = '0;
				 if(AMBA.BREADY)
				  MAWRITENext_state = MWRITE_IDLE;			
				 else
				  MAWRITENext_state = MWRITE_VALID;
			    end
	endcase
end



/////////////////////////////////////////FSM for Write Data Channel of Master\\\\\\\\\\\\\/////////////////////////////////////

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
				 AMBA.WID = '0;
				 AMBA.WDATA = '0;
				 AMBA.WSTRB = '0;
				 AMBA.WLAST = '0;
				 AMBA.WVALID = '0;
				 NextCount = '0;
                    if(AMBA.AWREADY == 1) MWRITENext_state = MWRITE_TRANSFER;	
                    else MWRITENext_state = MWRITE_INIT;
                end

   MWRITE_TRANSFER:begin	
                 if(AWaddr > 32'h5ff && AWaddr <=32'hfff && AWsize <3'b100) 
                    begin
                      AMBA.WID =  AMBA.AWID;
                      AMBA.WVALID = '1;
                      AMBA.WSTRB = WStrb;
                      AMBA.WDATA = WData;	
                      NextCount = Count + 4'b1;
                      MWRITENext_state = MWRITE_READY;
				 end
				 else begin
					  NextCount = Count + 4'b1;
					  MWRITENext_state = MWRITE_ERROR;
				 end
				end

	  MWRITE_READY:begin
				 if(AMBA.WREADY) begin
					  if(NextCount == (AWlen+1))  AMBA.WLAST = 1'b1;
					  else  AMBA.WLAST = 1'b0;
                    
					  MWRITENext_state = MDWRITE_VALID;
				 end			
				 else MWRITENext_state = MWRITE_READY;	
			    end
	
	  MDWRITE_VALID:begin
                 AMBA.WVALID = '0;
                      
				 if(NextCount == AWlen+1) begin
					  MWRITENext_state = MWRITE_INIT;	
					  AMBA.WLAST='0;
				 end
				 else MWRITENext_state = MWRITE_TRANSFER;
				end
	  
      MWRITE_ERROR:begin
				 if(NextCount == (AWlen+1)) begin
					  AMBA.WLAST = 1'b1;
					  MWRITENext_state = MDWRITE_VALID;
				 end
				 else begin
					  AMBA.WLAST = 1'b0;
					  MWRITENext_state = MWRITE_TRANSFER;
				 end
			    end	
	endcase
end

///////////////////////////////////////FSM for Write Response Channel of Master\\\\\\\\\\\\\\\\\\\\\\\////////////

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
			 AMBA.BREADY = '0;
			 MASTERBNext_state = MASTERB_START;
			end		
            
  MASTERB_START:begin
			 if(AMBA.BVALID) begin
			  MASTERBNext_state = MASTERB_READY;	
			 end
			end
            
  MASTERB_READY:begin	
			  AMBA.BREADY = 1'b1;
			  MASTERBNext_state = MASTERB_IDLE;
			end
	endcase
end



//////////////////////////////////////////////FSM for Read Address Channel of Master \\\\\\\\\\\\\\\\\\\\\\\/////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//


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
             AMBA.ARID = 0;
             AMBA.ARADDR = 0;
             AMBA.ARLEN = 0;
             AMBA.ARSIZE = 0;
             AMBA.ARBURST = 0;
             AMBA.ARVALID = 0;
            ARMREADNext_state = MREAD_WAIT;
            end
            
  MREAD_WAIT:begin
            if(ARaddr > 32'h0) begin	
             AMBA.ARID = ARid;
             AMBA.ARADDR = ARaddr;
             AMBA.ARLEN = ARlen;
             AMBA.ARSIZE = ARsize;
             AMBA.ARBURST = ARburst;
             AMBA.ARVALID = 1'b1;
            ARMREADNext_state = MREAD_READY;
            end
            else
             ARMREADNext_state = MREAD_IDLE;
            end
            
 MREAD_READY:begin
            if (AMBA.ARREADY)
             ARMREADNext_state = MREAD_VALID;
            else 					
             ARMREADNext_state = MREAD_READY;
            end
            
 MREAD_VALID:begin
             AMBA.ARVALID = '0;
             if(AMBA.RLAST)
              ARMREADNext_state = MREAD_EXTRA;
             else
              ARMREADNext_state = MREAD_VALID;
            end	
            
 MREAD_EXTRA:begin
             ARMREADNext_state = MREAD_IDLE;
            end
        endcase
end


////////////////////////////////////////////////////////////////FSM for Read Data Channel of Master\\\\\\\\\\\\\\\\\\\\\\\\\\////////////////////


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
        if(AMBA.ARREADY)
            ARADDR_r = ARaddr;
  
        case(MREADState)
  MREAD_CLEAR:begin
                MREADNext_state  =  MREAD_STARTM;
                 AMBA.RREADY = '0;
                first_time1_next = 0;	
                slaveaddress = '0;
                slaveaddress_r='0;
            end
                
   MREAD_STARTM:begin
                if(AMBA.RVALID) begin
                    MREADNext_state = MREAD_READ;                    
                    slaveaddress = slaveaddress_r;
                end
                else
                    MREADNext_state =  MREAD_STARTM;	
            end
        
   MREAD_READ:begin
                MREADNext_state = MDREAD_VALID;
                AMBA.RREADY= '1; 
                
                case(ARburst)    ///Burst type - Fixed(00), Increment(01), Wrapping(10)
                  2'b00:begin  //fixed
                            slaveaddress = ARADDR_r;
                            case (ARsize)
                            3'b000: begin	
                                         read_memory[slaveaddress] =  AMBA.RDATA[7:0]; 
                                    end
                            3'b001: begin	
                                        read_memory[slaveaddress] =  AMBA.RDATA[7:0]; 
                                        read_memory[slaveaddress+1] =  AMBA.RDATA[15:8]; 		
                                    end
                            3'b010: begin	
                                        read_memory[slaveaddress] =  AMBA.RDATA[7:0];
                                        read_memory[slaveaddress+1] =  AMBA.RDATA[15:8];
                                        read_memory[slaveaddress+2] =  AMBA.RDATA[23:16];
                                        read_memory[slaveaddress+3] =  AMBA.RDATA[31:24];
                                    end
                            endcase
                        end
                                
                  2'b01:begin   ///Increment
                            if(first_time1 == 0) begin
                                slaveaddress = ARADDR_r;
                                first_time1_next = 1;
                            end	
                            else	
                                first_time1_next = first_time1;
                                
                            if(AMBA.RLAST == 1)
                                first_time1_next = 0;
                            else 
                                first_time1_next = first_time1;
                            
                            case (ARsize)
                            3'b000: begin	
                                        read_memory[slaveaddress] =  AMBA.RDATA[7:0];
                                    end
                            3'b001: begin	
                                        read_memory[slaveaddress] =  AMBA.RDATA[7:0];
                                        read_memory[slaveaddress+1] =  AMBA.RDATA[15:8];
                                        slaveaddress_r = slaveaddress + 2;	
                                    end
                            3'b010: begin	
                                        read_memory[slaveaddress] =  AMBA.RDATA[7:0];
                                        read_memory[slaveaddress+1] =  AMBA.RDATA[15:8];
                                        read_memory[slaveaddress+2] =  AMBA.RDATA[23:16];
                                        read_memory[slaveaddress+3] =  AMBA.RDATA[31:24];
                                        slaveaddress_r = slaveaddress + 4;
                                    end
                            endcase
                        end
                         2'b10:begin    //Wrapping type
                            if(first_time1 == 0) begin
                                slaveaddress =  ARADDR_r;
                                first_time1_next = 1;
                            end	
                            else 
                                first_time1_next = first_time1;
                        
                            if(AMBA.RLAST == 1)
                                first_time1_next = 0;
                            else 
                                first_time1_next = first_time1;
                                
                            case(ARlen)                       ///////////////Calculating the Wrapping Boundary based on the Length of the Burst and size of each transfer inside a burst.
                            4'b0001:begin        				///ARlen signal encoded as a 4bit vector each specifying a number of transfers in a burst
                                        case(ARsize)		/////////////////ARsize signal specifies Size of each transfer in bytes and encoded as a 3 bit vector with maximum data width constraints (Max 4bytes used here in the design)
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
                                            read_memory[slaveaddress] =  AMBA.RDATA[7:0];
                                            slaveaddress_temp = slaveaddress + 1;
                                            
                                            if(slaveaddress_temp % wrap_boundary == 0)
                                                slaveaddress_r = slaveaddress_temp - wrap_boundary;
                                            else		
                                                slaveaddress_r = slaveaddress_temp;	
                                        end
                                        
                                3'b001: begin	
                                            read_memory[slaveaddress] =  AMBA.RDATA[7:0];
                                            slaveaddress_temp = slaveaddress + 1;
                                            
                                            if(slaveaddress_temp % wrap_boundary == 0)
                                                slaveaddress_r = slaveaddress_temp - wrap_boundary;
                                            else
                                                slaveaddress_r = slaveaddress_temp;
                                                
                                            read_memory[slaveaddress_r] =  AMBA.RDATA[15:8];
                                            slaveaddress_temp = slaveaddress_r + 1;
                                            
                                            if(slaveaddress_temp % wrap_boundary == 0)
                                                slaveaddress_r = slaveaddress_temp - wrap_boundary;
                                            else
                                                slaveaddress_r = slaveaddress_temp;
                                        end
                                        
                                3'b010: begin	
                                            read_memory[slaveaddress] =  AMBA.RDATA[7:0];
                                            slaveaddress_temp = slaveaddress + 1;
                                            
                                            if(slaveaddress_temp % wrap_boundary == 0)
                                                slaveaddress_r = slaveaddress_temp - wrap_boundary;
                                            else
                                                slaveaddress_r = slaveaddress_temp;
                                                
                                            read_memory[slaveaddress_r] =  AMBA.RDATA[15:8];
                                            slaveaddress_temp = slaveaddress_r + 1;
                                            
                                            if(slaveaddress_temp % wrap_boundary == 0)
                                                slaveaddress_r = slaveaddress_temp - wrap_boundary;
                                            else
                                                slaveaddress_r = slaveaddress_temp;
                                                
                                            read_memory[slaveaddress_r] =  AMBA.RDATA[23:16];
                                            slaveaddress_temp = slaveaddress_r + 1;
                                            
                                            if(slaveaddress_temp % wrap_boundary == 0)
                                                slaveaddress_r = slaveaddress_temp - wrap_boundary;
                                            else
                                                slaveaddress_r = slaveaddress_temp;
                                                
                                            read_memory[slaveaddress_r] =  AMBA.RDATA[31:24];
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
                AMBA.RREADY = 1'b0;
                if(AMBA.RLAST) begin
                    $display("MASTER Memory= %p",read_memory);
                    MREADNext_state = MREAD_CLEAR;
                end
                else
                    MREADNext_state =  MREAD_STARTM;	
            end
        endcase
    end
endmodule		
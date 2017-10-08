//////////////////////////////////////////////////////////
//Module for the Axi3 interconnect protocol behaviour with various response signals from Slave's channels-
// 1.Write address channel 2.Write Data Channel 3. Write Response channel 4. Read Address channel 5.Read Data Channel
//Implementing the Axi3 protocol while interfacing with Slave
//Slave<->AXI fsm's 
//
///////////////////////////////////////////////////////////
module Slave_Axi3Protocol(
input	clock, reset,
axi.Slave AMBAS,

output logic [4095:0] [7:0] slave_memory);

//////////////////////enums for the states\\\\\\\\\\\\\\//
//Write address channel for Slave///
enum logic [1:0] { 
WSLAVE_IDLE=2'b00, 
WSLAVE_START, 
WSLAVE_READY } WRITEADDR_STATE, WRITEADDR_NEXTSTATE;


////////////Write Data Channel for slave\\\
logic [31:0]	AWADDR_r;
integer first_time, first_time_next2,wrap_boundary; 
logic [31:0] masteraddress, masteraddress_reg, masteraddress_temp;
enum logic [1:0]{
WSLAVE_INIT=2'b00, 
WDSLAVE_START, 
WDSLAVE_READY, 
WDSLAVE_VALID} WRITED_STATE, WRITED_NEXTSTATE;

/////////////////Write Response Channel for slave
enum logic [2:0] { 
RESPONSEB_IDLE=3'b000, 
RESPONSEB_LAST, 
RESPONSEB_START, 
RESPONSEB_WAIT, 
RESPONSEB_VALID } SLAVEB_STATE, SLAVEB_NEXTSTATE;


/////////////////Read Address Channel for Slave//
enum logic [1:0] {
RSLAVE_IDLE=2'b00, 
RSLAVE_WAIT, 
RSLAVE_READY} RSLAVE_STATE,RSLAVE_NEXTSTATE;

//////////////////Read Data Channel for Slave//
enum logic [2:0] {
RDSLAVE_CLEAR=3'b000, 
RDSLAVE_START, 
RDSLAVE_WAIT, 
RDSLAVE_VALID, 
RDSLAVE_ERROR } RDSLAVE_STATE, RDSLAVE_NEXTSTATE;
integer  first_time2, first_time2_next,wrap_boundary2;
logic [4:0] Counter, Next_Counter;
logic [31:0] ARADDR_r1, readdata_address,readdata_address_r, readdata_address_temp;


/////////////////////////////////////////////////////////////////////////////FSMs Slave channels with Axi Protocol implementing\\\\\\\\\\\\\\//////////////////////
///////////Assigning each channel w.r.t Axi interconnect signals(in Camel case) to the Slave's  output ports.
///////////////////////////FSM for -  Write Address Channel Slave\\\\\\\\\\\\\\\\\\\\\/////////////// 

always_ff @(posedge clock or negedge reset)	
begin	
	if(!reset)	begin
		WRITEADDR_STATE <= WSLAVE_IDLE;
	end
	else begin
		WRITEADDR_STATE <= WRITEADDR_NEXTSTATE;
	end	
end


always_comb	
begin	
	case(WRITEADDR_STATE)
  WSLAVE_IDLE:begin
                AMBAS.AWREADY = '0;
                WRITEADDR_NEXTSTATE = WSLAVE_START;
			end		
            
 WSLAVE_START:begin
				if(AMBAS.AWVALID) begin
                    WRITEADDR_NEXTSTATE = WSLAVE_READY;	
				end
				else
                    WRITEADDR_NEXTSTATE = WSLAVE_START;
			end
            
 WSLAVE_READY:begin	
                AMBAS.AWREADY = 1'b1;
				WRITEADDR_NEXTSTATE = WSLAVE_IDLE;
			end
	endcase
end


/////////////////////////////////////////FSM for Write Data Channel of Slave \\\\\\\\\\\\\/////////////////////////////////////


always_ff @(posedge clock or negedge reset)
begin
	if(!reset) begin
		WRITED_STATE <= WSLAVE_INIT;	
	end
	else begin
		WRITED_STATE <= WRITED_NEXTSTATE;
		first_time <= first_time_next2;
	end
end

always_comb
begin
	if(AMBAS.AWVALID == 1)
		AWADDR_r =  AMBAS.AWADDR; 	
	
    case(WRITED_STATE)
   WSLAVE_INIT:begin
                AMBAS.WREADY = 1'b0;
                WRITED_NEXTSTATE = WDSLAVE_START;
                first_time_next2 = 0;
                masteraddress_reg = '0;
                masteraddress = '0;
            end

  WDSLAVE_START:begin
                if(AMBAS.WVALID) begin
                    WRITED_NEXTSTATE = WDSLAVE_READY;
                    masteraddress = masteraddress_reg;
                end
                else begin
                    WRITED_NEXTSTATE = WDSLAVE_START;
                end
			end		
	
  WDSLAVE_READY:begin
				if(AMBAS.WLAST) begin
					WRITED_NEXTSTATE = WSLAVE_INIT;
				end
				else
                    WRITED_NEXTSTATE = WDSLAVE_VALID;
					AMBAS.WREADY = 1'b1;
                    
                unique case(AMBAS.AWBURST)
                  2'b00:begin
                            masteraddress = AWADDR_r;
                            
                            unique case (AMBAS.WSTRB)
                            4'b0001:begin	
                                        slave_memory[masteraddress] = AMBAS.WDATA[7:0];
                                    end
                                    
                            4'b0010:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA[15:8];
                                    end
                                    
                            4'b0100:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA[23:16];
                                    end
                                    
                            4'b1000:begin
                                        slave_memory[masteraddress] =  AMBAS.WDATA[31:24];
                                    end
                                    
                            4'b0011:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA[7:0];
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA[15:8];
                                    end
                                    
                            4'b0101:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA[7:0];											
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA[23:16];
                                    end
                                    
                            4'b1001:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA[7:0];											
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA[31:24];
                                    end
                                    
                            4'b0110:begin
                                        slave_memory[masteraddress] =  AMBAS.WDATA[15:0];												
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA[23:16];
                                    end
                                    
                            4'b1010:begin
                                        slave_memory[masteraddress] =  AMBAS.WDATA[15:8];										
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA[31:24];
                                    end
                                    
                            4'b1100:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA[23:16];
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA[31:24];
                                    end
                                    
                            4'b0111:begin										
                                        slave_memory[masteraddress] =  AMBAS.WDATA[7:0];
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA[15:8];											
                                        slave_memory[masteraddress+2] =  AMBAS.WDATA[23:16];
                                    end
                                    
                            4'b1110:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA[15:8];
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA[23:16];										
                                        slave_memory[masteraddress+2] =  AMBAS.WDATA[31:24];
                                    end
                                    
                            4'b1011:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA[7:0];
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA[15:8];											
                                        slave_memory[masteraddress+2] =  AMBAS.WDATA[31:24];
                                    end
                                    
                            4'b1101:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA[7:0];										
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA[23:16];											
                                        slave_memory[masteraddress+2] =  AMBAS.WDATA[31:24];
                                    end
                                    
                            4'b1111:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA[7:0];										
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA[15:8];										
                                        slave_memory[masteraddress+2] =  AMBAS.WDATA [23:16];										
                                        slave_memory[masteraddress+3] =  AMBAS.WDATA [31:24];
                                    end
                            default: begin
				end	

                                endcase
			end
									
                  2'b01:begin
                            if(first_time == 0) 
                            begin
                                masteraddress = AWADDR_r;
                                first_time_next2 = 1;
                            end	
                            else	
                                first_time_next2 = first_time;
                            
                            if(AMBAS.BREADY == 1)
                                first_time_next2 = 0;
                            else 
                                first_time_next2 = first_time;
                            
                            unique case (AMBAS.WSTRB)
                            4'b0001:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];
                                        masteraddress_reg = masteraddress + 1;				
                                    end
                                    
                            4'b0010:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [15:8];
                                        masteraddress_reg = masteraddress + 1;
                                    end
                                    
                            4'b0100:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [23:16];
                                        masteraddress_reg = masteraddress + 1;
                                    end
                                    
                            4'b1000:begin
                                        slave_memory[masteraddress] =  AMBAS.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 1;
                                    end
                                    
                            4'b0011:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];												
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA [15:8];
                                        masteraddress_reg = masteraddress + 2;
                                    end
                                    
                            4'b0101:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];										
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA [23:16];
                                        masteraddress_reg = masteraddress + 2;
                                    end
                                    
                            4'b1001:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];													
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 2;
                                    end
                                    
                            4'b0110:begin
                                        slave_memory[masteraddress] =  AMBAS.WDATA [15:0];													
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA [23:16];
                                        masteraddress_reg = masteraddress + 2;
                                    end
                                    
                            4'b1010:begin
                                        slave_memory[masteraddress] =  AMBAS.WDATA [15:8];											
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 2;
                                    end
                                    
                            4'b1100:begin
                                        slave_memory[masteraddress] =  AMBAS.WDATA [23:16];												
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 2;
                                    end
                                    
                            4'b0111:begin										
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];												
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA [15:8];												
                                        slave_memory[masteraddress+2] =  AMBAS.WDATA [23:16];
                                        masteraddress_reg = masteraddress + 3;
                                    end
                                    
                            4'b1110:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [15:8];												
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA [23:16];												
                                        slave_memory[masteraddress+2] =  AMBAS.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 3;
                                    end
                                    
                            4'b1011:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];												
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA [15:8];												
                                        slave_memory[masteraddress+2] =  AMBAS.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 3;
                                    end
                                    
                            4'b1101:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];												
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA [23:16];												
                                        slave_memory[masteraddress+2] =  AMBAS.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 3;
                                    end
                                    
                            4'b1111:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];												
                                        slave_memory[masteraddress+1] =  AMBAS.WDATA [15:8];													
                                        slave_memory[masteraddress+2] =  AMBAS.WDATA [23:16];													
                                        slave_memory[masteraddress+3] =  AMBAS.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 4;
                                    end
			    default: begin	end
                            endcase
                        end
			
 2'b10:begin
                            if(first_time == 0) begin
                                masteraddress = AWADDR_r;
                                first_time_next2 = 1;
                            end	
                            else 
                                first_time_next2 = first_time;								
                            if(AMBAS.BREADY == 1)
                                first_time_next2 = 0;
                            else 
                                first_time_next2 = first_time;
								
                            unique case(AMBAS.AWLEN)
							4'b0001:begin
                                        unique case(AMBAS.AWSIZE)
                                        3'b000: begin
                                                    wrap_boundary = 2 * 1; 
                                                end
                                        3'b001: begin
                                                    wrap_boundary = 2 * 2;																		
                                                end	
                                        3'b010: begin
                                                    wrap_boundary = 2 * 4;																		
                                                end
                                         default: begin end
                                        endcase			
                                    end
                                    
                            4'b0011:begin
                                        unique case(AMBAS.AWSIZE)
                                        3'b000: begin
                                                    wrap_boundary = 4 * 1;
                                                end
                                        3'b001: begin
                                                    wrap_boundary = 4 * 2;																		
                                                end	
                                        3'b010: begin
                                                    wrap_boundary = 4 * 4;																		
                                                end
                                        default: begin	end
                                        endcase			
                                    end
													
                            4'b0111:begin
                                        unique case(AMBAS.AWSIZE)
                                        3'b000: begin
                                                    wrap_boundary = 8 * 1;
                                                end
                                        3'b001: begin
                                                    wrap_boundary = 8 * 2;																		
                                                end	
                                        3'b010: begin
                                                    wrap_boundary = 8 * 4;																		
                                                end
                                        default: begin	end
                                        endcase			
                                    end	
											
                            4'b1111:begin
                                        unique case(AMBAS.AWSIZE)
                                        3'b000: begin
                                                    wrap_boundary = 16 * 1;
                                                    
                                                end
                                        3'b001: begin
                                                    wrap_boundary = 16 * 2;																		
                                                end	
                                        3'b010: begin
                                                    wrap_boundary = 16 * 4;																		
                                                end
                                        default: begin	end
                                        endcase			
                                    end
                            endcase						
										
                            unique case(AMBAS.WSTRB)    //Write strobe signal is encoded for writing different bit positions to the slave memory.
                            4'b0001:begin	    
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else		
                                            masteraddress_reg = masteraddress_temp;	
                                    end
                                    
                            4'b0010:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [15:8];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b0100:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [23:16];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b1000:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [31:24];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b0011:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                    
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                            
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [15:8];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b0101:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [23:16];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b1001:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [31:24];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b0110:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [15:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [23:16];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b1010:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [15:8];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary== 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [31:24];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b1100:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [23:16];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [31:24];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b0111:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [15:8];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [23:16];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b1110:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [15:8];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [23:16];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [31:24];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b1011:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [15:8];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [31:24];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                            4'b1101:begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [23:16];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [31:24];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b1111: begin	
                                        slave_memory[masteraddress] =  AMBAS.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [15:8];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [23:16];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  AMBAS.WDATA [31:24];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                            default: begin	end
                            endcase
                        end


						
                endcase
						$display("each beat Meme= %p",slave_memory);
						end
  WDSLAVE_VALID:begin
                AMBAS.WREADY = 1'b0;
				WRITED_NEXTSTATE = WDSLAVE_START;
				end
		endcase
end



///////////////////////////////////////FSM for Write Response Channel of Slave\\\\\\\\\\\\\\\\\\\\\\\////////////

always_ff @(posedge clock or negedge reset)	
begin	
	if(!reset)	begin
		SLAVEB_STATE <= RESPONSEB_IDLE;
	end
	else
		SLAVEB_STATE <= SLAVEB_NEXTSTATE;
end


always_comb 
begin
	case(SLAVEB_STATE)
   RESPONSEB_IDLE:begin
                AMBAS.BID = '0;
                AMBAS.BRESP = '0;
                AMBAS.BVALID = '0;
                SLAVEB_NEXTSTATE = RESPONSEB_LAST;
            end
            
   RESPONSEB_LAST:begin		
                if(AMBAS.WLAST)
                    SLAVEB_NEXTSTATE = RESPONSEB_START;
                else
                    SLAVEB_NEXTSTATE = RESPONSEB_LAST;
                end

  RESPONSEB_START:begin
                AMBAS.BID =  AMBAS.AWID;
                if ( AMBAS.AWADDR > 32'h5ff &&  AMBAS.AWADDR <=32'hfff &&  AMBAS.AWSIZE < 3'b011 )
                    AMBAS.BRESP = 2'b00;
                else if(( AMBAS.AWADDR > 32'h1ff &&  AMBAS.AWADDR <=32'h5ff) ||  AMBAS.AWSIZE > 3'b010)
                    AMBAS.BRESP = 2'b10;
                else 
                    AMBAS.BRESP = 2'b11;
                
                AMBAS.BVALID = 1'b1;
                SLAVEB_NEXTSTATE = RESPONSEB_WAIT;	
				end
                
   RESPONSEB_WAIT:begin	
				if (AMBAS.BREADY)	begin
					SLAVEB_NEXTSTATE = RESPONSEB_IDLE;
				end
			end
	endcase
end	




//////////////////////////////////////////////FSM for Read Address Channel of Slave \\\\\\\\\\\\\\\\\\\\\\\/////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//


always_ff @(posedge clock or negedge reset)
begin
	if (!reset)	begin
		RSLAVE_STATE <= RSLAVE_IDLE;
	end
	else	begin
		RSLAVE_STATE <= RSLAVE_NEXTSTATE;
	end
end	

always_comb
begin 	
     case (RSLAVE_STATE)
  RSLAVE_IDLE:begin
                AMBAS.ARREADY = '0;
                RSLAVE_NEXTSTATE = RSLAVE_WAIT;
            end
            
  RSLAVE_WAIT:begin
                if (AMBAS.ARVALID)
                    RSLAVE_NEXTSTATE = RSLAVE_READY;
                else
                    RSLAVE_NEXTSTATE = RSLAVE_WAIT;
            end
            
 RSLAVE_READY:begin
                RSLAVE_NEXTSTATE = RSLAVE_IDLE;
                AMBAS.ARREADY = 1'b1;
            end
    endcase
end



////////////////////////////////////////////////////////////////FSM for Read Data Channel of Slave\\\\\\\\\\\\\\\\\\\\\\\\\\////////////////////
    
    
always_ff@(posedge clock or negedge reset)
begin
    if(!reset) begin
        RDSLAVE_STATE    <= RDSLAVE_CLEAR;
        Counter     <= '0;
    end
    else begin
        RDSLAVE_STATE    <= RDSLAVE_NEXTSTATE;
        Counter     <= Next_Counter;
        first_time2 <= first_time2_next;
    end
end
        
always_comb
begin
    if(AMBAS.ARVALID)
        ARADDR_r1 =  AMBAS.ARADDR;	
        
    unique case(RDSLAVE_STATE)
  RDSLAVE_CLEAR:begin
                AMBAS.RID = '0;           
                AMBAS.RDATA = '0;         
                AMBAS.RRESP = '0;         
                AMBAS.RLAST = '0;         
                AMBAS.RVALID = '0; 
                first_time2_next = 0;
                Next_Counter = '0;
                readdata_address_r='0;
                readdata_address='0;
                if(AMBAS.ARVALID) begin
                    RDSLAVE_NEXTSTATE  = RDSLAVE_START;
                end
                else
                    RDSLAVE_NEXTSTATE = RDSLAVE_CLEAR;
            end
            
  RDSLAVE_START:begin
                if( AMBAS.ARADDR > 32'h1ff &&  AMBAS.ARADDR <=32'hfff &&  AMBAS.ARSIZE <3'b100) begin	
                    AMBAS.RID    =  AMBAS.ARID;
                    
                    unique case(AMBAS.ARBURST)		//Read Burst type- Fixed, increment, Wrapping
                      2'b00:begin					//Fixed(00)
                                readdata_address = ARADDR_r1;
                                unique case (AMBAS.ARSIZE)
                                 3'b000:begin	
                                             AMBAS.RDATA[7:0] = slave_memory[readdata_address];
                                        end
                                        
                                 3'b001:begin	
                                             AMBAS.RDATA[7:0] = slave_memory[readdata_address];
                                             AMBAS.RDATA[15:8] = slave_memory[readdata_address+1];		
                                        end
                                        
                                3'b010:begin	
                                             AMBAS.RDATA[7:0] = slave_memory[readdata_address];
                                             AMBAS.RDATA[15:8] = slave_memory[readdata_address+1];
                                             AMBAS.RDATA[23:16] = slave_memory[readdata_address+2];
                                             AMBAS.RDATA[31:24] = slave_memory[readdata_address+3];
                                        end
                                endcase
                            end
                                
                      2'b01:begin					//Increment(01)
                                if(first_time2 == 0) begin
                                    readdata_address = ARADDR_r1;
                                    first_time2_next = 1;
                                end	
                                else 
                                    first_time2_next = first_time2;	
                                    
                                if(Next_Counter ==  AMBAS.ARLEN+4'b1)				
                                    first_time2_next = 0;
                                else 
                                    first_time2_next = first_time2;
                                    
                                unique case (AMBAS.ARSIZE)
                                3'b000:begin	
                                             AMBAS.RDATA[7:0] = slave_memory[readdata_address];
                                        end
                                        
                                3'b001: begin	
                                             AMBAS.RDATA[7:0] = slave_memory[readdata_address];
                                             AMBAS.RDATA[15:8] = slave_memory[readdata_address+1];
                                            readdata_address_r = readdata_address + 2;
                                        end
                                3'b010: begin	
                                        AMBAS.RDATA[7:0] = slave_memory[readdata_address];
                                        AMBAS.RDATA[15:8] = slave_memory[readdata_address+1];
                                        AMBAS.RDATA[23:16] = slave_memory[readdata_address+1];
                                        AMBAS.RDATA[31:24] = slave_memory[readdata_address+1];
                                        readdata_address_r = readdata_address + 4;
                                        end
                                    endcase
                                end
                           2'b10:begin        //Wrapping (10)
                                if(first_time2 == 0) begin
                                    readdata_address = ARADDR_r1;
                                    first_time2_next = 1;
                                end	
                                else 
                                    first_time2_next = first_time2;
                                
                                if(Next_Counter ==  AMBAS.ARLEN+4'b1)				
                                    first_time2_next = 0;
                                else 
                                    first_time2_next = first_time2;
                                
                                unique case( AMBAS.ARLEN)
                                4'b0001:begin
                                            unique case( AMBAS.ARSIZE)
                                             3'b000:begin
                                                        wrap_boundary2 = 2 * 1; 
                                                    end
                                                    
                                             3'b001:begin
                                                        wrap_boundary2 = 2 * 2;																		
                                                    end	
                                                    
                                             3'b010:begin
                                                        wrap_boundary2 = 2 * 4;																		
                                                    end
                                             default: begin	end
                                            endcase			
                                        end
                                        
                                4'b0011:begin
                                            unique case(AMBAS.ARSIZE)
                                             3'b000:begin
                                                        wrap_boundary2 = 4 * 1;
                                                    end
                                                    
                                             3'b001:begin
                                                        wrap_boundary2 = 4 * 2;																		
                                                    end
                                                    
                                             3'b010:begin
                                                        wrap_boundary2 = 4 * 4;																		
                                                    end
                                             default: begin	end
                                            endcase			
                                        end
                                                
                                4'b0111:begin
                                            unique case(AMBAS.ARSIZE)
                                             3'b000:begin
                                                        wrap_boundary2 = 8 * 1;
                                                    end
                                                    
                                             3'b001:begin
                                                        wrap_boundary2 = 8 * 2;																		
                                                    end	
                                                    
                                             3'b010:begin
                                                        wrap_boundary2 = 8 * 4;																		
                                                    end
                                             default: begin	end
                                            endcase			
                                        end	
                                        
                                4'b1111:begin
                                            unique case(AMBAS.ARSIZE)
                                             3'b000:begin
                                                        wrap_boundary2 = 16 * 1;
                                                    end
                                                    
                                             3'b001:begin
                                                        wrap_boundary2 = 16 * 2;																		
                                                    end	
                                                    
                                             3'b010:begin
                                                        wrap_boundary2 = 16 * 4;																		
                                                    end
                                             default: begin	end
                                            endcase			
                                        end
                                endcase						
                                    
                                unique case(AMBAS.ARSIZE)
                                 3'b000:begin	    
                                            AMBAS.RDATA[7:0] = slave_memory[readdata_address];
                                            readdata_address_temp = readdata_address + 1;
                                            
                                            if(readdata_address_temp % wrap_boundary2 == 0)
                                                readdata_address_r = readdata_address_temp - wrap_boundary2;
                                            else		
                                                readdata_address_r = readdata_address_temp;	
                                        end
                                        
                                 3'b001:begin	
                                            AMBAS.RDATA[7:0] = slave_memory[readdata_address];
                                            readdata_address_temp = readdata_address + 1;
                                            
                                            if(readdata_address_temp % wrap_boundary2 == 0)
                                                readdata_address_r = readdata_address_temp - wrap_boundary2;
                                            else
                                                readdata_address_r = readdata_address_temp;
                                                
                                            AMBAS.RDATA[15:8] = slave_memory[readdata_address_r];
                                            readdata_address_temp = readdata_address_r + 1;
                                            
                                            if(readdata_address_temp % wrap_boundary2 == 0)
                                                readdata_address_r = readdata_address_temp - wrap_boundary2;
                                            else
                                                readdata_address_r = readdata_address_temp;
                                        end
                                        
                                 3'b010:begin	
                                            AMBAS.RDATA[7:0] = slave_memory[readdata_address];
                                            readdata_address_temp = readdata_address + 1;
                                            
                                            if(readdata_address_temp % wrap_boundary2 == 0)
                                                readdata_address_r = readdata_address_temp - wrap_boundary2;
                                            else
                                                readdata_address_r = readdata_address_temp;
                                            
                                            AMBAS.RDATA[15:8] = slave_memory[readdata_address_r];
                                            readdata_address_temp = readdata_address_r + 1;
                                            
                                            if(readdata_address_temp % wrap_boundary2 == 0)
                                                readdata_address_r = readdata_address_temp - wrap_boundary2;
                                            else
                                                readdata_address_r = readdata_address_temp;
                                                
                                            AMBAS.RDATA[23:16] = slave_memory[readdata_address_r];
                                            readdata_address_temp = readdata_address_r + 1;
                                            
                                            if(readdata_address_temp % wrap_boundary2 == 0)
                                                readdata_address_r = readdata_address_temp - wrap_boundary2;
                                            else
                                                readdata_address_r = readdata_address_temp;
                                                
                                            AMBAS.RDATA[31:24] = slave_memory[readdata_address_r];
                                            readdata_address_temp = readdata_address_r + 1;
                                            
                                            if(readdata_address_temp % wrap_boundary2 == 0)
                                                readdata_address_r = readdata_address_temp - wrap_boundary2;
                                            else
                                                readdata_address_r = readdata_address_temp;														
                                        end
                                    default: begin	end
                                endcase
                            end
                    endcase
                    
                   
                 
                  
                    
                    AMBAS.RVALID = '1; 
                    Next_Counter=Counter+4'b1;
                    RDSLAVE_NEXTSTATE = RDSLAVE_WAIT;
                    AMBAS.RRESP  = 2'b00;
                end
                
                else begin
                    if (AMBAS.ARSIZE >= 3'b011)				
                        AMBAS.RRESP = 2'b10; 
                    else 
                        AMBAS.RRESP = 2'b11; 
                        
                    Next_Counter=Counter+4'b1;
                    RDSLAVE_NEXTSTATE = RDSLAVE_ERROR;
                end	
            end
            
   RDSLAVE_WAIT:begin
                if(AMBAS.RREADY) begin
                    if(Next_Counter == AMBAS.ARLEN+4'b1) begin
                        AMBAS.RLAST = '1;
                    end
                    else 
                        AMBAS.RLAST = '0;
        
                RDSLAVE_NEXTSTATE = RDSLAVE_VALID;  
                end
                else begin
                    RDSLAVE_NEXTSTATE = RDSLAVE_WAIT;
                    end
            end    
            
  RDSLAVE_VALID:begin
                AMBAS.RVALID = '0;
                
                if (Next_Counter == AMBAS.ARLEN+4'b1) begin
                    RDSLAVE_NEXTSTATE =  RDSLAVE_CLEAR;
                    AMBAS.RLAST = '0;
                end
                else begin
                    readdata_address = readdata_address_r;
                    RDSLAVE_NEXTSTATE = RDSLAVE_START;
                end 
            end	

  RDSLAVE_ERROR:begin	
                if (Next_Counter ==  AMBAS.ARLEN+4'b1) begin
                    AMBAS.RLAST = '1;
                    RDSLAVE_NEXTSTATE =  RDSLAVE_VALID;
                end
                else begin
                    AMBAS.RLAST = '0;
                    RDSLAVE_NEXTSTATE = RDSLAVE_START;
                end	
            end	
    endcase
end
        
endmodule 
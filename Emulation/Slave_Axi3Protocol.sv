module AXI_Slave_emulation(
input	clock, reset,
AXI.slave slaveintf,
output logic		    AWVALID_tb_s,//inputs received from master
output logic	[1:0]	AWBURST_tb_s,
output logic	[2:0]	AWSIZE_tb_s,
output logic	[3:0]	AWLEN_tb_s,
output logic	[31:0]	AWADDR_tb_s,
output logic	[3:0]	AWID_tb_s,
output logic		WVALID_tb_s,
output logic		WLAST_tb_s,
output logic	[3:0]	WSTRB_tb_s,
output logic	[31:0]	WDATA_tb_s,
output logic	[3:0]	WID_tb_s,
output logic		BREADY_tb_s,
output logic	[3:0]	ARID_tb_s,
output logic	[31:0]	ARADDR_tb_s,
output logic	[3:0]	ARLEN_tb_s,
output logic	[2:0]	ARSIZE_tb_s,
output logic	[1:0]	ARBURST_tb_s,
output logic	ARVALID_tb_s,
output logic		RREADY_tb_s
);

logic [4095:0][7:0] slave_memory ;//instantiating a 2D array
//pragma attribute slave_mem ram_block 1        //for emulator
assign AWVALID_tb_s = slaveintf.AWVALID;//passing inputs from master to slave
assign AWBURST_tb_s = slaveintf.AWBURST;
assign AWSIZE_tb_s = slaveintf.AWSIZE;
assign AWLEN_tb_s = slaveintf.AWLEN;
assign AWADDR_tb_s = slaveintf.AWADDR;
assign AWID_tb_s = slaveintf.AWID;
assign WVALID_tb_s = slaveintf.WVALID;
assign WLAST_tb_s = slaveintf.WLAST;
assign WSTRB_tb_s = slaveintf.WSTRB;
assign WDATA_tb_s = slaveintf.WDATA;
assign WID_tb_s = slaveintf.WID;
assign BREADY_tb_s = slaveintf.BREADY;
assign ARID_tb_s = slaveintf.ARID;
assign ARADDR_tb_s = slaveintf.ARADDR;
assign ARLEN_tb_s = slaveintf.ARLEN;
assign ARSIZE_tb_s = slaveintf.ARSIZE;
assign ARBURST_tb_s = slaveintf.ARBURST;
assign ARVALID_tb_s = slaveintf.ARVALID;
assign RREADY_tb_s = slaveintf.RREADY;

//slave write address 
enum logic [1:0] { WSLAVE_IDLE=2'b00,
 WSLAVE_START,
 WSLAVE_READY } WRITEADDR_STATE, WRITEADDR_NEXTSTATE;
//slave write data 
logic [31:0]	AWADDR_r;
integer first_time, first_time_next2,wrap_boundary; 
logic [31:0] masteraddress, masteraddress_reg, masteraddress_temp;
enum logic [1:0]{WSLAVE_INIT=2'b00, 
WDSLAVE_START,
 WDSLAVE_READY,
 WDSLAVE_VALID} WRITED_STATE, WRITED_NEXTSTATE;
//slave write response
enum logic [2:0] { RESPONSEB_IDLE=3'b000,
 RESPONSEB_LAST,
 RESPONSEB_START,
 RESPONSEB_WAIT,
 RESPONSEB_VALID } SLAVEB_STATE, SLAVEB_NEXTSTATE;
//slave read address
enum logic [1:0] {RSLAVE_IDLE=2'b00,
 RSLAVE_WAIT, 
 RSLAVE_READY} RSLAVE_STATE,RSLAVE_NEXTSTATE;
//slave read data
enum logic [2:0] {RDSLAVE_CLEAR=3'b000, 
RDSLAVE_START,
 RDSLAVE_WAIT,
 RDSLAVE_VALID, 
 RDSLAVE_ERROR } RDSLAVE_STATE, RDSLAVE_NEXTSTATE;
integer  first_time2, first_time2_next,wrap_boundary2;
logic [4:0] Counter, Next_Counter;
logic [31:0] ARADDR_r1, readdata_address,readdata_address_r, readdata_address_temp;

//write address channel slave
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
                slaveintf.AWREADY = '0;
                WRITEADDR_NEXTSTATE = WSLAVE_START;
			end		
            
 WSLAVE_START:begin
				if(slaveintf.AWVALID) begin
                    WRITEADDR_NEXTSTATE = WSLAVE_READY;	
				end
				else
                    WRITEADDR_NEXTSTATE = WSLAVE_START;
			end
            
 WSLAVE_READY:begin	
                slaveintf.AWREADY = 1'b1;
				WRITEADDR_NEXTSTATE = WSLAVE_IDLE;
			end
	endcase
end



//slave write data channel


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
	if(slaveintf.AWVALID == 1)
		AWADDR_r =  slaveintf.AWADDR; 	
	
    case(WRITED_STATE)
   WSLAVE_INIT:begin
                slaveintf.WREADY = 1'b0;
                WRITED_NEXTSTATE = WDSLAVE_START;
                first_time_next2 = 0;
                masteraddress_reg = '0;
                masteraddress = '0;
            end

  WDSLAVE_START:begin
                if(slaveintf.WVALID) begin
                    WRITED_NEXTSTATE = WDSLAVE_READY;
                    masteraddress = masteraddress_reg;
                end
                else begin
                    WRITED_NEXTSTATE = WDSLAVE_START;
                end
			end		
	
  WDSLAVE_READY:begin
				if(slaveintf.WLAST) begin
					WRITED_NEXTSTATE = WSLAVE_INIT;
				end
				else
                    WRITED_NEXTSTATE = WDSLAVE_VALID;
					slaveintf.WREADY = 1'b1;
                    
                 case(slaveintf.AWBURST)
                  2'b00:begin
                            masteraddress = AWADDR_r;
                            
                             case (slaveintf.WSTRB)
                            4'b0001:begin	
                                        slave_memory[masteraddress] = slaveintf.WDATA[7:0];
                                    end
                                    
                            4'b0010:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA[15:8];
                                    end
                                    
                            4'b0100:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA[23:16];
                                    end
                                    
                            4'b1000:begin
                                        slave_memory[masteraddress] =  slaveintf.WDATA[31:24];
                                    end
                                    
                            4'b0011:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA[7:0];
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA[15:8];
                                    end
                                    
                            4'b0101:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA[7:0];											
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA[23:16];
                                    end
                                    
                            4'b1001:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA[7:0];											
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA[31:24];
                                    end
                                    
                            4'b0110:begin
                                        slave_memory[masteraddress] =  slaveintf.WDATA[15:0];												
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA[23:16];
                                    end
                                    
                            4'b1010:begin
                                        slave_memory[masteraddress] =  slaveintf.WDATA[15:8];										
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA[31:24];
                                    end
                                    
                            4'b1100:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA[23:16];
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA[31:24];
                                    end
                                    
                            4'b0111:begin										
                                        slave_memory[masteraddress] =  slaveintf.WDATA[7:0];
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA[15:8];											
                                        slave_memory[masteraddress+2] =  slaveintf.WDATA[23:16];
                                    end
                                    
                            4'b1110:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA[15:8];
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA[23:16];										
                                        slave_memory[masteraddress+2] =  slaveintf.WDATA[31:24];
                                    end
                                    
                            4'b1011:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA[7:0];
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA[15:8];											
                                        slave_memory[masteraddress+2] =  slaveintf.WDATA[31:24];
                                    end
                                    
                            4'b1101:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA[7:0];										
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA[23:16];											
                                        slave_memory[masteraddress+2] =  slaveintf.WDATA[31:24];
                                    end
                                    
                            4'b1111:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA[7:0];										
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA[15:8];										
                                        slave_memory[masteraddress+2] =  slaveintf.WDATA [23:16];										
                                        slave_memory[masteraddress+3] =  slaveintf.WDATA [31:24];
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
                            
                            if(slaveintf.BREADY == 1)
                                first_time_next2 = 0;
                            else 
                                first_time_next2 = first_time;
                            
                             case (slaveintf.WSTRB)
                            4'b0001:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];
                                        masteraddress_reg = masteraddress + 1;				
                                    end
                                    
                            4'b0010:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [15:8];
                                        masteraddress_reg = masteraddress + 1;
                                    end
                                    
                            4'b0100:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [23:16];
                                        masteraddress_reg = masteraddress + 1;
                                    end
                                    
                            4'b1000:begin
                                        slave_memory[masteraddress] =  slaveintf.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 1;
                                    end
                                    
                            4'b0011:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];												
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA [15:8];
                                        masteraddress_reg = masteraddress + 2;
                                    end
                                    
                            4'b0101:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];										
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA [23:16];
                                        masteraddress_reg = masteraddress + 2;
                                    end
                                    
                            4'b1001:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];													
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 2;
                                    end
                                    
                            4'b0110:begin
                                        slave_memory[masteraddress] =  slaveintf.WDATA [15:0];													
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA [23:16];
                                        masteraddress_reg = masteraddress + 2;
                                    end
                                    
                            4'b1010:begin
                                        slave_memory[masteraddress] =  slaveintf.WDATA [15:8];											
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 2;
                                    end
                                    
                            4'b1100:begin
                                        slave_memory[masteraddress] =  slaveintf.WDATA [23:16];												
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 2;
                                    end
                                    
                            4'b0111:begin										
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];												
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA [15:8];												
                                        slave_memory[masteraddress+2] =  slaveintf.WDATA [23:16];
                                        masteraddress_reg = masteraddress + 3;
                                    end
                                    
                            4'b1110:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [15:8];												
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA [23:16];												
                                        slave_memory[masteraddress+2] =  slaveintf.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 3;
                                    end
                                    
                            4'b1011:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];												
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA [15:8];												
                                        slave_memory[masteraddress+2] =  slaveintf.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 3;
                                    end
                                    
                            4'b1101:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];												
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA [23:16];												
                                        slave_memory[masteraddress+2] =  slaveintf.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 3;
                                    end
                                    
                            4'b1111:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];												
                                        slave_memory[masteraddress+1] =  slaveintf.WDATA [15:8];													
                                        slave_memory[masteraddress+2] =  slaveintf.WDATA [23:16];													
                                        slave_memory[masteraddress+3] =  slaveintf.WDATA [31:24];
                                        masteraddress_reg = masteraddress + 4;
                                    end
			    
                            endcase
                        end
			
 2'b10:begin
                            if(first_time == 0) begin
                                masteraddress = AWADDR_r;
                                first_time_next2 = 1;
                            end	
                            else 
                                first_time_next2 = first_time;								
                            if(slaveintf.BREADY == 1)
                                first_time_next2 = 0;
                            else 
                                first_time_next2 = first_time;
								
                             case(slaveintf.AWLEN)
							4'b0001:begin
                                         case(slaveintf.AWSIZE)
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
                                    
                            4'b0011:begin
                                         case(slaveintf.AWSIZE)
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
                                         case(slaveintf.AWSIZE)
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
											
                            4'b1111:begin
                                        case(slaveintf.AWSIZE)
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
										
                             case(slaveintf.WSTRB)
                            4'b0001:begin	    
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else		
                                            masteraddress_reg = masteraddress_temp;	
                                    end
                                    
                            4'b0010:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [15:8];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b0100:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [23:16];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b1000:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [31:24];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b0011:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                    
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                            
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [15:8];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b0101:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [23:16];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b1001:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [31:24];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b0110:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [15:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [23:16];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b1010:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [15:8];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary== 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [31:24];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b1100:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [23:16];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [31:24];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b0111:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [15:8];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [23:16];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b1110:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [15:8];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [23:16];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [31:24];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b1011:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [15:8];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [31:24];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                            4'b1101:begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [23:16];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [31:24];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                                    
                            4'b1111: begin	
                                        slave_memory[masteraddress] =  slaveintf.WDATA [7:0];
                                        masteraddress_temp = masteraddress + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [15:8];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [23:16];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                        
                                        slave_memory[masteraddress_reg] =  slaveintf.WDATA [31:24];
                                        masteraddress_temp = masteraddress_reg + 1;
                                        
                                        if(masteraddress_temp % wrap_boundary == 0)
                                            masteraddress_reg = masteraddress_temp - wrap_boundary;
                                        else
                                            masteraddress_reg = masteraddress_temp;
                                    end
                            
                            endcase
                        end


						
                endcase
						//$display("each beat Meme= %p",slave_memory);
						end
  WDSLAVE_VALID:begin
                slaveintf.WREADY = 1'b0;
				WRITED_NEXTSTATE = WDSLAVE_START;
				end
		endcase
end

//slave write response channel

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
                slaveintf.BID = '0;
                slaveintf.BRESP = '0;
                slaveintf.BVALID = '0;
                SLAVEB_NEXTSTATE = RESPONSEB_LAST;
            end
            
   RESPONSEB_LAST:begin		
                if(slaveintf.WLAST)
                    SLAVEB_NEXTSTATE = RESPONSEB_START;
                else
                    SLAVEB_NEXTSTATE = RESPONSEB_LAST;
                end

  RESPONSEB_START:begin
                slaveintf.BID =  slaveintf.AWID;
                if ( slaveintf.AWADDR > 32'h5ff &&  slaveintf.AWADDR <=32'hfff &&  slaveintf.AWSIZE < 3'b011 )
                    slaveintf.BRESP = 2'b00;
                else if(( slaveintf.AWADDR > 32'h1ff &&  slaveintf.AWADDR <=32'h5ff) ||  slaveintf.AWSIZE > 3'b010)
                    slaveintf.BRESP = 2'b10;
                else 
                    slaveintf.BRESP = 2'b11;
                
                slaveintf.BVALID = 1'b1;
                SLAVEB_NEXTSTATE = RESPONSEB_WAIT;	
				end
                
   RESPONSEB_WAIT:begin	
				if (slaveintf.BREADY)	begin
					SLAVEB_NEXTSTATE = RESPONSEB_IDLE;
				end
			end
	endcase
end	




//read address channel slave


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
                slaveintf.ARREADY = '0;
                RSLAVE_NEXTSTATE = RSLAVE_WAIT;
            end
            
  RSLAVE_WAIT:begin
                if (slaveintf.ARVALID)
                    RSLAVE_NEXTSTATE = RSLAVE_READY;
                else
                    RSLAVE_NEXTSTATE = RSLAVE_WAIT;
            end
            
 RSLAVE_READY:begin
                RSLAVE_NEXTSTATE = RSLAVE_IDLE;
                slaveintf.ARREADY = 1'b1;
            end
    endcase
end



//slave read data channel    
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
    if(slaveintf.ARVALID)
        ARADDR_r1 =  slaveintf.ARADDR;	
        
    case(RDSLAVE_STATE)
  RDSLAVE_CLEAR:begin
                slaveintf.RID = '0;           
                slaveintf.RDATA = '0;         
                slaveintf.RRESP = '0;         
                slaveintf.RLAST = '0;         
                slaveintf.RVALID = '0; 
                first_time2_next = 0;
                Next_Counter = '0;
                readdata_address_r='0;
                readdata_address='0;
                if(slaveintf.ARVALID) begin
                    RDSLAVE_NEXTSTATE  = RDSLAVE_START;
                end
                else
                    RDSLAVE_NEXTSTATE = RDSLAVE_CLEAR;
            end
            
  RDSLAVE_START:begin
                if( slaveintf.ARADDR > 32'h1ff &&  slaveintf.ARADDR <=32'hfff &&  slaveintf.ARSIZE <3'b100) begin	
                    slaveintf.RID    =  slaveintf.ARID;
                    
                    case(slaveintf.ARBURST)
                      2'b00:begin
                                readdata_address = ARADDR_r1;
                                 case (slaveintf.ARSIZE)
                                 3'b000:begin	
                                             slaveintf.RDATA[7:0] = slave_memory[readdata_address];
                                        end
                                        
                                 3'b001:begin	
                                             slaveintf.RDATA[7:0] = slave_memory[readdata_address];
                                             slaveintf.RDATA[15:8] = slave_memory[readdata_address+1];		
                                        end
                                        
                                3'b010:begin	
                                             slaveintf.RDATA[7:0] = slave_memory[readdata_address];
                                             slaveintf.RDATA[15:8] = slave_memory[readdata_address+1];
                                             slaveintf.RDATA[23:16] = slave_memory[readdata_address+2];
                                             slaveintf.RDATA[31:24] = slave_memory[readdata_address+3];
                                        end
                                endcase
                            end
                                
                      2'b01:begin
                                if(first_time2 == 0) begin
                                    readdata_address = ARADDR_r1;
                                    first_time2_next = 1;
                                end	
                                else 
                                    first_time2_next = first_time2;	
                                    
                                if(Next_Counter ==  slaveintf.ARLEN+4'b1)				
                                    first_time2_next = 0;
                                else 
                                    first_time2_next = first_time2;
                                    
                                 case (slaveintf.ARSIZE)
                                3'b000:begin	
                                             slaveintf.RDATA[7:0] = slave_memory[readdata_address];
                                        end
                                        
                                3'b001: begin	
                                             slaveintf.RDATA[7:0] = slave_memory[readdata_address];
                                             slaveintf.RDATA[15:8] = slave_memory[readdata_address+1];
                                            readdata_address_r = readdata_address + 2;
                                        end
                                3'b010: begin	
                                        slaveintf.RDATA[7:0] = slave_memory[readdata_address];
                                        slaveintf.RDATA[15:8] = slave_memory[readdata_address+1];
                                        slaveintf.RDATA[23:16] = slave_memory[readdata_address+1];
                                        slaveintf.RDATA[31:24] = slave_memory[readdata_address+1];
                                        readdata_address_r = readdata_address + 4;
                                        end
                                    endcase
                                end
                           2'b10:begin
                                if(first_time2 == 0) begin
                                    readdata_address = ARADDR_r1;
                                    first_time2_next = 1;
                                end	
                                else 
                                    first_time2_next = first_time2;
                                
                                if(Next_Counter ==  slaveintf.ARLEN+4'b1)				
                                    first_time2_next = 0;
                                else 
                                    first_time2_next = first_time2;
                                
                                 case( slaveintf.ARLEN)
                                4'b0001:begin
                                             case( slaveintf.ARSIZE)
                                             3'b000:begin
                                                        wrap_boundary2 = 2 * 1; 
                                                    end
                                                    
                                             3'b001:begin
                                                        wrap_boundary2 = 2 * 2;																		
                                                    end	
                                                    
                                             3'b010:begin
                                                        wrap_boundary2 = 2 * 4;																		
                                                    end
                                             
                                            endcase			
                                        end
                                        
                                4'b0011:begin
                                            case(slaveintf.ARSIZE)
                                             3'b000:begin
                                                        wrap_boundary2 = 4 * 1;
                                                    end
                                                    
                                             3'b001:begin
                                                        wrap_boundary2 = 4 * 2;																		
                                                    end
                                                    
                                             3'b010:begin
                                                        wrap_boundary2 = 4 * 4;																		
                                                    end
                                             
                                            endcase			
                                        end
                                                
                                4'b0111:begin
                                             case(slaveintf.ARSIZE)
                                             3'b000:begin
                                                        wrap_boundary2 = 8 * 1;
                                                    end
                                                    
                                             3'b001:begin
                                                        wrap_boundary2 = 8 * 2;																		
                                                    end	
                                                    
                                             3'b010:begin
                                                        wrap_boundary2 = 8 * 4;																		
                                                    end
                                             
                                            endcase			
                                        end	
                                        
                                4'b1111:begin
                                            case(slaveintf.ARSIZE)
                                             3'b000:begin
                                                        wrap_boundary2 = 16 * 1;
                                                    end
                                                    
                                             3'b001:begin
                                                        wrap_boundary2 = 16 * 2;																		
                                                    end	
                                                    
                                             3'b010:begin
                                                        wrap_boundary2 = 16 * 4;																		
                                                    end
                                                                                         endcase			
                                        end
                                endcase						
                                    
                                case(slaveintf.ARSIZE)
                                 3'b000:begin	    
                                            slaveintf.RDATA[7:0] = slave_memory[readdata_address];
                                            readdata_address_temp = readdata_address + 1;
                                            
                                            if(readdata_address_temp % wrap_boundary2 == 0)
                                                readdata_address_r = readdata_address_temp - wrap_boundary2;
                                            else		
                                                readdata_address_r = readdata_address_temp;	
                                        end
                                        
                                 3'b001:begin	
                                            slaveintf.RDATA[7:0] = slave_memory[readdata_address];
                                            readdata_address_temp = readdata_address + 1;
                                            
                                            if(readdata_address_temp % wrap_boundary2 == 0)
                                                readdata_address_r = readdata_address_temp - wrap_boundary2;
                                            else
                                                readdata_address_r = readdata_address_temp;
                                                
                                            slaveintf.RDATA[15:8] = slave_memory[readdata_address_r];
                                            readdata_address_temp = readdata_address_r + 1;
                                            
                                            if(readdata_address_temp % wrap_boundary2 == 0)
                                                readdata_address_r = readdata_address_temp - wrap_boundary2;
                                            else
                                                readdata_address_r = readdata_address_temp;
                                        end
                                        
                                 3'b010:begin	
                                            slaveintf.RDATA[7:0] = slave_memory[readdata_address];
                                            readdata_address_temp = readdata_address + 1;
                                            
                                            if(readdata_address_temp % wrap_boundary2 == 0)
                                                readdata_address_r = readdata_address_temp - wrap_boundary2;
                                            else
                                                readdata_address_r = readdata_address_temp;
                                            
                                            slaveintf.RDATA[15:8] = slave_memory[readdata_address_r];
                                            readdata_address_temp = readdata_address_r + 1;
                                            
                                            if(readdata_address_temp % wrap_boundary2 == 0)
                                                readdata_address_r = readdata_address_temp - wrap_boundary2;
                                            else
                                                readdata_address_r = readdata_address_temp;
                                                
                                            slaveintf.RDATA[23:16] = slave_memory[readdata_address_r];
                                            readdata_address_temp = readdata_address_r + 1;
                                            
                                            if(readdata_address_temp % wrap_boundary2 == 0)
                                                readdata_address_r = readdata_address_temp - wrap_boundary2;
                                            else
                                                readdata_address_r = readdata_address_temp;
                                                
                                            slaveintf.RDATA[31:24] = slave_memory[readdata_address_r];
                                            readdata_address_temp = readdata_address_r + 1;
                                            
                                            if(readdata_address_temp % wrap_boundary2 == 0)
                                                readdata_address_r = readdata_address_temp - wrap_boundary2;
                                            else
                                                readdata_address_r = readdata_address_temp;														
                                        end
                                    
                                endcase
                            end
                    endcase
                    
                   
                 
                  
                    
                    slaveintf.RVALID = '1; 
                    Next_Counter=Counter+4'b1;
                    RDSLAVE_NEXTSTATE = RDSLAVE_WAIT;
                    slaveintf.RRESP  = 2'b00;
                end
                
                else begin
                    if (slaveintf.ARSIZE >= 3'b011)				
                        slaveintf.RRESP = 2'b10; 
                    else 
                        slaveintf.RRESP = 2'b11; 
                        
                    Next_Counter=Counter+4'b1;
                    RDSLAVE_NEXTSTATE = RDSLAVE_ERROR;
                end	
            end
            
   RDSLAVE_WAIT:begin
                if(slaveintf.RREADY) begin
                    if(Next_Counter == slaveintf.ARLEN+4'b1) begin
                        slaveintf.RLAST = '1;
                    end
                    else 
                        slaveintf.RLAST = '0;
        
                RDSLAVE_NEXTSTATE = RDSLAVE_VALID;  
                end
                else begin
                    RDSLAVE_NEXTSTATE = RDSLAVE_WAIT;
                    end
            end    
            
  RDSLAVE_VALID:begin
                slaveintf.RVALID = '0;
                
                if (Next_Counter == slaveintf.ARLEN+4'b1) begin
                    RDSLAVE_NEXTSTATE =  RDSLAVE_CLEAR;
                    slaveintf.RLAST = '0;
                end
                else begin
                    readdata_address = readdata_address_r;
                    RDSLAVE_NEXTSTATE = RDSLAVE_START;
                end 
            end	

  RDSLAVE_ERROR:begin	
                if (Next_Counter ==  slaveintf.ARLEN+4'b1) begin
                    slaveintf.RLAST = '1;
                    RDSLAVE_NEXTSTATE =  RDSLAVE_VALID;
                end
                else begin
                    slaveintf.RLAST = '0;
                    RDSLAVE_NEXTSTATE = RDSLAVE_START;
                end	
            end	
    endcase
end
        
endmodule
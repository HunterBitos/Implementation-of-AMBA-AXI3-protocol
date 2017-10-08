
`ifndef drvr_sv
`define drvr_sv


class DRVI;									//Creating a class for generating random signals which are passed to the driver for performing different type of transactions.
rand 	bit	[3:0]	rand_awid;				//Random write address id generating
rand 	bit	[31:0]	rand_awaddr_valid;		//Random Valid Write Address generating with Constraint S1 
constraint S1{								//
	rand_awaddr_valid > 32'h5ff;			//
	rand_awaddr_valid <=32'hfff;			//
		}
rand	bit	[31:0]	rand_awaddr_readonly;	//Random Read-only address with Constraint S2
constraint S2{
	rand_awaddr_readonly > 32'h1ff;
	rand_awaddr_readonly <= 32'h5ff;
		}
rand	bit	[31:0]	rand_awaddr_invalid;	//Random InValid write address with Constraint S3
constraint S3{
	rand_awaddr_invalid <= 32'h1ff;
		}
rand	bit	[31:0]	rand_wdata;				//Random write data generating. 32bit  used
rand	bit	[31:0]	rand_araddr_valid;		// Random Valid read address with Constraint S4
constraint S4{
	rand_araddr_valid > 32'h1ff;
	rand_araddr_valid <= 32'hfff;
		}
rand	bit	[31:0]	rand_araddr_invalid;	// Random InValid read address with Constraint S5
constraint S5{
	rand_araddr_invalid <= 32'h1ff;
		}
rand 	bit	[3:0]	rand_arid;				//Random read address id generating
	
endclass


class driver;						//Driver class 

	DRVI val=new();                //creating an instance of  the driver stimulus class
	virtual axi intf;				//instance of MasterSlaveAxiInterface
	
	function new(virtual axi intf);
		this.intf = intf;			//assigning to the driver class member intf
	endfunction

	int	status;						//status variable used for randomize status
		
	logic [3:0] STRB = '0;
	logic [3:0] p;
	int i,n;
	bit [1:0] b,x;
	bit [2:0] k,y;
	bit [3:0] j,l,z,s;
	task stimulus;                  //creating a task for passing the stimulus -randomly assigned signals while performing testing.
		output bit [3:0]	rand_awid;
		output bit [31:0]	rand_awaddr_valid;
		output bit [31:0]	rand_awaddr_invalid;
		output bit [31:0]	rand_awaddr_readonly;
		output bit [31:0]	rand_wdata;
		output bit [31:0]	rand_araddr_valid;
		output bit [31:0]	rand_araddr_invalid;
		output bit [3:0]	rand_arid;
						
		DRVI val					= 	new();
		status 					= 	val.randomize();
		rand_awid				=	val.rand_awid;
		rand_awaddr_valid		=	val.rand_awaddr_valid;
		rand_awaddr_invalid		=	val.rand_awaddr_invalid;
		rand_awaddr_readonly	=	val.rand_awaddr_readonly;
		rand_wdata		=	val.rand_wdata;
		rand_araddr_valid		=	val.rand_araddr_valid;
		rand_araddr_invalid		=	val.rand_araddr_invalid;
		rand_arid				=	val.rand_arid;
	
		$display("\nInside Driver:-");        
	endtask
	



	task reset_enable;					//Reset task - used for clearing all signals-active low reset used.
		top.reset   		=	1'b0;
		intf.AWREADY		=	'0; 
		intf.AWVALID		=	'0;
		intf.AWBURST		=	'0;
		intf.AWSIZE		=	'0;
		intf.AWLEN		=	'0;
		intf.AWADDR		=	'0;
		intf.AWID		=	'0;
		intf.WREADY		=	'0;
		intf.WVALID		=	'0;
		intf.WLAST		=	'0;
		intf.WSTRB		=	'0;
		intf.WDATA		=	'0;
		intf.WID		=	'0;
		intf.BID		=	'0;	
		intf.BRESP		=	'0;
		intf.BVALID		=	'0;
		intf.BREADY		=	'0;
		intf.ARREADY		=	'0;
		intf.ARID		=	'0;
		intf.ARADDR		=	'0;	
		intf.ARLEN		=	'0;
		intf.ARSIZE		=	'0;
		intf.ARBURST		=	'0;
		intf.ARVALID		=	'0;
		intf.RID		=	'0;
		intf.RDATA		=	'0;
		intf.RRESP		=	'0;
		intf.RLAST		=	'0;
		intf.RVALID		=	'0;
		intf.RREADY		=	'0;
		top.AWaddr	=	'0;
		top.AWid	=	'0;
		top.AWsize	=	'0;
		top.AWlen	=	'0;	
		top.WStrb	=	'0;
		top.AWburst	=	'0;
		top.WData	=	'0;
		top.ARid	=	'0;	
		top.ARaddr	=	'0;
		top.ARlen	=	'0;
		top.ARsize	=	'0;
		top.ARburst	=	'0;
		#10;
		top.reset		=	1'b1;		
	endtask
	


///////////////////////////////////////////////////////////Tasks for Performing the Burst Read , Write Operations-\\//////////////////////////////////////
	
	
	

/////////////////////////////////// 1. Task for 'Alternate write and read transactions' /////////////////////////////////////////////////////////////////////

task burst_write_read(input bit [3:0] rand_awid, input bit [31:0] rand_awaddr_valid, input bit [31:0] rand_awaddr_invalid, input bit [31:0] rand_awaddr_readonly, input bit [31:0] rand_wdata,  input bit [31:0] rand_araddr_valid, input bit [31:0] rand_araddr_invalid, input bit [3:0] rand_arid );

for(b=2'b10;b<2'b11;b++) begin
				stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);
				top.AWid 	=	rand_awid;
				top.AWaddr 	=	32'hddd; //Valid write address;
				top.AWburst	=	top.AWburst + b;
				top.AWsize	=	3'b010;
				top.AWlen	=	4'b0011;
				top.WStrb	=	4'b1111;		
				for(i='0;i<=top.AWlen;i=i+4'b1)
					begin
					wait(intf.WVALID)
					stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);
					top.WData  = rand_wdata;
					wait(!intf.WVALID);
					end
					wait(intf.BREADY)
				repeat(2) @(posedge top.clock);
                           
				stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);
				top.AWid 	=	rand_awid;
				top.ARid	=	rand_arid;	
				top.AWaddr 	=	32'hccc;    //rand_awaddr_valid;
				top.ARaddr	=	32'hddd;    //rand_araddr_valid;
				top.AWburst	=	top.AWburst + b;
				top.ARburst	=	top.ARburst + b;
				top.AWsize	=	3'b010;
				top.ARsize	=	3'b010;
				top.AWlen	=	4'b0011;
				top.ARlen	=	4'b0011;	
				top.WStrb	=	4'b1111;
				for(i='0;i<=top.AWlen;i=i+4'b1) begin
				wait(intf.WVALID)
				stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);
				top.WData  = rand_wdata;
				wait(!intf.WVALID);
				end
				wait(intf.BREADY)
				repeat(2) @(posedge top.clock);
			

			

				stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);
				top.AWid 	=	rand_awid;
				top.ARid	=	rand_arid;	
				top.AWaddr 	=	32'hbbb;//valid write address
				top.ARaddr	=	32'hccc;//valid read address
				top.AWburst	=	top.AWburst + b;
				top.ARburst	=	top.ARburst + b;
				top.AWsize	=	3'b010;
				top.ARsize	=	3'b010;
				top.AWlen	=	4'b0011;
				top.ARlen	=	4'b0011;	
				top.WStrb	=	4'b1111;
				for(i='0;i<=top.AWlen;i=i+4'b1) begin
				wait(intf.WVALID)
				stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);
				top.WData  = rand_wdata;
				wait(!intf.WVALID);
				end//i_for
				wait(intf.BREADY)
				repeat(2) @(posedge top.clock);
				


				stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);
				top.AWid 	=	rand_awid;
				top.ARid	=	rand_arid;	
				top.AWaddr 	=	32'haaa;//valid write address
				top.ARaddr	=	32'hbbb;//valid read address
				top.AWburst	=	top.AWburst + b;
				top.ARburst	=	top.ARburst + b;
				top.AWsize	=	3'b010;
				top.ARsize	=	3'b010;
				top.AWlen	=	4'b0011;
				top.ARlen	=	4'b0011;	
				top.WStrb	=	4'b1111;
				for(i='0;i<=top.AWlen;i=i+4'b1) begin
				wait(intf.WVALID)
				stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);
				top.WData  = rand_wdata;
				wait(!intf.WVALID);
				end//i_for
				wait(intf.BREADY)
				repeat(2) @(posedge top.clock);
				
			
				stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);
				top.AWid 	=	rand_awid;
				top.ARid	=	rand_arid;	
				top.AWaddr 	=	32'h999;//Valid write address
				top.ARaddr	=	32'haaa;//Valid read address
				top.AWburst	=	top.AWburst + b;
				top.ARburst	=	top.ARburst + b;
				top.AWsize	=	3'b010;
				top.ARsize	=	3'b010;
				top.AWlen	=	4'b0011;
				top.ARlen	=	4'b0011;	
				top.WStrb	=	4'b1111;
				for(i='0;i<=top.AWlen;i=i+4'b1) begin
				wait(intf.WVALID)
				stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);
				top.WData  = rand_wdata;
				wait(!intf.WVALID);
				end
				wait(intf.BREADY)
				repeat(2) @(posedge top.clock);	
		
			end
endtask	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
////////////////////////////////2. Valid Read Operation ///////////////////////////////////////////////////////

task burst_read(input bit [3:0] rand_awid, input bit [31:0] rand_awaddr_valid, input bit [31:0] rand_awaddr_invalid, input bit [31:0] rand_awaddr_readonly, input bit [31:0] rand_wdata,  input bit [31:0] rand_araddr_valid, input bit [31:0] rand_araddr_invalid, input bit [3:0] rand_arid );


for(x='0;x<2'b11;x++) begin
	for(y='0;y<=3'b010;y++) begin
		if(x!=2'b10) begin	
		for(z='0;z<=4'b1111;z++) begin
		stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);	
			top.ARid	=	4'b1;//id
			top.ARaddr	=	32'ha11;// Valid Write address
			top.ARburst	=	top.ARburst + x;
			top.ARsize	=	top.ARsize + y;
			top.ARlen	=	top.ARlen + z;	
			wait (intf.RLAST)
			repeat(3) @(posedge top.clock);
		end
		end
		else 
		begin
		for(p=4'b1;p<=4'b0100;p++) 
			begin
			l=((2**(p))-1);	
			stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);	
			top.ARid	=	4'b1;//id 	
			top.ARaddr	=	32'ha11;// Valid Read address
			top.ARburst	=	top.ARburst + x;
			top.ARsize	=	top.ARsize + y;
			top.ARlen	=	top.ARlen + l;	
			wait (intf.RLAST)
			repeat(3) @(posedge top.clock);
			end
		end
	end
end	

endtask


///////////////////////////////// 3.Writing to a read only location //////////////////////////////////////////////////

task burst_write_readonly(input bit [3:0] rand_awid, input bit [31:0] rand_awaddr_valid, input bit [31:0] rand_awaddr_invalid, input bit [31:0] rand_awaddr_readonly, input bit [31:0] rand_wdata,  input bit [31:0] rand_araddr_valid, input bit [31:0] rand_araddr_invalid, input bit [3:0] rand_arid );

for(n=0;n<10;n++) begin
	for(b=2'b00;b<2'b11;b++) begin
			stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);
				top.AWid 		=	rand_awid;
				top.AWaddr 	=	rand_awaddr_readonly;
				top.AWburst	=	top.AWburst + b;
				top.AWsize	=	3'b010;
				top.AWlen	=	4'b0011;
				top.WStrb	=	4'b1111;		
				for(i='0;i<=top.AWlen;i=i+4'b1) 
				begin
				
				stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);
				top.WData  = rand_wdata;

				end
				wait(intf.BREADY)
				repeat(2) @(posedge top.clock);
	end
end	
endtask



///////////////////////////////////4. Writing to invalid address   //////////////////////////////////////////////////////

task burst_write_invalid(input bit [3:0] rand_awid, input bit [31:0] rand_awaddr_valid, input bit [31:0] rand_awaddr_invalid, input bit [31:0] rand_awaddr_readonly, input bit [31:0] rand_wdata,  input bit [31:0] rand_araddr_valid, input bit [31:0] rand_araddr_invalid, input bit [3:0] rand_arid );

for(n=0;n<10;n++) begin
	for(b=2'b00;b<2'b11;b++) begin
			stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);
				top.AWid 		=	rand_awid;
				top.AWaddr 	=	rand_awaddr_invalid;
				top.AWburst	=	top.AWburst + b;
				top.AWsize	=	3'b010;
				top.AWlen	=	4'b0011;
				top.WStrb	=	4'b1111;		
				for(i='0;i<=top.AWlen;i=i+4'b1) 
				begin
				
				stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);
				top.WData  = rand_wdata;

				end
				wait(intf.BREADY)
				repeat(2) @(posedge top.clock);
	end
end	
endtask



/////////////////////////////// 5.Reading from invalid address  /////////////////////////////////////////////////////////////////

task burst_read_invalid(input bit [3:0] rand_awid, input bit [31:0] rand_awaddr_valid, input bit [31:0] rand_awaddr_invalid, input bit [31:0] rand_awaddr_readonly, input bit [31:0] rand_wdata,  input bit [31:0] rand_araddr_valid, input bit [31:0] rand_araddr_invalid, input bit [3:0] rand_arid );

for(n=0;n<10;n++) begin      
for(x='0;x<2'b11;x++) begin  //for each burst type
		stimulus(rand_awid,rand_awaddr_valid,rand_awaddr_invalid,rand_awaddr_readonly,rand_wdata,rand_araddr_valid,rand_araddr_invalid,rand_arid);	
		top.ARid	=	rand_arid;	
		top.ARaddr	=	rand_araddr_invalid;
		top.ARburst	=	top.ARburst + x;
		top.ARsize	=	3'b010;
		top.ARlen	=	4'b0011;	
		wait (intf.RLAST)
		repeat(3) @(posedge top.clock);
	end
end

endtask




		
endclass
`endif		
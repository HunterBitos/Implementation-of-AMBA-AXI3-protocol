configure -emul velocesolo1
reg setvalue AXI_design_emulation.reset 1'b0
run 2
reg setvalue AXI_design_emulation.reset 1'b1     
run 10
reg setvalue AXI_design_emulation.AWid 4'b1
reg setvalue AXI_design_emulation.AWaddr 32'haaa
reg setvalue AXI_design_emulation.AWlen 4'd3
reg setvalue AXI_design_emulation.AWsize 3'b010
reg setvalue AXI_design_emulation.AWburst 2'b00
reg setvalue AXI_design_emulation.WStrb 4'b1111
run 2
reg setvalue AXI_design_emulation.WData 32'h0000aaaa
run 3
reg setvalue AXI_design_emulation.WData 32'h1111eeee
run 3
reg setvalue AXI_design_emulation.WData 32'h23232323
run 3
reg setvalue AXI_design_emulation.WData 32'haaaaaaaa
run 4
reg setvalue AXI_design_emulation.AWid 4'b0
reg setvalue AXI_design_emulation.AWaddr 32'h000
reg setvalue AXI_design_emulation.AWlen 4'b0
reg setvalue AXI_design_emulation.AWsize 3'b000
reg setvalue AXI_design_emulation.AWburst 2'b00
run 10
reg setvalue AXI_design_emulation.AWid 4'b0010           
reg setvalue AXI_design_emulation.ARid 4'b1011
reg setvalue AXI_design_emulation.ARaddr 32'haaa
reg setvalue AXI_design_emulation.AWaddr 32'h999
reg setvalue AXI_design_emulation.AWlen 4'd3
reg setvalue AXI_design_emulation.AWsize 3'b010
reg setvalue AXI_design_emulation.AWburst 2'b00
reg setvalue AXI_design_emulation.ARburst 2'b00
reg setvalue AXI_design_emulation.ARsize 3'b010
reg setvalue AXI_design_emulation.ARlen 4'd3
reg setvalue AXI_design_emulation.WStrb 4'b1111
run 2
reg setvalue AXI_design_emulation.WData 32'h01234567
run 3
reg setvalue AXI_design_emulation.WData 32'h09090909
run 3
reg setvalue AXI_design_emulation.WData 32'habababab
run 3
reg setvalue AXI_design_emulation.WData 32'h55667788
run 4
reg setvalue AXI_design_emulation.AWid 4'b0
reg setvalue AXI_design_emulation.AWaddr 32'd0
reg setvalue AXI_design_emulation.AWlen 4'b0
reg setvalue AXI_design_emulation.AWsize 3'b000
reg setvalue AXI_design_emulation.AWburst 2'b00
reg setvalue AXI_design_emulation.ARid 4'b0
reg setvalue AXI_design_emulation.ARaddr 32'd0
reg setvalue AXI_design_emulation.ARlen 4'b0
reg setvalue AXI_design_emulation.ARsize 3'b000
reg setvalue AXI_design_emulation.ARburst 2'b00
run 10


reg setvalue AXI_design_emulation.AWid 4'b0110           
reg setvalue AXI_design_emulation.ARid 4'b1010
reg setvalue AXI_design_emulation.ARaddr 32'h999
reg setvalue AXI_design_emulation.AWaddr 32'he32
reg setvalue AXI_design_emulation.AWlen 4'd2
reg setvalue AXI_design_emulation.AWsize 3'b000
reg setvalue AXI_design_emulation.AWburst 2'b01
reg setvalue AXI_design_emulation.ARburst 2'b00
reg setvalue AXI_design_emulation.ARsize 3'b010
reg setvalue AXI_design_emulation.ARlen 4'd3
reg setvalue AXI_design_emulation.WStrb 4'b0100
run 2
reg setvalue AXI_design_emulation.WData 32'h01234567
run 3
reg setvalue AXI_design_emulation.WData 32'h09090909
run 3
reg setvalue AXI_design_emulation.WData 32'habababab
run 4
reg setvalue AXI_design_emulation.AWid 4'b0
reg setvalue AXI_design_emulation.AWaddr 32'd0
reg setvalue AXI_design_emulation.AWlen 4'b0
reg setvalue AXI_design_emulation.AWsize 3'b000
reg setvalue AXI_design_emulation.AWburst 2'b00
reg setvalue AXI_design_emulation.ARid 4'b0
reg setvalue AXI_design_emulation.ARaddr 32'd0
reg setvalue AXI_design_emulation.ARlen 4'b0
reg setvalue AXI_design_emulation.ARsize 3'b000
reg setvalue AXI_design_emulation.ARburst 2'b00
run 10

reg setvalue AXI_design_emulation.AWid 4'b0101           
reg setvalue AXI_design_emulation.ARid 4'b1100
reg setvalue AXI_design_emulation.ARaddr 32'he32
reg setvalue AXI_design_emulation.AWaddr 32'hbab
reg setvalue AXI_design_emulation.AWlen 4'd0
reg setvalue AXI_design_emulation.AWsize 3'b000
reg setvalue AXI_design_emulation.AWburst 2'b00
reg setvalue AXI_design_emulation.ARburst 2'b01
reg setvalue AXI_design_emulation.ARsize 3'b000
reg setvalue AXI_design_emulation.ARlen 4'd2
reg setvalue AXI_design_emulation.WStrb 4'b0100
run 2
reg setvalue AXI_design_emulation.WData 32'h01234567
run 4
reg setvalue AXI_design_emulation.AWid 4'b0
reg setvalue AXI_design_emulation.AWaddr 32'd0
reg setvalue AXI_design_emulation.AWlen 4'b0
reg setvalue AXI_design_emulation.AWsize 3'b000
reg setvalue AXI_design_emulation.AWburst 2'b00
reg setvalue AXI_design_emulation.ARid 4'b0
reg setvalue AXI_design_emulation.ARaddr 32'd0
reg setvalue AXI_design_emulation.ARlen 4'b0
reg setvalue AXI_design_emulation.ARsize 3'b000
reg setvalue AXI_design_emulation.ARburst 2'b00
run 10


reg setvalue AXI_design_emulation.AWid 4'b0110           
reg setvalue AXI_design_emulation.ARid 4'b0010
reg setvalue AXI_design_emulation.AWaddr 32'haaa
reg setvalue AXI_design_emulation.AWlen 4'd7
reg setvalue AXI_design_emulation.AWsize 3'b010
reg setvalue AXI_design_emulation.AWburst 2'b10
reg setvalue AXI_design_emulation.WStrb 4'b1111
run 2
reg setvalue AXI_design_emulation.WData 32'hcccccdda
run 3
reg setvalue AXI_design_emulation.WData 32'h01020304
run 3
reg setvalue AXI_design_emulation.WData 32'h77668855
run 3
reg setvalue AXI_design_emulation.WData 32'h49354367
run 3
reg setvalue AXI_design_emulation.WData 32'h34567899
run 3
reg setvalue AXI_design_emulation.WData 32'h11111111
run 3
reg setvalue AXI_design_emulation.WData 32'h23456765
run 3
reg setvalue AXI_design_emulation.WData 32'h11111556
run 4
reg setvalue AXI_design_emulation.AWid 4'b0
reg setvalue AXI_design_emulation.AWaddr 32'd1
reg setvalue AXI_design_emulation.AWlen 4'b0
reg setvalue AXI_design_emulation.AWsize 3'b000
reg setvalue AXI_design_emulation.AWburst 2'b00
reg setvalue AXI_design_emulation.ARid 4'b0
reg setvalue AXI_design_emulation.ARaddr 32'd1
reg setvalue AXI_design_emulation.ARlen 4'b0
reg setvalue AXI_design_emulation.ARsize 3'b000
reg setvalue AXI_design_emulation.ARburst 2'b00
run 10

reg setvalue AXI_design_emulation.AWid 4'b0111           
reg setvalue AXI_design_emulation.ARid 4'b1110
reg setvalue AXI_design_emulation.ARaddr 32'haaa
reg setvalue AXI_design_emulation.AWaddr 32'hcac
reg setvalue AXI_design_emulation.AWlen 4'd0
reg setvalue AXI_design_emulation.AWsize 3'b000
reg setvalue AXI_design_emulation.AWburst 2'b00
reg setvalue AXI_design_emulation.ARburst 2'b10
reg setvalue AXI_design_emulation.ARsize 3'b010
reg setvalue AXI_design_emulation.ARlen 4'd7
reg setvalue AXI_design_emulation.WStrb 4'b0001
run 2
reg setvalue AXI_design_emulation.WData 32'h01234567
run 4
reg setvalue AXI_design_emulation.AWid 4'b0
reg setvalue AXI_design_emulation.AWaddr 32'd1
reg setvalue AXI_design_emulation.AWlen 4'b0
reg setvalue AXI_design_emulation.AWsize 3'b000
reg setvalue AXI_design_emulation.AWburst 2'b00
reg setvalue AXI_design_emulation.ARid 4'b0
reg setvalue AXI_design_emulation.ARaddr 32'd1
reg setvalue AXI_design_emulation.ARlen 4'b0
reg setvalue AXI_design_emulation.ARsize 3'b000
reg setvalue AXI_design_emulation.ARburst 2'b00
run 10
upload -tracedir ./veloce.wave/wave1
exit 

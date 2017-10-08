Aim of the Project: IMPLEMENTATION OF INTERFACE USING AMBA AXI3 BUS PROTOCOL
-The folder consists of the files for Questa Simulator and Veloce Emulator. 
-Standalone mode of emulation was being implemented.

AXI_Questa Folder: 
This contains files to be run on QuestaSIM 
	
1)Master_Axi3Protocol.sv
2)Slave_Axi3Protocol.sv
3)MasterSlaveAxiInterface.sv
4)Top_HVL.sv
5)Top_HDL.sv
6)assertions.sv
7)driver.sv
8)monitor.sv
9)VE.sv
10)testcase.sv

Simulation steps:

1) Extract the contents of .zip file.
2) Create a new project in Questasim.
3) Add the files from AXI_Questa directory to the project.
4) Select Compile all 
 FOR SIMULATION:( We commented out all the test cases except alternative Write and Read. The waveforms that get generated on the GUI window has the initial address that is manually given in the Driver module)
6) Right click on the testbench file(top.sv) and select the Simulate option.
7) Now Right click on the top file (top) and intf and select AddWave option.
8) The Wave window opens and all the signals are added to the wave.
9) Hit the runall option.

[or]

1)Extract the contents of .zip file.
2)open questa and goto FILE and click on Change Directory .Navigate to the ECE571_FinalProject/AXI_QUESTA folder.
3)Now type the command "do run.do" in the transcript.
The run file has commands for compiling and simulating.Also wave gets added.




Emulation Folder:
This contains files to be run on Emulator

1)MasterSlaveAxiInterface.sv
2)Master_Axi3Protocol.sv
3)Slave_Axi3Protocol.sv
4)Top_HDL.sv
5)Makefile
6)run.do
7)veloce.config
8)view.do	

Emulation steps:
1) Copy files into veloce login
2) In the terminal navigate to the directory where the files are present,and enter "make" command.
3) If you want to give other inputs and verify the design, make changes in run.do (As mentioned above, standalone mode is implemented where the inputs are manually given through a text file)
4) Add all the input output signals in the timing setup while setting the clock.
5) Check the outputs and verify them manually.
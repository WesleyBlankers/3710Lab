`timescale 1ns/1ps

module cpu_tb;

reg clk;
reg reset;

wire [15:0] R15Out;

cpu #(
		.ADDR_WIDTH(10),
		.DATA_WIDTH(16),
		.MEM_FILE("../src/RI_Type_Instructions.mem")
	)uut(
		.clk(clk),
		.reset(reset),
		.R15Out(R15Out)
	);
		
always #5 clk = ~clk; //10ns period

initial begin
		clk = 0;			
		reset = 1;

		#20;									//hold for 2 clock cycles
		reset = 0;							//disable reset
		
		wait (uut.RegisterEnables[15] == 1'b1); //wait until R15 write is enabled
		@(posedge clk);					//register write on positive clock edge
		@(negedge clk);					//read updated value on negative clock edge
		
		
		//Display final result
		if (R15Out === 16'd3) 			//if R15 equals the expected result -->hardcoded to 3 (Change according to expected value)
		
				$display("PASS: R15 = %0d", R15Out);
		else
				$display("FAIL: R15 = %0d", R15Out);
		
		$finish;
	end
endmodule
		


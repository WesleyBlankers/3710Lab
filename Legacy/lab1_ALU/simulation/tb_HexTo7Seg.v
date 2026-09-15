/*
	A typical structure of testbenches is:
		- Define registers that can be manually altered to simulate various circuit inputs.
		- Define wires to act like the outputs driven by the circuit.
		- initialize any other variables/memory before you instantiate the uut.
		- Instantiate the module you're testing, called the unit under test (uut), using your register and wire inputs and outputs.
		- Initialize all input values.
		- while(there are still cases to test)
			- Alter the current inputs so they cover a new test case.
			- Wait some amount of time for the changes to be captured before you try observing them.
			- Using the display() function to observe the outputs caused by the new inputs.
			- Wait again for the results to be observed before you allow any inputs to be changed again.
*/
module tb_HexTo7Seg;
	
	// input
	reg [3:0] test_input;
	
	// output
	wire [6:0] test_output;
	
	// Internal data
	integer i;
	reg [6:0] expected_output;
	
	// When instantiating submodules, the format of parameters is ".name_of_inside_variable(name_of_outside_variable)"
	HexTo7Seg uut(.hex_input(test_input), .segment_display(test_output));
	
	initial begin
		for (i = 0; i < 16; i = i + 1) begin
			
			test_input = i;
			#5;
			
			// Determine the expected output
			case (test_input)
				4'h0: expected_output = ~7'b0111111; // 0
				4'h1: expected_output = ~7'b0000110; // 1
				4'h2: expected_output = ~7'b1011011; // 2
				4'h3: expected_output = ~7'b1001111; // 3
				4'h4: expected_output = ~7'b1100110; // 4
				4'h5: expected_output = ~7'b1101101; // 5
				4'h6: expected_output = ~7'b1111101; // 6
				4'h7: expected_output = ~7'b0000111; // 7
				4'h8: expected_output = ~7'b1111111; // 8
				4'h9: expected_output = ~7'b1101111; // 9
				4'hA: expected_output = ~7'b1110111; // A
				4'hB: expected_output = ~7'b1111100; // b
				4'hC: expected_output = ~7'b1011000; // c
				4'hD: expected_output = ~7'b1011110; // d
				4'hE: expected_output = ~7'b1111001; // E
				4'hF: expected_output = ~7'b1110001; // F
			endcase
			
			// Self-check
			if (test_output === expected_output) begin
				$display("PASS: input = %x, output = %b", test_input, test_output);
			end
			else begin
				$display("FAIL: input = %x, expected = %b, got = %b",
						 test_input, expected_output, test_output);
			end
			
		end
		
	end
	
	
endmodule
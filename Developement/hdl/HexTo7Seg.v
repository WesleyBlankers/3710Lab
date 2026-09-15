/*
	Uses the 7-segment display lights on the MAX10 to indicate the number counted by four slide switches.
*/

module HexTo7Seg(
	input [3:0] hex_input,
	output reg [6:0] segment_display
);

	
	always@(*) begin
	// "always@(*)" (using a *) means "be sensitive to all dependant variables".
	// If you only want to be sensitive to some inputs or variables then specify which ones rather than using "*".
	// for example: "always@(hex_input[1])" will trigger all code in the always block any time the second least significant bit of hex_input is changed.
		
		// The seven-segment lights on your board are "active low" (hense the use of the negation symbol "~").
		// See page 25 in the user manual to see what "active low" mean. The push buttons on your FPGA are also active low.
		case (hex_input)
			4'h0: segment_display = ~7'b0111111; // 0
			4'h1: segment_display = ~7'b0000110; // 1
			4'h2: segment_display = ~7'b1011011; // 2
			4'h3: segment_display = ~7'b1001111; // 3
			4'h4: segment_display = ~7'b1100110; // 4
			4'h5: segment_display = ~7'b1101101; // 5
			4'h6: segment_display = ~7'b1111101; // 6
			4'h7: segment_display = ~7'b0000111; // 7
			4'h8: segment_display = ~7'b1111111; // 8
			4'h9: segment_display = ~7'b1101111; // 9
			4'hA: segment_display = ~7'b1110111; // A
			4'hB: segment_display = ~7'b1111100; // b
			4'hC: segment_display = ~7'b1011000; // c
			4'hD: segment_display = ~7'b1011110; // d
			4'hE: segment_display = ~7'b1111001; // E
			4'hF: segment_display = ~7'b1110001; // F
			default: segment_display = ~7'b0000000; // all lights off
		endcase
	end
endmodule

/*

PIN ASSIGNMENTS for the Cyclone V (ECE 3710) board:

	Inputs:
		hex_input[0]	-	PIN_AB12
		hex_input[1]	-	PIN_AC12
		hex_input[2]	-	PIN_AF9
		hex_input[3]	-	PIN_AF10
	
	Outputs:
		seven_seg[0]	-	PIN_AE26
		seven_seg[1]	-	PIN_AE27
		seven_seg[2]	-	PIN_AE28
		seven_seg[3]	-	PIN_AG27
		seven_seg[4]	-	PIN_AF28
		seven_seg[5]	-	PIN_AG28
		seven_seg[6]	-	PIN_AH28


PIN ASSIGNMENTS for the DE-10 (ECE 3700) board:

	Inputs:
		hex_input[0]	-	PIN_C10
		hex_input[1]	-	PIN_C11
		hex_input[2]	-	PIN_D12
		hex_input[3]	-	PIN_C12
	
	Outputs:
		seven_seg[0]	-	PIN_C14
		seven_seg[1]	-	PIN_E15
		seven_seg[2]	-	PIN_C15
		seven_seg[3]	-	PIN_C16
		seven_seg[4]	-	PIN_E16
		seven_seg[5]	-	PIN_D17
		seven_seg[6]	-	PIN_C17

*/
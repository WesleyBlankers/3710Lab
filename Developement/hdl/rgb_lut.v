module rgb_lut(
	input wire [7:0] color_index,
	output reg [23:0] rgb_value
	;
	
	//TODO: Fill in rgb values we will be using.
	
	always @(color_index) begin
		case(color_index)
		   00000000: rgb_value = //
			00000001: rgb_value = //
			00000010: rgb_value = //
			00000011: rgb_value = //
			00000100: rgb_value = //
			00000101: rgb_value = //
			00000110: rgb_value = //
			00000111: rgb_value = //
			00001000: rgb_value = //
			00001001: rgb_value = //
			00001010: rgb_value = //
			00001011: rgb_value = //
			00001100: rgb_value = //
			00001101: rgb_value = //
			00001110: rgb_value = //
			00001111: rgb_value = //
			00010000: rgb_value = //
			00010001: rgb_value = //
			00010010: rgb_value = //
			00010011: rgb_value = //
			00010100: rgb_value = //
			00010101: rgb_value = //
			00010110: rgb_value = //
			00010111: rgb_value = //
			
			default: //bg color
		
		endcase
	end
end module
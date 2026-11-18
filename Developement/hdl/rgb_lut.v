module rgb_lut(
	input wire [7:0] color_index,
	output reg [23:0] rgb_value
	);
	
	//TODO: Fill in rgb values we will be using.
	
	always @(color_index) begin
		case(color_index)
		   8'd00: rgb_value = //
			8'd01: rgb_value = //
			8'd02: rgb_value = //
			8'd03: rgb_value = //
			8'd04: rgb_value = //
			8'd05: rgb_value = //
			8'd06: rgb_value = //
			8'd07: rgb_value = //
			8'd08: rgb_value = //
			8'd09: rgb_value = //
			8'd10: rgb_value = //
			8'd11: rgb_value = //
			8'd12: rgb_value = //
			8'd13: rgb_value = //
			8'd14: rgb_value = //
			8'd15: rgb_value = //
			8'd16: rgb_value = //
			8'd17: rgb_value = //
			8'd18: rgb_value = //
			8'd19: rgb_value = //
			8'd20: rgb_value = //
			8'd21: rgb_value = //
			8'd22: rgb_value = //
			8'd23: rgb_value = //
			
			default: //bg color
		
		endcase
	end
endmodule
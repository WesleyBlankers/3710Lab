module glyph_renderer
( 	
		input wire vga_blank_n,
		input wire [9:0] hcount,
		input wire [9:0] vcount,
		input wire [7:0] pixel_color_index,
		output reg [23:0] rgb
);
		
		wire [23:0] lut_rgb;
		
		//instantiate LUT
		rgb_lut lut (
				.color_index(pixel_color_index),
				.rgb_value(lut_rgb)
		);
		
		//Outputs RGB color when display is active, otherwise output is black
		always @(*) begin
			if (vga_blank_n) begin
				rgb = lut_rgb;
			end
			else begin
				rgb = 24'h000000;
			end
		end
endmodule
module hard_coded_bitgen (
    input wire vga_blank_n,
    input wire [9:0] hcount,
    input wire [9:0] vcount,
    input wire [9:0] block_x_offset,
    output [23:0] rgb
);

    // Display is 640x480
    // Static green rectangle in the top half of the screen, centered.
    // Moving red block in the bottom half of the screen, from left to right.

    reg [7:0] r, g, b;
    assign rgb = {r, g, b};

    wire [9:0] x_pos, y_pos;
	 assign x_pos = hcount - 10'd144;
	 assign y_pos = vcount - 10'd35;

    always @(*) begin // Tip: @(*) prevents accidental sensitivity list bugs
        {r, g, b} = 24'd0;
        if (vga_blank_n) begin
            // Draws a moving red block (160x160) in the bottom half
            if ((x_pos >= block_x_offset) && (x_pos < 160 + block_x_offset) && (y_pos >= (240 + 40) && (y_pos < (480 - 40)))) begin
                r = 8'd255;
            end
            // Draws a static green rectangle (320x160), horizontally centered.
            else if ((x_pos >= 160) && (x_pos < 480) && (y_pos >= (0 + 40)) && (y_pos < (240-40))) begin
                g = 8'd255;
            end
            // Background (White)
            else begin
                r = 8'd255;
                g = 8'd255;
                b = 8'd255;
            end
        end
    end

endmodule

// Top-Level Module for VGA Demo
// Connects the clock divider, VGA controller, block mover,
// and pixel generator to produce the VGA display output.

module hard_coded_vga
(
    input wire clk,
    input wire rst,

    output wire VGA_CLK,
    output wire VGA_BLANK_N,
    output wire VGA_VS,
    output wire VGA_HS,

    output wire [7:0] VGA_R,
    output wire [7:0] VGA_G,
    output wire [7:0] VGA_B
);

// Internal signals
wire vga_clk;

wire vga_hs;
wire vga_vs;
wire vga_blank_n;

wire [9:0] hcount;
wire [9:0] vcount;

wire [9:0] block_x_offset;

wire [7:0] r;
wire [7:0] g;
wire [7:0] b;


// ---------------------------------------------------------
// Clock Divider
// Divides the input clock to generate the pixel clock
// used by the VGA controller and graphics modules.
// ---------------------------------------------------------

clk_divider clk_div
(
    .clk(clk),
    .rst(rst),
    .div_clk(vga_clk)
);


// ---------------------------------------------------------
// VGA Controller
// Generates horizontal and vertical synchronization
// signals and maintains the current pixel coordinates
// (hcount and vcount) for the VGA display.
// ---------------------------------------------------------

vga_controller vga_ctrl
(
    .vga_clk(vga_clk),
    .rst(rst),

    .vga_hs(vga_hs),
    .vga_vs(vga_vs),
    .vga_blank_n(vga_blank_n),

    .hcount(hcount),
    .vcount(vcount)
);


// ---------------------------------------------------------
// Block Mover
// Controls the horizontal position of the displayed
// block by generating its current X-coordinate offset.
// ---------------------------------------------------------

block_mover block_mov
(
    .vga_clk(vga_clk),
    .rst(rst),

    .block_x_offset(block_x_offset)
);


// ---------------------------------------------------------
// Hard-Coded Bit Generator
// Determines the RGB color of each pixel based on the
// current VGA coordinates, blanking signal, and block
// position. Generates the red, green, and blue channels.
// ---------------------------------------------------------

hard_coded_bitgen blockgen_inst
(
    .vga_blank_n(vga_blank_n),

    .hcount(hcount),
    .vcount(vcount),

    .block_x_offset(block_x_offset),

    .rgb({r, g, b})
);


// ---------------------------------------------------------
// VGA Output Assignments
// Connects internal signals to the top-level VGA ports.
// ---------------------------------------------------------

assign VGA_CLK     = vga_clk;

assign VGA_HS      = vga_hs;
assign VGA_VS      = vga_vs;
assign VGA_BLANK_N = vga_blank_n;

assign VGA_R = r;
assign VGA_G = g;
assign VGA_B = b;

endmodule

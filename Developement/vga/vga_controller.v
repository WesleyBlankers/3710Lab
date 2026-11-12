
module vga_controller (
    input wire vga_clk,
    input wire rst,

    output wire vga_hs,
    output wire vga_vs,
    output wire vga_blank_n,

    output reg [9:0] hcount,
    output reg [9:0] vcount
);

// ---------------------------------------------------------
// VGA Timing Parameters (640 x 480 @ approximately 60 Hz)
// ---------------------------------------------------------

parameter H_SYNC        = 10'd96;
parameter H_BACK_PORCH  = 10'd48;
parameter H_DISPLAY     = 10'd640;
parameter H_FRONT_PORCH = 10'd16;
parameter H_TOTAL       = 10'd800;

parameter V_SYNC        = 10'd2;
parameter V_BACK_PORCH  = 10'd33;
parameter V_DISPLAY     = 10'd480;
parameter V_FRONT_PORCH = 10'd10;
parameter V_TOTAL       = 10'd525;


// ---------------------------------------------------------
// Horizontal and Vertical Counters
//
// hcount tracks the current pixel in a horizontal line.
// vcount tracks the current horizontal line in a frame.
//
// hcount increments every pixel clock.
// vcount increments only when a horizontal line finishes.
// Both counters reset after reaching their respective totals.
// ---------------------------------------------------------

always @(posedge vga_clk or negedge rst) begin

    if (!rst) begin
        hcount <= 10'd0;
        vcount <= 10'd0;
    end

    else begin

        if (hcount == H_TOTAL - 1) begin
            hcount <= 10'd0;

            if (vcount == V_TOTAL - 1)
                vcount <= 10'd0;
            else
                vcount <= vcount + 1'b1;

        end

        else begin
            hcount <= hcount + 1'b1;
        end

    end
end


// ---------------------------------------------------------
// Horizontal Sync
//
// Active LOW during the horizontal synchronization pulse.
// The pulse occupies the first H_SYNC pixels of each line.
// ---------------------------------------------------------

assign vga_hs = (hcount >= H_SYNC);


// ---------------------------------------------------------
// Vertical Sync
//
// Active LOW during the vertical synchronization pulse.
// The pulse occupies the first V_SYNC lines of each frame.
// ---------------------------------------------------------

assign vga_vs = (vcount >= V_SYNC);


// ---------------------------------------------------------
// VGA Blanking Signal
//
// Active HIGH only during the visible display region.
// Must account for both horizontal and vertical coordinates.
// ---------------------------------------------------------

assign vga_blank_n =
    (hcount >= H_SYNC + H_BACK_PORCH) &&
    (hcount < H_SYNC + H_BACK_PORCH + H_DISPLAY) &&
    (vcount >= V_SYNC + V_BACK_PORCH) &&
    (vcount < V_SYNC + V_BACK_PORCH + V_DISPLAY);

endmodule

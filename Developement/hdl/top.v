module top(
    input wire clk,
    input wire reset,

    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [6:0] HEX4,
    output wire [6:0] HEX5
);

    // R15 register value
    wire [15:0] R15Out;

    // Six decimal digits from double-dabble
    wire [23:0] R15BCD;
	 
    // ------------------------------------------------------------
    // Instantiate cpu.v module
    // ------------------------------------------------------------
	 
	 cpu #(
	 .ADDR_WIDTH(10),
    .DATA_WIDTH(16),
    .MEM_FILE("../src/RI_Type_Instructions.mem")
	 ) cpu (
	 .clk(clk),
	 .reset(reset),
	 .R15Out(R15Out)
	 );
	 
    // ------------------------------------------------------------
    // Convert the 16-bit binary value into six BCD digits
    // ------------------------------------------------------------
    double_dabble #(
        .INPUT_WIDTH(16)
    ) r15_converter (
        .binary_in(R15Out),
        .bcd_out(R15BCD)
    );

    // ------------------------------------------------------------
    // Convert each BCD digit into seven-segment signals
    // ------------------------------------------------------------

    HexTo7Seg digit0 (
        .hex_input(R15BCD[3:0]),     // Ones
        .segment_display(HEX0)
    );

    HexTo7Seg digit1 (
        .hex_input(R15BCD[7:4]),     // Tens
        .segment_display(HEX1)
    );

    HexTo7Seg digit2 (
        .hex_input(R15BCD[11:8]),    // Hundreds
        .segment_display(HEX2)
    );

    HexTo7Seg digit3 (
        .hex_input(R15BCD[15:12]),   // Thousands
        .segment_display(HEX3)
    );

    HexTo7Seg digit4 (
        .hex_input(R15BCD[19:16]),   // Ten-thousands
        .segment_display(HEX4)
    );

    HexTo7Seg digit5 (
        .hex_input(R15BCD[23:20]),   // Hundred-thousands
        .segment_display(HEX5)
    );

endmodule
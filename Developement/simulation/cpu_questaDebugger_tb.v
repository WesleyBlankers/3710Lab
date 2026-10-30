
`timescale 1ns/1ps

module cpu_questaDebugger_tb;

    reg clk;
    reg reset;

    integer cycle;

    // ============================================================
    // CPU Under Test
    // ============================================================

    cpu #(
        .ADDR_WIDTH(10),
        .DATA_WIDTH(16),
        .MEM_FILE("../../../src/Multiple_Type_Instructions.mem")
    ) uut (
        .clk(clk),
        .reset(reset)
    );

    // ============================================================
    // Clock: 10 ns period
    // ============================================================

    initial clk = 1'b0;
    always #5 clk = ~clk;
	 
    // ============================================================
    // Reset and Simulation Control
    // ============================================================

    initial begin
        reset = 1'b1;
        cycle = 0;

        // Hold reset for two clock edges
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 1'b0;
    end

    // ============================================================
    // Cycle Counter
    // ============================================================

    always @(posedge clk) begin
        if (reset)
            cycle <= 0;
        else
            cycle <= cycle + 1;
    end

    // ============================================================
    // Simulation Runtime
    // ============================================================

    initial begin
        // Allow the CPU to execute for 10 us
        #10000;
        $stop;
    end

endmodule
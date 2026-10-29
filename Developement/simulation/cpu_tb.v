
`timescale 1ns/1ps

module cpu_tb;

    reg clk;
    reg reset;

    wire [15:0] debugR15;

    integer cycle;
    integer passed;

    // ============================================================
    // CPU Under Test
    // ============================================================

    cpu #(
        .ADDR_WIDTH(10),
        .DATA_WIDTH(16),
        .MEM_FILE("../../../src/RI_Type_Instructions.mem")
    ) uut (
        .clk(clk),
        .reset(reset),
        .debugR15(debugR15)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    // ============================================================
    // Debug Trace
    // Prints internal signals after each falling clock edge.
    // ============================================================


always @(posedge clk) begin
    if (!reset) begin

        // ====================================================
        // CPU STATE
        // ====================================================
        $display("\n");
        $display("==============================================================");
        $display(" TIME: %0t ns", $time);
        $display("==============================================================");

        $display("--- FETCH / INSTRUCTION ---");
        $display(" PC:          %d", uut.debugPCout);
        $display(" BRAM Address:%d", uut.debugBramAddress);
        $display(" BRAM Data:   %b", uut.debugBramReadValue);
        $display(" IR:          %b", uut.debugInstructionRegister);
        $display(" Instruction: %b", uut.debugInstruction);

        // ====================================================
        // INSTRUCTION DECODE
        // ====================================================
        $display("\n--- DECODE ---");
        $display(" Opcode:      %b", uut.debugOpcode);
        $display(" Rsrc:        %d", uut.debugRsrc);
        $display(" Rdest:       %d", uut.debugRdest);
        $display(" Immediate:   %d", uut.debugImmediate);
        $display(" Ra:          %b", uut.debugRa);
        $display(" Rb:          %b", uut.debugRb);

        // ====================================================
        // CONTROL SIGNALS
        // ====================================================
        $display("\n--- CONTROL ---");
        $display(" RegisterEn:  %b", uut.debugRegisterEnables);
        $display(" Flags:       %05b", uut.debugFlagsRegister);
        $display(" PCEnable:    %b",   uut.debugPCEnable);
        $display(" PC Mux:      %b",   uut.debugPCMultiplexorControl);
        $display(" IR Enable:   %b",   uut.debugInstructionRegisterEnable);
        $display(" IR Mux:      %b",   uut.debugInstructionRegisterMultiplexorControl);
        $display(" BRAM WE:     %b",   uut.debugBramWriteEnable);
        $display(" ALU Mux:     %b",   uut.debugALUMultiplexorControl);
        $display(" Imm Mux:     %b",   uut.debugImmediateMultiplexorControl);
        $display(" Load/Store:  %b",   uut.debugLoadStoreMultiplexorControl);

        // ====================================================
        // REGISTER FILE
        // ====================================================
        $display("\n--- REGISTER FILE ---");
        $display(" R00: %d    R01: %d    R02: %d    R03: %d",
                 uut.debugR0, uut.debugR1, uut.debugR2, uut.debugR3);

        $display(" R04: %d    R05: %d    R06: %d    R07: %d",
                 uut.debugR4, uut.debugR5, uut.debugR6, uut.debugR7);

        $display(" R08: %d    R09: %d    R10: %d    R11: %d",
                 uut.debugR8, uut.debugR9, uut.debugR10, uut.debugR11);

        $display(" R12: %d    R13: %d    R14: %d    R15: %d",
                 uut.debugR12, uut.debugR13, uut.debugR14, uut.debugR15);

        $display("==============================================================");

    end
end


    // ============================================================
    // Test
    // ============================================================

    initial begin : test_sequence

        clk = 0;
        reset = 1;
        cycle = 0;
        passed = 0;

        $display("========================================");
        $display("Starting CPU test");
        $display("========================================");

        // Hold reset for two clock cycles
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // Wait for R15 to be enabled, with a timeout.
        // Check before the active edge, then read the result
        // after the register write has completed.
        begin : wait_for_r15
            for (cycle = 0; cycle < 500; cycle = cycle + 1) begin
                @(posedge clk);

                if (uut.RegisterEnables[15] === 1'b1) begin
                    @(negedge clk);
                    #1;

                    $display("========================================");
                    $display("R15 write detected at cycle %0d", cycle);
                    $display("Final R15 = %0d (0x%h)", debugR15, debugR15);

                    if (debugR15 === 16'd3) begin
                        $display("PASS: R15 = %0d", debugR15);
                        passed = 1;
                    end
                    else begin
                        $display("FAIL: Expected R15 = 3, got %0d (0x%h)",
                                 debugR15, debugR15);
                    end

                    $display("========================================");
                    disable wait_for_r15;
                end
            end
        end

        if (!passed) begin
            $display("TIMEOUT: R15 was not written within 500 cycles.");
            $display("Last PC = %d", uut.PCout);
            $display("Last instruction = %b", uut.Instruction);
            $display("Last opcode = %b", uut.Opcode);
				$display("Last immediate = %b", uut.Immediate);
            $display("Last register enables = %b",
                     uut.RegisterEnables);
        end

        $finish;
    end

endmodule

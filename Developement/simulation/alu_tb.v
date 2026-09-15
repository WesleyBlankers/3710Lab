`timescale 1ns / 1ps

module alu_tb;

`include "../hdl/params.sv"

    // ============================================================
    // DUT INPUTS
    // ============================================================

    reg [15:0] A;
    reg [15:0] B;
    reg [7:0]  Opcode;
    reg        Cin;

    // ============================================================
    // DUT OUTPUTS
    // ============================================================

    wire [15:0] C;
    wire [4:0]  Flags;

    // Flags:
    // Flags[4] = C (Carry)
    // Flags[3] = L (Less-than unsigned)
    // Flags[2] = F (Signed overflow)
    // Flags[1] = Z (Zero)
    // Flags[0] = N (Negative / signed less-than)

    // ============================================================
    // TESTBENCH VARIABLES
    // ============================================================

    integer passed;
    integer failed;
    integer i;
	 integer testNumber;

    reg [15:0] expected_C;
    reg [4:0]  expected_Flags;

    reg [16:0] temp_result;

    // ============================================================
    // INSTANTIATE ALU
    // ============================================================

    alu uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .C(C),
        .Opcode(Opcode),
        .Flags(Flags)
    );

    // ============================================================
    // TEST TASK
    // ============================================================
    //
    // Applies inputs, waits for combinational logic to settle,
    // and checks both C and Flags.
    //
    // ============================================================

    task run_test;

        input [255:0] test_name;
        input [15:0]  test_A;
        input [15:0]  test_B;
        input [7:0]   test_Opcode;
        input         test_Cin;
        input [15:0]  test_expected_C;
        input [4:0]   test_expected_Flags;

        begin

            A      = test_A;
            B      = test_B;
            Opcode = test_Opcode;
            Cin    = test_Cin;

            // Give combinational logic time to settle
            #1;

            if ((C !== test_expected_C) ||
                (Flags !== test_expected_Flags)) begin

                failed = failed + 1;

                $display("");
                $display("FAILED Test #%d: %s", testNumber, test_name);
                $display("  Opcode          = %h", Opcode);
                $display("  A               = %h (%0d)", A, A);
                $display("  B               = %h (%0d)", B, B);
                $display("  Cin             = %b", Cin);
                $display("  Expected C      = %h", test_expected_C);
                $display("  Actual C        = %h", C);
                $display("  Expected Flags  = %b", test_expected_Flags);
                $display("  Actual Flags    = %b", Flags);
                $display("");

            end
            else begin

                passed = passed + 1;

                $display("PASSED Test #%d: %s", testNumber, test_name);
            end
				
				testNumber = testNumber + 1;
        end

    endtask


    // ============================================================
    // START TESTING
    // ============================================================

    initial begin

        passed = 0;
        failed = 0;
		  testNumber = 1;

        A      = 16'd0;
        B      = 16'd0;
        Opcode = 8'd0;
        Cin    = 1'b0;

        #10;

        $display("");
        $display("============================================================");
        $display("                 STARTING ALU TESTBENCH");
        $display("============================================================");
        $display("");

        // ========================================================
        // ADD TESTS
        // ========================================================

        // 1. Normal addition
        // 10 + 20 = 30
        run_test(
            "ADD: 10 + 20", 	// Test Name
            16'd10,				// A
            16'd20,				// B
            ADD,					// OPCODE
            1'b0,					// CIN
            16'd30,				// Expected C
            5'b00000				// Flags
        );

        // 2. Addition resulting in zero
        // 0 + 0 = 0
        run_test(
            "ADD: 0 + 0",
            16'd0,
            16'd0,
            ADD,
            1'b0,
            16'd0,
            5'b00010
        );

        // 3. Signed addition
        // 15 + (-10) = 5
        run_test(
            "ADD: 15 + (-10)",
            16'sd15,
            -16'sd10,
            ADD,
            1'b0,
            16'd5,
            5'b00000
        );

        // 4. Positive signed overflow
        // 32767 + 1 = -32768
        run_test(
            "ADD: positive overflow",
            16'h7FFF,
            16'h0001,
            ADD,
            1'b0,
            16'h8000,
            5'b00100
        );

        // 5. Negative signed overflow
        // -32768 + (-1) = 32767
        run_test(
            "ADD: negative overflow",
            16'h8000,
            16'hFFFF,
            ADD,
            1'b0,
            16'h7FFF,
            5'b10100
        );


        // ========================================================
        // ADDI TESTS
        // ========================================================

        run_test(
            "ADDI: 10 + 3",
            16'd10,
            16'd3,
            ADDI,
            1'b0,
            16'd13,
            5'b00000
        );

        run_test(
            "ADDI: 0 + 0",
            16'd0,
            16'd0,
            ADDI,
            1'b0,
            16'd0,
            5'b00010
        );


        // ========================================================
        // ADDU TESTS
        // ========================================================

        // 65530 + 10 = 4 with carry
        run_test(
            "ADDU: unsigned carry",
            16'd65530,
            16'd10,
            ADDU,
            1'b0,
            16'd4,
            5'b10000
        );

        // FFFF + 1 = 0000 with carry
        run_test(
            "ADDU: FFFF + 1",
            16'hFFFF,
            16'h0001,
            ADDU,
            1'b0,
            16'h0000,
            5'b10010
        );

        // No carry
        run_test(
            "ADDU: 100 + 5",
            16'd100,
            16'd5,
            ADDU,
            1'b0,
            16'd105,
            5'b00000
        );


        // ========================================================
        // ADDUI TESTS
        // ========================================================

        run_test(
            "ADDUI: 100 + 5",
            16'd100,
            16'd5,
            ADDUI,
            1'b0,
            16'd105,
            5'b00000
        );


        // ========================================================
        // ADDC TESTS
        // ========================================================

        // Cin = 0
        run_test(
            "ADDC: 10 + 20 + 0",
            16'd10,
            16'd20,
            ADDC,
            1'b0,
            16'd30,
            5'b00000
        );

        // Cin = 1
        run_test(
            "ADDC: 10 + 20 + 1",
            16'd10,
            16'd20,
            ADDC,
            1'b1,
            16'd31,
            5'b00000
        );

        // Carry generated
        run_test(
            "ADDC: FFFF + 0 + 1",
            16'hFFFF,
            16'h0000,
            ADDC,
            1'b1,
            16'h0000,
            5'b10010
        );


        // ========================================================
        // ADDCI TESTS
        // ========================================================

        run_test(
            "ADDCI: 10 + 2 + 1",
            16'd10,
            16'd2,
            ADDCI,
            1'b1,
            16'd13,
            5'b00000
        );


        // ========================================================
        // SUB TESTS
        // ========================================================

        // 20 - 5 = 15
        run_test(
            "SUB: 20 - 5",
            16'd20,
            16'd5,
            SUB,
            1'b0,
            16'd15,
            5'b00000
        );

        // 20 - 20 = 0
        run_test(
            "SUB: 20 - 20",
            16'd20,
            16'd20,
            SUB,
            1'b0,
            16'd0,
            5'b00010
        );

        // 0 - 1 = FFFF
        run_test(
            "SUB: 0 - 1",
            16'd0,
            16'd1,
            SUB,
            1'b0,
            16'hFFFF,
            5'b00000
        );

        // Positive overflow
        // 32767 - (-1) = 32768
        run_test(
            "SUB: positive overflow",
            16'h7FFF,
            16'hFFFF,
            SUB,
            1'b0,
            16'h8000,
            5'b00100
        );

        // Negative overflow
        // -32768 - 1 = -32769
        run_test(
            "SUB: negative overflow",
            16'h8000,
            16'h0001,
            SUB,
            1'b0,
            16'h7FFF,
            5'b00100
        );


        // ========================================================
        // SUBI TESTS
        // ========================================================

        run_test(
            "SUBI: 20 - 4",
            16'd20,
            16'd4,
            SUBI,
            1'b0,
            16'd16,
            5'b00000
        );


        // ========================================================
        // CMP TESTS
        // ========================================================

        // A < B
        run_test(
            "CMP: 10 < 20",
            16'd10,
            16'd20,
            CMP,
            1'b0,
            16'd0,
            5'b01001
        );

        // A > B
        run_test(
            "CMP: 20 > 10",
            16'd20,
            16'd10,
            CMP,
            1'b0,
            16'd0,
            5'b00000
        );

        // A == B
        run_test(
            "CMP: 10 == 10",
            16'd10,
            16'd10,
            CMP,
            1'b0,
            16'd0,
            5'b00010
        );

        // Signed comparison:
        // -1 < 1
        run_test(
            "CMP: signed -1 < 1",
            16'hFFFF,
            16'h0001,
            CMP,
            1'b0,
            16'd0,
            5'b00001
        );

        // Signed comparison:
        // -32768 < 32767
        run_test(
            "CMP: signed MIN < MAX",
            16'h8000,
            16'h7FFF,
            CMP,
            1'b0,
            16'd0,
            5'b00001
        );


        // ========================================================
        // CMPI TESTS
        // ========================================================

        run_test(
            "CMPI: 15 > 5",
            16'd15,
            16'd5,
            CMPI,
            1'b0,
            16'd0,
            5'b00000
        );

        run_test(
            "CMPI: 15 == 15",
            16'd15,
            16'd15,
            CMPI,
            1'b0,
            16'd0,
            5'b00010
        );


        // ========================================================
        // UNSIGNED COMPARE TESTS
        // ========================================================

        // 10 < 20
        run_test(
            "CMPUI: unsigned 10 < 20",
            16'd10,
            16'd20,
            CMPUI,
            1'b0,
            16'd0,
            5'b01001
        );

        // 65535 > 5
        run_test(
            "CMPUI: 65535 > 5",
            16'hFFFF,
            16'd5,
            CMPUI,
            1'b0,
            16'd0,
            5'b00000
        );

        // Equal
        run_test(
            "CMPUI: 100 == 100",
            16'd100,
            16'd100,
            CMPUI,
            1'b0,
            16'd0,
            5'b00010
        );

        // Important signed/unsigned distinction:
        // FFFF = -1 signed but 65535 unsigned
        run_test(
            "CMPUI: FFFF > 0001 unsigned",
            16'hFFFF,
            16'h0001,
            CMPUI,
            1'b0,
            16'd0,
            5'b00000
        );


        // ========================================================
        // AND TESTS
        // ========================================================

        run_test(
            "AND: 12 & 10",
            16'd12,
            16'd10,
            AND,
            1'b0,
            16'd8,
            5'b00000
        );

        run_test(
            "AND: 15 & 0",
            16'd15,
            16'd0,
            AND,
            1'b0,
            16'd0,
            5'b00010
        );

        run_test(
            "AND: FFFF & FFFF",
            16'hFFFF,
            16'hFFFF,
            AND,
            1'b0,
            16'hFFFF,
            5'b00000
        );


        // ========================================================
        // OR TESTS
        // ========================================================

        run_test(
            "OR: 12 | 10",
            16'd12,
            16'd10,
            OR,
            1'b0,
            16'd14,
            5'b00000
        );

        run_test(
            "OR: 0 | 0",
            16'd0,
            16'd0,
            OR,
            1'b0,
            16'd0,
            5'b00010
        );

        run_test(
            "OR: FFFF | 0",
            16'hFFFF,
            16'h0000,
            OR,
            1'b0,
            16'hFFFF,
            5'b00000
        );


        // ========================================================
        // XOR TESTS
        // ========================================================

        run_test(
            "XOR: 12 ^ 10",
            16'd12,
            16'd10,
            XOR,
            1'b0,
            16'd6,
            5'b00000
        );

        run_test(
            "XOR: 15 ^ 15",
            16'd15,
            16'd15,
            XOR,
            1'b0,
            16'd0,
            5'b00010
        );

        run_test(
            "XOR: FFFF ^ 0000",
            16'hFFFF,
            16'h0000,
            XOR,
            1'b0,
            16'hFFFF,
            5'b00000
        );


        // ========================================================
        // NOT TESTS
        // ========================================================

        run_test(
            "NOT: ~0000",
            16'h0000,
            16'h0000,
            NOT,
            1'b0,
            16'hFFFF,
            5'b00000
        );

        run_test(
            "NOT: ~FFFF",
            16'hFFFF,
            16'h0000,
            NOT,
            1'b0,
            16'h0000,
            5'b00010
        );

        run_test(
            "NOT: ~000F",
            16'h000F,
            16'h0000,
            NOT,
            1'b0,
            16'hFFF0,
            5'b00000
        );


        // ========================================================
        // LSH TESTS
        // ========================================================

        // Left
        run_test(
            "LSH: 5 << 2",
            16'd5,
            16'd2,
            LSH,
            1'b0,
            16'd20,
            5'b00000
        );

        // Right
        run_test(
            "LSH: 20 >> 2",
            16'd20,
            -16'sd2,
            LSH,
            1'b0,
            16'd5,
            5'b00000
        );

        // Shift by zero
        run_test(
            "LSH: shift by zero",
            16'h1234,
            16'd0,
            LSH,
            1'b0,
            16'h1234,
            5'b00000
        );

        // Shift by 15
        run_test(
            "LSH: 1 << 15",
            16'h0001,
            16'd15,
            LSH,
            1'b0,
            16'h8000,
            5'b00000
        );

        // Shift by 16
        run_test(
            "LSH: 1 << 16",
            16'h0001,
            16'd16,
            LSH,
            1'b0,
            16'h0000,
            5'b00010
        );


        // ========================================================
        // LSHI TESTS
        // ========================================================

        run_test(
            "LSHI: 3 << 3",
            16'd3,
            16'd3,
            LSHI,
            1'b0,
            16'd24,
            5'b00000
        );

        run_test(
            "LSHI: 1 << 15",
            16'd1,
            16'd15,
            LSHI,
            1'b0,
            16'h8000,
            5'b00000
        );


        // ========================================================
        // ALSH TESTS
        // ========================================================

        // Arithmetic left shift
        run_test(
            "ALSH: 5 << 2",
            16'sd5,
            16'sd2,
            ALSH,
            1'b0,
            16'd20,
            5'b00000
        );

        // Arithmetic right shift positive
        run_test(
            "ALSH: 20 >> 2",
            16'sd20,
            -16'sd2,
            ALSH,
            1'b0,
            16'd5,
            5'b00000
        );

        // Arithmetic right shift negative
        // -16 >>> 2 = -4
        run_test(
            "ALSH: -16 >>> 2",
            -16'sd16,
            -16'sd2,
            ALSH,
            1'b0,
            16'hFFFC,
            5'b00000
        );

        // -1 >>> 1 should remain -1
        run_test(
            "ALSH: -1 >>> 1",
            16'hFFFF,
            -16'sd1,
            ALSH,
            1'b0,
            16'hFFFF,
            5'b00000
        );

        // Most-negative number
        // 8000 >>> 1 = C000
        run_test(
            "ALSH: 8000 >>> 1",
            16'h8000,
            -16'sd1,
            ALSH,
            1'b0,
            16'hC000,
            5'b00000
        );


        // ========================================================
        // INVALID OPCODE TEST
        // ========================================================

        // Change this expected result if your ALU has a specific
        // behavior for an invalid opcode.

        run_test(
            "INVALID OPCODE: FF",
            16'h1234,
            16'h5678,
            8'hFF,
            1'b0,
            16'h0000,
            5'b00000
        );

        // ========================================================
        // RANDOMIZED LOGIC TESTS
        // ========================================================

        $display("");
        $display("============================================================");
        $display("                RANDOMIZED LOGIC TESTS");
        $display("============================================================");

        for (i = 0; i < 1000; i = i + 1) begin

            A = $random;
            B = $random;
            Cin = 0;

            // --------------------------------------------
            // AND
            // --------------------------------------------

            Opcode = AND;
            #1;

            expected_C = A & B;

            if (C !== expected_C) begin
                failed = failed + 1;
                $display("FAIL: Random AND test %0d", i);
                $display("  A=%h B=%h Expected=%h Actual=%h",
                         A, B, expected_C, C);
            end
            else begin
                passed = passed + 1;
            end


            // --------------------------------------------
            // OR
            // --------------------------------------------

            Opcode = OR;
            #1;

            expected_C = A | B;

            if (C !== expected_C) begin
                failed = failed + 1;
                $display("FAIL: Random OR test %0d", i);
                $display("  A=%h B=%h Expected=%h Actual=%h",
                         A, B, expected_C, C);
            end
            else begin
                passed = passed + 1;
            end


            // --------------------------------------------
            // XOR
            // --------------------------------------------

            Opcode = XOR;
            #1;

            expected_C = A ^ B;

            if (C !== expected_C) begin
                failed = failed + 1;
                $display("FAIL: Random XOR test %0d", i);
                $display("  A=%h B=%h Expected=%h Actual=%h",
                         A, B, expected_C, C);
            end
            else begin
                passed = passed + 1;
            end


            // --------------------------------------------
            // NOT
            // --------------------------------------------

            Opcode = NOT;
            #1;

            expected_C = ~A;

            if (C !== expected_C) begin
                failed = failed + 1;
                $display("FAIL: Random NOT test %0d", i);
                $display("  A=%h Expected=%h Actual=%h",
                         A, expected_C, C);
            end
            else begin
                passed = passed + 1;
            end

        end


        // ========================================================
        // FINAL RESULTS
        // ========================================================

        #10;

        $display("");
        $display("============================================================");
        $display("                  ALU TESTBENCH COMPLETE");
        $display("============================================================");
        $display("Tests Passed : %0d", passed);
        $display("Tests Failed : %0d", failed);
        $display("============================================================");

        if (failed == 0) begin
            $display("RESULT: ALL TESTS PASSED!");
        end
        else begin
            $display("RESULT: TESTBENCH FAILED!");
        end

        $display("");

        $stop;

    end

endmodule
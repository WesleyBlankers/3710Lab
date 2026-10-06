// ============================================================
// Maximum Value Demo
//
// r0-r14 contain hard-coded numbers.
// r15 contains the largest value found so far.
//
// FSM:
//   1. Initialize r0-r14.
//   2. CMPU r15 against r[index].
//   3. On the following cycle, check the registered
//      unsigned-less-than flag.
//   4. If r15 < r[index], MOV r[index] -> r15.
//   5. Repeat for r0-r14.
//   6. Hold with the final maximum value in r15.
// ============================================================

module top(
    input  wire       CLOCK_50,
    input  wire       KEY,
	 input  wire [3:0] SW,
    output wire [8:0] LEDS
);

    `include "params.sv"

    // ============================================================
    // Clock / Reset
    // ============================================================

    wire clk;
    wire reset;

    assign clk   = CLOCK_50;
    assign reset = ~KEY;


    // ============================================================
    // Datapath Control Signals
    // ============================================================

    reg [3:0]  selectA;
    reg [3:0]  selectB;

    reg [15:0] registerEnables;

    reg        immediateEnable;
    reg [15:0] immediate;

    reg [7:0]  Opcode;


    // ============================================================
    // Datapath Outputs
    // ============================================================

    wire [4:0]  aluFLAGOutput;
    wire [15:0] aluResult;

    // Current value stored in r15
    wire [15:0] r15Value;


    // ============================================================
    // FSM
    // ============================================================

    reg [5:0] state;
    reg [5:0] nextState;

    // Register currently being compared against r15
    reg [3:0] compareIndex;


    // ============================================================
    // Datapath
    // ============================================================

    datapath uut (
        .selectA(selectA),
        .selectB(selectB),

        .registerEnables(registerEnables),

        .immediateEnable(immediateEnable),
        .immediate(immediate),

        .Opcode(Opcode),

        .aluFLAGOutput(aluFLAGOutput),
        .aluResult(aluResult),
        .clk(clk),
        .reset(reset)
    );


    // ============================================================
    // LED Display
    // ============================================================

    // Display the lower 9 bits of r15.
    assign LEDS = aluResult[8:0];


    // ============================================================
    // Control Logic
    // ============================================================

    always @(*) begin

        // --------------------------------------------------------
        // Default values
        // --------------------------------------------------------

        registerEnables = 16'd0;

        immediateEnable = 1'b0;
        immediate = 16'd0;

        selectA = 4'd0;
        selectB = 4'd0;

        Opcode = NOP;


        case (state)

            // ====================================================
            // INITIALIZE REGISTERS
            // ====================================================

            // r0 = 7
            6'd0: begin
                selectA = 4'd15; // FIX: Use r15 (which is 0) instead of r0
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd7;
                registerEnables[0] = 1'b1;
            end

            // r1 = 3
            6'd1: begin
                selectA = 4'd15;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd3;
                registerEnables[1] = 1'b1;
            end

            // r2 = 12
            6'd2: begin
                selectA = 4'd15;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd12;
                registerEnables[2] = 1'b1;
            end

            // r3 = 5
            6'd3: begin
                selectA = 4'd15;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd5;
                registerEnables[3] = 1'b1;
            end

            // r4 = 9
            6'd4: begin
                selectA = 4'd15;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd9;
                registerEnables[4] = 1'b1;
            end

            // r5 = 2
            6'd5: begin
                selectA = 4'd15;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd2;
                registerEnables[5] = 1'b1;
            end

            // r6 = 11
            6'd6: begin
                selectA = 4'd15;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd11;
                registerEnables[6] = 1'b1;
            end

            // r7 = 4
            6'd7: begin
                selectA = 4'd15;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd4;
                registerEnables[7] = 1'b1;
            end

            // r8 = 18
            6'd8: begin
                selectA = 4'd15;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd18;
                registerEnables[8] = 1'b1;
            end

            // r9 = 6
            6'd9: begin
                selectA = 4'd15;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd6;
                registerEnables[9] = 1'b1;
            end

            // r10 = 1
            6'd10: begin
                selectA = 4'd15;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd1;
                registerEnables[10] = 1'b1;
            end

            // r11 = 15
            6'd11: begin
                selectA = 4'd15;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd15;
                registerEnables[11] = 1'b1;
            end

            // r12 = 10
            6'd12: begin
                selectA = 4'd15;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd10;
                registerEnables[12] = 1'b1;
            end

            // r13 = 13
            6'd13: begin
                selectA = 4'd15;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd13;
                registerEnables[13] = 1'b1;
            end

            // r14 = 8
            6'd14: begin
                selectA = 4'd15;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd8;
                registerEnables[14] = 1'b1;
            end

            // r15 starts at zero after reset
            6'd15: begin
                Opcode = NOP;
            end


            // ====================================================
            // COMPARE
            // ====================================================

            // Perform:
            //
            //     r15 CMPU r[index]
            //
            // The result of CMPU is stored in the flag register
            // at the clock edge.
            //
            6'd16: begin

                selectA = 4'd15;
                selectB = compareIndex;

                Opcode = CMPU;

            end


            // ====================================================
            // COPY
            // ====================================================

            // aluFLAGOutput now contains the flags generated by
            // the CMPU operation from state 16.
            //
            // If:
            //
            //     r15 < r[index]
            //
            // then Flags[3] = 1 and MOV copies:
            //
            //     r[index] -> r15
            //
            6'd17: begin

                selectA = compareIndex;

                Opcode = MOV;

                registerEnables[15] = aluFLAGOutput[3];

            end


            // ====================================================
            // DONE
            // ====================================================

            6'd18: begin
                selectA = SW;   // Use switches to select the register to view
                Opcode = MOV;   // Pass the selected register through the ALU
					 
            end


            default: begin
                Opcode = NOP;
            end

        endcase

    end


    // ============================================================
    // Next State Logic
    // ============================================================

    always @(*) begin

        case (state)

            // Initialization
            6'd0  : nextState = 6'd1;
            6'd1  : nextState = 6'd2;
            6'd2  : nextState = 6'd3;
            6'd3  : nextState = 6'd4;
            6'd4  : nextState = 6'd5;
            6'd5  : nextState = 6'd6;
            6'd6  : nextState = 6'd7;
            6'd7  : nextState = 6'd8;
            6'd8  : nextState = 6'd9;
            6'd9  : nextState = 6'd10;
            6'd10 : nextState = 6'd11;
            6'd11 : nextState = 6'd12;
            6'd12 : nextState = 6'd13;
            6'd13 : nextState = 6'd14;
            6'd14 : nextState = 6'd15;

            // Allow one cycle for initialization to finish
            6'd15 : nextState = 6'd16;

            // Compare
            6'd16 : nextState = 6'd17;

            // Copy / advance
            6'd17: begin

                if (compareIndex == 4'd14)
                    nextState = 6'd18;
                else
                    nextState = 6'd16;

            end

            // Hold final result
            6'd18 : nextState = 6'd18;

            default : nextState = 6'd0;

        endcase

    end


    // ============================================================
    // State / Index Registers
    // ============================================================

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            state        <= 6'd0;
            compareIndex <= 4'd0;

        end
        else begin

            state <= nextState;

            // Advance after the MOV/decision state.
            //
            // 0 -> 1 -> 2 -> ... -> 14
            //
            // We don't increment after processing r14.
            if (state == 6'd17) begin

                if (compareIndex < 4'd14)
                    compareIndex <= compareIndex + 4'd1;

            end

        end

    end
	 
	 always @(*) begin
	 
	 
	 
	 end

endmodule
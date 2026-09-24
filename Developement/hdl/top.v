// Implements a 'sort' algorithm that compares r15 to the other registers that contain hard-coded numbers. 
// At the end of the FSM r15 should contain the largest number out of the other registers.

// FIXME: LEDS are not exposed to r15.
// FIXME: Implement a move operation in the alu that can be used to copy a registers value into anothers. 

module top(
    input  wire  CLOCK_50,
    input  wire       KEY,
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
	 assign LEDS = 

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

    // ============================================================
    // FSM
    // ============================================================

    reg [5:0] state;
    reg [5:0] nextState;

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
    // Control Logic
    // ============================================================

    always @(*) begin

        // Default control values
        registerEnables = 16'd0;
        immediateEnable = 1'b0;
        immediate = 16'd0;

        selectA = 4'd0;
        selectB = 4'd0;

        Opcode = NOP;

        case (state)

            // ====================================================
            // INITIALIZE LIST
            // ====================================================

            // r0 = 7
            5'd0: begin
                selectA = 4'd0;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd7;
                registerEnables[0] = 1'b1;
            end

            // r1 = 3
            5'd1: begin
                selectA = 4'd0;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd3;
                registerEnables[1] = 1'b1;
            end

            // r2 = 12
            5'd2: begin
                selectA = 4'd0;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd12;
                registerEnables[2] = 1'b1;
            end

            // r3 = 5
            5'd3: begin
                selectA = 4'd0;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd5;
                registerEnables[3] = 1'b1;
            end

            // r4 = 9
            5'd4: begin
                selectA = 4'd0;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd9;
                registerEnables[4] = 1'b1;
            end

            // r5 = 2
            5'd5: begin
                selectA = 4'd0;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd2;
                registerEnables[5] = 1'b1;
            end

            // r6 = 11
            5'd6: begin
                selectA = 4'd0;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd11;
                registerEnables[6] = 1'b1;
            end

            // r7 = 4
            5'd7: begin
                selectA = 4'd0;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd4;
                registerEnables[7] = 1'b1;
            end

            // r8 = 15
            5'd8: begin
                selectA = 4'd0;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd15;
                registerEnables[8] = 1'b1;
            end

            // r9 = 6
            5'd9: begin
                selectA = 4'd0;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd6;
                registerEnables[9] = 1'b1;
            end

            // r10 = 1
            5'd10: begin
                selectA = 4'd0;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd1;
                registerEnables[10] = 1'b1;
            end

            // r11 = 14
            5'd11: begin
                selectA = 4'd0;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd14;
                registerEnables[11] = 1'b1;
            end

            // r12 = 10
            5'd12: begin
                selectA = 4'd0;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd10;
                registerEnables[12] = 1'b1;
            end

            // r13 = 13
            5'd13: begin
                selectA = 4'd0;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd13;
                registerEnables[13] = 1'b1;
            end

            // r14 = 8
            5'd14: begin
                selectA = 4'd0;
                Opcode = ADDUI;
                immediateEnable = 1'b1;
                immediate = 16'd8;
                registerEnables[14] = 1'b1;
            end

            // r15 = 0
            // Reset already makes this zero, so no write needed.
            5'd15: begin
                Opcode = NOP;
            end

            // ====================================================
            // FIND MAXIMUM
            // ====================================================

            // Compare r15 with r0
            5'd16: begin
                selectA = 4'd15;
                selectB = 4'd0;
                Opcode = CMPU;
            end

            // If r15 < r0, copy r0 -> r15
            5'd17: begin
                selectA = 4'd0;
                Opcode = ADDU;
                registerEnables[15] = aluFLAGOutput[3];
            end

            // Compare r15 with r1
            5'd18: begin
                selectA = 4'd15;
                selectB = 4'd1;
                Opcode = CMPU;
            end

            // If r15 < r1, copy r1 -> r15
            5'd19: begin
                selectA = 4'd1;
                Opcode = ADDU;
                registerEnables[15] = aluFLAGOutput[3];
            end

            // Compare r15 with r2
            5'd20: begin
                selectA = 4'd15;
                selectB = 4'd2;
                Opcode = CMPU;
            end

            // If r15 < r2, copy r2 -> r15
            5'd21: begin
                selectA = 4'd2;
                Opcode = ADDU;
                registerEnables[15] = aluFLAGOutput[3];
            end
				
				// Compare r15 with r3
            5'd22: begin
                selectA = 4'd15;
                selectB = 4'd3;
                Opcode = CMPU;
            end

            // If r15 < r3, copy r3 -> r15
            5'd23: begin
                selectA = 4'd3;
                Opcode = ADDU;
                registerEnables[15] = aluFLAGOutput[3];
            end
				
				// Compare r15 with r4
            5'd24: begin
                selectA = 4'd15;
                selectB = 4'd4;
                Opcode = CMPU;
            end

            // If r15 < r4, copy r4 -> r15
            5'd25: begin
                selectA = 4'd4;
                Opcode = ADDU;
                registerEnables[15] = aluFLAGOutput[3];
            end

            // Compare r15 with r5
            5'd26: begin
                selectA = 4'd15;
                selectB = 4'd5;
                Opcode = CMPU;
            end

            // If r15 < r5, copy r5 -> r15
            5'd27: begin
                selectA = 4'd5;
                Opcode = ADDU;
                registerEnables[15] = aluFLAGOutput[3];
            end

            // Compare r15 with r6
            5'd28: begin
                selectA = 4'd15;
                selectB = 4'd6;
                Opcode = CMPU;
            end

            // If r15 < r6, copy r6 -> r15
            5'd29: begin
                selectA = 4'd6;
                Opcode = ADDU;
                registerEnables[15] = aluFLAGOutput[3];
            end

            // Compare r15 with r7
            5'd30: begin
                selectA = 4'd15;
                selectB = 4'd7;
                Opcode = CMPU;
            end

            // If r15 < r7, copy r7 -> r15
            5'd31: begin
                selectA = 4'd7;
                Opcode = ADDU;
                registerEnables[15] = aluFLAGOutput[3];
            end

            // Compare r15 with r8 (Note: Switched to 6'd to prevent 5-bit overflow)
            6'd32: begin
                selectA = 4'd15;
                selectB = 4'd8;
                Opcode = CMPU;
            end

            // If r15 < r8, copy r8 -> r15
            6'd33: begin
                selectA = 4'd8;
                Opcode = ADDU;
                registerEnables[15] = aluFLAGOutput[3];
            end

            // Compare r15 with r9
            6'd34: begin
                selectA = 4'd15;
                selectB = 4'd9;
                Opcode = CMPU;
            end

            // If r15 < r9, copy r9 -> r15
            6'd35: begin
                selectA = 4'd9;
                Opcode = ADDU;
                registerEnables[15] = aluFLAGOutput[3];
            end

            // Compare r15 with r10
            6'd36: begin
                selectA = 4'd15;
                selectB = 4'd10;
                Opcode = CMPU;
            end

            // If r15 < r10, copy r10 -> r15
            6'd37: begin
                selectA = 4'd10;
                Opcode = ADDU;
                registerEnables[15] = aluFLAGOutput[3];
            end

            // Compare r15 with r11
            6'd38: begin
                selectA = 4'd15;
                selectB = 4'd11;
                Opcode = CMPU;
            end

            // If r15 < r11, copy r11 -> r15
            6'd39: begin
                selectA = 4'd11;
                Opcode = ADDU;
                registerEnables[15] = aluFLAGOutput[3];
            end

            // Compare r15 with r12
            6'd40: begin
                selectA = 4'd15;
                selectB = 4'd12;
                Opcode = CMPU;
            end

            // If r15 < r12, copy r12 -> r15
            6'd41: begin
                selectA = 4'd12;
                Opcode = ADDU;
                registerEnables[15] = aluFLAGOutput[3];
            end

            // Compare r15 with r13
            6'd42: begin
                selectA = 4'd15;
                selectB = 4'd13;
                Opcode = CMPU;
            end

            // If r15 < r13, copy r13 -> r15
            6'd43: begin
                selectA = 4'd13;
                Opcode = ADDU;
                registerEnables[15] = aluFLAGOutput[3];
            end

            // Compare r15 with r14
            6'd44: begin
                selectA = 4'd15;
                selectB = 4'd14;
                Opcode = CMPU;
            end

            // If r15 < r14, copy r14 -> r15
            6'd45: begin
                selectA = 4'd14;
                Opcode = ADDU;
                registerEnables[15] = aluFLAGOutput[3];
            end

            // ====================================================
            // HOLD
            // ====================================================

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
					6'd15 : nextState = 6'd16;
					6'd16 : nextState = 6'd17;
					6'd17 : nextState = 6'd18;
					6'd18 : nextState = 6'd19;
					6'd19 : nextState = 6'd20;
					6'd20 : nextState = 6'd21;
					6'd21 : nextState = 6'd22;
					6'd22 : nextState = 6'd23;
					6'd23 : nextState = 6'd24;
					6'd24 : nextState = 6'd25;
					6'd25 : nextState = 6'd26;
					6'd26 : nextState = 6'd27;
					6'd27 : nextState = 6'd28;
					6'd28 : nextState = 6'd29;
					6'd29 : nextState = 6'd30;
					6'd30 : nextState = 6'd31;
					6'd31 : nextState = 6'd32;
					6'd32 : nextState = 6'd33;
					6'd33 : nextState = 6'd34;
					6'd34 : nextState = 6'd35;
					6'd35 : nextState = 6'd36;
					6'd36 : nextState = 6'd37;
					6'd37 : nextState = 6'd38;
					6'd38 : nextState = 6'd39;
					6'd39 : nextState = 6'd40;
					6'd40 : nextState = 6'd41;
					6'd41 : nextState = 6'd42;
					6'd42 : nextState = 6'd43;
					6'd43 : nextState = 6'd44;
					6'd44 : nextState = 6'd45;
					
					// Hold at the final state when the sequence is complete
					6'd45 : nextState = 6'd45; 

					default : nextState = 6'd0;

			  endcase
	 end

    // ============================================================
    // State Register
    // ============================================================

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= 5'd0;
        else
            state <= nextState;
    end

endmodule
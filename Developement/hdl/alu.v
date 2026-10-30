module alu (
    // Inputs
    input  wire [15:0] A,          // Rdest operand
    input  wire [15:0] B,          // Rsrc or immediate operand
    input  wire        Cin,
    input  wire [7:0]  Opcode,
    input  wire        reset,

    // Outputs
    output reg  [15:0] C,
    output reg  [4:0]  Flags,

    // Debug outputs
    output wire [15:0] debugAluA,
    output wire [15:0] debugAluB,
    output wire        debugAluCin,
    output wire [7:0]  debugAluOpcode,
    output wire [15:0] debugAluResult,
    output wire [4:0]  debugAluFlags,
    output wire        debugAluReset
);


	`include "params.sv"

    // Flags:
    // Flags[4] = C (Carry)
    // Flags[3] = L (Less-than unsigned)
    // Flags[2] = F (Overflow)
    // Flags[1] = Z (Zero)
    // Flags[0] = N (Negative / less-than signed)
	 
    always @(A, B, Opcode, Cin, reset) begin

	  // Reset
    if (reset) begin
        C     = 16'b0;
        Flags = 5'b0;
    end

    // Normal ALU operation
    else begin
	 
        // Default values
        C     = 16'b0;
        Flags = 5'b0;

        casex (Opcode)

            // =================================================
            // ADDITION
            // =================================================

            ADD, ADDI: begin
                {Flags[4], C} = $signed(A) + $signed(B);
						
					//Zero Flag
					if (C == 16'b0)
						Flags[1] = 1'b1;
					else
						Flags[1] = 1'b0;
						
					// Signed Overflow Flag
					 if ((~A[15] & ~B[15] & C[15]) | (A[15] & B[15] &~C[15]))
						Flags[2] = 1'b1;
					 else
						Flags[2] = 1'b0;
					 
            end

            ADDU, ADDUI: begin
                {Flags[4], C} = A + B;

					//Zero Flag
					if ( C == 16'b0)
						Flags[1] = 1'b1;
					else
						Flags[1] = 1'b0;
						
            end

            ADDC, ADDCI: begin
               {Flags[4], C} = A + B + Cin;
						
					//Zero Flag
					if ( C == 16'b0)
						Flags[1] = 1'b1;
					else
						Flags[1] = 1'b0;
							
					// Signed Overflow Flag
						if (( ~A[15] & ~B[15] & C[15]) | (A[15] & B[15] & ~C[15]))
							Flags[2] = 1'b1;
						else
							Flags[2] = 1'b0;
            end

            // =================================================
            // SUBTRACTION
            // =================================================

            SUB, SUBI: begin
               C = $signed(A) - $signed(B);
					 						
					//Zero Flag
					if ( C == 16'b0)
						Flags[1] = 1'b1;
					else
						Flags[1] = 1'b0;
						
					// Overflow Flag
					if ((A[15] ^ B[15]) & (A[15] ^ C[15]))
						Flags[2] = 1'b1;
					else
						Flags[2] = 1'b0;
            end

            // =================================================
            // COMPARISON
            // =================================================

            CMP, CMPI: begin
					Flags[3] = A < B; // Set Low flag
					Flags[0] = $signed(A) < $signed(B); // Set Less than flag
					Flags[1] = $signed(A) == $signed(B); // Set equal flag
            end
				
            CMPU, CMPUI: begin
					Flags[3] = A < B; // Set Low flag
               Flags[0] = A < B; // Set Less than flag
					Flags[1] = A == B; // Set equal flag
            end

            // =================================================
            // LOGICAL OPERATIONS
            // =================================================

            AND, ANDI: begin
					C = A & B;
					
					//Zero Flag
					if ( C == 16'b0)
						Flags[1] = 1'b1;
					else
						Flags[1] = 1'b0;
            end

            OR, ORI: begin
                C = A | B;
									
					//Zero Flag
					if ( C == 16'b0)
						Flags[1] = 1'b1;
					else
						Flags[1] = 1'b0;
					 
            end

            XOR, XORI: begin
                C = A ^ B;
					 
					//Zero Flag
					if ( C == 16'b0)
						Flags[1] = 1'b1;
					else
						Flags[1] = 1'b0;
            end

            NOT: begin
					 C = ~A;
					
					//Zero Flag
					if ( C == 16'b0)
						Flags[1] = 1'b1;
					else
						Flags[1] = 1'b0;
            end

            // =================================================
            // SHIFT OPERATIONS
            // =================================================

            LSH, LSHI: begin
                if ($signed(B[4:0]) < 0)
						C = A >> (-$signed(B[4:0]));
					 else
					   C = A << B[3:0];
						
					//Zero Flag
					if ( C == 16'b0)
						Flags[1] = 1'b1;
					else
						Flags[1] = 1'b0;
            end

            ALSH: begin
                if ($signed(B[4:0]) < 0)
						C = $signed(A) >>> (-$signed(B[4:0]));
					 else
						C = $signed(A) <<< $signed(B[4:0]);
						
					//Zero Flag
					if ( C == 16'b0)
						Flags[1] = 1'b1;
					else
						Flags[1] = 1'b0;
            end

            // =================================================
            // NO OPERATION
            // =================================================

            NOP: begin
                // Do literally nothing.
            end

            WAIT: begin
                // Do literally nothing.
            end
				
				// =================================================
            // MOVE OPERATIONS
            // =================================================
				
				MOV: begin
					C = A;
				end
				
				MOVI: begin
					C = B;
				end

            // =================================================
            // DEFAULT
            // =================================================

            default: begin
                C     = 16'b0;
                Flags = 5'b0;
            end
        endcase
    end
end

				// ============================================================
				// ALU DEBUG SIGNALS
				// ============================================================
				assign debugAluA      = A;
				assign debugAluB      = B;
				assign debugAluCin    = Cin;
				assign debugAluOpcode = Opcode;
				assign debugAluResult = C;
				assign debugAluFlags  = Flags;
				assign debugAluReset  = reset;

endmodule
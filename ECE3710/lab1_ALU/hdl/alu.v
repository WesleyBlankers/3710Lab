`include "params.v"

module alu (
    A,
    B,
    Cin,
    Opcode,
    C,
    Flags
);

    input  [15:0] A, B;
    input         Cin;
    input  [7:0]  Opcode;

    output reg [15:0] C;
    output reg [4:0]  Flags;

    // Flags:
    // Flags[4] = C (Carry)
    // Flags[3] = L (Less-than unsigned)
    // Flags[2] = F (Overflow)
    // Flags[1] = Z (Zero)
    // Flags[0] = N (Negative / less-than signed)


    always @(A, B, Opcode) begin

        // Default values
        C     = 16'b0;
        Flags = 5'b0;

        casex (Opcode)

            // =================================================
            // ADDITION
            // =================================================

            ADD, ADDI: begin
                C = A + B;
					 
					//Zero Flag
					 if (C == 16'b0)
						Flags[1] = 1'b1;
					 else
						Flags[1] = 1'b0; 
						
					//Signed Overflow Flag
					 if ((~A[15] & ~B[15] & C[15]) | (A[15] & B[15] &~C[15]))
						Flags[2] = 1'b1;
					 else
						Flags[2] = 1'b0;
						
				   //Reset other Flags
					  Flags[4] = 1'b0;
					  Flags[3] = 1'b0;
					  Flags[0] = 1'b0;
					 
            end


            ADDU, ADDUI: begin
                {Flags[4], C} = A + B;
					 
					//Zero Flag
						if (C == 16'b0)
							Flags[1] = 1'b1;
						else
							Flags[1] = 1'b0;
						
					//Reset Other Flags
					  Flags[3] = 1'b0;
					  Flags[2] = 1'b0;
					  Flags[0] = 1'b0;
						
            end


            ADDC, ADDCI: begin
               C = A + B + Cin;
					
					//Zero Flag
						if (C == 16'b0)
							Flags[1] = 1'b1;
						else
							Flags[1] = 1'b0;
							
					//Signed Overflow Flag
						if (( ~A[15] & ~B[15] & C[15]) | (A[15] & B[15] & ~C[15]))
							Flags[2] = 1'b1;
						else
							Flags[2] = 1'b0;
					
					//Reset Other Flags
					  Flags[4] = 1'b0;
					  Flags[3] = 1'b0;
					  Flags[0] = 1'b0;
						
					
            end

            ADDCU, ADDCUI: begin
					{Flags[4], C} = A + B + Cin;
				
					if (C == 16'b0)
						Flags[1] = 1'b1;
					else 
						Flags[1] = 1'b0;
						
					//Reset Other Flags
					  Flags[3] = 1'b0;
					  Flags[2] = 1'b0;
					  Flags[0] = 1'b0;
               
            end





            // =================================================
            // SUBTRACTION
            // =================================================

            SUB, SUBI: begin
                C = A - B;
					 
					//Zero Flag
					if (C == 16'b0)
						Flags[1] = 1'b1;
					else
						Flags[1] = 1'b0;
						
					//Overflow Flag
					if ((A[15] ^ B[15]) & (A[15] ^ C[15]))
						Flags[2] = 1'b1;
					else
						Flags[2] = 1'b0;
						
					//Reset Other Flags
					Flags[3] = 1'b0;
					Flags[0] = 1'b0;
            end

            // =================================================
            // COMPARISON
            // =================================================

            CMP: begin
                // Implement CMP
            end

            CMPI: begin
                // Implement CMPI
            end

            CMPUI: begin
                // Implement CMPUI
            end


            // =================================================
            // LOGICAL OPERATIONS
            // =================================================

            AND: begin
                // Implement AND
            end

            OR: begin
                // Implement OR
            end

            XOR: begin
                // Implement XOR
            end

            NOT: begin
                // Implement NOT
            end


            // =================================================
            // SHIFT OPERATIONS
            // =================================================

            LSH: begin
                // Implement LSH
            end

            LSHI: begin
                // Implement LSHI
            end

            ALSH: begin
                // Implement ALSH
            end


            // =================================================
            // NO OPERATION
            // =================================================

            NOP: begin
                // Implement NOP
            end

            WAIT: begin
                // Implement WAIT
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

endmodule
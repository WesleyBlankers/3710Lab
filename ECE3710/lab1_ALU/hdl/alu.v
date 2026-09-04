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

            ADD: begin
                // Implement ADD
            end

            ADDI: begin
                // Implement ADDI
            end

            ADDU: begin
                // Implement ADDU
            end

            ADDUI: begin
                // Implement ADDUI
            end

            ADDC: begin
                // Implement ADDC
            end

            ADDCU: begin
                // Implement ADDCU
            end

            ADDCUI: begin
                // Implement ADDCUI
            end

            ADDCI: begin
                // Implement ADDCI
            end


            // =================================================
            // SUBTRACTION
            // =================================================

            SUB: begin
                // Implement SUB
            end

            SUBI: begin
                // Implement SUBI
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
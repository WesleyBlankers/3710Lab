module cpu_decoder (
    input  wire [7:0] Opcode,
    output reg        Rtype,
    output reg        Itype,
    output reg        Stype,
    output reg        Ltype,
    output reg        BJtype
);


`include "params.sv"

always @(*) begin
    // Default: no instruction type selected
    Rtype = 1'b0;
	 Itype = 1'b0;
    Stype = 1'b0;
    Ltype = 1'b0;
    BJtype = 1'b0;
	 
    casex (Opcode)

        // =========================================
        // R-Type: ALU, logical, move, and shift
        // =========================================
        ADD, ADDU, ADDC, ADDCU,
		  SUB, SUBC, MUL,
		  CMP, CMPU,
		  AND, OR, XOR, NOT,
		  MOV,
		  LSH, ALSH,
		  WAIT, NOP:
				Rtype = 1'b1;
				
		  // =========================================
        // I-Type: ALU, logical, move, and shift
        // =========================================
		  ADDI, ADDUI, ADDCI, ADDCUI,
		  SUBI, SUBCI, MULI,
		  CMPI, CMPUI,
		  ANDI, ORI, XORI,
		  MOVI, LUI,
		  LSHI, ASHUI:
				 Itype = 1'b1;

        // =========================================
        // S-Type: Store instructions
        // =========================================
        STOR, SPR:
            Stype = 1'b1;

        // =========================================
        // L-Type: Load instructions
        // =========================================
        LOAD, LPR, SNXB, ZRXB:
            Ltype = 1'b1;

        // =========================================
        // Branch / Jump instructions
        // =========================================
        SCOND, BCOND, JCOND, JAL, RETX, EXCP:
            BJtype = 1'b1;

        // =========================================
        // Other system instructions
        // =========================================
        TBIT, TBITI, DI, EI:
            Rtype = 1'b1;

        // Unrecognized opcode: all outputs remain zero
        default: begin
            Rtype = 1'b0;
				Itype = 1'b0;
            Stype = 1'b0;
            Ltype = 1'b0;
            BJtype = 1'b0;
        end

		endcase
	end
endmodule
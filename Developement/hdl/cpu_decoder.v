module cpu_decoder (
    input  wire [7:0] Opcode,
    output reg        Rtype,
    output reg        Itype,
    output reg        Stype,
    output reg        Ltype,
    output reg        Btype,
	 output reg			 Jtype,
	 output reg			 Ctype,
	 output reg			 CItype
);

`include "params.sv"

always @(*) begin

    // Default: no instruction type selected
    Rtype  = 1'b0;
    Itype  = 1'b0;
    Stype  = 1'b0;
    Ltype  = 1'b0;
    Btype  = 1'b0;
	 Jtype  = 1'b0;
	 Ctype  = 1'b0;
	 CItype = 1'b0;


        casex (Opcode)

            // =========================================
            // R-Type: ALU, logical, move, and shift
            // =========================================
            ADD, ADDU, ADDC, ADDCU,
            SUB, SUBC, MUL,
            AND, OR, XOR, NOT,
            MOV,
            LSH, ALSH:
                Rtype = 1'b1;

            // =========================================
            // I-Type: ALU, logical, move, and shift
            // =========================================
            ADDI, ADDUI, ADDCI, ADDCUI,
            SUBI, SUBCI, MULI,
            ANDI, ORI, XORI,
            MOVI, LUI,
            LSHI, ASHUI:
                Itype = 1'b1;
					 
            // =========================================
            // C-Type: Compare Instructions.
            // =========================================
				CMP, CMPU:
					 Ctype = 1'b1;
				
            // =========================================
            // CU-Type: ALU, logical, move, and shift
            // =========================================
				CMPI, CMPUI:
					 CItype = 1'b1;
				
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
            // B-Type: Branch instructions
            // =========================================
            BCOND:
                Btype = 1'b1;
					 
				// =========================================
            // J-Type: Jump instructions
            // =========================================
            SCOND, JCOND, JAL, RETX, EXCP:
                Jtype = 1'b1;

            // =========================================
            // Other system instructions
            // =========================================
            TBIT, TBITI, DI, EI:
                Rtype = 1'b1;

            // =========================================
            // Unrecognized opcode
            // =========================================
            default: begin
                Rtype  = 1'b0;
                Itype  = 1'b0;
                Stype  = 1'b0;
                Ltype  = 1'b0;
                Btype  = 1'b0;
                Jtype  = 1'b0;
					 Ctype  = 1'b0;
					 CItype = 1'b0;

            end

        endcase

end

endmodule
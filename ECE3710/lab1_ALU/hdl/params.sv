// ============================================================
// EECS 427 RISC PROCESSOR
// Instruction / Opcode Definitions
// ============================================================

// ------------------------------------------------------------
// Register ALU Operations
// Format:
// 15-12   11-8    7-4     3-0
// OP      Rdest   Ext     Rsrc
// ------------------------------------------------------------

// ------------------------------------------------------------
// Immediate ALU Operations
// Format:
// 15-12   11-8    7-4     3-0
// OP      Rdest   ImmHi   ImmLo
// ------------------------------------------------------------

// ============================================================
// REGISTER OPERATIONS
// [7:4] = Extended Opcode
// [3:0] = Source Register
// ============================================================

`ifndef PARAMS_SV
`define PARAMS_SV

// Arithmetic
parameter ADD    = 8'b0000_0101;//
parameter ADDI   = 8'b0101_XXXX;//
parameter ADDU   = 8'b0000_0110;//
parameter ADDUI  = 8'b0110_XXXX;//
parameter ADDC   = 8'b0000_0111;//
parameter ADDCU  = 8'b0000_1111;// This is an unused OPCODE 4, do not repeat implementation.//
parameter ADDCUI = 8'b0100_1111;// This is an unused OPCODE 5, do not repeat implementation.//
parameter ADDCI  = 8'b0111_XXXX;//
parameter SUB    = 8'b0000_1001;//
parameter SUBI   = 8'b1001_XXXX;//
parameter SUBC   = 8'b0000_1010;
parameter SUBCI  = 8'b1010_XXXX;
parameter MUL    = 8'b0000_1110;
parameter MULI   = 8'b1110_XXXX;
parameter CMP    = 8'b0000_1011;//
parameter CMPI   = 8'b1011_XXXX;//
parameter CMPU   = 8'b1000_0101;// This is an unused OPCODE 6, do not repeat implementation.//
parameter CMPUI  = 8'b0000_1000;// This is an unused OPCODE 1, do not repeat implementation.//

// Logical
parameter AND    = 8'b0000_0001;//
parameter ANDI   = 8'b0001_XXXX;
parameter OR     = 8'b0000_0010;//
parameter ORI    = 8'b0010_XXXX;
parameter XOR    = 8'b0000_0011;//
parameter XORI   = 8'b0011_XXXX;
parameter NOT    = 8'b0000_0100; // This is an unused OPCODE 2, do not repeat implementation.//

// Move
parameter MOV    = 8'b0000_1101;
parameter MOVI   = 8'b1101_XXXX;
parameter LUI    = 8'b1111_XXXX;

// Shift
parameter LSH    = 8'b1000_0100;//
parameter LSHI   = 8'b1000_000X;//
parameter ALSH   = 8'b1000_0110;
parameter ASHUI  = 8'b1000_001X;

// Memory
parameter LOAD   = 8'b0100_0000;
parameter STOR   = 8'b0100_0100;
parameter SNXB   = 8'b0100_0010;
parameter ZRXB   = 8'b0100_0110;

// Control Flow
parameter Scond  = 8'b0100_1101;
parameter Bcond  = 8'b1100_XXXX;
parameter Jcond  = 8'b0100_1100;
parameter JAL    = 8'b0100_1000;

// System / Special
parameter TBIT   = 8'b0100_1010;
parameter TBITI  = 8'b0100_1110;
parameter LPR    = 8'b0100_0001;
parameter SPR    = 8'b0100_0101;
parameter DI     = 8'b0100_0011;
parameter EI     = 8'b0100_0111;
parameter EXCP   = 8'b0100_1011;
parameter RETX   = 8'b0100_1001;
parameter WAIT   = 8'b0000_0000;//
parameter NOP 	  = 8'b0000_1100; // This is an unused OPCODE 3, do not repeat implementation.

`endif
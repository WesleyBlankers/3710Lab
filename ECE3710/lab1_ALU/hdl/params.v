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

`ifndef PARAMS_V
`define PARAMS_V

// ============================================================
// REGISTER OPERATIONS
// [7:4] = Extended Opcode
// [3:0] = Source Register
// ============================================================

// Arithmetic Instructions
//We changed these "parameters" to "`define" for now
`define ADD   = 8'b0000_0101; 
`define ADDI  = 8'b0101_XXXX; 
`define ADDU  = 8'b0000_0110; 
`define ADDUI = 8'b0110_XXXX; 
`define ADDC  = 8'b0000_0111; 
`define ADDCI = 8'b0111_XXXX; 
`define SUB   = 8'b0000_1001; 
`define SUBI  = 8'b1001_XXXX; 
`define SUBC  = 8'b0000_1010; 
`define SUBCI = 8'b1010_XXXX; 
`define MUL   = 8'b0000_1110; 
`define MULI  = 8'b1110_XXXX; 
`define CMP   = 8'b0000_1011; 
`define CMPI  = 8'b1011_XXXX;
`define CMPUI = 8'b0000_1000; // This is an unused OPCODE, do not repeat implementation.


// Logical Instructions
`define AND   = 8'b0000_0001; 
`define ANDI  = 8'b0001_XXXX; 
`define OR    = 8'b0000_0010; 
`define ORI   = 8'b0010_XXXX; 
`define XOR   = 8'b0000_0011; 
`define XORI  = 8'b0011_XXXX; 
`define NOT	 = 8'b0000_0100; // This is an unused OPCODE, do not repeat implementation.

// Move & Immediate Load
`define MOV   = 8'b0000_1101; 
`define MOVI  = 8'b1101_XXXX; 
`define LUI   = 8'b1111_XXXX; 

// Shift Instructions (Bit 0 of extension is the 's' sign bit)
`define LSH   = 8'b1000_0100; 
`define LSHI  = 8'b1000_000X; 
`define ASHU  = 8'b1000_0110; 
`define ASHUI = 8'b1000_001X; 

// Memory & Extension Instructions
`define LOAD  = 8'b0100_0000; 
`define STOR  = 8'b0100_0100; 
`define SNXB  = 8'b0100_0010; 
`define ZRXB  = 8'b0100_0110; 

// Control Flow (Branch / Jump)
`define Scond = 8'b0100_1101; 
`define Bcond = 8'b1100_XXXX; 
`define Jcond = 8'b0100_1100; 
`define JAL   = 8'b0100_1000; 

// System / Special Instructions
`define TBIT  = 8'b0100_1010; 
`define TBITI = 8'b0100_1110; 
`define LPR   = 8'b0100_0001; 
`define SPR   = 8'b0100_0101; 
`define DI    = 8'b0100_0011; 
`define EI    = 8'b0100_0111; 
`define EXCP  = 8'b0100_1011; 
`define RETX  = 8'b0100_1001; 
`define WAIT  = 8'b0000_0000;
`endif
module alu( A, B, Cin, C, Opcode, Flags);

input [15:0] A, B;
input Cin;
input [7:0] Opcode;

output reg [15:0] C;

// C = Carry bit
// L = Low flag
// F = Flag bit
// Z = Z bit
// N = Negative bit
output reg [4:0] Flags;

parameter ADD = 
parameter ADDI =
parameter ADDU = 
parameter ADDUI =
parameter ADDC = 
parameter ADDCU =
parameter ADDCUI =
parameter SUB =  
parameter SUBI = 
parameter CMP =
parameter CMPI = 
parameter CMPU =
parameter AND = 
parameter OR = 
parameter XOR = 
parameter NOT =
parameter LSH =
parameter LSHI =
parameter ALSH =
parameter WAIT =
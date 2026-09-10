`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:25:01 08/30/2011
// Design Name:   alu
// Module Name:   C:/Documents and Settings/Administrator/ALU/alutest.v
// Project Name:  ALU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: alu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module alutest;

	// Inputs
	reg [15:0] A,B;
	reg [7:0] Opcode;
	reg Cin;
	// Outputs
	wire [15:0] C;
   wire [4:0] Flags;

	integer i;
	
	// Instantiate the Unit Under Test (UUT)
	alu uut (
		.A(A), 
		.B(B), 
		.Cin(Cin), 
		.C(C),
		.Opcode(Opcode), 
		.Flags(Flags)
	);
 // Flags:
    // Flags[4] = C (Carry)
    // Flags[3] = L (Less-than unsigned)
    // Flags[2] = F (Overflow
    // Flags[1] = Z (Zero)
    // Flags[0] = N (Negative / less-than signed)

	 localparam ADD = 8'b0000_0101;
    localparam ADDI = 8'b0101_XXXX;
	 
	initial begin
	$monitor("A: %0d, B: %0d, C: %0d, Flags[1:0]: %b, time:%0d", A, B, C, Flags[1:0], $time );
//Instead of the $display stmt in the loop, you could use just this
//monitor statement which is executed everytime there is an event on any
//signal in the argument list.
	#10
		  A = 16'd0;
        B = 16'd0;
        Opcode = 8'd0;
        Cin = 1'b0;
	#10
	
	// Monitor automatically prints every time A, B, C, or Flags change
        $monitor("Time=%0t | Op=%h | A=%0d | B=%0d | C=%0d | Flags(C,L,F,Z,N)=%b", 
                 $time, Opcode, A, B, C, Flags);

        #10; // Wait 10 ns

   
		  
		

    // 1. ADD: Signed Addition (15 + -10 = 5)
    A = 16'sd15;
    B = -16'sd10;
    Opcode = ADD;
    #10;

    // 2. ADDI: Add Immediate (10 + 3 = 13)
    A = 16'sd10;
	 B = 16'sd3;
    Opcode = ADDI; 
    #10;

    // 3. ADDU: Unsigned Addition (65530 + 10 = 65540 -> Carry Out)
    A = 16'hFFFE; 
    B = 16'h000A;
    Opcode = ADDU;
    #10;

    // 4. ADDUI: Add Immediate Unsigned (100 + 5 = 105)
    A = 16'd100;
	 B = 16'd5;
    Opcode = ADDUI; 
    #10;

    // 5. ADDC: Add with Carry (10 + 20 + 1 = 31)
    A = 16'd10;
    B = 16'd20;
    Cin = 1'b1;
    Opcode = ADDC;
    #10;

    // 6. ADDCI: Add with Carry Immediate (10 + 2 + 1 = 13)
    A = 16'd10;
	 B = 16'd2;
    Cin = 1'b1;
    Opcode = ADDCI; 
    #10;

    // 7. SUB: Signed Subtraction (20 - 5 = 15)
    Cin = 1'b0;
    A = 16'sd20;
    B = 16'sd5;
    Opcode = SUB;
    #10;

    // 8. SUBI: Subtract Immediate (20 - 4 = 16)
    A = 16'sd20;
	 B = 16'sd4;
    Opcode = SUBI; 
    #10;

    // 9. SUBC: Subtract with Carry/Borrow (20 - 5 - 1 = 14)
    A = 16'sd20;
    B = 16'sd5;
    Cin = 1'b1;
    Opcode = SUBC;
    #10;

    // 10. SUBCI: Subtract with Carry Immediate (20 - 2 - 1 = 17)
    A = 16'sd20;
	 B = 16'sd2;
    Cin = 1'b1;
    Opcode = SUBCI; 
    #10;

    // 11. MUL: Signed Multiplication (6 * 7 = 42)
    Cin = 1'b0;
    A = 16'sd6;
    B = 16'sd7;
    Opcode = MUL;
    #10;

    // 12. MULI: Multiply Immediate (5 * 3 = 15)
    A = 16'sd5;
	 B = 16'sd3;
    Opcode = MULI; 
    #10;

    // 13. CMP: Compare Signed (Compare 10 and 20 -> A < B, sets N/L flags)
    A = 16'sd10;
    B = 16'sd20;
    Opcode = CMP;
    #10;

    // 14. CMPI: Compare Immediate Signed (Compare 15 and 5 -> A > B)
    A = 16'sd15;
	 B = 16'sd5;
    Opcode = CMPI;
    #10;

    $stop;
end
		  /*
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
*/
        // 5. End Simulation
        $stop;
   

	end
      
endmodule


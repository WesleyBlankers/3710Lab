`timescale 1ns / 1ps

module alu_tb;
`include "../hdl/params.sv"
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

	initial begin

	#10
		  A = 16'd0;
        B = 16'd0;
        Opcode = 8'd0;
        Cin = 1'b0;
	#10
	
	// Monitor automatically prints every time A, B, C, or Flags change
        $monitor("Time=%0t | Op=%h | A=%0d | B=%0d | C=%0d |Cin=%0d | Flags(C,L,F,Z,N)=%b", 
                 $time, Opcode, A, B, C, Cin, Flags);

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

    // 3. ADDU: Unsigned Addition (65530 + 10 = 4 -> Carry Out)
    A = 16'd65530; 
    B = 16'd10;
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

   //We don't need MUL or MULI yet. 
   /* // 11. MUL: Signed Multiplication (6 * 7 = 42)
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
*/ 
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
	 
	 
		#10;
        // 15. CMPIU: Compare Immediate Unsigned (A = 10, B = 20 -> A < B)
        // Expected: Sets Unsigned Less-than flag (L = 1), Zero flag (Z = 0)
        A = 16'd10;
        B = 16'd20;
        Cin = 1'b0;
        Opcode = CMPUI;
        
        #10;
        // 16. CMPIU: Compare Immediate Unsigned (A = 65535, B = 5 -> A > B)
        // Crucial Test: Verifies 65535 is treated as Unsigned (+65535), NOT Signed (-1)
        // Expected: Sets Unsigned Less-than flag (L = 0), Zero flag (Z = 0)
        A = 16'd65535;
        B = 16'd5;
        Cin = 1'b0;
        Opcode = CMPUI;

        #10;
        // 17. CMPIU: Compare Immediate Unsigned (A = 100, B = 100 -> A == B)
        // Expected: Sets Zero flag (Z = 1), Unsigned Less-than flag (L = 0)
        A = 16'd100;
        B = 16'd100;
        Cin = 1'b0;
        Opcode = CMPUI;
		  
		  ///Tests for Logic Operators:
		    
		  #10;
        // 18. AND: Bitwise AND (12 AND 10 = 8)
        // Binary: 0000_0000_0000_1100 & 0000_0000_0000_1010 = 0000_0000_0000_1000
        // Expected Result: C = 8 | Flags: Zero (Z = 0)
        A = 16'd12;
        B = 16'd10;
        Cin = 1'b0;
        Opcode = AND;
		  
		  #10;
        // 19. AND: Bitwise AND resulting in Zero (15 AND 0 = 0)
        // Expected Result: C = 0 | Flags: Zero (Z = 1)
        A = 16'd15;
        B = 16'd0;
        Cin = 1'b0;
        Opcode = AND;
		  
		  #10;
        // 20. AND: Bitwise AND resulting in Ones (15 AND 15 = 15)
        // Expected Result: C = 15 | Flags: Zero (Z = 0)
        A = 16'd15;
        B = 16'd15;
        Cin = 1'b0;
        Opcode = AND;
		  
		  // OR tests:
		  #10;
        // 21. OR: Bitwise OR (12 OR 10 = 14)
        // Binary: 0000_0000_0000_1100 | 0000_0000_0000_1010 = 0000_0000_0000_1110
        // Expected Result: C = 14 | Flags: Zero (Z = 0)
        A = 16'd12;
        B = 16'd10;
        Cin = 1'b0;
        Opcode = OR;

        #10;
        // 22. OR: Bitwise OR with Zero Result (0 OR 0 = 0)
        // Expected Result: C = 0 | Flags: Zero (Z = 1)
        A = 16'd0;
        B = 16'd0;
        Cin = 1'b0;
        Opcode = OR;
		  
		  #10;
        // 22. OR: Bitwise OR with Ones Result (1 OR 0 = 1)
        // Expected Result: C = 1 | Flags: Zero (Z = 0)
        A = 16'd1;
        B = 16'd0;
        Cin = 1'b0;
        Opcode = OR;
		  
		  //XOR tests: 
		  
        #10;
        // 23. XOR: Bitwise XOR (12 XOR 10 = 6)
        // Binary: 0000_0000_0000_1100 ^ 0000_0000_0000_1010 = 0000_0000_0000_0110
        // Expected Result: C = 6 | Flags: Zero (Z = 0)
        A = 16'd12;
        B = 16'd10;
        Cin = 1'b0;
        Opcode = XOR;

        #10;
        // 24. XOR: Bitwise XOR with identical values resulting in Zero (15 XOR 15 = 0)
        // Expected Result: C = 0 | Flags: Zero (Z = 1)
        A = 16'd15;
        B = 16'd15;
        Cin = 1'b0;
        Opcode = XOR;
		  
		    #10;
        // 25. XOR: Bitwise XOR with identical values resulting in Zero (15 XOR 0 = 15)
        // Expected Result: C = 15 | Flags: Zero (Z = 0)
        A = 16'd15;
        B = 16'd0;
        Cin = 1'b0;
        Opcode = XOR;
		  
		  //Not Tests: 
		  #10;
        // 26. NOT: Bitwise NOT of 0 (~0 = 65535 or -1 signed)
        // Binary: ~0000_0000_0000_0000 = 1111_1111_1111_1111
        // Expected Result: C = 65535 (-1) | Flags: Zero (Z = 0)
        A = 16'd0;
        B = 16'd0;
        Cin = 1'b0;
        Opcode = NOT;

        #10;
        // 27. NOT: Bitwise NOT of 65535 (~65535 = 0)
        // Binary: ~1111_1111_1111_1111 = 0000_0000_0000_0000
        // Expected Result: C = 0 | Flags: Zero (Z = 1)
        A = 16'd65535;
        B = 16'd0;
        Cin = 1'b0;
        Opcode = NOT;

        #10;
        // 28. NOT: Bitwise NOT of a positive value (~15 = 65520 or -16 signed)
        // Binary: ~0000_0000_0000_1111 = 1111_1111_1111_0000
        // Expected Result: C = 65520 (-16) | Flags: Zero (Z = 0)
        A = 16'd15;
        B = 16'd0;
        Cin = 1'b0;
        Opcode = NOT;
		  
		  //Shift Operations tests:
		  
		  #10;
        // 29. LSH: Logical Shift Left by 2 bits (5 << 2 = 20)
        // Binary: 0000_0000_0000_0101 << 2 = 0000_0000_0001_0100
        // Expected Result: C = 20 | Flags: Zero (Z = 0)
        A = 16'd5;
        B = 16'd2;
        Cin = 1'b0;
        Opcode = LSH;

        #10;
        // 30. LSH: Logical Shift Right by 2 bits (20 >> 2 = 5)
        // Binary: 0000_0000_0001_0100 >> 2 = 0000_0000_0000_0101
        // Expected Result: C = 5 | Flags: Zero (Z = 0)
        A = 16'd20;
        B = -16'sd2;       
        Cin = 1'b0;
        Opcode = LSH;

        #10;
        // 31. LSH: Shift completely out resulting in Zero (1 << 16 = 0)
        // Expected Result: C = 0 | Flags: Zero (Z = 1)
        A = 16'd1;
        B = 16'd16;
        Cin = 1'b0;
        Opcode = LSH;

        #10;
        // 32. LSHI: Logical Shift Immediate Left by 3 bits (3 << 3 = 24)
        // Binary: 0000_0000_0000_0011 << 3 = 0000_0000_0001_1000
        // Expected Result: C = 24 | Flags: Zero (Z = 0)
        A = 16'd3;
        B = 16'd3;          // Immediate shift count
        Cin = 1'b0;
        Opcode = LSHI;
		  
		  //ALSH tests (Keeps signed values when shifting right). 
		  #10;
        // 33. ALSH: Arithmetic Shift Left Positive Value (5 <<< 2 = 20)
        // Binary: 0000_0000_0000_0101 <<< 2 = 0000_0000_0001_0100
        // Expected Result: C = 20 | Flags: Zero (Z = 0)
        A = 16'sd5;
        B = 16'sd2;
        Cin = 1'b0; 
        Cin = 1'b0;
        Opcode = ALSH;

        #10;
        // 34. ALSH: Arithmetic Shift Right Positive Value (20 >>> 2 = 5)
        // Binary: 0000_0000_0001_0100 >>> 2 = 0000_0000_0000_0101
        // Expected Result: C = 5 | Flags: Zero (Z = 0)
        A = 16'sd20;
        B = -16'sd2;       // Negative shift count indicates right shift
        Cin = 1'b0;
        Opcode = ALSH;

        #10;
        // 35. ALSH: Arithmetic Shift Right Negative Value (-16 >>> 2 = -4)
        // Sign Extension Check: MSB (1) is replicated into shifted bits.
        // Binary: 1111_1111_1111_0000 >>> 2 = 1111_1111_1111_1100 (-4)
        // Expected Result: C = -4 (65532) | Flags: Zero (Z = 0)
        A = -16'sd16;
        B = -16'sd2;       // Negative shift count indicates right shift
        Cin = 1'b0;
        Opcode = ALSH;
		  
		  
    $stop;
end
endmodule


module datapath(
    input  wire [3:0]  selectA,
    input  wire [3:0]  selectB,

    input  wire [15:0] RegisterEnables,
    input  wire        ImmediateMutiplexorControl,
	 input  wire		  ALUMultiplexorControl,
	 input  wire [15:0] BramReadValue,

    input  wire [15:0] Immediate,
    input  wire [7:0]  Opcode,

	 output wire [4:0]  FlagsRegister,
	 output wire [15:0] Ra,
	 output wire [15:0] Rb,
	 	 
    input  wire        clk,
    input  wire        reset,
	 output wire [15:0] debugALUBus,
	 output wire [15:0] debugR0,
	 output wire [15:0] debugR1,
	 output wire [15:0] debugR2,
	 output wire [15:0] debugR3,
	 output wire [15:0] debugR4,
	 output wire [15:0] debugR5,
	 output wire [15:0] debugR6,
	 output wire [15:0] debugR7,
	 output wire [15:0] debugR8,
	 output wire [15:0] debugR9,
	 output wire [15:0] debugR10,
	 output wire [15:0] debugR11,
	 output wire [15:0] debugR12,
	 output wire [15:0] debugR13,
	 output wire [15:0] debugR14,
	 output wire [15:0] debugR15
	 
);
	
    // ============================================================
    // Register File Outputs
    // ============================================================

    wire [15:0] r0;
    wire [15:0] r1;
    wire [15:0] r2;
    wire [15:0] r3;
    wire [15:0] r4;
    wire [15:0] r5;
    wire [15:0] r6;
    wire [15:0] r7;
    wire [15:0] r8;
    wire [15:0] r9;
    wire [15:0] r10;
    wire [15:0] r11;
    wire [15:0] r12;
    wire [15:0] r13;
    wire [15:0] r14;
    wire [15:0] r15;
	 
	 assign debugR0  = r0;
	 assign debugR1  = r1;
 	 assign debugR2  = r2;
	 assign debugR3  = r3;
	 assign debugR4  = r4;
	 assign debugR5  = r5;
	 assign debugR6  = r6;
	 assign debugR7  = r7;
	 assign debugR8  = r8;
	 assign debugR9  = r9;
	 assign debugR10 = r10;
	 assign debugR11 = r11;
	 assign debugR12 = r12;
	 assign debugR13 = r13;
	 assign debugR14 = r14;
	 assign debugR15 = r15;

    // ============================================================
    // ALU Inputs
    // ============================================================

    wire [15:0] ALUA;
    wire [15:0] ALUB;
	 wire Cin;

    // ============================================================
    // ALU Outputs
    // ============================================================

    wire [15:0] ALUResult;
    wire [4:0]  ALUFlags;

    // ============================================================
    // Register File
    // ============================================================

	 wire [15:0] ALUBus; 
	 assign ALUBus = ALUMultiplexorControl ? BramReadValue : ALUResult;
	 
    regfile_2D_memory regfile (
        .ALUBus(ALUBus),

        .r0(r0),
        .r1(r1),
        .r2(r2),
        .r3(r3),
        .r4(r4),
        .r5(r5),
        .r6(r6),
        .r7(r7),
        .r8(r8),
        .r9(r9),
        .r10(r10),
        .r11(r11),
        .r12(r12),
        .r13(r13),
        .r14(r14),
        .r15(r15),

        .regEnable(RegisterEnables),
        .clk(clk),
        .reset(reset)
    );


		// ============================================================
		// ALU A Input MUX
		// ============================================================

		wire [15:0] selectedA;

		mux muxA (
			 .r0(r0),
			 .r1(r1),
			 .r2(r2),
			 .r3(r3),
			 .r4(r4),
			 .r5(r5),
			 .r6(r6),
			 .r7(r7),
			 .r8(r8),
			 .r9(r9),
			 .r10(r10),
			 .r11(r11),
			 .r12(r12),
			 .r13(r13),
			 .r14(r14),
			 .r15(r15),

			 .MUXcontrol(selectA),
			 .MUXoutput(selectedA)
		);


	 // ============================================================
	 // ALU B Input MUX
	 // ============================================================

	 wire [15:0] selectedB;

	 mux muxB (
			 .r0(r0),
			 .r1(r1),
			 .r2(r2),
			 .r3(r3),
			 .r4(r4),
			 .r5(r5),
			 .r6(r6),
			 .r7(r7),
			 .r8(r8),
			 .r9(r9),
			 .r10(r10),
			 .r11(r11),
			 .r12(r12),
			 .r13(r13),
			 .r14(r14),
			 .r15(r15),

			 .MUXcontrol(selectB),
			 .MUXoutput(selectedB)
		);
		
		assign Ra = selectedA;
		assign Rb = selectedB;


    // ============================================================
    // Immediate/Register Selection
    // ============================================================

    assign ALUA = selectedA;
    assign ALUB = ImmediateMutiplexorControl ? Immediate : selectedB;
	 assign Cin = FlagsRegister[4];


    // ============================================================
    // ALU
    // ============================================================

    alu alu_unit (
        .A(ALUA),
        .B(ALUB),
        .Cin(Cin),
        .Opcode(Opcode),
        .C(ALUResult),
        .Flags(ALUFlags),
		  .reset(reset)
    );


    // ============================================================
    // ALU Result Bus
    // ============================================================

	 assign debugALUBus = ALUResult;

    // ============================================================
    // Flag Register
    // ============================================================

    flagReg flag_register (
        .ALUFlags(ALUFlags),
        .FlagsOut(FlagsRegister),
        .clk(clk),
        .reset(reset)
    );

endmodule
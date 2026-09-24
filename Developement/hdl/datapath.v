module datapath(
    input  wire [3:0]  selectA,
    input  wire [3:0]  selectB,

    input  wire [15:0] registerEnables,

    input  wire        immediateEnable,

    input  wire [15:0] immediate,
    input  wire [7:0]  Opcode,

	 output wire [4:0] aluFLAGOutput,
	 output wire [15:0] aluResult,
	 	 
    input  wire        clk,
    input  wire        reset
	 
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

    regfile_2D_memory regfile (
        .ALUBus(ALUResult),

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

        .regEnable(registerEnables),
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


    // ============================================================
    // Immediate/Register Selection
    // ============================================================

    assign ALUA = selectedA;
    assign ALUB = immediateEnable ? immediate : selectedB;
	 assign Cin = aluFLAGOutput[4];


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

	 assign aluResult = ALUResult;

    // ============================================================
    // Flag Register
    // ============================================================

    flagReg flag_register (
        .ALUFlags(ALUFlags),
        .FlagsOut(aluFLAGOutput),
        .clk(clk),
        .reset(reset)
    );

endmodule
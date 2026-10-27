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
	 output wire [15:0] aluResult,
	 output wire [15:0] Ra,
	 output wire [15:0] Rb,
	 	 
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

	 assign aluResult = ALUResult;

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
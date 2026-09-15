module datapath(
    input  wire [3:0]  selectA,
    input  wire [3:0]  selectB,

    input  wire [15:0] registerEnables,

    input  wire        immediateEnable,

    input  wire [15:0] immediate,
    input  wire [7:0]  Opcode,
    input  wire        Cin,

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
    // Selects one of the 16 registers
    // ============================================================

	reg [15:0] selectedA;

	always @(*) begin
		 if (reset)
			  selectedA = 16'd0;
		 else begin
			  case (selectA)
					4'd0:  selectedA = r0;
					4'd1:  selectedA = r1;
					4'd2:  selectedA = r2;
					4'd3:  selectedA = r3;
					4'd4:  selectedA = r4;
					4'd5:  selectedA = r5;
					4'd6:  selectedA = r6;
					4'd7:  selectedA = r7;
					4'd8:  selectedA = r8;
					4'd9:  selectedA = r9;
					4'd10: selectedA = r10;
					4'd11: selectedA = r11;
					4'd12: selectedA = r12;
					4'd13: selectedA = r13;
					4'd14: selectedA = r14;
					4'd15: selectedA = r15;
					default: selectedA = 16'd0;
			  endcase
		 end
	end


    // ============================================================
    // ALU B Input MUX
    // Selects one of the 16 registers
    // ============================================================

	reg [15:0] selectedB;

	always @(*) begin
		 if (reset)
			  selectedB = 16'd0;
		 else begin
			  case (selectB)
					4'd0:  selectedB = r0;
					4'd1:  selectedB = r1;
					4'd2:  selectedB = r2;
					4'd3:  selectedB = r3;
					4'd4:  selectedB = r4;
					4'd5:  selectedB = r5;
					4'd6:  selectedB = r6;
					4'd7:  selectedB = r7;
					4'd8:  selectedB = r8;
					4'd9:  selectedB = r9;
					4'd10: selectedB = r10;
					4'd11: selectedB = r11;
					4'd12: selectedB = r12;
					4'd13: selectedB = r13;
					4'd14: selectedB = r14;
					4'd15: selectedB = r15;
					default: selectedB = 16'd0;
			  endcase
		 end
	end


    // ============================================================
    // Immediate/Register Selection
    // ============================================================

    assign ALUA = selectedA;

    assign ALUB = immediateEnable ? immediate : selectedB;


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
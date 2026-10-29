
module cpu #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 16,
    parameter MEM_FILE   = "../src/bram.mem"
)(
    input wire clk,
    input wire reset,

    // Existing debug output
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
	 output wire [15:0] debugR15,

    // Instruction fetch and program counter
    output wire [15:0] debugPCout,
    output wire [15:0] debugBramAddress,
    output wire [15:0] debugBramReadValue,
    output wire [15:0] debugInstruction,
    output wire [15:0] debugInstructionRegister,

    // Instruction decoder
    output wire [7:0] debugOpcode,
    output wire [7:0] debugImmediate,
    output wire [3:0] debugRsrc,
    output wire [3:0] debugRdest,

    // Datapath
    output wire [15:0] debugRa,
    output wire [15:0] debugRb,
    output wire [15:0] debugRegisterEnables,
    output wire [4:0]  debugFlagsRegister,

    // FSM control signals
    output wire debugPCEnable,
    output wire debugPCMultiplexorControl,
    output wire debugInstructionRegisterEnable,
    output wire debugInstructionRegisterMultiplexorControl,
    output wire debugImmediateMultiplexorControl,
    output wire debugALUMultiplexorControl,
    output wire debugLoadStoreMultiplexorControl,
    output wire debugBramWriteEnable
);

    // ============================================================
    // Internal Wires: Instruction, Memory, and Datapath
    // ============================================================

    // Instruction and memory interface
    wire [15:0] Instruction;
    wire [15:0] BramReadValue;
    wire [15:0] BramAddress;

    // Program counter
    wire [15:0] PCout;

    // Register file data outputs
    wire [15:0] Ra;
    wire [15:0] Rb;

    // Instruction fields
    wire [7:0] Opcode;
    wire [7:0] Immediate;
    wire [3:0] Rsrc;
    wire [3:0] Rdest;

    // ALU status flags
    wire [4:0] FlagsRegister;

    // ============================================================
    // CPU Control Signals: FSM Outputs
    // ============================================================

    wire [15:0] RegisterEnables;

    wire PCEnable;
    wire PCMultiplexorControl;
    wire InstructionRegisterEnable;
	 wire InstructionRegisterMultiplexorControl;

    wire ImmediateMutiplexorControl;
    wire ALUMultiplexorControl;
    wire LoadStoreMultiplexorControl;
    wire BramWriteEnable;

    // ============================================================
    // BRAM: Instruction and Data Memory
    // Port A is used for memory reads and writes.
    // Port B is left unconnected.
    // ============================================================

    bram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MEM_FILE(MEM_FILE)
    ) memory (
        .data_a(Ra),
        .data_b(),
        .addr_a(BramAddress[ADDR_WIDTH-1:0]),
        .addr_b(),
        .we_a(BramWriteEnable),
        .we_b(),
        .clk(clk),
        .q_a(BramReadValue),
        .q_b()
    );

    // ============================================================
    // Datapath
    // Contains the register file, ALU, and associated logic.
    // ============================================================

    datapath datapath (
        .selectA(Rsrc),
        .selectB(Rdest),
        .RegisterEnables(RegisterEnables),
        .ImmediateMutiplexorControl(ImmediateMutiplexorControl),
        .ALUMultiplexorControl(ALUMultiplexorControl),
        .BramReadValue(BramReadValue),
        .Immediate(Immediate),
        .Opcode(Opcode),
        .FlagsRegister(FlagsRegister),
        .Ra(Ra),
        .Rb(Rb),
        .clk(clk),
        .reset(reset),
		  .debugR0(debugR0),
		  .debugR1(debugR1),
		  .debugR2(debugR2),
		  .debugR3(debugR3),
		  .debugR4(debugR4),
		  .debugR5(debugR5),
		  .debugR6(debugR6),
		  .debugR7(debugR7),
		  .debugR8(debugR8),
		  .debugR9(debugR9),
		  .debugR10(debugR10),
		  .debugR11(debugR11),
		  .debugR12(debugR12),
		  .debugR13(debugR13),
		  .debugR14(debugR14),
		  .debugR15(debugR15)
    );

    // ============================================================
    // CPU Finite State Machine (FSM)
    // Decodes instructions and generates CPU control signals.
    // ============================================================

    cpu_fsm fsm (
        .clk(clk),
        .reset(reset),

        .Instruction(Instruction),
        .FlagsRegister(FlagsRegister),

        .PCEnable(PCEnable),
        .PCMultiplexorControl(PCMultiplexorControl),
        .InstructionRegisterEnable(InstructionRegisterEnable),
		  .InstructionRegisterMultiplexorControl(InstructionRegisterMultiplexorControl),
        .RegisterEnables(RegisterEnables),
        .ImmediateMutiplexorControl(ImmediateMutiplexorControl),
        .BramWriteEnable(BramWriteEnable),
        .ALUMultiplexorControl(ALUMultiplexorControl),
        .LoadStoreMultiplexorControl(LoadStoreMultiplexorControl),

        .Rdest(Rdest),
        .Rsrc(Rsrc),
        .Opcode(Opcode),
        .Immediate(Immediate)
    );

    // ============================================================
    // Program Counter (PC)
    // Updates the instruction address based on FSM control signals.
    // ============================================================

    pc pc (
        .PCEnable(PCEnable),
        .PCMultiplexorControl(PCMultiplexorControl),
        .Immediate(Immediate),
        .clk(clk),
        .reset(reset),
        .PCout(PCout)
    );
	 
	 // ============================================================
    // BRAM Address Multiplexer
    // Selects the address for instruction fetches or data access.
    // ============================================================

    assign BramAddress = LoadStoreMultiplexorControl ? Rb : PCout;
	 
	 // ============================================================
    // Instruction Register
    // Stores the current instruction fetched from BRAM.
    // ============================================================

    reg [15:0] InstructionRegister;

    always @(posedge clk or posedge reset) begin
        if (reset)
            InstructionRegister <= 16'b0;
        else if (InstructionRegisterEnable)
            InstructionRegister <= BramReadValue;
    end
	 
	 // Select between the BRAM output and the stored instruction.
    assign Instruction = InstructionRegisterMultiplexorControl ? InstructionRegister : BramReadValue;
	 
	 // Instruction fetch and program counter
    assign debugPCout = PCout;
    assign debugBramAddress = BramAddress;
    assign debugBramReadValue = BramReadValue;
    assign debugInstruction = Instruction;
    assign debugInstructionRegister = InstructionRegister;

    // Instruction decoder
    assign debugOpcode = Opcode;
    assign debugImmediate = Immediate;
    assign debugRsrc = Rsrc;
    assign debugRdest = Rdest;

    // Datapath
    assign debugRa = Ra;
    assign debugRb = Rb;
    assign debugRegisterEnables = RegisterEnables;
    assign debugFlagsRegister = FlagsRegister;

    // FSM control signals
    assign debugPCEnable = PCEnable;
    assign debugPCMultiplexorControl = PCMultiplexorControl;
    assign debugInstructionRegisterEnable = InstructionRegisterEnable;
    assign debugInstructionRegisterMultiplexorControl = InstructionRegisterMultiplexorControl;
    assign debugImmediateMultiplexorControl = ImmediateMutiplexorControl;
    assign debugALUMultiplexorControl = ALUMultiplexorControl;
    assign debugLoadStoreMultiplexorControl = LoadStoreMultiplexorControl;
    assign debugBramWriteEnable = BramWriteEnable;

endmodule
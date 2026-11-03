
module cpu #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 16,
    parameter MEM_FILE   = "../src/bram.mem"
)(
		input wire clk,
		input wire reset
);

    // ============================================================
    // Internal Wires: Instruction, Memory, and Datapath
    // ============================================================

    // Instruction and memory interface
    wire [15:0] Instruction;
    wire [15:0] BramReadValue;
    wire [15:0] BramAddress;

    // Program counter
    wire [15:0] PCOut;

    // Register file data outputs
    wire [15:0] Ra;
    wire [15:0] Rb;

    // Instruction fields
    wire [7:0] Opcode;
    wire [7:0] Immediate;
    wire [3:0] AMultiplexorControl;
    wire [3:0] BMultiplexorControl;

    // ALU status flags
    wire [4:0] FlagsRegister;
	 wire FlagsRegisterEnable;

    // ============================================================
    // CPU Control Signals: FSM Outputs
    // ============================================================

    wire [15:0] RegisterEnables;

    wire PCEnable;
    wire PCImmediateMultiplexorControl;
	 wire PCTargetMultiplexorControl;
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
        .selectA(AMultiplexorControl),
        .selectB(BMultiplexorControl),
        .RegisterEnables(RegisterEnables),
        .ImmediateMutiplexorControl(ImmediateMutiplexorControl),
        .ALUMultiplexorControl(ALUMultiplexorControl),
        .BramReadValue(BramReadValue),
        .Immediate(Immediate),
        .Opcode(Opcode),
        .FlagsRegister(FlagsRegister),
		  .FlagsRegisterEnable(FlagsRegisterEnable),
        .Ra(Ra),
        .Rb(Rb),
        .clk(clk),
        .reset(reset)
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
			.FlagsRegisterEnable(FlagsRegisterEnable),

			.PCEnable(PCEnable),
			.PCImmediateMultiplexorControl(PCImmediateMultiplexorControl),
			.PCTargetMultiplexorControl(PCTargetMultiplexorControl),
			.InstructionRegisterEnable(InstructionRegisterEnable),
			.InstructionRegisterMultiplexorControl(InstructionRegisterMultiplexorControl),
			.RegisterEnables(RegisterEnables),
			.ImmediateMutiplexorControl(ImmediateMutiplexorControl),
			.BramWriteEnable(BramWriteEnable),
			.ALUMultiplexorControl(ALUMultiplexorControl),
			.LoadStoreMultiplexorControl(LoadStoreMultiplexorControl),

			.AMultiplexorControl(AMultiplexorControl),
			.BMultiplexorControl(BMultiplexorControl),
			.Opcode(Opcode),
			.Immediate(Immediate)
 );

    // ============================================================
    // Program Counter (PC)
    // Updates the instruction address based on FSM control signals.
    // ============================================================

    pc pc (
        .PCEnable(PCEnable),
        .PCImmediateMultiplexorControl(PCImmediateMultiplexorControl),
		  .PCTargetMultiplexorControl(PCTargetMultiplexorControl),
		  .PCTarget(Rb),
        .Immediate(Immediate),
        .clk(clk),
        .reset(reset),
        .PCOut(PCOut)
    );
	 
	 // ============================================================
    // BRAM Address Multiplexer
    // Selects the address for instruction fetches or data access.
    // ============================================================

    assign BramAddress = LoadStoreMultiplexorControl ? Rb : PCOut;
	 
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

endmodule
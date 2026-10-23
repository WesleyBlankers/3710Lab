module cpu #(
	 parameter ADDR_WIDTH = 10,
	 parameter DATA_WIDTH = 16,
	 parameter MEM_FILE = "../src/bram.mem"
)(
	 input wire clk,
	 input wire reset
);


// Global wires
wire [15:0] Dout; // Connects the BRAM module to the Instruction Register
wire Instruction;
wire InstructionRegisterEnable;


// Instruction register

reg [15:0] InstructionRegister ; // Register holds the last instruction from Dout.

always @(posedge clk or posedge reset) begin
	if (reset)
		InstructionRegister <= 16'b0;
	else if (InstructionRegisterEnable)
		InstructionRegister <= Dout;
end

assign Instruction = InstructionRegisterEnable ? Dout : InstructionRegister;

// FSM wires
wire PCEnable;
wire PCMultiplexorControl;
wire [15:0] RegisterEnables;
wire ImmediateMutiplexorControl;
wire BramWriteEnable;
wire LoadStoreMultiplexorControl;
wire ALUMultiplexorControl;
wire [15:0] Immediate;

// Datapath wires
wire [15:0] Ra;
wire [15:0] Rb;
wire [3:0] Rsrc;
wire [3:0] Rdest;
wire [4:0] FlagsRegister; // Register containing most recent Flags from the ALU/Datapath
wire [15:0] aluResult;

// PC wires
wire [15:0] PCout;
wire [15:0] PCin;

wire [15:0] MemoryAddress;

assign MemoryAddress = LoadStoreMultiplexorControl ? Rb : PCout;
assign PCin = PCMultiplexorControl ? (PCout + Immediate) : (PCout + 16'd1);


bram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MEM_FILE(MEM_FILE)
    ) memory (
        .data_a(Ra),
        .data_b({DATA_WIDTH{1'b0}}),
        .addr_a(MemoryAddress[ADDR_WIDTH-1:0]),
        .addr_b({ADDR_WIDTH{1'b0}}),
        .we_a(BramWriteEnable),
        .we_b(1'b0),
        .clk(clk),
        .q_a(Dout),
        .q_b()
    );
	 
    // ============================================================
    // Datapath
    // ============================================================

    datapath datapath (
        .selectA(Rsrc),
        .selectB(Rdest),
        .registerEnables(RegisterEnables),
        .immediateEnable(ImmediateMutiplexorControl),
		  .ALUMultiplexorControl(ALUMultiplexorControl),
		  .Data_From_Mem(Dout),
        .immediate(Immediate),

        .Opcode(Opcode),

        .aluFLAGOutput(FlagsRegister),
        .aluResult(aluResult),
		  
		  .Ra(Ra),
		  .Rb(Rb),
		  
        .clk(clk),
        .reset(reset)
    );
	 
cpu_fsm fsm (
			.clk(clk),
			.reset(reset),
			
			.Instruction(Instruction),
			.FlagsRegister(FlagsRegister),
			
			.PCEnable(PCEnable),
			.PCMultiplexorControl(PCMultiplexorControl),
			.InstructionRegisterEnable(InstructionRegisterEnable),
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

pc pc (
			.PCEnable(PCEnable),
			.PCin(PCin),
			.clk(clk),
			.reset(reset),
			.PCout(PCout)
);

endmodule
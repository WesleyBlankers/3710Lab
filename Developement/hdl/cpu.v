module cpu(
// Inputs or Outputs for peripherals go here.


input reset,
input clk
);

// Instruction register
reg [15:0] IR ; // Register holds the last instruction from Dout.

// Global wires
wire [15:0] Dout; // Connects the BRAM module to FSM and Datapath.
wire Alu_Mux_Cntrl; // Controls whether the next value to store in the reg file comes from mem or the alu.

// FSM wires
wire PCen; // Enables program counter advancement. (Either PC+1 or PC+Displacement)
wire [15:0] Ren; // Register enables 
wire Ien;
wire We;
wire LSCntrl;
wire Opcode;

// Datapath wires
wire Ra;
wire Rb;
wire Rsrc;
wire Rdest;
wire [4:0] Flags; // Register containing most recent flags from the ALU/Datapath
wire immediate;

wire PCout;
wire pc; // program counter

assign pc = LSCntrl ? Rb : PCout // Mux controls whether the program counter advances or not.
assign immediate = Dout[7:0]; // Assign the lowest 8 bits to the immediate field. Regardless of instruction type.

bram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MEM_FILE(MEM_FILE)
    ) bram (
        .data_a(Ra),
        .data_b(),
        .addr_a(addr_a),
        .addr_b(),
        .we_a(We),
        .we_b(),
        .clk(clk),
        .q_a(Dout),
        .q_b()
    );
	 
    // ============================================================
    // Datapath
    // ============================================================

    datapath datapath (
        .selectA(selectA),
        .selectB(selectB),
        .registerEnables(Ren),
        .immediateEnable(Ien),
		  .Alu_Mux_Cntrl(Alu_Mux_Cntrl),
		  .Data_From_Mem(Dout),
        .immediate(immediate),

        .Opcode(Opcode),

        .aluFLAGOutput(aluFLAGOutput),
        .aluResult(aluResult),
        .clk(clk),
        .reset(reset)
    );
	 
cpu_fsm fsm(
			.Dout(Dout)
			.Flags(


);

pc pc(
			.PCen(PCen),
			.PCin(PCin),
			.clk(clk),
			.reset(reset),
			.PCout(PCout)
);
module cpu #(
	 parameter ADDR_WIDTH = 10,
	 parameter DATA_WIDTH = 16,
	 parameter MEM_FILE = "../src/bram.mem"
)(
	 input wire clk,
	 input wire reset
);


// Global wires
wire [15:0] Dout; // Connects the BRAM module to FSM and Datapath.
wire IRen;
wire [15:0] fsmInstr;


// Instruction register

reg [15:0] IR ; // Register holds the last instruction from Dout.


always @(posedge clk or posedge reset) begin
	if (reset)
		IR <= 16'b0;
	else if (IRen)
		IR <= Dout;
end

assign fsmInstr = IRen ? Dout : IR;

// FSM wires
wire PCen; // Enables program counter advancement. (Either PC+1 or PC+Displacement)
wire PC_Mux_Cntrl;
wire [15:0] Ren; // Register enables 
wire Ien;
wire We;
wire LSCntrl;
wire Alu_Mux_Cntrl;
wire flagEn;
wire [7:0] Opcode;
wire [15:0] Immediate;

// Datapath wires
wire [15:0] Ra;
wire [15:0] Rb;
wire [3:0] Rsrc;
wire [3:0] Rdest;
wire [4:0] Flags; // Register containing most recent flags from the ALU/Datapath
wire [15:0] aluResult;

// PC wires
wire [15:0] PCout;
wire [15:0] PCin;
wire [15:0] memAddress; 

assign memAddress = LSCntrl ? Rb : PCout;
assign PCin = PC_Mux_Cntrl ? (PCout + Immediate) : (PCout + 16'd1);


bram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MEM_FILE(MEM_FILE)
    ) memory (
        .data_a(Ra),
        .data_b({DATA_WIDTH{1'b0}}),
        .addr_a(memAddress[ADDR_WIDTH-1:0]),
        .addr_b({ADDR_WIDTH{1'b0}}),
        .we_a(We),
        .we_b(1'b0),
        .clk(clk),
        .q_a(Dout),
        .q_b()
    );
	 
    // ============================================================
    // Datapath
    // ============================================================

    datapath datapath (
        .selectA(Rdest),
        .selectB(Rsrc),
        .registerEnables(Ren),
        .immediateEnable(Ien),
		  .Alu_Mux_Cntrl(Alu_Mux_Cntrl),
		  .Data_From_Mem(Dout),
        .immediate(Immediate),

        .Opcode(Opcode),
		  .flagEn(flagEn),

        .aluFLAGOutput(Flags),
        .aluResult(aluResult),
		  
		  .Ra(Ra),
		  .Rb(Rb), 
		  
        .clk(clk),
        .reset(reset)
    );
	 
cpu_fsm fsm (
			.clk(clk),
			.reset(reset),
			
			.Dout(fsmInstr),
			.Flags(Flags),
			
			.PCen(PCen),
			.PC_Mux_Cntrl(PC_Mux_Cntrl),
			.IRen(IRen),
			.Ren(Ren),
			.Ien(Ien),
			.We(We),
			.ALU_Mux_Cntrl(Alu_Mux_Cntrl),
			.LSCntrl(LSCntrl),
			.flagEn(flagEn),
			
			.Rdest(Rdest),
			.Rsrc(Rsrc),
			.Opcode(Opcode),
			.Immediate(Immediate)

);

pc pc (
			.PCen(PCen),
			.PCin(PCin),
			.clk(clk),
			.reset(reset),
			.PCout(PCout)
);

endmodule
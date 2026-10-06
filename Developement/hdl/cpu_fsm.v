module cpu_fsm (
    input  wire        clk,
    input  wire        reset,          // Global reset
    input  wire [15:0] Dout,           // Fetched instruction from memory
    input  wire [5:0]  Flags,          // Flags from ALU/Status register
	 
    output reg         PCen,           // Program Counter Enable
    output reg         Ren,            // Register Write Enable
    output reg         Ien,           // Register/Immediate select 1 = immediate, 0 = register
    output reg         We,             // Memory Write Enable
    output reg         ALU_Mux_Cntrl,  // ALU Mux Control
    output reg         LSCntrl,         // Load/Store Control
	 output reg			  Rdest,
	 output reg 		  Rsrc,
	 output reg			  Opcode [7:0],
	 output reg			  Immediate [7:0]
);



	 reg isRType;
	 reg Dout8Bit [7:0];
	 
    // State Encoding
    localparam S0_FETCH   = 2'b00;
    localparam S1_DECODE  = 2'b01;
    localparam S2_EXEC_WB = 2'b10;
	
    // Opcode Extraction from Instruction (bits 15:12 assuming 4-bit opcode in 16-bit word)
    wire [3:0] opcode = Dout[15:12];

    // Example R-type Opcode (Adjust 4'b0000 to match your specific ISA definition)
    localparam OPCODE_RTYPE = 4'b0000;

    reg [1:0] current_state, next_state;
	 
	 wire [7:0] concat_opcode = {Dout[15:12], Dout[11:8]};

	 task check_rtype;
        input  [7:0] opcode_in;
        begin
            case (opcode_in)
                // Specific 8-bit binary values for R-type instructions
                01000000, 01000100, 01001000, 01001100, 01010000, 01010100, 01011000, 01011100 //These are non R Type OpCodes
					 : begin
                    isRType = 1'b0;
                end
                default: begin
                    isRType = 1'b1;
                end
            endcase
        end
    endtask
	 
    // State Register (Sequential Logic)
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= S0_FETCH;
        else
            current_state <= next_state;
    end

    // Next State Logic (Combinational)
    always @(*) begin
	 
    check_rtype(Dout, Dout8Bit);

        case (current_state)
            S0_FETCH: begin
                next_state = S1_DECODE;
            end

            S1_DECODE: begin
                // Transition to Execute + Writeback if the instruction is R-type
                if (isRType)
                    next_state = S2_EXEC_WB;
                else
                    next_state = S0_FETCH; // Default fallback
            end

            S2_EXEC_WB: begin
                next_state = S0_FETCH;
            end

            default: next_state = S0_FETCH;
        endcase
    end

    // Output Logic (Combinational)
    always @(*) begin
        // Default Outputs (De-asserted)
        PCen          = 1'b0;
        Ren           = 1'b0;
        Ien           = 1'bx;
        We            = 1'bx;
        ALU_Mux_Cntrl = 1'bx;
        LSCntrl       = 1'bx;
		  Rdest 			 = 4'bx;
		  Rsrc 			 = 4'bx;
		  Opcode        = 8'bx;
		  Immediate     = 8'bx;

        case (current_state)
            S0_FETCH: begin
                // Fetch Stage: All control signals remain disabled
		  PCen          = 1'b0;
        Ren           = 1'b0;
        Ien           = 1'bx;
        We            = 1'bx;
        ALU_Mux_Cntrl = 1'bx;
        LSCntrl       = 1'bx;
		  Rdest 			 = 4'bx;
		  Rsrc 			 = 4'bx;
		  Opcode        = 8'bx;
		  Immediate     = 8'bx;
               
            end

            S1_DECODE: begin
                // Decode Stage: Waiting for opcode evaluation
					 PCen          = 1'b0;
                Ren           = 1'b0;
                Ien           = 1'bx;
                We            = 1'b0;
                ALU_Mux_Cntrl = 1'b0;
                LSCntrl       = 1'b0;
					 Rdest 			= 4'bx;
					 Rsrc 			= 4'bx;
		          Opcode        = concat_opcode;
					 Immediate     = 8'bx;
            end

            S2_EXEC_WB: begin
                // Execute + Writeback Stage for R-type instruction
                PCen          = 1'b1; // Advance PC to next instruction
                Ren           = 1'b1; // Write ALU result back into regfile
                Ien          = 1'b0; // Select Register mode (0 = Register)
                We            = 1'b0; // Disable memory write
                ALU_Mux_Cntrl = 1'b0; // Select ALU output to write to regfile
                LSCntrl       = 1'b1; // Drive MAR from PC (+1) path
					 
            end
        endcase
    end

endmodule
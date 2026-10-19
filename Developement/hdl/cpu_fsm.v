module cpu_fsm (
    input  wire        clk,
    input  wire        reset,          // Global reset
    input  wire [15:0] Dout,           // Fetched instruction from memory
    input  wire [4:0]  Flags,          // Flags from ALU/Status register
	 
    output reg         PCen,           // Program Counter Enable
	 output reg			  PC_Mux_Cntrl,	//Select PC increment or branch target
	 output reg			  IRen,				// Instruction Register Enable
    output reg  [15:0] Ren,            // Register Write Enable
    output reg         Ien,           // Register/Immediate select 1 = immediate, 0 = register
    output reg         We,             // Memory Write Enable
    output reg         ALU_Mux_Cntrl,  // ALU Mux Control
    output reg         LSCntrl,         // Load/Store Control
	 output reg 		  flagEn,
	 output reg	 [3:0]  Rdest,
	 output reg  [3:0]  Rsrc,
	 output reg	 [7:0]  Opcode, 
	 output reg	 [15:0]  Immediate
);



	 reg isRType;
	 
    // State Encoding
    localparam S0_FETCH      = 3'b000;
    localparam S1_DECODE     = 3'b001;
    localparam S2_EXEC_WB 	  = 3'b010;
	 localparam S3_MEM_ACCESS = 3'b011;
    localparam S4_LOAD_WB    = 3'b100;
	 localparam S5_BRANCH	  = 3'b101;
	
    // Opcode Extraction from Instruction (bits 15:12 assuming 4-bit opcode in 16-bit word)
    wire [3:0] opcode = Dout[15:12];

    reg [2:0] current_state, next_state;
	 
	 wire [7:0] concat_opcode = {Dout[15:12], Dout[7:4]};
	 
	 wire isLoad = (concat_opcode == 8'b0100_0000); // LOAD
	 wire isStore = (concat_opcode == 8'b0100_0100); // STORE
	 wire isBranch = (opcode == 4'b1100);
	 
	 wire isShiftImm = (opcode == 4'b1000) && (Dout[7:5] == 3'b000); //LSHI
	 
	 wire isIType =
		(opcode == 4'b0001) || // ANDI
		(opcode == 4'b0010) || // ORI
		(opcode == 4'b0011) || // XORI
		(opcode == 4'b0101) || // ADDI
		(opcode == 4'b0110) || // ADDUI
		(opcode == 4'b0111) || // ADDCI
		(opcode == 4'b1001) || // SUBI
		(opcode == 4'b1011) ||// CMPI
		(opcode == 4'b1101) || // MOVI
		(opcode == 4'b1111) || // LUI
		isShiftImm;				  // LSHI

	 task check_rtype;
        input  [7:0] opcode_in;
        begin
        case (opcode_in)
            // R-Type Arithmetic Instructions
            8'b0000_0101, // ADD
            8'b0000_0110, // ADDU
            8'b0000_0111, // ADDC
            8'b0000_1001, // SUB     
            8'b0000_1011, // CMP

            // R-Type Logical Instructions
            8'b0000_0001, // AND
            8'b0000_0010, // OR
            8'b0000_0011, // XOR

            // R-Type Move and Shift Instructions
            8'b0000_1101, // MOV
            8'b1000_0100, // LSH
            8'b1000_0110: // ALSH
                isRType = 1'b1;

            default:
                isRType = 1'b0;
        endcase
    end
endtask

	
	 reg conditionMet;

	 always @(*) begin
		  case (Dout[11:8])
			   4'h0: conditionMet = Flags[1];               // EQ
				4'h1: conditionMet = ~Flags[1];              // NE
				4'h2: conditionMet = Flags[4];               // CS
				4'h3: conditionMet = ~Flags[4];              // CC
				4'h4: conditionMet = Flags[3];               // HI
				4'h5: conditionMet = ~Flags[3];              // LS
				4'h6: conditionMet = Flags[0];               // GT
				4'h7: conditionMet = ~Flags[0];              // LE
				4'h8: conditionMet = Flags[2];               // FS
				4'h9: conditionMet = ~Flags[2];              // FC
				4'hA: conditionMet = ~Flags[3] & ~Flags[1];  // LO
				4'hB: conditionMet = Flags[3] | Flags[1];    // HS
				4'hC: conditionMet = ~Flags[0] & ~Flags[1];  // LT
				4'hD: conditionMet = Flags[0] | Flags[1];    // GE
				4'hE: conditionMet = 1'b1;                   // UC
				default: conditionMet = 1'b0;                // Never
		  endcase
    end
	 
    // State Register (Sequential Logic)
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= S0_FETCH;
        else
            current_state <= next_state;
    end

    // Next State Logic (Combinational)
    always @(*) begin
	 
    check_rtype(concat_opcode);

        case (current_state)
            S0_FETCH: begin
                next_state = S1_DECODE;
            end

            S1_DECODE: begin
                // Transition to Execute + Writeback if the instruction is R-type
                if (isRType || isIType)
                    next_state = S2_EXEC_WB;
					 else if (isLoad || isStore)
						  next_state = S3_MEM_ACCESS;
					 else if (isBranch) 
						  next_state = S5_BRANCH;
                else
                    next_state = S0_FETCH; // Default fallback
            end
				
            S2_EXEC_WB: begin
                next_state = S0_FETCH;
            end
				
		      S3_MEM_ACCESS: begin
					 if (isLoad)
						  next_state = S4_LOAD_WB;
					 else
					     next_state = S0_FETCH;
				end
				
				S4_LOAD_WB: begin
					 next_state = S0_FETCH;
			   end
				
				S5_BRANCH: begin
				    next_state = S0_FETCH;
				end
				
            default: next_state = S0_FETCH;
        endcase
    end

    // Output Logic (Combinational)
    always @(*) begin
        // Default Outputs (De-asserted)
        PCen          = 1'b0;
		  PC_Mux_Cntrl  = 1'b0;
		  IRen			 = 1'b0;
        Ren           = 16'b0;
        Ien           = 1'bx;
        We            = 1'b0;
        ALU_Mux_Cntrl = 1'bx;
        LSCntrl       = 1'bx;
		  flagEn        = 1'b0;
		  Rdest 			 = 4'bx;
		  Rsrc 			 = 4'bx;
		  Opcode        = 8'bx;
		  Immediate     = 16'b0;

        case (current_state)
            S0_FETCH: begin
                // Fetch Stage: All control signals remain disabled
		  PCen          = 1'b0;
        Ren           = 16'b0;
        Ien           = 1'bx;
        We            = 1'b0;
        ALU_Mux_Cntrl = 1'bx;
        LSCntrl       = 1'b0;
		  Rdest 			 = 4'bx;
		  Rsrc 			 = 4'bx;
		  Opcode        = 8'bx;
		  Immediate     = 16'b0;
               
            end

            S1_DECODE: begin
                // Decode Stage: Waiting for opcode evaluation
					 PCen          = 1'b0;
					 IRen			   = 1'b1;
                Ren           = 16'b0;
                Ien           = 1'bx;
                We            = 1'b0;
                ALU_Mux_Cntrl = 1'b0;
                LSCntrl       = 1'b0;
					 Rdest 			= 4'bx;
					 Rsrc 			= 4'bx;
					 Immediate     = 16'b0;
					 Opcode        = concat_opcode;
					 
					 if (!(isRType || isIType ||
						  isLoad || isStore || isBranch))
						  PCen = 1'b1;
            end

            S2_EXEC_WB: begin
                // Execute + Writeback Stage for R-type instruction
                PCen          = 1'b1; // Advance PC to next instruction
                Ren           = 16'b1 << Dout[11:8]; // Enable destination register 
                Ien          = isIType; // 1 = immediate, 0 = register
                We            = 1'b0; // Disable memory write
                ALU_Mux_Cntrl = 1'b0; // Select ALU output to write to regfile
                LSCntrl       = 1'b0; // Drive MAR from PC (+1) path
					 
					 Rdest         = Dout[11:8];
					 Rsrc 			= Dout[3:0];
					 
					 if (isIType && !isShiftImm)
						  Opcode = {opcode, 4'b0000};
					 else
						  Opcode = concat_opcode;
						  
					 if (concat_opcode == 8'b0000_1101)
						  Rdest = Dout[3:0];
					 
					 if (isShiftImm) begin
						  Immediate = {{11{Dout[4]}}, Dout[4:0]};
					 end
					 
					 else if (isIType) begin
						case (opcode)
						// Zero-extended immediate
						4'b0001, // ANDI
						4'b0010, // ORI
						4'b0011, // XORI
						4'b1101, // MOVI
						4'b1111: //LUI
						Immediate = {8'b0, Dout[7:0]};

						// Sign-extended immediate
						default:
							Immediate = {{8{Dout[7]}}, Dout[7:0]};
					endcase
				end
				
				
					 // CMP and CMPI update flags without reg writeback
					 if ((concat_opcode == 8'b0000_1011) || (isIType && opcode == 4'b1011)) begin
						  Ren = 16'b0;
					end	  
					
					    // R-type instructions that update flags 
					case (concat_opcode)
					
						  // Arithmetic
						  8'b0000_0101, // ADD
						  8'b0000_0111, // ADDC
						  8'b0000_1001, // SUB
						  8'b0000_1011: // CMP
						  flagEn = 1'b1;

                    default: ;
					endcase
    			
					// I-type instructions that update flags
					if (isIType && ((opcode == 4'b0101) || // ADDI
						(opcode == 4'b0111) || // ADDCI
						(opcode == 4'b1001) || // SUBI
						(opcode == 4'b1011)))  // CMPI
						flagEn = 1'b1;
					end
					
				S3_MEM_ACCESS: begin
							// Memory access stage for LOAD and STORE
					 PCen          = isStore; // Advance PC after STORE
					 Ren           = 16'b0;   // Disable register writes
					 Ien           = 1'b0;
					 We            = isStore; // Write memory only for STORE
					 ALU_Mux_Cntrl = 1'b0;
					 LSCntrl       = 1'b1;    // Select register-based memory address

					 Rdest         = Dout[11:8];
					 Rsrc          = Dout[3:0];
				end
				
				S4_LOAD_WB: begin
					 // Write loaded memory data to destination register
					 PCen          = 1'b1; // Advance PC after LOAD
					 Ren           = 16'b1 << Dout[11:8]; // Enable destination register
					 Ien           = 1'b0;
					 We            = 1'b0; // Disable memory write
					 ALU_Mux_Cntrl = 1'b1; // Select memory data for writeback
					 LSCntrl       = 1'b0; // Select PC for instruction fetch

					 Rdest         = Dout[11:8];
					 Rsrc          = Dout[3:0];
				end
				
				S5_BRANCH:begin
				    // Branch execution stage
					 PCen          = 1'b1; // Update PC
					 PC_Mux_Cntrl  = conditionMet; // 1 = branch target, 0 = PC + 1
					 Ren           = 16'b0; // Disable register writes
					 Ien           = 1'b0;
					 We            = 1'b0; // Disable memory writes
					 ALU_Mux_Cntrl = 1'b0;
					 LSCntrl       = 1'b0; // Select PC for instruction fetch

					 // Sign-extend branch displacement
					 Immediate = {{8{Dout[7]}}, Dout[7:0]};
				end
        endcase
    end

endmodule
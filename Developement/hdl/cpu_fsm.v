module cpu_fsm (
    input  wire        clk,       // System clock
    input  wire        reset,     // Active-high asynchronous reset

    input  wire [15:0] Instruction,   // Instruction currently presented to the FSM
    input  wire [4:0]  FlagsRegister,  // ALU status flags: C, L, F, Z, N

    // Program counter control
    output reg         PCEnable,                    // Enables the PC to update
    output reg         PCMultiplexorControl,         // Selects PC increment or branch displacement

    // Instruction register control
    output reg         InstructionRegisterEnable,   // Enables the instruction register to capture memory data
    output reg         InstructionRegisterMultiplexorControl, // Selects which instruction source is used

    // Register file and datapath control
    output reg  [15:0] RegisterEnables,              // One-hot register write enables
    output reg         ImmediateMutiplexorControl,   // Selects immediate or register operand
    output reg         ALUMultiplexorControl,        // Selects the appropriate ALU result/data source

    // Memory control
    output reg         BramWriteEnable,              // Enables a BRAM write
    output reg         LoadStoreMultiplexorControl,  // Selects a data-memory address instead of the PC

    // Instruction fields passed to the datapath
	 output reg  [3:0]  AMultiplexorControl,     // Operand A Multiplexor Select
    output reg  [3:0]  BMultiplexorControl,    // Operand B Multiplexor Select
    output wire [7:0]  Opcode,   // Decoded operation code
    output wire [7:0]  Immediate, // Immediate value or branch displacement
	 
	 // Debug Wires
	 output wire debugRegisterInstruction,
	 output wire debugImmediateInstruction,
	 output wire debugStoreInstruction,
	 output wire debugLoadInstruction,
	 output wire debugBranchInstruction,
	 output wire debugConditionMet,
	 output wire [2:0] debugCurrentState,
	 output wire [2:0] debugNextState
);

    // ------------------------------------------------------------
    // Instruction decoding
    // ------------------------------------------------------------

    // Signals indicating which instruction class the current
    // instruction belongs to.
    wire RegisterInstruction;
    wire ImmediateInstruction;
    wire StoreInstruction;
    wire LoadInstruction;
    wire BranchInstruction;
	 
	 // CurrentState stores the active state.
    // NextState is calculated by the combinational next-state logic.
    reg [2:0] CurrentState;
    reg [2:0] NextState;

    // Indicates whether the current conditional branch should be taken.
    reg ConditionMet;
	 
    // Extract the opcode from the instruction fields.
    // This concatenation must match the instruction encoding
    // defined by the ISA.
    assign Opcode = {Instruction[15:12], Instruction[7:4]};

    // Extract the low eight bits as the immediate/displacement.
    assign Immediate = Instruction[7:0];

    // Determine the instruction class from the opcode.
    cpu_decoder decoder (
        .Opcode (Opcode),
        .Rtype  (RegisterInstruction),
        .Itype  (ImmediateInstruction),
        .Stype  (StoreInstruction),
        .Ltype  (LoadInstruction),
        .BJtype (BranchInstruction)
    );

    // ------------------------------------------------------------
    // FSM state encoding
    // ------------------------------------------------------------

    // Three bits are sufficient to represent the seven states.
    localparam FETCH   = 3'd0;  // Fetch instruction from memory
    localparam DECODE  = 3'd1;  // Determine instruction type
    localparam R_TYPE  = 3'd2;  // Execute register operation
	 localparam I_TYPE  = 3'd3;  // Execute immediate operation
    localparam STORE   = 3'd4;  // Write data to memory
    localparam LOAD_1  = 3'd5;  // Initiate memory read for a load
    localparam LOAD_2  = 3'd6;  // Write loaded data into a register
    localparam BRANCH  = 3'd7;  // Evaluate and execute a branch

    // ------------------------------------------------------------
    // Branch-condition evaluation
    // ------------------------------------------------------------

    // Flag bit assignments:
    // FlagsRegister[4] = C: Carry
    // FlagsRegister[3] = L: Unsigned less-than
    // FlagsRegister[2] = F: Overflow
    // FlagsRegister[1] = Z: Zero
    // FlagsRegister[0] = N: Negative / signed less-than
    //
    // Instruction[11:8] selects the branch condition.
    // Verify these condition definitions against the ISA specification.
    always @(*) begin
        case (Instruction[11:8])
            4'h0: ConditionMet =  FlagsRegister[1];                 		// EQ: Equal, Z = 1
            4'h1: ConditionMet = ~FlagsRegister[1];                 		// NE: Not Equal, Z = 0
            4'h2: ConditionMet =  FlagsRegister[4];                 		// CS: Carry Set, C = 1 
            4'h3: ConditionMet = ~FlagsRegister[4];                 		// CC: Carry Clear, C = 0
            4'h4: ConditionMet =  FlagsRegister[3];                 		// HI: Higher than, L = 1
            4'h5: ConditionMet = ~FlagsRegister[3];                 		// LS: Lower than or Same as, L = 0
            4'h6: ConditionMet =  FlagsRegister[0];                 		// GT: Greater than, N = 1
            4'h7: ConditionMet = ~FlagsRegister[0];                 		// LE: Less than or Equal, N = 0
            4'h8: ConditionMet =  FlagsRegister[2];                 		// FS: Flag Set, F = 1
            4'h9: ConditionMet = ~FlagsRegister[2];                 		// FC: Flag Clear, F = 0
            4'hA: ConditionMet = ~FlagsRegister[3] & ~FlagsRegister[1]; // LO: Lower than, L = 0 and Z = 0
            4'hB: ConditionMet =  FlagsRegister[3] | FlagsRegister[1];  // HS: Higher than or Same as, L = 0 or Z = 1
            4'hC: ConditionMet = ~FlagsRegister[0] & ~FlagsRegister[1]; // LT: Less than, N = 0 and Z = 0
            4'hD: ConditionMet =  FlagsRegister[0] | FlagsRegister[1];  // GE: Greater than or Equal, N = 1 or Z = 1
            4'hE: ConditionMet = 1'b1;                             		// UC: Unconditional
            default: ConditionMet = 1'b0;
        endcase
    end

    // ------------------------------------------------------------
    // State register
    // ------------------------------------------------------------

    // Advance to the calculated next state on each rising clock edge.
    // Reset immediately returns the FSM to FETCH.
    always @(posedge clk or posedge reset) begin
        if (reset)
            CurrentState <= FETCH;
        else
            CurrentState <= NextState;
    end

    // ------------------------------------------------------------
    // Next-state logic
    // ------------------------------------------------------------

    // Determine which state should follow the current state.
    // This block is combinational, so NextState must receive a
    // default assignment to avoid inferring a latch.
    always @(*) begin

        case (CurrentState)

            // Start the instruction-fetch sequence.
            FETCH: begin
                NextState = DECODE;
            end

            // Identify the instruction class and choose its execution path.
            DECODE: begin
                if (RegisterInstruction)
                    NextState = R_TYPE;
					 else if (ImmediateInstruction)
						  NextState = I_TYPE;
                else if (StoreInstruction)
                    NextState = STORE;
                else if (LoadInstruction)
                    NextState = LOAD_1;
                else if (BranchInstruction)
                    NextState = BRANCH;
                else
                    NextState = FETCH;  // Unsupported instruction
            end

            // Register operation.
            R_TYPE: begin
                NextState = FETCH;
            end
				
				// Immediate operation.
            I_TYPE: begin
                NextState = FETCH;
            end

            // Store completes after writing data to memory.
            STORE: begin
                NextState = FETCH;
            end

            // Load is split into a memory-read phase and a write-back phase.
            LOAD_1: begin
                NextState = LOAD_2;
            end

            // Finish the load by writing the data into its destination register.
            LOAD_2: begin
                NextState = FETCH;
            end

            // Branch execution completes and returns to instruction fetch.
            BRANCH: begin
                NextState = FETCH;
            end

            // Recover from an invalid state.
            default: begin
                NextState = FETCH;
            end
        endcase
    end


    // ------------------------------------------------------------
    // Output/control logic
    // ------------------------------------------------------------

    // Default every output before decoding the current state.
    // This prevents unintended latches in combinational logic.
    always @(CurrentState) begin
        PCEnable                            		= 1'b0;
        PCMultiplexorControl                		= 1'b0;
        InstructionRegisterEnable          	 	= 1'b0;
        InstructionRegisterMultiplexorControl 	= 1'b0;
        RegisterEnables                      	= 16'b0;
        ImmediateMutiplexorControl           	= 1'b0;
        BramWriteEnable                      	= 1'b0;
        ALUMultiplexorControl                	= 1'b0;
        LoadStoreMultiplexorControl          	= 1'b0;

        // These fields are irrelevant unless the active state uses them.
        // X values may help simulation expose accidental use, but use
        // 0 instead if your project requires deterministic control values.
        BMultiplexorControl = 4'bxxxx;
        AMultiplexorControl  = 4'bxxxx;

        case (CurrentState)

            // ----------------------------------------------------
            // FETCH
            // ----------------------------------------------------
            FETCH: begin
                // Fetch-stage control signals go here.
                //
                // For synchronous BRAM, remember that the memory output
                // becomes valid after the clock edge that samples its
                // address. The FSM must account for that read latency.
            end

            // ----------------------------------------------------
            // DECODE
            // ----------------------------------------------------
            DECODE: begin
                // Decode-stage control signals go here.
                // The instruction fields must remain stable while decoded.
            end

            // ----------------------------------------------------
            // RI_TYPE: register operation
            // ----------------------------------------------------
            R_TYPE: begin
                // Advance the PC after executing the instruction.
                PCEnable = 1'b1;

                // Enable writing to the destination register.
                // Shifting 1 by the destination index produces a one-hot mask.
                RegisterEnables = 16'b1 << Instruction[11:8];

                // Pass the register indices to the datapath.
					 AMultiplexorControl  = Instruction[3:0];
                BMultiplexorControl = Instruction[11:8];
            end
				
            // ----------------------------------------------------
            // I_TYPE: immediate operation
            // ----------------------------------------------------
            I_TYPE: begin
                // Advance the PC after executing the instruction.
                PCEnable = 1'b1;

                // Enable writing to the destination register.
                // Shifting 1 by the destination index produces a one-hot mask.
                RegisterEnables = 16'b1 << Instruction[11:8];

                // Select the immediate operand for immediate instructions.
                ImmediateMutiplexorControl = ImmediateInstruction;

                // Pass the register indices to the datapath.
					 AMultiplexorControl  = Instruction[11:8];
                BMultiplexorControl = Instruction[11:8];
            end

            // ----------------------------------------------------
            // STORE: write register data to memory
            // ----------------------------------------------------
            STORE: begin
                // Advance the PC after the store.
                PCEnable = 1'b1;

                // Enable writing to BRAM.
                BramWriteEnable = 1'b1;

                // Select the register containing the memory address.
                LoadStoreMultiplexorControl = 1'b1;

                // Select the registers needed by the store operation.
					 AMultiplexorControl  = Instruction[3:0];
                BMultiplexorControl = Instruction[11:8];
            end

            // ----------------------------------------------------
            // LOAD_1: initiate a memory read
            // ----------------------------------------------------
            LOAD_1: begin
                // Advance the PC according to the current CPU design.
                // Confirm that this timing matches the BRAM read latency.
                PCEnable = 1'b1;

                // Select the load address instead of the instruction PC.
                LoadStoreMultiplexorControl = 1'b1;

                // Control whether memory data or the saved instruction
                // is presented to the instruction-decoding logic.
                InstructionRegisterEnable = 1'b1;

                // Provide the registers involved in the load operation.
					 AMultiplexorControl  = Instruction[3:0];
                BMultiplexorControl = Instruction[11:8];
            end

            // ----------------------------------------------------
            // LOAD_2: write loaded data to the destination register
            // ----------------------------------------------------
            LOAD_2: begin
                // Select the memory-read data path for the load write-back.
                ALUMultiplexorControl = 1'b1;

                // Select the previously saved instruction rather than
                // interpreting the loaded data as an instruction.
                InstructionRegisterMultiplexorControl = 1'b1;

                // Enable the destination register.
                RegisterEnables = 16'b1 << Instruction[11:8];
            end

            // ----------------------------------------------------
            // BRANCH: conditionally update the PC
            // ----------------------------------------------------
            BRANCH: begin
                // Update the PC only if the decoded condition is satisfied.
                PCEnable = ConditionMet;

                // Select the branch-displacement path in the PC logic.
                PCMultiplexorControl = 1'b1;
            end

            // ----------------------------------------------------
            // Invalid state
            // ----------------------------------------------------
            default: begin
                // All outputs remain at their default values.
            end
        endcase
    end
	 
		assign debugRegisterInstruction 	= RegisterInstruction;
		assign debugImmediateInstruction = ImmediateInstruction;
		assign debugStoreInstruction     = StoreInstruction;
		assign debugLoadInstruction      = LoadInstruction;
		assign debugBranchInstruction    = BranchInstruction;
		assign debugConditionMet         = ConditionMet;
		assign debugCurrentState         = CurrentState;
		assign debugNextState            = NextState;

endmodule


module cpu_fsm (
    input  wire        clk,
    input  wire        reset,

    input  wire [15:0] Instruction,
    input  wire [4:0]  FlagsRegister,

    output reg         PCEnable,
    output reg         PCMultiplexorControl,
    output reg         InstructionRegisterEnable,
    output reg  [15:0] RegisterEnables,
    output reg         ImmediateMutiplexorControl,
    output reg         BramWriteEnable,
    output reg         ALUMultiplexorControl,
    output reg         LoadStoreMultiplexorControl,

    output reg  [3:0]  Rdest,
    output reg  [3:0]  Rsrc,
    output wire [7:0]  Opcode,
    output wire [7:0]  Immediate
);

    wire RegisterInstruction;
    wire ImmediateInstruction;
    wire StoreInstruction;
    wire LoadInstruction;
    wire BranchInstruction;

    assign Opcode    = {Instruction[15:12], Instruction[7:4]};
    assign Immediate = Instruction[7:0];

    // Decode the instruction type
    cpu_decoder decoder (
        .Opcode (Opcode),
        .Rtype  (RegisterInstruction),
        .Itype  (ImmediateInstruction),
        .Stype  (StoreInstruction),
        .Ltype  (LoadInstruction),
        .BJtype (BranchInstruction)
    );

    // State encoding
    localparam FETCH  = 3'd0;
    localparam DECODE = 3'd1;
    localparam RI_TYPE = 3'd2;
    localparam STORE  = 3'd3;
    localparam LOAD_1 = 3'd4;
    localparam LOAD_2 = 3'd5;
    localparam BRANCH = 3'd6;

    reg [2:0] currentState, nextState;
    reg conditionMet;

    // Evaluate branch condition
    always @(*) begin
        case (Instruction[11:8])
            4'h0: conditionMet =  FlagsRegister[1];                 // EQ
            4'h1: conditionMet = ~FlagsRegister[1];                 // NE
            4'h2: conditionMet =  FlagsRegister[4];                 // CS
            4'h3: conditionMet = ~FlagsRegister[4];                 // CC
            4'h4: conditionMet =  FlagsRegister[3];                 // HI
            4'h5: conditionMet = ~FlagsRegister[3];                 // LS
            4'h6: conditionMet =  FlagsRegister[0];                 // GT
            4'h7: conditionMet = ~FlagsRegister[0];                 // LE
            4'h8: conditionMet =  FlagsRegister[2];                 // FS
            4'h9: conditionMet = ~FlagsRegister[2];                 // FC
            4'hA: conditionMet = ~FlagsRegister[3] & ~FlagsRegister[1]; // LO
            4'hB: conditionMet =  FlagsRegister[3] | FlagsRegister[1];  // HS
            4'hC: conditionMet = ~FlagsRegister[0] & ~FlagsRegister[1]; // LT
            4'hD: conditionMet =  FlagsRegister[0] | FlagsRegister[1];  // GE
            4'hE: conditionMet = 1'b1;                              // UC
            default: conditionMet = 1'b0;
        endcase
    end

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset)
            currentState <= FETCH;
        else
            currentState <= nextState;
    end

    // Next-state logic
    always @(*) begin
        nextState = FETCH;

        case (currentState)
            FETCH: begin
                nextState = DECODE;
            end

            DECODE: begin
                if (RegisterInstruction || ImmediateInstruction)
                    nextState = RI_TYPE;
                else if (StoreInstruction)
                    nextState = STORE;
                else if (LoadInstruction)
                    nextState = LOAD_1;
                else if (BranchInstruction)
                    nextState = BRANCH;
                else
                    nextState = FETCH;
            end

            RI_TYPE: begin
                nextState = FETCH;
            end

            STORE: begin
                nextState = FETCH;
            end

            LOAD_1: begin
                nextState = LOAD_2;
            end

            LOAD_2: begin
                nextState = FETCH;
            end

            BRANCH: begin
                nextState = FETCH;
            end

            default: begin
                nextState = FETCH;
            end
        endcase
    end

    // Output logic
    always @(*) begin
        // Default outputs
        PCEnable                       = 1'b0;
        PCMultiplexorControl           = 1'b0;
        InstructionRegisterEnable      = 1'b0;
        RegisterEnables                = 16'b0;
        ImmediateMutiplexorControl     = 1'b0;
        BramWriteEnable                = 1'b0;
        ALUMultiplexorControl           = 1'b0;
        LoadStoreMultiplexorControl    = 1'b0;

        Rdest = 4'bxxxx;
        Rsrc  = 4'bxxxx;

        case (currentState)
            FETCH: begin
                // Fetch stage
            end

            DECODE: begin
                // Decode stage
            end

            RI_TYPE: begin
                PCEnable = 1'b1;
                RegisterEnables = 16'b1 << Instruction[11:8];
                ImmediateMutiplexorControl = ImmediateInstruction;

                Rdest = Instruction[11:8];
                Rsrc  = Instruction[3:0];
            end

            STORE: begin
                PCEnable = 1'b1;
                BramWriteEnable = 1'b1;
                LoadStoreMultiplexorControl = 1'b1;

                Rdest = Instruction[11:8];
                Rsrc  = Instruction[3:0];
            end

            LOAD_1: begin
                PCEnable = 1'b1;
                InstructionRegisterEnable = 1'b1; // Unclear if this should be in the first stage or second stage.
                LoadStoreMultiplexorControl = 1'b1;

                Rdest = Instruction[11:8];
                Rsrc  = Instruction[3:0];
            end

            LOAD_2: begin
                RegisterEnables = 16'b1 << Instruction[11:8];
                ALUMultiplexorControl = 1'b1;
            end

            BRANCH: begin
                PCEnable = conditionMet;
                PCMultiplexorControl = 1'b1;
            end

            default: begin
                // Keep default outputs deasserted
            end
        endcase
    end

endmodule

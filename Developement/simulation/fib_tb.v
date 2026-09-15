`timescale 1ns / 1ps

module fib_tb;

`include "../hdl/params.sv"

    // DUT inputs
    reg [3:0]  selectA;
    reg [3:0]  selectB;
    reg [15:0] registerEnables;
    reg        immediateEnable;
    reg [15:0] immediate;
    reg [7:0]  Opcode;
    reg        Cin;
    reg        clk;
    reg        reset;

    // DUT outputs
    wire [4:0]  aluFLAGOutput;
    wire [15:0] aluResult;

    // FSM State Registers
    reg [3:0] state, nextState;

    // DUT Instantiation
    datapath uut (
        .selectA(selectA),
        .selectB(selectB),
        .registerEnables(registerEnables),
        .immediateEnable(immediateEnable),
        .immediate(immediate),
        .Opcode(Opcode),
        .Cin(Cin),
        .aluFLAGOutput(aluFLAGOutput),
        .aluResult(aluResult),
        .clk(clk),
        .reset(reset)
    );

    // Clock Generation (10ns period)
    always #5 clk = ~clk;

    // Initial stimulus & monitoring
    initial begin
        clk = 0;
        reset = 1;
        Cin = 0;

        // Display output whenever aluResult changes
        $monitor("Time = %0t | State = %b | ALU Output = %d", $time, state, aluResult);

        // Release reset after 15ns
        #15 reset = 0;

        // Run simulation through all 16 states
        #200;
        $finish;
		  
    end

    // Combinational Output Logic
    always @(*) begin
        // Default resets
        registerEnables = 16'd0; 
        immediateEnable = 1'b0; 
        immediate       = 16'd0; 
        selectA         = 4'd0;
        selectB         = 4'd0;
        Opcode          = 8'd0;

        case (state)
            // Seed R0 = 1
            4'b0000 : begin selectA = 4'd0; selectB = 4'd0; Opcode = ADDUI; registerEnables[0] = 1; immediateEnable = 1; immediate = 16'd1; end
            // Seed R1 = 1
            4'b0001 : begin selectA = 4'd0; selectB = 4'd0; Opcode = ADDUI; registerEnables[1] = 1; immediateEnable = 1; immediate = 16'd1; end
            // Start sequence: R2 = R0 + R1
            4'b0010 : begin selectA = 4'd0; selectB = 4'd1; Opcode = ADDU;  registerEnables[2] = 1; end
            4'b0011 : begin selectA = 4'd1; selectB = 4'd2; Opcode = ADDU;  registerEnables[3] = 1; end
            4'b0100 : begin selectA = 4'd2; selectB = 4'd3; Opcode = ADDU;  registerEnables[4] = 1; end
            4'b0101 : begin selectA = 4'd3; selectB = 4'd4; Opcode = ADDU;  registerEnables[5] = 1; end
            4'b0110 : begin selectA = 4'd4; selectB = 4'd5; Opcode = ADDU;  registerEnables[6] = 1; end
            4'b0111 : begin selectA = 4'd5; selectB = 4'd6; Opcode = ADDU;  registerEnables[7] = 1; end
            4'b1000 : begin selectA = 4'd6; selectB = 4'd7; Opcode = ADDU;  registerEnables[8] = 1; end
            4'b1001 : begin selectA = 4'd7; selectB = 4'd8; Opcode = ADDU;  registerEnables[9] = 1; end
            4'b1010 : begin selectA = 4'd8; selectB = 4'd9; Opcode = ADDU;  registerEnables[10] = 1; end
            4'b1011 : begin selectA = 4'd9; selectB = 4'd10; Opcode = ADDU; registerEnables[11] = 1; end
            4'b1100 : begin selectA = 4'd10; selectB = 4'd11; Opcode = ADDU; registerEnables[12] = 1; end
            4'b1101 : begin selectA = 4'd11; selectB = 4'd12; Opcode = ADDU; registerEnables[13] = 1; end
            4'b1110 : begin selectA = 4'd12; selectB = 4'd13; Opcode = ADDU; registerEnables[14] = 1; end
            4'b1111 : begin selectA = 4'd13; selectB = 4'd14; Opcode = ADDU; registerEnables[15] = 1; end
            default : begin 
                registerEnables = 16'd0; 
                immediateEnable = 1'b0; 
                immediate       = 16'd0; 
                selectA         = 4'd0; 
                selectB         = 4'd0; 
                Opcode          = 8'd0; 
            end
        endcase
    end

    // Next State Logic
    always @(*) begin
        case (state)
            4'b0000 : nextState = 4'b0001;
            4'b0001 : nextState = 4'b0010;
            4'b0010 : nextState = 4'b0011;
            4'b0011 : nextState = 4'b0100;
            4'b0100 : nextState = 4'b0101;
            4'b0101 : nextState = 4'b0110;
            4'b0110 : nextState = 4'b0111;
            4'b0111 : nextState = 4'b1000;
            4'b1000 : nextState = 4'b1001;
            4'b1001 : nextState = 4'b1010;
            4'b1010 : nextState = 4'b1011;
            4'b1011 : nextState = 4'b1100;
            4'b1100 : nextState = 4'b1101;
            4'b1101 : nextState = 4'b1110;
            4'b1110 : nextState = 4'b1111;
            4'b1111 : nextState = 4'b1111; // Hold state
            default : nextState = 4'bxxxx;
        endcase
    end

    // Sequential State Register Update
    always @(posedge reset or posedge clk) begin
        if (reset) begin
            state <= 4'b0000;
        end else begin
            state <= nextState;
        end
    end

endmodule
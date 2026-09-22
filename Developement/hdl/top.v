// This program is intended to take input n (maximum value of 361), and compute the sum of all the integers from 1 up to n. 

module top(
input n,
output Result
)

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
    reg [4:0] state, nextState;

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
	 
	 // Sequencer
	 
	 reg [8:0] n;
	 
	 // Combinational Output Logic
    always @(*) begin
        // Default resets
        registerEnables = 16'd0;
        immediateEnable = 1'b0;
        immediate       = 16'd0;
        selectA         = 4'd0;
        selectB         = 4'd0;
        Opcode          = 8'd0;

		always @(*) begin
			 case (state)

				  5'd0: begin
						selectA = 4'd0; selectB = 4'd0; Opcode = ADDUI; registerEnables[0] = 1; immediateEnable = 1; immediate = n;
				  end

				  5'd1: begin
						
				  end

				  5'd2: begin
				  end

				  5'd3: begin
				  end

				  5'd4: begin
				  end

				  5'd5: begin
				  end

				  5'd6: begin
				  end

				  5'd7: begin
				  end

				  5'd8: begin
				  end

				  5'd9: begin
				  end

				  5'd10: begin
				  end

				  5'd11: begin
				  end

				  5'd12: begin
				  end

				  5'd13: begin
				  end

				  5'd14: begin
				  end

				  5'd15: begin
				  end

				  default: begin
				  end

			 end

		// Next State Logic
		always @(*) begin
			 case (state)
				  5'd0  : nextState = 5'd1;
				  5'd1  : nextState = 5'd2;
				  5'd2  : nextState = 5'd3;
				  5'd3  : nextState = 5'd4;
				  5'd4  : nextState = 5'd5;
				  5'd5  : nextState = 5'd6;
				  5'd6  : nextState = 5'd7;
				  5'd7  : nextState = 5'd8;
				  5'd8  : nextState = 5'd9;
				  5'd9  : nextState = 5'd10;
				  5'd10 : nextState = 5'd11;
				  5'd11 : nextState = 5'd12;
				  5'd12 : nextState = 5'd13;
				  5'd13 : nextState = 5'd14;
				  5'd14 : nextState = 5'd15;
				  5'd15 : nextState = 5'd15;  // Hold state
				  default : nextState = 5'd0;
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
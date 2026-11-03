module flagReg(
    input [4:0] ALUFlags,
    input       clk,
    input       reset,
	 input		 FlagsRegisterEnable,
    output reg [4:0] FlagsOut
);

    always @(posedge clk or posedge reset)
    begin
        if (reset)
            FlagsOut <= 5'b00000;
        else if (FlagsRegisterEnable)
            FlagsOut <= ALUFlags;
    end

endmodule
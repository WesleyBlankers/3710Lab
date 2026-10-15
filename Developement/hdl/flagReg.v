module flagReg(
    input [4:0] ALUFlags,
	 input		 flagEn,
    input       clk,
    input       reset,
    output reg [4:0] FlagsOut
);

    always @(posedge clk or posedge reset)
    begin
        if (reset)
            FlagsOut <= 5'b00000;
        else if (flagEn)
            FlagsOut <= ALUFlags;
    end

endmodule
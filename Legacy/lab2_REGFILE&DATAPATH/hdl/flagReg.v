module flagReg(
    input [4:0] ALUFlags,
    input       clk,
    input       reset,
    output reg [4:0] FlagsOut
);

    always @(posedge clk or posedge reset)
    begin
        if (reset)
            FlagsOut <= 5'b00000;
        else
            FlagsOut <= ALUFlags;
    end

endmodule
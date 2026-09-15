module flagReg(
    ALUFlags,
    FlagsOut,
    clk,
    reset
);

    input [4:0] ALUFlags;
    input       flagEnable;
    input       clk;
    input       reset;

    output [4:0] FlagsOut;

    reg [4:0] flags;

    always @(posedge clk)
    begin
        if (reset)
            flags <= 5'b00000;
        else
            flags <= ALUFlags;
    end

    assign FlagsOut = flags;

endmodule